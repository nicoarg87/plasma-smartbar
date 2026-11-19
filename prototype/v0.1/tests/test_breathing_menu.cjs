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
const menuStart = ui.indexOf('text: "Botón de inicio SO"');
const light = ui.indexOf('text: "Efectos luminosos"', menuStart);
const colors = ui.indexOf('text: "Color y transparencia"', light);
const shape = ui.indexOf('text: "Figura y tamaño"', colors);
const windows = ui.indexOf('text: "Cajón y ventanas"', shape);
assert(menuStart > 0 && menuStart < light && light < colors &&
       colors < shape && shape < windows, "Orden de navegación Soledad");
assert.equal((ui.match(/text: "Botón de inicio SO"/g) || []).length, 1);
assert(!ui.includes('text: "Anchura del botón SO"'));
assert(!ui.includes('text: "Logo SO"'));
assert(ui.includes('text: "Anchura del botón SO · logo e imagen"'));
assert(ui.includes('model: ["Logo y ancho", "Texto", "Encuadre", "Reloj"]'));
assert(!ui.includes('text: "DEGRADADO SOLEDAD"'));
assert(!ui.includes('text: "DEGRADADO MALVINA"'));
assert(!ui.includes('model: ["Color y opacidad", "DEGRADADO", "Respiración y fondo"]'));
assert(ui.includes("function showSoledadGradient() { showSharedColors(0) }"));
assert(ui.includes("function showMalvinaGradient() { showSharedColors(1) }"));
assert(!ui.includes('visible: settings.logoSection === 4'));
assert(ui.includes('function showSoledadGlowBreathing()'));
assert(ui.includes('onClicked: settings.showSoledadGlowBreathing()'));
assert(ui.includes('text: "Ir a Efectos luminosos → Brillo y respiración SO"'));
assert(ui.includes('text: "Duración del ciclo"'));
assert(ui.includes('text: "Intensidad del pulso de luz (0–100 %)"'));
assert(ui.includes('onValueModified: settings.pulseSpeed ='));
assert(ui.includes('Math.round(1000 / Math.max(0.1, settings.pulseSpeed))'));
assert(ui.includes('text: "Activar efecto Respiración luminosa en SO"'));
assert(ui.includes('GridLayout {'));
assert(ui.includes('columns: appearanceScroll.availableWidth >= 740 ? 3'));
assert(ui.includes('Layout.minimumWidth: 0'));
assert.equal((ui.match(/QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn/g) || []).length, 10);
assert(!ui.includes('QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded'));
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
for (const name of [
    "soledadOpacity", "malvinaOpacity", "backgroundOpacity",
    "launcherOpacity", "malvinaOptionsOpacity"
]) {
    assert(kconfig.includes('<entry name="' + name +
                            '" type="Double"><default>0.7</default>'),
           "No se estableció valor inicial 70 % en KConfig: " + name);
    assert(ui.includes('property real ' + name + ': 0.7'));
    assert(bar.includes('property real ' + name + ': 0.7'));
}
for (const name of [
    "demoSoledadOpacity", "demoMalvinaOpacity", "demoBackgroundOpacity",
    "demoLauncherOpacity", "demoMalvinaOptionsOpacity"
]) assert(preview.includes('property real ' + name + ': 0.7'),
          "Valor 70 % no presente en el visor: " + name);
assert(kconfig.includes('<entry name="launcherOpacityOverride" type="Bool"><default>false</default>'),
       "El launcher debe poder heredar opacidad de Soledad");
assert(kconfig.includes('<entry name="malvinaOptionsOpacityOverride" type="Bool"><default>false</default>'),
       "El panel Web/IA debe poder heredar opacidad de Malvina");
console.log("OK: navegación Botón de inicio SO, scroll adaptativo, respiración y 70 % por defecto.");
