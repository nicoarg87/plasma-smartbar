// Contrato de Noche de fábrica: recursos fijos, restauración fiel y sin
// dependencia de themes locales ni imágenes de otros temas.
// Ejecutar: node prototype/v0.1/tests/test_factory_night.cjs
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const ui = fs.readFileSync(path.join(root, "package/contents/ui/SoledadSettings.qml"), "utf8");
const generator = fs.readFileSync(path.join(root, "scripts/fijar_noche_fabrica.cjs"), "utf8");
const presetPath = path.join(root, "package/contents/ui/assets/FactoryNightTheme.js");
const moduleText = fs.readFileSync(presetPath, "utf8");

assert(ui.includes('import "assets/FactoryNightTheme.js" as FactoryNightTheme'));
assert(ui.includes("readonly property var factoryNightPreset: FactoryNightTheme.preset"));
assert(ui.includes("readonly property bool factoryNightAvailable:"));
assert(ui.includes("factoryNightProbe.status === Image.Ready"));
assert(ui.includes("factoryNightTextProbe.status === Image.Ready"));
assert(ui.includes('slot === "night" ? factoryNightJson'),
       "Noche debe usar el preset empaquetado, jamás themeNightJson");
assert(ui.includes('if (slot === "night") {\n            themeStatus = "Noche de fábrica está protegida; usá Personalizado."'));
assert(!ui.includes('onClicked: settings.storeTheme("night")'));
assert(!ui.includes('text: "Fijar tema Noche"'));
// El selector actual es un único desplegable, sin tarjetas ni botones
// individuales de restauración. Noche histórica tiene prioridad cuando existe.
const popupStart = ui.indexOf("id: themeOptionsPopup");
const popupEnd = ui.indexOf("// Fin del selector de temas y packs.", popupStart);
assert(popupStart > 0 && popupEnd > popupStart, "Falta selector de temas vigente");
const popup = ui.slice(popupStart, popupEnd);
assert(popup.includes('index === 1 ? "Noche"'), "Noche debe figurar en la lista");
assert(popup.includes('settings.factoryNightImage'), "Falta imagen original en opción Noche");
assert(popup.includes('settings.themeNightJson.length ? "nightLegacy"'),
       "Se debe poder recuperar la copia histórica de Noche");
assert(popup.includes('(settings.factoryNightAvailable ? "night" : "")'),
       "No activar fábrica de Noche si falta su recurso");
assert(!popup.includes('settings.selectedImage'),
       "La opción Noche no debe tomar la imagen activa");
assert(popup.includes('settings.activateTheme(slot)'),
       "El desplegable debe aplicar exclusivamente el slot seleccionado");
assert(ui.includes('function showFactoryCapture(target)'),
       "Conservar la función de captura sin introducir un botón nuevo");
assert(ui.includes('factoryExportTarget = target === "sunset" ? "sunset" : "night"'),
       "La captura de Noche no debe mezclarse con Atardecer");
assert(ui.includes('factoryNightExportDialog.open()'));
assert(ui.includes("factoryNightExportText.copy()"));
assert(ui.includes("settings.factoryNightCandidateJson()"));
assert(ui.includes("originalImageUrl = logoMode === \"text\" ? \"\" : selectedImage.toString()"));
assert(ui.includes('slot === "sunset"') &&
       ui.includes('factorySunsetImage.toString()') &&
       ui.includes('slot === "dayOfficial" ? factoryDayImage.toString()') &&
       ui.includes('factoryNightImage.toString()'),
       "Cada fábrica debe conservar su propia ruta, incluido Día oficial");
assert(ui.includes('Qt.resolvedUrl("assets/" + info.assetTextFile)'));
assert(!ui.includes("officialNightAvailable"), "Resurgió fallback de imagen incorrecta");
// El modelo del selector mantiene tres opciones principales, más temas personales.
assert(/model:\s*settings\.selectedThemePack\s*\?\s*0\s*:\s*3\s*\+\s*settings\.otherNamedThemes\.length/.test(popup),
       "Sin pack personal, mantener los tres temas base y la biblioteca histórica");
assert(popup.includes('settings.themeImageSource(settings.themeNightJson)'),
       "Un tema personal histórico debe utilizar su imagen, no la fábrica");
assert(popup.includes('else if (selectedIndex === 1)'),
       "La opción Noche debe tener una ruta de selección explícita");
assert(ui.includes('soButtonWidth: soButtonWidth'), "Fábrica omite ancho de botón");
assert(ui.includes('panelHeight: panelHeight'), "Fábrica omite altura de barra");
assert(ui.includes('"soButtonWidth","panelHeight"'), "Restauración no trae geometría visual");
assert(ui.includes('"taskDisplayMode"'), "Restauración no incluye indicador de ventanas");
assert(generator.includes("fs.copyFileSync"));
assert(generator.includes("crypto.createHash(\"sha256\")"));
assert(generator.includes('delete preset.originalImageUrl'));
assert(generator.includes('preset.filePath = ""'));
assert(generator.includes('preset.soTextBackgroundImage = ""'));
assert(generator.includes("No se puede reemplazar con este comando"));
assert(generator.includes("Falta ") || generator.includes("Falta"));
if (/var preset = null\b/.test(moduleText)) {
    // El usuario aún no ha exportado su perfil. No declarar un tema fake.
    assert(!fs.existsSync(path.join(root, "package/contents/ui/assets/factory-night-manifest.json")));
    console.log("OK: Noche original protegida, sin imagen ajena; captura exacta del usuario pendiente.");
} else {
    const manifestPath = path.join(root, "package/contents/ui/assets/factory-night-manifest.json");
    assert(fs.existsSync(manifestPath), "Manifiesto de recursos de fábrica ausente");
    const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
    assert(manifest.presetSha256);
    for (const asset of manifest.assets) {
        assert(fs.existsSync(path.join(root, "package/contents/ui/assets", asset.file)));
    }
    console.log("OK: Noche original empaquetada, recursos presentes y restauración protegida.");
}
