#!/usr/bin/env node
"use strict";
// Copia LOCAL exacta; nunca publica archivos personales ni toca el panel.
const fs=require("node:fs");
const os=require("node:os");
const path=require("node:path");
const crypto=require("node:crypto");
const {fileURLToPath}=require("node:url");
const log=process.argv[2];
if (!log) {console.error("Falta la salida del visor Qt");process.exit(2)}
const lines=fs.readFileSync(log,"utf8").split(/\r?\n/);
const found=lines.filter(x=>x.includes("SMARTBAR_DAY_CAPTURE_JSON=")).pop();
if(!found){
  const err=lines.filter(x=>x.includes("SMARTBAR_DAY_CAPTURE_ERROR=")).pop();
  console.error(err?err.slice(err.indexOf("SMARTBAR_DAY_CAPTURE_ERROR=")):
                "No hubo captura confirmada. No se creó un respaldo nuevo.");
  process.exit(3);
}
let data;
try {data=JSON.parse(found.slice(found.indexOf("SMARTBAR_DAY_CAPTURE_JSON=")+26))}
catch(e){console.error("JSON de captura inválido:",e.message);process.exit(4)}
if(data.theme?.version!==1||!data.appearanceBefore90||!Array.isArray(data.previousLibrary)){
  console.error("No se archivó una instantánea incompleta");process.exit(5)
}
const root=path.join(process.env.XDG_DATA_HOME||path.join(os.homedir(),".local","share"),
                     "plasma-smartbar","resguardos-dia");
fs.mkdirSync(root,{recursive:true,mode:0o700});
const dest=fs.mkdtempSync(path.join(root,"Dia-"));
fs.chmodSync(dest,0o700);
function save(name,obj){const p=path.join(dest,name);fs.writeFileSync(p,JSON.stringify(obj,null,2)+"\n",{mode:0o600});return p}
const themePath=save("Dia-tema-90.json",data.theme);
save("Dia-apariencia-anterior-a-90.json",data.appearanceBefore90);
save("Dia-biblioteca-anterior.json",data.previousLibrary);
const sha256=b=>crypto.createHash("sha256").update(b).digest("hex");
const manifest={capturedAt:data.capturedAt,source:"Vista activa guardada en el visor Qt de Plasma SmartBar",files:[]};
for(const file of fs.readdirSync(dest)){
  const p=path.join(dest,file);
  manifest.files.push({file,sha256:sha256(fs.readFileSync(p))});
}
let image=data.theme.logoMode==="custom"?data.theme.filePath:"";
if(data.theme.logoMode==="default")
  image=path.resolve(__dirname,"../package/contents/ui/assets/so-tropical.gif");
if(image){
  try{
    if(image.startsWith("file:"))image=fileURLToPath(image);
    if(!fs.statSync(image).isFile())throw new Error("No es archivo");
    const ext=path.extname(image).toLowerCase();
    const target=path.join(dest,"Dia-GIF-original"+(ext||".gif"));
    fs.copyFileSync(image,target,fs.constants.COPYFILE_EXCL);
    manifest.files.push({file:path.basename(target),sha256:sha256(fs.readFileSync(target)),source:image});
  }catch(e){manifest.warning="No se pudo copiar el GIF original: "+e.message}
}
save("MANIFIESTO.json",manifest);
console.log("Día respaldado localmente en:",dest);
console.log("Tema archivado:",themePath);
if(manifest.warning) console.warn(manifest.warning);
console.log("No se modificaron los temas oficiales de fábrica ni el panel KDE.");
