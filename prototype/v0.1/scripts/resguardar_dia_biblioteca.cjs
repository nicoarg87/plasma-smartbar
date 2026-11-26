#!/usr/bin/env node
"use strict";
// Resguardo privado de Día desde themeLibraryJson, sin activar ningún tema.
// No modifica Qt Settings, perfiles, packs, recursos del proyecto ni KDE.
const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const crypto = require("node:crypto");
const {fileURLToPath} = require("node:url");

if (process.argv.length !== 3) {
    console.error("Uso interno: resguardar_dia_biblioteca.cjs archivo-log-qt");
    process.exit(2);
}
function fail(message) {
    console.error("Día NO respaldado: " + message);
    process.exit(3);
}
const hash = data => crypto.createHash("sha256").update(data).digest("hex");
let candidate;
try {
    const log = fs.readFileSync(process.argv[2], "utf8");
    const prefix = "SMARTBAR_PLAYA_FACTORY_CANDIDATE=";
    const records = log.split(/\r?\n/).filter(line => line.includes(prefix));
    if (records.length !== 1) throw Error("respuesta Qt ambigua");
    const payload = JSON.parse(records[0].slice(records[0].indexOf(prefix) + prefix.length));
    if (payload.selectedPack !== "playa-24hs")
        throw Error("Playa 24hs no está seleccionado; sin modificar preferencias");
    const library = JSON.parse(payload.library);
    if (!Array.isArray(library)) throw Error("biblioteca de temas inválida");
    const matches = library.filter(item => item &&
        typeof item.name === "string" &&
        ["día", "dia"].includes(item.name.trim().toLocaleLowerCase("es")));
    if (matches.length !== 1) throw Error("Día no tiene una entrada única");
    candidate = JSON.parse(matches[0].jsonData);
    if (!candidate || typeof candidate !== "object" ||
        Array.isArray(candidate) || candidate.version !== 1)
        throw Error("perfil Día inválido");
    // Reutilizar el contrato del empaquetador, sin invocarlo ni modificar archivos.
    const source = fs.readFileSync(path.join(__dirname, "fijar_dia_fabrica.cjs"), "utf8");
    const match = /const required =\s*(\[[\s\S]*?\]);/.exec(source);
    if (!match) throw Error("contrato de campos no disponible");
    const required = JSON.parse(match[1]);
    const missing = required.filter(key => !Object.hasOwn(candidate, key));
    if (missing.length) throw Error("perfil incompleto: " + missing.length + " campos");
} catch (err) { fail(err.message); }
const assetsDir = path.resolve(__dirname, "../package/contents/ui/assets");
const validExtensions = new Set([".gif", ".png", ".jpg", ".jpeg", ".webp", ".svg", ".bmp"]);
function asset(source, label) {
    if (typeof source !== "string" || !source.trim())
        throw Error("falta imagen " + label);
    let filename = source;
    if (filename.startsWith("file:")) filename = fileURLToPath(filename);
    else if (filename.includes("://") || !path.isAbsolute(filename))
        throw Error(label + " no indica archivo local absoluto");
    const ext = path.extname(filename).toLowerCase();
    if (!validExtensions.has(ext)) throw Error("extensión no admitida para " + label);
    const stat = fs.statSync(filename);
    if (!stat.isFile() || !stat.size || stat.size > 50 * 1024 * 1024)
        throw Error("archivo " + label + " inválido");
    const bytes = fs.readFileSync(filename);
    return {label, ext, bytes, sha256:hash(bytes)};
}
let images = [];
try {
    if (candidate.logoMode === "custom") {
        images.push(asset(candidate.originalImageUrl || candidate.filePath, "logo"));
    } else if (candidate.logoMode === "default") {
        images.push(asset(path.join(assetsDir, "so-tropical.gif"), "logo"));
    } else if (candidate.logoMode !== "text") {
        throw Error("modo de logo desconocido");
    }
    if (candidate.soTextBackgroundImage)
        images.push(asset(candidate.soTextBackgroundImage, "fondo-texto-so"));
} catch (err) { fail(err.message); }

const root = path.join(process.env.XDG_DATA_HOME ||
    path.join(os.homedir(), ".local/share"),
    "plasma-smartbar", "resguardos-playa-fabrica");
let destination;
try {
    fs.mkdirSync(root, {recursive:true, mode:0o700});
    destination = fs.mkdtempSync(path.join(root, "dia-biblioteca-"));
    fs.chmodSync(destination, 0o700);
    const json = Buffer.from(JSON.stringify(candidate, null, 2) + "\n");
    fs.writeFileSync(path.join(destination, "perfil-dia-biblioteca.json"), json,
        {flag:"wx", mode:0o600});
    const entries = [{name:"perfil-dia-biblioteca.json", sha256:hash(json), bytes:json.length}];
    for (const img of images) {
        const name = img.label + img.ext;
        fs.writeFileSync(path.join(destination,name), img.bytes,
            {flag:"wx", mode:0o600});
        entries.push({name,sha256:img.sha256,bytes:img.bytes.length});
    }
    const manifest = {
        version:1, status:"candidata local; no publicada ni activada",
        source:"tema Día único en biblioteca del visor Qt",
        createdAt:new Date().toISOString(), entries
    };
    fs.writeFileSync(path.join(destination, "MANIFIESTO.json"),
        JSON.stringify(manifest,null,2)+"\n", {flag:"wx",mode:0o600});
    console.log("Día: perfil original completo recuperado de la biblioteca.");
    console.log("Resguardo privado: " + destination);
    console.log("Archivos gráficos copiados: " + images.length);
    console.log("No se modificaron temas, packs, horarios, preferencias ni panel KDE.");
    console.log("No se instaló ni publicó todavía un preset de fábrica.");
} catch (err) {
    console.error("No se completó el respaldo: " + err.message +
                  (destination ? " (directorio parcial: " + destination + ")" : ""));
    process.exitCode = 4;
}
