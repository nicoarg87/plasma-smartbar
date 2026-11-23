// Verificación no gráfica: el centro único comparte controles en todas
// las secciones y permite volver al prototipo después de Aplicar.
// No inicia Qt, navegador, LayerShell ni modifica las preferencias.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const ui = path.resolve(__dirname, "../package/contents/ui");
const settings = fs.readFileSync(path.join(ui, "SoledadSettings.qml"), "utf8");
const bar = fs.readFileSync(path.join(ui, "SmartBarContent.qml"), "utf8");

assert.match(settings, /Window\s*\{\s*id: settings/);
assert.match(settings, /flags: Qt\.Window \| Qt\.WindowTitleHint \| Qt\.WindowSystemMenuHint \|\s*Qt\.WindowMinMaxButtonsHint \| Qt\.WindowCloseButtonHint/);
assert.match(settings, /transientParent:\s*null/);
assert.match(settings, /modality:\s*Qt\.NonModal/);
assert.doesNotMatch(settings, /flags:\s*Qt\.Dialog/);
assert.match(settings, /title:\s*"Plasma SmartBar · Configuración"/);

for (const label of ["Cancelar", "Cerrar", "Aplicar"]) {
    assert.match(settings, new RegExp('text: "' + label + '"'));
}
assert.match(settings, /text: "Cerrar"\s*onClicked: settings\.close\(\)/);
assert.match(settings, /onClosing: function\(event\).*discardPendingEdits\(\)/);
assert.match(settings, /text: "Aplicar"\s*highlighted: true\s*onClicked: settings\.applyChanges\(\)/);
assert.match(settings, /onSettingsApplied:\s*root\.requestPersistCurrentSettings\(\)/);
assert.match(bar, /function openMalvinaSettings\(\)\s*\{\s*root\.openSoledadSettings\(0, 2\)/);
assert.match(bar, /function openSoledadSettings\(tabIndex, islandSubtabIndex\)/);
assert.match(bar, /if \(soledadSettings\.visibility === Window\.Minimized\)\s*soledadSettings\.showNormal\(\)/);
assert.match(bar, /soledadSettings\.show\(\)/);
console.log("OK: Configuración independiente, controles nativos, cierre y retorno desde Malvina/Soledad.");
