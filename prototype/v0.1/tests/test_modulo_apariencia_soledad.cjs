// Composición y dependencias de apariencia extraída; no requiere iniciar Qt/KWin.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const ui = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(ui, "SoledadSettings.qml"), "utf8");
const view = fs.readFileSync(path.join(ui, "SoledadAppearancePage.qml"), "utf8");
const required = [
  "required property var settingsTarget",
  "required property var baseColorDialog",
  "required property var sampleColorDialog",
  "required property var gradientColorDialog",
  "property alias currentTargetIndex: appearanceTarget.currentIndex",
  "function resetScroll()",
  "function scrollToBreathing()",
  "gradientBreathingTitle.mapToItem",
  "settings.colorScope",
  "settings.soledadGradientEnabled",
  "settings.malvinaGradientEnabled",
  "settings.resetColorsForTarget(appearanceTarget.currentIndex)",
  "baseColorDialog.open()",
  "sampleColorDialog.open()",
  "gradientColorDialog.open()"
];
for (const token of required) assert.ok(view.includes(token), "Falta: " + token);
assert.match(main, /SoledadAppearancePage\s*\{\s*id:\s*appearancePage\s*settingsTarget:\s*settings\s*baseColorDialog:\s*islandColorDialog\s*sampleColorDialog:\s*samplePaletteColorDialog\s*gradientColorDialog:\s*activeGradientColorDialog\s*\}/);
assert.ok(main.includes("appearancePage.resetScroll()"));
assert.ok(main.includes("appearancePage.scrollToBreathing()"));
assert.ok(main.includes("appearancePage.currentTargetIndex"));
assert.ok(main.includes("function applyChanges()"));
assert.ok(main.includes("function discardPendingEdits()"));
assert.ok(!main.includes("appearanceScroll") && !main.includes("appearanceTarget.currentIndex"));
assert.ok(!view.includes("QtCore.Settings") && !view.includes("function applyChanges()"));
console.log("OK: apariencia modular, selector, diálogos y navegación preservados.");
