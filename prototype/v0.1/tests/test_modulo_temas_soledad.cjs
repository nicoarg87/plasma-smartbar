#!/usr/bin/env node
"use strict";
// Protege la extracción de Temas/Playa 24hs y sus dependencias sin iniciar Qt/KDE.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const host = fs.readFileSync(path.join(dir, "SoledadSettings.qml"), "utf8");
const page = fs.readFileSync(path.join(dir, "SoledadThemesPage.qml"), "utf8");
assert.match(host, /SoledadThemesPage\s*\{\s*id:\s*themesPage\s*settingsTarget:\s*settings\s*imagePicker:\s*chooseImage\s*paletteSamplerTarget:\s*paletteSampler\s*\}/);
assert.match(host, /settings\.creatingNewTheme && themesPage\.extractPaletteForNewTheme/);
for (const field of [
    "required property var settingsTarget",
    "required property var imagePicker",
    "required property var paletteSamplerTarget",
    "property alias extractPaletteForNewTheme: useGifPaletteForTheme.checked",
    'import "ThemePack.js" as ThemePack',
    'import "WallpaperFadeDuration.js" as WallpaperFadeDuration',
    "ThemePack.DEFAULT_ID",
    "ThemePack.labels(settings.selectedThemePack)",
    "WallpaperFadeDuration.limits",
    "id: themeOptionsPopup",
    "id: themeScheduleMenu",
    "settings.selectedThemePack",
    "settings.themeScheduleEnabled",
    "settings.updateScheduleTheme",
    "settings.saveNamedTheme()",
    "settings.createPersonalPack()",
    "settings.togglePackCandidate(index, checked)",
    "imagePicker.open()",
    'paletteSamplerTarget.suggestFromImage("theme")'
]) assert.ok(page.includes(field), "No se conservó: " + field);
assert.ok(host.includes("function applyChanges()"));
assert.ok(host.includes("function discardPendingEdits()"));
assert.ok(host.includes("id: chooseImage"));
assert.ok(host.includes("id: paletteSampler"));
assert.doesNotMatch(host, /\bthemesScroll\b|\buseGifPaletteForTheme\b/);
assert.doesNotMatch(page, /\bchooseImage\b|\bpaletteSampler\.|\bQtCore\.Settings\b|\bfunction applyChanges\(/);
assert.equal((page.match(/id: themeOptionsPopup/g) || []).length, 1);
assert.equal((page.match(/id: useGifPaletteForTheme/g) || []).length, 1);
console.log("OK: página de temas modular, Playa 24hs, packs, programación y guardado central intactos.");
