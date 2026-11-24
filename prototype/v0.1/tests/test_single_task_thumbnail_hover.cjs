"use strict";
// Regresión estática del issue #18: no sustituye la prueba real en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = name => fs.readFileSync(path.join(base, name), "utf8");

const thumbnail = read("package/contents/ui/LayerShellTaskThumbnail.qml");
const host = read("preview_soledad_input_mask.qml");
const group = read("package/contents/ui/LayerShellTaskGroupPicker.qml");

for (const marker of [
    "property bool cursorInside: false",
    "MouseArea {",
    "anchors.fill: parent",
    "hoverEnabled: true",
    "acceptedButtons: Qt.LeftButton",
    "signal selectWindow(string uuid)",
    "preview.selectWindow(preview.windowUuid)",
    "preview.cursorInside = true",
    "preview.cursorInside = false",
    "preview.cursorEntered()",
    "preview.cursorExited()",
    "if (!visible) cursorInside = false"
]) assert(thumbnail.includes(marker), "Falta captura de cursor: " + marker);

for (const marker of [
    "onCursorEntered: thumbnailDismiss.stop()",
    "onCursorExited: thumbnailDismiss.restart()",
    "if (taskThumbnail.cursorInside) return",
    "if (uuid === taskThumbnail.windowUuid)",
    "thumbnailDismiss.restart()",
    "onRealTrackedFullscreenChanged:",
    "onSelectWindow: function(uuid)",
    "uuid !== taskThumbnail.windowUuid",
    "kdeWindows.requestActivate(kdeWindows.index(found, 0))",
    "if (bar.autoCollapseSO) bar.soExpanded = false",
]) assert(host.includes(marker), "Falta política de cierre: " + marker);

assert(host.indexOf("if (taskThumbnail.cursorInside) return") <
       host.indexOf('taskThumbnail.requested = false', host.indexOf('id: thumbnailDismiss')),
       "El cierre debe consultar primero el cursor");
assert(thumbnail.includes("LayerShell.Window.exclusionZone: -1"));
assert(thumbnail.includes("LayerShell.Window.KeyboardInteractivityNone"));
assert(host.includes("if (found < 0)"), "No activar UUID inexistente");
assert(group.includes("onHoveredChanged:"),
       "No alterar el selector agrupado durante esta corrección");
console.log("OK: miniatura individual conserva hover y habilita activación por UUID; falta validación Qt real.");
