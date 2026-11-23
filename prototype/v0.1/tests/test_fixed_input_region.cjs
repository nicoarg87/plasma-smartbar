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
    "onIslandOffsetChanged: {",
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
// Regla confirmada: fullscreen conserva la ÚLTIMA posición visible, incluso
// si un chat auxiliar obtiene foco al salir. No crear perfiles extra por chat.
const vm = require("node:vm");
const realActiveSource = read("package/contents/ui/RealActiveWindow.js")
    .replace(/^\s*\.pragma library\s*\n/, "");
const activePolicy = vm.runInNewContext(realActiveSource +
    "\n;({resolve, shouldKeepNormalFocusPosition, uniqueMaximizedProfile, fallbackAfterActiveUnmaximize, topmostMaximizedProfile})");
function qmlFunction(name) {
    const marker = "    function " + name + "(";
    const start = qml.indexOf(marker);
    assert(start >= 0, "Falta función QML: " + name);
    const open = qml.indexOf("{", start);
    let depth = 0;
    for (let i = open; i < qml.length; ++i) {
        if (qml[i] === "{") ++depth;
        else if (qml[i] === "}" && --depth === 0)
            return qml.slice(start, i + 1);
    }
    throw new Error("Función QML sin cierre: " + name);
}
const simulation = {
    lastVisibleIslandOffset: 0,
    lastVisibleIslandKnown: false,
    positionProfilesJson: '{"brave-browser":125.4140625,"steam":369}',
    fullscreenSavedIslandOffset: 0,
    fullscreenObserved: false,
    fullscreenAnchorHeld: false,
    fullscreenExited: false,
    fullscreenPriorAppId: "",
    fullscreenFocusSettled: false,
    fullscreenTransitionFocusIds: {},
    trackedAppId: "steam",
    trackedAppName: "Steam",
    trackedKnown: true,
    trackedMaximized: true,
    trackedFullscreen: false,
    heldNormalFocusAppId: "",
    positionTransitionRevision: 0,
    lastTopMaximizedSignature: "",
    SoledadPositionProfiles: {readProfiles(json) {return JSON.parse(json);}},
    rows: [],
    kdeWindows: {count: 3},
    bar: {
        islandOffset: 320, maxIslandOffset: 1000,
        width: 1920, actualIslandWidth: 180,
        draggingIslandGrip: false, activeRealAppHasSavedPosition: true,
        alignRightSelected: false, mockProfileOffset: 115,
        setIslandOffset(value) { this.islandOffset = Math.max(0, Math.min(1000, value)); },
        ensureExpansionFits() {},
        applyRealPositionProfile() { this.islandOffset = this.mockProfileOffset; },
        alignRightNow() { this.islandOffset = 0; }
    },
    Qt: {callLater(callback) {callback();}},
    fullscreenFocusTimer: {restart() {}, stop() {}},
    RealActiveWindow: activePolicy,
    console: {log() {}},
    logPositionStorage() {},
    scheduleWindowRecheck() {},
    refreshInputRegion() {},
};
simulation.probe = simulation;
simulation.snapshotRealWindows = () => simulation.rows;
vm.runInNewContext([
    qmlFunction("recoverInitialMaximizedAnchor"),
    qmlFunction("rememberVisibleIslandOffset"),
    qmlFunction("restoreLastFullscreenPosition"),
    qmlFunction("refreshExternalWindow")
].join("\n\n"), simulation);
simulation.rememberVisibleIslandOffset();
assert.equal(simulation.lastVisibleIslandOffset, 320,
             "Antes de fullscreen se recuerda la coordenada VISIBLE");
const steamMain = {
    appId: "steam", appName: "Steam", active: false,
    maximized: true, minimized: false, fullscreen: false,
    stackingOrder: 1
};
const steamBigPicture = {
    appId: "steam", appName: "Steam", active: true,
    maximized: false, minimized: false, fullscreen: true
};
const steamChat = {
    appId: "steam-chat", appName: "Steam Chat", active: true,
    maximized: false, minimized: false, fullscreen: false
};
simulation.rows = [steamMain, steamBigPicture];
simulation.refreshExternalWindow();
assert.equal(simulation.fullscreenSavedIslandOffset, 320,
             "Entrar a fullscreen captura el último desplazamiento visible");
assert.equal(simulation.fullscreenAnchorHeld, true);
simulation.bar.islandOffset = 0; // simular retorno a derecha durante transición
simulation.rows = [steamMain, steamChat];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 320,
             "Salir a chat no maximizado restaura la última ubicación sin clic");
assert.equal(simulation.fullscreenTransitionFocusIds["steam-chat"], true,
             "Foco del chat es contexto de salida, no aplicación configurada aparte");
simulation.rows = [steamMain, {...steamChat, appId: "steamwebhelper"}];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 320,
             "Foco auxiliar tardío no fuerza derecha durante estabilización");
// Steam sigue maximizado detrás de Brave; un chat puede desaparecer
// sin que se haya agotado el tiempo de transición de fullscreen.
simulation.rows = [{...steamMain, active: true}];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 320,
             "Cerrar chat conserva posición de Steam principal");
// REGRESIÓN del mantenedor: clic en Brave con YouTube reproduciéndose
// DURANTE la estabilización, mientras Steam permanece maximizado detrás.
simulation.fullscreenFocusSettled = false;
simulation.rows = [steamMain, {
    appId: "brave-browser", appName: "Brave", active: true,
    maximized: true, minimized: false, fullscreen: false,
    stackingOrder: 2
}];
simulation.refreshExternalWindow();
assert.equal(simulation.fullscreenAnchorHeld, false,
             "Brave maximizado libera memoria de Steam incluso durante 1,8 s");
assert.equal(simulation.bar.islandOffset, 125.4140625,
             "El cambio real a Brave recupera SU perfil sin minimizar Steam");
// El simulador no emite onIslandOffsetChanged automáticamente: imitar
// la señal de QML para actualizar la memoria visual de Brave.
simulation.rememberVisibleIslandOffset();
assert.equal(simulation.lastVisibleIslandOffset, 125.4140625,
             "La última posición visible ahora pertenece a Brave");
simulation.rows = [steamMain, {
    appId: "brave-browser", appName: "Brave", active: true,
    maximized: false, minimized: false, fullscreen: true
}];
simulation.refreshExternalWindow();
assert.equal(simulation.fullscreenSavedIslandOffset, 125.4140625,
             "YouTube fullscreen captura posición de Brave, NO Steam");
simulation.bar.islandOffset = 0;
simulation.rows = [steamMain, {
    appId: "brave-browser", appName: "Brave", active: true,
    maximized: true, minimized: false, fullscreen: false,
    stackingOrder: 2
}];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
             "Salir de YouTube sin clic devuelve la posición de Brave");
assert.equal(simulation.fullscreenAnchorHeld, true,
             "La salida fullscreen conserva momentáneamente anclaje de Brave");
simulation.fullscreenAnchorHeld = true;
simulation.fullscreenExited = true;
simulation.bar.draggingIslandGrip = true;
simulation.bar.islandOffset = 470;
simulation.rememberVisibleIslandOffset();
assert.equal(simulation.fullscreenAnchorHeld, false,
             "Arrastre manual cancela la posición temporal");
assert.equal(simulation.lastVisibleIslandOffset, 470,
             "Arrastre actualiza última posición visible");
// Regresión real CachyOS 23/11: Brave max detrás, foco en Steam restaurada.
 // El cambio de FOCO conserva la coordenada de Brave, pero maximizar Steam
 // aplica su perfil; desmaximizar la propia Steam retorna a la derecha.
const braveMax = {
    appId: "brave-browser", appName: "Brave", active: true,
    maximized: true, minimized: false, fullscreen: false,
    stackingOrder: 1
};
const steamNormal = {
    appId: "steam", appName: "Steam", active: false,
    maximized: false, minimized: false, fullscreen: false,
    stackingOrder: 2
};
const steamFocus = {...steamNormal, active: true};
assert.equal(activePolicy.shouldKeepNormalFocusPosition(
    [{...braveMax, active: false}, steamFocus],
    {appId: "steam", maximized: false, fullscreen: false, known: true},
    "brave-browser", ""), true,
    "Enfocar Steam restaurada con Brave maximizada debe conservar la posición");
assert.equal(activePolicy.shouldKeepNormalFocusPosition(
    [{...braveMax, active: false}, steamFocus],
    {appId: "steam", maximized: false, fullscreen: false, known: true},
    "steam", "steam"), true,
    "La siguiente lectura KDE no debe perder la retención temporal");
assert.equal(activePolicy.shouldKeepNormalFocusPosition(
    [steamFocus],
    {appId: "steam", maximized: false, fullscreen: false, known: true},
    "brave-browser", "steam"), false,
    "Sin ninguna maximizada detrás se recupera retorno general");
assert.equal(activePolicy.shouldKeepNormalFocusPosition(
    [{...braveMax, active: false}, {...steamFocus, maximized: true}],
    {appId: "steam", maximized: true, fullscreen: false, known: true},
    "brave-browser", "steam"), false,
    "Maximizar Steam debe liberar el retén y cargar su perfil");
assert.equal(activePolicy.shouldKeepNormalFocusPosition(
    [{...braveMax, active: false}, steamFocus],
    {appId: "steam", maximized: false, fullscreen: false, known: true},
    "steam", ""), false,
    "Desmaximizar la MISMA ventana no es un cambio de foco");
assert.equal(activePolicy.shouldKeepNormalFocusPosition(
    [{...braveMax, active: false}, steamFocus],
    {appId: "steam", maximized: false, fullscreen: true, known: true},
    "brave-browser", ""), false,
    "Fullscreen nunca usa la retención de foco normal");

// KDE StackingOrder: mayor índice significa ventana más arriba.
const visibleProfiles = JSON.parse(simulation.positionProfilesJson);
const stackedBrave = {appId: "brave-browser", active: false,
    maximized: true, minimized: false, fullscreen: false, stackingOrder: 3};
const stackedSteam = {appId: "steam", active: true,
    maximized: true, minimized: false, fullscreen: false, stackingOrder: 5};
assert.equal(activePolicy.topmostMaximizedProfile(
    [stackedBrave, stackedSteam], visibleProfiles).appId, "steam",
    "Steam apilada arriba prevalece aunque no sea unica maximizada");
assert.equal(activePolicy.topmostMaximizedProfile(
    [{...stackedBrave, stackingOrder: 8}, stackedSteam],
    visibleProfiles).appId, "brave-browser",
    "Brave elevada por KWin debe pasar a ser la referencia");
assert.equal(activePolicy.topmostMaximizedProfile(
    [stackedBrave, {...stackedSteam, stackingOrder: 3}],
    visibleProfiles).kind, "hold",
    "Indices duplicados asincronos no autorizan elegir una ventana");
assert.equal(activePolicy.topmostMaximizedProfile(
    [stackedBrave, {...stackedSteam, stackingOrder: -1}],
    visibleProfiles).kind, "hold",
    "Indice Wayland -1 no autoriza elegir entre varias maximizadas");
assert.equal(activePolicy.topmostMaximizedProfile(
    [stackedBrave, stackedSteam], {"brave-browser":125.4140625}).kind,
    "hold", "La ventana superior sin perfil no permite usar la inferior");
assert.equal(activePolicy.topmostMaximizedProfile(
    [{...stackedBrave, stackingOrder: -1}], visibleProfiles).appId,
    "brave-browser", "Con una sola maximizada no hace falta StackingOrder");
assert.equal(activePolicy.topmostMaximizedProfile(
    [{...stackedBrave, maximized:false}], visibleProfiles).kind,
    "none", "Sin ninguna maximizada se aplica retorno general");
assert.equal(activePolicy.fallbackAfterActiveUnmaximize(
    [stackedSteam], {appId:"brave-browser", known:true,
                     maximized:false, fullscreen:false},
    "brave-browser", true, visibleProfiles).appId, "steam",
    "Desmaximizar Brave debe respetar Steam superior restante");

// Reproducir la cadena con las mismas funciones QML del ensayo.
simulation.bar.draggingIslandGrip = false;
simulation.fullscreenObserved = false;
simulation.fullscreenAnchorHeld = false;
simulation.fullscreenExited = false;
simulation.heldNormalFocusAppId = "";
simulation.trackedAppId = "brave-browser";
simulation.trackedAppName = "Brave";
simulation.trackedMaximized = true;
simulation.trackedFullscreen = false;
simulation.trackedKnown = true;
simulation.bar.islandOffset = 125.4140625;
simulation.bar.mockProfileOffset = 125.4140625;
simulation.rows = [braveMax, steamNormal];
simulation.refreshExternalWindow();
simulation.rows = [{...braveMax, active: false}, steamFocus];
simulation.bar.mockProfileOffset = 0; // perfil cero si se aplicara erróneamente
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
    "Foco Steam restaurada NO debe mover Soledad a la derecha");
assert.equal(simulation.heldNormalFocusAppId, "steam");
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
    "Relectura de KWin conserva la posición mientras Brave sigue maximizada");
simulation.rows = [{...braveMax, active: false}, {...steamFocus, maximized: true,
                    stackingOrder: 3}];
simulation.bar.mockProfileOffset = 369;
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 369,
    "Maximizar Steam recupera el perfil de Steam");
assert.equal(simulation.heldNormalFocusAppId, "");
simulation.rows = [{...braveMax, active: false}, steamFocus];
simulation.bar.mockProfileOffset = 0;
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
    "Desmaximizar Steam activa recupera perfil de Brave maximizada detrás");
simulation.rows = [{...braveMax, stackingOrder: 4}, steamNormal];
simulation.bar.mockProfileOffset = 125.4140625;
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
    "Volver a Brave maximizada recupera su perfil");
simulation.rows = [{...braveMax, active: false}, steamFocus];
simulation.bar.mockProfileOffset = 0;
simulation.refreshExternalWindow();
assert.equal(simulation.heldNormalFocusAppId, "steam");
simulation.rows = [
    {...braveMax, active: false, maximized: false}, steamFocus
];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 0,
    "Al desaparecer la última maximizada se retorna a derecha");
assert.equal(simulation.heldNormalFocusAppId, "",
    "Sin ventana maximizada no debe quedar retención temporal");

assert(qml.includes('property string heldNormalFocusAppId: ""') &&
       qml.includes("RealActiveWindow.shouldKeepNormalFocusPosition(") &&
       qml.includes('console.log("SmartBar foco restaurado: conserva posicion"'),
       "La política de foco normal debe estar conectada al ensayo aislado");
assert.equal((qml.match(/profileSettings\.setValue\(/g) || []).length, 1,
    "Conservar retención de foco no debe escribir perfiles");

// REGRESIÓN DE ARRANQUE 23/11 (nueva captura): la terminal mantiene
// foco al ejecutar el ensayo, Brave está maximizada DETRÁS y Steam normal.
// La primera coordenada debe venir del ÚNICO perfil maximizado, no de 0.
const consoleFocus = {
    appId: "Alacritty", appName: "Alacritty", active: true,
    maximized: false, minimized: false, fullscreen: false
};
const savedTwo = JSON.parse(simulation.positionProfilesJson);
assert.equal(activePolicy.uniqueMaximizedProfile([
    {...braveMax, active: false}, steamNormal, consoleFocus
], savedTwo).offset, 125.4140625,
"Un único fondo maximizado con perfil identifica anclaje de arranque");
assert.equal(activePolicy.uniqueMaximizedProfile([
    {...braveMax, active: false}, {...steamNormal, maximized: true},
    consoleFocus
], savedTwo).known, false,
"No adivinar entre Brave y Steam maximizadas al arrancar");
assert.equal(activePolicy.uniqueMaximizedProfile([
    {...braveMax, active: false}, steamNormal, consoleFocus
], {}).known, false,
"No inventar anclaje si faltan perfiles guardados");
simulation.fullscreenObserved = false;
simulation.fullscreenAnchorHeld = false;
simulation.fullscreenExited = false;
simulation.lastVisibleIslandKnown = false;
simulation.lastVisibleIslandOffset = 0;
simulation.heldNormalFocusAppId = "";
simulation.trackedAppId = "";
simulation.trackedAppName = "";
simulation.trackedMaximized = false;
simulation.trackedFullscreen = false;
simulation.trackedKnown = false;
simulation.bar.islandOffset = 0;
simulation.bar.mockProfileOffset = 0;
simulation.rows = [{...braveMax, active: false}, steamNormal, consoleFocus];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
"Arranque con Konsole activa debe recolocar Soledad según Brave max detrás");
assert.equal(simulation.heldNormalFocusAppId, "Alacritty",
"No aplicar retorno general al procesar la terminal activa");
assert.equal(simulation.lastVisibleIslandKnown, true,
"El anclaje de arranque se conserva como contexto visual");
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
"Relecturas de TasksModel no deben volver a cero desde terminal");
simulation.rows = [
    {...braveMax, active: false}, {...steamNormal, active: true},
    {...consoleFocus, active: false}
];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
"Minimizar Konsole y enfocar Steam restaurada conserva anclaje Brave");
simulation.rows = [
    {...braveMax, active: false}, {...steamNormal, active: true,
                                    maximized: true, stackingOrder: 3}
];
simulation.bar.mockProfileOffset = 369;
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 369,
"Maximizar Steam tras arrancar desde Konsole aplica perfil Steam");
assert.equal(simulation.heldNormalFocusAppId, "",
"La retención temporal no bloquea Steam maximizada");
simulation.rows = [
    {...braveMax, active: true, stackingOrder: 4},
    {...steamNormal, active: false, maximized: true, stackingOrder: 3}
];
simulation.bar.mockProfileOffset = 125.4140625;
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
"Cambiar a Brave maximizada recupera su perfil, no Steam");
// Integración de QML: dos ventanas maximizadas, cambia SOLO el
// apilamiento de KWin sin cambiar el foco de Steam. La isla debe seguir
// la que pasó al frente (Brave) aun con Steam todavía activa.
simulation.fullscreenObserved = false;
simulation.fullscreenAnchorHeld = false;
simulation.fullscreenExited = false;
simulation.positionTransitionRevision = 0;
simulation.lastTopMaximizedSignature = "";
simulation.heldNormalFocusAppId = "";
simulation.trackedAppId = "steam";
simulation.trackedAppName = "Steam";
simulation.trackedKnown = true;
simulation.trackedMaximized = true;
simulation.trackedFullscreen = false;
simulation.bar.draggingIslandGrip = false;
simulation.bar.islandOffset = 369;
simulation.rows = [stackedBrave, stackedSteam];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 369,
    "Steam al frente mantiene su perfil");
simulation.rows = [{...stackedBrave, stackingOrder: 8}, stackedSteam];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
    "Cambio de apilamiento sin cambio de foco debe recuperar Brave superior");
simulation.rows = [stackedBrave, stackedSteam];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 369,
    "Steam vuelve al frente y recupera su propio perfil");
simulation.rows = [{...stackedBrave, stackingOrder: 5}, stackedSteam];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 369,
    "Empate de apilamiento conserva coordenada, no inventa ganador");
simulation.rows = [{...stackedBrave, stackingOrder: 8}, stackedSteam];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 125.4140625,
    "Cuando KDE resuelve el empate retoma el perfil superior");
simulation.rows = [
    {...stackedBrave, stackingOrder: 3, maximized: false, active: true},
    {...stackedSteam, active: false, stackingOrder: 5}
];
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 369,
    "Brave restaurada sobre Steam maximizada usa perfil de Steam visible");
simulation.rows = [
    {...stackedBrave, stackingOrder: 3, maximized: false, active: true},
    {...stackedSteam, maximized: false, active: false}
];
// El mock no implementa resolveOffset: simular el retorno real para
// una ventana activa que ya no está maximizada.
simulation.bar.mockProfileOffset = 0;
simulation.refreshExternalWindow();
assert.equal(simulation.bar.islandOffset, 0,
    "Solo sin maximizadas restantes se vuelve a extrema derecha");

// Integración QML: observa el rol KDE sin instalar nada en KWin.
for (const required of [
    "readonly property var taskStackingOrder: model.StackingOrder",
    "stackingOrder: taskStackingOrder",
    'onTaskStackingOrderChanged: probe.scheduleWindowRecheck("apilamiento")',
    "RealActiveWindow.topmostMaximizedProfile(",
    'currentTop.kind === "profile"',
    'currentTop.kind === "hold"',
    'console.log("SmartBar maximizada superior:"'
]) assert(qml.includes(required), "Falta prioridad visual KDE: " + required);

assert(qml.includes("function recoverInitialMaximizedAnchor(rows)") &&
       qml.includes("RealActiveWindow.topmostMaximizedProfile(") &&
       qml.includes('console.log("SmartBar inicio anclaje: maximizada superior"'),
       "El ensayo incluye la reconciliación inicial sin nuevos botones");
assert.equal((qml.match(/profileSettings\.setValue\(/g) || []).length, 1,
       "La reconciliación inicial no debe escribir perfiles");

for (const marker of [
    "property real lastVisibleIslandOffset: 0",
    "property real fullscreenSavedIslandOffset: 0",
    "property bool fullscreenAnchorHeld: false",
    "function rememberVisibleIslandOffset()",
    "function restoreLastFullscreenPosition()",
    "fullscreenSavedIslandOffset = lastVisibleIslandKnown",
    "fullscreenAnchorHeld = true",
    "fullscreenExited = true",
    "function snapshotRealWindows()",
    "fullscreenTransitionFocusIds[active.appId] = true",
    "active.maximized && !active.fullscreen",
    "active.appId !== fullscreenPriorAppId",
    'console.log("SmartBar fullscreen: nueva aplicacion maximizada"',
    "if (!probe.fullscreenAnchorHeld)",
    "probe.restoreLastFullscreenPosition()",
    "probe.rememberVisibleIslandOffset()"
]) assert(qml.includes(marker), "Falta retener posición visible: " + marker);
assert(!qml.includes("fullscreenExitCandidate(") &&
       !realActiveSource.includes("fullscreenExitCandidate"),
       "No volver a inferir un perfil de aplicación a partir del fullscreen");
assert(!qml.includes("steam-chat") && !qml.includes("steamwebhelper"),
       "No introducir excepciones rígidas por ventana auxiliar de Steam");
assert((qml.match(/profileSettings\.setValue\(/g) || []).length === 1,
       "La memoria de fullscreen NO debe escribir preferencias locales");

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
    "trackedFullscreen || bar.draggingIslandGrip",
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
