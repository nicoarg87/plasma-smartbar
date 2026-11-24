"use strict";
// Regresión NO nativa: aparienciaV1 del visor -> dos islas; aplicar solo
// campos cambiados; conservar perfiles, temas y consentimiento sin pisarlos.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const root=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(root,p),"utf8");
const js=read("package/contents/ui/RuntimeAppearance.js")
    .split("\n").slice(1).join("\n");
const api=new Function(js+"\nreturn {visualKeys,editorNames,savedKey,parse,applyToBar,captureChanges};")();
const source=read("package/contents/ui/SmartBarContent.qml");
const bridge=read("package/contents/ui/RuntimeAppearanceBridge.qml");
const native=read("native_probes/soledad_input_mask_main.cpp");
const runner=read("probar_islas_juntas.sh");
const reader=read("scripts/leer_apariencia_playa.qml");
const importer=read("scripts/importar_apariencia_conjunta.cjs");
const probes=["preview_soledad_input_mask.qml","preview_malvina_input_mask.qml"].map(read);

assert(api.visualKeys.length>60,"Recuperar colores, degradados, geometrías y cajón");
const editorQml=read("package/contents/ui/SoledadSettings.qml");
const viewerQml=read("preview_redimensionable.qml");
for(const key of api.visualKeys) {
    const editorKey=api.editorNames[key] || key;
    const matches=(code,property)=>code.split("\n").some(line=>
        line.includes("property ") && line.includes(" "+property+":"));
    assert(matches(source,key),"Falta propiedad destino SmartBar: "+key);
    assert(matches(editorQml,editorKey),"Falta propiedad del editor: "+editorKey);
    assert(matches(viewerQml,api.savedKey(key)),
           "Falta clave de apariencia guardada: "+api.savedKey(key));
}
for(const p of ["malvinaShape","soledadOpacity","malvinaOpacity",
    "soledadGradientEnabled","malvinaGradientEnabled","launcherIconsWithNames",
    "taskDisplayMode","soLogoShape","soActivityStyle"])
    assert(api.visualKeys.includes(p),"Apariencia omitida: "+p);
for(const p of ["positionMode","autoReturnRight","launcherIslandVisible",
    "autoHideMalvina","malvinaAllowChatGpt","showBackground"])
    assert(!api.visualKeys.includes(p),"No alterar posiciones/permisos: "+p);
assert.equal(api.savedKey("launcherIconsWithNames"),"demoLauncherIconsWithNames");
assert.equal(api.savedKey("taskDisplayMode"),"demoTaskDisplayMode");
const appearance={
    demoMalvinaShape:"leftTip", demoMalvinaOpacity:0.4,
    demoMalvinaGradientEnabled:true, demoLauncherIconsWithNames:true,
    demoTaskDisplayMode:"both", demoOutlineConfig:{malvina:{style:"solid"}},
    demoLauncherIslandVisible:false, demoAutoReturnRight:false,
    demoMalvinaAllowChatGpt:true
};
const fakeBar={malvinaShape:"rounded",malvinaOpacity:0.9,
    malvinaGradientEnabled:false,launcherIconsWithNames:false,
    taskDisplayMode:"icon",outlineConfig:{},launcherIslandVisible:true,
    autoReturnRight:true,malvinaAllowChatGpt:false};
assert.equal(api.applyToBar(fakeBar,appearance),6);
assert.equal(fakeBar.malvinaShape,"leftTip");
assert.equal(fakeBar.malvinaOpacity,0.4);
assert.equal(fakeBar.malvinaGradientEnabled,true);
assert.equal(fakeBar.launcherIconsWithNames,true);
assert.equal(fakeBar.taskDisplayMode,"both");
assert.equal(fakeBar.launcherIslandVisible,true,
    "No apagar Malvina desde la apariencia histórica");
assert.equal(fakeBar.autoReturnRight,true,
    "No sobreescribir anclajes ni retorno");
assert.equal(fakeBar.malvinaAllowChatGpt,false,
    "No cambiar consentimientos IA");
const baseline={launcherIconsWithNames:false,malvinaShape:"rounded",
    malvinaOpacity:0.9,taskDisplayMode:"icon"};
const editor={baselineLoaded:true,lastAppliedSettings:baseline,
    launcherIconsWithNames:true,malvinaShape:"rounded",
    malvinaOpacity:0.9,taskDisplayMode:"icon",
    preferenceCopy:(key,value)=>value};
const patch=api.captureChanges(editor);
assert.deepEqual(patch,{demoLauncherIconsWithNames:true},
    "Aplicar solo debe guardar controles modificados");
assert.equal(api.parse(JSON.stringify(patch)).demoLauncherIconsWithNames,true);
assert.equal(api.parse("{malformed"),null);

assert(source.includes("requestRuntimeAppearancePatch(JSON.stringify(diff))"));
assert(source.includes("RuntimeAppearance.captureChanges(soledadSettings)"));
assert(source.includes("onSettingsApplied: {"));
assert(bridge.includes("RuntimeAppearance.applyToBar(target,parsed)"));
assert(bridge.includes("backend.saveAppearancePatch(patchJson)"));
assert(bridge.includes("backend.readAppearanceJson()"));
assert(bridge.includes("interval: 1750"));
for(const probe of probes) {
    assert(probe.includes("SmartBar.RuntimeAppearanceBridge {"));
    assert(probe.includes("runtimeAppearanceEnabled: smartbarContinuousMode"));
    assert(probe.includes("onRequestRuntimeAppearancePatch: function(json)"));
}
assert(native.includes("Q_INVOKABLE QString readAppearanceJson() const"));
assert(native.includes("Q_INVOKABLE bool saveAppearancePatch("));
assert(native.includes("QSaveFile out(path)"));
assert(native.includes('qEnvironmentVariable("SMARTBAR_SHARED_APPEARANCE_PATH")'));
assert(reader.includes('saved.value("appearanceV1", "")'));
assert(importer.includes('fs.writeFileSync(destination,json,'));
assert(importer.includes('flag:"wx"'));
assert(runner.includes('APPEARANCE_FILE="$LOG_ROOT/appearance-runtime.json"'));
assert(runner.includes('node "$HERE/scripts/importar_apariencia_conjunta.cjs"'));
assert(runner.includes('SMARTBAR_SHARED_APPEARANCE_PATH="$APPEARANCE_FILE"'));
console.log("OK: apariencia visual, iconos/nombres y aplicar entre ambas islas");
