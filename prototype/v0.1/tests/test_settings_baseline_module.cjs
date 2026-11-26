#!/usr/bin/env node
// Contrato de la extracción de copia de preferencias: sin Qt ni cambios de datos.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const ui = path.join(__dirname, "../package/contents/ui");
const helperSource = fs.readFileSync(path.join(ui, "SoledadSettingsBaseline.js"), "utf8");
const qmlSource = fs.readFileSync(path.join(ui, "SoledadSettings.qml"), "utf8");
const sandbox = {};
vm.runInNewContext(helperSource.replace(/^\\.pragma library\\s*/m, ""), sandbox);
assert.match(qmlSource, /import "SoledadSettingsBaseline.js" as SoledadSettingsBaseline/);
assert.match(qmlSource, /return SoledadSettingsBaseline\\.preferenceCopy\\(key, value, editableColorKeys\\)/);
const oldCopy = (key, value, colors) => {
    if (value === undefined || value === null) return value;
    if (colors.indexOf(key) !== -1) return String(value);
    if (typeof value === "object") return JSON.parse(JSON.stringify(value));
    return value;
};
const colors = ["soledadColor", "taskFrameColor"];
const inputs = [null, undefined, false, true, 0, 17, "", "texto", [1, 2], {x: 1, deep: {y: 2}}];
let checked = 0;
for (const key of ["soledadColor", "taskFrameColor", "shape", "outlineConfig"]) {
    for (const value of inputs) {
        const actual = sandbox.preferenceCopy(key, value, colors);
        const expected = oldCopy(key, value, colors);
        assert.deepEqual(JSON.parse(JSON.stringify({value: actual})), JSON.parse(JSON.stringify({value: expected})));
        if (value && typeof value === "object" && !colors.includes(key))
            assert.notStrictEqual(actual, value);
        checked++;
    }
}
console.log("OK: " + checked + " equivalencias de copia de preferencias y vínculo QML.");
