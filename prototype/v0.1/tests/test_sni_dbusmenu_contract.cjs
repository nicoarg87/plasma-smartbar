#!/usr/bin/env node
"use strict";
// REGRESIÓN SIGABRT (27/11/2026): el decodificador recursivo de
// QDBusArgument abortó Soledad al abrir la bandeja y hacer clic en KMix.
// Mantenerlo desconectado hasta contar con compilación y pruebas nativas.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(base, p), "utf8");
const bridge = read("native_probes/status_notifier_bridge.cpp");
const header = read("native_probes/status_notifier_bridge.h");
const view = read("package/contents/ui/SystemTrayRealView.qml");
const cmake = read("native_probes/CMakeLists.txt");
assert.doesNotMatch(bridge, /readMenuRoot|readMenuNode|beginStructure\(|beginMap\(|beginArray\(|QDBusArgument/);
assert.doesNotMatch(bridge, /GetLayout|com\.canonical\.dbusmenu|KWaylandExtras|ProvideXdgActivationToken/);
assert.doesNotMatch(header, /menuEntries|menuChanged|triggerMenuEntry|requestMenu/);
assert.doesNotMatch(view, /QQC2\.Menu\s*\{|Instantiator\s*\{|actionRequested|onClicked:/);
assert.match(view, /enabled:\s*false/);
assert.doesNotMatch(cmake, /KF6WindowSystem|SMARTBAR_HAS_KWAYLAND_ACTIVATION/);
assert.match(cmake, /if\(TARGET Qt6::DBus\)/);
console.log("OK: decoder DBusMenu inseguro aislado; visualización SNI conservada.");
