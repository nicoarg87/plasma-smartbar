// Verifica la conexión real del permiso entre Configuración y el ensayo
// temporal de Malvina. No inicia Qt, no abre navegadores ni guarda permisos.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "..");
const qml = fs.readFileSync(path.join(base, "preview_malvina_input_mask.qml"), "utf8");
const bar = fs.readFileSync(path.join(base, "package/contents/ui/SmartBarContent.qml"), "utf8");
const policy = fs.readFileSync(path.join(base, "package/contents/ui/MalvinaUrlPolicy.js"), "utf8")
    .replace(/^\.pragma library\s*$/m, "");

for (const provider of ["ChatGpt", "Gemini", "Claude"]) {
    assert(qml.includes("property bool testAllow" + provider + ": false"),
        "El permiso del ensayo comienza desactivado: " + provider);
    assert(qml.includes("malvinaAllow" + provider + ": probe.testAllow" + provider),
        "El permiso debe llegar a SmartBarContent: " + provider);
    assert(bar.includes("allow" + provider + "Prefill: root.malvinaAllow" + provider),
        "El buscador recibe el permiso de SmartBarContent: " + provider);
}
assert(qml.includes("onRequestMalvinaConsentsChange: function(chatGpt, gemini, claude)"));
assert(bar.includes("root.requestMalvinaConsentsChange(chatGpt, gemini, claude)"));
assert(!qml.includes("Plasmoid.configuration") &&
       !qml.includes("localPreviewSettings.") &&
       !qml.includes("profileSettings."),
       "El ensayo no persiste permisos personales");

function handler(name) {
    const signature = "on" + name + ": function(";
    const at = qml.indexOf(signature);
    assert(at !== -1, "No se encontró " + name);
    const start = qml.indexOf("{", at);
    let depth = 0;
    for (let i = start; i < qml.length; i++) {
        if (qml[i] === "{") depth++;
        else if (qml[i] === "}" && --depth === 0)
            return qml.slice(start + 1, i);
    }
    throw new Error("Handler incompleto: " + name);
}

const memory = {
    testAllowChatGpt: false,
    testAllowGemini: false,
    testAllowClaude: false
};
const apply = new Function("probe", "chatGpt", "gemini", "claude", "console",
    handler("RequestMalvinaConsentsChange"));
const logs = {log() {}};
apply(memory, true, false, true, logs);
assert.equal(memory.testAllowChatGpt, true);
assert.equal(memory.testAllowGemini, false);
assert.equal(memory.testAllowClaude, true);
apply(memory, false, false, false, logs);
assert.equal(memory.testAllowChatGpt, false, "Revocar permiso ChatGPT funciona");
assert.equal(memory.testAllowClaude, false, "Revocar permiso Claude funciona");

const sandbox = {};
vm.createContext(sandbox);
vm.runInContext(policy, sandbox);
const cases = [
    [0, "https://chatgpt.com/", "cerveza", "https://chatgpt.com/?q=cerveza"],
    [2, "https://claude.ai/new", "cerveza", "https://claude.ai/new?q=cerveza"]
];
for (const [index, url, query, expected] of cases) {
    assert.equal(sandbox.resolveAiPrefill(index, url, query, false).url, url,
                 "Sin permiso no adjuntar la consulta");
    assert.equal(sandbox.resolveAiPrefill(index, url, query, true).url, expected,
                 "Con permiso, construir URL de ensayo, sin garantía de envío externo");
}
assert.equal(sandbox.resolveAiPrefill(1, "https://gemini.google.com/app", "cerveza", true).url,
             "https://gemini.google.com/app", "Gemini no tiene enlace verificado");
console.log("OK: permisos temporales IA conectados, revocables y URLs diferenciadas.");
