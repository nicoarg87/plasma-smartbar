// Regresión estructural de la extracción de la página Comportamiento.
// Ejecutar desde cualquier carpeta: node prototype/v0.1/tests/test_modulo_comportamiento_soledad.cjs
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const ui = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(ui, "SoledadSettings.qml"), "utf8");
const view = fs.readFileSync(path.join(ui, "SoledadBehaviorPage.qml"), "utf8");
const required = [
  "required property var settingsTarget",
  "required property var launcherSwitchColorDialog",
  "readonly property var settings: settingsTarget",
  "page.availableWidth",
  "settings.soLeftClickOpensLauncher",
  "settings.launcherIconsWithNames",
  "settings.launcherCategoryLayout",
  "settings.launcherSwitchShape",
  "settings.launcherSwitchColorOverride",
  "settings.launcherMaxSlots",
  "settings.autoCollapseSO",
  "settings.autoCollapseTray",
  "settings.showSharedLayout()",
  "settings.showSoledadShape()",
  "launcherSwitchColorDialog.open()"
];
for (const term of required) assert.ok(view.includes(term), "Falta contrato de página: " + term);
assert.match(main, /SoledadBehaviorPage\\s*\\{\\s*settingsTarget:\\s*settings\\s*launcherSwitchColorDialog:\\s*launcherSwitchColorDialog\\s*\\}/);
assert.ok(main.includes("function applyChanges()"), "Aplicar sigue en el centro");
assert.ok(main.includes("function discardPendingEdits()"), "Cancelar sigue en el centro");
assert.ok(!view.includes("function applyChanges()") && !view.includes("QtCore.Settings"), "La vista no persiste datos");
assert.ok(!view.includes("collapseScroll.availableWidth"), "Scroll local renombrado");
assert.equal((view.match(/QQC2.Button \\{/g) || []).length, 5);
assert.equal((view.match(/QQC2.CheckBox \\{/g) || []).length, 3);
assert.equal((view.match(/QQC2.ComboBox \\{/g) || []).length, 4);
console.log("OK: módulo de comportamiento Soledad, 15 contratos y controles originales.");
