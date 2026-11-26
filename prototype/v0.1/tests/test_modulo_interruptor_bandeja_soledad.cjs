#!/usr/bin/env node
"use strict";
// Contratos del interruptor de bandeja; no inicia Qt ni modifica el panel KDE.
const fs = require("node:fs");
const path = require("node:path");
const assert = require("node:assert/strict");
const dir = path.resolve(__dirname, "../package/contents/ui");
const host = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const view = fs.readFileSync(path.join(dir, "SoledadTrayToggle.qml"), "utf8");
assert.match(host, /SoledadTrayToggle\s*\{\s*id:\s*trayToggle\s*host:\s*root\s*\}/);
assert.match(host, /trayToggle\.implicitWidth \+ soButton\.implicitWidth/);
for (const part of [
 "required property var host",
 'text: host.trayExpanded ? "▶" : "◀"',
 "frameShape: host.trayButtonShape",
 "useTileColor: true",
 "tileColor: host.effectiveTrayButtonColor",
 "tileOpacity: host.soledadGradientEnabled &&",
 "!host.trayButtonColorOverride",
 "? 0 : host.effectiveTrayButtonOpacity",
 "outlineStyle: host.outlineConfig.tray.style",
 "outlineWidth: host.outlineConfig.tray.width",
 "outlineColor: host.displayOutlineTrayColor",
 "outlineOpacity: host.outlineConfig.tray.opacity",
 "onClicked: host.toggleTray()",
 'QQC2.ToolTip.text: "Cajón de sistema: abrir/cerrar bandeja"'
]) assert.ok(view.includes(part), "Contrato perdido: " + part);
assert.doesNotMatch(view, /\broot\.|QtCore\.Settings|requestRealTaskClose/);
assert.equal((host.match(/SoledadTrayToggle\s*\{/g) || []).length,1);
console.log("OK: bandeja modular sin cambios de interacción, contorno ni reserva de ancho.");
