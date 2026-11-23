"use strict";
// Comprobación estática del ensayo de Malvina LayerTop. La detección
// real de fullscreen y la región Qt requieren prueba nativa en KWin.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(base, p), "utf8");

const qml = read("preview_malvina_input_mask.qml");
const script = read("probar_malvina_superposicion.sh");
const cpp = read("native_probes/soledad_input_mask_main.cpp");
const shared = read("package/contents/ui/SmartBarContent.qml");
const viewer = read("preview_redimensionable.qml");
const soledadProbe = read("preview_soledad_input_mask.qml");
const search = read("package/contents/ui/MalvinaSearch.qml");

assert(shared.includes("readonly property bool autoRevealBlocked:"));
const blocking = shared.slice(
    shared.indexOf("readonly property bool autoRevealBlocked:"),
    shared.indexOf("onAutoRevealBlockedChanged:")
);
assert(blocking.includes("!windowStateKnown") &&
       blocking.includes("previewFullscreen") &&
       blocking.includes("hostFullscreen"),
       "Con estado desconocido o fullscreen real, bloquear Malvina");
assert(!blocking.includes("previewMaximized") &&
       !blocking.includes("hostMaximized"),
       "Una ventana maximizada NO debe bloquear Malvina");
assert(shared.includes("launcherIslandVisible &&") &&
       shared.includes("(!autoHideMalvina || malvinaHoverRevealed"),
       "No borrar la distinción activada/autooculta del usuario");
assert(shared.includes("readonly property real actualMalvinaWidth: malvinaHotspot.width") &&
       shared.includes("readonly property real actualMalvinaHeight: malvinaHotspot.height"),
       "Exponer solamente ancho y alto efectivos de Malvina");
assert(viewer.includes("demoLauncherIslandVisible: true") &&
       viewer.includes("demoAutoHideMalvina: true") &&
       viewer.includes("restoreAppearancePreset()"),
       "Conservar ajustes guardados y defaults del visor");
assert(soledadProbe.includes("launcherIslandVisible: false"),
       "El ensayo fijo de Soledad sigue sin duplicar Malvina");

for (const expected of [
    'objectName: "smartbarMalvinaTopProbe"',
    "property bool malvinaMaskProbe: true",
    "visible: false",
    "LayerShell.Window.LayerTop",
    "LayerShell.Window.AnchorTop",
    "LayerShell.Window.AnchorLeft",
    "LayerShell.Window.exclusionZone: -1",
    "LayerShell.Window.KeyboardInteractivityOnDemand",
    "LayerShell.Window.margins: ({left: 0, top: 0, right: 0, bottom: 0})",
    "width: Math.max(1, Math.ceil(bar.actualMalvinaWidth),",
    "height: Math.max(1, Math.ceil(bar.actualMalvinaHeight),",
    "inputGeometrySignature",
    "onInputGeometrySignatureChanged: Qt.callLater(probe.refreshInputRegion)",
    "onWidthChanged: Qt.callLater(probe.refreshInputRegion)",
    "onHeightChanged: Qt.callLater(probe.refreshInputRegion)",
    "soledadInputMask.setMalvinaInputRegions(",
    "bar.malvinaFieldInputWidth, bar.malvinaFieldInputHeight",
    "bar.malvinaOptionsInputWidth, bar.malvinaOptionsInputHeight",
    "function bridgeReady()",
    "function refreshVisibility()",
    "if (kdeWindows.count === 0 || observedWindows.count < kdeWindows.count)",
    "const full = snapshotFullscreen()",
    "if (full) {",
    "if (visible) visible = false",
    "hostFullscreen: probe.fullscreenDetected",
    "model.IsFullScreen === true",
    "model.IsMinimized === true",
    "onTaskFullScreenChanged: probe.scheduleCheck()",
    "onTaskMinimizedChanged: probe.scheduleCheck()",
    "launcherIslandVisible: true",
    "autoHideMalvina: false",
    "interval: 90000",
    "probe.close()"
]) assert(qml.includes(expected), "Falta protección en ensayo: " + expected);

// Estado nativo y editor: antes se usaba KeyboardInteractivityNone y
// setIslandRect que era recortado al ancho colapsado. No basta dibujar el
// campo: debe recibir clic y poder aceptar teclado, aun con popup abierto.
assert(!qml.includes("LayerShell.Window.KeyboardInteractivityNone") &&
       !qml.includes("LayerShell.Window.KeyboardInteractivityExclusive"),
       "Foco a demanda, jamás NONE ni exclusivo");
assert(!qml.includes("soledadInputMask.setIslandRect("),
       "El ensayo Malvina debe incluir las regiones de editor y Web/IA");
for (const text of [
    "fieldRegionVisible: fieldPopup.visible",
    "fieldRegionX: fieldPopup.x",
    "fieldRegionY: fieldPopup.y",
    "fieldRegionWidth: fieldPopup.visible ? fieldPopup.width : 0",
    "fieldRegionHeight: fieldPopup.visible ? fieldPopup.height : 0",
    "optionsRegionVisible: options.visible",
    "optionsRegionWidth: options.visible ? options.width : 0",
    "optionsRegionHeight: options.visible ? options.height : 0",
    "function focusSearch()",
    "queryInput.forceActiveFocus()"
]) assert(search.includes(text), "Editor debe exponer region sin duplicarse: " + text);
for (const text of [
    "malvinaFieldInputX:", "malvinaFieldInputY:",
    "malvinaFieldInputWidth: malvinaSearch.fieldRegionWidth",
    "malvinaFieldInputHeight: malvinaSearch.fieldRegionHeight",
    "malvinaOptionsInputX:", "malvinaOptionsInputY:",
    "malvinaOptionsInputWidth: malvinaSearch.optionsRegionWidth",
    "malvinaOptionsInputHeight: malvinaSearch.optionsRegionHeight"
]) assert(shared.includes(text), "Falta geometria de popup compartido: " + text);
for (const text of [
    "Q_INVOKABLE void setMalvinaInputRegions(",
    "includeRect(0, 0, islandWidth, islandHeight);",
    "includeRect(fieldX, fieldY, fieldWidth, fieldHeight);",
    "includeRect(optionsX, optionsY, optionsWidth, optionsHeight);",
    "std::isfinite(x)", "right > left && bottom > top",
    "allowed += QRegion(QRect(",
    "m_window->setMask(allowed);"
]) assert(cpp.includes(text), "Máscara de clic debe cubrir controles y no zona vacía: " + text);

assert.equal((qml.match(/\bWindow\s*\{/g) || []).length, 1,
    "Una sola ventana Malvina, no banda duplicada");
assert.equal((qml.match(/SmartBar\.SmartBarContent\s*\{/g) || []).length, 1,
    "Reutilizar el contenido existente, sin rediseñar Malvina");
assert(!qml.includes("requestActivate(") &&
       !qml.includes("requestClose(") &&
       !qml.includes("Qt.WindowTransparentForInput") &&
       !qml.includes("profileSettings.setValue(") &&
       !qml.includes("Plasmoid.configuration"),
       "El ensayo no manipula aplicaciones ni preferencias");

const initialMask = cpp.indexOf('QMetaObject::invokeMethod(window, "refreshInputRegion"');
const newProbe = cpp.indexOf('window->property("malvinaMaskProbe").toBool()');
const show = cpp.indexOf("window->show();");
assert(initialMask >= 0 && initialMask < newProbe && newProbe < show,
       "Malvina no debe mostrarse antes de instalar la máscara inicial");
assert(cpp.includes('QMetaObject::invokeMethod(window, "bridgeReady"'),
       "El nuevo visor debe requerir detección KDE antes de mostrar");
assert(cpp.includes("} else {\n        window->show();"),
       "El visor previo de Soledad conserva el mismo flujo nativo");
for (const expected of [
    "XDG_SESSION_TYPE", "WAYLAND_DISPLAY", "mktemp -d",
    "trap cleanup EXIT", "cmake --build", "QT_QPA_PLATFORM=wayland",
    "QT_WAYLAND_SHELL_INTEGRATION=layer-shell",
    "preview_malvina_input_mask.qml"
]) assert(script.includes(expected), "Falta guarda en el lanzador: " + expected);
for (const forbidden of [
    "sudo ", "pacman -S", "paru ", "yay ", "plasmapkg", "kpackagetool",
    "kwriteconfig", "qdbus", "systemctl", "pkill", "killall", "git reset"
]) assert(!script.includes(forbidden), "Lanzador invasivo: " + forbidden);

console.log("OK: Malvina LayerTop y fullscreen; máscara antes de mostrar; sin tocar preferencias ni panel.");
