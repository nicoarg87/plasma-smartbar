// Extracción de búsquedas/índices de temas PERSONALES hacia ThemeLibrary.js.
// No crea, elimina, restaura ni guarda temas; no abre Qt ni altera KConfig.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const ui = path.resolve(__dirname, "../package/contents/ui");
const librarySource = fs.readFileSync(path.join(ui, "ThemeLibrary.js"), "utf8");
const qml = fs.readFileSync(path.join(ui, "SoledadSettings.qml"), "utf8");
assert(librarySource.startsWith(".pragma library\n"));
assert(qml.includes('import "ThemeLibrary.js" as ThemeLibrary'));
const library = {};
vm.runInNewContext(librarySource.replace(/^\s*\.pragma library\s*/, ""), library);
for (const name of ["parse", "namedThemeIndex", "otherNamedThemes",
                    "otherNamedThemeOriginalIndex"])
    assert.equal(typeof library[name], "function", "Falta " + name);

const entries = [
    {name: "Mi uno", jsonData: "{\"x\":1}"},       // 0
    {name: "  Día  ", jsonData: "{\"x\":2}"},     // 1: primer Día
    {name: "  Atardecer ", jsonData: "{\"x\":3}"}, // 2
    {name: "Dia", jsonData: "{\"x\":4}"},          // 3: otro Día
    {name: "Noche", jsonData: "{\"x\":5}"},        // 4
    {name: "ANOCHE", jsonData: "{\"x\":6}"},       // 5
    {name: "Día", jsonData: "{\"x\":7}"},          // 6: Día duplicado
    {name: "Mi dos", jsonData: "{\"x\":8}"},       // 7
    {name: "", jsonData: "{\"x\":9}"},             // 8: nombre vacío histórico
    {name: "sin perfil", jsonData: ""},             // inválido
    null                                              // inválido
];
const originalJson = JSON.stringify(entries);
const saved = library.parse(originalJson);
assert.equal(saved.length, 9, "Se conservan entradas históricas válidas");
const before = JSON.stringify(saved);

assert.equal(library.namedThemeIndex(saved, "day"), 1);
assert.equal(library.namedThemeIndex(saved, "sunset"), 2);
assert.equal(library.namedThemeIndex(saved, "night"), 4);
assert.equal(library.namedThemeIndex(saved, "inexistente"), -1);
assert.equal(library.namedThemeIndex([], "day"), -1);
assert.equal(library.namedThemeIndex([], "night"), -1);

const other = library.otherNamedThemes(saved);
assert.deepEqual(Array.from(other, x => x.name),
                 ["Mi uno", "  Atardecer ", "Noche", "ANOCHE", "Mi dos", ""]);
const positions = [0, 2, 4, 5, 7, 8];
for (let i = 0; i < positions.length; ++i)
    assert.equal(library.otherNamedThemeOriginalIndex(saved, i),
                 positions[i], "Índice del tema personal " + i);
for (const invalidIndex of [-1, positions.length, 99, 1.5])
    assert.equal(library.otherNamedThemeOriginalIndex(saved, invalidIndex), -1);
assert.equal(library.otherNamedThemes([]).length, 0);
assert.equal(library.otherNamedThemeOriginalIndex([], 0), -1);
assert.equal(JSON.stringify(saved), before, "No modificar temas guardados");
assert.equal(JSON.stringify(entries), originalJson, "No mutar entradas origen");

// API QML previa y reevaluación reactiva cuando cambia savedThemeLibrary.
assert(qml.includes("function namedThemeIndex(theme) {"));
assert(qml.includes("return ThemeLibrary.namedThemeIndex(savedThemeLibrary, theme)"));
assert(qml.includes('function dayThemeIndex() { return namedThemeIndex("day") }'));
assert(qml.includes("readonly property var otherNamedThemes: ThemeLibrary.otherNamedThemes(savedThemeLibrary)"));
assert(qml.includes("return ThemeLibrary.otherNamedThemeOriginalIndex(savedThemeLibrary, index)"));

// Ejecutar las fachadas QML sin crear componentes ni tocar preferencias.
const begin = qml.indexOf("    function namedThemeIndex(theme) {");
const end = qml.indexOf("    // Perfil Noche original", begin);
assert(begin >= 0 && end > begin, "No se halló bloque de fachadas QML");
const wrapperSource = qml.slice(begin, end).replace(
    /^\s*readonly property var otherNamedThemes:[^\n]*$/m, "");
const ctx = {ThemeLibrary: library, savedThemeLibrary: saved};
vm.runInNewContext(wrapperSource, ctx);
assert.equal(ctx.dayThemeIndex(), 1, "Día usa su índice original");
assert.equal(ctx.namedThemeIndex("sunset"), 2);
assert.equal(ctx.otherNamedThemeOriginalIndex(0), 0);
assert.equal(ctx.otherNamedThemeOriginalIndex(1), 2);
assert.equal(ctx.otherNamedThemeOriginalIndex(5), 8);
assert(qml.includes('id: themeOptionsPopup') && qml.includes('CloseOnPressOutsideParent'),
       "Conservar selector único desplegable");
assert(qml.includes('id: themeSelectorButton') &&
       qml.includes('settings.factoryDayAvailable'),
       "Mantener temas de fábrica separados de la biblioteca personal");
console.log("OK: índices estables de temas personales y fachadas QML, sin tocar presets.");
