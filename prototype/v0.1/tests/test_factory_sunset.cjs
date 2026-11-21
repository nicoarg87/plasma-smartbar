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

// Tras la sustitución de tarjetas por un desplegable con scroll, el
// selector mantiene los tres temas centrales y las copias personales.
const popupStart = ui.indexOf("id: themeOptionsPopup");
const popupEnd = ui.indexOf('text: "Crear tema nuevo"', popupStart);
assert(popupStart >= 0 && popupEnd > popupStart, "Falta desplegable de temas");
const popup = ui.slice(popupStart, popupEnd);
assert(/model:\s*settings\.selectedThemePack\s*\?\s*0\s*:\s*3\s*\+\s*settings\.otherNamedThemes\.length/.test(popup),
       "Sin pack personal, mantener los tres temas base y la biblioteca histórica");
assert(popup.includes('index === 0 ? "Atardecer"'), "Atardecer debe ser primera opción");
assert(popup.includes('settings.factorySunsetImage'), "Falta imagen original Atardecer");
assert(popup.includes('settings.themeImageSource(settings.themeDayJson)'),
       "La copia personal histórica conserva su propia imagen");
assert(popup.includes('settings.themeDayJson.length ? "day"'),
       "Priorizar copia histórica de Atardecer sin sobrescribir fábrica");
assert(popup.includes('(settings.factorySunsetAvailable ? "sunset" : "")'),
       "No restaurar fábrica sin su preset e imagen");
assert(popup.includes('settings.activateTheme(slot)'));
assert(!popup.includes('settings.selectedImage'), "No usar logo actual como miniatura");
assert(!popup.includes('text: "Restaurar"'), "No reintroducir botones de tarjetas");
assert(ui.includes('function showFactoryCapture(target)'),
       "Mantener el helper de captura de perfiles originales");
assert(ui.includes('factoryExportTarget = target === "sunset" ? "sunset" : "night"'),
       "El empaquetador no debe mezclar recursos de distintas fábricas");
assert(ui.includes('factoryExportTarget === "sunset" ? "Atardecer" : "Noche"'));
assert(ui.includes("factoryNightExportText.copy()"));
assert(ui.includes("settings.factoryNightCandidateJson()"), "Una sola exportación de valores reales");
assert(ui.includes('filePath = slot === "sunset"'));
assert(ui.includes('slot === "sunset"') &&
       ui.includes('factorySunsetImage.toString()') &&
       ui.includes('slot === "dayOfficial" ? factoryDayImage.toString()') &&
       ui.includes('factoryNightImage.toString()'),
       "Cada fábrica debe conservar su propia ruta, incluido Día oficial");
assert(popup.includes('settings.otherNamedThemes.length'),
       "Las opciones personales deben mantenerse en la lista");
assert(popup.includes('settings.dayThemeIndex() >= 0'),
       "Si no hay fábrica Día, conservar alternativa personal guardada");
assert(popup.includes('if (settings.factoryDayAvailable) slot = "dayOfficial"'),
       "Día oficial no debe suplantarse con datos personales");
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
