// Contrato de dos/tres tonos en los componentes QML del visor experimental.
// Ejecutar desde Fish: node prototype/v0.1/tests/test_gradient_palette.cjs
// Solo prueba estática: no sustituye la ejecución QML/CachyOS.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.join(__dirname, "..");
function read(name) {
    return fs.readFileSync(path.join(base, name), "utf8");
}
const settings = read("package/contents/ui/SoledadSettings.qml");
const bar = read("package/contents/ui/SmartBarContent.qml");
const main = read("package/contents/ui/main.qml");
const kconfig = read("package/contents/config/main.xml");
const preview = read("preview_redimensionable.qml");
const launcher = read("package/contents/ui/SoLauncherPopup.qml");
const search = read("package/contents/ui/MalvinaSearch.qml");
const popup = read("package/contents/ui/IslandPopupSurface.qml");
const island = read("package/contents/ui/MalvinaIsland.qml");
for (const name of ["soledad", "malvina"]) {
    assert(settings.includes('property int ' + name + 'GradientColorCount: 2'));
    assert(bar.includes('property int ' + name + 'GradientColorCount: 2'));
    assert(preview.includes('property int demo' + name[0].toUpperCase() +
                            name.slice(1) + 'GradientColorCount: 2'));
    assert(kconfig.includes('<entry name="' + name +
                            'GradientColorCount" type="Int"><default>2</default>'));
    for (const source of [settings, bar, main, preview, kconfig])
        assert(source.includes(name + 'GradientThird'),
               "Tercer tono perdido en transporte: " + name);
}
assert.match(settings, /requestTargetIsland = appearanceTarget\.currentIndex/);
assert.match(settings, /settings\.sampledColors = colors\.map/);
assert.match(settings, /settings\.soledadColor = first/);
assert.match(settings, /settings\.soledadGradientEnd = second/);
assert.match(settings, /settings\.soledadGradientThird = third/);
assert.match(settings, /settings\.soledadGradientColorCount = 2/);
assert.match(settings, /settings\.malvinaGradientColorCount = 2/);
assert.match(settings, /settings\.soledadGradientEnabled = true/);
assert.match(settings, /settings\.malvinaGradientEnabled = true/);
assert.match(settings, /model: \["2 colores \(predeterminado\)", "3 colores"\]/);
assert.match(settings, /settings\.selectedSampleIndex\(slotName\)/);
assert.match(settings, /settings\.chooseSampledColor\(i - 1, slotName\)/);
assert.match(settings, /slotName:\s*index === 0 \? "base" : index === 1 \? "end" : "third"/);
assert.match(settings, /settings\.gradientPreviewStop\(2\)/);
assert.match(bar, /onSaveIslandGradientRequested: function\(a, b, c, d, e, f, g, h, i, j\)/);
assert.match(preview, /onRequestIslandGradientChange: function\(a, b, c, d, e, f, g, h, i, j\)/);
assert.match(main, /onRequestIslandGradientChange: function\(a, b, c, d, e, f, g, h, i, j\)/);
assert((bar.match(/addColorStop\(0\.5/g) || []).length >= 3,
       "Soledad y punta Malvina deben dibujar tres paradas");
assert(bar.includes("position: root.malvinaGradientColorCount === 3 ? 0.5 : 1"));
assert(popup.includes("position: surface.gradientColorCount === 3 ? 0.5 : 1"));
assert(search.includes("position: search.islandGradientColorCount === 3 ? 0.5 : 1"));
assert(island.includes("position: island.gradientColorCount === 3 ? 0.5 : 1"));
assert.equal((launcher.match(/IslandPopupSurface\s*\{/g) || []).length,
             (launcher.match(/thirdColor: launcher\.islandGradientThird/g) || []).length,
             "Todo panel flotante SO debe recibir el tercer tono");
assert(launcher.includes("islandGradientColorCount"));
assert(search.includes("gradientColorCount: search.islandGradientColorCount"));
assert(preview.includes('key.endsWith("GradientThird")'),
       "Persistencia de colores de Qt Settings debe serializar tercer HEX");
console.log("OK: 2 colores predeterminados, tercer tono optativo, transporte, pintado y guardado.");
