#!/usr/bin/env node
"use strict";
// Preparación LOCAL de Playa 24hs para las islas LayerShell, sin tocar KDE.
// Lee perfiles auténticos ya resguardados y conserva intacto el perfil vigente.
const fs=require("node:fs"),path=require("node:path"),os=require("node:os");
const crypto=require("node:crypto"),vm=require("node:vm");
const {pathToFileURL}=require("node:url");
function fail(msg){console.error("No se habilitó el menú de temas: "+msg);process.exit(3)}
if(process.argv.length!==3)fail("falta registro de la lectura Qt");
const sha=b=>crypto.createHash("sha256").update(b).digest("hex");
const home=process.env.XDG_DATA_HOME||path.join(os.homedir(),".local/share");
const state=process.env.XDG_STATE_HOME||path.join(os.homedir(),".local/state");
const backups=path.join(home,"plasma-smartbar","resguardos-playa-fabrica");
const assets=path.resolve(__dirname,"../package/contents/ui/assets");
const target=path.join(assets,".smartbar-runtime-theme-pack.json");
const live=path.join(state,"plasma-smartbar","ensayos","appearance-runtime.json");
const allowed=new Set([".gif",".png",".jpg",".jpeg",".webp",".svg",".bmp"]);
let runtime;
try{
 const context={};
 const code=fs.readFileSync(path.join(__dirname,"../package/contents/ui/RuntimeAppearance.js"),"utf8")
   .replace(/^\.pragma library\s*$/m,"");
 vm.runInNewContext(code,context,{timeout:1000});
 runtime=context;
 if(typeof runtime.themeToPatch!=="function"||!Array.isArray(runtime.visualKeys))
   throw Error("contrato visual no disponible");
}catch(e){fail(e.message)}
function choose(prefix,file,requireName){
 const folders=fs.readdirSync(backups,{withFileTypes:true})
  .filter(e=>e.isDirectory()&&e.name.startsWith(prefix))
  .map(e=>path.join(backups,e.name))
  .filter(d=>fs.existsSync(path.join(d,file)));
 if(requireName){
  return folders.find(d=>{
   try{return JSON.parse(fs.readFileSync(path.join(d,"MANIFIESTO.json"),"utf8")).theme===requireName}
   catch(_){return false}
  });
 }
 return folders.length ? folders.sort((a,b)=>fs.statSync(b).mtimeMs-fs.statSync(a).mtimeMs)[0] : null;
}
function readVerified(dir,file,metaName){
 const candidate=path.join(dir,file);
 const buf=fs.readFileSync(candidate);
 const manifest=JSON.parse(fs.readFileSync(path.join(dir,"MANIFIESTO.json"),"utf8"));
 const entries=manifest.entries||manifest.files||[];
 if(!entries.some(e=>(e.name||e.file)===(metaName||file)&&e.sha256===sha(buf)))
   throw Error("el hash del respaldo "+file+" no coincide");
 return JSON.parse(buf.toString("utf8"));
}
function asset(dir,base){
 if(!dir)return "";
 const found=fs.readdirSync(dir).filter(f=>f.startsWith(base+".")&&allowed.has(path.extname(f).toLowerCase()));
 if(found.length!==1)return "";
 const loc=path.join(dir,found[0]);
 if(!fs.statSync(loc).isFile())return "";
 return pathToFileURL(loc).href;
}
function localImage(source){
 if(typeof source!=="string"||!source.trim())return "";
 let file=source;
 if(file.startsWith("file:")){
  try{file=require("node:url").fileURLToPath(file)}catch(_){return ""}
 }else if(file.includes("://")||!path.isAbsolute(file))return "";
 if(!allowed.has(path.extname(file).toLowerCase()))return "";
 try{
  const st=fs.statSync(file);
  return st.isFile()&&st.size>0?pathToFileURL(file).href:"";
 }catch(_){return ""}
}
function normalizeImage(profile,dir){
 if(profile.logoMode==="custom"){
  const logo=asset(dir,"logo")||localImage(profile.filePath);
  if(!logo)throw Error("falta el logo original del tema");
  profile.filePath=logo;
 }
 if(profile.soTextBackgroundImage){
  const background=asset(dir,"fondo-texto-so")||
    localImage(profile.soTextBackgroundImage);
  if(!background)throw Error("falta el fondo de texto original");
  profile.soTextBackgroundImage=background;
 }
}
function fromRuntime(profile,dir){
 const patch={};
 for(const name of runtime.visualKeys){
  if(runtime.themeBehaviorKeys.indexOf(name)>=0)continue;
  const key=runtime.savedKey(name);
  if(Object.hasOwn(profile,key))patch[key]=profile[key];
 }
 const logo=asset(dir,"logo");
 if(patch.demoSoLogoMode==="custom"&&!logo)throw Error("falta el logo original de Noche");
 if(logo&&patch.demoSoLogoMode==="custom")patch.demoSoLogoPath=logo;
 const bg=asset(dir,"fondo-texto-so");
 if(patch.demoSoTextBackgroundImage&&!bg)throw Error("falta fondo de texto de Noche");
 if(bg&&patch.demoSoTextBackgroundImage)patch.demoSoTextBackgroundImage=bg;
 return patch;
}
let payload;
try{
 if(fs.existsSync(target))throw Error("ya existe un pack local; no se sobrescribe");
 const log=fs.readFileSync(process.argv[2],"utf8");
 const marker="SMARTBAR_PLAYA_FACTORY_CANDIDATE=";
 const matches=log.split(/\r?\n/).filter(l=>l.includes(marker));
 if(matches.length!==1)throw Error("respuesta Qt ambigua");
 payload=JSON.parse(matches[0].slice(matches[0].indexOf(marker)+marker.length));
 if(payload.selectedPack!=="playa-24hs")
  throw Error("el pack seleccionado en Qt no es Playa 24hs");
 if(!fs.existsSync(live)||!fs.statSync(live).isFile())
  throw Error("no hay apariencia compartida del ensayo conjunto");
 const day=choose("dia-biblioteca-","perfil-dia-biblioteca.json");
 const sunset=choose("atardecer-candidata-no-oficial-","atardecer-candidata-NO-OFICIAL.json");
 const night=choose("noche-","apariencia-activa-completa.json","Noche");
 if(!day||!sunset||!night)throw Error("faltan respaldos de Día, Atardecer o Noche");
 const d=readVerified(day,"perfil-dia-biblioteca.json");
 const a=readVerified(sunset,"atardecer-candidata-NO-OFICIAL.json");
 const n=readVerified(night,"apariencia-activa-completa.json");
 normalizeImage(d,day);
 normalizeImage(a,sunset); // Atardecer provisional, siempre identificado como tal.
 const themes={
   sunset:runtime.themeToPatch(a),
   night:fromRuntime(n,night),
   day:runtime.themeToPatch(d)
 };
 for(const [name,patch] of Object.entries(themes)){
  if(!patch||Object.keys(patch).length<55)
   throw Error("el perfil "+name+" no incluye estética visual suficiente");
 }
 const original=fs.readFileSync(live);
 JSON.parse(original.toString("utf8"));
 const copy=path.join(path.dirname(live),"appearance-before-menu-temas-"+sha(original).slice(0,16)+".json");
 if(!fs.existsSync(copy))fs.writeFileSync(copy,original,{flag:"wx",mode:0o600});
 else if(sha(fs.readFileSync(copy))!==sha(original))
   throw Error("el respaldo previo no coincide");
 const staged={
  version:1,packId:"playa-24hs",
  provisionalSunset:true,
  themes,
  themesSequence:["sunset","night","day"],
  sourceHashes:{day:sha(fs.readFileSync(path.join(day,"perfil-dia-biblioteca.json"))),
    sunset:sha(fs.readFileSync(path.join(sunset,"atardecer-candidata-NO-OFICIAL.json"))),
    night:sha(fs.readFileSync(path.join(night,"apariencia-activa-completa.json")))}
 };
 fs.writeFileSync(target,JSON.stringify(staged,null,2)+"\n",{flag:"wx",mode:0o600});
 console.log("Playa 24hs preparado para islas conjuntas: Atardecer provisional, Noche, Día.");
 console.log("Copia previa de la apariencia activa: "+copy);
 console.log("Tres estéticas de SO/Soledad/Malvina disponibles, con sus recursos originales.");
 console.log("No se modificó el perfil activo, las posiciones por aplicación ni el wallpaper KDE.");
 console.log("Para usar el menú, reiniciar el ensayo conjunto después de actualizar Git.");
}catch(e){fail(e.message)}
