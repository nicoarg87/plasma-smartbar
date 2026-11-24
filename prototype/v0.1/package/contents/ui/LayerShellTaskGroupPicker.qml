// SPDX-License-Identifier: MIT
// Previsualización agrupada: HORIZONTAL predeterminada, vertical configurable.
// Solo para ensayo nativo. No cambia ni instala panel KDE.
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import QtCore as QtCore
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.pipewire as KPipeWire

Window {
    id: chooser
    property bool runtimeActive: false
    property bool requested: false
    property var taskModel: null
    property var groupUuids: []
    property string appLabel: ""
    property real leftOffset: 0
    property real topOffset: 52
    readonly property bool isVertical: layoutMode === "vertical"
    property string layoutMode: String(layoutSettings.value("orientation", "horizontal"))
    readonly property int cardWidth: 252
    readonly property int cardHeight: 178
    signal selectWindow(string uuid)
    signal cursorEntered()
    signal cursorExited()

    QtCore.Settings {
        id: layoutSettings
        category: "plasma-smartbar-v01-group-previews"
    }
    function chooseLayout(value) {
        if (value !== "horizontal" && value !== "vertical") return
        chooser.layoutMode = value
        layoutSettings.setValue("orientation", value)
        layoutSettings.sync()
    }
    function closePicker() {
        requested = false
        groupUuids = []
    }
    visible: runtimeActive && requested && groupUuids.length > 1
    width: isVertical ? 270 : Math.min(
        Math.max(270, Screen.width - 12),
        Math.max(270, 12 + groupUuids.length * cardWidth))
    height: isVertical
        ? Math.max(1, Math.min(Math.max(200, Screen.height - 70),
                              42 + groupUuids.length * 180))
        : 222
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    transientParent: null
    title: "Plasma SmartBar — miniaturas agrupadas"

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorLeft
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityOnDemand
    LayerShell.Window.margins: ({
        left: Math.max(0, Math.round(leftOffset)),
        top: Math.max(48, Math.round(topOffset)),
        right: 0, bottom: 0
    })

    Keys.onEscapePressed: closePicker()

    QQC2.Menu {
        id: orientationMenu
        QQC2.MenuItem {
            text: "Miniaturas horizontales (predeterminado)"
            checkable: true
            checked: !chooser.isVertical
            onTriggered: chooser.chooseLayout("horizontal")
        }
        QQC2.MenuItem {
            text: "Miniaturas verticales"
            checkable: true
            checked: chooser.isVertical
            onTriggered: chooser.chooseLayout("vertical")
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#172331"
        radius: 10
        border.color: "#5d7c90"
        border.width: 1
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 0
            Item {
                width: parent.width
                height: 30
                Text {
                    anchors.fill: parent
                    color: "#f0f6fc"
                    font.pixelSize: 13
                    font.bold: true
                    text: chooser.appLabel + " (" + chooser.groupUuids.length + ")"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: orientationMenu.popup()
                }
            }
            Flickable {
                id: scrollArea
                width: parent.width
                height: Math.max(1, parent.height - 30)
                clip: true
                contentWidth: chooser.isVertical ? width :
                              Math.max(width, chooser.groupUuids.length * chooser.cardWidth)
                contentHeight: chooser.isVertical ?
                               Math.max(height, chooser.groupUuids.length * 180) : height
                boundsBehavior: Flickable.StopAtBounds

                Grid {
                    id: choices
                    width: scrollArea.contentWidth
                    columns: chooser.isVertical ? 1 : Math.max(1, chooser.groupUuids.length)
                    spacing: 2
                    Repeater {
                        model: chooser.visible ? chooser.taskModel : null
                        delegate: Item {
                            id: option
                            required property var model
                            readonly property var ids: model.WinIdList || []
                            readonly property string uuid:
                                ids.length === 1 ? String(ids[0]) : ""
                            readonly property bool belongs:
                                uuid.length > 0 && chooser.groupUuids.indexOf(uuid) >= 0
                            readonly property string windowTitle:
                                String(model.display || model.AppName || chooser.appLabel)
                            width: belongs ? (chooser.isVertical ? choices.width : 250) : 0
                            height: belongs ? chooser.cardHeight : 0
                            visible: belongs

                            TaskManager.ScreencastingRequest {
                                id: capture
                                uuid: chooser.visible && option.belongs ? option.uuid : ""
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: hover.containsMouse ? "#30485a" : "#20313e"
                                radius: 8
                                border.color: hover.containsMouse ? "#80bddb" : "#425968"
                                border.width: 1
                                KPipeWire.PipeWireSourceItem {
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.topMargin: 4
                                    width: 246
                                    height: 145
                                    nodeId: option.belongs && chooser.visible ? capture.nodeId : 0
                                    visible: capture.nodeId > 0 && option.belongs
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "Cargando miniatura…"
                                    color: "#d9e8f2"
                                    font.pixelSize: 12
                                    visible: option.belongs && capture.nodeId <= 0
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 7
                                    color: "white"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    text: option.windowTitle
                                }
                                MouseArea {
                                    id: hover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (option.belongs) chooser.selectWindow(option.uuid)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        HoverHandler {
            onHoveredChanged: {
                if (hovered) chooser.cursorEntered()
                else chooser.cursorExited()
            }
        }
    }
}
