// Selector compacto: un desplegable con Atardecer, Noche, Día y
// temas personales, sin ventanas de tarjetas ni acciones duplicadas.
// Ejecutar: node prototype/v0.1/tests/test_theme_selector.cjs
"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const base=path.resolve(__dirname,"..");
const ui=fs.readFileSync(path.join(base,"package/contents/ui/SoledadSettings.qml"),"utf8");
const bar=fs.readFileSync(path.join(base,"package/contents/ui/SmartBarContent.qml"),"utf8");
const preview=fs.readFileSync(path.join(base,"preview_redimensionable.qml"),"utf8");
const main=fs.readFileSync(path.join(base,"package/contents/ui/main.qml"),"utf8");
const config=fs.readFileSync(path.join(base,"package/contents/config/main.xml"),"utf8");
assert(ui.includes("id: themeSelectorButton"));
assert(ui.includes("id: themeOptionsPopup"));
assert(ui.includes("id: themeOptionsColumn"));
assert(ui.includes("CloseOnPressOutsideParent"));
assert(ui.includes('index === 0 ? "Atardecer"'));
assert(ui.includes('index === 1 ? "Noche"'));
assert(ui.includes('index === 2 ? "Día"'));
assert(ui.includes("settings.factoryDayAvailable"));
assert(ui.includes("settings.themeImageSource"));
assert(ui.includes("QQC2.ScrollBar.vertical"));
assert(!ui.includes("id: themesDropdownButton"));
assert(!ui.includes('text: "Guardar cambios actuales en Día"'));
assert(!ui.includes("function saveCurrentDayTheme("));
assert(ui.includes('text: "Crear tema nuevo"'));
assert(ui.includes("settings.saveNamedTheme()"));
for(const s of [ui,bar,main,config,preview])
  assert(s.includes("themeLibraryJson"),"Falta biblioteca de temas");
assert(ui.includes('const themeSlots = ["dayPrevious", "day", "night", "custom", "library"]'));
assert(bar.includes("soledadSettings.themeLibraryJson = root.themeLibraryJson"));
assert(preview.includes('slot === "library" ? "themeLibraryJson"'));
assert(main.includes('slot === "library") Plasmoid.configuration.themeLibraryJson = data'));
assert(config.includes('<entry name="themeLibraryJson" type="String"><default>[]</default></entry>'));

function extract(name) {
    const index=ui.indexOf("    function "+name+"(");
    assert(index>=0,"Falta función "+name);
    const begin=ui.indexOf("{",index);
    let depth=0;
    for(let i=begin;i<ui.length;i++) {
        if(ui[i]==="{")++depth;
        if(ui[i]==="}"&&--depth===0) return ui.slice(index,i+1);
    }
    throw Error("Llaves incompletas "+name);
}
const state={
    themeLibraryJson:"[]",newThemeName:"Día",themeStatus:"",
    pendingThemeChanges:{},baselineLoaded:true,lastAppliedSettings:{},
    editableSettingsKeys:["themeLibraryJson"],editableColorKeys:[],
    alignmentEdited:false,pendingAlignAction:"",
    appliedLabel:{text:""},refreshOutlinePreview(){},
    themeSnapshot(){return JSON.stringify({version:1,logoMode:"custom",filePath:"file:///original.gif"})},
    appliedCount:0
};
state.settings=state;
const script=[
    extract("preferenceCopy"),extract("captureSettingsBaseline"),
    extract("stageThemeSlot"),extract("parseThemeLibrary"),
    extract("saveNamedTheme"),extract("namedThemeIndex"),extract("dayThemeIndex"),
    'Object.defineProperty(settings,"savedThemeLibrary",{get:function(){return parseThemeLibrary(themeLibraryJson)}})',
    'applyChanges = function(){appliedCount++;captureSettingsBaseline()}',
    'saveNamedTheme()',
    'newThemeName="Noche personalizada";saveNamedTheme()',
    'newThemeName="Día 2";saveNamedTheme()',
    'if(dayThemeIndex()!==0)throw Error("No se halló Día")',
    'if(parseThemeLibrary(themeLibraryJson).length!==3)throw Error("Se perdieron temas")'
].join("\n");
vm.runInNewContext(script,state);
assert.equal(state.appliedCount,3);
assert.equal(JSON.parse(state.themeLibraryJson)[0].name,"Día");
assert.equal(JSON.parse(state.themeLibraryJson)[1].name,"Noche personalizada");
console.log("OK: selector único, Día inmutable por separado y biblioteca personal persistente.");
