"use strict";
// Un clic = un fundido. Simulación aislada: sin modificar perfil, GIF ni KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const root = path.resolve(__dirname,"..");
const read = p => fs.readFileSync(path.join(root,p),"utf8");
const viewer = read("preview_redimensionable.qml");
const settings = read("package/contents/ui/SoledadSettings.qml");
const bar = read("package/contents/ui/SmartBarContent.qml");
const cfg = read("package/contents/config/main.xml");
const raw = read("package/contents/ui/WallpaperFadeDuration.js")
  .replace(/^\.pragma library\s*/, "");
const duration = vm.createContext({});
vm.runInContext(raw,duration);
assert.equal(duration.durationMs(3,"seconds"),3000);
assert.equal(duration.durationMs(2,"minutes"),120000);
assert.equal(duration.durationMs(1,"hours"),3600000);
assert.equal(duration.durationMs(24,"hours"),86400000);
for(const [count,unit] of [[0,"seconds"],[25,"hours"],[241,"minutes"],[3601,"seconds"],[1.5,"seconds"],[-1,"hours"]])
  assert.equal(duration.valid(count,unit),false,count+" "+unit);
assert(settings.includes('text: "Fundido del wallpaper"'));
assert(settings.includes('model: ["Segundos", "Minutos", "Horas"]'));
assert(settings.includes('settings.setWallpaperFade(amount,settings.wallpaperFadeUnit)'));
assert(settings.includes('saveWallpaperFadeRequested(amount,unit)'));
assert(bar.includes("onSaveWallpaperFadeRequested: function(amount, unit)"));
assert(viewer.includes('onRequestWallpaperFadeChange: function(amount, unit)'));
assert(viewer.includes('localPreviewSettings.setValue("wallpaperFadeAmount",amount)'));
assert(viewer.includes('localPreviewSettings.setValue("wallpaperFadeUnit",unit)'));
assert(viewer.includes('WallpaperFadeDuration.durationMs(demoWallpaperFadeAmount,demoWallpaperFadeUnit)'));
assert(cfg.includes('name="wallpaperFadeAmount" type="Int"><default>3</default>'));
assert(cfg.includes('name="wallpaperFadeUnit" type="String"><default>seconds</default>'));
assert(!viewer.includes("wallpaperDemoHoldTimer"),"No debe haber recorrido automático");
assert(!viewer.includes("wallpaperDemoRemaining"),"Un clic no inicia una cadena");

function extract(name) {
  const start=viewer.indexOf("    function "+name+"(");
  assert(start>=0,name+" no existe");
  const brace=viewer.indexOf("{",start);
  let depth=0;
  for(let i=brace;i<viewer.length;i++) {
    if(viewer[i]==="{")depth++;
    if(viewer[i]==="}"&&--depth===0) return viewer.slice(start,i+1);
  }
  throw Error("Cierre de función ausente "+name);
}
const funcs=["changeSimulatedWallpaper","finishWallpaperFade","previewNextWallpaper",
             "abortWallpaperFade","wallpaperForTheme","startWallpaperFadeIfReady"];
const writes=[],later=[],colorPreviewCalls=[];
const ctx={
  simulatedWallpaperTheme:"day", wallpaperShownTheme:"day",
  wallpaperPrimaryTheme:"day",wallpaperSecondaryTheme:"",
  wallpaperIncomingTheme:"", wallpaperIncomingLayer:"",
  wallpaperQueuedTheme:"",wallpaperActiveLayer:"primary",
  wallpaperFadeBusy:false,simulatedWallpaperEnabled:true,
  wallpaperDemoPendingTheme:"",
  bar:{previewBarThemeColors:theme=>{colorPreviewCalls.push(theme);return true}},
  wallpaperFade:{running:false,target:null,stop(){},start(){}},
  simulatedDesktopWallpaper:{opacity:1,status:1},
  incomingWallpaper:{opacity:0,status:1},
  localPreviewSettings:{setValue:(...a)=>writes.push(a),sync:()=>writes.push(["sync"])},
  Image:{Ready:1},Qt:{callLater:f=>later.push(f),resolvedUrl:x=>x}
};
ctx.previewWindow=ctx;
const scope=vm.createContext(ctx);
for(const f of funcs)vm.runInContext(extract(f),scope);
for(const next of ["sunset","night","day"]) {
  ctx.previewNextWallpaper(); // exactamente UN cambio
  assert.equal(ctx.wallpaperDemoPendingTheme,next);
  ctx.startWallpaperFadeIfReady(); // dispara ambas animaciones al cargar el PNG
  assert.equal(ctx.wallpaperDemoPendingTheme,"");
  assert.equal(ctx.wallpaperIncomingTheme,next);
  assert.equal(ctx.wallpaperFadeBusy,true);
  assert.equal(ctx.simulatedWallpaperTheme,"day");
  assert.notEqual(ctx.wallpaperShownTheme,next);
  ctx.finishWallpaperFade();
  assert.equal(ctx.wallpaperShownTheme,next);
  assert.equal(ctx.wallpaperFadeBusy,false);
  assert.equal(ctx.wallpaperIncomingTheme,"");
  assert.deepEqual(writes,[],"El botón de prueba guardó una preferencia");
}
assert.equal(ctx.wallpaperShownTheme,"day");
assert.deepEqual(colorPreviewCalls,["sunset","night","day"],
  "Cada clic debe previsualizar también una sola paleta de islas");
// Con horas de transición, un cambio automático/manual no debe quedar en cola.
ctx.previewNextWallpaper(); // fundido hacia Atardecer iniciado
ctx.startWallpaperFadeIfReady();
ctx.wallpaperQueuedTheme="sunset"; // solicitud previa obsoleta
ctx.changeSimulatedWallpaper("night",true);
assert.equal(ctx.wallpaperQueuedTheme,"");
assert.equal(ctx.wallpaperIncomingTheme,"night");
assert.equal(ctx.wallpaperFadeBusy,true);
assert.deepEqual(writes,[["simulatedWallpaperTheme","night"],["sync"]]);
assert.deepEqual(colorPreviewCalls,["sunset","night","day","sunset"],
  "El evento real no debe disparar una vista previa del siguiente color");
assert(!writes.some(([key])=>/themeLibrary|themeDay|themeNight|appearanceV1|Schedule|Factory/.test(key)));
assert(settings.includes("readonly property var factoryDayPreset"));
assert(settings.includes('slot.length && settings.activateTheme(slot)'));
assert(viewer.includes('id: wallpaperDemoButton'));
assert(viewer.includes('duration: previewWindow.wallpaperFadeDurationMs'));
assert(viewer.includes('fillMode: Image.Stretch'));
assert(!viewer.includes("plasma-apply-wallpaperimage"));
console.log("OK: un clic un fundido, 3 s por defecto, minutos/horas, sin alterar temas ni panel KDE.");
