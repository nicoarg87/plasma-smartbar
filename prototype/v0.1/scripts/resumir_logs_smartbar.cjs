#!/usr/bin/env node
"use strict";
// Resumen de logs ya conservados por probar_islas_juntas.sh.
// SOLO LECTURA: no borra, trunca, rota, mueve ni altera ningún archivo.
const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const readline = require("node:readline");

const stateRoot = process.env.XDG_STATE_HOME || path.join(os.homedir(), ".local", "state");
const logRoot = path.join(stateRoot, "plasma-smartbar", "ensayos");
const marker = path.join(logRoot, "ultima_sesion.txt");
const names = ["compilacion.log", "soledad.log", "malvina.log", "catalogo.log"];
const levels = ["debug", "info", "warning", "critical", "fatal"];

async function summary(file) {
    const result = {lines: 0};
    for (const level of levels) result[level] = 0;
    const stream = fs.createReadStream(file, {encoding: "utf8"});
    const lines = readline.createInterface({input: stream, crlfDelay: Infinity});
    for await (const line of lines) {
        result.lines++;
        const match = line.match(/(?:\]\s*|^)(debug|info|warning|critical|fatal):/i);
        if (match) result[match[1].toLowerCase()]++;
    }
    return result;
}

async function main() {
    if (process.argv.length !== 2) {
        console.error("Uso: node prototype/v0.1/scripts/resumir_logs_smartbar.cjs");
        process.exitCode = 2;
        return;
    }
    if (!fs.existsSync(marker)) {
        console.error("Todavía no se encontró un registro de sesión de islas conjuntas.");
        process.exitCode = 1;
        return;
    }
    const rootReal = fs.realpathSync(logRoot);
    const sessionText = fs.readFileSync(marker, "utf8").trim();
    if (!sessionText || !fs.existsSync(sessionText)) {
        console.error("El registro de la última sesión no apunta a una carpeta existente.");
        process.exitCode = 1;
        return;
    }
    const sessionReal = fs.realpathSync(sessionText);
    if (!sessionReal.startsWith(rootReal + path.sep) ||
            !fs.statSync(sessionReal).isDirectory()) {
        console.error("Ruta de sesión fuera del directorio autorizado; lectura cancelada.");
        process.exitCode = 1;
        return;
    }
    console.log("Plasma SmartBar · resumen estadístico de la última sesión");
    console.log("Sesión: " + sessionReal);
    for (const name of names) {
        const target = path.join(sessionReal, name);
        if (!fs.existsSync(target) || !fs.lstatSync(target).isFile()) continue;
        const stats = await summary(target);
        console.log(name + ": " + stats.lines + " líneas; " +
            levels.map(level => level + "=" + stats[level]).join(", "));
    }
    console.log("Registros conservados íntegros. No se borró ni reescribió ningún archivo.");
}
main().catch(error => {
    // Nunca imprimir contenido de logs o preferencias personales.
    console.error("No se pudo leer el resumen: " + error.code);
    process.exitCode = 1;
});
