#!/usr/bin/env node
"use strict";
// Valida que existen EXACTAMENTE las dos entradas solicitadas y archiva
// una copia de la biblioteca local ANTES de cualquier modificación por Qt.
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const crypto = require("node:crypto");
const vm = require("node:vm");

const logFile = process.argv[2];
if (!logFile) { console.error("Falta el registro de lectura Qt."); process.exit(2); }
const lines = fs.readFileSync(logFile, "utf8").split(/\r?\n/);
const marker = "SMARTBAR_DAY_CLEANUP_LIBRARY=";
const matches = lines.filter(line => line.includes(marker));
if (matches.length !== 1) {
    console.error("No se pudo leer una biblioteca inequívoca desde Qt; no se eliminará nada.");
    process.exit(3);
}
let raw, items;
try {
    raw = JSON.parse(matches[0].slice(matches[0].indexOf(marker) + marker.length));
    if (typeof raw !== "string") throw Error("no es una cadena");
    items = JSON.parse(raw);
} catch (e) {
    console.error("La biblioteca local no es JSON válido; no se eliminará nada:", e.message);
    process.exit(4);
}

const script = fs.readFileSync(path.join(__dirname, "../package/contents/ui/DayEntryCleanup.js"), "utf8");
const cleanup = {};
vm.runInNewContext(script.replace(/^\s*\.pragma library\s*/, ""), cleanup);
const plan = cleanup.plan(items);
if (!plan.ok) {
    console.error(plan.reason);
    process.exit(5);
}
const root = path.join(process.env.XDG_DATA_HOME || path.join(os.homedir(), ".local", "share"),
                       "plasma-smartbar", "resguardos-temas");
fs.mkdirSync(root, {recursive:true, mode:0o700});
const dir = fs.mkdtempSync(path.join(root, "antes-quitar-dos-dia-"));
fs.chmodSync(dir, 0o700);
const snapshot = path.join(dir, "biblioteca-original.json");
fs.writeFileSync(snapshot, raw + "\n", {mode:0o600, flag:"wx"});
const digest = crypto.createHash("sha256").update(raw).digest("hex");
fs.writeFileSync(path.join(dir, "MANIFIESTO.json"),
    JSON.stringify({reason:"Retiro autorizado de dos entradas Día",sha256:digest,
       removedNames:plan.removed,originalCount:items.length,
       remainingCount:plan.items.length}, null, 2) + "\n",
    {mode:0o600,flag:"wx"});
// Comprobar la copia antes de autorizar la escritura de Qt Settings.
const reread = fs.readFileSync(snapshot, "utf8").replace(/\n$/, "");
if (reread !== raw) {
    console.error("No se pudo verificar el respaldo: aborto sin modificar Qt.");
    process.exit(6);
}
console.log("Respaldo íntegro creado en: " + snapshot);
console.log("Entradas que se eliminarán: " + plan.removed.join(" | "));
