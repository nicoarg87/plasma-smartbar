// Limpieza puntual de DOS respaldos Día: no toca los temas principales.
// Regresión de política pura + guardas estáticas de scripts de Qt.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const base = path.resolve(__dirname, "..");
const ui = path.join(base, "package/contents/ui");
const policy = fs.readFileSync(path.join(ui, "DayEntryCleanup.js"), "utf8");
const moduleContext = {};
assert(policy.startsWith(".pragma library\n"));
vm.runInNewContext(policy.replace(/^\s*\.pragma library\s*/, ""), moduleContext);
assert.equal(typeof moduleContext.plan, "function");

const original = [
    {name:"Atardecer",jsonData:"atardecer"},
    {name:"Noche",jsonData:"noche"},
    {name:"Día",jsonData:"dia-principal"},
    {name:"Día · versión anterior",jsonData:"anterior"},
    {name:"Mi tema",jsonData:"personal"},
    {name:"Día · respaldo 2026-11-20T02-00",jsonData:"respaldo"},
    {name:"Día · respaldo 2026-11-19T00-00",jsonData:"otro-no-autorizado"},
    {name:"Día · modificado",jsonData:"modificado"},
    {name:"Dia",jsonData:"otro-principal-historico"},
    null, false
];
const frozen = JSON.stringify(original);
const result = moduleContext.plan(original);
assert(result.ok);
assert.deepEqual(Array.from(result.removed), [
    "Día · versión anterior", "Día · respaldo 2026-11-20T02-00"]);
assert.equal(result.items.length, original.length-2);
assert.deepEqual(Array.from(result.items, x => x && x.name), [
    "Atardecer", "Noche", "Día", "Mi tema",
    "Día · respaldo 2026-11-19T00-00", "Día · modificado", "Dia",
    null, false
]);
assert.equal(JSON.stringify(original), frozen, "No mutar biblioteca original");
assert.equal(result.items[2], original[2], "No alterar Día principal");
assert.equal(result.items[0], original[0], "No alterar Atardecer");
assert.equal(result.items[1], original[1], "No alterar Noche");

assert.equal(moduleContext.plan([]).ok, false, "Faltan entradas");
assert.equal(moduleContext.plan("[]").ok, false, "Tipo equivocado");
assert.equal(moduleContext.plan(original.filter(x => x?.name !== "Día · versión anterior")).ok, false);
assert.equal(moduleContext.plan(original.concat([original[3]])).ok, false,
             "Ante entradas duplicadas, abortar en lugar de borrar más");
assert.equal(moduleContext.plan(original.concat([original[5]])).ok, false);
assert.equal(moduleContext.plan(original.filter(x => x?.name !== "Día · respaldo 2026-11-20T02-00")).ok, false);

const reader = fs.readFileSync(path.join(base, "scripts/leer_biblioteca_para_quitar_dia.qml"), "utf8");
const writer = fs.readFileSync(path.join(base, "scripts/quitar_dos_entradas_dia.qml"), "utf8");
const wrapper = fs.readFileSync(path.join(base, "quitar_dos_temas_dia.sh"), "utf8");
const verifier = fs.readFileSync(path.join(base, "scripts/verificar_limpieza_dos_dia.cjs"), "utf8");
const archiver = fs.readFileSync(path.join(base, "scripts/respaldar_biblioteca_antes_de_quitar_dia.cjs"), "utf8");
const comparer = fs.readFileSync(path.join(base, "scripts/comparar_biblioteca_dia_antes.cjs"), "utf8");
const visor = fs.readFileSync(path.join(base, "preview_redimensionable.qml"), "utf8");

assert(reader.includes('category: "plasma-smartbar-v01-preview-appearance"'));
assert(writer.includes('category: "plasma-smartbar-v01-preview-appearance"'));
assert(visor.includes('category: "plasma-smartbar-v01-preview-appearance"'));
assert(!reader.includes("setValue("), "La primera lectura debe ser solo lectura");
assert(writer.includes('localPreviewSettings.setValue("themeLibraryJson", updated)'));
assert(writer.includes('localPreviewSettings.setValue("dayEntriesRemovedBackupV1", original)'));
assert(writer.includes('DayEntryCleanup.plan(items)'), "Abortar si los nombres son distintos");
assert(writer.includes('SMARTBAR_DAY_CLEANUP_DONE=2'));
assert(archiver.includes("fs.mkdtempSync(") && archiver.includes("fs.writeFileSync("),
       "Crear respaldo externo antes de borrar");
assert(comparer.includes('assert.equal(raw + "\\n", original'),
       "Comprobar que el respaldo coincide con Qt antes de escribir");
assert(wrapper.indexOf("respaldar_biblioteca_antes_de_quitar_dia.cjs") <
       wrapper.indexOf("quitar_dos_entradas_dia.qml"),
       "Respaldar antes de escribir");
assert(wrapper.indexOf("comparar_biblioteca_dia_antes.cjs") <
       wrapper.indexOf("quitar_dos_entradas_dia.qml"),
       "Verificar copia antes de escribir");
assert(wrapper.indexOf("verificar_limpieza_dos_dia.cjs") >
       wrapper.indexOf("quitar_dos_entradas_dia.qml"),
       "Verificar el resultado al terminar");
assert(wrapper.includes("pgrep -f") &&
       wrapper.includes("preview_redimensionable"),
       "Evitar limpieza con visor activo");
assert(verifier.includes("JSON.stringify(current), JSON.stringify(planned.items)"));
assert(!writer.includes("themeDayJson") && !writer.includes("themeNightJson") &&
       !writer.includes("appearanceV1"), "Preservar todos los presets");
console.log("OK: limpieza estricta de 2 entradas Día, respaldos y temas principales intactos.");
