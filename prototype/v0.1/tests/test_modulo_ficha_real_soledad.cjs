#!/usr/bin/env node
"use strict";
// Contratos de las dos presentaciones de fichas reales; no inicia Qt ni modifica KDE.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const host = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const chip = fs.readFileSync(path.join(dir, "SoledadRealTaskChip.qml"), "utf8");
assert.equal((host.match(/delegate: SoledadRealTaskChip\s*\{\s*host: root\s*\}/g) || []).length, 2,
  "Las dos posiciones usan exactamente la misma ficha real");
assert.equal((host.match(/root\.usingRealTasks \? root\.realTaskModel : null/g) || []).length, 2,
  "El modelo real y las condiciones de los Repeater siguen en el anfitrión");
for (const fragment of [
  "IslandButton {",
  "required property var host",
  "required property var model",
  "required property int index",
  "taskDisplayMode: host.taskDisplayMode",
  "taskCloseVisible: host.realTaskActivationEnabled",
  "onTaskCloseRequested:",
  "host.requestRealTaskClose(",
  "host.requestRealTaskGroup(",
  "host.requestRealTaskPreview(",
  "host.requestHideRealTaskPreview(previewUuid)",
  "host.requestHideRealTaskGroup()",
  "host.activateRealTask(index, appId, appName,",
  "interval: 420",
  "host.installedLauncherPopupVisible",
  "if (isGrouped && taskWindowIds.length > 1) return",
  "host.taskNameExtraWidth",
  "QQC2.ToolTip.visible: false"
]) assert.ok(chip.includes(fragment), "Contrato perdido: " + fragment);
assert.doesNotMatch(chip, /\broot\./);
assert.doesNotMatch(chip, /\bQtCore\.Settings\b|function applyChanges\(/);
assert.doesNotMatch(host, /delegate: IslandButton\s*\{\s*id: realTaskChip/);
console.log("OK: ficha KDE compartida por derecha/centro, cierre, activación y previsualización preservados.");
