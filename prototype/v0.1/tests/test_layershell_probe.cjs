"use strict";
// Prueba estática de seguridad, NO certifica que KWin permita clics pasantes.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = name => fs.readFileSync(path.join(base,name),"utf8");
const qml = read("preview_superposicion_layershell.qml");
const runner = read("probar_superposicion_layershell.sh");
const installed = read("package/contents/ui/main.qml");
const viewer = read("preview_redimensionable.qml");
for (const key of [
    "import org.kde.layershell 1.0 as LayerShell",
    "LayerShell.Window.anchors:",
    "LayerShell.Window.AnchorTop",
    "LayerShell.Window.AnchorRight",
    "LayerShell.Window.layer: LayerShell.Window.LayerTop",
    "LayerShell.Window.exclusionZone: -1",
    "LayerShell.Window.KeyboardInteractivityNone",
    "Qt.WindowTransparentForInput",
    "Qt.WindowDoesNotAcceptFocus",
    "width: 456",
    "height: 44",
    "interval: 60000",
    "onTriggered: probe.close()"
]) assert(qml.includes(key),"Falta garantía LayerShellQt: "+key);
assert(!/^\s*(?:x|y)\s*:/m.test(qml),
       "No confiar en x/y de ventanas normales Wayland");
assert(runner.includes("QT_WAYLAND_SHELL_INTEGRATION=layer-shell"));
assert(runner.includes("QT_QPA_PLATFORM=wayland"));
assert(runner.includes("XDG_SESSION_TYPE"));
assert(runner.includes("WAYLAND_DISPLAY"));
assert(runner.includes("exec env "));
for (const forbidden of [
    "plasmapkg", "kpackagetool", "kwriteconfig", "sudo ",
    "qdbus", "kwinrc", "pacman -S", "systemctl",
    "killall", "pkill", "rm -rf"
]) assert(!runner.includes(forbidden),"Lanzador peligroso: "+forbidden);
for (const forbidden of [
    "QtCore.Settings", "TasksModel", "requestActivate",
    "requestClose", "MouseArea", "onClicked:", "WindowDoesNotAcceptFocus: false"
]) assert(!qml.includes(forbidden),"La superficie debe ser completamente pasiva: "+forbidden);
assert(!installed.includes("preview_superposicion_layershell"));
assert(!viewer.includes("preview_superposicion_layershell"));
console.log("OK: LayerShellQt anclado, pasivo, sin zona exclusiva y cierre temporal.");
