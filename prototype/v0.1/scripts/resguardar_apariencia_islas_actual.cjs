#!/usr/bin/env node
"use strict";
// Resguardo de SOLO LECTURA de la apariencia del ensayo conjunto de islas.
// No etiqueta automáticamente como Atardecer ni altera estado, panel o Qt.
const fs=require("node:fs");
const path=require("node:path");
const os=require("node:os");
const crypto=require("node:crypto");
const {fileURLToPath}=require("node:url");
if(process.argv.length!==2){
 console.error("Uso: node prototype/v0.1/scripts/resguardar_apariencia_islas_actual.cjs");
 process.exit(2);
}
const state=process.env.XDG_STATE_HOME||path.join(os.homedir(),".local","state");
const data=process.env.XDG_DATA_HOME||path.join(os.homedir(),".local","share");
const src=path.join(state,"plasma-smartbar","ensayos","appearance-runtime.json");
const sha=buf=>crypto.createHash("sha256").update(buf).digest("hex");
const allowed=new Set([".gif",".png",".jpg",".jpeg",".webp",".svg",".bmp"]);
function fail(s){console.error("No se creó resguardo: "+s);process.exit(3)}
let raw,obj,stat;
try{
 stat=fs.lstatSync(src);
 if(!stat.isFile()||stat.isSymbolicLink()||stat.size<2||stat.size>200000)
   throw Error("perfil compartido ausente o inválido");
 raw=fs.readFileSync(src);
 obj=JSON.parse(raw.toString("utf8"));
 if(!obj||typeof obj!=="object"||Array.isArray(obj))
   throw Error("perfil JSON inválido");
}catch(e){fail(e.message)}
// Campos presentes, no completar campos ausentes ni atribuir nombre al tema.
const values=Object.keys(obj);
const signatures=["demoSoledadColor","demoMalvinaColor","demoSoLogoMode"];
if(!signatures.some(key=>Object.hasOwn(obj,key)))
 fail("el perfil no contiene claves visuales identificables");
const images=[];
for(const [key,base] of [
 ["demoSoLogoPath","logo-so"],
 ["demoSoTextBackgroundImage","fondo-texto-so"]
]){
 const spec=obj[key];
 if(typeof spec!=="string"||!spec.trim())continue;
 try{
  let file=spec;
  if(file.startsWith("file:"))file=fileURLToPath(file);
  else if(file.includes("://")||!path.isAbsolute(file))continue;
  const ext=path.extname(file).toLowerCase();
  if(!allowed.has(ext))continue;
  const st=fs.statSync(file);
  if(!st.isFile()||st.size<1||st.size>50*1024*1024)continue;
  images.push({key,base,ext,bytes:fs.readFileSync(file)});
 }catch(_){/* no sustituir ni inventar recursos faltantes */}
}
const root=path.join(data,"plasma-smartbar","resguardos-playa-fabrica");
let dest;
try{
 fs.mkdirSync(root,{recursive:true,mode:0o700});
 dest=fs.mkdtempSync(path.join(root,"islas-actuales-sin-identificar-"));
 fs.chmodSync(dest,0o700);
 function save(name,bytes){
  fs.writeFileSync(path.join(dest,name),bytes,{flag:"wx",mode:0o600});
  return {name,bytes:bytes.length,sha256:sha(bytes)};
 }
 const entries=[save("apariencia-compartida-original.json",raw)];
 for(const img of images)entries.push(save(img.base+img.ext,img.bytes));
 const manifest={
   version:1,
   source:"Ensayo conjunto Soledad/Malvina: appearance-runtime.json",
   identity:"sin identificar; el wallpaper no determina el tema",
   capturedAt:new Date().toISOString(),
   keysPresent:values.length,
   entries
 };
 save("MANIFIESTO.json",Buffer.from(JSON.stringify(manifest,null,2)+"\n"));
 console.log("Apariencia actual del ensayo conjunto respaldada SIN asignarle un tema.");
 console.log("Resguardo privado: "+dest);
 console.log("Claves presentes: "+values.length);
 console.log("Recursos gráficos copiados: "+images.length);
 console.log("Huella SHA-256 del perfil: "+sha(raw));
 console.log("No se modificó la apariencia, el wallpaper, los horarios ni el panel KDE.");
 console.log("Esta copia NO demuestra todavía que el perfil completo sea Atardecer.");
}catch(e){
 console.error("No se completó resguardo: "+e.message+
   (dest?" (revisá copia parcial: "+dest+")":""));
 process.exitCode=4;
}
