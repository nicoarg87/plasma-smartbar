#!/usr/bin/env node
"use strict";
// Sella una única vez los tres temas inmutables, usando exclusivamente las
// instantáneas YA guardadas por el mantenedor en el visor Qt. No hay paletas
// inventadas, escritura sobre QSettings ni modificación del panel KDE.
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const { fileURLToPath } = require("node:url");
const { spawnSync } = require("node:child_process");

const root = path.resolve(__dirname, "..");
const assetsDir = path.join(root, "package/contents/ui/assets");
const helper = path.join(__dirname, "leer_temas_locales.qml");
const specs = [
    {name:"Día", slug:"day", file:"FactoryDayTheme.js"},
    {name:"Atardecer", slug:"sunset", file:"FactorySunsetTheme.js"},
    {name:"Noche", slug:"night", file:"FactoryNightTheme.js"}
];
const SHA = data => crypto.createHash("sha256").update(data).digest("hex");
function die(message) {
    console.error("No se modificó ningún tema oficial: " + message);
    process.exit(1);
}
function findRunner() {
    const candidates = [process.env.QML_RUNNER, "qml6", "/usr/lib/qt6/bin/qml", "qmlscene6"]
        .filter(Boolean);
    for (const candidate of candidates) {
        if (path.isAbsolute(candidate)) {
            if (fs.existsSync(candidate)) return candidate;
        } else {
            const which = spawnSync("which", [candidate], {encoding:"utf8"});
            if (which.status === 0) return which.stdout.trim();
        }
    }
    die("No está disponible qml6. Ejecutá el visor normal primero y verificá qt6-declarative.");
}
function localFile(spec, label) {
    if (typeof spec !== "string" || !spec.trim()) die("No hay ruta del GIF original de " + label);
    let candidate = spec;
    if (candidate.startsWith("file://")) {
        try { candidate = fileURLToPath(candidate); }
        catch(e) { die("Ruta inválida de " + label + ": " + e.message); }
    } else if (candidate.includes("://")) die("La imagen de " + label + " no es un archivo local.");
    const file = path.resolve(candidate);
    if (!fs.existsSync(file) || !fs.statSync(file).isFile())
        die("No existe la imagen exacta de " + label + ": " + file);
    const ext = path.extname(file).toLowerCase();
    if (![".gif",".png",".jpg",".jpeg",".webp",".svg",".bmp"].includes(ext))
        die("Formato no admitido en " + label + ": " + ext);
    const bytes = fs.readFileSync(file);
    if (bytes.length === 0) die("Imagen vacía de " + label);
    return {file, ext, bytes};
}
function snapshot(json, label) {
    if (typeof json !== "string" || !json.length) die(label + " no tiene instantánea guardada.");
    let value;
    try { value = JSON.parse(json); }
    catch(e) { die("JSON de " + label + " corrupto: " + e.message); }
    if (!value || Array.isArray(value) || value.version !== 1)
        die("Versión incompatible de " + label);
    // La maqueta guarda todas estas claves visuales en themeSnapshot().
    // No sellar temas antiguos cuya instantánea omita valores visuales actuales.
    const required = [
        "version", "effectStyle", "allowMotion", "strokeSize", "orbitSpeed",
        "trailPercent", "trailStyle", "showOutlineWhenEmpty", "showOutlineWhenOpen", "pulseSpeed",
        "pulseDepth", "logoMode", "filePath", "shape", "cropFitMode",
        "cropZoom", "cropPanX", "cropPanY", "cropRotation", "enableGif",
        "soledadColor", "soledadOpacity", "soledadGradientEnabled", "soledadGradientEnd", "soledadGradientThird",
        "soledadGradientColorCount", "soledadGradientDirection", "soledadGradientSyncBreathing", "soledadGradientSyncIntensity", "soledadGradientBreathingEnabled",
        "soledadGradientBreathingSpeed", "soledadGradientBreathingIntensity", "malvinaColor", "malvinaOpacity", "malvinaGradientEnabled",
        "malvinaGradientEnd", "malvinaGradientThird", "malvinaGradientColorCount", "malvinaGradientDirection", "malvinaGradientSyncBreathing",
        "malvinaGradientBreathingEnabled", "malvinaGradientBreathingSpeed", "malvinaGradientBreathingIntensity", "accentColor", "glowColor",
        "glowGradient", "glowIntensity", "glowSpread", "showBackground", "backgroundColor",
        "backgroundOpacity", "trayButtonColorOverride", "trayButtonColor", "trayButtonOpacity", "gripButtonColorOverride",
        "gripButtonColor", "gripButtonOpacity", "soledadShape", "malvinaShape", "malvinaGearButtonShape",
        "malvinaSearchButtonShape", "soButtonFrameShape", "soButtonWidth", "panelHeight", "soledadHeight",
        "malvinaHeight", "soledadRadius", "malvinaRadius", "soledadMinWidth", "malvinaWidth",
        "gripShape", "trayButtonShape", "soTextLabel", "soTextColor", "soTextBackground",
        "soTextBackgroundOpacity", "soTextFontFamily", "soTextFontSize", "soTextBold", "soTextBackgroundImage",
        "clockFontFamily", "clockFontSize", "clockTextColor", "taskDisplayMode", "taskFrameShape",
        "taskFrameColor", "taskFrameOpacity", "taskFrameWidth", "taskActiveGlowEnabled", "taskActiveDoubleBorderEnabled",
        "launcherSwitchShape", "launcherSwitchColorOverride", "launcherSwitchColor", "launcherIconsWithNames", "outlineConfig",
        "launcherOpacityOverride", "launcherOpacity", "malvinaOptionsOpacityOverride", "malvinaOptionsOpacity"
    ];
    const missing = required.filter(key=>!Object.hasOwn(value,key));
    if (missing.length) die(label + " tiene un perfil incompleto: " + missing.join(", "));
    if (!["default","custom","text"].includes(value.logoMode))
        die("Modo de botón SO desconocido en " + label);
    return structuredClone(value);
}
function gather() {
    const runner = findRunner();
    const output = spawnSync(runner, [helper], {
        encoding: "utf8", timeout: 15000, maxBuffer: 8*1024*1024,
        env: {...process.env, QML_XHR_ALLOW_FILE_READ:"1"}
    });
    const logs = (output.stdout || "") + "\n" + (output.stderr || "");
    const line = logs.split(/\r?\n/).find(line => line.includes("SMARTBAR_PRESETS_EXPORT="));
    if (output.error) die("Error al leer QSettings: " + output.error.message);
    if (!line) die("No se pudieron leer las instantáneas de Qt. Salida: " + logs.slice(-1000));
    let data;
    try { data = JSON.parse(line.slice(line.indexOf("SMARTBAR_PRESETS_EXPORT=") + 24)); }
    catch(e) { die("No se pudo interpretar la salida del visor: " + e.message); }
    let library;
    try { library = JSON.parse(data.themeLibraryJson || "[]"); }
    catch(e) { die("Biblioteca personal inválida; se conserva sin cambios."); }
    if (!Array.isArray(library)) die("Biblioteca personal inválida.");
    const savedDay = library.find(item => item && /^(día|dia)$/i.test(String(item.name || "").trim()));
    if (!savedDay) die("El tema Día debe estar guardado en la biblioteca local con ese nombre.");
    return [
        snapshot(savedDay.jsonData, "Día"),
        snapshot(data.themeDayJson, "Atardecer"),
        snapshot(data.themeNightJson, "Noche")
    ];
}
function prepare(values) {
    const outputs=[];
    for (let i=0; i<specs.length; ++i) {
        const spec=specs[i], preset=values[i];
        const modulePath=path.join(assetsDir,spec.file);
        const manifestPath=path.join(assetsDir,"factory-"+spec.slug+"-manifest.json");
        if (!fs.existsSync(modulePath) ||
            !/\bvar preset = null\b/.test(fs.readFileSync(modulePath,"utf8")))
            die(spec.name + " ya fue sellado o falta su plantilla. No se sobrescribe.");
        if (fs.existsSync(manifestPath))
            die("El manifiesto de "+spec.name+" ya existe. No se sobrescribe.");
        const resources=[];
        if (preset.logoMode !== "text") {
            // Por defecto se usa exactamente el GIF instalado por el propio proyecto.
            const source = preset.logoMode === "default"
                ? path.join(assetsDir,"so-tropical.gif") : preset.filePath;
            const origin=localFile(source,spec.name);
            preset.assetFile="factory-"+spec.slug+"-logo"+origin.ext;
            resources.push({role:"logo",from:origin.file,to:path.join(assetsDir,preset.assetFile),bytes:origin.bytes});
            preset.logoMode="custom";
        }
        preset.filePath="";
        if (preset.soTextBackgroundImage) {
            const origin=localFile(preset.soTextBackgroundImage,spec.name+" (fondo de texto)");
            preset.assetTextFile="factory-"+spec.slug+"-text"+origin.ext;
            resources.push({role:"text",from:origin.file,to:path.join(assetsDir,preset.assetTextFile),bytes:origin.bytes});
            preset.soTextBackgroundImage="";
        }
        if (preset.originalImageUrl) delete preset.originalImageUrl;
        for (const item of resources)
            if (fs.existsSync(item.to)) die("Ya existe " + item.to);
        const serialized=JSON.stringify(preset,null,2);
        const js=".pragma library\n\n// "+spec.name+
            " oficial: identidad visual inmutable del mantenedor.\nvar preset = "+serialized+"\n";
        const manifest=JSON.stringify({
            version:1, theme:spec.name, presetSha256:SHA(Buffer.from(serialized)),
            assets:resources.map(item=>({
                role:item.role,file:path.basename(item.to),
                sha256:SHA(item.bytes),bytes:item.bytes.length
            })),
            provenance:"Snapshot local del mantenedor; revisar autorización de distribución de cada GIF antes de publicar"
        },null,2)+"\n";
        outputs.push({spec,modulePath,manifestPath,js,manifest,resources,
                      old:fs.readFileSync(modulePath,"utf8")});
    }
    return outputs;
}
if (process.argv.length !== 2) die("Uso: node prototype/v0.1/scripts/sellar_tres_temas_fabrica.cjs");
const outputs=prepare(gather());
const created=[];
const replaced=[];
try {
    // Se escribe solo después de validar LOS TRES perfiles e imágenes.
    for (const item of outputs) for (const resource of item.resources) {
        fs.copyFileSync(resource.from,resource.to,fs.constants.COPYFILE_EXCL);
        created.push(resource.to);
    }
    for (const item of outputs) {
        fs.writeFileSync(item.manifestPath,item.manifest,{flag:"wx"});
        created.push(item.manifestPath);
    }
    for (const item of outputs) {
        fs.writeFileSync(item.modulePath,item.js,"utf8");
        replaced.push(item);
    }
} catch(e) {
    for (const item of replaced) fs.writeFileSync(item.modulePath,item.old,"utf8");
    for (const target of created.reverse()) { try{fs.unlinkSync(target);}catch(_){} }
    die("No pudo completarse el sellado: "+e.message);
}
console.log("Se sellaron Día, Atardecer y Noche en esta copia local del prototipo.");
console.log("Los valores y GIF son los exactos de los temas guardados. No se modificó Qt Settings.");
console.log("Revisá hashes, licencias y pruebas en CachyOS antes de publicar los archivos en GitHub.");
for (const item of outputs) for (const resource of item.resources)
    console.log(path.basename(resource.to)+" SHA-256 "+SHA(resource.bytes));
