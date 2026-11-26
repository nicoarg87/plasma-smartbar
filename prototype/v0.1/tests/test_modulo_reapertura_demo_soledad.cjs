#!/usr/bin/env node
"use strict";
// Contratos de botón de reapertura simulada compartido, sin iniciar KDE.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const button = fs.readFileSync(path.join(dir, "SoledadDemoReopenButton.qml"), "utf8");
for (const mode of ["right", "center"]) {
  assert.ok(main.includes('SoledadDemoReopenButton {\n                    host: root\n                    presentationMode: "' + mode + '"'));
}
for (const fragment of [
  'import "DemoWindows.js" as DemoWindows',
  "required property var host",
  "required property string presentationMode",
  "host.positionMode === presentationMode && host.soExpanded",
  "host.demoWindowControlsEnabled && !host.usingRealTasks",
  "host.demoClosedHistory.length > 0",
  'DemoWindows.firstClosed(host.demoOpenedApps, host.demoApps) !== ""',
  "Accessible.name:",
  "implicitWidth: 26",
  "implicitHeight: 34",
  "enabled ?",
  "onClicked: host.reopenNextDemoWindow()",
  "color: reopenDemo.enabled"
]) assert.ok(button.includes(fragment), "Contrato faltante: " + fragment);
assert.equal((main.match(/SoledadDemoReopenButton \{/g)||[]).length,2);
assert.doesNotMatch(main,/id: reopenDemoRight|id: reopenDemoCenter/);
assert.doesNotMatch(button,/\broot\.|QtCore\.Settings|requestRealTaskClose/);
console.log("OK: reapertura simulada derecha y centro usa un único botón intacto.");
