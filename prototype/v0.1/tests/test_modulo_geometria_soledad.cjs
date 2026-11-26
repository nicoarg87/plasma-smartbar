// Contratos de extracción de geometría; no inicia Qt ni modifica panel Plasma.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(dir, "SoledadSettings.qml"), "utf8");
const page = fs.readFileSync(path.join(dir, "SoledadGeometryPage.qml"), "utf8");
for (const token of [
  "required property var settingsTarget",
  "readonly property var settings: settingsTarget",
  "function resetScroll()",
  "page.availableWidth",
  "settings.geometryScope",
  "settings.geometrySection",
  "settings.positionMode",
  "settings.malvinaShape",
  "settings.soledadShape",
  "settings.panelHeight",
  "settings.soledadHeight",
  "settings.malvinaHeight",
  "settings.gripShape",
  "settings.trayButtonShape"
]) assert.ok(page.includes(token), "Falta contrato: " + token);
assert.match(main, /SoledadGeometryPage\s*\{\s*id:\s*geometryPage\s*settingsTarget:\s*settings\s*\}/);
assert.ok(main.includes("geometryPage.resetScroll()"));
assert.ok(main.includes("function applyChanges()"));
assert.ok(!main.includes("positionScroll") && !page.includes("positionScroll."));
assert.ok(!page.includes("QtCore.Settings") && !page.includes("function applyChanges()"));
console.log("OK: geometría modular con navegación y preferencias intactas.");
