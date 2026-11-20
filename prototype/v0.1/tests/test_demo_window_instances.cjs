// Instancias ficticias agrupadas: sin KDE, sin capturas ni ventanas reales.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const ui=path.resolve(__dirname,"../package/contents/ui");
const js=fs.readFileSync(path.join(ui,"DemoWindowInstances.js"),"utf8");
const qml=fs.readFileSync(path.join(ui,"DemoTaskChip.qml"),"utf8");
const bar=fs.readFileSync(path.join(ui,"SmartBarContent.qml"),"utf8");
assert(js.startsWith(".pragma library\n"));
const functions={};
vm.runInNewContext(js.replace(/^\s*\.pragma library\s*/,""),functions);

const initial=functions.initial();
const dolphin=functions.forApp(initial,"Dolphin");
assert.equal(dolphin.length,2, "Dos Dolphin ficticios en un solo grupo");
assert.notEqual(dolphin[0].id,dolphin[1].id);
assert(dolphin.every(x=>x.minimized===true));
assert.equal(functions.forApp(initial,"Konsole").length,1);
assert.equal(functions.forApp(initial,"Brave").length,1);
const one=functions.close(initial,"Dolphin",dolphin[0].id);
assert.equal(functions.forApp(one,"Dolphin").length,1);
assert.equal(functions.forApp(initial,"Dolphin").length,2,"No mutar estado anterior");
assert.equal(functions.forApp(one,"Brave").length,1);
const none=functions.close(one,"Dolphin",dolphin[1].id);
assert.equal(functions.forApp(none,"Dolphin").length,0);
const reopened=functions.reopen(none,"Dolphin");
assert.equal(functions.forApp(reopened,"Dolphin").length,2);
assert.equal(functions.close(initial,"Dolphin","fantasma"),initial);
assert.equal(functions.forApp(functions.withoutApp(initial,"Brave"),"Brave").length,0);

// El + debe deshacer el ÚLTIMO cierre individual aunque la ficha Dolphin
// continúe visible por tener otra ventana abierta.
const savedDolphin1=functions.snapshot(initial,"Dolphin","dolphin-1");
assert.equal(savedDolphin1.appName,"Dolphin");
assert.equal(savedDolphin1.items.length,1);
const oneDolphin=functions.close(initial,"Dolphin","dolphin-1");
const twoAgain=functions.restore(oneDolphin,savedDolphin1);
assert.deepEqual(Array.from(functions.forApp(twoAgain,"Dolphin"),x=>x.id),
                 ["dolphin-1","dolphin-2"],"Reponer en el orden original");
assert.equal(functions.forApp(oneDolphin,"Dolphin").length,1,
             "No mutar el estado anterior al recuperar");
assert.equal(functions.forApp(functions.restore(twoAgain,savedDolphin1),"Dolphin").length,2,
             "No duplicar una instancia ya recuperada");
const wholeDolphin=functions.snapshot(initial,"Dolphin");
assert.equal(wholeDolphin.items.length,2);
const wholeAgain=functions.restore(functions.withoutApp(initial,"Dolphin"),wholeDolphin);
assert.equal(functions.forApp(wholeAgain,"Dolphin").length,2,
             "La X de grupo permite reponer todas sus tarjetas ficticias");
assert.equal(functions.snapshot(initial,"Dolphin","no-existe"),null);
assert.equal(functions.restore(initial,null),initial);
assert(bar.includes("property var demoClosedHistory: []") &&
       bar.includes("DemoWindowInstances.snapshot(demoWindowInstances, appName, windowId)") &&
       bar.includes("DemoWindowInstances.restore(demoWindowInstances, record)") &&
       bar.includes("demoClosedHistory = demoClosedHistory.slice(0, -1)"),
       "Guardar historial y deshacer cierre individual en SO simulada");
assert.equal((bar.match(/root.demoClosedHistory.length > 0 \|\|/g)||[]).length,2,
             "El + debe habilitarse a izquierda y centro si se cierra una sola Dolphin");

assert(bar.includes("function closeDemoWindowInstance(appName, windowId)"));
assert(bar.includes("if (current.length === 1) return closeDemoWindow(appName)"));
assert(bar.includes("if (!demoWindowControlsEnabled || usingRealTasks ||"));
assert(bar.includes("DemoWindowInstances.close(demoWindowInstances, appName, windowId)"));
assert(qml.includes("interval: 450"), "Abrir miniatura tras hover breve");
assert(qml.includes("acceptedButtons: Qt.RightButton"));
assert(qml.includes("id: previewPopup"));
// Regresión: antes los tres popups se quedaban abiertos aun después
// de quitar el cursor de Dolphin/Konsole/Brave (captura CachyOS).
assert(qml.includes("id: previewDismissDelay") &&
       qml.includes("interval: 240") &&
       qml.includes("if (!chipHover.hovered && !previewPopupHover.hovered)") &&
       qml.includes("chip.closePreview()"),
       "Al salir de la ficha Y del popup, la vista previa debe cerrarse");
assert(qml.includes("id: chipHover") &&
       qml.includes("id: previewPopupHover") &&
       qml.includes("previewDismissDelay.stop()"),
       "Mantener abierta mientras se pasa el puntero a la X de la vista previa");
assert(qml.includes("chip.host.activeDemoPreviewApp = chip.appName") &&
       qml.includes("onActiveDemoPreviewAppChanged()") &&
       qml.includes("chip.host.activeDemoPreviewApp !== chip.appName"),
       "Solo una aplicación debe mostrar vista previa a la vez");
assert(bar.includes('property string activeDemoPreviewApp: ""'),
       "Estado de popup efímero, sin preferencias adicionales");
assert(qml.includes("id: previewPopup"));
assert(qml.includes("chip.host.demoInstancesForApp(chip.appName)"));
assert(qml.includes("required property var modelData"));
assert(qml.includes("chip.host.closeDemoWindowInstance(chip.appName, modelData.id)"));
assert(qml.includes("Minimizada · vista simulada") &&
       qml.includes("Vista simulada · sin captura real"),
       "No fingir miniaturas de ventanas KDE");
assert(!/requestClose\s*\(|requestActivate\s*\(|Qt\.openUrlExternally/.test(qml));
console.log("OK: dos Dolphin ficticios, popup hover/derecho y X por instancia; sin KDE real.");
