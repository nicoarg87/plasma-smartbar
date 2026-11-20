"use strict";
// Regresión: cada wallpaper de la prueba corresponde a su propio GIF/imagen
// de SO y su paleta, sin mutar los temas de fábrica ni el escritorio real.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const base=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(base,p),"utf8");
const settings=read("package/contents/ui/SoledadSettings.qml");
const bar=read("package/contents/ui/SmartBarContent.qml");
const btn=read("package/contents/ui/IslandButton.qml");
const preview=read("preview_redimensionable.qml");
function extract(source,name) {
  const from=source.indexOf("    function "+name+"(");
  assert(from>=0,"No existe "+name);
  const start=source.indexOf("{",from);
  let depth=0;
  for(let i=start;i<source.length;i++) {
    if(source[i]==="{")depth++;
    if(source[i]==="}" && --depth===0) return source.slice(from,i+1);
  }
  throw Error("Llaves incorrectas: "+name);
}
assert.equal((btn.match(/QQC2\.Button \{/g)||[]).length,1,"No crear botones extras");
assert(btn.includes("function beginArtworkPreview(art, durationMs)"));
assert(btn.includes("function beginActualArtworkFade(durationMs)"));
assert(btn.includes("renderedPreviewOpacityA + renderedPreviewOpacityB"));
assert(btn.includes("model: 2"),"Un GIF saliente y otro entrante");
assert(btn.includes("animateGif: !!artworkLayer.art.animated"));
assert(btn.includes("cropShape: artworkLayer.art.shape"));
assert(btn.includes("artworkLayer.art.textBackgroundImage"));
assert(bar.includes("soButton.beginArtworkPreview(art,artDuration)"));
assert(bar.includes("barThemeTransitionEnabled ? themeColorsDurationMs : 1"),
       "El apagado del efecto debe afectar también la imagen SO");
assert(bar.includes("soButton.beginActualArtworkFade(themeColorsDurationMs)"));
assert(bar.includes("WallpaperFadeDuration.durationMs(wallpaperFadeAmount, wallpaperFadeUnit)"));
assert(preview.includes("bar.previewThemeAvailable(next)"));
assert(preview.includes("!bar.previewBarThemeColors(wallpaperIncomingTheme)"));
assert(!preview.includes("plasma-apply-wallpaperimage"));

const named=vm.createContext({savedThemeLibrary:[
 {name:"Día",jsonData:"day"},{name:"Atardecer",jsonData:"sunset"},
 {name:"Noche",jsonData:"night"}]});
vm.runInContext(extract(settings,"namedThemeIndex"),named);
assert.equal(named.namedThemeIndex("day"),0);
assert.equal(named.namedThemeIndex("sunset"),1);
assert.equal(named.namedThemeIndex("night"),2);
assert.equal(named.namedThemeIndex("unknown"),-1);
named.savedThemeLibrary[1].name="Noche personalizada";
assert.equal(named.namedThemeIndex("sunset"),-1,"No inventar coincidencias");

const schedule=vm.createContext({soledadSettings:{
 factoryDayAvailable:false,factorySunsetAvailable:false,factoryNightAvailable:false,
 namedThemeIndex:t=>({day:0,sunset:1,night:2}[t]??-1),
 themeDayJson:"",themeNightJson:""
}});
vm.runInContext(extract(bar,"scheduledThemeSlot"),schedule);
assert.equal(schedule.scheduledThemeSlot("day"),"library:0");
assert.equal(schedule.scheduledThemeSlot("sunset"),"library:1");
assert.equal(schedule.scheduledThemeSlot("night"),"library:2");
schedule.soledadSettings.factoryNightAvailable=true;
assert.equal(schedule.scheduledThemeSlot("night"),"night","Fábrica tiene prioridad");
schedule.soledadSettings.factoryNightAvailable=false;
schedule.soledadSettings.namedThemeIndex=()=>-1;
schedule.soledadSettings.themeNightJson="legacy";
assert.equal(schedule.scheduledThemeSlot("night"),"nightLegacy","Conservar respaldos");

const art=vm.createContext({
 defaultSoLogo:"file:///assets/so-tropical.gif",
 soButton:{frameShape:"capsule"},soLogoShape:"square",
 soLogoFitMode:"stretch",soLogoZoom:1,soLogoPanX:0,
 soLogoPanY:0,soLogoRotation:0,
 Qt:{resolvedUrl:s=>"file:///assets/"+s}
});
vm.runInContext(extract(bar,"previewArtworkFromTheme"),art);
const gif=art.previewArtworkFromTheme({
 logoMode:"custom",filePath:"file:///home/test/tarde.gif",enableGif:true,
 soButtonFrameShape:"capsule",shape:"square",cropFitMode:"stretch",
 cropZoom:1.25,cropPanX:0.2,soTextLabel:"SO"});
assert.equal(gif.image,"file:///home/test/tarde.gif");
assert.equal(gif.animated,true);
assert.equal(gif.fit,"stretch");
assert.equal(gif.zoom,1.25);
assert.equal(gif.panX,0.2);
assert.equal(gif.shape,"capsule");
const textTheme=art.previewArtworkFromTheme({
 logoMode:"text",soTextLabel:"SOL",soTextColor:"#fafafa",
 soTextBackgroundImage:"file:///texto.png"});
assert.equal(textTheme.mode,"text");
assert.equal(textTheme.label,"SOL");
assert.equal(textTheme.textBackgroundImage,"file:///texto.png");
const packed=art.previewArtworkFromTheme({
 logoMode:"custom",assetFile:"factory-night-logo.gif"});
assert.equal(packed.image,"file:///assets/assets/factory-night-logo.gif");
assert.equal(art.previewArtworkFromTheme({logoMode:"custom",filePath:""}),null,
             "Si falta imagen auténtica, no inventar otra");
console.log("OK: Día/Atardecer/Noche resuelven el tema exacto, funden logo/GIF y respetan fábricas.");
