"use strict";
// Aísla el fallo del ensayo de dos ventanas. Solo prueba el contrato QML,
// NO es un resultado de entrada de KWin/Wayland.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(base,file),"utf8");
const qml = read("preview_superposicion_interactiva_layershell.qml");
const script = read("probar_so_interactivo.sh");
const mixed = read("preview_superposicion_mixta.qml");
const viewer = read("preview_redimensionable.qml");
const plasma = read("package/contents/ui/main.qml");
for (const marker of [
    "Window {", "LayerShell.Window.AnchorTop", "LayerShell.Window.AnchorRight",
    "LayerShell.Window.LayerTop", "LayerShell.Window.exclusionZone: -1",
    "LayerShell.Window.KeyboardInteractivityNone",
    "flags: Qt.Window | Qt.FramelessWindowHint",
    "width: 64", "height: 48",
    'source: Qt.resolvedUrl("package/contents/ui/assets/so-tropical.gif")',
    "AnimatedImage {", "MouseArea {", "hoverEnabled: true",
    "acceptedButtons: Qt.LeftButton | Qt.RightButton",
    "onEntered:", "onPressed: function(mouse)", "testWindow.pressCount += 1",
    "HOVER RECIBIDO", "PULSACION RECIBIDA",
    "interval: 60000", "onTriggered: testWindow.close()"
]) assert(qml.includes(marker),"Falta condición ensayo aislado: "+marker);
assert.equal((qml.match(/\bWindow\s*\{/g)||[]).length,1,
    "Tiene que existir una sola ventana para distinguir conflicto entre superficies");
assert.equal((qml.match(/\bMouseArea\s*\{/g)||[]).length,1,
    "Tiene que existir exactamente un receptor de entrada");
assert(!qml.includes("Qt.WindowTransparentForInput") ||
       qml.includes('"No se usa Qt.WindowTransparentForInput."'));
assert(!qml.includes("WindowDoesNotAcceptFocus"));
assert(!qml.includes("QtCore.Settings") &&
       !qml.includes("requestActivate(") && !qml.includes("requestClose("));
for (const marker of [
    "XDG_SESSION_TYPE", "WAYLAND_DISPLAY", "QT_QPA_PLATFORM=wayland",
    "QT_WAYLAND_SHELL_INTEGRATION=layer-shell",
    "preview_superposicion_interactiva_layershell.qml", "exec env"
]) assert(script.includes(marker),"Falta condición en lanzador: "+marker);
for (const marker of ["sudo ", "pacman -S", "plasmapkg", "kpackagetool",
                      "kwriteconfig", "qdbus", "systemctl", "pkill", "killall"]) {
    assert(!script.includes(marker),"Lanzador con efectos no autorizados: "+marker);
}
assert(mixed.includes("property Window passThrough: Window {"),
    "No sobreescribir la prueba mixta fallida: conservarla como evidencia");
assert(!viewer.includes("preview_superposicion_interactiva_layershell"));
assert(!plasma.includes("preview_superposicion_interactiva_layershell"));
console.log("OK: prueba diferencial SO con ventana única, eventos y GIF, sin modificar KDE.");
