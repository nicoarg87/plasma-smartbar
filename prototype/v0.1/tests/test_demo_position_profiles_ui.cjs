"use strict";
// Regression de cableado para el ensayo Qt: no sustituye una prueba visual.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const qml = fs.readFileSync(path.join(base, "package/contents/ui/SmartBarContent.qml"), "utf8");
const preview = fs.readFileSync(path.join(base, "preview_redimensionable.qml"), "utf8");
const main = fs.readFileSync(path.join(base, "package/contents/ui/main.qml"), "utf8");
for (const marker of [
    'import "SoledadPositionProfiles.js" as SoledadPositionProfiles',
    'function applyDemoPositionProfile()',
    'function saveDemoPositionProfile()',
    'function deleteDemoPositionProfile()',
    'requestDemoPositionProfilesChange(updated)',
    'if (previewMaximized) applyDemoPositionProfile()',
    'text: "Recordar esta posición para " + root.lastDemoSelection',
    'text: "Olvidar posición de " + root.lastDemoSelection',
    'visible: root.demoProfileContextReady',
    'visible: root.demoProfileExists',
    'demoWindowControlsEnabled && !usingRealTasks && previewMaximized'
]) assert(qml.includes(marker), "Falta integración: " + marker);
for (const marker of [
    'soledadDemoPositionProfilesV1',
    'demoPositionProfilesJson: previewWindow.demoPositionProfilesJson',
    'onRequestDemoPositionProfilesChange: function(json)',
    'localPreviewSettings.sync()'
]) assert(preview.includes(marker), "Falta visor: " + marker);
assert(!main.includes('onRequestDemoPositionProfilesChange'),
    "No se permite persistir posiciones ficticias en el applet Plasma");
assert(!qml.includes('requestActivate(') && !qml.includes('requestClose('),
    "La simulación no debe manipular las ventanas KDE");
console.log("OK: memoria por aplicación conectada al visor y agarre, sin alterar panel KDE.");
