"use strict";
// Prueba estática: no sustituye la carga real de Qt/LayerShell en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(root, file), "utf8");

const launcher = read("probar_islas_juntas.sh");
const native = read("native_probes/soledad_input_mask_main.cpp");
const so = read("preview_soledad_input_mask.qml");
const mal = read("preview_malvina_input_mask.qml");
const source = read("package/contents/ui/SmartBarContent.qml");

assert(launcher.startsWith("#!/usr/bin/env bash"));
for (const requirement of [
    'XDG_SESSION_TYPE:-', 'WAYLAND_DISPLAY:-',
    'mktemp -d', 'QT_QPA_PLATFORM=wayland',
    'SMARTBAR_CONTINUOUS=1', 'wait -n "$SO_PID" "$MAL_PID"',
    'trap finish EXIT', 'trap \'exit 130\' INT',
    'soledad.log', 'malvina.log', 'compilacion.log',
    'preview_soledad_input_mask.qml',
    'preview_malvina_input_mask.qml',
    'env -u QT_WAYLAND_SHELL_INTEGRATION',
    'chmod 700 -- "$LOG_ROOT"',
    'rm -rf -- "$BUILD_DIR"'
]) assert(launcher.includes(requirement), "Falta contrato: " + requirement);
assert(!/\b(sudo|kpackagetool6|plasmapkg2|kwriteconfig6|systemctl|killall|pkill)\b/.test(launcher),
       "El ensayo no debe instalar, cambiar paneles, activar servicios o matar procesos ajenos");
assert(native.includes('qEnvironmentVariableIntValue("SMARTBAR_CONTINUOUS") == 1'),
       "El modo continuo debe ser explícito y desactivado por defecto");
assert(native.includes('setContextProperty(\n        "smartbarContinuousMode"'),
       "El puente debe exponer la preferencia temporal a ambos QML");
assert(so.includes('running: !smartbarContinuousMode'),
       "Soledad no debe autocerrarse en modo conjunto");
assert(mal.includes('running: !smartbarContinuousMode'),
       "Malvina no debe autocerrarse en modo conjunto");
assert(mal.includes('autoHideMalvina: smartbarContinuousMode'),
       "En modo conjunto Malvina conserva el autoocultamiento");
assert(so.includes('LayerShell.Window.KeyboardInteractivityNone'));
assert(mal.includes('LayerShell.Window.KeyboardInteractivityOnDemand'));
assert(so.includes('realTaskModel: groupedKdeWindows'),
       "Soledad sigue usando el modelo KDE real de solo lectura");
assert(so.includes('refreshInputRegion') && mal.includes('refreshInputRegion'),
       "Ambas islas necesitan región de entrada limitada");
assert(source.includes('readonly property bool autoRevealBlocked:'),
       "Conservar el bloqueo cuando el estado KDE sea desconocido o fullscreen");
console.log("OK: contrato estático de ejecución conjunta segura");
