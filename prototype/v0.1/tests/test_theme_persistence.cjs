// Validación estática del contrato de persistencia de temas y favorita.
// Ejecutar: node prototype/v0.1/tests/test_theme_persistence.cjs
// No sustituye el ensayo gráfico Qt/CachyOS.
"use strict";
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const base = path.join(__dirname, "..");
const settings = fs.readFileSync(path.join(base, "package/contents/ui/SoledadSettings.qml"), "utf8");
const preview = fs.readFileSync(path.join(base, "preview_redimensionable.qml"), "utf8");
const root = fs.readFileSync(path.join(base, "package/contents/ui/SmartBarContent.qml"), "utf8");
const plasmoid = fs.readFileSync(path.join(base, "package/contents/ui/main.qml"), "utf8");
const kcfg = fs.readFileSync(path.join(base, "package/contents/config/main.xml"), "utf8");

function block(source, functionName) {
    const start = source.indexOf("function " + functionName + "(");
    assert(start >= 0, functionName + " debe existir");
    let open = source.indexOf("{", start);
    assert(open >= 0);
    let level = 0;
    for (let i = open; i < source.length; ++i) {
        if (source[i] === "{") ++level;
        if (source[i] === "}") {
            --level;
            if (level === 0) return source.slice(open, i + 1);
        }
    }
    throw new Error("Bloque no cerrado: " + functionName);
}

const saveFavorite = block(preview, "saveFavoriteAppearance");
assert.match(saveFavorite, /setValue\("favoriteSoledadV1", current\)/);
assert.doesNotMatch(saveFavorite, /theme(?:Day|Night|Custom)Json|setValue\("appearanceV1"/);
const savePersonalDefault = block(preview, "savePersonalDefault");
assert.match(savePersonalDefault, /setValue\("personalDefaultV1", current\)/);
assert.doesNotMatch(savePersonalDefault, /setValue\("appearanceV1"/);
const restore = block(preview, "restoreSavedAppearance");
assert.match(restore, /appearanceWriteSuspended = true/);
assert.match(restore, /appearanceWriteSuspended = false/);
assert.match(restore, /saveAppearancePreset\(\)/);
const snapshot = block(settings, "themeSnapshot");
const activate = block(settings, "activateTheme");
for (const field of [
    "soledadColor", "soledadGradientEnd", "soledadGradientDirection",
    "malvinaColor", "malvinaGradientEnd", "malvinaGradientDirection",
    "soledadGradientSyncBreathing", "malvinaGradientSyncBreathing",
    "backgroundColor", "soTextBackground", "taskFrameColor",
    "launcherOpacity", "malvinaOptionsOpacity", "outlineConfig"
]) {
    assert(snapshot.includes(field), "Snapshot sin " + field);
    assert(activate.includes(field), "Restauración sin " + field);
}
assert.doesNotMatch(activate, /applyBeachDayPalette|synchronizeIslandPalette/);
assert.match(activate, /applyChanges\(\)/);
assert(!settings.includes('id: updateSunsetConfirmation'),
       "Atardecer de fábrica no admite sobrescritura con el editor");
assert(!settings.includes('id: restoreSunsetConfirmation'),
       "No deben mezclarse respaldos históricos con tema original");
assert(!settings.includes('function updateSunsetFromCurrent()'),
       "La operación anterior de reescritura debe quedar inaccesible");
assert(!settings.includes('function restorePreviousSunset()'),
       "La rotación de respaldos no puede modificar Atardecer original");
assert.match(block(settings, "storeTheme"), /stageThemeSlot\(slot, data\)/);
assert.doesNotMatch(block(settings, "storeTheme"), /saveThemeSlotRequested/);
assert.match(block(settings, "applyChanges"),
             /saveThemeSlotRequested\(slot, pendingThemeChanges\[slot\]\)/);
assert.match(block(settings, "discardPendingEdits"),
             /pendingThemeChanges = \(\{\}\)/);
assert.match(block(settings, "captureSettingsBaseline"),
             /pendingThemeChanges = \(\{\}\)/);
assert.match(settings, /text: "Restaurar Atardecer de fábrica"/);
assert.match(settings, /onClicked: settings.activateTheme\("sunset"\)/);
assert(!settings.includes('text: "Fijar Atardecer"'));
assert(!settings.includes('text: "Actualizar Atardecer con estética actual…"'));
assert(settings.includes("themeDayJson"), "Conservar legado sin borrar preferencias");
for (const s of [settings, preview, root, plasmoid, kcfg]) {
    assert(s.includes("themeDayPreviousJson"), "Falta conexión de respaldo");
}
assert.match(preview, /slot === "dayPrevious"/);
assert.match(plasmoid, /slot === "dayPrevious"/);
console.log("OK: ranuras, copia recuperable y favorita aisladas (validación estática).");
