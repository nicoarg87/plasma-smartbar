#!/usr/bin/env node
"use strict";
// Verifica extracción de controles de demostración sin acceder a KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const dir = path.resolve(__dirname, "../package/contents/ui");
const content = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const controls = fs.readFileSync(path.join(dir, "SoledadDemoWindowControls.qml"), "utf8");
assert.match(content, /SoledadDemoWindowControls\s*\{\s*id:\s*windowControls\s*visible:\s*root\.previewMaximized\s*anchors\.right:\s*parent\.right\s*anchors\.verticalCenter:\s*parent\.verticalCenter/);
assert.match(content, /root\.previewMaximized \? windowControls\.width \+ 6 : 0/);
assert.match(content, /value \? windowControls\.width \+ 6 : 0/);
for (const value of ['height: 44', 'radius: 22', 'color: "#101e31"', 'border.color: "#4e8499"', 'border.width: 1', 'width: windowControlsRow.implicitWidth + 12', 'model: ["−", "□", "×"]', 'enabled: false', 'delegate: IslandButton', 'QQC2.ToolTip.text: "Control ficticio anclado a la derecha"'])
    assert.ok(controls.includes(value), "Falta el parámetro original: " + value);
assert.doesNotMatch(controls, /requestActivate|requestClose|requestToggleMinimized|QProcess|QtCore\.Settings/);
console.log("OK: bloque de controles ficticios extraído, anclaje y reserva de ancho intactos.");
