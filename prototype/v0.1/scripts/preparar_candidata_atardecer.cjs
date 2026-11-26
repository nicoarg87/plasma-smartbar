#!/usr/bin/env node
"use strict";
// CANDIDATA local de Atardecer: conservar TODAS las claves históricas,
// completar SOLO ausencias desde la apariencia compartida, sin activar temas.
// No altera QSettings, appearance-runtime.json, packs ni presets de fábrica.
const fs=require("node:fs"),path=require("node:path"),os=require("node:os"),crypto=require("node:crypto");
if(process.argv.length!==3){console.error("Uso interno: preparar_candidata_atardecer.cjs <registro-qt>");process.exit(2)}
const sha=b=>crypto.createHash("sha256").update(b).digest("hex");
const fail=s=>{console.error("Sin candidata: "+s);process.exit(3)};
const marker="SMARTBAR_SUNSET_CANDIDATES=";
const state=process.env.XDG_STATE_HOME||path.join(os.homedir(),".local","state");
const data=process.env.XDG_DATA_HOME||path.join(os.homedir(),".local","share");
const source=path.join(state,"plasma-smartbar","ensayos","appearance-runtime.json");
const inverse={
 effectStyle:"soActivityStyle",allowMotion:"soActivityMotion",
 strokeSize:"soActivityStroke",orbitSpeed:"soActivityOrbitSpeed",
 trailPercent:"soActivityTrailPercent",trailStyle:"soActivityTrailStyle",
 showOutlineWhenEmpty:"soActivityShowWhenEmpty",showOutlineWhenOpen:"soActivityShowWhenOpen",
 pulseSpeed:"soActivityPulseSpeed",pulseDepth:"soActivityPulseDepth",
 logoMode:"soLogoMode",filePath:"soLogoPath",shape:"soLogoShape",
 cropFitMode:"soLogoFitMode",cropZoom:"soLogoZoom",cropPanX:"soLogoPanX",
 cropPanY:"soLogoPanY",cropRotation:"soLogoRotation",enableGif:"soLogoAnimate",
 accentColor:"soActivityColor",glowColor:"soActivityGlowColor",
 glowIntensity:"soActivityGlowIntensity",glowSpread:"soActivityGlowSpread",
 glowGradient:"soActivityGlowGradient",clockFontFamily:"soClockFontFamily",
 clockFontSize:"soClockFontSize",clockTextColor:"soClockTextColor"
};
function runtimeKey(k){const n=inverse[k]||k;return "demo"+n[0].toUpperCase()+n.slice(1)}
let legacy,runtime,required,original;
try{
 const log=fs.readFileSync(process.argv[2],"utf8");
 const lines=log.split(/\r?\n/).filter(x=>x.includes(marker));
 if(lines.length!==1)throw Error("lectura Qt no inequívoca");
 const payload=JSON.parse(lines[0].slice(lines[0].indexOf(marker)+marker.length));
 original=payload.legacy;
 legacy=JSON.parse(original);
 const st=fs.lstatSync(source);
 if(!st.isFile()||st.isSymbolicLink()||st.size>200000)throw Error("apariencia conjunta inválida");
 runtime=JSON.parse(fs.readFileSync(source,"utf8"));
 const contract=fs.readFileSync(path.join(__dirname,"sellar_tres_temas_fabrica.cjs"),"utf8");
 const m=/const required =\s*(\[[\s\S]*?\]);/.exec(contract);
 if(!m)throw Error("contrato visual no encontrado");
 required=JSON.parse(m[1]);
 if(!legacy||legacy.version!==1||Array.isArray(legacy)||!runtime||Array.isArray(runtime))
   throw Error("perfiles incompatibles");
}catch(e){fail(e.message)}
const draft={...legacy};
const missing=required.filter(k=>!Object.hasOwn(legacy,k));
const fields=[];
for(const key of missing){
 const from=runtimeKey(key);
 if(!Object.hasOwn(runtime,from)||runtime[from]===null||runtime[from]===undefined)
   fail("campo faltante sin fuente: "+key);
 draft[key]=runtime[from];
 fields.push({key,sourceKey:from});
}
const conflicts=required.filter(k=>Object.hasOwn(legacy,k)&&Object.hasOwn(runtime,runtimeKey(k))&&
  JSON.stringify(legacy[k])!==JSON.stringify(runtime[runtimeKey(k)]));
if(required.some(k=>!Object.hasOwn(draft,k)))fail("candidata sigue incompleta");
const root=path.join(data,"plasma-smartbar","resguardos-playa-fabrica");
let dest;
try{
 fs.mkdirSync(root,{recursive:true,mode:0o700});
 dest=fs.mkdtempSync(path.join(root,"atardecer-candidata-no-oficial-"));
 fs.chmodSync(dest,0o700);
 function save(name,raw){
  const bytes=Buffer.from(raw,"utf8");
  fs.writeFileSync(path.join(dest,name),bytes,{flag:"wx",mode:0o600});
  return {name,sha256:sha(bytes),bytes:bytes.length};
 }
 const copies=[
  save("atardecer-historico-original.json",original+"\n"),
  save("atardecer-candidata-NO-OFICIAL.json",JSON.stringify(draft,null,2)+"\n")
 ];
 const manifest={
  version:1,identity:"NO VERIFICADA; candidato de reconstrucción, NO fábrica",
  method:"conservar claves históricas y añadir SOLO faltantes desde ensayo conjunto",
  originalProperties:Object.keys(legacy).length,
  filledProperties:fields.length,filledFields:fields,
  preservedConflictFields:conflicts,createdAt:new Date().toISOString(),
  originalsUnchanged:true,files:copies
 };
 save("MANIFIESTO.json",JSON.stringify(manifest,null,2)+"\n");
 console.log("Candidata privada de Atardecer creada, SIN activar.");
 console.log("Ruta: "+dest);
 console.log("Campos faltantes incorporados: "+fields.length);
 console.log("Campos históricos conservados pese a diferencias: "+conflicts.length);
 console.log("Claves requeridas aún faltantes: 0");
 console.log("Identidad visual y correspondencia originales: PENDIENTES de validar.");
 console.log("No se modificaron temas, packs, wallpapers, Qt Settings ni panel KDE.");
}catch(e){console.error("Error de resguardo: "+e.message+(dest?" (copia parcial: "+dest+")":""));process.exitCode=4}
