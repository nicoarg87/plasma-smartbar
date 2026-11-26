#!/usr/bin/env node
"use strict";
// Contratos de las tres extracciones; no inicia el visor ni modifica KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const dir = path.resolve(__dirname, "../package/contents/ui");
const read = name => fs.readFileSync(path.join(dir, name), "utf8");
const main = read("SmartBarContent.qml");
const surface = read("SoledadIslandSurface.qml");
const button = read("SoledadMainButton.qml");
const menu = read("SoledadGripMenu.qml");
assert.match(main, /SoledadIslandSurface\s*\{\s*host: root\s*rowTarget: systemRow\s*islandTarget: systemIsland\s*gripTarget: moveGrip\s*anchors\.fill: parent\s*\}/);
assert.match(main, /SoledadMainButton\s*\{\s*id: soButton\s*host: root\s*islandTarget: systemIsland\s*launcherPopup: installedAppsPopup\s*\}/);
assert.match(main, /SoledadGripMenu\s*\{\s*id: gripMenu\s*host: root\s*gripTarget: moveGrip\s*positionEditor: soPositionEditor\s*clockRevealTimer: soClockRevealTimer\s*\}/);
for (const token of [
  "rowTarget.children", "child === gripTarget", "islandTarget.topLeftRadius",
  "ctx.globalCompositeOperation = \"destination-out\"",
  "host.trayButtonColorOverride", "host.gripButtonColorOverride",
  "target: rowTarget", "target: host", "canvas.requestPaint()"
]) assert.ok(surface.includes(token), "Superficie: " + token);
for (const token of [
  "required property var host", "required property var islandTarget",
  "required property var launcherPopup", "interval: 400",
  "onReleased: soHoldTimer.stop()", "onCanceled: soHoldTimer.stop()",
  "host.triggerSOButton(true, host.soLauncherOpenOnLeftPress)",
  "host.triggerSOButton(false, host.soLauncherOpenOnRightPress)",
  "host.openInstalledLauncher(\"so\")", "launcherPopup.visible",
  "iconAnimationEnabled:", "activityExternalPulsePhase:"
]) assert.ok(button.includes(token), "Botón SO: " + token);
for (const token of [
  "required property var host", "required property var gripTarget",
  "required property var positionEditor", "required property var clockRevealTimer",
  'import "DemoWindowInstances.js" as DemoWindowInstances',
  "popupType: QQC2.Popup.Window", "parent: gripTarget",
  "x: gripTarget.width - width", "clockRevealTimer.stop()",
  "host.requestAutoCollapseSOChange(", "host.passToNextPackTheme()",
  "host.returnToConfiguredPosition()", "positionEditor.openFor(",
  "DemoWindowInstances.initial()"
]) assert.ok(menu.includes(token), "Menú: " + token);
assert.equal((main.match(/SoledadIslandSurface\s*\{/g) || []).length,1);
assert.equal((main.match(/SoledadMainButton\s*\{/g) || []).length,1);
assert.equal((main.match(/SoledadGripMenu\s*\{/g) || []).length,1);
for (const child of [surface, button, menu]) {
  assert.doesNotMatch(child, /\broot\./, "No depender del id privado del host");
  assert.doesNotMatch(child, /\bQtCore\.Settings\b/, "No duplicar persistencia");
}
assert.ok(main.includes("gripMenu.close()") && main.includes("soButton.beginArtworkPreview("));
console.log("OK: superficie, botón SO y menú contextual mantienen enlaces y acciones.");
