#!/usr/bin/env node
"use strict";
// Crea una copia local privada del aspecto activo YA GUARDADO en Qt.
// Nunca modifica Qt Settings, temas oficiales, packs ni panel KDE.
// No afirma que los faltantes de un perfil histórico existan en el original.
const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const crypto = require("node:crypto");
const {fileURLToPath} = require("node:url");

const logPath = process.argv[2];
const themeId = process.argv[3];
const config = {
    dia: {label:"Día",slot:"library",display:"Día"},
    atardecer: {label:"Atardecer",slot:"sunsetLegacy",display:"Atardecer histórico"},
    noche: {label:"Noche",slot:"nightLegacy",display:"Noche histórica"}
};
if (process.argv.length !== 4 || !logPath || !Object.hasOwn(config,themeId)) {
    console.error("Uso: archivar_original_playa.cjs registro-qt dia|atardecer|noche");
    process.exit(2);
}
const cwd = path.resolve(__dirname, "..");
const assetsDir = path.join(cwd, "package/contents/ui/assets");
const allowedExtensions = new Set([".gif",".png",".jpg",".jpeg",".webp",".svg",".bmp"]);
function stop(reason) {
    console.error("Resguardo NO creado: " + reason);
    process.exit(3);
}
function sha(fileOrBuffer) {
    return crypto.createHash("sha256").update(fileOrBuffer).digest("hex");
}
let payload, appearance, library, source;
try {
    const log = fs.readFileSync(logPath,"utf8");
    const marker = "SMARTBAR_PLAYA_FACTORY_CANDIDATE=";
    const matches = log.split(/\r?\n/).filter(x=>x.includes(marker));
    if (matches.length !== 1) throw Error("Lectura Qt no inequívoca");
    payload = JSON.parse(matches[0].slice(matches[0].indexOf(marker)+marker.length));
    if (!payload || typeof payload !== "object") throw Error("Datos Qt inválidos");
    if (payload.selectedPack !== "playa-24hs")
        throw Error("El pack seleccionado debe ser Playa 24hs; no se tocó el pack actual");
    appearance = JSON.parse(payload.appearance);
    library = JSON.parse(payload.library);
    if (!appearance || typeof appearance !== "object" || Array.isArray(appearance))
        throw Error("Apariencia guardada inválida");
    if (!Array.isArray(library)) throw Error("Biblioteca inválida");
    if (config[themeId].slot === "library") {
        const matches = library.filter(item=>item && typeof item.name === "string" &&
            ["día","dia"].includes(item.name.trim().toLocaleLowerCase("es")));
        if (matches.length !== 1) throw Error("Día inexistente o ambiguo en biblioteca");
        source = JSON.parse(matches[0].jsonData);
    } else {
        source = JSON.parse(payload[config[themeId].slot]);
    }
    if (!source || typeof source !== "object" || source.version !== 1 ||
        Array.isArray(source)) throw Error("La referencia histórica está incompleta o es inválida");
    const previewSrc = fs.readFileSync(path.join(cwd,"preview_redimensionable.qml"),"utf8");
    const match = /readonly property var appearanceKeys:\s*(\[[^\r\n]+\])/.exec(previewSrc);
    if (!match) throw Error("No se pudo verificar el contrato completo de apariencia Qt");
    const required = JSON.parse(match[1]);
    const missing = required.filter(k=>!Object.hasOwn(appearance,k) || appearance[k] === null);
    if (missing.length) throw Error("Apariencia activa incompleta ("+missing.length+
        " campos): "+missing.slice(0,5).join(", "));
} catch (error) {
    stop(error.message);
}
function readImage(raw, label) {
    if (typeof raw !== "string" || !raw.trim())
        throw Error("Falta " + label);
    let filename = raw;
    if (filename.startsWith("file:")) filename = fileURLToPath(filename);
    else if (filename.includes("://") || !path.isAbsolute(filename))
        throw Error(label + " no es una ruta de archivo local absoluta");
    const extension = path.extname(filename).toLowerCase();
    if (!allowedExtensions.has(extension))
        throw Error("Extensión no aceptada para " + label);
    const stat = fs.statSync(filename);
    if (!stat.isFile() || stat.size === 0)
        throw Error("Archivo de " + label + " vacío o no regular");
    return {file: filename, extension, size: stat.size, hash: sha(fs.readFileSync(filename))};
}
function visualLogo(values, modeKey, pathKey) {
    if (values[modeKey] === "text") return null;
    if (values[modeKey] === "default")
        return readImage(path.join(assetsDir,"so-tropical.gif"),"logo predeterminado");
    if (values[modeKey] === "custom")
        return readImage(values[pathKey],"logo personalizado");
    throw Error("Modo de logo desconocido: " + values[modeKey]);
}
let activeLogo, originalLogo, activeBg;
try {
    activeLogo = visualLogo(appearance,"demoSoLogoMode","demoSoLogoPath");
    originalLogo = visualLogo(source,"logoMode","filePath");
    if (!!activeLogo !== !!originalLogo ||
        (activeLogo && activeLogo.hash !== originalLogo.hash))
        throw Error("El logo de la apariencia activa NO coincide con el tema elegido. "+
            "No se archivó bajo un nombre incorrecto.");
    if (appearance.demoSoTextBackgroundImage)
        activeBg = readImage(appearance.demoSoTextBackgroundImage,"fondo de texto SO");
    if (source.soTextBackgroundImage) {
        const historicBg = readImage(source.soTextBackgroundImage,"fondo histórico");
        if (!activeBg || activeBg.hash !== historicBg.hash)
            throw Error("El fondo de texto SO no coincide con la referencia del tema.");
    }
} catch(error) {stop(error.message);}

// Conservamos la apariencia completa activa y la referencia histórica POR
// SEPARADO. No rellenamos campos en la referencia, ni aplicamos restauraciones.
const root = path.join(process.env.XDG_DATA_HOME ||
    path.join(os.homedir(),".local","share"),"plasma-smartbar","resguardos-playa-fabrica");
let destination;
try {
    fs.mkdirSync(root,{recursive:true,mode:0o700});
    destination = fs.mkdtempSync(path.join(root,themeId+"-"));
    fs.chmodSync(destination,0o700);
    function writeJson(name,obj) {
        const buf = Buffer.from(JSON.stringify(obj,null,2)+"\n","utf8");
        fs.writeFileSync(path.join(destination,name),buf,{flag:"wx",mode:0o600});
        return {file:name,bytes:buf.length,sha256:sha(buf)};
    }
    const saved = [
        writeJson("apariencia-activa-completa.json",appearance),
        writeJson("referencia-original-local.json",source)
    ];
    function archiveImage(image,basename) {
        if (!image) return;
        const name = basename+image.extension;
        fs.copyFileSync(image.file,path.join(destination,name),fs.constants.COPYFILE_EXCL);
        fs.chmodSync(path.join(destination,name),0o600);
        saved.push({file:name,bytes:image.size,sha256:image.hash});
    }
    archiveImage(activeLogo,"logo");
    archiveImage(activeBg,"fondo-texto-so");
    const details = {
        version:1, intent:"CANDIDATA pendiente de verificación visual y legal",
        theme:config[themeId].label, source:config[themeId].display,
        selectedPack:payload.selectedPack, capturedAt:new Date().toISOString(),
        wallpaperPreview:payload.wallpaperPreview,
        profileComplete:"Apariencia activa guardada con todas las claves requeridas",
        historicalProfile:"Referencia preservada SIN completar valores ausentes",
        entries:saved,
        licenses:"No autorizada aún la redistribución de imágenes"
    };
    writeJson("MANIFIESTO.json",details);
    console.log("Resguardo LOCAL creado para "+config[themeId].label+": "+destination);
    console.log("Apariencia Qt completa y referencia anterior copiadas por separado.");
    console.log("Recursos gráficos: "+saved.filter(x=>/^(logo|fondo-texto-so)/.test(x.file)).length+
                " archivo(s) respaldado(s).");
    console.log("No se modificó Playa 24hs, ningún tema, KConfig ni el panel KDE.");
    console.log("Esto NO publica ni activa aún los originales oficiales de fábrica.");
} catch(error) {
    console.error("No se pudo finalizar el resguardo: "+error.message+
        (destination ? ". Revisá la carpeta parcial: "+destination : ""));
    process.exitCode=4;
}
