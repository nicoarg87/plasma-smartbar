#!/usr/bin/env node
"use strict";
// Wallpaper REAL de Playa 24hs, solo tras una acción explícita del menú SO.
// No cambia paneles, otros escritorios, actividades, plugins ni FillMode.
// El primer cambio crea un respaldo privado; undo restaura el último cambio.
// NUNCA imprimir rutas privadas ni sobrescribir una imagen cambiada a mano.
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const crypto = require("node:crypto");
const {spawnSync} = require("node:child_process");
const {pathToFileURL} = require("node:url");
const action = process.argv[2];
if (process.argv.length !== 3 ||
    !["day","sunset","night","undo","restore","check"].includes(action)) {
    console.error("Uso: wallpaper_playa_kde.cjs check|day|sunset|night|undo|restore");
    process.exit(2);
}
const here = path.resolve(__dirname, "..");
const repo = path.resolve(here,"../..");
const stateRoot = path.join(process.env.XDG_STATE_HOME ||
    path.join(os.homedir(),".local/state"),"plasma-smartbar","ensayos");
const stateFile = path.join(stateRoot,"wallpaper-playa24hs-original.json");
const manifestFile = path.join(here,"package/contents/ui/assets/wallpapers/manifest.json");
const marker = "SMARTBAR_WALLPAPER_RESULT=";
function stop(reason) { throw Error(reason); }
function hash(bytes) { return crypto.createHash("sha256").update(bytes).digest("hex"); }
function wallpaperSource(theme) {
    const manifest = JSON.parse(fs.readFileSync(manifestFile,"utf8"));
    const item = manifest.assets && manifest.assets.find(a=>a.theme===theme);
    if (!item || typeof item.file!=="string" ||
        item.file!=="prototype/v0.1/package/contents/ui/assets/wallpapers/"+theme+".png")
        stop("no se encontró el recurso auténtico del tema "+theme);
    const file = path.join(repo,item.file);
    const content = fs.readFileSync(file);
    if (content.length!==item.bytes || hash(content)!==item.sha256)
        stop("integridad del wallpaper de "+theme+" no confirmada");
    return pathToFileURL(file).href;
}
function findBus() {
    const candidates=["qdbus6","qdbus-qt6","/usr/lib/qt6/bin/qdbus"];
    for (const name of candidates) {
        if (name.includes("/") && fs.existsSync(name)) return name;
        if (!name.includes("/")) {
            const envPaths = String(process.env.PATH||"").split(path.delimiter);
            if (envPaths.some(dir=>{
                try{fs.accessSync(path.join(dir,name),fs.constants.X_OK);return true}
                catch(_){return false}
            })) return name;
        }
    }
    stop("Qt D-Bus de KDE no está disponible");
}
const bus = findBus();
function evaluate(source) {
    const call = spawnSync(bus,[
        "org.kde.plasmashell","/PlasmaShell",
        "org.kde.PlasmaShell.evaluateScript",source
    ],{encoding:"utf8",timeout:7000,maxBuffer:150000});
    if (call.error || call.status!==0)
        stop("Plasma 6 no respondió a la consulta de wallpaper");
    const lines = String(call.stdout||"").split(/\r?\n/)
        .filter(line=>line.includes(marker));
    if (lines.length!==1) stop("respuesta del escritorio KDE ambigua");
    const line = lines[0];
    const data = JSON.parse(line.slice(line.indexOf(marker)+marker.length));
    if (!data || typeof data!=="object" || Array.isArray(data))
        stop("respuesta KDE inválida");
    return data;
}
const activeScript = `(function() {
 var ds=desktopsForActivity(currentActivity());
 if(ds.length!==1 || Number(ds[0].screen)!==0){
   print("${marker}"+JSON.stringify({ok:false,reason:"scope"}));return;
 }
 var d=ds[0], plugin=String(d.wallpaperPlugin||"");
 d.currentConfigGroup=["Wallpaper","org.kde.image","General"];
 print("${marker}"+JSON.stringify({
   ok:true,id:Number(d.id),screen:Number(d.screen),
   plugin:plugin,image:String(d.readConfig("Image","")),
   fillMode:String(d.readConfig("FillMode",""))
 }));
})();`;
function currentWallpaper() {
    const d=evaluate(activeScript);
    if (!d.ok || !Number.isInteger(d.id) || d.id<0 || d.screen!==0 ||
        d.plugin!=="org.kde.image" || !d.image)
        stop("se requiere un único escritorio activo con imagen KDE (pantalla 0)");
    return d;
}
function updateKde(id,expected,next) {
    const script=`(function() {
 var ds=desktopsForActivity(currentActivity());
 var safe=ds.length===1 && Number(ds[0].id)===${JSON.stringify(id)}
  && Number(ds[0].screen)===0
  && String(ds[0].wallpaperPlugin)==="org.kde.image";
 if(!safe){print("${marker}"+JSON.stringify({ok:false}));return;}
 var d=ds[0];d.currentConfigGroup=["Wallpaper","org.kde.image","General"];
 var before=String(d.readConfig("Image",""));
 if(before!==${JSON.stringify(expected)}){
   print("${marker}"+JSON.stringify({ok:false}));return;
 }
 // Igual que plasma-apply-wallpaperimage: revalidar el plugin de imagen
 // para que KDE refresque el fondo en la pantalla del escritorio elegido.
 d.wallpaperPlugin="org.kde.image";
 d.currentConfigGroup=["Wallpaper","org.kde.image","General"];
 d.writeConfig("Image",${JSON.stringify(next)});
 print("${marker}"+JSON.stringify({
   ok:String(d.readConfig("Image",""))===${JSON.stringify(next)}
 }));
})();`;
    return evaluate(script).ok===true;
}
function saveState(state,exclusive) {
    fs.mkdirSync(stateRoot,{recursive:true,mode:0o700});
    fs.chmodSync(stateRoot,0o700);
    const data=JSON.stringify(state,null,2)+"\n";
    if(exclusive){
        fs.writeFileSync(stateFile,data,{flag:"wx",mode:0o600});
        return;
    }
    const temp=stateFile+".tmp-"+process.pid;
    try {
        fs.writeFileSync(temp,data,{flag:"wx",mode:0o600});
        fs.renameSync(temp,stateFile);
    } catch(e) {
        try{fs.unlinkSync(temp)}catch(_){}
        throw e;
    }
}
function readState(current) {
    if (!fs.existsSync(stateFile)) return null;
    const state=JSON.parse(fs.readFileSync(stateFile,"utf8"));
    if (!state || state.version!==1 || state.desktopId!==current.id ||
        state.screen!==0 || typeof state.originalImage!=="string" ||
        !state.originalImage || typeof state.lastApplied!=="string")
        stop("el escritorio cambió desde el respaldo; no se modificó nada");
    return state;
}
function run() {
    // No leer ni modificar el escritorio hasta confirmar recursos originales.
    if(action==="check"){
        for(const theme of ["day","sunset","night"]) wallpaperSource(theme);
        const desktop=currentWallpaper();
        const existing=readState(desktop);
        if(existing && existing.lastApplied &&
            existing.lastApplied!==desktop.image)
            stop("el usuario cambió el fondo fuera de SmartBar; revisar manualmente");
        console.log("OK: 3 fondos originales verificados por SHA-256;");
        console.log("    un único escritorio KDE activo (imagen estática, pantalla 0).");
        console.log("    Sin modificaciones de KDE, panel, wallpaper o respaldo.");
        return;
    }
    const desired = ["day","sunset","night"].includes(action)
        ? wallpaperSource(action):"";
    const current=currentWallpaper();
    let state=readState(current);
    if (action==="undo" || action==="restore") {
        if (!state) stop("todavía no hay un fondo anterior que restaurar");
        if (!state.lastApplied || current.image!==state.lastApplied)
            stop("el wallpaper cambió externamente; no se sobrescribirá");
        const back=action==="undo" ? state.previousImage:state.originalImage;
        if (!back) stop("no hay imagen anterior registrada");
        if (!updateKde(current.id,current.image,back))
            stop("KDE no confirmó la restauración");
        state.lastApplied=back;
        state.previousImage="";
        state.lastTheme="";
        saveState(state,false);
        console.log(action==="undo" ? "Wallpaper anterior restaurado." :
                    "Wallpaper original del escritorio restaurado.");
        return;
    }
    if(!state){
        state={version:1,desktopId:current.id,screen:0,
            originalImage:current.image,originalFillMode:current.fillMode,
            originalPlugin:current.plugin,lastApplied:"",previousImage:"",
            lastTheme:"",createdAt:new Date().toISOString()};
        // Resguardar antes de cualquier escritura en KDE.
        saveState(state,true);
    } else if(state.lastApplied && current.image!==state.lastApplied) {
        stop("el usuario cambió el fondo fuera de SmartBar; no se sobrescribirá");
    }
    if(current.image===desired){
        state.previousImage=current.image;
        state.lastApplied=desired;
        state.lastTheme=action;
        saveState(state,false);
        console.log("Wallpaper del tema "+action+" ya estaba seleccionado.");
        return;
    }
    if(!updateKde(current.id,current.image,desired))
        stop("KDE no confirmó el nuevo wallpaper; no aplicar cambio visual");
    state.previousImage=current.image;
    state.lastApplied=desired;
    state.lastTheme=action;
    try{saveState(state,false)}
    catch(e){
        // El backup debe ser coherente con el estado real; intentar deshacer.
        updateKde(current.id,desired,current.image);
        throw e;
    }
    console.log("Wallpaper KDE aplicado: "+action+" (escritorio activo).");
}
try{run()}
catch(e){console.error("SmartBar wallpaper: "+e.message);process.exitCode=3}
