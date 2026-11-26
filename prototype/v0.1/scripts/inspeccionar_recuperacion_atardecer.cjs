#!/usr/bin/env node
"use strict";
// Busca candidatos Atardecer en respaldos locales conocidos. SOLO LECTURA.
// No copia, aplica, etiqueta como fábrica, ni revela rutas/valores personales.
const fs=require("node:fs");
const path=require("node:path");
const os=require("node:os");
const crypto=require("node:crypto");
if(process.argv.length!==3){console.error("Uso interno: inspeccionar_recuperacion_atardecer.cjs log-qt");process.exit(2)}
const sha=x=>crypto.createHash("sha256").update(x).digest("hex").slice(0,16);
function decode(s){try{const v=JSON.parse(s);return v&&typeof v==="object"&&!Array.isArray(v)?v:null}catch(_){return null}}
let raw,legacy,previous,library;
try{
 const lines=fs.readFileSync(process.argv[2],"utf8").split(/\r?\n/);
 const marker="SMARTBAR_SUNSET_CANDIDATES=";
 const hits=lines.filter(x=>x.includes(marker));
 if(hits.length!==1)throw Error("respuesta Qt no inequívoca");
 raw=JSON.parse(hits[0].slice(hits[0].indexOf(marker)+marker.length));
 legacy=decode(raw.legacy);previous=decode(raw.previous);
 library=JSON.parse(raw.library);
 if(!Array.isArray(library))throw Error("biblioteca inválida");
}catch(e){console.error("No se pudo leer Qt: "+e.message);process.exit(3)}
let required;
try{
 const source=fs.readFileSync(path.join(__dirname,"sellar_tres_temas_fabrica.cjs"),"utf8");
 const match=/const required =\s*(\[[\s\S]*?\]);/.exec(source);
 if(!match)throw Error("lista de claves ausente");
 required=JSON.parse(match[1]);
}catch(e){console.error("Contrato visual no disponible: "+e.message);process.exit(3)}
function inspect(name,v){
 if(!v||v.version!==1){console.log(name+": sin perfil v1 válido");return}
 const missing=required.filter(k=>!Object.hasOwn(v,k));
 const common=legacy?required.filter(k=>Object.hasOwn(legacy,k)&&Object.hasOwn(v,k)):[];
 const different=common.filter(k=>JSON.stringify(legacy[k])!==JSON.stringify(v[k]));
 const digest=sha(JSON.stringify(v));
 console.log(name+": "+(missing.length?"INCOMPLETO":"COMPLETO")+"; faltantes="+missing.length+
  "; coincidencia histórica="+(common.length-different.length)+"/"+common.length+
  "; diferencias="+different.length+"; huella="+digest);
 if(different.length)console.log("  Campos distintos (sin valores): "+different.slice(0,8).join(", "));
}
console.log("Plasma SmartBar: recuperación Atardecer (SOLO LECTURA)");
inspect("Atardecer histórico",legacy);
inspect("Atardecer anterior recuperable",previous);
const matching=library.filter(x=>x&&typeof x.name==="string"&&x.name.trim().toLocaleLowerCase("es")==="atardecer");
console.log("Biblioteca: "+matching.length+" entrada(s) llamadas Atardecer");
matching.forEach((x,i)=>inspect("Biblioteca Atardecer "+(i+1),decode(x.jsonData)));
const dataHome=process.env.XDG_DATA_HOME||path.join(os.homedir(),".local/share");
const stateHome=process.env.XDG_STATE_HOME||path.join(os.homedir(),".local/state");
const roots=[
 path.join(dataHome,"plasma-smartbar","resguardos-playa-fabrica"),
 path.join(dataHome,"plasma-smartbar","resguardos-dia"),
 path.join(dataHome,"plasma-smartbar","resguardos"),
 path.join(stateHome,"plasma-smartbar","resguardos")
];
let scanned=0, found=0;
function visit(dir,depth){
 if(depth>3||scanned>=500)return;
 let entries;try{entries=fs.readdirSync(dir,{withFileTypes:true})}catch(_){return}
 for(const entry of entries){
  if(scanned>=500)return;
  const loc=path.join(dir,entry.name);
  if(entry.isDirectory()){visit(loc,depth+1);continue}
  if(!entry.isFile()||!entry.name.endsWith(".json"))continue;
  let stat;try{stat=fs.statSync(loc)}catch(_){continue}
  if(stat.size>2000000||stat.size===0)continue;
  ++scanned;
  let obj;try{obj=JSON.parse(fs.readFileSync(loc,"utf8"))}catch(_){continue}
  const candidates=[];
  if(obj&&typeof obj==="object"){
   candidates.push(obj);
   for(const key of ["theme","appearance","snapshot","preset","profile"]){
    if(obj[key]&&typeof obj[key]==="object")candidates.push(obj[key]);
   }
  }
  for(const v of candidates){
   if(!v||v.version!==1||!Object.hasOwn(v,"soledadGradientEnabled")||
      !Object.hasOwn(v,"logoMode"))continue;
   ++found;
   // Identificar copia local con etiqueta neutral. No asumir que es Atardecer.
   inspect("Resguardo candidato "+found,v);
  }
 }
}
roots.forEach(x=>visit(x,0));
console.log("Archivos JSON examinados en carpetas de resguardo: "+scanned+
 "; perfiles candidatos: "+found);
console.log("NO se restauró ni guardó nada. No compartir JSON ni rutas privadas.");
console.log("Una coincidencia técnica requiere comprobar identidad visual antes de fijar fábrica.");
