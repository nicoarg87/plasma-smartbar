"use strict";
// Los dos menús contextuales y el botón de ensayo del visor comparten
// la misma acción, sin guardar perfiles ni crear botones de barra.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const base=path.resolve(__dirname,"..");
const bar=fs.readFileSync(path.join(base,"package/contents/ui/SmartBarContent.qml"),"utf8");
const malvina=fs.readFileSync(path.join(base,"package/contents/ui/MalvinaRuntimeIsland.qml"),"utf8");
const gripMenu=fs.readFileSync(path.join(base,"package/contents/ui/SoledadGripMenu.qml"),"utf8");
const visor=fs.readFileSync(path.join(base,"preview_redimensionable.qml"),"utf8");
const main=fs.readFileSync(path.join(base,"package/contents/ui/main.qml"),"utf8");
const label='text: "siguiente tema y wallpaper"';
assert.equal(malvina.split(label).length-1,1,
  "El menú Malvina conserva la opción de siguiente wallpaper");
assert.equal(gripMenu.split('text: "Pasar al tema siguiente"').length-1,1,
  "El menú del agarre conserva el cambio al siguiente tema del pack");
assert.equal(visor.split(label).length-1,1,
  "El botón de prueba mantiene su etiqueta");
assert(!bar.includes("Probar transición de tema y wallpaper"));
assert(!visor.includes("Probar transición de tema y wallpaper"));
assert(malvina.includes("id: launcherContextMenu"));
assert(malvina.includes("enabled: host.themeWallpaperPreviewAvailable"));
assert(malvina.includes("onTriggered: host.triggerThemeWallpaperPreview()"));
assert(gripMenu.includes("onTriggered: host.passToNextPackTheme()"));
assert(bar.includes("signal requestThemeWallpaperPreview()"));
assert(malvina.includes("visible: host.themeScheduleRuntimeEnabled"));
assert(visor.includes("onRequestThemeWallpaperPreview: previewWindow.previewNextWallpaper()"));
assert(visor.includes("onClicked: bar.triggerThemeWallpaperPreview()"));
assert(visor.includes("themeWallpaperPreviewAvailable: previewWindow.simulatedWallpaperEnabled"));
assert(visor.includes("!previewWindow.wallpaperFadeBusy"));
assert(visor.includes("function previewNextWallpaper()"));
assert(main.includes("themeScheduleRuntimeEnabled: false"),
       "El panel real no debe exponer la prueba no disponible");
const start=bar.indexOf("    function triggerThemeWallpaperPreview()");
assert(start>=0);
const end=bar.indexOf("\n    }",start);
assert(end>start);
const context={
  themeScheduleRuntimeEnabled:true,
  themeWallpaperPreviewAvailable:true,
  calls:0,
  requestThemeWallpaperPreview: () => { context.calls++ }
};
context.root=context;
vm.runInNewContext(bar.slice(start,end+6)+";triggerThemeWallpaperPreview()",context);
assert.equal(context.calls,1,"Solo una transición por clic");
context.themeWallpaperPreviewAvailable=false;
vm.runInNewContext(bar.slice(start,end+6)+";triggerThemeWallpaperPreview()",context);
assert.equal(context.calls,1,"Deshabilitada mientras se ejecuta un fundido");
context.themeWallpaperPreviewAvailable=true;
context.themeScheduleRuntimeEnabled=false;
vm.runInNewContext(bar.slice(start,end+6)+";triggerThemeWallpaperPreview()",context);
assert.equal(context.calls,1,"No activar en el panel real");
console.log("OK: dos menús y un botón con una sola transición, sin duplicar lógica.");
