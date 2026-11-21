#!/usr/bin/env node
"use strict";
// Confirmar por lectura de Qt que se eliminaron SOLO los dos registros.
// Comparar el resto con el respaldo externo exacto; nunca escribir Settings.
const fs = require("node:fs");
const assert = require("node:assert/strict");
const path = require("node:path");
const vm = require("node:vm");

const backup = process.argv[2], log = process.argv[3];
if (!backup || !log) { console.error("Faltan respaldo y lectura Qt."); process.exit(2); }
const marker = "SMARTBAR_DAY_CLEANUP_LIBRARY=";
const lines = fs.readFileSync(log, "utf8").split(/\r?\n/);
const matches = lines.filter(line => line.includes(marker));
if (matches.length !== 1) {console.error("Lectura de verificación no válida.");process.exit(3);}
try {
    const original = JSON.parse(fs.readFileSync(backup, "utf8"));
    const current = JSON.parse(JSON.parse(
        matches[0].slice(matches[0].indexOf(marker) + marker.length)));
    const js = fs.readFileSync(path.join(__dirname, "../package/contents/ui/DayEntryCleanup.js"), "utf8");
    const cleanup = {};
    vm.runInNewContext(js.replace(/^\s*\.pragma library\s*/, ""), cleanup);
    const planned = cleanup.plan(original);
    assert(planned.ok, "El respaldo no contiene las dos entradas originales.");
    assert.equal(JSON.stringify(current), JSON.stringify(planned.items),
                 "La biblioteca final difiere de la original en algo más que los dos temas.");
    console.log("Verificado: solo desaparecieron las dos entradas de Día solicitadas.");
    console.log("El resto de los temas permanece íntegro.");
} catch (error) {
    console.error("ERROR: no se pudo verificar la limpieza:", error.message);
    process.exit(4);
}
