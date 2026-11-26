#!/usr/bin/env node
"use strict";
// Reconciliación sin escrituras: solo informa cobertura y conflictos.
// NUNCA presume que la apariencia conjunta sea Atardecer de fábrica.
const fs=require("node:fs"),path=require("node:path"),os=require("node:os");
const args=process.argv;
if(args.length!==3){console.error("Uso interno: comparar_atardecer_islas.cjs <registro-qt>");process.exit(2)}
const origin=path.join(process.env.XDG_STATE_HOME||path.join(os.homedir(),".local/state"),"plasma-smartbar/ensayos/appearance-runtime.json");
const marker="SMARTBAR_SUNSET_CANDIDATES=";
let old,now,required;
try{
 const log=fs.readFileSync(args[2],"utf8");
 const lines=log.split(/\r?\n/).filter(x=>x.includes(marker));
 if(lines.length!==1)throw Error("lector Qt no inequívoco");
 const data=JSON.parse(lines[0].slice(lines[0].indexOf(marker)+marker.length));
 old=JSON.parse(data.legacy);
 const stat=fs.lstatSync(origin);
 if(!stat.isFile()||stat.isSymbolicLink()||stat.size>200000)throw Error("perfil compartido inválido");
 now=JSON.parse(fs.readFileSync(origin,"utf8"));
 const text=fs.readFileSync(path.join(__dirname,"sellar_tres_temas_fabrica.cjs"),"utf8");
 const m=/const required =\s*(\[[\s\S]*?\]);/.exec(text);
 if(!m)throw Error("contrato visual no disponible");
 required=JSON.parse(m[1]);
 if(!old||old.version!==1||!now||typeof now!=="object")throw Error("perfiles incompatibles");
}catch(e){console.error("Sin comparación: "+e.message);process.exit(3)}
const inverse={
 effectStyle:"soActivityStyle",allowMotion:"soActivityMotion",
 strokeSize:"soActivityStroke",orbitSpeed:"soActivityOrbitSpeed",
 trailPercent:"soActivityTrailPercent",trailStyle:"soActivityTrailStyle",
 showOutlineWhenEmpty:"soActivityShowWhenEmpty",
 showOutlineWhenOpen:"soActivityShowWhenOpen",pulseSpeed:"soActivityPulseSpeed",
 pulseDepth:"soActivityPulseDepth",logoMode:"soLogoMode",filePath:"soLogoPath",
 shape:"soLogoShape",cropFitMode:"soLogoFitMode",cropZoom:"soLogoZoom",
 cropPanX:"soLogoPanX",cropPanY:"soLogoPanY",cropRotation:"soLogoRotation",
 enableGif:"soLogoAnimate",accentColor:"soActivityColor",
 glowColor:"soActivityGlowColor",glowIntensity:"soActivityGlowIntensity",
 glowSpread:"soActivityGlowSpread",glowGradient:"soActivityGlowGradient",
 clockFontFamily:"soClockFontFamily",clockFontSize:"soClockFontSize",
 clockTextColor:"soClockTextColor"
};
function runtimeKey(name){const source=inverse[name]||name;return "demo"+source[0].toUpperCase()+source.slice(1)}
const missing=required.filter(k=>!Object.hasOwn(old,k));
const available=missing.filter(k=>Object.hasOwn(now,runtimeKey(k))&&now[runtimeKey(k)]!==null);
const unavailable=missing.filter(k=>!available.includes(k));
const common=required.filter(k=>Object.hasOwn(old,k)&&Object.hasOwn(now,runtimeKey(k)));
const different=common.filter(k=>JSON.stringify(old[k])!==JSON.stringify(now[runtimeKey(k)]));
console.log("Atardecer histórico: "+missing.length+" campos faltantes del contrato completo");
console.log("De esos, aparecen en apariencia conjunta: "+available.length);
console.log("Todavía sin datos en esas dos fuentes: "+unavailable.length);
console.log("Campos recuperables potenciales (solo nombres): "+(available.join(", ")||"(ninguno)"));
console.log("Campos aún ausentes: "+(unavailable.join(", ")||"(ninguno)"));
console.log("Comparación de campos históricos presentes: "+common.length+" comparables, "+different.length+" distintos");
console.log("Nombres de campos distintos: "+(different.join(", ")||"(ninguno)"));
console.log("No se aplicó ningún tema ni se escribió ningún archivo. No asumir identidad oficial.");
