"use strict";
// Test ESTÁTICO: valida el contrato de seguridad de la estrategia nueva.
// El comportamiento de QWindow::setMask requiere ensayo en KWin/Wayland.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const base = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(base, p), "utf8");

const cpp = read("native_probes/soledad_input_mask_main.cpp");
const cmake = read("native_probes/CMakeLists.txt");
const qml = read("preview_soledad_input_mask.qml");
const script = read("probar_soledad_entrada_fija.sh");
const real = read("package/contents/ui/SmartBarContent.qml");
const main = read("package/contents/ui/main.qml");
const viewer = read("preview_redimensionable.qml");
const previous = read("preview_soledad_layershell.qml");

for (const marker of [
    "#include <QQuickWindow>", "#include <QRegion>", "Q_INVOKABLE void setIslandRect(",
    "const QRegion requested(QRect(", "m_window->setMask(requested);",
    "std::isfinite", "std::floor", "std::ceil",
    'engine.rootContext()->setContextProperty("soledadInputMask", &input);',
    'QMetaObject::invokeMethod(window, "refreshInputRegion"',
    "window->create();", "window->show();"
]) assert(cpp.includes(marker), "Falta puente Qt6 seguro: " + marker);
// La llamada setMask vive en la clase, pero se INVoca después de crear
// la superficie nativa y antes de hacer show: comprobar orden efectivo abajo.
assert(cpp.indexOf("window->create();") < cpp.indexOf("input.attach(window);"));
assert(cpp.indexOf("input.attach(window);") <
       cpp.indexOf('QMetaObject::invokeMethod(window, "refreshInputRegion"'));
assert(cpp.indexOf('QMetaObject::invokeMethod(window, "refreshInputRegion"') <
       cpp.indexOf("window->show();"),
       "La ventana NO puede verse antes de la máscara inicial.");
assert(cpp.includes("window->mask().isEmpty()"),
       "Abortar si no se instaló región de entrada válida.");
assert(cpp.includes("right <= left || bottom <= top"),
       "No aceptar regiones vacías de entrada.");
assert(!cpp.includes("setPosition(") && !cpp.includes("setGeometry("),
       "No mover otras ventanas ni el toplevel en este ensayo.");

for (const marker of [
    'import "package/contents/ui" as SmartBar',
    "SmartBar.SmartBarContent {", "visible: false",
    "LayerShell.Window.AnchorTop", "LayerShell.Window.AnchorLeft",
    "LayerShell.Window.AnchorRight", "LayerShell.Window.LayerTop",
    "LayerShell.Window.exclusionZone: -1",
    "LayerShell.Window.KeyboardInteractivityNone",
    "LayerShell.Window.margins: ({ left: 0, top: 6, right: 0, bottom: 0 })",
    "function refreshInputRegion()", "soledadInputMask.setIslandRect(",
    "width: probe.width", "height: probe.height", "x: 0", "y: 0",
    "layerShellDragCompensation: false",
    "onIslandOffsetChanged: probe.refreshInputRegion()",
    "onActualIslandWidthChanged: probe.refreshInputRegion()",
    "interval: 90000", "probe.close()"
]) assert(qml.includes(marker), "Falta condición ventana fija: " + marker);
assert.equal((qml.match(/SmartBar\.SmartBarContent\s*\{/g) || []).length, 1);
assert.equal((qml.match(/\bWindow\s*\{/g) || []).length, 1);
assert(!qml.includes("Qt.WindowTransparentForInput"),
       "No permitir clics bajo la propia isla.");
assert(!qml.includes("right: 12 + Math.round(bar.islandOffset)"),
       "NO reconfigurar los márgenes de LayerShell en cada pixel.");
assert(!qml.includes("AnimatedImage {") && !qml.includes("MouseArea {") &&
       !qml.includes("DragHandler {"),
       "Cargar el componente real: no duplicar agarre, GIF ni botones.");
// Perfil real ya existente y probado en visor Qt; solo se escribe mediante
// la opción contextual REAL «Recordar esta posición para [aplicación]».
for (const marker of [
    "import org.kde.taskmanager 0.1 as TaskManager",
    'import QtCore as QtCore',
    'import "package/contents/ui/RealActiveWindow.js" as RealActiveWindow',
    'category: "plasma-smartbar-v01-fixed-input-positions"',
    'profileSettings.value("soledadRealPositionProfilesV1", "{}")',
    "TaskManager.TasksModel {",
    "groupMode: TaskManager.TasksModel.GroupDisabled",
    "groupMode: TaskManager.TasksModel.GroupApplications",
    "launcherList: []",
    "required property var model",
    "model.IsActive === true",
    "model.IsMaximized === true",
    "model.IsMinimized === true",
    "model.IsFullScreen === true",
    "RealActiveWindow.resolve(rows)",
    "onTaskMaximizedChanged: probe.scheduleWindowRecheck(\"maximizada\")",
    "onTaskActiveChanged: probe.scheduleWindowRecheck(\"foco\")",
    "onTaskMinimizedChanged: probe.scheduleWindowRecheck(\"minimizada\")",
    "kdeWindowObservers.itemAt(i)",
    "realTaskModel: groupedKdeWindows",
    "realTrackedAppId: probe.trackedAppId",
    "realTrackedAppName: probe.trackedAppName",
    "realTrackedMaximized: probe.trackedMaximized",
    "realTrackedKnown: probe.trackedKnown",
    "onRequestRealPositionProfilesChange: function(json)",
    'profileSettings.setValue("soledadRealPositionProfilesV1", json)',
    "profileSettings.sync()",
    "externalWindowControlsReserve: 0",
    "onControlsReservationChanged: probe.refreshInputRegion()",
    "else if (!bar.draggingIslandGrip) bar.alignRightNow()"
]) assert(qml.includes(marker), "Falta memoria real / diseño de prueba: " + marker);
assert(!qml.includes("trialControlsReservePx") &&
       !qml.includes("externalActiveMaximized"),
       "No conservar reserva artificial de 176 px");
assert(!qml.includes("Qt.WindowTransparentForInput") &&
       !/requestActivate\s*\(|requestClose\s*\(|requestToggleMaximized\s*\(/.test(qml),
       "Nunca modificar ventanas externas ni pasar clics bajo Soledad");
assert(!qml.includes("themeDayJson") && !qml.includes("themeNightJson") &&
       !qml.includes("kwriteconfig") && !qml.includes("KConfig"),
       "No modificar temas ni KConfig del usuario");
assert((qml.match(/profileSettings\.setValue\(/g) || []).length === 1,
       "La prueba solo puede persistir la clave de posiciones reales");
assert(qml.includes("LayerShell.Window.margins: ({ left: 0, top: 6, right: 0, bottom: 0 })"),
       "La ventana debe seguir fija y sin obstruir Brave");
assert(real.includes("property real externalWindowControlsReserve: 0") &&
       real.includes("readonly property bool draggingIslandGrip: gripDrag.active"),
       "No alterar producción, exponer únicamente estado del agarre");
assert(real.includes("onRequestRealPositionProfilesChange") === false,
       "El contenido base solo emite la solicitud de guardado, no debe persistir");
assert(real.includes("Recordar esta posición para ") &&
       real.includes("root.saveRealPositionProfile()") &&
       real.includes("root.deleteRealPositionProfile()"),
       "Conservar el menú de perfiles existente y la opción de olvido");
assert(viewer.includes('setValue("soledadRealPositionProfilesV1", json)') &&
       viewer.includes('category: "plasma-smartbar-v01-preview-appearance"'),
       "Conservar memoria actual del visor independiente");
assert(!viewer.includes('plasma-smartbar-v01-fixed-input-positions') &&
       !qml.includes('category: "plasma-smartbar-v01-preview-appearance"'),
       "La prueba no debe alterar los perfiles existentes del visor");

// Traza de KWin solo en ensayo: no cambia foco ni configuraciones.
for (const marker of [
    "function reportKdeState(reason, force)",
    "snapshotRealWindows()",
    "hasProfile: Object.prototype.hasOwnProperty.call(saved, row.appId)",
    'console.log("SmartBar ESTADO KDE:"',
    "SoledadOffset=",
    'probe.reportKdeState("auditoria sin clic", false)',
    'onTaskFullScreenChanged: probe.scheduleWindowRecheck("fullscreen")',
    'onTaskActiveChanged: probe.scheduleWindowRecheck("foco")',
    'onItemRemoved: probe.scheduleWindowRecheck("ventana retirada")',
    'probe.scheduleWindowRecheck("inicio")'
]) assert(qml.includes(marker), "Falta traza de roles KDE: " + marker);
const traceStart = qml.indexOf("    function reportKdeState(reason, force)");
const traceEnd = qml.indexOf("    // Durante arranque", traceStart);
assert(traceStart >= 0 && traceEnd > traceStart);
const traceBlock = qml.slice(traceStart, traceEnd);
for (const forbidden of [
    "profileSettings.setValue(", "profileSettings.remove(",
    "profileSettings.clear(", "requestActivate(", "requestClose(",
    "requestToggleMaximized("
]) assert(!traceBlock.includes(forbidden), "Traza invasiva: " + forbidden);
assert(traceBlock.includes("interval: 1000") &&
       traceBlock.includes("running: true") && traceBlock.includes("repeat: true"),
       "La traza es de un segundo, solo durante el ensayo");
assert(qml.includes("interval: 90000") && qml.includes("probe.close()"),
       "La traza termina con el ensayo");

// Diagnóstico de regresión: Steam perdió su posición al REABRIR la isla
// (sin entrar en Big Picture en esta última prueba). Solo lectura, sin
// sobrescribir el perfil de Steam, Brave ni la configuración del visor.
for (const marker of [
    'import "package/contents/ui/SoledadPositionProfiles.js" as SoledadPositionProfiles',
    "function logPositionStorage(reason)",
    "SoledadPositionProfiles.readProfiles(positionProfilesJson)",
    "SoledadPositionProfiles.validAppId(trackedAppId)",
    "IDs guardados=",
    "AppId observado=",
    "coincidencia=",
    'probe.logPositionStorage("inicio del ensayo")',
    'logPositionStorage("cambio de ventana/estado")'
]) assert(qml.includes(marker), "Falta diagnóstico de memoria Steam: " + marker);
assert((qml.match(/profileSettings\.setValue\(/g) || []).length === 1,
       "El diagnóstico jamás debe agregar escrituras a las preferencias");
assert(!qml.includes("profileSettings.remove(") &&
       !qml.includes("profileSettings.clear("),
       "No eliminar ni restaurar preferencias durante el diagnóstico");
assert(qml.includes('category: "plasma-smartbar-v01-fixed-input-positions"'),
       "Mantener almacenamiento aislado del visor histórico");

// La política pura nunca guarda por mover: guardar requiere invocar explícitamente.
const profiles = read("package/contents/ui/SoledadPositionProfiles.js");
assert(profiles.includes("function saveProfile(json, appId, offset, maxOffset)") &&
       profiles.includes("function resolveOffset(") &&
       profiles.includes("function clampOffset("),
       "Reutilizar la política ya probada de posiciones por aplicación");
// Regresión real: al SALIR de Big Picture IsActive puede quedar vacío
// aunque la ventana principal maximizada de Steam siga en TasksModel.
// No forzar Steam si KWin identifica otra ventana activa o un fullscreen.
const vm = require("node:vm");
const realActiveSource = read("package/contents/ui/RealActiveWindow.js")
    .replace(/^\s*\.pragma library\s*\n/, "");
const getExitCandidate = vm.runInNewContext(
    realActiveSource + "\n;fullscreenExitCandidate");
const steamMain = {
    appId: "steam", appName: "Steam", active: false,
    maximized: true, minimized: false, fullscreen: false
};
const braveMain = {
    appId: "brave-browser", appName: "Brave", active: false,
    maximized: true, minimized: false, fullscreen: false
};
assert.equal(getExitCandidate([steamMain, braveMain], "steam").appId,
             "steam", "Solo retomar Steam si era el AppId anterior");
assert.equal(getExitCandidate([steamMain, braveMain], "brave-browser").appId,
             "brave-browser", "La regla también debe funcionar con Brave");
assert.equal(getExitCandidate([steamMain], "no-guardada"), null,
             "No inventar aplicación distinta de la previamente activa");
assert.equal(getExitCandidate([steamMain], ""), null,
             "Sin identidad anterior no inferir una posición");
assert.equal(getExitCandidate([steamMain, {
    appId: "org.kde.konsole", active: true, minimized: false
}], "steam"), null, "Nunca sobreponer el perfil de Steam si Konsole es activa");
assert.equal(getExitCandidate([steamMain, {
    appId: "steam", active: true, minimized: false
}], "steam"), null, "Ventana activa conocida debe usar flujo normal");
assert.equal(getExitCandidate([steamMain, {
    appId: "steam", fullscreen: true, minimized: false
}], "steam"), null, "No reponer isla mientras siga fullscreen");
assert.equal(getExitCandidate([{
    appId: "steam", maximized: true, minimized: true, fullscreen: false
}], "steam"), null, "No elegir Steam minimizado");
assert.equal(getExitCandidate([{
    appId: "steam", maximized: false, minimized: false, fullscreen: false
}], "steam"), null, "Exigir ventana principal maximizada");
assert.equal(getExitCandidate([], "steam"), null, "Sin ventanas no hay retorno");
for (const marker of [
    "property string lastRegularProfileAppId:",
    "property string fullscreenReturnAppId:",
    "property bool fullscreenObserved:",
    "property bool fullscreenExitPending:",
    "fullscreenReturnAppId = lastRegularProfileAppId",
    "fullscreenExitPending = fullscreenReturnAppId.length > 0",
    "function recoverFullscreenExit()",
    "RealActiveWindow.fullscreenExitCandidate(",
    "snapshotRealWindows(), fullscreenReturnAppId",
    "bar.draggingIslandGrip",
    "bar.islandOffset !== 0",
    "SoledadPositionProfiles.resolveOffset(",
    "bar.setIslandOffset(savedOffset)",
    "bar.alignRightSelected = savedOffset === 0",
    "fullscreenExitPending = false",
    "probe.recoverFullscreenExit()",
    "Qt.callLater(probe.recoverFullscreenExit)"
]) assert(qml.includes(marker), "Falta recuperación conservadora: " + marker);
assert((qml.match(/profileSettings\.setValue\(/g) || []).length === 1,
       "El retorno de Big Picture no debe guardar ninguna nueva preferencia");

// Inicio y regreso de fullscreen: reevaluación corta de roles KDE.
for (const marker of [
    "property int remainingStateRechecks: 0",
    "function scheduleWindowRecheck(reason)",
    "remainingStateRechecks = 12",
    "stateRecheckTimer.restart()",
    "interval: 250",
    "probe.refreshExternalWindow()",
    "probe.recoverProfileAfterSettling()",
    "probe.remainingStateRechecks--",
    "if (probe.remainingStateRechecks <= 0) stop()",
    "function recoverProfileAfterSettling()",
    "bar.draggingIslandGrip || bar.islandOffset !== 0",
    "!bar.activeRealAppHasSavedPosition",
    "bar.applyRealPositionProfile()",
    "onCountChanged: probe.scheduleWindowRecheck(\"cantidad ventanas\")",
    "onItemAdded: probe.scheduleWindowRecheck(\"ventana agregada\")",
    "onItemRemoved: probe.scheduleWindowRecheck(\"ventana retirada\")",
    "onTaskFullScreenChanged: probe.scheduleWindowRecheck(\"fullscreen\")",
    "Component.onCompleted: probe.scheduleWindowRecheck()"
]) assert(qml.includes(marker), "Falta reconciliación temporal: " + marker);
assert(!qml.includes("running: true\n        repeat: true"),
       "La observación de ventanas no debe ser sondeo permanente");
// Regresión reportada en Brave: menú «Alinear a la derecha» con perfil
// ya guardado debe volver al anclaje de esa app maximizada, NO a x=0.
for (const expected of [
    "readonly property bool activeRealAppHasSavedPosition:",
    "realTrackedMaximized && !realTrackedFullscreen",
    "realTrackedAppId.length > 0",
    "SoledadPositionProfiles.readProfiles(realPositionProfilesJson)",
    "realTrackedAppId)",
    "else if (activeRealAppHasSavedPosition) {",
    "soExpanded = false",
    "trayExpanded = false",
    "applyRealPositionProfile()",
    '"Volver a posición de " + root.realTrackedAppName',
    "root.activeRealAppHasSavedPosition"
]) assert(real.includes(expected), "Falta retorno contextual por perfil: " + expected);
const returnStart = real.indexOf("    function returnToConfiguredPosition() {");
const returnEnd = real.indexOf("    function setPreviewMaximized(", returnStart);
assert(returnStart >= 0 && returnEnd > returnStart);
const returnAction = real.slice(returnStart, returnEnd);
assert(returnAction.indexOf("activeRealAppHasSavedPosition") <
       returnAction.indexOf("applyRealPositionProfile()"),
       "La opción contextual debe comprobar perfil real antes de usarlo");
assert(returnAction.includes("else {\n            alignRightNow()"),
       "Sin perfil activo, mantener la derecha general");
assert(!qml.includes("trialControlsReservePx"),
       "No reintroducir margen horizontal arbitrario");

assert(real.includes("id: moveGrip") && real.includes("model: 6") &&
       real.includes("id: gripDrag"));
assert(real.includes("property bool layerShellDragCompensation: false") &&
       real.includes("root.offsetAtDragStart - activeTranslation.x"));
assert(real.includes('Qt.resolvedUrl("assets/so-tropical.gif")'));

for (const marker of [
    "CMAKE_AUTOMOC ON", "find_package(Qt6",
    "COMPONENTS Gui Qml Quick", "Qt6::Quick",
    "soledad_input_mask_main.cpp"
]) assert(cmake.includes(marker), "Falta compilación Qt: " + marker);
for (const marker of [
    "XDG_SESSION_TYPE", "WAYLAND_DISPLAY", "command -v cmake",
    "command -v c++", "mktemp -d",
    "trap cleanup EXIT", "rm -rf -- \"$BUILD_DIR\"",
    "QT_QPA_PLATFORM=wayland", "QT_WAYLAND_SHELL_INTEGRATION=layer-shell",
    "preview_soledad_input_mask.qml", "cmake --build"
]) assert(script.includes(marker), "Lanzador no seguro: " + marker);
for (const forbidden of [
    "sudo ", "pacman -S", "paru ", "yay ", "plasmapkg",
    "kpackagetool", "kwriteconfig", "qdbus", "systemctl",
    "killall", "pkill", "git reset"
]) assert(!script.includes(forbidden), "Lanzador invasivo: " + forbidden);

assert(!main.includes("preview_soledad_input_mask"));
assert(!viewer.includes("preview_soledad_input_mask"));
assert(previous.includes("right: 12 + Math.round(bar.islandOffset)"),
       "Preservar el ensayo anterior como evidencia para comparar.");
console.log("OK: superficie fija; perfiles reales existentes por aplicación; sin reserva fija ni cambios al panel.");
