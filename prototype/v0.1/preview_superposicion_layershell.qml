// Ensayo exclusivo de capa Wayland con la tecnología oficial KDE LayerShellQt.
// NO instala panel, NO reserva espacio, NO controla ventanas, NO captura clics.
// Si LayerShellQt no está disponible, fallará el inicio del QML sin alterar KDE.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell

Window {
    id: probe
    visible: true
    width: 456
    height: 44
    color: "transparent"
    title: "Plasma SmartBar — prueba PASIVA LayerShellQt"
    flags: Qt.FramelessWindowHint |
           Qt.WindowTransparentForInput |
           Qt.WindowDoesNotAcceptFocus

    // NO utilizar x/y bajo XDG Shell: pedir anclaje al compositor.
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    // -1: no crear zona exclusiva ni mover el espacio de las apps maximizadas.
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityNone

    Rectangle {
        anchors.fill: parent
        color: "#df153c59"
        radius: 11
        border.width: 1
        border.color: "#9bdcf1"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            spacing: 12
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 27
                radius: 7
                color: "#273a50"
                border.color: "#f3f8ff"
                Text {
                    anchors.centerIn: parent
                    text: "SO"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 12
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 12
                    text: "ENSAYO LAYER-SHELL · PASIVO"
                }
                Text {
                    color: "#e3ebf4"
                    font.pixelSize: 10
                    text: "Arriba a la derecha · clics pasantes POR COMPROBAR"
                }
            }
        }
    }

    Timer {
        running: true
        repeat: false
        interval: 60000
        onTriggered: probe.close()
    }
    Component.onCompleted: console.log(
        "SmartBar LayerShellQt: prueba temporal pasiva; 456x44;",
        "anclaje superior derecho solicitado; sin zona exclusiva;",
        "autocierre 60 s; clics y apilamiento NO verificados")
    onClosing: console.log("SmartBar LayerShellQt: ensayo terminado")
}
