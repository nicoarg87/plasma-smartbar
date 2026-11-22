"use strict";
// Regresión ESTÁTICA: no equivale a verificar KWin/Wayland o pestañas.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root,p),"utf8");
const qml = read("preview_superposicion_mixta.qml");
const shell = read("probar_superposicion_mixta.sh");
const plasma = read("package/contents/ui/main.qml");
const original = read("preview_redimensionable.qml");
const priorPassive = read("preview_superposicion_layershell.qml");
assert(qml.includes("import org.kde.layershell 1.0 as LayerShell"));
assert(qml.includes("QtObject {"));
for(const marker of [
    "property Window passThrough: Window {",
    "property Window interactive: Window {",
    "property Timer timeout: Timer {",
    "LayerShell.Window.AnchorTop",
    "LayerShell.Window.AnchorRight",
    "LayerShell.Window.LayerTop",
    "LayerShell.Window.KeyboardInteractivityNone",
    "Qt.WindowTransparentForInput",
    "Qt.WindowDoesNotAcceptFocus",
    "Qt.FramelessWindowHint",
    "LayerShell.Window.margins: ({left: 0, top: 6, right: 76, bottom: 0})",
    "LayerShell.Window.margins: ({left: 0, top: 6, right: 12, bottom: 0})",
    "acceptedButtons: Qt.LeftButton",
    "experiment.receivedClicks += 1",
    "interval: 60000",
    "Qt.quit()"
]) assert(qml.includes(marker),"Falta garantía ensayo mixto: "+marker);
assert.equal((qml.match(/LayerShell.Window.exclusionZone: -1/g)||[]).length,2,
    "Ambas superficies deben no reservar espacio ni cambiar la maximización.");
assert.equal((qml.match(/LayerShell.Window.anchors: /g)||[]).length,2);
assert.equal((qml.match(/LayerShell.Window.margins: /g)||[]).length,2);
assert.equal((qml.match(/visible: true/g)||[]).length,2);
assert.equal((qml.match(/MouseArea \{/g)||[]).length,1,
    "Solo la superficie pequeña recibe clics.");
assert.equal((qml.match(/Qt.WindowTransparentForInput/g)||[]).length,1,
    "Solo la superficie pasante debe tener input vacío.");
assert(!/\b(?:x|y)\s*:/.test(qml),"No posicionar a la fuerza con coordenadas XDG.");
assert(!qml.includes("LayerShell.Window.LayerOverlay"),
    "No mostrar la prueba sobre fullscreen con capa Overlay.");
for(const forbidden of ["QtCore.Settings", "TaskManager", "requestActivate(",
    "requestClose(", "setGeometry(", "setPosition(", "PlasmaShell",
    "ThemePack", "ThemeSchedule"]) assert(!qml.includes(forbidden));
for(const marker of ["XDG_SESSION_TYPE", "WAYLAND_DISPLAY",
    "QT_QPA_PLATFORM=wayland", "QT_WAYLAND_SHELL_INTEGRATION=layer-shell",
    'exec env ', "preview_superposicion_mixta.qml"]) {
    assert(shell.includes(marker),"Lanzador incompleto: "+marker);
}
for(const forbidden of ["sudo ", "pacman -S", "plasmapkg", "kpackagetool",
    "kwriteconfig", "qdbus", "systemctl", "pkill", "killall", "rm -rf"])
    assert(!shell.includes(forbidden),"Lanzador invasivo: "+forbidden);
assert(!plasma.includes("preview_superposicion_mixta"));
assert(!original.includes("preview_superposicion_mixta"));
assert(priorPassive.includes("Qt.WindowTransparentForInput"),
    "Conservar el experimento anterior ya validado, sin sobreescribirlo.");
console.log("OK: dos LayerShellQt autónomas con entrada separada, sin panel ni cambios del usuario.");
