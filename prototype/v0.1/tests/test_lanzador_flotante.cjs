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
const launcherBlock = source("package/contents/ui/SoledadLauncherHost.qml");
const gripMenu = source("package/contents/ui/SoledadGripMenu.qml");
const so = source("preview_soledad_input_mask.qml");
const mal = source("preview_malvina_input_mask.qml");
const native = source("native_probes/soledad_input_mask_main.cpp");
const script = source("probar_islas_juntas.sh");
const catalog = source("catalogo_aplicaciones.py");

for (const token of [
    "popupType: layerSurfaceHosted ? QQC2.Popup.Item :",
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
assert(launcherBlock.includes("realLaunchEnabled: host.realAppLaunchEnabled"));
// Regresión real repetida en KWin/Wayland: ni Popup.Window ni un
// desplazamiento relativo al botón evitaron la superposición con SO.
// En el ensayo conjunto, crear un Window LayerShell ACOTADO bajo SO y
// alojar un Popup.Item dentro de esa nueva superficie.

const host=source("package/contents/ui/LayerShellLauncherWindow.qml");
assert(popup.includes("layerSurfaceHosted ? QQC2.Popup.Item :"),
       "En ventana LayerShell el launcher debe ser Item, no otro Window");
assert(launcherBlock.includes("host.layerShellLauncherHost.contentItem") &&
       launcherBlock.includes("layerSurfaceHosted: root.realAppLaunchEnabled"),
       "El popup debe habitar el Window LayerShell creado para él");
assert(launcherBlock.includes("if (root.layerShellLauncherHost) return 0") &&
       launcherBlock.includes("host.layerShellLauncherHost ? 0 :"),
       "El popup comienza en 0,0 dentro de la nueva superficie");
assert(launcherBlock.includes("Math.min(root.launcherAvailableHeight, 760)"),
       "El cajón debe poder crecer hasta 760px si hay altura disponible");
assert(popup.includes("primaryWidth: realLaunchEnabled ? sharedColumnWidth : 285") &&
       popup.includes("categoryWidth: realLaunchEnabled ? sharedColumnWidth : 280") &&
       popup.includes("realLaunchEnabled ? 540 : 170"),
       "Aumentar alto y mantener ambas columnas con la misma proporción");
assert(popup.includes("Math.ceil(maxInstalledTextWidth() + 62)") &&
       popup.includes("Math.floor((Math.max(480, availableScreenWidth) - 42) / 2)"),
       "Adaptar anchura sin cortar bordes ni dejar espacio innecesario");
assert(bar.includes("calculateInstalledLauncherScreenLeft()") &&
       bar.includes("Math.max(0, screenWidth - popupWidth)"),
       "El ancho completo debe permanecer dentro de pantalla");
for(const expected of [
    "LayerShell.Window.AnchorTop", "LayerShell.Window.AnchorLeft",
    "LayerShell.Window.layer: LayerShell.Window.LayerTop",
    "LayerShell.Window.exclusionZone: -1",
    "LayerShell.Window.KeyboardInteractivityOnDemand",
    "top: Math.max(48, Math.round(topOffset))",
    "ownerBar.installedLauncherScreenLeft",
    "ownerBar.installedLauncherPopupWidth",
    "ownerBar.installedLauncherPopupHeight",
    "transientParent: null",
    "ownerBar.installedLauncherPopupVisible"
]) assert(host.includes(expected),"Falta superficie flotante segura: "+expected);
for(const probe of [so,mal]) {
    assert(probe.includes("SmartBar.LayerShellLauncherWindow {"),
           "Los dos procesos deben usar alojamiento LayerShell para launcher");
    assert(probe.includes("layerShellLauncherHost: smartbarContinuousMode ? launcherHost : null"),
           "El alojamiento no debe estar activo en el visor de 90/180s");
    assert(probe.includes("Math.min(760, probe.Screen.height - probe.height - 32)"),
           "Acotar altura al escritorio del usuario");
}
assert(gripMenu.includes("parent: gripTarget") &&
       gripMenu.includes("popupType: QQC2.Popup.Window"),
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
