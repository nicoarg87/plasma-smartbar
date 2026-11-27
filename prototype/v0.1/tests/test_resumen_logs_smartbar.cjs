#!/usr/bin/env node
"use strict";
// Aísla los tests en un directorio temporal: jamás tocar logs reales.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const tool = path.resolve(__dirname, "../scripts/resumir_logs_smartbar.cjs");
const temp = fs.mkdtempSync(path.join(os.tmpdir(), "smartbar-logs-test-"));
try {
    const root = path.join(temp, "plasma-smartbar", "ensayos");
    const session = path.join(root, "sesion-prueba");
    fs.mkdirSync(session, {recursive: true});
    const so = path.join(session, "soledad.log");
    const mal = path.join(session, "malvina.log");
    const soText = [
        "[2026-11-27 10:00:00] debug: secreto-privado",
        "[2026-11-27 10:00:01] warning: fallo de ejemplo",
        "[2026-11-27 10:00:02] critical: problema",
        ""
    ].join("\n");
    const malText = "[2026-11-27 10:00:03] info: inicio\n" +
                    "[2026-11-27 10:00:04] fatal: salida\n";
    fs.writeFileSync(so, soText);
    fs.writeFileSync(mal, malText);
    const marker = path.join(root, "ultima_sesion.txt");
    fs.writeFileSync(marker, session + "\n");
    const exec = () => spawnSync(process.execPath, [tool], {
        env: {...process.env, XDG_STATE_HOME: temp}, encoding: "utf8", timeout: 8000
    });
    const result = exec();
    assert.equal(result.status, 0, result.stderr);
    assert.match(result.stdout, /soledad\.log: 3 líneas; debug=1, info=0, warning=1, critical=1, fatal=0/);
    assert.match(result.stdout, /malvina\.log: 2 líneas; debug=0, info=1, warning=0, critical=0, fatal=1/);
    assert.doesNotMatch(result.stdout, /secreto-privado|fallo de ejemplo/);
    assert.equal(fs.readFileSync(so, "utf8"), soText);
    assert.equal(fs.readFileSync(mal, "utf8"), malText);
    const external = fs.mkdtempSync(path.join(os.tmpdir(), "smartbar-logs-external-"));
    try {
        fs.writeFileSync(marker, external + "\n");
        const rejected = exec();
        assert.equal(rejected.status, 1);
        assert.match(rejected.stderr, /fuera del directorio autorizado/);
    } finally {
        fs.rmSync(external, {recursive: true, force: true});
    }
    console.log("OK: resumen sin filtración de contenido; logs conservados y ruta confinada.");
} finally {
    fs.rmSync(temp, {recursive: true, force: true});
}
