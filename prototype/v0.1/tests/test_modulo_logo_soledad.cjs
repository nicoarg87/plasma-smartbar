#!/usr/bin/env node
"use strict";
// Contratos de la página modular del logo SO; no inicia Qt ni altera KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const dir = path.resolve(__dirname, "../package/contents/ui");
const host = fs.readFileSync(path.join(dir, "SoledadSettings.qml"), "utf8");
const logo = fs.readFileSync(path.join(dir, "SoledadLogoPage.qml"), "utf8");
const connections = {
    imageFileDialog: "chooseImage",
    textFontPicker: "soTextFontDialog",
    textColorPicker: "soTextColorDialog",
    textBackgroundColorPicker: "soTextBackgroundDialog",
    textBackgroundFileDialog: "chooseTextBackground",
    clockFontPicker: "clockFontDialog",
    clockColorPicker: "clockColorDialog",
    lightOutlineColorPicker: "outlineColorDialog",
    glowColorPicker: "glowColorDialog",
    paletteSamplerTarget: "paletteSampler"
};
assert.match(host, /SoledadLogoPage\s*\{\s*id:\s*logoPage\s*settingsTarget:\s*settings/);
for (const [property, id] of Object.entries(connections)) {
    assert.ok(logo.includes("required property var " + property), "Propiedad faltante: " + property);
    assert.ok(host.includes(property + ": " + id), "Conexión faltante: " + property);
}
for (const token of [
    "function resetScroll()",
    "function scrollToLight()",
    "soLightSectionTitle.mapToItem",
    "settings.logoMode",
    "settings.cropFitMode",
    "settings.clockFontSize",
    "settings.effectStyle",
    "settings.showOutlineWhenEmpty",
    'paletteSamplerTarget.suggestFromImage("contour")'
]) assert.ok(logo.includes(token), "Contenido no encontrado: " + token);
assert.ok(host.includes("logoPage.resetScroll()"));
assert.ok(host.includes("logoPage.scrollToLight()"));
assert.match(host, /function applyChanges\(\)/);
assert.match(host, /function discardPendingEdits\(\)/);
assert.doesNotMatch(host, /\blogoScroll\b|\bsoLightSectionTitle\b/);
assert.doesNotMatch(logo, /\bQtCore\.Settings\b|\bfunction applyChanges\(/);
console.log("OK: página del logo SO, diez conexiones y navegación modular preservadas.");
