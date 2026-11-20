"use strict";
// Prueba de contratos visuales: el fundido de islas NO muta snapshots.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const root=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(root,p),"utf8");
const bar=read("package/contents/ui/SmartBarContent.qml");
const ui=read("package/contents/ui/SoledadSettings.qml");
const viewer=read("preview_redimensionable.qml");
const config=read("package/contents/config/main.xml");
const main=read("package/contents/ui/main.qml");
const duration=read("package/contents/ui/WallpaperFadeDuration.js");
const button=read("package/contents/ui/IslandButton.qml");
assert(ui.includes('text: "Transición suave de las islas"'));
assert(ui.includes('checked: settings.barThemeTransitionEnabled'));
assert(ui.includes('saveBarThemeTransitionRequested(checked)'));
assert(ui.includes('signal themeVisualTransitionRequested()'));
assert(ui.includes('themeVisualTransitionRequested()\n            const fields = ['));
assert(bar.includes('property bool barThemeTransitionEnabled: true'));
assert(bar.includes('onThemeVisualTransitionRequested: root.startActualThemeColorTransition()'));
assert(bar.includes('onSaveBarThemeTransitionRequested: function(enabled)'));
assert(bar.includes('WallpaperFadeDuration.durationMs(wallpaperFadeAmount, wallpaperFadeUnit)'));
assert(bar.includes('themeColorsTransitionActive = themeScheduleRuntimeEnabled && barThemeTransitionEnabled'));
assert(bar.includes('function previewBarThemeColors(theme)'));
assert(bar.includes('function previewArtworkFromTheme(info)'));
assert(bar.includes('function previewThemeAvailable(theme)'));
assert(bar.includes('soButton.beginArtworkPreview(art,themeColorsDurationMs)'));
assert(bar.includes('soButton.beginActualArtworkFade(themeColorsDurationMs)'));
assert(button.includes('function beginArtworkPreview(art, durationMs)'));
assert(button.includes('function beginActualArtworkFade(durationMs)'));
assert(button.includes('function clearArtworkPreview()'));
assert(button.includes('active: control.previewArtworkEnabled'));
assert(button.includes('model: 2'));
assert.equal((button.match(/QQC2\\.Button \\{/g)||[]).length,1,
             "El fundido no debe agregar botones adicionales");
assert(bar.includes('themeScheduleRuntimeEnabled || soledadSettings.visible'));
assert(bar.includes('if (info.accentColor) palette.soActivityColor'));
assert(bar.includes('if (info.glowColor) palette.soActivityGlowColor'));
assert(bar.includes('if (info.clockTextColor) palette.soClockTextColor'));
assert(viewer.includes('bar.previewBarThemeColors(wallpaperIncomingTheme)'));
assert(viewer.includes('if (target.status === Image.Ready) {'));
assert(viewer.includes('onRequestBarThemeTransitionChange: function(enabled)'));
assert(viewer.includes('localPreviewSettings.setValue("barThemeTransitionEnabled",enabled)'));
assert(viewer.includes('localPreviewSettings.value("barThemeTransitionEnabled", true)'));
assert(config.includes('name="barThemeTransitionEnabled" type="Bool"><default>true</default>'));
assert(config.includes('name="themeScheduleEnabled" type="Bool"><default>true</default>'));
assert(main.includes('Plasmoid.configuration.barThemeTransitionEnabled = enabled'));
assert(main.includes('themeScheduleRuntimeEnabled: false'));
assert(!viewer.includes("plasma-apply-wallpaperimage"));

const visual=["SoledadColor","MalvinaColor",
 "SoledadGradientEnd","SoledadGradientThird",
 "MalvinaGradientEnd","MalvinaGradientThird",
 "SoActivityColor","SoActivityGlowColor",
 "TrayButtonColor","GripButtonColor","TaskFrameColor",
 "LauncherSwitchColor","SoTextBackground","SoTextColor",
 "SoClockTextColor","OutlineSoColor","OutlineMalvinaColor",
 "OutlineTrayColor","OutlineGripColor"];
for(const name of visual){
  assert(bar.includes('property color display'+name+':'),"Falta color visual "+name);
  assert(bar.includes('Behavior on display'+name+' {'),"Falta interpolación "+name);
  assert(bar.includes('root.display'+name) ||
         (name==="TrayButtonColor" && bar.includes('? displayTrayButtonColor : displaySoledadColor')) ||
         (name==="GripButtonColor" && bar.includes('? displayGripButtonColor : displaySoledadColor')),
         "El color no está conectado a la vista "+name);
}
assert.equal((bar.match(/Behavior on display\w+ \{/g)||[]).length,19);
assert(bar.includes('onDisplaySoledadColorChanged() { islandSurface.requestPaint() }'));
assert(bar.includes('onDisplayMalvinaColorChanged() { malvinaTipSurface.requestPaint() }'));
assert(bar.includes('onDisplaySoledadColorChanged() { soTipBackground.requestPaint() }'));
assert(!bar.includes('root.displayTrayButtonColorOverride'));
assert(!bar.includes('root.displayGripButtonColorOverride'));
assert(!bar.includes('root.displaySoTextBackgroundOpacity'));
assert(!bar.includes('root.displaySoTextBackgroundImage'));

function extract(name) {
    const start=bar.indexOf("    function "+name+"(");
    assert(start>=0,"Falta función "+name);
    const pos=bar.indexOf("{",start);
    let depth=0;
    for(let i=pos;i<bar.length;i++) {
        if(bar[i]==="{")depth++;
        if(bar[i]==="}"&&--depth===0)return bar.slice(start,i+1);
    }
    throw Error("Bloque sin cierre "+name);
}
let fakeWrites=0, transitionStarts=0, syncs=0;
let artworkPreviews=0,actualArtworkFades=0,clearedArtwork=0;
const saved=JSON.stringify({
    version:1,soledadColor:"#112233",malvinaColor:"#445566",
    soledadGradientEnd:"#aa2200",malvinaGradientEnd:"#bb3300",
    accentColor:"#44ff44",glowColor:"#ffff55",clockTextColor:"#ddddff",
    outlineConfig:{soledad:{color:"#abcdef"},malvina:{color:"#fedcba"},
                   tray:{color:"#aabbcc"},grip:{color:"#ccbbaa"}}
});
const state={
    themeScheduleRuntimeEnabled:true,barThemeTransitionEnabled:true,
    barColorPreviewActive:false,barPreviewColors:{},themeColorsTransitionActive:false,
    themeColorsTimer:{start(){},stop(){}},themeColorsDurationMs:3000,
    soledadSettings:{visible:false,slotJson:()=>saved},
    soButton:{
        beginArtworkPreview:()=>{artworkPreviews++;return true},
        beginActualArtworkFade:()=>{actualArtworkFades++},
        clearArtworkPreview:()=>{clearedArtwork++}
    },
    previewArtworkFromTheme:()=>({mode:"image",image:"file:///so-original.gif"}),
    syncSettingsFromRoot:()=>syncs++,
    scheduledThemeSlot:()=> "library:0",
    beginThemeColorTransition:()=>transitionStarts++,
    localPreviewSettings:{setValue(){fakeWrites++}},
    requestThemeSlotChange(){fakeWrites++},
    Image:{Ready:1}
};
state.root=state;
const functions=["previewBarThemeColors","startActualThemeColorTransition","cancelBarColorPreview"];
vm.runInContext(functions.map(extract).join("\n"),vm.createContext(state));
assert.equal(state.previewBarThemeColors("sunset"),true);
assert.equal(transitionStarts,1);
assert.equal(syncs,1);
assert.equal(artworkPreviews,1,"El logo SO debe fundirse con la paleta");
assert.equal(state.barPreviewColors.soledadColor,"#112233");
assert.equal(state.barPreviewColors.malvinaColor,"#445566");
assert.equal(state.barPreviewColors.soActivityColor,"#44ff44");
assert.equal(state.barPreviewColors.soActivityGlowColor,"#ffff55");
assert.equal(state.barPreviewColors.outlineSo,"#abcdef");
assert.equal(state.barPreviewColors.outlineMalvina,"#fedcba");
assert.equal(fakeWrites,0,"La vista previa tocó temas guardados");
state.barColorPreviewActive=true;
state.startActualThemeColorTransition();
assert.equal(state.barColorPreviewActive,false);
assert.equal(actualArtworkFades,1,"El cambio de tema real debe fundir SO");
assert.equal(fakeWrites,0,"El fin de la vista previa escribió temas");
state.soledadSettings.visible=true;
assert.equal(state.previewBarThemeColors("night"),false,"No pisar formularios abiertos");

const ms=new Function(duration.replace(/^\.pragma library/,"")+";return durationMs;")();
assert.equal(ms(3,"seconds"),3000);
assert.equal(ms(2,"minutes"),120000);
assert.equal(ms(1,"hours"),3600000);
console.log("OK: 19 colores y GIF/imagen SO sincronizados sin escrituras de temas.");
