#!/usr/bin/env node
"use strict";
// Auditoría sin escrituras: no registra rutas personales completas, no copia
// perfiles, no decide cuál debe ser el tema oficial ni empaqueta imágenes.
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const {fileURLToPath} = require("node:url");
const logPath = process.argv[2];
if (!logPath || process.argv.length !== 3) {
    console.error("Uso interno: inspeccionar_perfiles_playa.cjs registro-qt");
    process.exit(2);
}
const log = fs.readFileSync(logPath, "utf8");
function readMarker(prefix) {
    const matches = log.split(/\r?\n/).filter(row => row.includes(prefix));
    if (matches.length !== 1)
        throw Error("Respuesta QML no inequívoca para " + prefix);
    return JSON.parse(matches[0].slice(matches[0].indexOf(prefix) + prefix.length));
}
let themes, context, legacy;
try {
    const raw = readMarker("SMARTBAR_PLAYA_AUDIT_LIBRARY=");
    context = readMarker("SMARTBAR_PLAYA_AUDIT_CONTEXT=");
    legacy = readMarker("SMARTBAR_PLAYA_AUDIT_LEGACY=");
    if (!legacy || typeof legacy.sunset !== "string" ||
        typeof legacy.night !== "string") throw Error("Ranuras históricas inválidas");
    if (typeof raw !== "string") throw Error("Biblioteca inválida");
    themes = JSON.parse(raw);
    if (!Array.isArray(themes)) throw Error("La biblioteca no es una lista");
} catch (error) {
    console.error("No se pudo analizar la biblioteca sin riesgos: " + error.message);
    process.exit(3);
}
const base = path.resolve(__dirname, "../package/contents/ui/assets");
const factoryScripts = {
    "Día": "fijar_dia_fabrica.cjs",
    "Atardecer": "fijar_atardecer_fabrica.cjs",
    "Noche": "fijar_noche_fabrica.cjs"
};
const sha = buffer => crypto.createHash("sha256").update(buffer).digest("hex");
function imageInfo(source) {
    if (typeof source !== "string" || !source.trim()) return "sin ruta de imagen";
    let resolved = source;
    if (resolved.startsWith("file:")) {
        try { resolved = fileURLToPath(resolved); }
        catch (_) { return "referencia file: inválida"; }
    } else if (resolved.includes("://") || !path.isAbsolute(resolved)) {
        return "referencia no local/absoluta: revisar manualmente";
    }
    try {
        const stat = fs.statSync(resolved);
        if (!stat.isFile() || stat.size === 0) return "archivo vacío o no regular";
        return "archivo disponible (" + stat.size + " bytes; SHA-256 " +
            sha(fs.readFileSync(resolved)).slice(0,16) + "…)";
    } catch (_) { return "ARCHIVO NO ENCONTRADO"; }
}
function requiredKeys(script) {
    const src = fs.readFileSync(path.join(__dirname, script), "utf8");
    const match = /const required =\s*(\[[\s\S]*?\]);/.exec(src);
    if (!match) throw Error("No se pudo leer el contrato del empaquetador " + script);
    return JSON.parse(match[1]);
}
console.log("Plasma SmartBar — inspección local de Playa 24hs (SOLO LECTURA)");
console.log("Biblioteca: " + themes.length + " entradas. Pack seleccionado: " +
    (context && typeof context.selectedPackId === "string" ?
        context.selectedPackId : "desconocido"));
let candidates = 0, ready = 0;
for (const [label, script] of Object.entries(factoryScripts)) {
    const aliases = label === "Día" ? ["día", "dia"] : [label.toLocaleLowerCase("es")];
    const matching = themes.filter(item => item &&
        typeof item.name === "string" &&
        aliases.includes(item.name.trim().toLocaleLowerCase("es")));
    console.log("\n" + label + ": " + matching.length + " coincidencia(s) exacta(s) de nombre.");
    if (matching.length !== 1) {
        console.log(matching.length ? "  AMBIGUO: no se elige perfil automáticamente." :
            "  PENDIENTE: sin tema con ese nombre exacto; no usar «Día prueba» ni otros sustitutos.");
        continue;
    }
    ++candidates;
    let values;
    try {
        values = JSON.parse(matching[0].jsonData);
        if (!values || typeof values !== "object" || Array.isArray(values)) throw Error();
    } catch (_) {
        console.log("  Perfil JSON inválido: no se selecciona como fábrica.");
        continue;
    }
    const missing = requiredKeys(script).filter(k =>
        !Object.prototype.hasOwnProperty.call(values,k));
    console.log("  Versión: " + String(values.version ?? "ausente") +
        "; datos visuales requeridos faltantes: " + missing.length);
    if (missing.length) console.log("  Faltan campos: " + missing.slice(0,8).join(", ") +
        (missing.length>8 ? "…" : ""));
    const mode = values.logoMode;
    const imageSource = mode === "default" ?
        path.join(base, "so-tropical.gif") :
        mode === "custom" ? values.filePath : "";
    const imageStatus = mode === "text" ? "logo de texto (sin binario)" : imageInfo(imageSource);
    console.log("  Logo: " + String(mode ?? "sin modo") + "; " + imageStatus);
    if (values.soTextBackgroundImage)
        console.log("  Fondo de texto SO: " + imageInfo(values.soTextBackgroundImage));
    console.log("  Huella JSON (SHA-256): " + sha(Buffer.from(matching[0].jsonData,"utf8")).slice(0,16) + "…");
    if (values.version === 1 && !missing.length &&
        ["default","custom","text"].includes(mode) &&
        (mode === "text" || imageStatus.startsWith("archivo disponible")) &&
        (!values.soTextBackgroundImage ||
         imageInfo(values.soTextBackgroundImage).startsWith("archivo disponible")))
        ++ready;
}
console.log("\nPerfiles únicos hallados: " + candidates + "/3. Técnicamente revisables: " + ready + "/3.");
console.log("Ranuras históricas (NO equivalen a fábrica): Atardecer=" +
    (context && context.historicalSunset ? "presente" : "ausente") +
    ", Noche=" + (context && context.historicalNight ? "presente" : "ausente"));
// Las ranuras históricas pueden contener algo visualmente parecido a la
// fábrica, pero NUNCA autorizan automáticamente sustituir los originales.
// Se inspeccionan individualmente, sin consultar ni alterar su forma activa.
for (const [label, raw, script] of [
    ["Atardecer histórico (themeDayJson)", legacy.sunset, factoryScripts["Atardecer"]],
    ["Noche histórica (themeNightJson)", legacy.night, factoryScripts["Noche"]]
]) {
    console.log("\\n" + label + ":");
    if (!raw.length) {
        console.log("  SIN DATOS guardados.");
        continue;
    }
    let values;
    try {
        values = JSON.parse(raw);
        if (!values || typeof values !== "object" || Array.isArray(values))
            throw Error("No es objeto JSON");
    } catch (_) {
        console.log("  JSON antiguo inválido; no se modifica.");
        continue;
    }
    const missing = requiredKeys(script).filter(k =>
        !Object.prototype.hasOwnProperty.call(values, k));
    console.log("  Versión: " + String(values.version ?? "ausente") +
        "; campos visuales requeridos faltantes: " + missing.length);
    if (missing.length)
        console.log("  Faltan: " + missing.slice(0,8).join(", ") +
            (missing.length > 8 ? "…" : ""));
    const mode = values.logoMode;
    const source = mode === "default" ?
        path.join(base, "so-tropical.gif") :
        mode === "custom" ? values.filePath : "";
    const imageStatus = mode === "text" ? "logo de texto (sin binario)" :
        imageInfo(source);
    console.log("  Logo: " + String(mode ?? "sin modo") + "; " + imageStatus);
    if (values.soTextBackgroundImage)
        console.log("  Fondo de texto SO: " + imageInfo(values.soTextBackgroundImage));
    console.log("  Huella JSON (SHA-256): " +
        sha(Buffer.from(raw, "utf8")).slice(0,16) + "…");
    const technicallyComplete = values.version === 1 && !missing.length &&
        ["default", "custom", "text"].includes(mode) &&
        (mode === "text" || imageStatus.startsWith("archivo disponible")) &&
        (!values.soTextBackgroundImage ||
         imageInfo(values.soTextBackgroundImage).startsWith("archivo disponible"));
    console.log(technicallyComplete ?
        "  COMPLETO técnicamente; identidad de fábrica NO verificada." :
        "  INCOMPLETO técnicamente; conservar para recuperación manual.");
}
console.log("\\nNo se copió ni modificó ninguna configuración, GIF, tema ni panel KDE.");
console.log("No se verificaron derechos de imagen ni wallpapers; NO se empaquetó fábrica.");
