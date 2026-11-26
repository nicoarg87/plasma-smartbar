import QtQuick
import QtQuick.Controls as QQC2

// Separador de bandeja y SO, editable solo en ancho horizontal.
Item {
                    id: separator
                    required property var host
                    visible: host.trayExpanded && host.soExpanded
                    width: 14
                    height: 28
                    y: (parent.height - height) / 2
                    // Tres marcas indican que este separador se puede arrastrar.
                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        Repeater {
                            model: 3
                            Rectangle {
                                width: 2
                                height: 15
                                radius: 1
                                color: "#a6c4d4"
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        cursorShape: Qt.SizeHorCursor
                        onPressed: function(mouse) {
                            const pt = mapToItem(host, mouse.x, mouse.y)
                            host.taskResizeStartX = pt.x
                            host.taskResizeStartWidth = host.taskNameExtraWidth
                            host.taskResizeChipCount = Math.max(1, host.usingRealTasks
                                ? host.realTaskModel.count : host.demoOpenedApps.length)
                        }
                        onPositionChanged: function(mouse) {
                            if (!(pressedButtons & Qt.LeftButton)) return
                            const pt = mapToItem(host, mouse.x, mouse.y)
                            // A la izquierda agranda las fichas SO; derecha achica.
                            host.updateTaskNameExtraWidth(host.taskResizeStartWidth +
                                Math.round((host.taskResizeStartX - pt.x) /
                                    host.taskResizeChipCount))
                        }
                        onDoubleClicked: function(mouse) {
                            if (mouse.button !== Qt.LeftButton) return
                            // Restablecer la medida predeterminada y persistirla
                            // de inmediato, sin cambiar preferencias de fichas.
                            host.taskNameExtraWidth = 0
                            host.saveTaskNameExtraWidth()
                        }
                        onReleased: host.saveTaskNameExtraWidth()
                    }
                    QQC2.ToolTip.visible: false
                    QQC2.ToolTip.text: "Arrastrar para ajustar nombres SO · doble clic para restablecer"
                    HoverHandler { id: resizeHover }
                }
