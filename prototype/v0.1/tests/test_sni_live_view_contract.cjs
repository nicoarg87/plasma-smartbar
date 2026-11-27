#!/usr/bin/env node
"use strict";
// Protección del primer corte SNI en la vista Soledad.
// Validación estructural: Qt/Wayland aún debe comprobarse en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const ui = path.join(root, "package", "contents", "ui");
const read = file => fs.readFileSync(path.join(root, file), "utf8");
const bar = fs.readFileSync(path.join(ui, "SmartBarContent.qml"), "utf8");
const preview = read("preview_soledad_input_mask.qml");
const real = fs.readFileSync(path.join(ui, "SystemTrayRealView.qml"), "utf8");
const demo = fs.readFileSync(path.join(ui, "SystemTrayView.qml"), "utf8");
const cmake = read("native_probes/CMakeLists.txt");
const native = read("native_probes/soledad_input_mask_main.cpp");
const bridge = read("native_probes/status_notifier_bridge.cpp");
const header = read("native_probes/status_notifier_bridge.h");

assert.match(bar, /property bool useRealSystemTray: false/);
assert.match(bar, /property var realSystemTrayEntries: \[\]/);
assert.match(bar, /readonly property var demoTray: SystemTrayModel\.demoEntries\(\)/);
assert.match(bar, /SystemTrayView\s*\{[\s\S]*?expanded: root\.trayExpanded && !root\.useRealSystemTray/);
assert.match(bar, /SystemTrayRealView\s*\{[\s\S]*?expanded: root\.trayExpanded && root\.useRealSystemTray/);
assert.match(real, /Repeater\s*\{/);
assert.match(real, /model: expanded \? sourceEntries : \[\]/);
assert.match(real, /delegate: IslandButton\s*\{/);
assert.match(real, /iconSource: itemIcon/);
assert.match(real, /preferredButtonWidth: 40/);
assert.match(real, /enabled: false/);
assert.doesNotMatch(real, /onClicked:|qdbus|QProcess|RegisterStatusNotifier/);
assert.match(demo, /Bandeja simulada/);
assert.match(preview, /useRealSystemTray: smartbarSni\.enabled && smartbarSni\.available/);
assert.match(preview, /realSystemTrayEntries: smartbarSni\.entries/);
assert.match(native, /qEnvironmentVariableIntValue\("SMARTBAR_ENABLE_REAL_TRAY"\) == 1/);
assert.match(native, /preview_soledad_input_mask\.qml/);
assert.match(native, /engine\.rootContext\(\)->setContextProperty\("smartbarSni", &sni\)/);
assert.match(native, /engine\.addImageProvider\(QStringLiteral\("smartbar-sni"\)/);
assert.match(cmake, /target_sources\(smartbar_input_mask_probe PRIVATE[\s\S]*?status_notifier_bridge\.cpp/);
assert.match(cmake, /if\(TARGET Qt6::DBus\)/);
assert.match(cmake, /SMARTBAR_HAS_DBUS=1/);
assert.match(cmake, /smartbar_sni_readonly_probe EXCLUDE_FROM_ALL/);
assert.match(header, /Q_PROPERTY\(QVariantList entries READ entries NOTIFY entriesChanged\)/);
assert.match(bridge, /StatusNotifierItemRegistered/);
assert.match(bridge, /StatusNotifierItemUnregistered/);
assert.match(bridge, /NewIcon/);
assert.match(bridge, /NewStatus/);
assert.match(bridge, /QIcon::fromTheme/);
assert.match(bridge, /m_connectedSignals = desiredConnections/);
// QDBusConnection::connect/disconnect no son métodos const en Qt 6.
// La conexión local debe ser mutable tanto en el constructor como en refresh().
assert.equal((bridge.match(/QDBusConnection bus = QDBusConnection::sessionBus\(\);/g) || []).length, 2);
assert.doesNotMatch(bridge, /const QDBusConnection bus = QDBusConnection::sessionBus\(\);/);
assert.doesNotMatch(bridge, /RegisterStatusNotifierHost|RegisterStatusNotifierItem|\.call\(.*Activate|\.call\(.*ContextMenu|QProcess|startDetached|registerService\(/);
console.log("OK: bandeja real SNI opcional/pasiva, demo conservada, sin acciones ni panel KDE.");
