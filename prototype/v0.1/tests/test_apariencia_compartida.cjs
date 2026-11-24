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
for(const p of ["positionMode","launcherIslandVisible",
    "autoHideMalvina","malvinaAllowChatGpt","panelHeight"])
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
assert.equal(api.applyToBar(fakeBar,appearance),7);
assert.equal(fakeBar.malvinaShape,"leftTip");
assert.equal(fakeBar.malvinaOpacity,0.4);
assert.equal(fakeBar.malvinaGradientEnabled,true);
assert.equal(fakeBar.launcherIconsWithNames,true);
assert.equal(fakeBar.taskDisplayMode,"both");
assert.equal(fakeBar.launcherIslandVisible,true,
    "No apagar Malvina desde la apariencia histórica");
assert.equal(fakeBar.autoReturnRight,false,
    "La opción explícita de retorno sí debe aplicarse en el ensayo");
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
assert(source.includes("RuntimeAppearance.unmappedChanges(soledadSettings)"));
assert(source.includes("runtimeLastAppearanceCommitOk"));
assert(source.includes("soledadSettings.runtimeApplyFailed = true"));
assert(source.includes("RuntimeAppearance.applyToBar(root, diff)"));
assert(bridge.includes("return false") && bridge.includes("return true"),
       "Aplicar debe comunicar éxito o fallo real");
assert(source.includes("onSettingsApplied: {"));
assert(source.includes("SmartBar Aplicar: intento de persistencia"),
       "No ocultar Aplicar si no escribió nada");
assert(source.includes("SmartBar Aplicar: sin línea base"),
       "No confirmar si no se capturó el estado anterior");
assert(bridge.includes("RuntimeAppearance.applyToBar(target,parsed)"));
assert(bridge.includes("RuntimeAppearance.parse(backend.readAppearanceJson())"),
       "La confirmación requiere releer el perfil guardado");
assert(bridge.includes("JSON.stringify(saved[key]) !== JSON.stringify(changes[key])"),
       "Verificar los valores escritos, no solo el éxito de QSaveFile");
assert(bridge.includes("backend.saveAppearancePatch(patchJson)"));
assert(bridge.includes("backend.readAppearanceJson()"));
assert(bridge.includes("interval: 1750"));
for(const probe of probes) {
    assert(probe.includes("SmartBar.RuntimeAppearanceBridge {"));
    assert(probe.includes("runtimeAppearanceEnabled: smartbarContinuousMode"));
    assert(probe.includes("onRequestRuntimeAppearancePatch: function(json)"));
}
// QSettings de las dos islas debe tener organización/app antes de engine.load.
for (const field of ["setOrganizationName(", "setOrganizationDomain(", "setApplicationName("])
    assert(native.includes(field), "Falta identidad Qt para Settings: " + field);
assert(native.indexOf("setApplicationName(") < native.indexOf("engine.load("),
       "QSettings se inicializa al cargar QML: identidad obligatoria antes");
// El orden Web/IA de Malvina debe sobrevivir reinicios del ensayo conjunto.
const malvinaProbe=probes[1];
assert(malvinaProbe.includes("plasma-smartbar-v01-malvina-layer-probe-order"));
for (const key of ["webFirstV1","webOrderV1","aiOrderV1"]) {
    assert(malvinaProbe.includes('value("'+key+'"'),
           "Malvina no recupera "+key);
    assert(malvinaProbe.includes('setValue("'+key+'"'),
           "Malvina no guarda "+key);
}
assert(malvinaProbe.includes("malvinaOrderSettings.sync()"));
// Los tres buscadores canónicos deben respetar ocultar y deshabilitar,
// ambas opciones distintas, guardadas al pulsar Aplicar.
for (const key of ["googleEnabledV1","duckEnabledV1","yahooEnabledV1","hiddenWebV1","hiddenAiV1"]) {
    assert(malvinaProbe.includes(key),
           "Falta clave declarada "+key);
    if (key.startsWith("hidden"))
        assert(malvinaProbe.includes('malvinaWebSettings.value("'+key+'"'),
               "Falta recuperación de "+key);
    else
        assert(malvinaProbe.includes('storedWebEnabled("'+key+'")'),
               "Falta recuperación de "+key);
    assert(malvinaProbe.includes('malvinaWebSettings.setValue("'+key+'"'),
           "Falta persistencia de "+key);
}
for (const signal of ["onRequestMalvinaWebEnabledChange","onRequestMalvinaExtrasChange"]) {
    assert(malvinaProbe.includes(signal), "Malvina no recibe "+signal);
}
assert(malvinaProbe.includes("malvinaWebSettings.sync()"));
for (const prop of ["malvinaWebGoogleEnabled: probe.testGoogleEnabled",
                   "malvinaWebDuckEnabled: probe.testDuckEnabled",
                   "malvinaWebYahooEnabled: probe.testYahooEnabled",
                   "malvinaHiddenWeb: probe.testHiddenWeb"]) {
    assert(malvinaProbe.includes(prop), "Malvina no aplica "+prop);
}
assert(malvinaProbe.includes("if (smartbarContinuousMode) {"),
       "El modo aislado debe seguir sin escritura del orden");
assert(malvinaProbe.includes('validOrder(value, ["duck","yahoo","google"])'),
       "Validar prioridad Web recuperada");
assert(malvinaProbe.includes('validOrder(value, ["chatgpt","claude","gemini"])'),
       "Validar prioridad IA recuperada");
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
