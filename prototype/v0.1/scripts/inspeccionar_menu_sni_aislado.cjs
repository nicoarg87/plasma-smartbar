#!/usr/bin/env node
"use strict";
// Ensayo de DBusMenu completamente SEPARADO de Soledad/Malvina.
// Lee la firma de GetLayout con busctl como proceso hijo; nunca convierte
// QDBusArgument, ejecuta Event/Activate ni registra otro host de KDE.
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const {execFileSync} = require("node:child_process");

if (process.argv.length !== 2) {
    console.error("Uso: node prototype/v0.1/scripts/inspeccionar_menu_sni_aislado.cjs");
    process.exit(2);
}
const ids = {};
const idsPath = path.resolve(__dirname, "../package/contents/ui/StatusNotifierIds.js");
vm.runInNewContext(
    fs.readFileSync(idsPath, "utf8").replace(/^\.pragma library\s*/, ""), ids
);
const watcherNames = ["org.kde.StatusNotifierWatcher",
                      "org.freedesktop.StatusNotifierWatcher"];
const itemInterfaces = ["org.kde.StatusNotifierItem",
                        "org.freedesktop.StatusNotifierItem"];
const validObjectPath = /^\/(?:[A-Za-z0-9_]+(?:\/[A-Za-z0-9_]+)*)?$/;
function busctl(args, maxBuffer = 65536) {
    try {
        return execFileSync("busctl", ["--user", "--no-pager", ...args],
            {encoding:"utf8", timeout:2800, maxBuffer,
             stdio:["ignore","pipe","ignore"]}).trim();
    } catch (_) { return null; }
}
function dbusQuoted(raw, signature) {
    if (!raw) return null;
    const m = raw.match(/^([a-z]+)\s+("(?:[^"\\]|\\.)*")$/);
    if (!m || m[1] !== signature) return null;
    try { return JSON.parse(m[2]); } catch (_) { return null; }
}
function items(raw) {
    if (!raw) return null;
    const m = raw.match(/^as\s+(\d+)(?:\s+(.*))?$/s);
    if (!m) return null;
    const expected = Number(m[1]);
    if (!Number.isSafeInteger(expected) || expected > 128) return null;
    const text = m[2] || "";
    const found = [...text.matchAll(/"([^"\\]*)"/g)].map(x => x[1]);
    if (found.length !== expected) return null;
    return ids.normalizeRegisteredIds(found);
}
let registered = null;
let watcherName = "";
for (const watcher of watcherNames) {
    const list = items(busctl(["get-property", watcher, "/StatusNotifierWatcher",
                               watcher, "RegisteredStatusNotifierItems"]));
    if (list !== null) { registered = list; watcherName = watcher; break; }
}
if (registered === null) {
    console.error("No se encontró un watcher SNI consultable. KDE no fue modificado.");
    process.exit(4);
}
console.log("Diagnóstico DBusMenu aislado · " + watcherName);
console.log("Indicadores registrados: " + registered.length);
let candidateCount = 0, validReplies = 0, failedReplies = 0;
for (const item of registered.slice(0, 16)) {
    let menuPath = null;
    for (const iface of itemInterfaces) {
        menuPath = dbusQuoted(busctl(["get-property", item.service, item.objectPath,
                                      iface, "Menu"]), "o");
        if (menuPath !== null) break;
    }
    if (menuPath === null || menuPath === "/") continue;
    if (!validObjectPath.test(menuPath) || menuPath.length > 256) continue;
    candidateCount++;
    // Consulta estándar iias: parentId=0, depth=1 y propiedades limitadas.
    // La ejecución completa y su deserialización compleja corren en busctl,
    // no en el proceso Qt de las islas; nunca invoca clics ni Event().
    const reply = busctl(["--json=short", "--timeout=2s", "call",
                          item.service, menuPath, "com.canonical.dbusmenu",
                          "GetLayout", "iias", "0", "1", "5",
                          "label", "enabled", "visible", "type",
                          "children-display"], 131072);
    if (!reply) {
        failedReplies++;
        console.log("Menú " + candidateCount + ": GetLayout no respondió o excedió los límites.");
        continue;
    }
    try {
        const value = JSON.parse(reply);
        const signature = value && typeof value === "object" ? value.type : null;
        if (signature === "u(ia{sv}av)" && Array.isArray(value.data) &&
            value.data.length === 2) {
            validReplies++;
            console.log("Menú " + candidateCount +
                        ": respuesta recibida; firma u(ia{sv}av) válida.");
        } else {
            failedReplies++;
            console.log("Menú " + candidateCount +
                        ": JSON recibido, formato distinto; no se interpretó.");
        }
    } catch (_) {
        failedReplies++;
        console.log("Menú " + candidateCount +
                    ": respuesta no compatible con JSON; no se interpretó.");
    }
}
console.log("Menús anunciados: " + candidateCount);
console.log("Respuestas compatibles: " + validReplies);
console.log("Respuestas no compatibles o fallidas: " + failedReplies);
console.log("Solo lectura. Ningún menú fue ejecutado; Soledad y Malvina no se iniciaron.");
