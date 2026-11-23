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
    'property string testWebOrder: "google,duck,yahoo"',
    'property string testAiOrder: "chatgpt,gemini,claude"',
    "malvinaWebFirst: probe.testWebFirst",
    "malvinaWebOrder: probe.testWebOrder",
    "malvinaAiOrder: probe.testAiOrder",
    "onRequestMalvinaOrderChange: function(firstWeb, webOrder, aiOrder)",
    "probe.testWebOrder = webOrder",
    "probe.testAiOrder = aiOrder",
    'console.log("SmartBar MALVINA orden temporal:"',
    "interval: 180000",
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
    "property real optionsViewportWidthOverride: 0",
    "optionsViewportWidthOverride > 0",
    "function focusSearch()",
    "function reorderProvider(section, fromIndex, destinationIndex)",
    'console.log("SmartBar MALVINA gesto reordenar:"',
    "queryInput.forceActiveFocus()"
]) assert(search.includes(text), "Editor debe exponer region sin duplicarse: " + text);
for (const text of [
    "malvinaFieldInputX:", "malvinaFieldInputY:",
    "malvinaFieldInputWidth: malvinaSearch.fieldRegionWidth",
    "malvinaFieldInputHeight: malvinaSearch.fieldRegionHeight",
    "malvinaOptionsInputX:", "malvinaOptionsInputY:",
    "malvinaOptionsInputWidth: malvinaSearch.optionsRegionWidth",
    "malvinaOptionsInputHeight: malvinaSearch.optionsRegionHeight",
    "property real malvinaOptionsViewportWidth: 0",
    "optionsViewportWidthOverride: root.malvinaOptionsViewportWidth"
]) assert(shared.includes(text), "Falta geometria de popup compartido: " + text);
// El visor común y el plasmoide procesan RequestMalvinaOrderChange,
// pero este experimento temporal antes dejaba la señal sin receptor.
// Verificar el enlace sin escribir KConfig o preferencias de Qt.
const orderIndex = qml.indexOf("onRequestMalvinaOrderChange: function(");
const orderWindow = qml.slice(orderIndex, orderIndex + 420);
assert(orderIndex >= 0 &&
       orderWindow.includes("probe.testWebFirst = firstWeb") &&
       orderWindow.includes("probe.testWebOrder = webOrder") &&
       orderWindow.includes("probe.testAiOrder = aiOrder"),
       "La reordenación del ensayo actualiza los tres estados en memoria");
assert(qml.includes("malvinaWebFirst: probe.testWebFirst") &&
       qml.includes("malvinaWebOrder: probe.testWebOrder") &&
       qml.includes("malvinaAiOrder: probe.testAiOrder"),
       "Los valores temporales deben llegar a SmartBarContent");
assert(!qml.includes("Plasmoid.configuration") &&
       !qml.includes("localPreviewSettings.") &&
       !qml.includes("profileSettings."),
       "Arrastrar proveedores en el ensayo no puede persistir preferencias");
assert(script.includes("180 segundos") &&
       !script.includes("90 segundos"),
       "El lanzador informa el plazo de 3 minutos del ensayo reversible");
assert(qml.includes("malvinaOptionsViewportWidth: width"),
       "Evitar binding circular del menu LayerShell al propio Window.width");
assert(!qml.includes("malvinaOptionsViewportWidth: probe.width"),
       "Nunca calcular opciones desde ancho dinamico del mismo Window");
for (const text of [
    "Q_INVOKABLE void setMalvinaInputRegions(",
    "includeRect(0, 0, islandWidth, islandHeight);",
    "includeRect(fieldX, fieldY, fieldWidth, fieldHeight);",
    "includeRect(optionsX, optionsY, optionsWidth, optionsHeight);",
    "std::isfinite(x)", "right > left && bottom > top",
    "allowed += QRegion(QRect(",
    "m_window->setMask(allowed);"
]) assert(cpp.includes(text), "Máscara de clic debe cubrir controles y no zona vacía: " + text);

// Regresión de teclado tras reordenar: el DragHandler rehace Repeater
// y el sistema de botones/Popup puede volver a tomar el foco DESPUÉS de
// requestOrderChange. Se necesita foco inmediato y otro diferido.
// Extraer las tres funciones QML reales para probar las dos etapas sin KDE.
function qmlFunction(name) {
    const start = search.indexOf("    function " + name + "(");
    assert(start >= 0, "Falta función real " + name);
    const brace = search.indexOf("{", start);
    let depth = 0;
    for (let i = brace; i < search.length; i++) {
        if (search[i] === "{") depth++;
        if (search[i] === "}" && --depth === 0)
            return search.slice(start, i + 1);
    }
    throw new Error("Función QML incompleta: " + name);
}
const focusQueue = [];
let hasEditorFocus = false;
let orderRequests = 0;
let sentQueries = 0;
const fakeSearch = {expanded:true};
const fakeField = {visible:true};
const fakeInput = {forceActiveFocus() {hasEditorFocus = true;}};
const fakeQt = {callLater(callback) {focusQueue.push(callback);}};
const focusMethods = new Function(
    "search","fieldPopup","queryInput","Qt","requestOrderChange","resetDefault",
    qmlFunction("restoreEditorFocusAfterLayout") + "\n" +
    qmlFunction("activeEditorFocus") + "\n" +
    qmlFunction("applyOrder") +
    "\nreturn {restoreEditorFocusAfterLayout, activeEditorFocus, applyOrder};"
)(
    fakeSearch, fakeField, fakeInput, fakeQt,
    () => {orderRequests++; hasEditorFocus = false;},
    () => {hasEditorFocus = false;}
);
fakeSearch.restoreEditorFocusAfterLayout =
    focusMethods.restoreEditorFocusAfterLayout;
focusMethods.applyOrder(true,"duck,google,yahoo","chatgpt,gemini,claude");
assert.equal(orderRequests,1,"Arrastre debe emitir una solicitud de orden");
assert.equal(hasEditorFocus,true,
             "Restaurar foco tras el reordenamiento en mismo turno");
hasEditorFocus = false; // Qt entrega el foco a la ficha en pointer release
for (const callback of focusQueue.splice(0)) callback();
assert.equal(hasEditorFocus,true,
             "Después de reconstruir el popup el editor recupera el foco");
assert.equal(sentQueries,0,
             "Restaurar foco jamás dispara búsqueda automáticamente");
hasEditorFocus = false;
fakeSearch.expanded = false;
focusMethods.restoreEditorFocusAfterLayout();
assert.equal(hasEditorFocus,false,
             "No robar foco tras cerrar el buscador");
fakeSearch.expanded = true;
fakeField.visible = false;
focusMethods.restoreEditorFocusAfterLayout();
assert.equal(hasEditorFocus,false,
             "No enfocar editor de Popup oculto");
for (const required of [
    "activeEditorFocus()",
    "Qt.callLater(search.restoreEditorFocusAfterLayout)",
    "search.activeEditorFocus()"
]) assert(search.includes(required),
          "Reordenar, elegir y soltar deben devolver foco: " + required);
assert(search.includes("if (Keyboard.enterAction(navigationSection) === \"confirm\")") &&
       search.includes("confirmCandidate()") &&
       search.includes("openSelected()"),
       "Enter: primera pulsación confirma, segunda ejecuta búsqueda");

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
