"use strict";
// Comprobación estática del menú flotante en la sesión LayerShell conjunta.
// No sustituye el ensayo Qt/KWin nativo ni la apertura de apps en CachyOS.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const source = p => fs.readFileSync(path.join(root, p), "utf8");
const popup = source("package/contents/ui/SoLauncherPopup.qml");
const bar = source("package/contents/ui/SmartBarContent.qml");
const so = source("preview_soledad_input_mask.qml");
const mal = source("preview_malvina_input_mask.qml");
const native = source("native_probes/soledad_input_mask_main.cpp");
const script = source("probar_islas_juntas.sh");
const catalog = source("catalogo_aplicaciones.py");

for (const token of [
    "popupType: realLaunchEnabled ? QQC2.Popup.Window : QQC2.Popup.Item",
    "signal launchDesktopEntry(string desktopId)",
    "launcher.selectApplication(modelData)",
    "realLaunchEnabled && launcher.catalogIsReal",
    "launcher.appMatches()"
]) assert(popup.includes(token), "Popup QML: "+token);
assert(!popup.includes("launcher.appSelected(label, launcher.catalogIsReal)"),
       "No enviar texto de categoría como si fuera app real");
assert(bar.includes("property bool realAppLaunchEnabled: false"),
       "No cambiar comportamiento del visor habitual");
assert(bar.includes("signal requestLaunchDesktopEntry(string desktopId)"));
assert(bar.includes("realLaunchEnabled: root.realAppLaunchEnabled"));
// Regresión visual informada por el mantenedor: con Popup.Window
// anclado al root de LayerShell, KWin lo colocaba en y=0 sobre Soledad.
// El mismo mecanismo del gripMenu (botón como parent) debe usarse aquí.
const launcherBlock = bar.slice(bar.indexOf("    SoLauncherPopup {"),
    bar.indexOf("\n    Item {", bar.indexOf("    SoLauncherPopup {")));
assert(launcherBlock.includes("parent: root.realAppLaunchEnabled") &&
       launcherBlock.includes("? soButton : launcherIsland)") &&
       launcherBlock.includes(": root"),
       "El Popup.Window experimental debe anclarse al botón y preservar el visor");
assert(launcherBlock.includes("return left - anchor.mapToItem(root, 0, 0).x"),
       "Convertir el origen del Popup.Window a coordenadas del botón");
assert(launcherBlock.includes("? soButton.height + 8 : launcherIsland.height + 8"),
       "En Wayland el Popup debe abrirse DEBAJO del botón, no desde y=0");
assert(launcherBlock.includes("Math.max(0, root.width - width)"),
       "La ventana emergente debe mantenerse dentro del ancho de pantalla");
assert(bar.includes("parent: moveGrip") &&
       bar.includes("popupType: QQC2.Popup.Window"),
       "No alterar el menú de los seis puntos que ya se ve bien");
assert(so.includes("realAppLaunchEnabled: smartbarContinuousMode"));
assert(mal.includes("realAppLaunchEnabled: smartbarContinuousMode"));
assert(so.includes("LayerShell.Window.KeyboardInteractivityOnDemand"),
       "El lanzador SO necesita teclado al abrir un popup");
assert(native.includes("Q_INVOKABLE bool launchDesktopEntry("));
assert(native.includes("QStandardPaths::ApplicationsLocation"));
assert(native.includes('QStringLiteral("kioclient6")'));
assert(native.includes('QStringList{QStringLiteral("exec"), entry.absoluteFilePath()}'));
assert(native.includes("safeId.match(desktopId)"),
       "No aceptar rutas ni argumentos de entradas .desktop");
assert(!native.includes("sh -c") && !native.includes("sudo "));
assert(catalog.includes('"desktopId": filename.name'),
       "Preservar identidad KDE para apps de nombres repetidos");
assert(script.includes("python3 \"$HERE/catalogo_aplicaciones.py\""),
       "El ensayo debe preparar un catálogo local real");
assert(script.includes("CATALOG_CREATED=0") &&
       script.includes('if (( CATALOG_CREATED == 1 ))'),
       "Limpiar solo el catálogo creado por esta sesión");
assert(script.includes("QML_XHR_ALLOW_FILE_READ=1"));
assert(!script.includes("QT_WAYLAND_SHELL_INTEGRATION=layer-shell"),
       "No aplicar LayerShell globalmente al Popup.Window");
console.log("OK: launcher flotante independiente y ejecución KDE optativa");
