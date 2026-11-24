"use strict";
// Regresión estática: launcher de instaladas no se contrae al lanzar app
// salvo selección explícita de autocontracción. SO de ventanas independiente.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname,"..");
const read = p => fs.readFileSync(path.join(base,p),"utf8");
const bar = read("package/contents/ui/SmartBarContent.qml");
const popup = read("package/contents/ui/SoLauncherPopup.qml");
const shell = read("package/contents/ui/LayerShellLauncherWindow.qml");
const host = read("preview_soledad_input_mask.qml");
const settings = read("package/contents/ui/SoledadSettings.qml");
const demo = read("preview_redimensionable.qml");
const runtime = read("package/contents/ui/RuntimeAppearance.js");
const bridge = read("package/contents/ui/RuntimeAppearanceBridge.qml");

assert(bar.includes("property bool autoCollapseSO: true"));
assert(settings.includes("property bool autoCollapseSO: true"));
assert(demo.includes("property bool demoAutoCollapseSO: true"));
assert(bar.includes("if (realTaskActivationDispatched && autoCollapseSO)"));
assert(host.includes("if (bar.autoCollapseSO) bar.soExpanded = false"));
assert(bar.includes("property bool autoCollapseLauncher: false"));
assert(bar.includes('text: "Autocontraer launcher al elegir aplicación"'));
assert(bar.includes("checked: root.autoCollapseLauncher"));
assert(bar.includes("onTriggered: root.requestAutoCollapseLauncherChange("));
assert(host.includes("onRequestAutoCollapseLauncherChange: function(newValue)"));
assert(host.includes("JSON.stringify({demoAutoCollapseLauncher: newValue})"));
assert(host.includes("appearanceBridge.commitPatch(patch)"));
assert(runtime.includes('"autoCollapseLauncher"'));
assert(bridge.includes("function commitPatch(patchJson)"));
assert(bar.includes("autoCollapseOnSelection: root.autoCollapseLauncher"));
assert(popup.includes("property bool autoCollapseOnSelection: false"));
assert.equal((popup.match(/if \(autoCollapseOnSelection\) close\(\)/g)||[]).length,2);
assert(popup.includes('launchDesktopEntry(String(entry.desktopId))'));

// La ventana de Wayland ya no depende de Popup.visible.
assert(bar.includes("property bool launcherRequestedOpen: false"));
assert(bar.includes("function closeInstalledLauncher()"));
assert(bar.includes("launcherRequestedOpen = false"));
assert(bar.includes("function ensureLauncherOpen()"));
assert(bar.includes("if (!installedAppsPopup.visible) {"));
assert(bar.includes("installedAppsPopup.open()"));
assert(bar.includes("launcherRecoveryAttempts >= 6"));
assert(bar.includes("id: launcherRecoveryTimer"));
assert(bar.includes("interval: 260"));
assert(bar.includes("launcherRequestedOpen = true"));
assert(bar.includes("root.launcherRequestedOpen = false"));
assert(bar.includes("onClosed: {"));
assert(bar.includes("if (root.launcherRequestedOpen && !root.autoCollapseLauncher &&"));
assert(bar.includes("onRequestDismiss: root.closeInstalledLauncher()"));
assert(bar.includes("readonly property bool installedLauncherPopupVisible:"));
assert(bar.includes("? launcherRequestedOpen : installedAppsPopup.visible"));
assert(shell.includes("ownerBar.installedLauncherPopupVisible"));
assert(shell.includes("!ownerBar.realTrackedFullscreen"));

// Escape y click derecho son cierres voluntarios.
assert(bar.includes('if (!leftClick && installedLauncherSource === "so" &&'));
assert(bar.includes("closeInstalledLauncher()"));
assert(popup.includes("closePolicy: layerSurfaceHosted ? QQC2.Popup.NoAutoClose"));
assert(popup.includes("signal requestDismiss()"));
assert(popup.includes('sequence: "Escape"'));
assert(popup.includes("onActivated: launcher.requestDismiss()"));
assert(bar.includes("const launch = leftClick === soLeftClickOpensLauncher"));
assert(!bar.includes("launcherKeepOpenAfterSelection"));
console.log("OK: ventana LayerShell controlada por estado deseado, selección conserva launcher y cierre manual funciona.");
