// Prueba de la extracción cromática y del contrato de aplicación.
// Ejecutar: node prototype/v0.1/tests/test_palette_extractor.cjs
// No sustituye la validación gráfica Qt/CachyOS.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const root = path.join(__dirname, "..");
const source = fs.readFileSync(path.join(root, "package/contents/ui/PaletteExtractor.js"), "utf8");
const extract = vm.runInNewContext(source + "\nextractDominantColors;", {});

function pixels(groups) {
    const data = [];
    for (const [hex, quantity] of groups) {
        const rgb = [1,3,5].map(i => parseInt(hex.slice(i, i + 2), 16));
        for (let k = 0; k < quantity; k++) data.push(...rgb, 255);
    }
    return data;
}
const swatches = extract(pixels([
    ["#408bcc", 180], ["#3bd7e9", 100], ["#34a464", 70]
]), 3);
assert.equal(swatches.length, 3);
assert.deepEqual(Array.from(swatches, x => x.hex),
                 ["#408bcc", "#3bd7e9", "#34a464"]);
assert(swatches[0].pixels > swatches[1].pixels);
assert(swatches[1].pixels > swatches[2].pixels);
const single = extract(pixels([["#3060bc", 120]]), 3);
assert.equal(single.length, 1, "No inventar tonos si la imagen solo tiene uno");
const noColor = extract([0,0,0,255, 255,255,255,255], 3);
assert.equal(noColor.length, 0, "Evitar crear un color inexistente");
const qml = fs.readFileSync(path.join(root, "package/contents/ui/SoledadSettings.qml"), "utf8");
assert(qml.includes("PaletteExtractor.extractDominantColors(raw, 3)"));
assert(qml.includes("function chooseSampledColor(index, slot)"));
assert(qml.includes("function setIslandHex(slot, raw)"));
assert(qml.includes("currentBaseHex.copy()"));
assert(qml.includes("currentEndHex.copy()"));
assert(qml.includes("sampleHexField.copy()"));
assert(qml.includes('text: "Usar como color 1"'));
assert(qml.includes('text: "Usar como color 2"'));
assert(qml.includes('text: "Dirección del degradado"'));
assert(qml.includes('text: "Activar degradado de la isla seleccionada"'));
for (const old of ["putSuggestedPaletteOnSoledad", "suggestedIslandBase",
                  "suggestIslandFromCurrentOutline"]) {
    assert(!qml.includes(old), "Se encontró código anterior: " + old);
}
console.log("OK: colores dominantes, selección independiente, HEX y degradado.");
