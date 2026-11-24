// SPDX-License-Identifier: MIT
// Selector secundario de ventanas agrupadas, únicamente para ensayo nativo.
// Los UUID de TaskManager son efímeros. No instalar ni reemplazar panel KDE.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.pipewire as KPipeWire

Window {
    id: chooser
    property bool runtimeActive: false
    property bool requested: false
    property var taskModel: null // TasksModel GroupDisabled, solo de la sesión KDE
    property var groupUuids: []
    property string appLabel: ""
    property real leftOffset: 0
    property real topOffset: 52
    signal selectWindow(string uuid)

    function closePicker() {
        requested = false
        groupUuids = []
    }
    visible: runtimeActive && requested && groupUuids.length > 1
    width: 270
    height: Math.max(1, Math.min(600, 42 + groupUuids.length * 180))
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    transientParent: null
    title: "Plasma SmartBar — ventanas agrupadas"

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
            Text {
                width: parent.width
                height: 30
                color: "#f0f6fc"
                font.pixelSize: 13
                font.bold: true
                text: chooser.appLabel + " (" + chooser.groupUuids.length + ")"
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            Flickable {
                width: parent.width
                height: Math.max(1, parent.height - 30)
                clip: true
                contentWidth: width
                contentHeight: choices.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                Column {
                    id: choices
                    width: parent.width
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
                            width: choices.width
                            height: belongs ? 178 : 0
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
    }
}
