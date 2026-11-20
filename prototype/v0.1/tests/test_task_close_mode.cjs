// Regresión de ubicación de X en fichas SO y vista previa.
// No inicia Qt, no controla ventanas KDE ni altera preferencias locales.
"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const base=path.resolve(__dirname,"..");
const ui=path.join(base,"package/contents/ui");
const read=p=>fs.readFileSync(path.join(ui,p),"utf8");
const bar=read("SmartBarContent.qml");
const chip=read("DemoTaskChip.qml");
const settings=read("SoledadSettings.qml");
const viewer=fs.readFileSync(path.join(base,"preview_redimensionable.qml"),"utf8");
const main=read("main.qml");
const xml=fs.readFileSync(path.join(base,"package/contents/config/main.xml"),"utf8");

// Una sola opción de tres modos impide desactivar simultáneamente
// la X en ficha y las X de las tarjetas de vista previa.
// "both" es el valor anterior, que no debe cambiar a usuarios actuales.
function policy(mode) {
    return {chip:mode!=="preview",preview:mode!=="chip"};
}
assert.deepEqual(policy("both"),{chip:true,preview:true});
assert.deepEqual(policy("preview"),{chip:false,preview:true});
assert.deepEqual(policy("chip"),{chip:true,preview:false});
assert.deepEqual(policy("valor-antiguo"),{chip:true,preview:true},
                 "Valor inesperado: fallback conservador a ambas entradas");
for(const file of [bar,settings]) {
    assert(file.includes('taskCloseMode: "both"'),
           "El modo anterior debe permanecer como predeterminado");
}
assert(viewer.includes('demoTaskCloseMode: "both"'),
       "El visor conserva ambas formas de cierre en perfiles nuevos");
assert(xml.includes('<entry name="taskCloseMode" type="String"><default>both</default></entry>'));
assert(main.includes("taskCloseMode: Plasmoid.configuration.taskCloseMode"));
assert(main.includes("onRequestTaskCloseModeChange: function(mode)"));
assert(bar.includes("signal requestTaskCloseModeChange(string mode)"));
assert(bar.includes("soledadSettings.taskCloseMode = root.taskCloseMode"));
assert(bar.includes("onSaveTaskCloseModeRequested: function(mode)"));
assert(settings.includes("property string taskCloseMode: \"both\""));
assert(settings.includes("signal saveTaskCloseModeRequested(string mode)"));
assert(settings.includes("saveTaskCloseModeRequested(taskCloseMode)"));
assert(settings.includes('model: ["X en ficha y vista previa",'));
assert(settings.includes('"Solo vista previa (sin X en ficha)"') &&
       settings.includes('"Solo X en ficha (sin vista previa)"'));
assert(settings.includes('settings.taskCloseMode = ["both", "preview", "chip"][i]'));
const keys=settings.match(/readonly property var editableSettingsKeys: (\[[^\n]+\])/);
assert(keys && JSON.parse(keys[1]).includes("taskCloseMode"),
       "Cancelar debe revertir esta opción si no se pulsó Aplicar");
assert(settings.includes("taskCloseMode: taskCloseMode"),
       "Los perfiles de apariencia deben conservar el modo");
assert(settings.includes('"taskDisplayMode","taskCloseMode"'),
       "Restaurar un tema con la preferencia guardada no debe perderla");
assert(viewer.includes('"demoTaskCloseMode"'), "Persistencia local en appearanceV1");
assert(viewer.includes("taskCloseMode: previewWindow.demoTaskCloseMode"));
assert(viewer.includes("onRequestTaskCloseModeChange: function(mode)"));
assert(viewer.includes("onDemoTaskCloseModeChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }"));
assert(chip.includes('readonly property bool previewAllowed: chip.host.taskCloseMode !== "chip"'));
assert(chip.includes('readonly property bool chipCloseAllowed: chip.host.taskCloseMode !== "preview"'));
assert(chip.includes("if (!previewAllowed || !chip.host.demoWindowControlsEnabled ||"),
       "No abrir vista previa si se eligió solo X en ficha");
assert(chip.includes("enabled: chip.previewAllowed && chip.host.demoWindowControlsEnabled &&"),
       "No abrir popup con clic derecho si está deshabilitado");
assert(chip.includes("if (chip.previewAllowed && taskButton.hovered &&"),
       "No abrir popup con hover si está deshabilitado");
assert(chip.includes("if (!chip.previewAllowed) chip.closePreview()"),
       "Cerrar popup previo al aplicar modo sin vista previa");
assert(chip.includes("!chip.host.usingRealTasks &&\n                 chip.chipCloseAllowed"),
       "Ocultar la X de ficha en el modo solo vista previa");
assert(chip.includes("chip.host.closeDemoWindowInstance(chip.appName, modelData.id)"),
       "La X de cada tarjeta de preview sigue cerrando una instancia");
assert(chip.includes("chip.host.closeDemoWindow(chip.appName)"),
       "La X en ficha sigue cerrando el grupo ficticio");
assert(!/requestClose\s*\(|requestActivate\s*\(|requestToggleMinimized\s*\(/.test(chip));
console.log("OK: X opcional en ficha o vista previa; nunca ambas desactivadas, con Aplicar/Cancelar y persistencia.");
