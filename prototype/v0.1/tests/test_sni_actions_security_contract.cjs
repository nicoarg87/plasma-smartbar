#!/usr/bin/env node
"use strict";
// Barrera de seguridad tras SIGABRT en QtDBus: hasta completar un lector
// DBusMenu probado, los indicadores visibles no deben recibir clics.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const cpp = read("native_probes/status_notifier_bridge.cpp");
const header = read("native_probes/status_notifier_bridge.h");
const view = read("package/contents/ui/SystemTrayRealView.qml");
const bar = read("package/contents/ui/SmartBarContent.qml");
const preview = read("preview_soledad_input_mask.qml");
assert.match(view, /delegate:\s*IslandButton\s*\{/);
assert.match(view, /enabled:\s*false/);
assert.doesNotMatch(view, /onClicked:|onTapped:|onActionRequested:|remoteMenu|Instantiator/);
assert.doesNotMatch(header, /Q_INVOKABLE\s+bool\s+(?:activate|contextMenu|requestMenu|triggerMenuEntry)\(/);
assert.doesNotMatch(cpp, /QDBusArgument|readMenuRoot|readMenuNode|QStringLiteral\("GetLayout"\)|QStringLiteral\("Event"\)|QDBusMessage::createMethodCall/);
assert.match(cpp, /QIcon::fromTheme/);
assert.match(cpp, /StatusNotifierItemRegistered/);
assert.match(cpp, /StatusNotifierItemUnregistered/);
assert.doesNotMatch(bar, /realSystemTrayBackend|requestRealTrayAction/);
assert.match(preview, /realSystemTrayEntries:\s*smartbarSni.entries/);
assert.doesNotMatch(preview, /realSystemTrayBackend:/);
console.log("OK: vista real SNI sólo lectura; ningún camino al parser DBusMenu inestable.");
