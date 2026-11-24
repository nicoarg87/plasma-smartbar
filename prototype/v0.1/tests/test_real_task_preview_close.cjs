"use strict";
// Regresión estática de cierre de miniaturas reales. No ejecuta KWin.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = name => fs.readFileSync(path.join(base, name), "utf8");
const single = read("package/contents/ui/LayerShellTaskThumbnail.qml");
const grouped = read("package/contents/ui/LayerShellTaskGroupPicker.qml");
const host = read("preview_soledad_input_mask.qml");
for (const [name, source] of [["single",single],["grouped",grouped]]) {
    assert(source.includes("signal closeWindow(string uuid)"), name + ": señal cierre");
    assert(source.includes("onClicked:"), name + ": clic");
    assert(source.includes("closeWindow("), name + ": emisión cierre");
    assert(source.includes('text: "×"'), name + ": icono cierre");
    assert(source.includes("acceptedButtons: Qt.LeftButton"), name + ": área clic");
}
assert(single.includes("preview.closeWindow(preview.windowUuid)"));
assert(single.includes("preview.selectWindow(preview.windowUuid)"),
       "El cierre no puede sustituir la selección normal");
assert(grouped.includes("chooser.closeWindow(option.uuid)"));
assert(grouped.includes("chooser.selectWindow(option.uuid)"),
       "Los grupos conservan la selección de ventana");
assert(host.includes("function closeRealWindowUuid(uuid)"));
assert(host.includes("kdeWindows.requestClose(kdeWindows.index(i, 0))"));
assert(host.includes("row.windowUuids.length === 1"));
assert(host.includes("String(row.windowUuids[0]) === String(uuid)"));
assert(host.includes("onCloseWindow: function(uuid)"));
assert.equal((host.match(/onCloseWindow: function\(uuid\)/g)||[]).length,2);
assert(host.includes("uuid !== taskThumbnail.windowUuid"));
assert(host.includes("groupPicker.groupUuids.indexOf(uuid) < 0"));
assert(!host.includes("killall") && !host.includes("pkill"));
console.log("OK: las X solicitan cerrar solamente la ventana real por UUID; se requiere prueba Qt/CachyOS.");
