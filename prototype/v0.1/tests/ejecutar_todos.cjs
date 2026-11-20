#!/usr/bin/env node
"use strict";
// Ejecuta solamente los tests Node aislados del prototipo.
// No inicia KDE ni modifica el panel o los datos del usuario.
const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const testDir = __dirname;
const tests = fs.readdirSync(testDir)
    .filter(name => /^test_[a-z0-9_]+\.cjs$/.test(name))
    .sort();
if (process.argv.includes("--list")) {
    console.log(tests.join("\n"));
    process.exit(0);
}
if (tests.length === 0) {
    console.error("No se encontraron pruebas JavaScript.");
    process.exit(1);
}
let failures = 0;
for (const file of tests) {
    console.log("\n=== " + file + " ===");
    const result = spawnSync(process.execPath, [path.join(testDir, file)], {
        cwd: path.resolve(testDir, ".."),
        stdio: "inherit",
        shell: false
    });
    if (result.error || result.status !== 0) {
        failures++;
        console.error("FALLÓ: " + file +
            (result.error ? " (" + result.error.message + ")" : ""));
    }
}
console.log("\nResultado: " + (tests.length - failures) + "/" +
            tests.length + " pruebas sin fallos.");
process.exitCode = failures ? 1 : 0;
