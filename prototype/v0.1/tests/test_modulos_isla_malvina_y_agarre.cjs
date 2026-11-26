#!/usr/bin/env node
"use strict";
// Comprueba interfaces de Malvina y agarre sin iniciar Qt ni controlar ventanas.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "../package/contents/ui");
const read = name => fs.readFileSync(path.join(base, name), "utf8");
const main = read("SmartBarContent.qml");
const malvina = read("MalvinaRuntimeIsland.qml");
const grip = read("SoledadGripControl.qml");
assert.match(main, /MalvinaRuntimeIsland\s*\{\s*id: malvinaHotspot\s*host: root\s*revealTimerTarget: malvinaRevealTimer\s*hideTimerTarget: malvinaHideTimer\s*\}/);
assert.match(main, /SoledadGripControl\s*\{\s*id: moveGrip\s*host: root\s*islandTarget: systemIsland\s*soButtonTarget: soButton\s*clockRevealTimerTarget: soClockRevealTimer\s*\}/);
for (const token of [
 "required property var host",
 "required property var revealTimerTarget",
 "required property var hideTimerTarget",
 "property alias searchTarget: malvinaSearch",
 "property alias launcherTarget: launcherIsland",
 "property alias hoverTarget: malvinaHotspotHover",
 "host: malvinaHotspot.host",
 "hideTimerTarget.restart()",
 "revealTimerTarget.restart()",
 "onRequestOpenUrl: function(url)",
 "host.dismissMalvinaAfterSearch()",
 "id: launcherContextMenu",
 "anchors.left: parent.left",
 "anchors.top: parent.top"
]) assert.ok(malvina.includes(token), "Malvina: " + token);
for (const token of [
 "required property var host",
 "required property var islandTarget",
 "required property var soButtonTarget",
 "required property var clockRevealTimerTarget",
 "property alias dragTarget: gripDrag",
 "property alias menuTarget: gripMenu",
 "id: gripDrag",
 "target: null",
 "xAxis.enabled: true",
 "yAxis.enabled: false",
 "LayerShellDragCompensation.nextWithEdgeRebase(",
 "host.setIslandOffset(result.offset)",
 "host.centeredPresentation",
 "soButtonTarget.mapToItem(host,",
 "id: soPositionEditor",
 "id: gripMenu",
 "host: grip.host",
 "gripTarget: grip",
 "positionEditor: soPositionEditor",
 "clockRevealTimer: clockRevealTimerTarget"
]) assert.ok(grip.includes(token), "Agarre: " + token);
for (const token of [
 "malvinaHotspot.searchTarget.closeSearch()",
 "malvinaHotspot.searchTarget.focusSearch()",
 "malvinaHotspot.hoverTarget.hovered",
 "malvinaHotspot.launcherTarget.mapToItem(",
 "moveGrip.dragTarget.active",
 "moveGrip.menuTarget.open()",
 "moveGrip.menuTarget.close()"
]) assert.ok(main.includes(token), "Anfitrión: " + token);
assert.doesNotMatch(main, /\bgripDrag\b|\bmalvinaSearch\b|\blauncherIsland\b|\bmalvinaHotspotHover\b/);
assert.doesNotMatch(malvina + grip, /\broot\./);
console.log("OK: Malvina y agarre modularizados, aliases y arrastre original presentes.");
