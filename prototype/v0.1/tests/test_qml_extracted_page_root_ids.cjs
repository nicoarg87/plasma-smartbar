#!/usr/bin/env node
"use strict";
// Detecta una regresión real de extracción QML: dos "id:" asignados
// al mismo ScrollView raíz. No requiere escritorio, Qt ni permisos extra.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const ui = path.resolve(__dirname, "../package/contents/ui");
const pages = [
    "SoledadAboutPage.qml",
    "SoledadAppearancePage.qml",
    "SoledadBehaviorPage.qml",
    "SoledadGeometryPage.qml",
    "SoledadLogoPage.qml",
    "SoledadSharedOutlinesPage.qml",
    "SoledadTaskStylesPage.qml",
    "SoledadThemesPage.qml"
];
for (const name of pages) {
    const code = fs.readFileSync(path.join(ui, name), "utf8");
    assert.match(code, /QQC2\.ScrollView\s*\{/, name + ": falta ScrollView raíz");
    // En estas vistas, la primera ColumnLayout es el primer ítem
    // del ScrollView. Antes de ella solamente pueden declararse
    // propiedades, funciones y el identificador del propio ScrollView.
    const start = code.indexOf("QQC2.ScrollView {");
    const firstChild = code.indexOf("ColumnLayout {", start);
    assert.ok(firstChild > start, name + ": estructura de vista no reconocida");
    const rootHeader = code.slice(start, firstChild)
        .replace(/\/\*[\s\S]*?\*\//g, "")
        .replace(/^\s*\/\/.*$/gm, "");
    const ids = [...rootHeader.matchAll(/^\s*id:\s*([a-zA-Z_][a-zA-Z0-9_]*)\b/gm)]
        .map(match => match[1]);
    assert.deepEqual(ids, ["page"], name +
        ": la raíz ScrollView debe tener un único id 'page', no " + ids);
}
console.log("OK: 8 páginas extraídas tienen un solo id raíz; sin duplicados QML.");
