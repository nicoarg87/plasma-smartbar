// Regresión estática de navegación compacta y respiración por isla.
// Ejecutar: node prototype/v0.1/tests/test_breathing_menu.cjs
// Complementa, pero NO reemplaza, las pruebas QML/CachyOS.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const root = path.join(__dirname, "..");
const file = p => fs.readFileSync(path.join(root, p), "utf8");
const ui = file("package/contents/ui/SoledadSettings.qml");
const bar = file("package/contents/ui/SmartBarContent.qml");
const main = file("package/contents/ui/main.qml");
const preview = file("preview_redimensionable.qml");
const kconfig = file("package/contents/config/main.xml");
const metadata = JSON.parse(file("package/metadata.json"));
assert.equal(metadata.KPlugin.License, "MIT", "El metadato KDE debe coincidir con LICENSE");
const launcher = ui.indexOf('text: "Isla y launcher"');
const menuStart = ui.indexOf('text: "Botón de inicio SO"', launcher);
const colors = ui.indexOf('text: "Color y transparencia"', menuStart);
const shape = ui.indexOf('text: "Figura y tamaño"', colors);
const windows = ui.indexOf('text: "Cajón y ventanas"', shape);
assert(launcher > 0 && launcher < menuStart && menuStart < colors &&
       colors < shape && shape < windows, "Orden de navegación Soledad");
assert(!ui.includes('text: "Efectos luminosos"'), "Los efectos no son otra entrada lateral");
assert(!ui.includes('id: logoSubtabs'), "Efectos no deben ser otra pestaña");
assert(!ui.includes('id: outlineScroll'), "No usar scroll secundario para luz");
assert(ui.includes('id: logoScroll'), "Debe haber una sola página de logo");
assert(ui.includes('id: soLightSectionTitle'), "Falta encabezado de Efectos bajo el logo");
assert(ui.includes('text: "Efectos luminosos del botón SO"'));
assert.equal((ui.match(/text: "Botón de inicio SO"/g) || []).length, 1);
assert(!ui.includes('text: "Anchura del botón SO"'));
assert(!ui.includes('text: "Logo SO"'));
assert(ui.includes('text: "Anchura del botón SO · logo e imagen"'));
assert(!ui.includes('model: ["Logo y ancho", "Texto", "Encuadre", "Reloj"]'),
       "Se conservaron las pestañas redundantes");
assert(!ui.includes('visible: settings.logoSection === 1'),
       "El editor de texto sigue confinado a una pestaña");
assert(ui.includes('model: ["Predeterminada tropical", "Imagen propia", "Texto SO"]'));
const logoStart = ui.indexOf('text: "Logo, ancho y texto"');
const textChoice = ui.indexOf('model: ["Predeterminada tropical", "Imagen propia", "Texto SO"]', logoStart);
const textEditing = ui.indexOf('text: "Texto personalizado del botón SO"', textChoice);
const resetLogo = ui.indexOf('text: "Restablecer logo y formato"', textEditing);
const imageFit = ui.indexOf('text: "Ajuste de la imagen"', resetLogo);
const clockSection = ui.indexOf('text: "Hora y fecha en SO"', imageFit);
const effectsSection = ui.indexOf('text: "Efectos luminosos del botón SO"', clockSection);
assert(logoStart >= 0 && logoStart < textChoice &&
       textChoice < textEditing && textEditing < resetLogo &&
       resetLogo < imageFit && imageFit < clockSection &&
       clockSection < effectsSection,
       "Logo, editor de texto contextual, encuadre, reloj y efectos no mantienen el orden");
assert(ui.includes('visible: settings.logoMode === "text"'),
       "El editor contextual debe aparecer solo si se elige Texto SO");
assert(!ui.includes('text: "DEGRADADO SOLEDAD"'));
assert(!ui.includes('text: "DEGRADADO MALVINA"'));
assert(!ui.includes('model: ["Color y opacidad", "DEGRADADO", "Respiración y fondo"]'));
assert(ui.includes("function showSoledadGradient() { showSharedColors(0) }"));
assert(ui.includes("function showMalvinaGradient() { showSharedColors(1) }"));
assert(!ui.includes("logoSection"), "Las pestañas de texto/imagen se eliminaron");
assert(ui.includes('function showSoledadGlowBreathing()'));
assert(ui.includes('onClicked: settings.showSoledadGlowBreathing()'));
assert(ui.includes('text: "Ir a Botón de inicio SO → Efectos luminosos → Brillo y respiración"'));
assert(ui.includes('text: "Ir a Color y transparencia → Degradado y respiración de Soledad"'));
assert(ui.includes('onClicked: settings.showSoledadGradientBreathing()'));
assert(ui.includes('Math.min(1180, Math.max(560, Screen.desktopAvailableWidth - 48))'));
assert.equal((ui.match(/contentWidth: Math.max\(0, availableWidth - 32\)/g) || []).length, 9,
             "Margen de seguridad ausente para el scrollbar");
assert(ui.includes('id: currentColorCopyField\n                            Layout.fillWidth: true'));
assert(ui.includes('text: "Duración de cada ciclo"'));
assert(ui.includes('text: "INTENSIDAD DEL PULSO · LÍNEA SO"'));
assert(ui.includes('onValueModified: settings.setSoLineBreathingSpeed(1000 / value)'));
assert(ui.includes('Math.round(1000 / Math.max(0.1, settings.pulseSpeed))'));
assert(ui.includes('text: "Activar efecto Respiración luminosa en SO"'));
assert(ui.includes('GridLayout {'));
assert(ui.includes('columns: appearanceScroll.availableWidth >= 740 ? 3'));
assert(ui.includes('Layout.minimumWidth: 0'));
assert.equal((ui.match(/QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn/g) || []).length, 9);
assert(!ui.includes('QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded'));
assert(ui.includes('text: "RESPIRACIÓN DEL FONDO Y LOS MENÚS"'));
assert(ui.includes('text: "Activar respiración del degradado"'));
assert(ui.includes('text: "Sincronizar velocidad y ritmo con la línea SO"'));
assert(ui.includes('text: "Intensidad"'));
assert(ui.includes('text: "VELOCIDAD PROPIA DEL DEGRADADO"'));
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
                            'GradientSyncBreathing" type="Bool"><default>false</default>'),
           "La sincronización debe requerir activación del usuario: " + island);
}
// La pulsación de SO es la vista principal; al abrir efectos entra en respiración.
assert(ui.includes('property int outlineSection: 2'));
assert(ui.includes('model: ["Brillo y respiración", "Estados y color", "Luz móvil"]'));
assert(ui.includes('settings.outlineSection = [2,0,1][index]'));
assert(ui.includes('text: "VELOCIDAD DE LA RESPIRACIÓN · LÍNEA SO"'));
assert(ui.includes('text: "Sincronizar degradado Soledad con la línea SO (ritmo e intensidad)"'));
assert(ui.includes('text: "Desvincular degradado: usar velocidad e intensidad propias"'));
assert(ui.includes('text: "Igualar intensidad a la línea luminosa SO (también sincroniza ritmo)"'));
assert(ui.includes('text: "Posición de la isla en la barra…"'));
assert(ui.includes('text: "Figura y tamaño de la isla Soledad…"'));
for (const source of [ui, bar, main, kconfig]) {
    assert(source.includes("soledadGradientSyncIntensity"), "Falta nueva preferencia");
}
assert(preview.includes("demoSoledadGradientSyncIntensity"));
assert(preview.includes('"demoSoledadGradientSyncIntensity"'), "No participa en favoritos/temas del visor");
assert(preview.includes("onDemoSoledadGradientSyncIntensityChanged"));
assert(kconfig.includes('<entry name="soledadGradientSyncIntensity" type="Bool"><default>false</default>'));
assert(ui.includes('soledadGradientSyncIntensity: soledadGradientSyncIntensity'),
       "Tema no almacena la intensidad vinculada");
assert(ui.includes('"soledadGradientSyncBreathing","soledadGradientSyncIntensity"'),
       "Tema antiguo no puede restaurar opt-in de intensidad");
assert(bar.includes('soledadGradientSyncIntensity ? soActivityPulseDepth : soledadGradientBreathingIntensity'),
       "El renderer no conmuta intensidad según permiso");
assert(bar.includes('breathingFactor(soledadEffectiveBreathingIntensity,'));
assert(bar.includes('soledadEffectiveBreathingIntensity > 0'),
       "Reloj no debe prenderse si la intensidad sincronizada es cero");
assert(main.includes('Plasmoid.configuration.soledadGradientSyncIntensity = syncIntensity'));
assert(preview.includes('previewWindow.demoSoledadGradientSyncIntensity = syncIntensity'));
assert(ui.includes('property string effectStyle: "breathe"'));
assert(bar.includes('property string soActivityStyle: "breathe"'));
assert(preview.includes('property string demoSoActivityStyle: "breathe"'));
assert(kconfig.includes('<entry name="soActivityStyle" type="String"><default>breathe</default>'));
assert(kconfig.includes('<entry name="soActivityPulseSpeed" type="Double"><default>0.3</default>'));
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
// Regresión funcional de la causa reportada: antes el RowLayout quedaba
// disabled cuando el ritmo estaba sincronizado (aunque la intensidad no lo estuviera).
assert(!ui.includes("&& !syncToSO"), "La velocidad del degradado sigue bloqueada");
assert(ui.includes('text: "VELOCIDAD PROPIA DEL DEGRADADO"'));
assert(ui.includes('text: "VELOCIDAD DE LA RESPIRACIÓN · LÍNEA SO"'));
assert(ui.indexOf("VELOCIDAD DE LA RESPIRACIÓN · LÍNEA SO") <
       ui.indexOf("Sincronizar degradado Soledad con la línea SO (ritmo e intensidad)"),
       "La velocidad de la línea vuelve a estar oculta debajo del resto del menú");
assert(ui.includes("function showSoledadGradientBreathing()"));
assert(ui.includes("gradientBreathingTitle.mapToItem(scroll.contentItem"));
assert(ui.includes('onClicked: settings.showSoledadGradientBreathing()'));
assert(ui.includes('onMoved: settings.setIndependentGradientSpeed('));
assert(ui.includes('onMoved: settings.setSoLineBreathingSpeed(value)'));
assert(ui.includes('onMoved: settings.setSoLineBreathingDepth(value)'));
assert(ui.includes('text: "Mostrar la línea SO cuando hay ventanas abiertas"'));
assert(ui.includes("onPulseSpeedChanged: if (visible) refreshOutlinePreview()"));
assert(ui.includes("onPulseDepthChanged: if (visible) refreshOutlinePreview()"));
assert(ui.includes('settings.soledadGradientSyncIntensity = false'));
assert(ui.includes('settings.soledadGradientSyncBreathing = checked'));

// Ejecutar las funciones JavaScript del QML en un entorno aislado sin Qt:
// comprueba realmente el cambio de estado y que las velocidades no se mezclen.
function qmlFunction(name) {
    const start = ui.indexOf("    function " + name + "(");
    assert(start >= 0, "No existe helper " + name);
    const open = ui.indexOf("{", start);
    let depth = 0;
    for (let i = open; i < ui.length; i++) {
        if (ui[i] === "{") ++depth;
        else if (ui[i] === "}" && --depth === 0) return ui.slice(start, i + 1);
    }
    throw new Error("Bloque incompleto: " + name);
}
const interactiveState = {
    soledadGradientSyncBreathing: true, soledadGradientSyncIntensity: true,
    soledadGradientBreathingEnabled: false, soledadGradientBreathingSpeed: 0.2,
    malvinaGradientSyncBreathing: true,
    malvinaGradientBreathingEnabled: false, malvinaGradientBreathingSpeed: 0.7,
    effectStyle: "orbit", allowMotion: false, pulseSpeed: 0.2, pulseDepth: 0.7,
    previewRefreshes: 0,
    refreshOutlinePreview: function() { this.previewRefreshes++ }
};
vm.runInNewContext([
    qmlFunction("setIndependentGradientSpeed"),
    qmlFunction("setSoLineBreathingSpeed"),
    qmlFunction("setSoLineBreathingDepth"),
    "setIndependentGradientSpeed(0, 1.2)",
    "setIndependentGradientSpeed(1, 0.5)",
    "setSoLineBreathingSpeed(0.4)",
    "setSoLineBreathingDepth(0.35)"
].join("\n"), interactiveState);
assert.equal(interactiveState.soledadGradientBreathingSpeed, 1.2);
assert.equal(interactiveState.soledadGradientSyncBreathing, false);
assert.equal(interactiveState.soledadGradientSyncIntensity, false);
assert.equal(interactiveState.soledadGradientBreathingEnabled, true);
assert.equal(interactiveState.malvinaGradientBreathingSpeed, 0.5);
assert.equal(interactiveState.malvinaGradientSyncBreathing, false);
assert.equal(interactiveState.malvinaGradientBreathingEnabled, true);
assert.equal(interactiveState.effectStyle, "breathe");
assert.equal(interactiveState.allowMotion, true);
assert.equal(interactiveState.pulseSpeed, 0.4);
assert.equal(interactiveState.pulseDepth, 0.35);
assert.equal(interactiveState.previewRefreshes, 2);
// El pie fijo es el mismo en TODAS las secciones. Cancelar y la X
// revierten las preferencias editadas desde el último Aplicar.
assert(ui.includes('text: "Cancelar"'));
assert(ui.includes('text: "Aplicar"'));
assert(!ui.includes('text: "Cerrar"'));
const footer = ui.substring(ui.lastIndexOf("// Pie fijo"));
assert(footer.indexOf('text: "Cancelar"') < footer.indexOf('text: "Aplicar"'));
assert(footer.includes("onClicked: settings.close()"));
assert(footer.includes("onClicked: settings.applyChanges()"));
assert(ui.includes("onClosing: function(event) { discardPendingEdits() }"));
assert(ui.includes("function captureSettingsBaseline()"));
assert(ui.includes("function discardPendingEdits()"));
assert(ui.includes("function stageThemeSlot(slot, data)"));
assert(bar.includes("soledadSettings.captureSettingsBaseline()"));
assert(ui.includes('pendingAlignAction = "center"'));
assert(ui.includes('pendingAlignAction = "right"'));
assert(ui.includes('if (pendingAlignAction === "center") alignCenterNowRequested()'));
assert(ui.includes('else if (pendingAlignAction === "right") alignNowRequested()'));
assert(!ui.includes('text: "Mover isla 1 a la derecha AHORA"'));
const allKeysMatch = ui.match(/readonly property var editableSettingsKeys: (\[[^\n]+\])/);
assert(allKeysMatch, "No existe lista de opciones para Cancelar");
const transactionKeys = JSON.parse(allKeysMatch[1]);
const loaded = bar.substring(bar.indexOf("function openSoledadSettings("),
                             bar.indexOf("    SoledadSettings {"));
const required = [...loaded.matchAll(/soledadSettings\.([A-Za-z_][\w]*)\s*=/g)]
    .map(x => x[1]).filter(x => x !== "currentTab");
for (const name of required)
    assert(transactionKeys.includes(name), "Cancelar omite el ajuste " + name);
assert(transactionKeys.length >= 130, "Snapshot incompleto");

const state = {
    editableSettingsKeys: ["pulseSpeed", "soledadColor", "outlineConfig", "themeDayJson"],
    editableColorKeys: ["soledadColor"],
    lastAppliedSettings: {}, pendingThemeChanges: {}, baselineLoaded: false,
    pendingAlignAction: "", alignmentEdited: false,
    pulseSpeed: 0.2, soledadColor: "#112233",
    outlineConfig: {soledad:{width:1}}, themeDayJson: "tema anterior",
    appliedLabel: {text:""}, previewRefreshes:0,
    refreshOutlinePreview: function(){this.previewRefreshes++}
};
state.settings = state;
vm.runInNewContext([
    qmlFunction("preferenceCopy"),
    qmlFunction("captureSettingsBaseline"),
    qmlFunction("stageThemeSlot"),
    qmlFunction("discardPendingEdits"),
    "captureSettingsBaseline()",
    "pulseSpeed = 2.5",
    'soledadColor = "#abcdef"',
    "outlineConfig.soledad.width = 7",
    'themeDayJson = "borrador nuevo"',
    'stageThemeSlot("day", "borrador nuevo")',
    'pendingAlignAction = "right"',
    "discardPendingEdits()"
].join("\n"), state);
assert.equal(state.pulseSpeed, 0.2);
assert.equal(state.soledadColor, "#112233");
assert.equal(state.outlineConfig.soledad.width, 1);
assert.equal(state.themeDayJson, "tema anterior");
assert.equal(Object.keys(state.pendingThemeChanges).length, 0);
assert.equal(state.pendingAlignAction, "");
assert.equal(state.baselineLoaded, false);
assert.equal(state.previewRefreshes, 1);
// Luego de un «Aplicar» se captura un nuevo checkpoint, no el original.
vm.runInNewContext([
    qmlFunction("preferenceCopy"), qmlFunction("captureSettingsBaseline"),
    qmlFunction("discardPendingEdits"),
    "pulseSpeed = 0.6", "captureSettingsBaseline()",
    "pulseSpeed = 2.1", "discardPendingEdits()"
].join("\n"), state);
assert.equal(state.pulseSpeed, 0.6);
console.log("OK: logo/texto/luz juntos, Cancelar/Aplicar, 139 ajustes reversibles y respiración independiente.");
