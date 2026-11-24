"use strict";
// No mostrar carteles flotantes sobre fichas o miniaturas en la sesión SO.
// Contrato estático: no inicia KDE ni altera el panel del usuario.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const files = [
    "package/contents/ui/SmartBarContent.qml",
    "package/contents/ui/DemoTaskChip.qml",
    "package/contents/ui/DemoAudioButton.qml"
];
for (const name of files) {
    const code = fs.readFileSync(path.join(base, name), "utf8");
    const visible = Array.from(code.matchAll(/QQC2\.ToolTip\.visible:\s*([^\n]+)/g),
        m => m[1].trim());
    assert(visible.length > 0, name + ": faltan comprobaciones de tooltip");
    assert(visible.every(expr => expr === "false"),
        name + ": hay tooltips flotantes habilitados: " + visible.join(", "));
}
const bar = fs.readFileSync(path.join(base, files[0]), "utf8");
assert(bar.includes('QQC2.ToolTip.text: "Ventana real de KDE: " + appName'),
       "Las fichas reales siguen identificadas, pero sin cartel superpuesto");
assert.equal((bar.match(/QQC2\.ToolTip\.text: "Ventana real de KDE:/g)||[]).length, 2);
assert(bar.includes("onTaskCloseRequested:"));
assert(bar.includes("root.activateRealTask(index, appId, appName"));
const thumbnail = fs.readFileSync(path.join(base,
    "package/contents/ui/LayerShellTaskThumbnail.qml"), "utf8");
assert(thumbnail.includes("preview.selectWindow(preview.windowUuid)"));
assert(thumbnail.includes("preview.closeWindow(preview.windowUuid)"));
console.log("OK: ayudas emergentes SO desactivadas; miniaturas, selección y cierre siguen conectados.");
