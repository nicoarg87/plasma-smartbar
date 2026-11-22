"use strict";
// La prueba carga el componente REAL, pero no lo instala en Plasma.
// Este test es ESTÁTICO: la movilidad en KWin debe probarse en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(base, file), "utf8");
const qml = read("preview_soledad_layershell.qml");
const runner = read("probar_soledad_layershell.sh");
const bar = read("package/contents/ui/SmartBarContent.qml");
const viewer = read("preview_redimensionable.qml");
const plasma = read("package/contents/ui/main.qml");

for (const text of [
    'import "package/contents/ui" as SmartBar',
    "SmartBar.SmartBarContent {",
    "LayerShell.Window.AnchorTop",
    "LayerShell.Window.AnchorRight",
    "LayerShell.Window.LayerTop",
    "LayerShell.Window.exclusionZone: -1",
    "LayerShell.Window.KeyboardInteractivityNone",
    "flags: Qt.Window | Qt.FramelessWindowHint",
    'color: "transparent"',
    "width: Math.max(1, Math.ceil(bar.actualIslandWidth))",
    "height: 44",
    "width: Math.max(760, probe.Screen.width)",
    "x: -(width - actualIslandWidth - islandOffset - controlsReservation)",
    "right: 12 + Math.round(bar.islandOffset)",
    "positionMode: \"right\"",
    "launcherIslandVisible: false",
    "demoWindowControlsEnabled: false",
    "soLogoMode: \"default\"",
    "themeScheduleRuntimeEnabled: false",
    "interval: 90000",
    "onTriggered:"
]) assert(qml.includes(text), "Falta la condición de ensayo: " + text);
assert.equal((qml.match(/SmartBar\.SmartBarContent\s*\{/g)||[]).length, 1,
    "Debe montarse el componente REAL, exactamente una vez.");
assert(!qml.includes("AnimatedImage {") && !qml.includes("QQC2.Button {") &&
       !qml.includes("MouseArea {"),
       "No duplicar ni inventar el GIF, los controles o el agarre original.");
assert(!qml.includes("WindowTransparentForInput"),
       "La ISLA REAL debe ser sólida e interactiva, nunca clic-pasante.");
assert(!qml.includes("LayerShell.Window.LayerOverlay"),
       "No usar overlay por encima de fullscreen real.");
assert(!qml.includes("QtCore.Settings") && !qml.includes("Settings {"),
       "No leer ni escribir configuración personal en el ensayo.");
assert(bar.includes('readonly property url defaultSoLogo: Qt.resolvedUrl("assets/so-tropical.gif")'));
assert(bar.includes("id: moveGrip") && bar.includes("id: gripDrag"));
assert(bar.includes("root.setIslandOffset("));
assert(bar.includes("readonly property real actualIslandWidth: systemIsland.width"));
assert(bar.includes("id: systemIsland"));
assert(bar.includes("id: soButton"));
assert(bar.includes("id: trayToggle"));
assert(bar.includes("onActiveTranslationChanged:"));
assert(!/\b(?:x|y)\s*:/.test(qml.slice(0, qml.indexOf("SmartBar.SmartBarContent {"))),
       "No posicionar la ventana toplevel con coordenadas XDG.");
for (const key of [
    "XDG_SESSION_TYPE", "WAYLAND_DISPLAY", "QT_QPA_PLATFORM=wayland",
    "QT_WAYLAND_SHELL_INTEGRATION=layer-shell",
    "preview_soledad_layershell.qml", 'exec env '
]) assert(runner.includes(key), "Lanzador incompleto: " + key);
for (const bad of [
    "sudo ", "pacman -S", "kpackagetool", "plasmapkg", "kwriteconfig",
    "qdbus", "systemctl", "pkill", "killall", "rm -rf"
]) assert(!runner.includes(bad), "El lanzador alteraría el equipo: " + bad);
assert(!viewer.includes("preview_soledad_layershell"));
assert(!plasma.includes("preview_soledad_layershell"));
console.log("OK: Soledad original montada en LayerShellQt aislado, sin banda ni modificaciones al panel.");
