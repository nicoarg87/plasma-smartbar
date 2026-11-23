// Verifica la conexión y persistencia del consentimiento de Configuración
// en el ensayo Malvina. No inicia Qt, navegador ni modifica permisos reales.
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

const providers = [
    {name: "ChatGpt", key: "chatGptConsentV1", variable: "chatGpt"},
    {name: "Gemini", key: "geminiConsentV1", variable: "gemini"},
    {name: "Claude", key: "claudeConsentV1", variable: "claude"}
];
assert(qml.includes("import QtCore as QtCore"));
assert(qml.includes("QtCore.Settings {"));
assert(qml.includes('category: "plasma-smartbar-v01-malvina-layer-probe-consents"'),
       "El ensayo requiere categoría de almacenamiento exclusiva");
for (const provider of providers) {
    assert(qml.includes("property bool testAllow" + provider.name + ":"),
        "El permiso del ensayo se carga desde almacenamiento: " + provider.name);
    assert(qml.includes('malvinaConsentSettings.value("' + provider.key + '", false)'),
        "Primera ejecución/revocación predeterminada en false: " + provider.name);
    assert(qml.includes("malvinaAllow" + provider.name + ": probe.testAllow" + provider.name),
        "El permiso debe llegar a SmartBarContent: " + provider.name);
    assert(qml.includes('malvinaConsentSettings.setValue("' + provider.key +
                        '", ' + provider.variable + ')'),
        "Aplicar persiste el permiso específico: " + provider.name);
    assert(bar.includes("allow" + provider.name + "Prefill: root.malvinaAllow" + provider.name),
        "El buscador recibe el permiso de SmartBarContent: " + provider.name);
}
assert(qml.includes("malvinaConsentSettings.sync()"),
       "Aplicar debe sincronizar las tres autorizaciones al disco");
assert(qml.includes("onRequestMalvinaConsentsChange: function(chatGpt, gemini, claude)"));
assert(bar.includes("root.requestMalvinaConsentsChange(chatGpt, gemini, claude)"));
assert(!qml.includes("Plasmoid.configuration") &&
       !qml.includes("localPreviewSettings.") &&
       !qml.includes("profileSettings."),
       "El ensayo no puede reescribir KConfig ni perfiles del visor");

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

const data = new Map();
let syncCount = 0;
const storage = {
    value(key, defaultValue) { return data.has(key) ? data.get(key) : defaultValue; },
    setValue(key, value) { data.set(key, value); },
    sync() { syncCount++; }
};
function reload() {
    return {
        testAllowChatGpt: String(storage.value("chatGptConsentV1", false)).toLowerCase() === "true",
        testAllowGemini: String(storage.value("geminiConsentV1", false)).toLowerCase() === "true",
        testAllowClaude: String(storage.value("claudeConsentV1", false)).toLowerCase() === "true"
    };
}
assert.deepEqual(reload(), {
    testAllowChatGpt: false, testAllowGemini: false, testAllowClaude: false
}, "Primera ejecución sin permisos");
const memory = reload();
const apply = new Function("probe", "malvinaConsentSettings", "chatGpt", "gemini",
                           "claude", "console", handler("RequestMalvinaConsentsChange"));
const logs = {log() {}};
apply(memory, storage, true, false, true, logs);
assert.equal(syncCount, 1, "Aplicar sincroniza inmediatamente");
assert.deepEqual(reload(), {
    testAllowChatGpt: true, testAllowGemini: false, testAllowClaude: true
}, "Las autorizaciones sobreviven a otra ejecución");
apply(memory, storage, false, false, false, logs);
assert.equal(syncCount, 2, "Revocar también se persiste con Aplicar");
assert.deepEqual(reload(), {
    testAllowChatGpt: false, testAllowGemini: false, testAllowClaude: false
}, "Se pueden revocar los tres permisos sin perder el resto del perfil");
assert.equal(data.size, 3, "Solo se guardan tres indicadores de consentimiento");

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
console.log("OK: permisos IA persistentes del ensayo, desactivados inicialmente y revocables; URLs diferenciadas.");
