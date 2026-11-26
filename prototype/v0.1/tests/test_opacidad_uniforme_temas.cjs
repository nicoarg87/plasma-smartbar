#!/usr/bin/env node
"use strict";
// Prueba sin Qt, archivos personales ni cambios en KDE.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const ui=path.resolve(__dirname,"../package/contents/ui");
const src=fs.readFileSync(path.join(ui,"RuntimeAppearance.js"),"utf8")
    .replace(/^\.pragma library\s*$/m,"");
const context={};
vm.runInNewContext(src,context,{timeout:1000});
const raw={
    demoSoledadOpacity:0.95,
    demoMalvinaOpacity:0.7,
    demoLauncherOpacity:0.8,
    demoMalvinaOptionsOpacity:0.3,
    demoTrayButtonOpacity:0.1,
    demoGripButtonOpacity:0.2,
    demoBackgroundOpacity:0.9,
    demoSoledadColor:"#123456",
    demoMalvinaColor:"#abc123",
    demoSoledadGradientEnabled:true,
    demoSoButtonWidth:55,
    demoAutoCollapseSO:false
};
const original=JSON.stringify(raw);
const selected=context.withThemeOpacity(raw,"playa-24hs");
assert.notStrictEqual(selected,raw,"no debe mutar el preset de fábrica");
assert.equal(JSON.stringify(raw),original,"los originales deben conservarse");
for(const name of context.persistentThemeOpacityKeys){
    assert.equal(selected[context.savedKey(name)],0.6,name);
}
for(const name of ["demoSoledadColor","demoMalvinaColor",
                   "demoSoledadGradientEnabled","demoSoButtonWidth",
                   "demoAutoCollapseSO"])
    assert.equal(selected[name],raw[name],"conservar "+name);
assert.equal(context.withThemeOpacity(null,"playa-24hs"),null);
for(const name of ["day","sunset","night"]){
   const patch=context.withThemeOpacity(raw,"playa-24hs");
   assert.equal(patch.demoSoledadOpacity,0.6,name);
   assert.equal(patch.demoMalvinaOpacity,0.6,name);
}
for(const packId of ["pack-1","pack-20","",undefined]){
   const patch=context.withThemeOpacity(raw,packId);
   assert.equal(patch.demoSoledadOpacity,raw.demoSoledadOpacity,
       "opacidad Soledad personal "+packId);
   assert.equal(patch.demoMalvinaOpacity,raw.demoMalvinaOpacity,
       "opacidad Malvina personal "+packId);
   assert.equal(patch.demoLauncherOpacity,raw.demoLauncherOpacity);
}
const settings=fs.readFileSync(path.join(ui,"SoledadSettings.qml"),"utf8");
const block=settings.match(/function setUniformThemeOpacity\(\)\s*\{([^}]+)\}/);
assert.ok(block,"los temas del visor deben compartir la regla");
assert.ok(settings.includes("function isPlayaThemeSlot(slot)"));
assert.ok(settings.includes("if (isPlayaThemeSlot(slot)) setUniformThemeOpacity()"));
for(const name of context.persistentThemeOpacityKeys)
    assert.ok(new RegExp("\\b"+name+"\\s*=\\s*0\\.6\\b").test(block[1]),name+" del visor");
const bar=fs.readFileSync(path.join(ui,"SmartBarContent.qml"),"utf8");
assert.ok(bar.includes("RuntimeAppearance.withThemeOpacity(originalPatch,"),
    "el ensayo conjunto debe forzar la regla al pasar al tema siguiente");
console.log("OK: 60 % solo en Playa 24hs; packs personales conservados y originales intactos.");
