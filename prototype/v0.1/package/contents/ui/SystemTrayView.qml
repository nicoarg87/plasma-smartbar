// Vista modular de los iconos de la bandeja.
// Repeater es el root intencionalmente: Qt inserta cada delegate como
// hijo directo del Row de Soledad, conservando la fila única, las
// medidas existentes y el recorte de transparencias de islandSurface.
import QtQuick
import QtQuick.Controls as QQC2

Repeater {
    id: trayView
    property var sourceEntries: []
    property bool expanded: false
    property color trayColor: "#010111"
    property real trayOpacity: 0.9
    property string trayOutlineStyle: "solid"
    property real trayOutlineWidth: 1
    property color trayOutlineColor: "#45647a"
    property real trayOutlineOpacity: 1
    signal iconActivated(string iconName)

    model: expanded ? sourceEntries : []

    delegate: IslandButton {
        required property string modelData
        text: modelData
        useTileColor: true
        tileColor: trayView.trayColor
        tileOpacity: trayView.trayOpacity
        outlineStyle: trayView.trayOutlineStyle
        outlineWidth: trayView.trayOutlineWidth
        outlineColor: trayView.trayOutlineColor
        outlineOpacity: trayView.trayOutlineOpacity
        onClicked: trayView.iconActivated(modelData)
        QQC2.ToolTip.visible: false
        QQC2.ToolTip.text: "Bandeja simulada: " + modelData
                             + " (no modifica el sistema)"
    }
}
