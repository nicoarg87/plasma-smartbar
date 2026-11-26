#!/usr/bin/env node
"use strict";
// Comprueba las conexiones QML de dos extracciones sin iniciar KDE.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const ui = path.resolve(__dirname, "../package/contents/ui");
const read = name => fs.readFileSync(path.join(ui, name), "utf8");
const host = read("SoledadSettings.qml");
const exportDialog = read("SoledadFactoryExportDialog.qml");
const palette = read("SoledadPaletteSampler.qml");
assert.match(host, /SoledadFactoryExportDialog\s*\{\s*id:\s*factoryNightExportDialog\s*settingsTarget:\s*settings\s*\}/);
assert.ok(host.includes("factoryNightExportDialog.open()"));
for (const phrase of [
  "required property var settingsTarget",
  'settings.factoryExportTarget === "sunset"',
  "settings.factoryNightCandidateJson()",
  "readOnly: true",
  "factoryNightExportText.selectAll()",
  "factoryNightExportText.copy()",
  "factoryNightExportText.deselect()"
]) assert.ok(exportDialog.includes(phrase), "Diálogo: " + phrase);
assert.match(host, /SoledadPaletteSampler\s*\{\s*id:\s*paletteSampler\s*settingsTarget:\s*settings\s*appearanceTargetIndex:\s*appearancePage.currentTargetIndex\s*\}/);
for (const phrase of [
  "required property var settingsTarget",
  "required property int appearanceTargetIndex",
  "id: paletteImageLoadTimeout",
  "interval: 3500",
  "function suggestFromImage(mode)",
  "requestTargetIsland = appearanceTargetIndex",
  "paletteImageLoadTimeout.restart()",
  "paletteImageLoadTimeout.stop()",
  "loadImage(requestedUrl)",
  "activeUrl !== requestedUrl",
  "PaletteExtractor.extractDominantColors(raw, 3)",
  "settings.sampledColors = colors.map",
  'settings.chooseCoordinatedPalette(',
  'if (requestMode === "theme")'
]) assert.ok(palette.includes(phrase), "Paleta: " + phrase);
assert.doesNotMatch(host, /id:\s*paletteImageLoadTimeout|id:\s*factoryNightExportText|PaletteExtractor.extractDominantColors/);
assert.ok(host.includes("function applyChanges()") && host.includes("function discardPendingEdits()"));
assert.doesNotMatch(exportDialog + palette, /QtCore\.Settings|function applyChanges\(/);
console.log("OK: diálogo de exportación y muestreador GIF modulares; persistencia central preservada.");
