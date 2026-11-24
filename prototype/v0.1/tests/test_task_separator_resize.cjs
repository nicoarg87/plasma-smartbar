"use strict";
// Regresión estática: separador de bandeja/SO ajusta nombres sin tocar altura.
// No ejecuta KWin ni escribe en preferencias del usuario.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const bar = fs.readFileSync(path.join(base, "package/contents/ui/SmartBarContent.qml"),"utf8");
const island = fs.readFileSync(path.join(base, "package/contents/ui/IslandButton.qml"),"utf8");
const mask = fs.readFileSync(path.join(base,"preview_soledad_input_mask.qml"),"utf8");
for (const marker of [
  'id: traySOSeparator',
  'visible: root.trayExpanded && root.soExpanded',
  'cursorShape: Qt.SizeHorCursor',
  'root.taskResizeStartX - pt.x',
  'root.saveTaskNameExtraWidth()',
  'category: "plasma-smartbar-v01-task-chip-width"',
  'taskWidthSettings.setValue("extraWidth", taskNameExtraWidth)',
  'taskWidthSettings.sync()',
  'function updateTaskNameExtraWidth(value)',
  'availableIslandWidth - naturalIslandWidth',
  'Math.min(160,',
  'taskResizeChipCount'
]) assert(bar.includes(marker), "Falta ajuste: "+marker);
assert.equal((bar.match(/taskNameExtraWidth: root\.taskNameExtraWidth/g)||[]).length,2,
             "La ficha KDE debe ampliarse en ambos modos de posición");
assert(island.includes("property int taskNameExtraWidth: 0"));
assert(island.includes("+ taskTrailingControlWidth + taskNameExtraWidth"),
       "La ampliación suma ancho natural en lugar de comprimir texto");
assert(island.includes("font.pixelSize: control.customTextMode ? control.customTextFontSize : 13"),
       "No modificar fuente de fichas");
assert(bar.includes("onDoubleClicked: function(mouse)"));
assert(bar.includes("if (mouse.button !== Qt.LeftButton) return"));
assert(bar.includes("root.taskNameExtraWidth = 0"));
assert(bar.includes("root.saveTaskNameExtraWidth()"));
assert(bar.includes("doble clic para restablecer"));
assert(bar.includes('property string taskDisplayMode: "both"'),
       "El modo predeterminado del cajón SO debe ser icono y nombre");
const settings = fs.readFileSync(path.join(base, "package/contents/ui/SoledadSettings.qml"),"utf8");
assert(settings.includes('property string taskDisplayMode: "both"'),
       "El editor debe mostrar el mismo modo predeterminado");
assert(island.includes('property string taskDisplayMode: "both"'),
       "Las fichas deben mostrar nombre cuando no existe ajuste guardado");
assert(bar.includes("height: 28") && bar.includes("spacing: 2"),
       "Marcas del agarre sin cambiar altura de isla");
assert(mask.includes("probe.refreshInputRegion()"),
       "Conservar actualización de máscara de entradas");
console.log("OK: separador arrastrable, doble clic restablece ancho, icono y nombre predeterminados; falta prueba Qt.");
