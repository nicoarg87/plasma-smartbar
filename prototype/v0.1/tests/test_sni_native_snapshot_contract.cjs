#!/usr/bin/env node
"use strict";
// Contrato del lector nativo SNI: no se construye ni ejecuta con el ensayo normal.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..", "native_probes");
const cmake = fs.readFileSync(path.join(root, "CMakeLists.txt"), "utf8");
const source = fs.readFileSync(path.join(root, "status_notifier_readonly.cpp"), "utf8");
assert.match(cmake, /add_executable\(smartbar_input_mask_probe soledad_input_mask_main\.cpp\)/);
assert.match(cmake, /find_package\(Qt6 6\.2 QUIET COMPONENTS DBus\)/);
assert.match(cmake, /add_executable\(smartbar_sni_readonly_probe EXCLUDE_FROM_ALL/);
assert.match(cmake, /target_link_libraries\(smartbar_sni_readonly_probe PRIVATE[\s\S]*?Qt6::Core Qt6::DBus\)/);
assert.match(source, /QDBusConnection::sessionBus\(\)/);
assert.match(source, /RegisteredStatusNotifierItems/);
assert.match(source, /org\.kde\.StatusNotifierWatcher/);
assert.match(source, /org\.freedesktop\.StatusNotifierWatcher/);
assert.match(source, /org\.kde\.StatusNotifierItem/);
assert.match(source, /org\.freedesktop\.StatusNotifierItem/);
assert.match(source, /appendEntry\(item\)/);
assert.match(source, /appendEntry\(fallback\)/);
assert.doesNotMatch(source, /registerService\s*\(|RegisterStatusNotifierHost\s*\(|RegisterStatusNotifierItem\s*\(|QProcess|startDetached|requestClose/);
assert.doesNotMatch(cmake, /add_dependencies\(smartbar_input_mask_probe\s+smartbar_sni_readonly_probe\)/);
console.log("OK: lector SNI nativo solo lectura y build normal independiente.");
