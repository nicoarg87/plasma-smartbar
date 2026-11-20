// Audio por aplicación: solo simulación, ninguna orden PipeWire/KWin/Plasma.
"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const ui=path.resolve(__dirname,"../package/contents/ui");
const bar=fs.readFileSync(path.join(ui,"SmartBarContent.qml"),"utf8");
const chip=fs.readFileSync(path.join(ui,"DemoTaskChip.qml"),"utf8");
const button=fs.readFileSync(path.join(ui,"DemoAudioButton.qml"),"utf8");
const source=fs.readFileSync(path.join(ui,"DemoWindowInstances.js"),"utf8");
const opener=fs.readFileSync(path.join(ui,"DemoWindows.js"),"utf8");
const windowFns={}, appFns={};
vm.runInNewContext(source.replace(/^\s*\.pragma library\s*/,""),windowFns);
vm.runInNewContext(opener.replace(/^\s*\.pragma library\s*/,""),appFns);
function extract(name) {
  const index=bar.indexOf("    function "+name+"(");
  assert(index>=0,"Falta "+name);
  const start=bar.indexOf("{",index);
  let depth=0;
  for(let i=start;i<bar.length;i++) {
    if(bar[i]==="{")depth++;
    else if(bar[i]==="}"&&--depth===0)return bar.slice(index,i+1);
  }
  throw Error("Bloque QML incompleto "+name);
}
const state={
    demoWindowControlsEnabled:true,usingRealTasks:false,
    demoHasRunningWindows:true,
    demoApps:["Dolphin","Konsole","Brave"],
    demoOpenedApps:["Dolphin","Konsole","Brave"],
    demoWindowInstances:windowFns.initial(),DemoWindowInstances:windowFns,
    demoClosedHistory:[],demoMutedApps:{},
    DemoWindows:appFns,lastDemoSelection:""
};
vm.runInNewContext([
    extract("demoInstancesForApp"),
    extract("demoAppIsMuted"),extract("toggleDemoAppMute"),
    extract("openDemoWindow"),extract("closeDemoWindow"),
    extract("closeDemoWindowInstance"),extract("reopenNextDemoWindow"),
    'if(demoAppIsMuted("Dolphin"))throw Error("normal")',
    'if(!toggleDemoAppMute("Dolphin"))throw Error("no toggled")',
    'if(!demoAppIsMuted("Dolphin"))throw Error("no muted")',
    'if(demoAppIsMuted("Brave")||demoAppIsMuted("Konsole"))throw Error("cross mute")',
    'if(demoInstancesForApp("Dolphin").length!==2)throw Error("windows mutated")',
    'toggleDemoAppMute("Dolphin")',
    'if(demoAppIsMuted("Dolphin"))throw Error("unmute")',
    'toggleDemoAppMute("Dolphin")',
    'if(!closeDemoWindowInstance("Dolphin","dolphin-1") || !demoAppIsMuted("Dolphin"))throw Error("group")',
    'if(!closeDemoWindow("Dolphin") || demoAppIsMuted("Dolphin"))throw Error("reset")',
    'if(toggleDemoAppMute("Dolphin"))throw Error("closed")',
    'if(!reopenNextDemoWindow() || demoAppIsMuted("Dolphin"))throw Error("reopen")',
    'usingRealTasks=true',
    'if(toggleDemoAppMute("Brave"))throw Error("real tasks")',
    'usingRealTasks=false;demoWindowControlsEnabled=false',
    'if(toggleDemoAppMute("Brave"))throw Error("disabled demo")'
].join("\n"),state);
assert.equal(state.demoMutedApps["Dolphin"],undefined,
             "No retener silencio al cerrar la app ficticia");
assert(chip.includes("DemoAudioButton {") &&
       chip.includes("host: chip.host") &&
       chip.includes("appName: chip.appName"),
       "Mostrar control parlante al lado de cada ficha");
assert(button.includes("QQC2.ToolButton {") &&
       button.includes("id: control") &&
       button.includes("onClicked: host.toggleDemoAppMute(appName)"),
       "El parlante debe ser accionable por teclado y clic");
assert(button.includes("Canvas {") &&
       button.includes("ctx.arc(") &&
       button.includes('control.demoMuted ? "#f6baba" : "#ffffff"'),
       "Dibujar speaker/ondas/silencio sin dependencia de glifos");
assert(button.includes("Accessible.name:") &&
       button.includes("QQC2.ToolTip.text:"),
       "Explicar qué botón silencia y cómo reactivarlo");
assert(button.includes("host.demoWindowControlsEnabled && !host.usingRealTasks") &&
       button.includes("(no modifica audio real)"),
       "Nunca ejecutar un falso mute sobre aplicaciones KDE reales");
assert(!/Process\s*\{|Qt\.openUrlExternally|requestClose|requestActivate|wpctl|pactl|requestToggleMinimized/.test(button),
       "No introducir comandos, tareas o controles de audio reales sin verificar");
console.log("OK: parlante ficticio por aplicación, activar/desactivar y no afectar KDE/PipeWire.");
