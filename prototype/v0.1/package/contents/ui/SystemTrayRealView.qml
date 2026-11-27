// Indicadores SNI reales de KDE: presentación experimental de SOLO LECTURA.
// Comparte IslandButton, colores y fila de bandeja; las acciones no están
// habilitadas hasta validar menús remotos, clics y foco bajo Wayland.
import QtQuick
import QtQuick.Controls as QQC2

Repeater {
    id: realTray
    property var sourceEntries: []
    property bool expanded: false
    property color trayColor: "#010111"
    property real trayOpacity: 0.9
    property string trayOutlineStyle: "solid"
    property real trayOutlineWidth: 1
    property color trayOutlineColor: "#45647a"
    property real trayOutlineOpacity: 1

    // Repeater crea los delegates directamente en la Row del componente padre.
    model: expanded ? sourceEntries : []
    delegate: IslandButton {
        required property var modelData
        readonly property string itemTitle: String(modelData.title || modelData.iconName || "Indicador KDE")
        readonly property string itemIcon: String(modelData.iconSource || "")
        text: itemIcon.length ? "" : "•"
        iconSource: itemIcon
        iconFitMode: "fit"
        preferredButtonWidth: 40
        preferredButtonHeight: 34
        useTileColor: true
        tileColor: realTray.trayColor
        tileOpacity: realTray.trayOpacity
        outlineStyle: realTray.trayOutlineStyle
        outlineWidth: realTray.trayOutlineWidth
        outlineColor: realTray.trayOutlineColor
        outlineOpacity: realTray.trayOutlineOpacity
        // Prohibir clics simulados sobre aplicaciones reales. Ningún
        // cambio KDE ni autocontracción por un icono todavía inactivo.
        enabled: false
        Accessible.name: itemTitle + " (indicador KDE, solo lectura)"
        QQC2.ToolTip.visible: false
    }
}
