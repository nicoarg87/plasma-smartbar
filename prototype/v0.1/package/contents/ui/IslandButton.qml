// Ficha compacta compartida. Solo el botón SO puede usar un logo:
// imágenes fijas o GIF opcionales; las otras fichas no se animan.
import QtQuick
import QtQuick.Controls as QQC2

QQC2.Button {
    id: control
    property bool accent: false
    property url iconSource: ""
    property bool iconAnimated: false

    implicitHeight: 34
    // Ancho fijo para un logo: no altera la fila ni el alto al cambiarlo.
    implicitWidth: iconSource.toString().length > 0
                   ? 40 : Math.max(40, label.implicitWidth + 18)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        radius: 17
        color: control.down ? "#254c61" : (control.hovered ? "#24425a" : (control.accent ? "#1f4e65" : "#14283d"))
        border.width: 1
        border.color: control.accent ? "#3dc6d4" : "#45647a"
    }

    contentItem: Item {
        implicitWidth: Math.max(22, label.implicitWidth)
        implicitHeight: 28

        Image {
            id: stillIcon
            anchors.centerIn: parent
            width: 28
            height: 28
            visible: control.iconSource.toString().length > 0 && !control.iconAnimated
            source: visible ? control.iconSource : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
            sourceSize.width: 56
            sourceSize.height: 56
        }

        AnimatedImage {
            id: gifIcon
            anchors.centerIn: parent
            width: 28
            height: 28
            visible: control.iconSource.toString().length > 0 && control.iconAnimated
            source: visible ? control.iconSource : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            // Una sola animación pequeña a la vez; no cachear los cuadros.
            cache: false
            sourceSize.width: 56
            sourceSize.height: 56
            playing: visible && control.visible
        }

        Text {
            id: label
            anchors.fill: parent
            text: control.text
            // Si un archivo personalizado no existe, recuperar "SO".
            visible: control.iconSource.toString().length === 0 ||
                     (control.iconAnimated
                      ? gifIcon.status === Image.Error
                      : stillIcon.status === Image.Error)
            color: control.enabled ? "#eaf7ff" : "#91a8b8"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            font.weight: control.accent ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }
    }
}
