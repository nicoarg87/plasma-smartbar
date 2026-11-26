#!/usr/bin/env node
"use strict";
// El separador sigue siendo parte de la única fila y conserva el ajuste existente.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const view = fs.readFileSync(path.join(dir, "SoledadTaskWidthSeparator.qml"), "utf8");
assert.match(main, /SoledadTaskWidthSeparator\s*\{\s*host:\s*root\s*\}/);
assert.equal((main.match(/SoledadTaskWidthSeparator\s*\{/g) || []).length, 1);
for (const token of [
  "required property var host",
  "visible: host.trayExpanded && host.soExpanded",
  "width: 14",
  "height: 28",
  "y: (parent.height - height) / 2",
  "model: 3",
  "hoverEnabled: true",
  "cursorShape: Qt.SizeHorCursor",
  "mapToItem(host, mouse.x, mouse.y)",
  "host.taskResizeStartX = pt.x",
  "host.taskResizeStartWidth = host.taskNameExtraWidth",
  "host.taskResizeChipCount = Math.max(1, host.usingRealTasks",
  "host.updateTaskNameExtraWidth(host.taskResizeStartWidth +",
  "host.taskNameExtraWidth = 0",
  "onReleased: host.saveTaskNameExtraWidth()",
  "onDoubleClicked: function(mouse)"
]) assert.ok(view.includes(token), "Contrato no encontrado: " + token);
assert.doesNotMatch(main, /id:\s*traySOSeparator\b/);
assert.doesNotMatch(view, /\broot\.|\bQtCore\.Settings\b/);
console.log("OK: separador modular, arrastre y guardado de ancho preservados.");
