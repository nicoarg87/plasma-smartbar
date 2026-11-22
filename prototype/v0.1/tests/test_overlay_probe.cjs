"use strict";
// Contrato estático de superficie Qt descartable; NO acredita KWin/Wayland.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(base, file), "utf8");
const probe = read("OverlayProbe.qml");
const passive = read("preview_superposicion_pasivo.qml");
const active = read("preview_superposicion_interactivo.qml");
const shell = read("probar_superposicion.sh");
const plasma = read("package/contents/ui/main.qml");
const viewer = read("preview_redimensionable.qml");

for (const marker of [
    "import QtQuick", "import QtQuick.Window", "Window {",
    "property bool clickThrough: true", "Qt.Tool",
    "Qt.FramelessWindowHint", "Qt.WindowStaysOnTopHint",
    "Qt.WindowTransparentForInput", "Qt.WindowDoesNotAcceptFocus",
    "enabled: !overlay.clickThrough",
    "onClicked: overlay.observedClicks += 1",
    "Keys.onEscapePressed: overlay.close()",
    "interval: 60000", "onTriggered: overlay.close()",
    'color: "transparent"', "Screen.virtualX", "Screen.virtualY"
]) assert(probe.includes(marker), "Falta garantía en QML temporal: "+marker);
assert(passive.includes("OverlayProbe {") && passive.includes("clickThrough: true"));
assert(active.includes("OverlayProbe {") && active.includes("clickThrough: false"));
assert(shell.includes('MODE="${1:-pasivo}"') || shell.includes('MODE="${1:-pasivo}"'));
assert(shell.includes("pasivo|interactivo"));
assert(shell.includes("preview_superposicion_"));
assert(shell.includes('exec "$QML_RUNNER"'));
assert(!shell.includes("plasmapkg") && !shell.includes("kpackagetool") &&
       !shell.includes("sudo") && !shell.includes("kwriteconfig") &&
       !shell.includes("kwinrc"));
for (const forbidden of [
    "QtCore.Settings", "KConfig", "TasksModel", "requestClose(",
    "requestActivate(", "requestToggleMaximized(", "setPosition(",
    "KWin.registerWindow", "ShellSurface", "subprocess", "org.kde.plasma",
    "WindowType.Dock", "TaskManager"
]) assert(!probe.includes(forbidden), "La prueba no debe controlar KDE/guardar datos: "+forbidden);
assert(!plasma.includes("OverlayProbe") && !plasma.includes("preview_superposicion"));
assert(!viewer.includes("OverlayProbe") && !viewer.includes("preview_superposicion"),
    "No tocar el visor con preferencias reales ni la estética existente");
console.log("OK: overlay Qt pasivo/interactivo aislado, 60s de autocierre y sin panel ni preferencias.");
