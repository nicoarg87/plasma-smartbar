// Atardecer de fábrica usa exclusivamente su preset y archivos: nada de
// reutilizar el tema Día histórico ni Noche o tomar el logo activo.
// Ejecutar: node prototype/v0.1/tests/test_factory_sunset.cjs
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const ui = fs.readFileSync(path.join(root, "package/contents/ui/SoledadSettings.qml"), "utf8");
const script = fs.readFileSync(path.join(root, "scripts/fijar_atardecer_fabrica.cjs"), "utf8");
const factory = fs.readFileSync(path.join(root, "package/contents/ui/assets/FactorySunsetTheme.js"), "utf8");
const night = fs.readFileSync(path.join(root, "package/contents/ui/assets/FactoryNightTheme.js"), "utf8");
const bar = fs.readFileSync(path.join(root, "package/contents/ui/SmartBarContent.qml"), "utf8");
const preview = fs.readFileSync(path.join(root, "preview_redimensionable.qml"), "utf8");

assert(ui.includes('import "assets/FactorySunsetTheme.js" as FactorySunsetTheme'));
assert(ui.includes('import "assets/FactoryNightTheme.js" as FactoryNightTheme'));
assert(ui.includes("readonly property var factorySunsetPreset: FactorySunsetTheme.preset"));
assert(ui.includes("readonly property url factorySunsetImage:"));
assert(ui.includes("readonly property bool factorySunsetAvailable:"));
assert(ui.includes("factorySunsetProbe.status === Image.Ready"));
assert(ui.includes("factorySunsetTextProbe.status === Image.Ready"));
assert(ui.includes('slot === "sunset" ? factorySunsetJson'));
assert(ui.includes('slot === "night" ? factoryNightJson'));
assert(ui.includes('slot === "day" ? themeDayJson'), "No borrar respaldo Atardecer histórico");
assert(ui.includes('if (slot === "sunset") {\n            themeStatus = "Atardecer de fábrica está protegido; usá Personalizado."'));
assert(ui.includes('if (slot === "day") {\n            themeStatus = "La antigua ranura Atardecer se conserva, pero ya no se modifica; usá Personalizado."'));
assert(!ui.includes('onClicked: settings.storeTheme("sunset")'));
assert(!ui.includes('onClicked: settings.storeTheme("day")'));
assert(!ui.includes('text: "Fijar Atardecer"'));
assert(!ui.includes('text: "Actualizar Atardecer con estética actual…"'));
assert(!ui.includes("updateSunsetConfirmation.open()"));
assert(!ui.includes("restoreSunsetConfirmation.open()"));
assert(!ui.includes("function updateSunsetFromCurrent()"));
assert(!ui.includes("function restorePreviousSunset()"));

const cardStart = ui.indexOf('Image {\n                                    visible: settings.factorySunsetAvailable &&', ui.indexOf("id: themeListScroll"));
const nightCardStart = ui.indexOf('Image {\n                                    visible: settings.factoryNightAvailable &&', cardStart);
assert(cardStart >= 0 && nightCardStart > cardStart);
const sunsetRowEnd = nightCardStart;
assert(sunsetRowEnd > cardStart && nightCardStart === sunsetRowEnd);
const sunsetCard = ui.substring(cardStart, sunsetRowEnd);
assert(sunsetCard.includes("settings.factorySunsetImage"));
assert(!sunsetCard.includes("settings.factoryNightImage"));
assert(!sunsetCard.includes("settings.themeDayJson"));
assert(!sunsetCard.includes("settings.selectedImage"));
assert(!sunsetCard.includes("settings.defaultImage"));
assert(sunsetCard.includes('text: "Restaurar"'));
assert(sunsetCard.includes('enabled: settings.factorySunsetAvailable'));
assert(sunsetCard.includes('onClicked: settings.activateTheme("sunset")'));
assert(ui.includes('text: "Exportar aspecto actual para fijar Atardecer de fábrica…"'));
assert(ui.includes('onClicked: settings.showFactoryCapture("sunset")'));
assert(ui.includes('onClicked: settings.showFactoryCapture("night")'));
assert(ui.includes('factoryExportTarget === "sunset" ? "Atardecer" : "Noche"'));
assert(ui.includes("factoryNightExportText.copy()"));
assert(ui.includes("settings.factoryNightCandidateJson()"), "Una sola exportación de valores reales");
assert(ui.includes('filePath = slot === "sunset"'));
assert(ui.includes("factorySunsetImage.toString() : factoryNightImage.toString()"));
assert(ui.includes('text: "TUS TEMAS GUARDADOS"'));
assert(ui.includes("Día · tema de fábrica todavía no definido"));
assert(!ui.includes('text: "Aplicar Atardecer"'), "Atardecer personal no debe suplantar la fábrica");
assert(bar.includes("themeDayJson") && preview.includes("demoThemeDayJson"), "No perder copia anterior");
assert(script.includes("FactorySunsetTheme.js"));
assert(script.includes("factory-sunset-manifest.json"));
assert(script.includes("factory-sunset-logo"));
assert(script.includes("factory-sunset-text"));
assert(script.includes("atardecer-actual.json"));
assert(script.includes("crypto.createHash(\"sha256\")"));
assert(script.includes("fs.copyFileSync"));
assert(script.includes('delete preset.originalImageUrl'));
assert(script.includes('preset.filePath = ""'));
assert(script.includes("No se puede reemplazar con este comando"));
assert(!script.includes("FactoryNightTheme.js"));
assert(!script.includes("factory-night-logo"));
if (/var preset = null\b/.test(factory)) {
    assert(!fs.existsSync(path.join(root,"package/contents/ui/assets/factory-sunset-manifest.json")));
    console.log("OK: Atardecer original reservado, no editable ni mezclado; falta captura del mantenedor.");
} else {
    const manifest = JSON.parse(fs.readFileSync(path.join(root, "package/contents/ui/assets/factory-sunset-manifest.json"),"utf8"));
    assert.equal(manifest.theme, "Atardecer de fábrica");
    for (const asset of manifest.assets)
        assert(fs.existsSync(path.join(root, "package/contents/ui/assets", asset.file)));
}
assert(factory !== night, "No compartir un solo manifiesto entre temas");
