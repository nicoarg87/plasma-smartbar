// Regresión aislada: orden inicial Web de Malvina, sin alterar preferencias guardadas.
// Se ejecuta dentro de ejecutar_todos.cjs sin abrir Qt ni sitios externos.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");

assert.match(read("package/contents/ui/MalvinaSearch.qml"),
             /property string webOrder: "duck,yahoo,google"/);
assert.match(read("package/contents/ui/SoledadSettings.qml"),
             /property string malvinaWebOrder: "duck,yahoo,google"/);
assert.match(read("preview_redimensionable.qml"),
             /property string demoMalvinaWebOrder: "duck,yahoo,google"/);
assert.match(read("package/contents/config/main.xml"),
             /<entry name="malvinaWebOrder" type="String"><default>duck,yahoo,google<\/default><\/entry>/);
// No cambiar la política de consentimiento independiente de IA.
for (const provider of ["ChatGpt", "Gemini", "Claude"]) {
    assert.match(read("package/contents/config/main.xml"),
                 new RegExp('<entry name="malvinaAllow' + provider +
                 '" type="Bool"><default>false<\\/default><\\/entry>'));
}
console.log("OK: prioridad inicial DuckDuckGo > Yahoo > Google y permisos IA intactos.");
