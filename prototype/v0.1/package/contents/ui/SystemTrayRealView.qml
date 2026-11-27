// Indicadores SNI reales de KDE: iconos y acciones estándar.
// Las llamadas se delegan al puente Qt6 que valida el emisor; no se
// ejecuta nada por hover ni se registra otro host del escritorio.
import QtQuick
import QtQuick.Controls as QQC2

Repeater {
    id: realTray
    property var sourceEntries: []
    property var backend: null
    property bool expanded: false
    property color trayColor: "#010111"
    property real trayOpacity: 0.9
    property string trayOutlineStyle: "solid"
    property real trayOutlineWidth: 1
    property color trayOutlineColor: "#45647a"
    property real trayOutlineOpacity: 1
    signal actionRequested(string service, string objectPath, string action,
                           int x, int y)

    // Repeater crea los delegates directamente en la Row del componente padre.
    model: expanded ? sourceEntries : []
    delegate: IslandButton {
        id: indicator
        required property var modelData
        readonly property string itemTitle:
            String(modelData.title || modelData.iconName || "Indicador KDE")
        readonly property string itemIcon: String(modelData.iconSource || "")
        readonly property bool itemIsMenu: modelData.itemIsMenu === true
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
        enabled: true
        Accessible.name: itemTitle

        function requestAction(action) {
            if (!realTray.expanded) return
            // El protocolo espera coordenadas de pantalla como sugerencia.
            // Qt transforma la posición central del icono en el ensayo Wayland.
            const position = indicator.mapToGlobal(indicator.width / 2,
                                                    indicator.height / 2)
            realTray.actionRequested(String(modelData.service || ""),
                                     String(modelData.objectPath || ""),
                                     action, Math.round(position.x),
                                     Math.round(position.y))
        }

        onClicked: requestAction(itemIsMenu ? "context" : "activate")
        // Se mantiene el botón original: no se añade otro control visual.
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: indicator.requestAction("context")
        }
        // El menú KDE viaja por DBusMenu: se solicita el diseño al
        // emisor y se presenta junto al icono, sin nuevos botones de barra.
        QQC2.Menu {
            id: remoteMenu
            title: indicator.itemTitle
            Instantiator {
                id: rows
                model: realTray.backend &&
                       realTray.backend.menuService === String(indicator.modelData.service || "") &&
                       realTray.backend.menuObjectPath === String(indicator.modelData.objectPath || "")
                       ? realTray.backend.menuEntries : []
                delegate: QQC2.MenuItem {
                    required property var modelData
                    readonly property int entryId: Number(modelData.id || 0)
                    text: modelData.separator ? "────────────" :
                          String(modelData.label || "")
                    enabled: !modelData.separator && modelData.enabled !== false
                    onTriggered: {
                        if (!realTray.backend) return
                        if (modelData.hasChildren) {
                            realTray.backend.requestMenu(
                                String(indicator.modelData.service || ""),
                                String(indicator.modelData.objectPath || ""), entryId)
                        } else {
                            realTray.backend.triggerMenuEntry(
                                String(indicator.modelData.service || ""),
                                String(indicator.modelData.objectPath || ""), entryId)
                        }
                    }
                }
                onObjectAdded: function(index, object) {
                    remoteMenu.insertItem(index, object)
                }
                onObjectRemoved: function(index, object) {
                    remoteMenu.removeItem(object)
                }
            }
        }
        Connections {
            target: realTray.backend
            function onMenuChanged() {
                if (!realTray.expanded || !realTray.backend) return
                if (realTray.backend.menuService !== String(indicator.modelData.service || "") ||
                    realTray.backend.menuObjectPath !== String(indicator.modelData.objectPath || ""))
                    return
                Qt.callLater(function() {
                    if (realTray.expanded) remoteMenu.popup()
                })
            }
        }

        QQC2.ToolTip.visible: indicator.hovered && !remoteMenu.visible
        QQC2.ToolTip.text: itemTitle
    }
}
