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
// Error real de Qt/CachyOS (20/11): ReferenceError modelData is not defined.
// Si el delegate usa propiedades required, modelData debe declararse como
// propiedad requerida DENTRO del componente, no leerse en el padre.
assert(chip.includes("required property string modelData"),
       "Qt debe inyectar la fila actual en una propiedad requerida");
assert(chip.includes("readonly property string appName: modelData"),
       "El nombre de aplicación debe derivarse del dato del modelo");
assert(!/appName:\s*modelData/.test(bar),
       "Prohibir modelData contextual fuera del delegate con required");
assert.equal((bar.match(/delegate: DemoTaskChip \{\s*\/\/[\s\S]*?host: root\s*\}/g)||[]).length,2,
       "Derecha y centro deben pasar el host y dejar que Qt inyecte modelData");
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

// Regresión del visor: la preferencia de fichas SO debe surtir
// efecto al pulsar Aplicar, incluso si el visor tenía un modo forzado.
const taskIcon=fs.readFileSync(path.join(uiDir,"TaskAppIcon.qml"),"utf8");
const islandButton=fs.readFileSync(path.join(uiDir,"IslandButton.qml"),"utf8");
assert(!bar.includes("previewShowTaskIdentity"), "No forzar una presentación distinta a la elegida");
assert(!viewer.includes("previewShowTaskIdentity"), "El visor debe usar el modo guardado");
assert(viewer.includes('property string demoTaskDisplayMode: "both"'),
       "Un perfil nuevo debe identificar la aplicación con ícono y nombre");
assert(chip.includes("taskDisplayMode: chip.host.taskDisplayMode"));
assert.equal((bar.match(/taskDisplayMode: root.taskDisplayMode/g)||[]).length,2,
             "Fichas reales y simuladas deben respetar la preferencia");
assert(viewer.includes("previewWindow.demoTaskDisplayMode = mode"),
       "Aplicar debe enviar los cambios al visor");
assert(viewer.includes('bar.taskDisplayMode === "both"'),
       "El diagnóstico visible debe confirmar el modo efectivo");
// Íconos simulados: no adivinar la presencia de Konsole o Brave en el tema.
assert(bar.includes("entry.iconSource || entry.icon"),
       "El simulador debe preferir el ícono .desktop instalado");
assert(bar.includes('return label === "dolphin" ? "org.kde.dolphin" : ""'),
       "Si no existe .desktop, usar inicial K/B sin iconos inventados");
const iconState={localAppCatalog:[
    {name:"Dolphin",icon:"org.kde.dolphin"},
    {name:"Konsole",icon:"utilities-terminal"},
    {name:"Brave Web Browser",icon:"brave-browser"}]};
vm.runInNewContext([
    extract("demoIconForApp"),
    'if(demoIconForApp("Dolphin")!=="org.kde.dolphin")throw Error("Dolphin")',
    'if(demoIconForApp("Konsole")!=="utilities-terminal")throw Error("Konsole")',
    'if(demoIconForApp("Brave")!=="brave-browser")throw Error("Brave")',
    'localAppCatalog=[]',
    'if(demoIconForApp("Konsole")!==""||demoIconForApp("Brave")!=="")throw Error("fallback")'
].join("\n"),iconState);
assert(taskIcon.includes("visible: !appIcon.visible") &&
       taskIcon.includes("fallbackLabel") &&
       taskIcon.includes('fallback: ""') &&
       taskIcon.includes('font.pixelSize: 20'),
       "Usar inicial blanca legible si KDE no ofrece ícono");
assert(islandButton.includes('height: 28') &&
       islandButton.includes('width: control.taskDisplayMode === "icon" ? parent.width : 28'),
       "Reservar un tamaño visible para los iconos");
assert(chip.includes("contentItem: Item {") &&
       chip.includes("id: closeDemoChip") &&
       chip.includes("rotation: 45") &&
       chip.includes("rotation: -45") &&
       chip.includes("onClicked: chip.host.closeDemoWindow(chip.appName)"),
       "La X debe dibujarse con dos trazos dentro del botón existente");
assert(islandButton.includes("fallbackLabel: control.text"));
assert(islandButton.includes("control.inheritIslandFill ||"),
       "No esconder nombres de fichas porque falte una imagen de logo");
assert(islandButton.includes("Math.ceil(taskLabelMetrics.advanceWidth)"),
       "Reservar ancho medido, sin dependencia circular de Text.Fit");
assert(islandButton.includes("TextMetrics {") && islandButton.includes("text: control.text"),
       "Medir de forma independiente el nombre de la tarea");
assert(!viewer.includes('localPreviewSettings.setValue("demoTaskDisplayMode", "both")'),
       "No sobrescribir la preferencia existente al cargar el visor");
for(const mode of ["icon","both","text"]) {
    assert.equal(mode,["icon","both","text"].find(x=>x===mode));
}

console.log("OK: fichas ficticias SO abren y cierran; TaskManager real sigue solo lectura.");
