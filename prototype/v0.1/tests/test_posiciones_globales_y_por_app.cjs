"use strict";
// Test sin KDE: modelo de posición general + excepciones sin romper perfiles.
// La UI LayerShell/Wayland debe verificarse aparte en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(base,p), "utf8");
const js = read("package/contents/ui/SoledadPositionProfiles.js")
    .replace(/^\.pragma library\s*/, "");
const profiles = new Function(js + "\nreturn {defaultFromBrave,baselineFromSettings,"+
    "withGeneralBaseline,resolveForApp,saveProfile,removeProfile};")();
const source = JSON.stringify({"brave-browser": 270, "steam": 390});
assert.equal(profiles.defaultFromBrave(source), 270,
             "La ubicación existente de Brave debe ser la referencia general");
assert.equal(profiles.baselineFromSettings("", source), 270);
assert.equal(profiles.baselineFromSettings("200", source), 200);
assert.equal(profiles.baselineFromSettings("-2", source), 270);
assert.equal(profiles.baselineFromSettings("invalido", source), 270);
assert.equal(profiles.resolveForApp(source, "org.kde.dolphin", true,270,900),270);
assert.equal(profiles.resolveForApp(source, "steam", true,270,900),390);
assert.equal(profiles.resolveForApp(source, "steam", false,270,900),270);
const withDefault = profiles.withGeneralBaseline(
    [{appId:"steam",maximized:true},{appId:"org.kde.dolphin",maximized:true}],
    source,270);
assert.equal(withDefault.steam,390);
assert.equal(withDefault["org.kde.dolphin"],270);
assert.equal(profiles.defaultFromBrave(source),270,
             "La referencia de Brave no debe alterarse");
const saved = profiles.saveProfile(source,"org.kde.dolphin",540,900);
assert.equal(JSON.parse(saved)["org.kde.dolphin"],540);
assert.equal(JSON.parse(saved).steam,390);
assert.equal(JSON.parse(saved)["brave-browser"],270);
const removed = JSON.parse(profiles.removeProfile(saved,"org.kde.dolphin"));
assert(!Object.hasOwn(removed,"org.kde.dolphin"));
assert.equal(removed.steam,390);

const bar=read("package/contents/ui/SmartBarContent.qml");
const editor=read("package/contents/ui/SoledadPositionEditor.qml");
const preview=read("preview_soledad_input_mask.qml");
for (const snippet of [
    "Fijar esta posición para todas las aplicaciones",
    "Personalizar posición por aplicación…",
    "SoledadPositionEditor {",
    "signal requestGeneralSoledadOffsetChange(real offset)",
    "function storeRealPositionFor(appId, offset)",
    "function forgetRealPositionFor(appId)",
    "function saveGeneralSoledadPosition()",
    "property bool soLeftClickOpensLauncher: true"
]) assert(bar.includes(snippet),"Falta en SmartBarContent: "+snippet);
assert(!bar.includes("id: gripMalvinaVisibility"),
       "No volver a añadir el control duplicado de Malvina");
assert(editor.includes("model: editor.realTasksModel"));
assert(editor.includes("import QtQuick.Layouts"));
assert(!editor.split("\n").some(line =>
    ["QQC2.RowLayout", "QQC2.ColumnLayout", "QQC2.GridLayout",
     "QQC2.StackLayout"].some(type => line.includes(type))),
    "Los Layouts pertenecen a QtQuick.Layouts, no QtQuick.Controls");
assert.equal(editor.split("\n").filter(line => line.trim() === "RowLayout {").length, 2,
             "Los dos paneles horizontales deben usar RowLayout de QtQuick.Layouts");
assert(editor.includes("editor.savedIds"));
assert(editor.includes("positionSlider.value"));
assert(editor.includes("previewRequested(previousOffset)"),
       "Cancelar una vista previa debe restaurar la posición");
assert(preview.includes('profileSettings.value("generalSoledadOffsetV1", "")'));
assert(preview.includes('profileSettings.setValue("generalSoledadOffsetV1", probe.generalOffset)'));
assert(preview.includes("probe.allPositionProfiles(currentRows)"));
assert(preview.includes("bar.setIslandOffset(generalOffset)"));
console.log("OK: referencia Brave, anclaje general, excepciones por app y editor");
