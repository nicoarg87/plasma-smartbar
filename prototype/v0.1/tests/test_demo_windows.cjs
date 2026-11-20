// Regresión de fichas SO ficticias: únicamente visor Qt, sin acciones KDE.
"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const base=path.resolve(__dirname,"..");
const uiDir=path.join(base,"package/contents/ui");
const src=fs.readFileSync(path.join(uiDir,"DemoWindows.js"),"utf8");
const chip=fs.readFileSync(path.join(uiDir,"DemoTaskChip.qml"),"utf8");
const bar=fs.readFileSync(path.join(uiDir,"SmartBarContent.qml"),"utf8");
const viewer=fs.readFileSync(path.join(base,"preview_redimensionable.qml"),"utf8");
assert(src.startsWith(".pragma library\n"));
const helpers={};
vm.runInNewContext(src.replace(/^\s*\.pragma library\s*/,""),helpers);
for(const fn of ["open","close","firstClosed"])assert.equal(typeof helpers[fn],"function");
const catalog=["Dolphin","Konsole","Brave"];
const initial=catalog.slice();
const closed=helpers.close(initial,"Konsole");
assert.deepEqual(JSON.parse(JSON.stringify(closed)),["Dolphin","Brave"]);
assert.deepEqual(initial,catalog,"No mutar catálogo");
assert.equal(helpers.firstClosed(closed,catalog),"Konsole");
const reopened=helpers.open(closed,catalog,"Konsole");
assert.deepEqual(JSON.parse(JSON.stringify(reopened)),["Dolphin","Brave","Konsole"]);
assert.equal(helpers.open(reopened,catalog,"Konsole").length,3,"No duplicar");
assert.equal(helpers.open(closed,catalog,"NoExiste").length,2,"No inventar apps");
assert.equal(helpers.firstClosed(reopened,catalog),"");
const empty=catalog.reduce((arr,name)=>helpers.close(arr,name),initial);
assert.equal(empty.length,0);
assert.equal(helpers.firstClosed(empty,catalog),"Dolphin");
assert.equal(helpers.close(empty,"Brave").length,0);
assert(bar.includes('import "DemoWindows.js" as DemoWindows'));
assert(bar.includes("property bool demoWindowControlsEnabled: false"));
assert(viewer.includes("demoWindowControlsEnabled: true"));
assert(bar.includes("property var demoOpenedApps: demoApps.slice()"));
assert.equal((bar.match(/delegate: DemoTaskChip \{/g)||[]).length,2);
assert.equal((bar.match(/onClicked: root.reopenNextDemoWindow\(\)/g)||[]).length,2);
assert(chip.includes("onClicked: chip.host.closeDemoWindow(chip.appName)"));
assert(chip.includes("chip.host.demoWindowControlsEnabled && !chip.host.usingRealTasks"));
assert(!/requestClose|requestActivate|requestToggleMinimized|Process|execute/.test(src));
function extract(name) {
  const index=bar.indexOf("    function "+name+"(");
  assert(index>=0,"Falta "+name);
  const begin=bar.indexOf("{",index);
  let d=0;
  for(let i=begin;i<bar.length;i++){
    if(bar[i]==="{")++d;
    if(bar[i]==="}"&&--d===0)return bar.slice(index,i+1);
  }
  throw Error("Bloque incompleto "+name);
}
const state={
 demoWindowControlsEnabled:true,usingRealTasks:false,
 demoHasRunningWindows:true,demoApps:catalog.slice(),
 demoOpenedApps:catalog.slice(),lastDemoSelection:"Konsole",DemoWindows:helpers
};
vm.runInNewContext([
 extract("openDemoWindow"),extract("closeDemoWindow"),extract("reopenNextDemoWindow"),
 'if(!closeDemoWindow("Konsole") || lastDemoSelection!=="")throw Error("cerrar")',
 'if(!reopenNextDemoWindow())throw Error("reabrir")',
 'closeDemoWindow("Dolphin");closeDemoWindow("Brave");closeDemoWindow("Konsole")',
 'if(demoOpenedApps.length!==0)throw Error("cero")',
 'if(!reopenNextDemoWindow())throw Error("reabrir desde cero")',
 'usingRealTasks=true',
 'if(closeDemoWindow("Dolphin")||reopenNextDemoWindow())throw Error("real")',
 'usingRealTasks=false;demoWindowControlsEnabled=false',
 'if(closeDemoWindow("Dolphin")||reopenNextDemoWindow())throw Error("panel")'
].join("\n"),state);
assert.deepEqual(JSON.parse(JSON.stringify(state.demoOpenedApps)),["Dolphin"]);
// Incluso con cero ventanas, el gesto explícito de SO debe poder
// abrir el cajón VACÍO para utilizar "+". Solo en visor ficticio.
const emptyState={
    demoWindowControlsEnabled:true,usingRealTasks:false,
    soWindowCount:0,soExpanded:false,lastExpandedMode:"tray",
    installedAppsPopup:{visible:false,close(){}},
    ensureExpansionFits(){}
};
vm.runInNewContext([
    extract("toggleOpenWindowsFromSO"),
    "toggleOpenWindowsFromSO()"
].join("\n"),emptyState);
assert.equal(emptyState.soExpanded,true);
assert.equal(emptyState.lastExpandedMode,"so");
// Si se desactiva el visor ficticio, conservar el contrato anterior de 0 ventanas.
emptyState.demoWindowControlsEnabled=false;
emptyState.soExpanded=false;
vm.runInNewContext([
    extract("toggleOpenWindowsFromSO"),
    "toggleOpenWindowsFromSO()"
].join("\n"),emptyState);
assert.equal(emptyState.soExpanded,false);

// Regresión del problema visual observado en CachyOS: tres fichas con
// iconos ilegibles y ningún nombre en modo "Solo icono" persistido.
const taskIcon=fs.readFileSync(path.join(uiDir,"TaskAppIcon.qml"),"utf8");
const islandButton=fs.readFileSync(path.join(uiDir,"IslandButton.qml"),"utf8");
assert(bar.includes("property bool previewShowTaskIdentity: false"));
assert(bar.includes('previewShowTaskIdentity ? "both" : taskDisplayMode'));
assert(viewer.includes("previewShowTaskIdentity: true"));
assert(chip.includes("taskDisplayMode: chip.host.effectiveTaskDisplayMode"));
assert.equal((bar.match(/taskDisplayMode: root.effectiveTaskDisplayMode/g)||[]).length,2,
             "Real y simulado deben mostrar nombres en el visor de diagnóstico");
assert(bar.includes('return "org.kde.dolphin"'));
assert(bar.includes('return "org.kde.konsole"'));
assert(bar.includes('return "brave-browser"'));
assert(taskIcon.includes("visible: !appIcon.valid") &&
       taskIcon.includes("fallbackLabel") &&
       taskIcon.includes('fallback: ""'),
       "No se debe mostrar un glifo roto si KDE carece del ícono");
assert(islandButton.includes("fallbackLabel: control.text"),
       "El respaldo del ícono debe usar el nombre visible de la aplicación");
assert(!viewer.includes('localPreviewSettings.setValue("demoTaskDisplayMode", "both")'),
       "La prueba no debe sobrescribir el modo de fichas guardado");

// La simulación respeta la configuración pública: no la guarda ni migra.
function identity(mode,diagnostic) { return diagnostic ? "both" : mode }
for(const mode of ["icon","both","text"]) {
    assert.equal(identity(mode,true),"both");
    assert.equal(identity(mode,false),mode);
}

console.log("OK: fichas ficticias SO abren y cierran; TaskManager real sigue solo lectura.");
