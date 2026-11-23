// Regresión estática aislada: LayerShell solo en la isla, no en las
// ventanas normales Qt; diagnosticar IA sin volcar prompts a logs.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const load = p => fs.readFileSync(path.join(base, p), "utf8");
const runner = load("probar_malvina_superposicion.sh");
const probe = load("preview_malvina_input_mask.qml");
const settings = load("package/contents/ui/SoledadSettings.qml");
const search = load("package/contents/ui/MalvinaSearch.qml");

assert(runner.includes("env -u QT_WAYLAND_SHELL_INTEGRATION QT_QPA_PLATFORM=wayland"));
assert(!/env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell/.test(runner),
       "No imponer LayerShell globalmente sobre Configuración");
assert(probe.includes("LayerShell.Window.anchors:") &&
       probe.includes("LayerShell.Window.layer: LayerShell.Window.LayerTop"),
       "Solo la superficie superior debe tener layer-shell");
assert(settings.includes("flags: Qt.Window | Qt.WindowTitleHint") &&
       settings.includes("transientParent: null") &&
       settings.includes("modality: Qt.NonModal"),
       "Configuración solicita ventana convencional no modal");
assert(search.includes("SmartBar MALVINA diagnóstico IA:"));
assert(search.includes("consultaEnEnlace="));
assert(search.includes("permiso="));
assert(search.includes('result.url.indexOf("?q=" + encodeURIComponent(query)) >= 0'));
const logStart = search.indexOf('console.log("SmartBar MALVINA diagnóstico IA:"');
const logEnd = search.indexOf(")",logStart);
const diagnostic = search.slice(logStart,logEnd);
assert(!diagnostic.includes("queryText") &&
       !diagnostic.includes("result.url") &&
       !diagnostic.includes("query,"),
       "El log no debe incluir consulta ni URL completa");
console.log("OK: LayerShell selectivo y diagnóstico IA sin datos sensibles.");
