// Regresión de la primera extracción interna: ThemeLibrary.js.
// No abre Qt, no escribe preferencias ni reemplaza imágenes.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const uiDir = path.join(__dirname, "..", "package", "contents", "ui");
const qml = fs.readFileSync(path.join(uiDir, "SoledadSettings.qml"), "utf8");
const js = fs.readFileSync(path.join(uiDir, "ThemeLibrary.js"), "utf8");
assert(js.startsWith(".pragma library\n"), "El módulo debe ser importable en QML");
assert(qml.includes('import "ThemeLibrary.js" as ThemeLibrary'));
assert(qml.includes("readonly property var savedThemeLibrary: parseThemeLibrary(themeLibraryJson)"));
assert(qml.includes('console.warn("SmartBar: biblioteca de temas inválida, no se borró", error)'));

const library = {};
vm.runInNewContext(js.replace(/^\s*\.pragma library\s*/, ""), library);
assert.equal(typeof library.parse, "function");
const warnings = [];
const ctx = {
    ThemeLibrary: library,
    console: {warn: (...args) => warnings.push(args)},
};
const start = qml.indexOf("    function parseThemeLibrary(json) {");
assert(start >= 0);
const end = qml.indexOf("\n    function saveNamedTheme()", start);
assert(end > start, "Mantener la API QML anterior al guardado");
vm.runInNewContext(qml.slice(start, end), ctx);

assert.equal(ctx.parseThemeLibrary("").length, 0);
assert.equal(ctx.parseThemeLibrary("[]").length, 0);
assert.equal(ctx.parseThemeLibrary("{}").length, 0);
assert.equal(ctx.parseThemeLibrary("null").length, 0);
assert.equal(ctx.parseThemeLibrary("false").length, 0);

const original = [
    {name: "Día", jsonData: '{"logoMode":"custom"}'},
    {name: "Atardecer", jsonData: "x"},
    {name: "Noche", jsonData: "{}"},
    {name: "", jsonData: "{}"}, // La validación histórica permite nombres vacíos.
    {name: "sin JSON", jsonData: ""},
    {name: "sin perfil"},
    {name: 3, jsonData: "{}"},
    null, false, 42,
    {name: "Día", jsonData: "duplicado"} // No deduplicar temas guardados.
];
const serialized = JSON.stringify(original);
const result = Array.from(ctx.parseThemeLibrary(serialized));
assert.deepEqual(result, [original[0], original[1], original[2], original[3], original[10]]);
assert.equal(serialized, JSON.stringify(original), "El parser no debe reescribir entradas");
assert.equal(warnings.length, 0, "Datos válidos no deben generar advertencias");
assert.deepEqual(Array.from(ctx.parseThemeLibrary("{json roto")), []);
assert.equal(warnings.length, 1);
assert.match(String(warnings[0][0]), /biblioteca de temas inválida/);
assert.deepEqual(Array.from(ctx.parseThemeLibrary(serialized)), result,
    "Tras un error se deben conservar intactas las entradas anteriores");

console.log("OK: módulo puro de biblioteca, tolerancia histórica, perfiles y originales intactos.");
