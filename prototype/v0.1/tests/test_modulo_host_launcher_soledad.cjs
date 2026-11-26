#!/usr/bin/env node
"use strict";
// Contratos del popup launcher modular. Sin ejecutar ventanas ni modificar KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const dir = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(dir, "SmartBarContent.qml"), "utf8");
const popup = fs.readFileSync(path.join(dir, "SoledadLauncherHost.qml"), "utf8");
assert.match(main, /SoledadLauncherHost\s*\{\s*id:\s*installedAppsPopup\s*host:\s*root\s*soButtonTarget:\s*soButton\s*malvinaButtonTarget:\s*launcherIsland\s*islandTarget:\s*systemIsland\s*malvinaHoverTarget:\s*malvinaHotspotHover\s*malvinaHideTimerTarget:\s*malvinaHideTimer\s*\}/);
for (const prop of ["host", "soButtonTarget", "malvinaButtonTarget", "islandTarget", "malvinaHoverTarget", "malvinaHideTimerTarget"])
  assert.ok(popup.includes("required property var " + prop), "Dependencia no declarada: " + prop);
for (const token of [
  'import "SoledadLauncherPlacement.js" as SoledadLauncherPlacement',
  "host.layerShellLauncherHost.contentItem",
  "host.realAppLaunchEnabled",
  "SoledadLauncherPlacement.screenLeft({",
  "islandTarget.x",
  "islandTarget.width",
  "malvinaButtonTarget.mapToItem(",
  "const anchor = fromSo ? soButtonTarget : malvinaButtonTarget",
  "return left - anchor.mapToItem(host, 0, 0).x",
  "soButtonTarget.height + 8 : malvinaButtonTarget.height + 8",
  "autoCollapseOnSelection: true",
  "onLaunchDesktopEntry: function(desktopId)",
  "host.closeInstalledLauncher()",
  "host.requestLaunchDesktopEntry(desktopId)",
  "onRequestDismiss: host.closeInstalledLauncher()",
  'host.installedLauncherSource === "so" && soButtonTarget.hovered',
  "host.setLauncherIslandVisible(true)",
  "onClosed:",
  "malvinaHideTimerTarget.restart()"
]) assert.ok(popup.includes(token), "Contrato launcher faltante: " + token);
assert.ok(main.includes("installedAppsPopup.resetAndFocus()"));
assert.ok(main.includes("installedAppsPopup.focusInput()"));
assert.ok(main.includes("installedAppsPopup.open()"));
assert.doesNotMatch(popup, /\broot\.|\bQtCore\.Settings\b/);
assert.doesNotMatch(main, /SoLauncherPopup\s*\{\s*id:\s*installedAppsPopup/);
console.log("OK: popup modular mantiene anclajes, cierre, foco y selección originales.");
