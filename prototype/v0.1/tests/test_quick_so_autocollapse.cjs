"use strict";
// Contrato aprobado: launcher de programas cierra tras selección;
// cajón SO de ventanas permanece abierto salvo preferencia habilitada.
// Archivos no participa del cierre por selección de programas.
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

// Cajón SO (ventanas abiertas), optativo y persistente.
assert(bar.includes("property bool autoCollapseSO: false"));
assert(settings.includes("property bool autoCollapseSO: false"));
assert(demo.includes("property bool demoAutoCollapseSO: false"));
assert(bar.includes('text: "Autocontraer cajón SO al elegir ventana"'));
assert(bar.includes("checked: root.autoCollapseSO"));
assert(bar.includes("onTriggered: root.requestAutoCollapseSOChange("));
assert(host.includes("onRequestAutoCollapseSOChange: function(newValue)"));
assert(host.includes("JSON.stringify({demoAutoCollapseSO: newValue})"));
assert(runtime.includes('"autoCollapseSO"'));
assert(bar.includes("if (realTaskActivationDispatched && autoCollapseSO)"));
assert(host.includes("if (bar.autoCollapseSO) bar.soExpanded = false"));

// Launcher de instaladas: cerrar siempre sin depender de preferencias viejas.
assert(!bar.includes("autoCollapseLauncher"));
assert(!runtime.includes('"autoCollapseLauncher"'));
assert(!host.includes("onRequestAutoCollapseLauncherChange"));
assert(!bar.includes('text: "Autocontraer launcher al elegir aplicación"'));
assert(bar.includes("autoCollapseOnSelection: true"));
assert(popup.includes("property bool autoCollapseOnSelection: true"));
assert(popup.includes("function selectApplication(entry)"));
assert(popup.includes('launchDesktopEntry(String(entry.desktopId))'));
assert.equal((popup.match(/if \(autoCollapseOnSelection\) close\(\)/g)||[]).length,2);
assert(bar.includes("onLaunchDesktopEntry: function(desktopId)"));
assert(bar.includes("onAppSelected: function(name, realCatalog)"));
assert(bar.includes("root.closeInstalledLauncher()"));
assert(bar.includes('console.log("SmartBar launcher: aplicación elegida; caja cerrada")'));
assert(bar.includes("function closeInstalledLauncher()"));
assert(bar.includes("launcherRequestedOpen = false"));
assert(bar.includes("installedAppsPopup.close()"));
assert(bar.includes("launcherRequestedOpen = true"));
assert(bar.includes("? launcherRequestedOpen : installedAppsPopup.visible"));
assert(shell.includes("ownerBar.installedLauncherPopupVisible"));
assert(bar.includes("onRequestDismiss: root.closeInstalledLauncher()"));

// Archivos: navegar/abrir carpeta no equivale a elegir una aplicación.
assert(popup.includes("if (fileIsDir) {"));
assert(popup.includes("function openCurrentFolderInManager()"));
assert(popup.includes("Qt.openUrlExternally(fileList.folder)"));
assert(popup.includes("if (!filesMode) return"));

console.log("OK: launcher se cierra al seleccionar programa; cajón SO y Archivos independientes.");
