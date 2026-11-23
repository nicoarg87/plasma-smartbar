// Contrato del menú de IA: permisos y direcciones juntos, sin crear botones.
// Verificación de fuentes; QML/KWin requiere inspección gráfica en CachyOS.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const load = p => fs.readFileSync(path.join(base,p), "utf8");
const ui = load("package/contents/ui/MalvinaProvidersPage.qml");
const orderFiles = [
    ["package/contents/ui/SmartBarContent.qml", /property string malvinaAiOrder: "chatgpt,claude,gemini"/],
    ["package/contents/ui/MalvinaSearch.qml", /property string aiOrder: "chatgpt,claude,gemini"/],
    ["package/contents/ui/SoledadSettings.qml", /property string malvinaAiOrder: "chatgpt,claude,gemini"/],
    ["package/contents/config/main.xml", /<entry name="malvinaAiOrder" type="String"><default>chatgpt,claude,gemini<\/default><\/entry>/],
    ["preview_redimensionable.qml", /property string demoMalvinaAiOrder: "chatgpt,claude,gemini"/],
    ["preview_malvina_input_mask.qml", /property string testAiOrder: "chatgpt,claude,gemini"/]
];
for (const [file, pattern] of orderFiles)
    assert.match(load(file), pattern, "Orden inicial ChatGPT/Claude/Gemini en " + file);

const start = ui.indexOf("visible: panel.sectionIndex === 2");
const end = ui.indexOf("visible: panel.sectionIndex === 3", start);
assert(start >= 0 && end > start);
const section = ui.slice(start,end);
assert(section.includes('text: "Buscadores IA"'));
const headers = ['text: "ChatGPT"', 'text: "Claude"', 'text: "Gemini"'];
const positions = headers.map(t => section.indexOf(t));
assert(positions.every(n => n >= 0) &&
       positions[0] < positions[1] && positions[1] < positions[2],
       "Los formularios se muestran ChatGPT, Claude, Gemini");
assert.equal((section.match(/^\s*Rectangle\s*\{/gm) || []).length, 3,
             "Un bloque visual por cada proveedor");
assert.equal((section.match(/QQC2\.Button\s*\{/g) || []).length, 0,
             "No agregar nuevos botones al formulario IA");
assert.equal((section.match(/color: "#ffe29a"/g) || []).length, 1,
             "Agrupar las advertencias amarillas en un solo lugar");

const keys = [
    ["ChatGpt", "chatgpt"],
    ["Claude", "claude"],
    ["Gemini", "gemini"]
];
for(const [provider,id] of keys){
    const blockStart = section.indexOf("id: " + id + "Fields");
    const blockEnd = section.indexOf("        }\n        Rectangle {", blockStart);
    const block = section.slice(blockStart,blockEnd<0 ? undefined : blockEnd);
    for(const key of ["Name","Url","Allow"+provider]){
        const prop = key.startsWith("Allow") ? "malvina"+key : "malvina"+provider+key;
        assert(block.includes("panel.settingsTarget."+prop),
               "El formulario de "+provider+" conserva "+prop);
    }
    assert(block.includes('panel.isHidden("ai","'+id+'")'));
    assert(block.includes('panel.toggleHidden("ai","'+id+'",checked)'));
}
assert(section.includes("Gemini todavía abre su página") &&
       section.includes("sin la consulta"), "Gemini continúa marcado como pendiente");
assert(!section.includes("Qt.openUrlExternally(") &&
       !section.includes("Clipboard"), "No integrar funciones ajenas al rediseño");
console.log("OK: menú IA agrupado, un aviso amarillo, permisos intactos y Gemini último.");
