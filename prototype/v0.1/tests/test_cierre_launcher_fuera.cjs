#!/usr/bin/env node
"use strict";
// Comprobación estructural del contrato de autocierre.
// No sustituye la prueba real de foco Wayland en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const ui = path.resolve(__dirname, "../package/contents/ui");
const host = fs.readFileSync(path.join(ui, "LayerShellLauncherWindow.qml"), "utf8");
const popup = fs.readFileSync(path.join(ui, "SoLauncherPopup.qml"), "utf8");
const bar = fs.readFileSync(path.join(ui, "SmartBarContent.qml"), "utf8");

assert.match(host, /onActiveChanged\s*:\s*\{/,
    "el host debe responder a cambios de foco de la ventana");
assert.match(host, /launcherHadFocus\s*=\s*true/,
    "no cerrar el launcher antes de que haya tenido foco");
assert.match(host, /onTriggered\s*:\s*\{[\s\S]*?!shellLauncher\.active[\s\S]*?ownerBar\.closeInstalledLauncher\(\)/,
    "cerrar solo después de perder foco realmente");
assert.match(host, /dismissAfterFocusLoss\.restart\(\)/,
    "diferir el cierre para no reabrir al usar SO");
assert.match(host, /requestActivate\(\)/,
    "solicitar foco al mostrar la caja de aplicaciones");
assert.match(host, /LayerShell\.Window\.KeyboardInteractivityOnDemand/,
    "preservar la política de teclado del panel flotante");
assert.match(popup, /closePolicy:\s*layerSurfaceHosted\s*\?\s*QQC2\.Popup\.NoAutoClose/,
    "la detección exterior corresponde al host LayerShell, no al Popup.Item");
assert.match(bar, /function closeInstalledLauncher\(\)\s*\{\s*launcherRequestedOpen\s*=\s*false\s*installedAppsPopup\.close\(\)/,
    "no mezclar cierre del launcher con el cajón SO");
assert.match(bar, /function triggerSOButton\(leftClick, wasOpenAtPress\)/,
    "conservar la protección de alternancia por mismo clic");
assert.doesNotMatch(host, /LayerShell\.Window\.AnchorBottom/,
    "no añadir una capa de entrada que abarque toda la pantalla");

console.log("OK: cierre por foco externo del launcher aislado; SO y panel KDE no intervenidos.");
