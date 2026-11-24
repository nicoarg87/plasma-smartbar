"use strict";
// Contrato estático: alternar activar/minimizar sin afectar grupos ni KDE instalado.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(base, file), "utf8");
const ui = read("package/contents/ui/SmartBarContent.qml");
const host = read("preview_soledad_input_mask.qml");
assert(ui.includes("signal requestRealTaskActivation(int taskRow, bool taskActive, string windowUuid)"));
assert(ui.includes('requestRealTaskActivation(taskRow, taskActive === true, String(windowUuid || ""))'));
assert.equal((ui.match(/root\.activateRealTask\(index, appId, appName, model\.IsActive === true && model\.IsMinimized !== true, previewUuid\)/g)||[]).length, 2);
assert.equal((ui.match(/if \(isGrouped && taskWindowIds\.length > 1\) return/g)||[]).length, 2);
for (const marker of [
    "onRequestRealTaskActivation: function(taskRow, taskActive, windowUuid)",
    "row.windowUuids.length === 1",
    "String(row.windowUuids[0]) === windowUuid",
    "canMinimize = row.taskActive && !row.taskMinimized",
    "groupedKdeWindows.requestToggleMinimized(target)",
    "groupedKdeWindows.requestActivate(target)",
    "bar.realTaskActivationDispatched = true",
    "if (!smartbarContinuousMode || bar.realTrackedFullscreen"
]) assert(host.includes(marker), "Falta protección de alternancia: " + marker);
assert(host.indexOf("if (canMinimize)") < host.indexOf("groupedKdeWindows.requestToggleMinimized(target)"));
assert(host.includes("TaskManager.TasksModel.GroupApplications"));
console.log("OK: clic SO activa tareas inactivas y minimiza solo ventana única activa; requiere prueba en CachyOS.");
