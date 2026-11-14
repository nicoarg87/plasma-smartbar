// Widget de prueba v0.1: ficha genérica sin animaciones.
import QtQuick
import QtQuick.Controls as QQC2

QQC2.Button {
    id: control

    property bool accent: false

    implicitHeight: 34
    implicitWidth: Math.max(40, label.implicitWidth + 18)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        radius: 17
        color: control.down ? "#254c61" : (control.hovered ? "#24425a" : (control.accent ? "#1f4e65" : "#14283d"))
        border.width: 1
        border.color: control.accent ? "#3dc6d4" : "#45647a"
    }

    contentItem: Text {
        id: label
        text: control.text
        color: control.enabled ? "#eaf7ff" : "#91a8b8"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        font.weight: control.accent ? Font.DemiBold : Font.Normal
        elide: Text.ElideRight
    }
}
