// Interfaz de temas compacta, contraída al entrar, con scroll y biblioteca
// personal persistente sin reemplazar los temas ya existentes.
// Ejecutar: node prototype/v0.1/tests/test_theme_selector.cjs
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const root = path.resolve(__dirname, "..");
const ui = fs.readFileSync(path.join(root, "package/contents/ui/SoledadSettings.qml"),"utf8");
const bar = fs.readFileSync(path.join(root, "package/contents/ui/SmartBarContent.qml"),"utf8");
const preview = fs.readFileSync(path.join(root,"preview_redimensionable.qml"),"utf8");
const main = fs.readFileSync(path.join(root,"package/contents/ui/main.qml"),"utf8");
const config = fs.readFileSync(path.join(root,"package/contents/config/main.xml"),"utf8");

assert(ui.includes("id: themesDropdownButton"));
assert(ui.includes("property bool themeChooserExpanded: false"));
assert(ui.includes('function showThemes() { navigationGroup = "themes"; currentTab = 4; themeChooserExpanded = false; factoryToolsExpanded = false }'));
assert(ui.includes('text: settings.themeChooserExpanded'));
assert(ui.includes('onClicked: settings.themeChooserExpanded = !settings.themeChooserExpanded'));
assert(ui.includes("id: themeListScroll"));
assert(ui.includes("property bool factoryToolsExpanded: false"));
assert(ui.includes("settings.factoryToolsExpanded = !settings.factoryToolsExpanded"));
assert(ui.includes("visible: settings.factoryToolsExpanded && !settings.factorySunsetAvailable"));
assert(ui.includes("visible: settings.themeChooserExpanded"));
assert(ui.includes("QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn"));
assert(ui.includes('text: "Guardar tema"'));
assert(ui.includes("settings.saveNamedTheme()"));
assert(ui.includes("placeholderText: \"Nombre: Mi tema, Día, Atardecer...\""));
assert(ui.includes("model: settings.savedThemeLibrary"));
assert(ui.includes("settings.restoreNamedTheme(index)"));
assert(ui.includes("themeChooserExpanded = false; factoryToolsExpanded = false; discardPendingEdits()"));
assert(!ui.includes('text: "Actualizar Atardecer con estética actual…"'));
const themeArea = ui.substring(ui.indexOf("id: themesScroll"),ui.indexOf("// Pie fijo:", ui.indexOf("id: themesScroll")));
assert(themeArea.includes("id: themeListScroll"));
assert(!themeArea.includes("Layout.preferredHeight: 270"),"Volvió una tarjeta del mosaico");
assert(!themeArea.includes("Layout.preferredHeight: 275"),"Volvió una tarjeta del mosaico");
assert(themeArea.includes("TUS TEMAS GUARDADOS"));
assert(themeArea.includes("TEMAS DE FÁBRICA"));
assert(themeArea.includes("Día · tema de fábrica todavía no definido"));
assert(themeArea.includes("Mi predeterminada personal (ya guardada)"));
assert(themeArea.includes("Mi estética favorita (ya guardada)"));
assert(themeArea.includes("Atardecer guardado anteriormente"));
assert(themeArea.includes("Atardecer anterior · respaldo histórico"));
assert(themeArea.includes("Noche guardada anteriormente"));
assert(themeArea.includes("Personalizado guardado"));
assert(themeArea.includes('enabled: settings.factorySunsetAvailable'));
assert(themeArea.includes('enabled: settings.factoryNightAvailable'));
assert(!themeArea.includes("onClicked: settings.storeTheme(\"night\")"));

for(const s of [ui,bar,main,config,preview])
    assert(s.includes("themeLibraryJson"), "Persistencia de biblioteca ausente");
assert(ui.includes('"themeCustomJson","themeLibraryJson","filePath"'));
assert(ui.includes('const themeSlots = ["dayPrevious", "day", "night", "custom", "library"]'));
assert(bar.includes("soledadSettings.themeLibraryJson = root.themeLibraryJson"));
assert(bar.includes('signal requestThemeSlotChange(string slot, string jsonData)'));
assert(preview.includes('slot === "library" ? "themeLibraryJson"'));
assert(main.includes('slot === "library") Plasmoid.configuration.themeLibraryJson = data'));
assert(config.includes('<entry name="themeLibraryJson" type="String"><default>[]</default></entry>'));
assert(preview.includes('onRequestRestorePersonalDefault: previewWindow.restorePersonalDefault()'));
assert(preview.includes('onRequestRestoreFavoriteAppearance: previewWindow.restoreFavoriteAppearance()'));
assert(bar.includes('onRestorePersonalDefaultRequested: root.requestRestorePersonalDefault()'));
assert(bar.includes('onRestoreFavoriteAppearanceRequested: root.requestRestoreFavoriteAppearance()'));
assert(!ui.includes('function updateSunsetFromCurrent()'));

function fn(name) {
    const start = ui.indexOf("    function "+name+"(");
    assert(start>=0,"Falta "+name);
    let depth=0,begin=ui.indexOf("{", start);
    for(let i=begin;i<ui.length;i++){
        if(ui[i]==="{")depth++;
        else if(ui[i]==="}" && --depth===0)return ui.slice(start,i+1);
    }
    throw Error("Cierre ausente "+name);
}
const state={
  themeLibraryJson: "[]",newThemeName:"Día",themeStatus:"",
  pendingThemeChanges:{},baselineLoaded:true,lastAppliedSettings:{},
  editableSettingsKeys:["themeLibraryJson"],editableColorKeys:[],
  alignmentEdited:false,pendingAlignAction:"",
  previewRefreshes:0,
  refreshOutlinePreview: function(){this.previewRefreshes++},
  appliedLabel:{text:""},
  themeSnapshot: function(){return JSON.stringify({version:1,logoMode:"text",soTextLabel:this.newThemeName})},
  appliedCount:0
};
state.settings=state;
const program=[
    fn("preferenceCopy"),fn("captureSettingsBaseline"),
    fn("stageThemeSlot"),fn("parseThemeLibrary"),fn("saveNamedTheme"),
    fn("discardPendingEdits"),
    'Object.defineProperty(settings,"savedThemeLibrary",{get:function(){return parseThemeLibrary(themeLibraryJson)}})',
    'applyChanges = function(){appliedCount++;captureSettingsBaseline()}',
    'saveNamedTheme()',
    'newThemeName="Noche personalizada"',
    'saveNamedTheme()',
    'newThemeName="Día 2"',
    'saveNamedTheme()',
    'const all = parseThemeLibrary(themeLibraryJson)',
    'if(all.length!==3 || all[0].name!=="Día" || all[1].name!=="Noche personalizada" || all[2].name!=="Día 2") throw Error("Se reemplazó un tema guardado")',
    'if(appliedCount!==3)throw Error("Guardar tema no confirmó escritura")'
].join("\n");
vm.runInNewContext(program,state);
assert.equal(state.appliedCount,3);
assert.equal(JSON.parse(state.themeLibraryJson).length,3);
assert.equal(JSON.parse(state.themeLibraryJson)[0].name,"Día");
assert.equal(state.pendingAlignAction,"");
assert.equal(state.baselineLoaded,true);
assert(ui.includes('slot.indexOf("library:") === 0'));
assert(ui.includes('return isFinite(index) && index >= 0 && index < items.length'));
assert(ui.includes('activateTheme("library:" + index)'));
console.log("OK: tema desplegable cerrado, scroll, temas de fábrica y 3 nuevos diseños guardados sin sobrescritura.");
