#!/usr/bin/env node
"use strict";
// Exploración puntual de títulos e iconos SNI publicados por KDE.
// SOLO LECTURA: no registra hosts, no invoca acciones ni modifica el panel.
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const {execFileSync} = require("node:child_process");

if (process.argv.length !== 2) {
    console.error("Uso: node prototype/v0.1/scripts/inspeccionar_bandeja_sni_detalle.cjs");
    process.exit(2);
}

const modelPath = path.resolve(__dirname, "../package/contents/ui/StatusNotifierIds.js");
const moduleSource = fs.readFileSync(modelPath, "utf8");
const model = {};
vm.runInNewContext(moduleSource.replace(/^\.pragma library\s*/, ""), model);

function property(service, objectPath, iface, name) {
    try {
        return execFileSync("busctl", [
            "--user", "--no-pager", "get-property",
            service, objectPath, iface, name
        ], {encoding:"utf8", timeout:2500, maxBuffer:65536,
            stdio:["ignore", "pipe", "ignore"]}).trim();
    } catch (_) {
        return null;
    }
}
function quotedValue(response, kind) {
    if (!response) return null;
    const match = response.match(new RegExp("^" + kind + '\\s+("(?:[^"\\\\]|\\\\.)*")$'));
    if (!match) return null;
    try { return JSON.parse(match[1]); } catch (_) { return null; }
}
function registered(response) {
    if (!response) return null;
    const match = response.match(/^as\s+(\d+)(?:\s+([\s\S]*))?$/);
    if (!match) return null;
    const count = Number(match[1]);
    if (!Number.isSafeInteger(count) || count > 128) return null;
    const suffix = match[2] || "";
    const extracted = [...suffix.matchAll(/"([^"\\]*)"/g)].map(m => m[1]);
    if (extracted.length !== count) return null;
    return model.normalizeRegisteredIds(extracted);
}
function safe(value) {
    return String(value || "").replace(/[\x00-\x1f\x7f-\x9f]/g, " ").slice(0, 180);
}
const watcherNames = [
    "org.kde.StatusNotifierWatcher",
    "org.freedesktop.StatusNotifierWatcher"
];
let entries = null;
let watcherName = null;
for (const name of watcherNames) {
    entries = registered(property(name, "/StatusNotifierWatcher", name,
                                  "RegisteredStatusNotifierItems"));
    if (entries !== null) { watcherName = name; break; }
}
if (entries === null) {
    console.error("No se pudo consultar un watcher SNI. No se modificó KDE.");
    process.exit(4);
}
console.log("Bandeja KDE (solo lectura) · " + watcherName);
console.log("Indicadores SNI registrados: " + entries.length);
const itemInterfaces = ["org.kde.StatusNotifierItem", "org.freedesktop.StatusNotifierItem"];
for (const entry of entries) {
    let details = null;
    for (const iface of itemInterfaces) {
        const fields = {};
        for (const name of ["Id", "Title", "Status", "IconName"]) {
            fields[name] = quotedValue(property(entry.service, entry.objectPath, iface, name), "s");
        }
        if (Object.values(fields).some(v => v !== null)) {
            const menu = quotedValue(property(entry.service, entry.objectPath, iface, "Menu"), "o");
            details = {...fields, menu};
            break;
        }
    }
    console.log("\nServicio: " + safe(entry.service));
    console.log("Ruta: " + safe(entry.objectPath));
    if (!details) {
        console.log("Información de aplicación no disponible (el servicio puede haberse cerrado).");
        continue;
    }
    console.log("Aplicación: " + safe(details.Id || "sin Id"));
    console.log("Título: " + safe(details.Title || "sin título"));
    console.log("Estado: " + safe(details.Status || "desconocido"));
    console.log("Nombre de icono: " + safe(details.IconName || "sin nombre; podría usar pixmap"));
    console.log("Menú remoto anunciado: " + (details.menu && details.menu !== "/" ? "sí" : "no/no disponible"));
}
console.log("\nConsulta terminada. No se ejecutaron acciones ni se modificaron registros.");
