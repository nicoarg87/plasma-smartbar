"use strict";
// Regresión: el launcher de instaladas permanece abierto por defecto,
// y su preferencia es independiente de SO (ventanas abiertas).
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(base,p),"utf8");
const bar = read("package/contents/ui/SmartBarContent.qml");
const host = read("preview_soledad_input_mask.qml");
const settings = read("package/contents/ui/SoledadSettings.qml");
const demo = read("preview_redimensionable.qml");
const runtime = read("package/contents/ui/RuntimeAppearance.js");
const popup = read("package/contents/ui/SoLauncherPopup.qml");
const bridge = read("package/contents/ui/RuntimeAppearanceBridge.qml");
// Reversión precisa del cambio anterior sobre ventanas abiertas.
assert(bar.includes("property bool autoCollapseSO: true"));
assert(demo.includes("property bool demoAutoCollapseSO: true"));
assert(settings.includes("property bool autoCollapseSO: true"));
assert(bar.includes("if (realTaskActivationDispatched && autoCollapseSO)"));
assert(host.includes("if (bar.autoCollapseSO) bar.soExpanded = false"));
assert(!bar.includes('text: "Autocontraer SO después de seleccionar"'));
// Requisito nuevo: solo launcher.
assert(bar.includes("property bool autoCollapseLauncher: false"));
assert(bar.includes('text: "Autocontraer launcher al elegir aplicación"'));
assert(bar.includes("checked: root.autoCollapseLauncher"));
assert(bar.includes("onTriggered: root.requestAutoCollapseLauncherChange("));
assert(bar.includes("autoCollapseOnSelection: root.autoCollapseLauncher"));
assert(host.includes("onRequestAutoCollapseLauncherChange: function(newValue)"));
assert(host.includes("JSON.stringify({demoAutoCollapseLauncher: newValue})"));
assert(host.includes("appearanceBridge.commitPatch(patch)"));
assert(runtime.includes('"autoCollapseLauncher"'));
assert(bridge.includes("function commitPatch(patchJson)"));
// Permanencia y cierre explicito.
assert(popup.includes("property bool autoCollapseOnSelection: false"));
assert(popup.includes("autoCollapseOnSelection && !triggerButtonHovered"));
assert.equal((popup.match(/if \(autoCollapseOnSelection\) close\(\)/g)||[]).length,2);
assert(bar.includes('if (!leftClick && installedLauncherSource === "so" &&'));
assert(bar.includes('installedLauncherSource === "so"'));
assert(bar.includes("installedAppsPopup.close()"));
// No cambiar mecanismo de apertura ni activación de KDE.
assert(bar.includes("const launch = leftClick === soLeftClickOpensLauncher"));
assert(popup.includes('launchDesktopEntry(String(entry.desktopId))'));
assert(bar.includes("property bool launcherKeepOpenAfterSelection: false"));
assert(bar.includes("function cancelLauncherKeepOpen()"));
assert(bar.includes("function verifyLauncherStillOpen()"));
assert(bar.includes("id: launcherKeepOpenTimer"));
assert(bar.includes("interval: 750"));
assert(bar.includes("if (!installedAppsPopup.visible) {"));
assert(bar.includes("installedAppsPopup.open()"));
assert(bar.includes("if (keep) launcherKeepOpenTimer.restart()"));
assert(bar.includes("root.launcherKeepOpenAfterSelection = keep"));
assert(bar.includes("const keep = !root.autoCollapseLauncher &&"));
assert(bar.includes("root.realAppLaunchEnabled &&"));
assert(bar.includes("root.layerShellLauncherHost !== null"));
assert(bar.includes("console.warn(\"SmartBar launcher: cerrado por cambio de foco; reabriendo sin reiniciar selección\")"));
console.log("OK: launcher y su elección persisten tras apertura de app; SO separado, cierre explícito y casilla guardada.");
