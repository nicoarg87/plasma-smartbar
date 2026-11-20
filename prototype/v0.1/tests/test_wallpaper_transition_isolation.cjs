"use strict";
// Ejercicio sin KDE ni motor QML: el botón de prueba debe mover SOLO las
// dos capas PNG, no escribir biblioteca, GIF, apariencia ni presets originales.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const root = path.resolve(__dirname, "..");
const viewer = fs.readFileSync(path.join(root,"preview_redimensionable.qml"),"utf8");
const settings = fs.readFileSync(path.join(root,"package/contents/ui/SoledadSettings.qml"),"utf8");
const defaults = fs.readFileSync(path.join(root,"package/contents/config/main.xml"),"utf8");
const funcs = ["changeSimulatedWallpaper","finishWallpaperFade","previewNextWallpaper",
               "wallpaperForTheme","startWallpaperFadeIfReady","abortWallpaperFade"];
function extract(name) {
    const start=viewer.indexOf("    function "+name+"(");
    assert(start>=0,"No existe "+name);
    const brace=viewer.indexOf("{",start);
    let depth=0;
    for(let i=brace;i<viewer.length;i++){
        if(viewer[i]==="{")depth++;
        if(viewer[i]==="}"&&--depth===0)return viewer.slice(start,i+1);
    }
    throw Error("Llaves inválidas en "+name);
}
const writes=[];
const delayed=[];
const ctx = {
    wallpaperShownTheme:"day",
    simulatedWallpaperTheme:"day",
    wallpaperPrimaryTheme:"day",
    wallpaperSecondaryTheme:"",
    wallpaperIncomingTheme:"",
    wallpaperIncomingLayer:"",
    wallpaperQueuedTheme:"",
    wallpaperActiveLayer:"primary",
    simulatedWallpaperEnabled:true,
    wallpaperFadeBusy:false,
    localPreviewSettings:{setValue:(k,v)=>writes.push([k,v]),sync:()=>writes.push(["sync"])},
    simulatedDesktopWallpaper:{opacity:1,status:1},
    incomingWallpaper:{opacity:0,status:1},
    wallpaperFade:{running:false,target:null,stop(){},start(){}},
    Image:{Ready:1},
    Qt:{callLater:fn=>delayed.push(fn),resolvedUrl:x=>x},
    console,
};
ctx.previewWindow=ctx;
for(const name of funcs)vm.runInNewContext(extract(name),ctx);
function advance(expect) {
    ctx.previewNextWallpaper();
    assert.equal(ctx.wallpaperIncomingTheme,expect,"Siguiente wallpaper equivocado");
    assert.equal(ctx.wallpaperFadeBusy,true);
    assert.equal(ctx.simulatedWallpaperTheme,"day","Demo cambia tema guardado");
    assert.equal(ctx.wallpaperShownTheme===expect,false,"Cambió antes de animar");
    ctx.finishWallpaperFade();
    assert.equal(ctx.wallpaperShownTheme,expect);
    assert.equal(ctx.wallpaperFadeBusy,false);
    assert.equal(ctx.wallpaperIncomingTheme,"");
    const visible = ctx.wallpaperActiveLayer==="primary"
        ? ctx.simulatedDesktopWallpaper : ctx.incomingWallpaper;
    const hidden = ctx.wallpaperActiveLayer==="primary"
        ? ctx.incomingWallpaper : ctx.simulatedDesktopWallpaper;
    assert.equal(visible.opacity,1);
    assert.equal(hidden.opacity,0);
    assert.deepEqual(writes,[],"Demo escribió configuración persistente");
}
advance("sunset");
advance("night");
advance("day");
assert.equal(ctx.wallpaperActiveLayer,"secondary");
assert(settings.includes('slot.length && settings.activateTheme(slot)'));
assert(settings.includes("readonly property var factoryDayPreset"));
assert(!viewer.slice(viewer.indexOf('function previewNextWallpaper()'),
                      viewer.indexOf('onSimulatedWallpaperEnabledChanged:')).includes('themeSnapshot'));
assert(viewer.includes('id: wallpaperDemoButton'));
assert(viewer.includes('readonly property int wallpaperFadeDurationMs: 800'));
assert(viewer.includes('fillMode: Image.Stretch'));
assert(viewer.includes('wallpaperFade.target = target'));
assert(!viewer.includes('property string wallpaperShownTheme: simulatedWallpaperTheme'),
    "El tema persistido no puede cambiar wallpaperShownTheme antes del fundido");
assert(!viewer.includes('property string wallpaperPrimaryTheme: simulatedWallpaperTheme'),
    "El fondo cargado debe mantenerse hasta que termine la transición");
assert(viewer.includes('property string wallpaperShownTheme:\\n        String(localPreviewSettings.value("simulatedWallpaperTheme", "day"))'.replace('\\n','\n')));

assert(viewer.includes('wallpaperIncomingLayer === "primary" ? -0.9 : -1'));
assert(viewer.includes('wallpaperIncomingLayer === "secondary" ? -0.9 : -1'));
assert(defaults.includes('<entry name="themeScheduleEnabled" type="Bool"><default>true</default></entry>'));
assert(!viewer.includes("plasma-apply-wallpaperimage"));
assert(!viewer.includes("wallpaperSignal.setValue("));
console.log("OK: Día → Atardecer → Noche → Día sin escrituras ni cambios de tema; doble búfer 800ms.");
