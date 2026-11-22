"use strict";
// Análisis geométrico SOLO LECTURA: no equivale a overlay real de KWin.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "..");
const moduleFile = path.join(base, "package/contents/ui/KwinTopEdgeProbe.js");
const source = fs.readFileSync(moduleFile, "utf8");
const preview = fs.readFileSync(path.join(base,"preview_redimensionable.qml"),"utf8");
const main = fs.readFileSync(path.join(base,"package/contents/ui/main.qml"),"utf8");
assert(source.startsWith(".pragma library\n"));
const api = {};
vm.runInNewContext(source.replace(/^\.pragma library\s*/, ""), api);
const screen = {x: 0, y: 0, width: 1920, height: 1080};
const crossing = {x: 0, y: 0, width: 1920, height: 1080};
const reserved = {x: 0, y: 48, width: 1920, height: 1032};
assert.equal(api.inspect(crossing,screen,40,true,false).status,"potential");
assert.equal(api.inspect(crossing,screen,40,true,false).intersectsTopStrip,true);
assert.equal(api.inspect(reserved,screen,40,true,false).status,"separate");
assert.equal(api.inspect(crossing,screen,40,true,true).status,"fullscreen");
assert.equal(api.inspect(crossing,screen,40,false,false).status,"normal-top");
assert.equal(api.inspect(reserved,screen,40,false,false).status,"normal");
assert.equal(api.inspect(null,screen,40,true,false).status,"unknown");
assert.equal(api.inspect(crossing,null,40,true,false).status,"unknown");
assert.equal(api.inspect({...crossing,width:0},screen,40,true,false).status,"unknown");
assert.equal(api.inspect(crossing,screen,NaN,true,false).status,"unknown");
assert.equal(api.inspect(crossing,screen,-10,true,false).status,"unknown");
const shiftedScreen = {x:-1920,y:0,width:1920,height:1080};
assert.equal(api.inspect({x:-1920,y:35,width:1920,height:1045},
    shiftedScreen,40,true,false).status,"potential");
assert.equal(api.inspect({x:0,y:0,width:1920,height:1080},
    shiftedScreen,40,true,false).status,"separate");
assert.match(api.summary("Brave",api.inspect(crossing,screen,40,true,false)),/pestañas SIN verificar/);
assert.match(api.summary("Brave",api.inspect(null,screen,40,true,false)),/sin verificar/);
assert.match(api.summary("Steam",api.inspect(crossing,screen,40,true,true)),/barra debe ocultarse/);
// Integración pasiva en la ventana independiente; no en el panel KDE.
for (const marker of [
    'import "package/contents/ui/KwinTopEdgeProbe.js" as KwinTopEdgeProbe',
    'readonly property var observedWindowGeometry: model.Geometry',
    'readonly property var observedScreenGeometry: model.ScreenGeometry',
    'onObservedWindowGeometryChanged: previewWindow.scheduleRealWindowRefresh()',
    'KwinTopEdgeProbe.inspect(',
    'KwinTopEdgeProbe.summary(',
    'active.appId !== "org.qt-project.qml6"',
    'Pestañas y clics NO verificados.',
    'trackedExternalTopStatus: "unknown"'
]) assert(preview.includes(marker),"Falta lectura segura: "+marker);
assert(!main.includes("KwinTopEdgeProbe") && !main.includes("trackedExternalTopStatus"));
assert(!/(?:requestActivate|requestClose|requestToggle\w*|setGeometry|setPosition)\s*\(/.test(source),
       "El análisis nunca debe modificar ventanas KDE");
console.log("OK: geometría KDE conservadora, pantalla desplazada, fullscreen, sin superponer ni alterar panel.");
