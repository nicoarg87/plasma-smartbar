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
console.log("OK: fichas ficticias SO abren y cierran; TaskManager real sigue solo lectura.");
