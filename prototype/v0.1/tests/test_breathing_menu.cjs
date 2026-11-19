// Regresión estática de navegación compacta y respiración por isla.
// Ejecutar: node prototype/v0.1/tests/test_breathing_menu.cjs
// Complementa, pero NO reemplaza, las pruebas QML/CachyOS.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.join(__dirname, "..");
const file = p => fs.readFileSync(path.join(root, p), "utf8");
const ui = file("package/contents/ui/SoledadSettings.qml");
const bar = file("package/contents/ui/SmartBarContent.qml");
const main = file("package/contents/ui/main.qml");
const preview = file("preview_redimensionable.qml");
const kconfig = file("package/contents/config/main.xml");
const menuStart = ui.indexOf('text: "Anchura del botón SO"');
const logo = ui.indexOf('text: "Logo SO"', menuStart);
const light = ui.indexOf('text: "Efectos luminosos"', logo);
const colors = ui.indexOf('text: "Color y transparencia"', light);
const shape = ui.indexOf('text: "Figura y tamaño"', colors);
const windows = ui.indexOf('text: "Cajón y ventanas"', shape);
assert(menuStart > 0 && menuStart < logo && logo < light && light < colors &&
       colors < shape && shape < windows, "Orden de navegación Soledad");
assert(!ui.includes('text: "DEGRADADO SOLEDAD"'));
assert(!ui.includes('text: "DEGRADADO MALVINA"'));
assert(!ui.includes('model: ["Color y opacidad", "DEGRADADO", "Respiración y fondo"]'));
assert(ui.includes("function showSoledadGradient() { showSharedColors(0) }"));
assert(ui.includes("function showMalvinaGradient() { showSharedColors(1) }"));
assert(ui.includes('visible: settings.logoSection === 4'));
assert(ui.includes('text: "RESPIRACIÓN DEL FONDO Y LOS MENÚS"'));
assert(ui.includes('text: "Activar respiración del degradado"'));
assert(ui.includes('text: "Sincronizar velocidad y ritmo con el botón SO (predeterminado)"'));
assert(ui.includes('text: "Intensidad"'));
assert(ui.includes('text: "Velocidad"'));
for (const island of ["soledad", "malvina"]) {
    const pre = island === "soledad" ? "Soledad" : "Malvina";
    for (const key of [
        "GradientBreathingEnabled", "GradientSyncBreathing",
        "GradientBreathingIntensity", "GradientBreathingSpeed"
    ]) {
        const full = island + key;
        assert(ui.includes(full), "El editor no tiene " + full);
        assert(bar.includes(full), "El render no tiene " + full);
        assert(main.includes(full), "KConfig main no tiene " + full);
        assert(kconfig.includes('name="' + full + '"'),
               "No hay clave en main.xml: " + full);
        assert(preview.includes("demo" + pre + key),
               "No hay persistencia en visor: " + full);
    }
    assert(kconfig.includes('<entry name="' + island +
                            'GradientSyncBreathing" type="Bool"><default>true</default>'),
           "Sincronización predeterminada desactivada para " + island);
}
assert(bar.includes("root.anyGradientBreathingActive"));
assert(bar.includes("root.soledadIndependentBreathingPhase"));
assert(bar.includes("root.malvinaIndependentBreathingPhase"));
assert(bar.includes("root.sharedBreathingPhase"));
assert(!bar.includes("soBreathingSourceActive && soledadGradientEnabled"),
       "El fondo sigue dependiendo de abrir ventanas de SO");
const breatheFn = bar.substring(bar.indexOf("function breathingFactor("),
                               bar.indexOf("readonly property real gradientBreathingFactor:"));
assert(breatheFn.includes("intensity"));
assert(!breatheFn.includes("soActivityPulseDepth"),
       "La intensidad de fondo depende aún del logo SO");
console.log("OK: menú unificado, sincronización SO predeterminada, intensidad y velocidad independientes.");
