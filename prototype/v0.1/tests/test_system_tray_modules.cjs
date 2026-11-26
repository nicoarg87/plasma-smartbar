#!/usr/bin/env node
"use strict";
// Contrato del primer corte modular de la bandeja v0.1.
// Es estático/puro: no manipula bandeja real, panel ni ventanas KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const ui = path.resolve(__dirname, "../package/contents/ui");
function read(name) { return fs.readFileSync(path.join(ui, name), "utf8"); }
function pure(name) {
    const context = {};
    const source = read(name);
    assert.match(source, /^\.pragma library\s/);
    vm.runInNewContext(source.replace(/^\.pragma library\s*/, ""), context);
    return context;
}
function comparable(value) { return JSON.parse(JSON.stringify(value)); }
const model = pure("SystemTrayModel.js");
const ctrl = pure("SystemTrayController.js");
const defaults = comparable(model.demoEntries());
assert.deepEqual(defaults, ["Wi-Fi", "Audio", "Bluetooth"]);
const exposed = model.demoEntries();
exposed[0] = "otro";
assert.deepEqual(comparable(model.demoEntries()), defaults, "catálogo de muestra inmutable");
assert.deepEqual(comparable(model.visibleEntries(defaults, false)), []);
assert.deepEqual(comparable(model.visibleEntries(defaults, true)), defaults);
assert.deepEqual(comparable(model.visibleEntries(null, true)), []);
const copy = model.visibleEntries(defaults, true);
copy.pop();
assert.deepEqual(defaults, ["Wi-Fi", "Audio", "Bluetooth"], "no mutar modelo de origen");
assert.deepEqual(comparable(ctrl.toggle(false, "so")),
                 { expanded: true, lastExpandedMode: "tray", ensureFits: true });
assert.deepEqual(comparable(ctrl.toggle(true, "tray")),
                 { expanded: false, lastExpandedMode: "tray", ensureFits: false });
assert.deepEqual(comparable(ctrl.toggle(true, "so")),
                 { expanded: false, lastExpandedMode: "so", ensureFits: false });
assert.equal(ctrl.afterIconSelection(true, false), true);
assert.equal(ctrl.afterIconSelection(true, true), false);
assert.equal(ctrl.afterIconSelection(false, false), false);
const bar = read("SmartBarContent.qml");
const view = read("SystemTrayView.qml");
assert.match(bar, /import "SystemTrayModel\.js" as SystemTrayModel/);
assert.match(bar, /import "SystemTrayController\.js" as SystemTrayController/);
assert.match(bar, /readonly property var demoTray: SystemTrayModel\.demoEntries\(\)/);
assert.match(bar, /function toggleTray\(\)\s*\{\s*closeInstalledLauncher\(\)/,
             "mantener cierre previo del launcher al pulsar bandeja");
assert.match(bar, /const next = SystemTrayController\.toggle\(trayExpanded, lastExpandedMode\)/);
assert.match(bar, /if \(next\.ensureFits\) ensureExpansionFits\(\)/);
assert.match(bar, /trayExpanded = SystemTrayController\.afterIconSelection\(/);
assert.match(bar, /SystemTrayView\s*\{[\s\S]*?onIconActivated: function\(iconName\)/);
assert.match(bar, /id: trayToggle/);
assert.match(bar, /onClicked: root\.toggleTray\(\)/);
assert.match(bar, /id: traySOSeparator[\s\S]*?visible: root\.trayExpanded && root\.soExpanded/);
assert.match(view, /^\/\/[^]*?\nRepeater\s*\{/);
assert.match(view, /delegate: IslandButton\s*\{/);
assert.match(view, /required property string modelData/);
assert.match(view, /onClicked: trayView\.iconActivated\(modelData\)/);
assert.match(view, /trayOpacity: 0\.9/);
assert.match(view, /QQC2\.ToolTip\.text: "Bandeja simulada: "/);
assert.doesNotMatch(view, /qdbus|QProcess|KWin|execute\(/,
                    "vista no ejecuta acciones del sistema");
console.log("OK: bandeja modular (modelo, controlador, vista); reglas y diseño conservados.");
