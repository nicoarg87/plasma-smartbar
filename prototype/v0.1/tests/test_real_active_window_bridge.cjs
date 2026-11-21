"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "..");
const moduleSource = fs.readFileSync(path.join(base,
    "package/contents/ui/RealActiveWindow.js"), "utf8");
const preview = fs.readFileSync(path.join(base, "preview_redimensionable.qml"), "utf8");
const bar = fs.readFileSync(path.join(base, "package/contents/ui/SmartBarContent.qml"), "utf8");
const plasma = fs.readFileSync(path.join(base, "package/contents/ui/main.qml"), "utf8");
assert(moduleSource.startsWith(".pragma library\n"));
const api = {};
vm.runInNewContext(moduleSource.replace(/^\.pragma library\s*/, ""), api);
const norm = x => JSON.parse(JSON.stringify(x));
const steam = {appId:"com.valvesoftware.Steam", appName:"Steam", active:true,
               maximized:true, fullscreen:false, minimized:false};
assert.deepEqual(norm(api.resolve([steam])), {appId:"com.valvesoftware.Steam",
    appName:"Steam", maximized:true, fullscreen:false, known:true});
assert.equal(api.resolve([{...steam,active:false}]).known, false);
assert.equal(api.resolve([{...steam,minimized:true}]).known, false);
assert.equal(api.resolve([steam,{...steam,appId:"com.brave.Browser"}]).known, false);
assert.equal(api.resolve([{...steam,appId:""}]).known, false);
assert.equal(api.resolve([{...steam,maximized:false}]).maximized, false);
assert.equal(api.resolve([{...steam,fullscreen:true}]).fullscreen, true);
assert.equal(api.resolve(null).known, false);
for (const part of [
    'groupMode: TaskManager.TasksModel.GroupDisabled',
    'id: realTaskObserver',
    'model: kdeIndividualTasks',
    'readonly property bool observedActive: model.IsActive === true',
    'readonly property bool observedMaximized: model.IsMaximized === true',
    'readonly property string observedAppId: String(model.AppId || "")',
    'RealActiveWindow.resolve(rows)',
    'onObservedActiveChanged: previewWindow.scheduleRealWindowRefresh()',
    'onObservedMaximizedChanged: previewWindow.scheduleRealWindowRefresh()',
    'realObservedAppId: previewWindow.useRealWindowTasks',
    'realObservedMaximized: previewWindow.useRealWindowTasks'
]) assert(preview.includes(part), "Falta lectura: "+part);
assert(preview.includes('groupMode: TaskManager.TasksModel.GroupApplications'),
    "SO debe conservar su lista agrupada");
assert(bar.includes('property string realObservedAppId: ""'));
assert(bar.includes('property bool realObservedMaximized: false'));
assert(!bar.includes('onRealObservedAppIdChanged:'),
    "El puente todavía NO debe cambiar posición");
assert(!plasma.includes('RealActiveWindow.js'),
    "Este paso no activa el observador nuevo en el plasmoide instalado");
assert(!/requestActivate\s*\(|requestClose\s*\(|requestToggleMaximized\s*\(/.test(moduleSource),
    "No manipular ventanas KDE");
console.log("OK: AppId/foco/max de ventana individual, pasivo y sin afectar SO ni panel.");
