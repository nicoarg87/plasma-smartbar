import QtQuick
import QtQuick.Controls as QQC2
import "DemoWindows.js" as DemoWindows

// Único botón de recuperación de cierres simulados, compartido por ambos modos.
QQC2.ToolButton {
    id: reopenDemo
    required property var host
    required property string presentationMode
                    visible: host.positionMode === presentationMode && host.soExpanded &&
                             host.demoWindowControlsEnabled && !host.usingRealTasks
                    text: "+"
                    implicitWidth: 26
                    implicitHeight: 34
                    focusPolicy: Qt.StrongFocus
                    enabled: !host.demoHasRunningWindows || host.demoClosedHistory.length > 0 ||
                             DemoWindows.firstClosed(host.demoOpenedApps, host.demoApps) !== ""
                    Accessible.name: enabled ? "Recuperar última ventana simulada cerrada" :
                                     "Todas las ventanas simuladas están abiertas"
                    // El + no depende del texto del ToolButton, que el estilo
                    // Qt puede dejar invisible. Se reutiliza el botón existente.
                    contentItem: Item {
                        implicitWidth: 18
                        implicitHeight: 18
                        Rectangle {
                            anchors.centerIn: parent
                            width: 14
                            height: 2
                            radius: 1
                            color: reopenDemo.enabled ? "#ffffff" : "#a1b1c0"
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 2
                            height: 14
                            radius: 1
                            color: reopenDemo.enabled ? "#ffffff" : "#a1b1c0"
                        }
                    }
                    QQC2.ToolTip.visible: false
                    QQC2.ToolTip.text: enabled
                        ? "Deshacer último cierre de ventana simulada"
                        : "Todas las ventanas simuladas están abiertas"
                    onClicked: host.reopenNextDemoWindow()
                }
