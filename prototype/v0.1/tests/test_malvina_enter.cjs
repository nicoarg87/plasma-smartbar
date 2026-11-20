// Enter en Malvina: confirmación y envío separados, sin red ni KDE.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const ui = path.resolve(__dirname,"../package/contents/ui");
const code=fs.readFileSync(path.join(ui,"MalvinaKeyboard.js"),"utf8")
    .replace(/^\.pragma library\s*$/m,"");
const qml=fs.readFileSync(path.join(ui,"MalvinaSearch.qml"),"utf8");
const sandbox={};
vm.runInNewContext(code,sandbox);
assert.equal(sandbox.enterAction(0),"search");
assert.equal(sandbox.enterAction(1),"confirm");
assert.equal(sandbox.enterAction(2),"confirm");
assert(qml.includes('import "MalvinaKeyboard.js" as Keyboard'));
assert(qml.includes('Keyboard.enterAction(navigationSection) === "confirm"'));
assert(qml.includes("confirmCandidate()") && qml.includes("openSelected()"));
assert(qml.includes("navigationSection = 0") &&
       qml.includes("function chooseProvider(section, index)"),
       "Confirmar proveedor debe devolver el foco al campo");
assert(qml.includes("navigationSection !== 0 && event.key === Qt.Key_Space") &&
       qml.includes("confirmCandidate()"),
       "Espacio sigue disponible para confirmar");
assert(qml.includes("event.modifiers & Qt.ShiftModifier") &&
       qml.includes("addLine()"),
       "Shift+Enter mantiene la edición multilínea");
assert(qml.includes("Qt.openUrlExternally(result.url)"),
       "Solo openSelected puede abrir el destino");
console.log("OK: Enter elige primero y busca después; Espacio y Shift+Enter intactos.");
