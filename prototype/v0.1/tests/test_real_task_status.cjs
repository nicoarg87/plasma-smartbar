// Regresión aislada: roles de KDE TasksModel visibles, sin controlar ventanas.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const base = path.resolve(__dirname, "..");
const helper = fs.readFileSync(path.join(base,
    "package/contents/ui/RealTaskStatus.js"), "utf8");
const diagnostic = fs.readFileSync(path.join(base,
    "preview_ventanas_reales.qml"), "utf8");

assert(helper.startsWith(".pragma library\n"));
const state = {};
vm.runInNewContext(helper.replace(/^\s*\.pragma library\s*/, ""), state);
assert.equal(typeof state.label, "function");

assert.equal(state.label(false, false, false, false), "Inactiva · Normal");
assert.equal(state.label(true, false, false, false), "Activa · Normal");
assert.equal(state.label(true, false, true, false), "Activa · Maximizada");
assert.equal(state.label(false, false, true, false), "Inactiva · Maximizada");
assert.equal(state.label(true, false, true, true), "Activa · Pantalla completa");
assert.equal(state.label(false, true, false, false), "Inactiva · Minimizada");
assert.equal(state.label(false, true, true, true), "Inactiva · Pantalla completa");

// Roles oficiales de Plasma 6. No intentar leer títulos cambiantes
// para perfiles de aplicación: observar también AppId estable.
for (const role of ["AppName", "AppId", "IsGroupParent", "ChildCount",
                    "IsActive", "IsMaximized", "IsMinimized", "IsFullScreen"]) {
    assert(diagnostic.includes("model." + role), "Falta rol: " + role);
}
assert(diagnostic.includes("RealTaskStatus.label(isActive, isMinimized,"));
assert(diagnostic.includes("text: \"ID: \" + appId"));
assert(diagnostic.includes('import "package/contents/ui/RealTaskStatus.js" as RealTaskStatus'));

// La prueba es observacional: ningún gesto sobre ventanas reales.
assert(!/requestActivate\s*\(|requestClose\s*\(|requestToggle\w+\s*\(|Qt\.openUrlExternally\s*\(/.test(diagnostic),
       "El visor diagnóstico no puede modificar ventanas ni abrir aplicaciones");
console.log("OK: lectura KDE de foco/max/fullscreen/ID, sin controlar ventanas.");
