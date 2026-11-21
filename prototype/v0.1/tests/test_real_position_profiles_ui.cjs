"use strict";
// Regresión para el puente experimental: no acredita funcionamiento Qt/KWin.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "..");
const source = fs.readFileSync(path.join(base,"package/contents/ui/RealActiveWindow.js"),"utf8");
const bar = fs.readFileSync(path.join(base,"package/contents/ui/SmartBarContent.qml"),"utf8");
const preview = fs.readFileSync(path.join(base,"preview_redimensionable.qml"),"utf8");
const main = fs.readFileSync(path.join(base,"package/contents/ui/main.qml"),"utf8");
assert(source.startsWith(".pragma library\n"));
const api = {};
vm.runInNewContext(source.replace(/^\.pragma library\s*/, ""),api);
const steam={appId:"com.valvesoftware.Steam",appName:"Steam",maximized:true,
             fullscreen:false,known:true};
const viewer={appId:"org.qt-project.qml6",appName:"qml6",maximized:false,
              fullscreen:false,known:true};
const snapshot = (value)=>JSON.parse(JSON.stringify(value));
assert.deepEqual(snapshot(api.rememberExternal(steam,viewer,viewer.appId)),steam);
assert.deepEqual(snapshot(api.rememberExternal(steam,null,viewer.appId)),steam);
assert.equal(api.rememberExternal(steam,{...steam,maximized:false},viewer.appId).maximized,false);
assert.equal(api.rememberExternal(steam,{...steam,appId:"com.brave.Browser"},viewer.appId).appId,"com.brave.Browser");
assert.equal(api.rememberExternal(null,viewer,viewer.appId).known,false);
for(const expected of [
    'realTrackedAppId: previewWindow.useRealWindowTasks',
    'realTrackedMaximized: previewWindow.useRealWindowTasks',
    'realPositionProfilesJson: previewWindow.realPositionProfilesJson',
    'soledadRealPositionProfilesV1',
    'RealActiveWindow.rememberExternal(',
    'bar.applyRealPositionProfile()',
    'onRequestRealPositionProfilesChange: function(json)'
]) assert(preview.includes(expected),"Falta integración visor: "+expected);
for(const expected of [
    'function applyRealPositionProfile()',
    'function saveRealPositionProfile()',
    'function deleteRealPositionProfile()',
    'function saveDemoPositionProfile()',
    'function deleteDemoPositionProfile()',
    'demoWindowControlsEnabled && usingRealTasks &&',
    'realTrackedKnown && realTrackedMaximized && !realTrackedFullscreen',
    'text: "Recordar esta posición para " + root.realTrackedAppName',
    'text: "Olvidar posición de " + root.realTrackedAppName'
]) assert(bar.includes(expected),"Falta integración SO: "+expected);
const from = bar.indexOf('    // Última aplicación EXTERNA,');
const to = bar.indexOf('    property var realTaskModel:',from);
assert(from>0 && to>from);
const isolated = bar.slice(from,to);
assert(!/requestActivate\s*\(|requestClose\s*\(|requestToggle\w+\s*\(/.test(isolated),
    "La memoria real no debe activar/cerrar/minimizar ventanas KDE");
assert(!main.includes("soledadRealPositionProfilesV1") &&
       !main.includes("realTrackedAppId"),
       "El panel KDE no debe adoptar aún la integración experimental");
console.log("OK: perfil Steam real recordable en visor Qt, foco conservado y panel aislado.");
