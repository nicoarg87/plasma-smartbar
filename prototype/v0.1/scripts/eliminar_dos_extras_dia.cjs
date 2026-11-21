#!/usr/bin/env node
"use strict";
// Limpieza LOCAL y explícita de dos registros históricos del selector de temas.
// No borra temas de fábrica, otros temas, imágenes, KConfig ni paneles KDE.
// Exige coincidencia exacta de los dos nombres y guarda copia antes de escribir.
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const crypto = require("node:crypto");
const {spawnSync} = require("node:child_process");

const EXTRA_NAMES = Object.freeze([
    "Día · versión anterior",
    "Día · respaldo 2026-11-20T02-00"
]);

function cleanLibrary(raw) {
    if (typeof raw !== "string") throw new Error("La biblioteca no es texto.");
    const items = JSON.parse(raw);
    if (!Array.isArray(items)) throw new Error("La biblioteca de temas no es una lista.");
    const counts = EXTRA_NAMES.map(() => 0);
    const cleaned = items.filter(item => {
        const name = item && typeof item.name === "string"
            ? item.name.normalize("NFC") : "";
        const index = EXTRA_NAMES.indexOf(name);
        if (index < 0) return true;
        counts[index]++;
        return false;
    });
    if (counts.every(count => count === 0))
        return {status: "already-clean", items, removed: [], result: raw};
    if (counts.some(count => count !== 1))
        throw new Error("Los dos nombres no aparecen exactamente una vez cada uno; " +
                        "no se cambiará nada. Coincidencias: " +
                        EXTRA_NAMES.map((name, index) => name + "=" + counts[index]).join(", "));
    return {status: "ready", items, removed: EXTRA_NAMES.slice(),
            result: JSON.stringify(cleaned)};
}

function executable(command) {
    if (command.includes("/")) {
        try { fs.accessSync(command, fs.constants.X_OK); return command; }
        catch { return null; }
    }
    const directories = (process.env.PATH || "").split(path.delimiter);
    for (const dir of directories) {
        const candidate = path.join(dir, command);
        try { fs.accessSync(candidate, fs.constants.X_OK); return candidate; }
        catch { /* probar otro directorio */ }
    }
    return null;
}

function qmlRunner() {
    for (const candidate of ["qml6", "/usr/lib/qt6/bin/qml", "qmlscene6"]) {
        const program = executable(candidate);
        if (program) return program;
    }
    throw new Error("No se encontró qml6/qmlscene6. No se modificó nada.");
}

function runQml(runner, file) {
    const result = spawnSync(runner, [file], {
        encoding: "utf8", timeout: 30000, maxBuffer: 32 * 1024 * 1024,
        env: process.env
    });
    if (result.error || result.status !== 0)
        throw new Error("Qt no completó la operación: " +
                        (result.error ? result.error.message :
                         (result.stderr || result.stdout || "error desconocido").slice(-1600)));
    return (result.stdout || "") + "\n" + (result.stderr || "");
}

function readStoredLibrary(runner, script) {
    const log = runQml(runner, script);
    const marker = "SMARTBAR_PRESETS_EXPORT=";
    const match = log.split(/\r?\n/).find(line => line.includes(marker));
    if (!match) throw new Error("Qt no confirmó la lectura. No se modificó nada.");
    const data = JSON.parse(match.slice(match.indexOf(marker) + marker.length));
    if (typeof data.themeLibraryJson !== "string")
        throw new Error("Qt no devolvió la biblioteca original como texto.");
    return data.themeLibraryJson;
}

function qmlLiteral(value) {
    return JSON.stringify(value).replace(/\u2028/g, "\\u2028")
                               .replace(/\u2029/g, "\\u2029");
}

function writeQml(expected, replacement) {
    // Comprobar el valor exacto anterior: nunca pisar una edición simultánea.
    return [
        "import QtQuick",
        "import QtCore as QtCore",
        "Item {",
        "  width: 1; height: 1",
        '  QtCore.Settings { id: saved; category: "plasma-smartbar-v01-preview-appearance" }',
        "  Component.onCompleted: {",
        "    try {",
        '      const current = String(saved.value("themeLibraryJson", "[]"))',
        "      if (current !== " + qmlLiteral(expected) + ") {",
        '        console.warn("SMARTBAR_THEME_CLEANUP_CONFLICT")',
        "        Qt.quit(); return",
        "      }",
        "      const next = " + qmlLiteral(replacement),
        '      saved.setValue("themeLibraryJson", next)',
        "      saved.sync()",
        '      if (String(saved.value("themeLibraryJson", "")) === next)',
        '        console.log("SMARTBAR_THEME_CLEANUP_WRITTEN")',
        '      else console.warn("SMARTBAR_THEME_CLEANUP_VERIFY_FAILED")',
        "    } catch (e) { console.warn('SMARTBAR_THEME_CLEANUP_ERROR=' + e) }",
        "    Qt.quit()",
        "  }",
        "}",
        ""
    ].join("\n");
}

function makeBackup(original) {
    const root = path.join(process.env.XDG_DATA_HOME ||
                           path.join(os.homedir(), ".local", "share"),
                           "plasma-smartbar", "resguardos-temas");
    fs.mkdirSync(root, {recursive: true, mode: 0o700});
    const dir = fs.mkdtempSync(path.join(root, "antes-de-limpiar-dia-"));
    fs.chmodSync(dir, 0o700);
    fs.writeFileSync(path.join(dir, "biblioteca-original.json"), original,
                     {flag: "wx", mode: 0o600});
    const hash = crypto.createHash("sha256").update(original).digest("hex");
    fs.writeFileSync(path.join(dir, "MANIFIESTO.json"),
                     JSON.stringify({source: "Qt Settings locales del visor",
                                     beforeSha256: hash, targetedNames: EXTRA_NAMES,
                                     restoredBy: "reponer themeLibraryJson desde biblioteca-original.json"},
                                    null, 2) + "\n",
                     {flag: "wx", mode: 0o600});
    return dir;
}

function main() {
    if (process.argv.includes("--help")) {
        console.log("Cerrá el visor Qt y ejecutá: node prototype/v0.1/scripts/eliminar_dos_extras_dia.cjs");
        return;
    }
    const reader = path.resolve(__dirname, "leer_temas_locales.qml");
    const runner = qmlRunner();
    const original = readStoredLibrary(runner, reader);
    const plan = cleanLibrary(original);
    if (plan.status === "already-clean") {
        console.log("Las dos entradas ya no están en la biblioteca. No se modificó nada.");
        return;
    }
    const backup = makeBackup(original);
    console.log("Respaldo completo de la biblioteca creado en: " + backup);
    const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "smartbar-temas-"));
    fs.chmodSync(scratch, 0o700);
    const writer = path.join(scratch, "aplicar.qml");
    try {
        fs.writeFileSync(writer, writeQml(original, plan.result),
                         {mode: 0o600, flag: "wx"});
        const log = runQml(runner, writer);
        if (!log.includes("SMARTBAR_THEME_CLEANUP_WRITTEN"))
            throw new Error("Qt rechazó la escritura o cambió la biblioteca al mismo tiempo. " +
                            log.slice(-1200));
        const confirmed = readStoredLibrary(runner, reader);
        if (confirmed !== plan.result)
            throw new Error("La verificación posterior difiere de la biblioteca esperada.");
        console.log("Eliminadas de la biblioteca local:");
        for (const name of plan.removed) console.log("  - " + name);
        console.log("Conservadas todas las demás entradas, incluido el Día principal.");
        console.log("No se modificaron temas de fábrica, GIF, wallpaper ni panel KDE.");
    } catch (error) {
        console.error("AVISO: No se confirmó la limpieza. Respaldo disponible en: " + backup);
        throw error;
    } finally {
        fs.rmSync(scratch, {recursive: true, force: true});
    }
}

module.exports = {EXTRA_NAMES, cleanLibrary, qmlLiteral, writeQml};
if (require.main === module) {
    try { main(); } catch (error) {
        console.error("ERROR: " + error.message);
        process.exitCode = 1;
    }
}
