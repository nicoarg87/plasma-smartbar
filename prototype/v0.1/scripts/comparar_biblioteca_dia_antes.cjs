#!/usr/bin/env node
"use strict";
// Protección contra cambios concurrentes entre respaldo y escritura.
// Esta herramienta NO escribe ni modifica Qt Settings.
const fs = require("node:fs");
const assert = require("node:assert/strict");
const backup = process.argv[2], log = process.argv[3];
if (!backup || !log) process.exit(2);
const marker = "SMARTBAR_DAY_CLEANUP_LIBRARY=";
const lines = fs.readFileSync(log, "utf8").split(/\r?\n/);
const hits = lines.filter(line => line.includes(marker));
try {
    assert.equal(hits.length, 1, "Lectura Qt ambigua");
    const raw = JSON.parse(hits[0].slice(hits[0].indexOf(marker) + marker.length));
    const original = fs.readFileSync(backup, "utf8");
    assert.equal(typeof raw, "string");
    assert.equal(raw + "\n", original, "La biblioteca cambió durante la lectura");
    console.log("Biblioteca original sin cambios antes de escribir.");
} catch (error) {
    console.error("No se puede continuar:", error.message);
    process.exit(3);
}
