"use strict";
// Contrato estático: la preferencia taskCloseMode gobierna miniaturas reales.
// No modifica KDE ni ejecuta QML/Wayland.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = name => fs.readFileSync(path.join(base, name), "utf8");
const bar = read("package/contents/ui/SmartBarContent.qml");
const host = read("preview_soledad_input_mask.qml");
const single = read("package/contents/ui/LayerShellTaskThumbnail.qml");
const group = read("package/contents/ui/LayerShellTaskGroupPicker.qml");
const editor = read("package/contents/ui/SoledadSettings.qml");
const runtime = read("package/contents/ui/RuntimeAppearance.js");
const island = read("package/contents/ui/IslandButton.qml");

assert(editor.includes('["both", "preview", "chip"]'));
assert(runtime.includes('"taskCloseMode"'), "La preferencia debe sincronizarse");
for (const component of [single, group]) {
    assert(component.includes('property string taskCloseMode: "both"'));
    assert(component.includes('taskCloseMode !== "chip"'));
    assert(component.includes("signal closeWindow(string uuid)"));
}
assert.equal((host.match(/taskCloseMode: bar\.taskCloseMode/g)||[]).length, 2);
assert(host.includes('bar.taskCloseMode === "chip"'));
assert(host.includes("onTaskCloseModeChanged:"));
assert.equal((bar.match(/taskTrailingControlWidth: closeRealTaskChip\.visible \? 30 : 0/g)||[]).length, 2);
assert(island.includes("property int taskTrailingControlWidth: 0"));
assert(island.includes("+ taskTrailingControlWidth"), "El ancho extra debe sumarse al tamaño natural de ficha");
assert(island.includes("+ control.taskTrailingControlWidth"), "El texto respeta espacio de la X");
assert(island.includes("parent.width - control.taskTrailingControlWidth"), "El icono no crece al agregar X");
assert.equal((bar.match(/background: Item \{\}/g)||[]).length, 2,
             "La X debe usar el fondo original de Soledad, sin caja");
assert.equal((bar.match(/text: closeRealTaskChip\.text/g)||[]).length, 2,
             "El glifo X debe dibujarse directamente");
assert.equal((bar.match(/color: closeRealTaskChip\.hovered \? "#ffffff" : "#eaf7ff"/g)||[]).length, 2,
             "Solo cambia el color del glifo al posar el mouse");
assert.equal((bar.match(/width: 26\n\s*height: 28\n\s*z: 3\n\s*text: "×"/g)||[]).length, 2,
             "Conservar superficie clickeable sin aumentar la altura");
assert.equal((bar.match(/root\.taskCloseMode !== "preview" &&/g)||[]).length, 2);
assert.equal((bar.match(/root\.requestRealTaskClose\(/g)||[]).length, 2);
assert(bar.includes("signal requestRealTaskClose(var windowUuids)"));
assert(host.includes("onRequestRealTaskClose: function(uuids)"));
assert(host.includes("probe.closeRealWindowUuid(String(uuids[i]))"));
assert.equal((bar.match(/root\.taskCloseMode !== "chip" &&/g)||[]).length, 2);
assert(single.includes("preview.selectWindow(preview.windowUuid)"));
assert(group.includes("chooser.selectWindow(option.uuid)"));
assert(host.includes("kdeWindows.requestClose(kdeWindows.index(i, 0))"));
console.log("OK: modo de X compartido (both/preview/chip), sin alterar selección y cierre KDE por UUID; validar en CachyOS.");
