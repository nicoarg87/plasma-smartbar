// Diagnóstico diferencial: una SOLA ventana LayerShellQt interactiva.
// Aísla entrega de ratón de la prueba mixta anterior (dos Window).
// No instala nada, no guarda preferencias, no toca ventanas KDE.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell

Window {
    id: testWindow
    title: "Plasma SmartBar - control SO interactivo aislado"
    visible: true
    width: 64
    height: 48
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    property int pressCount: 0
    property bool pointerInside: false

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.margins: ({left: 0, top: 6, right: 12, bottom: 0})

    Rectangle {
        anchors.fill: parent
        color: "#194d76"
        radius: 10
        clip: true
        border.color: testWindow.pointerInside ? "#ffffff" : "#93ccee"
        border.width: testWindow.pointerInside ? 3 : 1

        AnimatedImage {
            anchors.fill: parent
            source: Qt.resolvedUrl("package/contents/ui/assets/so-tropical.gif")
            fillMode: Image.PreserveAspectCrop
            playing: true
        }
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 2
            radius: 5
            color: "#ed142335"
            border.color: "white"
            width: 22
            height: 20
            Text {
                anchors.centerIn: parent
                color: "white"
                text: String(testWindow.pressCount)
                font.bold: true
                font.pixelSize: 12
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            testWindow.pointerInside = true
            console.log("SmartBar SO INDIVIDUAL: HOVER RECIBIDO")
        }
        onExited: testWindow.pointerInside = false
        onPressed: function(mouse) {
            testWindow.pressCount += 1
            console.log("SmartBar SO INDIVIDUAL: PULSACION RECIBIDA",
                        testWindow.pressCount, "boton", mouse.button)
        }
    }
    Timer {
        running: true
        repeat: false
        interval: 60000
        onTriggered: testWindow.close()
    }
    Component.onCompleted: console.log(
        "SmartBar SO INDIVIDUAL: una sola superficie anclada arriba derecha.",
        "No se usa Qt.WindowTransparentForInput.",
        "HOVER y PULSACION deben aparecer en Konsole si KWin entrega eventos.",
        "Autocierre a 60s; Ctrl+C para cancelar.")
    onClosing: console.log("SmartBar SO INDIVIDUAL: ensayo terminado")
}
