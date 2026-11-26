// Verificación estructural sin iniciar ni modificar el panel KDE.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(dir, "SoledadSettings.qml"), "utf8");
const view = fs.readFileSync(path.join(dir, "SoledadSharedOutlinesPage.qml"), "utf8");
for (const requirement of [
  "required property var settingsTarget",
  "required property var outlineColorDialog",
  "property alias currentTargetIndex: outlineTarget.currentIndex",
  "page.availableWidth",
  "settings.selectedOutline.style",
  "settings.selectedOutline.width",
  "settings.selectedOutline.color",
  "settings.selectedOutline.opacity",
  "settings.setOutlineField",
  "outlineColorDialog.open()"
]) assert.ok(view.includes(requirement), "Falta: " + requirement);
assert.match(main, /SoledadSharedOutlinesPage\s*\{\s*id:\s*sharedOutlinesPage\s*settingsTarget:\s*settings\s*outlineColorDialog:\s*islandOutlineColorDialog\s*\}/);
assert.ok(main.includes('["soledad","malvina","tray","grip"][sharedOutlinesPage.currentTargetIndex]'));
assert.ok(main.includes('onAccepted: settings.setOutlineField("color", settings.toHex(selectedColor))'));
assert.ok(main.includes("function applyChanges()"));
assert.ok(!view.includes("QtCore.Settings") && !view.includes("function applyChanges()"));
assert.equal((view.match(/QQC2.ComboBox \{/g) || []).length, 2);
assert.equal((view.match(/QQC2.Slider \{/g) || []).length, 2);
assert.equal((view.match(/QQC2.Button \{/g) || []).length, 2);
console.log("OK: contornos compartidos modularizados, enlaces y controles preservados.");
