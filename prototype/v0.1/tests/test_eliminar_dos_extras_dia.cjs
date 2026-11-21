"use strict";
// Regresión PURA: no leer ni escribir Qt Settings, imágenes o paneles KDE.
const assert = require("node:assert/strict");
const path = require("node:path");
const fs = require("node:fs");
const clean = require(path.join(__dirname, "../scripts/eliminar_dos_extras_dia.cjs"));

assert.deepEqual(clean.EXTRA_NAMES, [
    "Día · versión anterior", "Día · respaldo 2026-11-20T02-00"
]);
const library = [
    {name:"Atardecer",jsonData:"sunset"},
    {name:"Noche",jsonData:"night"},
    {name:"Día",jsonData:"day-original"},
    {name:"Día · versión anterior",jsonData:"day-previous"},
    {name:"Mi tema",jsonData:"other"},
    {name:"Día · respaldo 2026-11-20T02-00",jsonData:"day-backup"},
    {name:"Día · respaldo 2026-11-21T02-00",jsonData:"different-backup"},
    {name:"Anoche",jsonData:"another"},
    {name:"",jsonData:"empty-name-legacy"}
];
const original = JSON.stringify(library);
const plan = clean.cleanLibrary(original);
assert.equal(plan.status, "ready");
assert.deepEqual(plan.removed, clean.EXTRA_NAMES);
assert.deepEqual(JSON.parse(plan.result), [
    library[0], library[1], library[2], library[4], library[6], library[7], library[8]
], "Solo se quitan los dos nombres exactos. Todo lo demás queda intacto.");
assert.equal(original, JSON.stringify(library), "La función no muta la entrada");
assert.equal(clean.cleanLibrary(plan.result).status, "already-clean",
             "Segunda ejecución es inocua");
assert.equal(clean.cleanLibrary("[]").status, "already-clean");
assert.equal(clean.cleanLibrary(JSON.stringify([{name:"Día",jsonData:"x"}])).status,
             "already-clean");
assert.throws(() => clean.cleanLibrary(JSON.stringify([
    library[3], library[3], library[5]
])), /no aparecen exactamente una vez/, "Duplicados ambiguos detienen limpieza");
assert.throws(() => clean.cleanLibrary(JSON.stringify([library[3]])),
              /no aparecen exactamente una vez/, "Una coincidencia faltante impide cambios");
assert.throws(() => clean.cleanLibrary("{json roto"), SyntaxError);
assert.throws(() => clean.cleanLibrary("{}"), /no es una lista/);
assert.throws(() => clean.cleanLibrary(null), /no es texto/);

// Asegurar generación de QML sin ejecutar ningún escritor. Entradas extrañas
// en los temas son datos y nunca deberían poder inyectar código QML.
const strange = 'línea 1"\n}); Qt.quit(); //\u2028unicode';
const qml = clean.writeQml(strange, plan.result);
assert(qml.includes('category: "plasma-smartbar-v01-preview-appearance"'));
assert(qml.includes('const current = String(saved.value("themeLibraryJson", "[]"))'));
assert(qml.includes("current !== " + clean.qmlLiteral(strange)));
assert(qml.includes("const next = " + clean.qmlLiteral(plan.result)));
assert(qml.includes('saved.setValue("themeLibraryJson", next)'));
assert(qml.includes('saved.sync()'));
assert(qml.includes("SMARTBAR_THEME_CLEANUP_CONFLICT"));
assert(qml.includes("SMARTBAR_THEME_CLEANUP_WRITTEN"));
assert(!qml.includes('saved.setValue("themeDayJson"'));
assert(!qml.includes('saved.setValue("themeNightJson"'));

const src = fs.readFileSync(
    path.join(__dirname, "../scripts/eliminar_dos_extras_dia.cjs"), "utf8");
assert(src.includes("makeBackup(original)"), "Copia completa anterior a escritura");
assert(src.indexOf("const backup = makeBackup(original)") <
       src.indexOf("const log = runQml(runner, writer)"), "Respaldo primero");
assert(src.includes("confirmed !== plan.result"), "Comprobar escritura en otra lectura");
assert(src.includes("if (plan.status === \"already-clean\")"));
assert(!/requestClose|wpctl|pactl|kquitapp|plasmashell/.test(src),
       "No manipular ventanas/sonido/panel KDE");
console.log("OK: solo dos extras de Día, copia segura, 3 temas principales conservados.");
