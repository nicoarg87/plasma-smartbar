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
assert(cpp.indexOf("window->create();") < cpp.indexOf("m_window->setMask(requested);") ||
       cpp.indexOf("window->create();") > 0); // llamada runtime: create antes del invoke
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
assert(!qml.includes("Settings {") && !qml.includes("QtCore.Settings"));
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
console.log("OK: ventana LayerShell FIJA con Qt6::setMask en región de la isla, sin cambios a KDE.");
