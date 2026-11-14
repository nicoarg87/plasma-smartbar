// Ventana independiente para validar el redimensionado con el MISMO
// SmartBarContent que usa el plasmoide. No instala nada ni toca paneles.
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import "package/contents/ui"

Window {
    id: previewWindow
    width: 1000
    height: 320
    minimumWidth: 760
    minimumHeight: 210
    visible: true
    title: "Plasma SmartBar v0.1 — prueba redimensionable (sin panel)"
    color: "#242236"

    property bool demoAutoReturnRight: true
    property bool demoLauncherIslandVisible: true
    property bool demoAutoCollapseSO: true
    property bool demoAutoCollapseTray: false
    // Estados de sesión de la maqueta (el panel KDE no se instala).
    property string demoSoLogoMode: "default"
    property string demoSoLogoPath: ""
    property string demoSoLogoShape: "square"
    property real demoSoLogoZoom: 1
    property real demoSoLogoPanX: 0
    property real demoSoLogoPanY: 0
    property bool demoSoLogoAnimate: true
    property color demoSoledadColor: "#101e31"
    property color demoMalvinaColor: "#101e31"
    property color demoBackgroundColor: "#202333"
    property real demoSoledadOpacity: 1
    property real demoMalvinaOpacity: 1
    property real demoBackgroundOpacity: 0.5
    property bool demoShowBackground: false

    SmartBarContent {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: fixedHeight

        autoReturnRight: previewWindow.demoAutoReturnRight
        launcherIslandVisible: previewWindow.demoLauncherIslandVisible
        autoCollapseSO: previewWindow.demoAutoCollapseSO
        autoCollapseTray: previewWindow.demoAutoCollapseTray
        soLogoMode: previewWindow.demoSoLogoMode
        soLogoPath: previewWindow.demoSoLogoPath
        soLogoShape: previewWindow.demoSoLogoShape
        soLogoZoom: previewWindow.demoSoLogoZoom
        soLogoPanX: previewWindow.demoSoLogoPanX
        soLogoPanY: previewWindow.demoSoLogoPanY
        soLogoAnimate: previewWindow.demoSoLogoAnimate
        soledadColor: previewWindow.demoSoledadColor
        malvinaColor: previewWindow.demoMalvinaColor
        backgroundColor: previewWindow.demoBackgroundColor
        soledadOpacity: previewWindow.demoSoledadOpacity
        malvinaOpacity: previewWindow.demoMalvinaOpacity
        backgroundOpacity: previewWindow.demoBackgroundOpacity
        showBackground: previewWindow.demoShowBackground
        onRequestSoLogoChange: function(mode, path, shape, zoom, panX, panY, allowGif) {
            previewWindow.demoSoLogoMode = mode
            previewWindow.demoSoLogoPath = path
            previewWindow.demoSoLogoShape = shape
            previewWindow.demoSoLogoZoom = zoom
            previewWindow.demoSoLogoPanX = panX
            previewWindow.demoSoLogoPanY = panY
            previewWindow.demoSoLogoAnimate = allowGif
        }
        onRequestAppearanceChange: function(a, alphaA, b, alphaB, shown, bg, alphaBg) {
            previewWindow.demoSoledadColor = a
            previewWindow.demoSoledadOpacity = alphaA
            previewWindow.demoMalvinaColor = b
            previewWindow.demoMalvinaOpacity = alphaB
            previewWindow.demoShowBackground = shown
            previewWindow.demoBackgroundColor = bg
            previewWindow.demoBackgroundOpacity = alphaBg
        }
        onRequestAutoReturnRightChange: function(newValue) {
            previewWindow.demoAutoReturnRight = newValue
        }
        onRequestLauncherIslandVisibilityChange: function(newValue) {
            previewWindow.demoLauncherIslandVisible = newValue
        }
        onRequestAutoCollapseSOChange: function(newValue) {
            previewWindow.demoAutoCollapseSO = newValue
        }
        onRequestAutoCollapseTrayChange: function(newValue) {
            previewWindow.demoAutoCollapseTray = newValue
        }
    }

    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: bar.bottom
        anchors.topMargin: 28
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        wrapMode: Text.WordWrap
        color: "#f4edf9"
        text: "Vista independiente: arrastrá el borde de esta ventana o maximizala. " +
              "Isla 2 debe quedar a la izquierda; isla 1, SO y los controles de " +
              "muestra siguen el borde derecho. El fondo es solamente de la ventana de prueba."
    }

    // Diagnóstico visible EXCLUSIVAMENTE en esta ventana de prueba;
    // no es parte de la barra ni del plasmoide final.
    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: widthLabel.top
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 8
        color: "#c7bad8"
        font.pixelSize: 11
        wrapMode: Text.WordWrap
        text: "Soledad: " + (bar.soExpanded ? "SO abierto" : "SO cerrado") +
              " · " + (bar.trayExpanded ? "bandeja abierta" : "bandeja cerrada") +
              " · Malvina: " + (bar.launcherIslandVisible ? "visible" : "oculta") +
              " · SO autocierre: " + (bar.autoCollapseSO ? "sí" : "no") +
              " · bandeja autocierre: " + (bar.autoCollapseTray ? "sí" : "no") +
              "\nAncho Soledad: " + Math.round(bar.actualIslandWidth) +
              " / espacio disponible: " + Math.round(bar.availableIslandWidth) +
              " px lógicos · prioridad: " + (bar.lastExpandedMode === "so" ? "SO" : "bandeja")
    }

    QQC2.Label {
        id: widthLabel
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.bottomMargin: 12
        color: "#c7bad8"
        text: "Ancho del contenido: " + Math.round(bar.width) + " px lógicos"
    }

    onWidthChanged: console.log("SmartBar ventana independiente: ancho =", width)
}
