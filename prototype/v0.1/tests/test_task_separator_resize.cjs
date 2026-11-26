"use strict";
// Regresión estática: separador de bandeja/SO ajusta nombres sin tocar altura.
// No ejecuta KWin ni escribe en preferencias del usuario.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const bar = fs.readFileSync(path.join(base, "package/contents/ui/SmartBarContent.qml"),"utf8");
const island = fs.readFileSync(path.join(base, "package/contents/ui/IslandButton.qml"),"utf8");
const separator = fs.readFileSync(path.join(base, "package/contents/ui/SoledadTaskWidthSeparator.qml"),"utf8");
const realChip = fs.readFileSync(path.join(base, "package/contents/ui/SoledadRealTaskChip.qml"),"utf8");
const sizing = fs.readFileSync(path.join(base, "package/contents/ui/SoledadTaskSizing.js"),"utf8");
assert(sizing.includes("availableIslandWidth - naturalIslandWidth"),
       "el cálculo de espacio debe estar delegado al módulo");
assert(sizing.includes("Math.min(160,"),
       "mantener límite de 160 píxeles");
const mask = fs.readFileSync(path.join(base,"preview_soledad_input_mask.qml"),"utf8");
for (const marker of [
  'category: "plasma-smartbar-v01-task-chip-width"',
  'taskWidthSettings.setValue("extraWidth", taskNameExtraWidth)',
  'taskWidthSettings.sync()',
  'function updateTaskNameExtraWidth(value)',
  'SoledadTaskSizing.resizedExtraWidth(',
  'taskResizeChipCount',
  'SoledadTaskWidthSeparator {'
]) assert(bar.includes(marker), "Falta ajuste anfitrión: "+marker);
for (const marker of [
  'visible: host.trayExpanded && host.soExpanded',
  'cursorShape: Qt.SizeHorCursor',
  'host.taskResizeStartX - pt.x',
  'host.saveTaskNameExtraWidth()',
  'onDoubleClicked: function(mouse)',
  'if (mouse.button !== Qt.LeftButton) return',
  'host.taskNameExtraWidth = 0',
  'doble clic para restablecer',
  'height: 28',
  'spacing: 2'
]) assert(separator.includes(marker), "Falta ajuste separador: "+marker);
assert.equal((bar.match(/delegate: SoledadRealTaskChip/g)||[]).length,2,
             "La ficha KDE debe usarse en ambos modos de posición");
assert(realChip.includes('taskNameExtraWidth: host.taskNameExtraWidth'));
assert(island.includes("property int taskNameExtraWidth: 0"));
assert(island.includes("+ taskTrailingControlWidth + taskNameExtraWidth"),
       "La ampliación suma ancho natural en lugar de comprimir texto");
assert(island.includes("font.pixelSize: control.customTextMode ? control.customTextFontSize : 13"),
       "No modificar fuente de fichas");
assert(bar.includes('property string taskDisplayMode: "both"'),
       "El modo predeterminado del cajón SO debe ser icono y nombre");
const settings = fs.readFileSync(path.join(base, "package/contents/ui/SoledadSettings.qml"),"utf8");
assert(settings.includes('property string taskDisplayMode: "both"'),
       "El editor debe mostrar el mismo modo predeterminado");
assert(island.includes('property string taskDisplayMode: "both"'),
       "Las fichas deben mostrar nombre cuando no existe ajuste guardado");
assert(separator.includes("height: 28") && separator.includes("spacing: 2"),
       "Marcas del agarre sin cambiar altura de isla");
assert(mask.includes("probe.refreshInputRegion()"),
       "Conservar actualización de máscara de entradas");
console.log("OK: separador arrastrable, doble clic restablece ancho, icono y nombre predeterminados; falta prueba Qt.");
