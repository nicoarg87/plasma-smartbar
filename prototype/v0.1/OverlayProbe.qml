// Ventana descartable para estudiar superposición y paso de clics.
// NO es un plasmoide, NO cambia el panel, NO mueve ventanas de terceros.
// En Wayland KWin puede ignorar la posición y el apilamiento solicitados.
import QtQuick
import QtQuick.Window

Window {
    id: overlay
    property bool clickThrough: true
    property int observedClicks: 0

    title: "Plasma SmartBar — ensayo TEMPORAL de superposición"
    width: 456
    height: 44
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    // Solicitud no vinculante: los clientes Wayland no eligen posición
    // ni orden Z bajo el protocolo XDG Shell normal.
    x: Screen.virtualX + Math.max(0, Screen.width - width - 16)
    y: Screen.virtualY + 4
    visible: true
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint |
           (clickThrough
               ? (Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus)
               : 0)

    Rectangle {
        anchors.fill: parent
        radius: 11
        color: overlay.clickThrough ? "#df173b5d" : "#df5d3817"
        border.color: overlay.clickThrough ? "#a6dff9" : "#ffcf83"
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 9

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 27
                radius: 8
                color: "#28313d"
                border.color: "#d4e3f2"
                Text {
                    anchors.centerIn: parent
                    text: "SO"
                    color: "#f8fcff"
                    font.bold: true
                    font.pixelSize: 12
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: overlay.clickThrough
                        ? "ENSAYO PASIVO · clics pasan a Brave"
                        : "ENSAYO INTERACTIVO · clics en esta franja"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 12
                }
                Text {
                    text: overlay.clickThrough
                        ? "Franja demostrativa, no es Soledad real"
                        : "Clics recibidos: " + overlay.observedClicks + " · Escape para salir"
                    color: "#e3e8ef"
                    font.pixelSize: 10
                }
            }
        }
    }

    // Solo el ensayo interactivo recibe clics; el pasivo usa una
    // región de entrada VACÍA a nivel de ventana Qt.
    MouseArea {
        anchors.fill: parent
        enabled: !overlay.clickThrough
        onClicked: overlay.observedClicks += 1
    }
    Item {
        anchors.fill: parent
        focus: !overlay.clickThrough
        enabled: !overlay.clickThrough
        Keys.onEscapePressed: overlay.close()
    }

    // Autocierre esencial: el modo pasivo no admite clics ni teclado.
    Timer {
        interval: 60000
        running: true
        repeat: false
        onTriggered: overlay.close()
    }
    Component.onCompleted: console.log(
        "SmartBar ensayo temporal", clickThrough ? "PASIVO" : "INTERACTIVO",
        "- ventana 456x44; cierre automático 60 s;",
        "posición solicitada", x, y,
        "(KWin/Wayland puede ignorarla)")
    onClosing: console.log("SmartBar ensayo temporal terminado, sin tocar panel.")
}
