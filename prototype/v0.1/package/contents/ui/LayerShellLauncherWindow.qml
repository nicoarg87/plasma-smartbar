// Superficie flotante separada para el launcher en KWin/Wayland.
// No sustituye al panel KDE ni reserva espacio (exclusionZone -1).
// Se usa solo al ejecutar ambas islas mediante probar_islas_juntas.sh.
// Su borde superior comienza DEBAJO de la isla, nunca en y=0.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell

Window {
    id: shellLauncher
    property var ownerBar: null
    property bool runtimeActive: false
    property real topOffset: 52

    // Mantener mapeada la superficie física mientras se solicita el
    // launcher. Un cierre involuntario de Popup.Item no debe ocultar
    // el Window LayerShell que lo contiene.
    visible: runtimeActive && ownerBar !== null &&
             ownerBar.installedLauncherPopupVisible &&
             !ownerBar.realTrackedFullscreen
    width: Math.max(1, ownerBar ? Math.ceil(ownerBar.installedLauncherPopupWidth) : 1)
    height: Math.max(1, ownerBar ? Math.ceil(ownerBar.installedLauncherPopupHeight) : 1)
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    title: "Plasma SmartBar — launcher experimental"
    // Ningún vínculo con la ventana superior de 44 px: es una capa
    // independiente y evita que Wayland reposicione un xdg_popup arriba.
    transientParent: null

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorLeft
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityOnDemand
    LayerShell.Window.margins: ({
        left: ownerBar ? Math.max(0, Math.round(ownerBar.installedLauncherScreenLeft)) : 0,
        top: Math.max(48, Math.round(topOffset)),
        right: 0, bottom: 0
    })

    // El área de entrada de esta superficie es EXACTAMENTE el rectángulo
    // del launcher. No hay un Window de pantalla completa que bloquee KDE.
    onVisibleChanged: {
        if (visible) console.log("SmartBar launcher LayerShell debajo de isla:",
                                 "x=", ownerBar.installedLauncherScreenLeft,
                                 "y=", Math.round(topOffset), "w=", width, "h=", height)
    }
}
