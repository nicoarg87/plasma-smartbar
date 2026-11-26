import QtQuick
import QtQuick.Controls as QQC2

// Controles ficticios del visor Qt: no realizan acciones sobre ventanas KDE.
Rectangle {
    id: controlSurface
    width: windowControlsRow.implicitWidth + 12
    height: 44
    radius: 22
    color: "#101e31"
    border.color: "#4e8499"
    border.width: 1

    Row {
        id: windowControlsRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: ["−", "□", "×"]
            delegate: IslandButton {
                text: modelData
                enabled: false
                QQC2.ToolTip.text: "Control ficticio anclado a la derecha"
            }
        }
    }
}
