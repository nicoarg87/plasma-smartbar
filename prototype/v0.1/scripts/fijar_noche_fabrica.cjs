#!/usr/bin/env node
// El autor exporta desde Configuraciones > Temas el JSON de la apariencia
// ACTUAL. Este script empaqueta el perfil visual exacto y sus archivos
// gráficos; no toma los valores predeterminados del código como sustituto.
// La salida es un recurso de solo lectura para la interfaz (versionado Git).
"use strict";
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const { fileURLToPath } = require("node:url");

const sourcePath = process.argv[2];
if (!sourcePath || process.argv.length !== 3) {
    console.error("Uso: node prototype/v0.1/scripts/fijar_noche_fabrica.cjs ~/noche-actual.json");
    console.error("Copiá primero el JSON exacto desde Configuraciones > Temas.");
    process.exit(1);
}

const assetsDir = path.resolve(__dirname, "../package/contents/ui/assets");
const presetPath = path.join(assetsDir, "FactoryNightTheme.js");
const manifestPath = path.join(assetsDir, "factory-night-manifest.json");
function fail(message) {
    console.error("Noche de fábrica NO se modificó: " + message);
    process.exit(1);
}
if (!fs.existsSync(presetPath)) fail("No se encuentra el manifiesto de fábrica del proyecto");
if (!/var preset = null\b/.test(fs.readFileSync(presetPath, "utf8")))
    fail("El tema de fábrica ya fue fijado. No se puede reemplazar con este comando.");
if (fs.existsSync(manifestPath))
    fail("Ya existe un manifiesto de Noche de fábrica. No se sobrescribe.");

let preset;
try {
    preset = JSON.parse(fs.readFileSync(path.resolve(sourcePath), "utf8"));
} catch (error) { fail("No se pudo leer JSON: " + error.message); }
if (!preset || typeof preset !== "object" || Array.isArray(preset))
    fail("El JSON debe contener un objeto con los controles visuales");
if (preset.version !== 1)
    fail("La exportación no coincide con la versión vigente (version: 1).");

const required = [
    "effectStyle", "allowMotion", "showOutlineWhenEmpty", "showOutlineWhenOpen",
    "pulseSpeed", "pulseDepth", "logoMode", "shape", "cropFitMode", "cropZoom",
    "cropPanX", "cropPanY", "cropRotation", "enableGif",
    "soledadColor", "soledadOpacity", "soledadGradientEnabled",
    "soledadGradientEnd", "soledadGradientThird", "soledadGradientColorCount",
    "soledadGradientDirection", "soledadGradientSyncBreathing",
    "soledadGradientSyncIntensity", "soledadGradientBreathingEnabled",
    "soledadGradientBreathingSpeed", "soledadGradientBreathingIntensity",
    "malvinaColor", "malvinaOpacity", "malvinaGradientEnabled",
    "malvinaGradientEnd", "malvinaGradientThird", "malvinaGradientColorCount",
    "malvinaGradientDirection", "malvinaGradientSyncBreathing",
    "malvinaGradientBreathingEnabled", "malvinaGradientBreathingSpeed",
    "malvinaGradientBreathingIntensity", "accentColor", "glowColor",
    "glowIntensity", "glowSpread", "showBackground", "backgroundColor",
    "backgroundOpacity", "soButtonFrameShape", "soButtonWidth",
    "panelHeight", "soledadHeight", "malvinaHeight",
    "soledadShape", "malvinaShape", "soTextLabel", "soTextColor",
    "soTextBackground", "clockFontFamily", "clockFontSize",
    "clockTextColor", "taskDisplayMode", "taskFrameShape", "taskFrameColor",
    "outlineConfig", "launcherOpacityOverride", "launcherOpacity"
];
const missing = required.filter(key => !Object.prototype.hasOwnProperty.call(preset, key));
if (missing.length) fail("La captura está incompleta: " + missing.join(", "));
if (!["default", "custom", "text"].includes(preset.logoMode))
    fail("Modo de logo desconocido");
if (!preset.outlineConfig || typeof preset.outlineConfig !== "object")
    fail("Contornos inválidos");

const allowedExtensions = new Set([".gif", ".png", ".jpg", ".jpeg", ".webp", ".svg", ".bmp"]);
function localFile(spec, label) {
    if (typeof spec !== "string" || !spec.length) fail("Falta " + label);
    let filename = spec;
    if (filename.startsWith("file://")) {
        try { filename = fileURLToPath(filename); }
        catch(e) { fail("URL inválida en " + label + ": " + e.message); }
    } else if (filename.includes("://")) {
        fail(label + " debe ser un archivo local, no una URL remota");
    }
    filename = path.resolve(filename);
    if (!fs.existsSync(filename) || !fs.statSync(filename).isFile())
        fail("No existe " + label + ": " + filename);
    const ext = path.extname(filename).toLowerCase();
    if (!allowedExtensions.has(ext)) fail("Formato no compatible en " + label);
    if (fs.statSync(filename).size === 0) fail("Archivo vacío: " + label);
    return { source: filename, ext };
}

const assets = [];
// Para una imagen por defecto también exigimos la FUENTE REAL que mostró
// la barra; no se sustituye por la imagen de Atardecer u otro tema.
if (preset.logoMode !== "text") {
    const original = localFile(preset.originalImageUrl || preset.filePath,
                               "imagen/GIF actual del botón SO");
    assets.push({kind:"logo", source:original.source, ext:original.ext});
    preset.assetFile = "factory-night-logo" + original.ext;
    preset.logoMode = "custom";
    preset.filePath = ""; // nunca publicar ruta del equipo del autor
} else {
    preset.filePath = "";
    delete preset.assetFile;
}
if (preset.soTextBackgroundImage) {
    const bg = localFile(preset.soTextBackgroundImage, "imagen de fondo del texto SO");
    assets.push({kind:"text", source:bg.source, ext:bg.ext});
    preset.assetTextFile = "factory-night-text" + bg.ext;
    preset.soTextBackgroundImage = "";
} else {
    delete preset.assetTextFile;
}
delete preset.originalImageUrl;

for (const item of assets) {
    const name = item.kind === "logo" ? preset.assetFile : preset.assetTextFile;
    if (fs.existsSync(path.join(assetsDir, name)))
        fail("El recurso ya existe y no se sobrescribirá: " + name);
}
const digest = buf => crypto.createHash("sha256").update(buf).digest("hex");
const resourceManifest = assets.map(item => {
    const buf = fs.readFileSync(item.source);
    return {
        role: item.kind,
        file: item.kind === "logo" ? preset.assetFile : preset.assetTextFile,
        sha256: digest(buf), bytes: buf.length
    };
});
const serialized = JSON.stringify(preset, null, 2);
const moduleText =
    ".pragma library\n\n" +
    "// Tema Noche de fábrica: recurso versionado. NO alterar desde la interfaz.\n" +
    "// Para publicar otra versión se requiere una decisión explícita del mantenedor.\n" +
    "var preset = " + serialized + "\n";
const manifestText = JSON.stringify({
    version: 1,
    theme: "Noche de fábrica",
    presetSha256: digest(Buffer.from(serialized, "utf8")),
    assets: resourceManifest,
    rights: "Verificar procedencia y permiso de cada imagen antes de publicar"
}, null, 2) + "\n";

try {
    for (const item of assets) {
        const filename = item.kind === "logo" ? preset.assetFile : preset.assetTextFile;
        fs.copyFileSync(item.source, path.join(assetsDir, filename), fs.constants.COPYFILE_EXCL);
    }
    fs.writeFileSync(manifestPath, manifestText, {flag:"wx"});
    // Escribir el preset al final: nunca dejar el original activo con imágenes
    // que no se hayan copiado correctamente.
    fs.writeFileSync(presetPath, moduleText, "utf8");
} catch(error) {
    fail("Error al empaquetar archivos: " + error.message);
}
console.log("Noche de fábrica preparada con el perfil exacto.");
for (const item of resourceManifest)
    console.log(item.file + "  SHA-256 " + item.sha256);
console.log("Revisá los cambios y publicalos mediante Git tras probarlos en CachyOS.");
