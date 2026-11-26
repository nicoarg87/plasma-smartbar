#!/usr/bin/env node
"use strict";
// Instalación LOCAL y reversible de Atardecer provisional aprobado.
// Nunca modifica FactorySunsetTheme.js, tema histórico, Qt Settings ni KDE.
const fs=require("node:fs"),path=require("node:path"),os=require("node:os"),crypto=require("node:crypto");
const source=process.argv[2];
if(process.argv.length!==3||!source){
 console.error("Uso: node prototype/v0.1/scripts/instalar_atardecer_provisional.cjs ruta-del-resguardo");
 process.exit(2);
}
function fail(msg){console.error("Atardecer provisional NO instalado: "+msg);process.exit(3)}
const root=path.resolve(__dirname,"../package/contents/ui/assets");
const destination=path.join(root,".smartbar-atardecer-provisional.json");
let original,manifest,preset,required;
try{
 const dir=path.resolve(source);
 const expected=path.join(process.env.XDG_DATA_HOME||path.join(os.homedir(),".local/share"),
   "plasma-smartbar","resguardos-playa-fabrica");
 if(path.dirname(dir)!==expected||!path.basename(dir).startsWith("atardecer-candidata-no-oficial-"))
   throw Error("origen fuera del directorio de candidatas");
 if(fs.existsSync(destination))throw Error("ya hay una candidata local instalada; no se sobrescribe");
 const candidateFile=path.join(dir,"atardecer-candidata-NO-OFICIAL.json");
 const manifestFile=path.join(dir,"MANIFIESTO.json");
 if(!fs.lstatSync(candidateFile).isFile()||!fs.lstatSync(manifestFile).isFile())
   throw Error("los archivos de origen no son regulares");
 original=fs.readFileSync(candidateFile,"utf8");
 manifest=JSON.parse(fs.readFileSync(manifestFile,"utf8"));
 const expectedHash=crypto.createHash("sha256").update(Buffer.from(original,"utf8")).digest("hex");
 if(!Array.isArray(manifest.files)||!manifest.files.some(x=>x.name==="atardecer-candidata-NO-OFICIAL.json"&&x.sha256===expectedHash))
   throw Error("el perfil no coincide con la huella del resguardo");
 preset=JSON.parse(original);
 if(manifest.identity!=="NO VERIFICADA; candidato de reconstrucción, NO fábrica"||
    manifest.filledProperties!==22||!manifest.originalsUnchanged)
   throw Error("manifiesto de candidata no reconocido");
 if(preset.version!==1||!preset||Array.isArray(preset))throw Error("perfil inválido");
 const helper=fs.readFileSync(path.join(__dirname,"sellar_tres_temas_fabrica.cjs"),"utf8");
 const match=/const required =\s*(\[[\s\S]*?\]);/.exec(helper);
 if(!match)throw Error("contrato visual ausente");
 required=JSON.parse(match[1]);
 if(required.some(k=>!Object.hasOwn(preset,k)))throw Error("faltan propiedades visuales");
 if(!["default","custom","text"].includes(preset.logoMode))throw Error("logo no reconocido");
 if(preset.logoMode==="custom"){
    const url=String(preset.filePath||"");
    if(!url.startsWith("file:///")&&!path.isAbsolute(url))
       throw Error("ruta de GIF del tema no local");
 }
}catch(e){fail(e.message)}
try{
 fs.writeFileSync(destination,original,{flag:"wx",mode:0o600});
 console.log("Atardecer provisional habilitado SOLO en esta copia de SmartBar.");
 console.log("Archivo local (reversible): "+destination);
 console.log("La ranura histórica y los temas oficiales permanecen intactos.");
 console.log("Reiniciá el visor/ensayo para que lea el archivo.");
 console.log("Para desactivar la candidata, renombrá el archivo local (no lo borres).");
}catch(e){fail(e.message)}
