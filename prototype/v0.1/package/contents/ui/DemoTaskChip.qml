// Ficha de ventana FICTICIA. El botón × solo cambia el modelo local del visor.
// No referencia TaskManager ni solicita cerrar ventanas KDE.
import QtQuick
import QtQuick.Controls as QQC2

Row {
    id: chip
    required property var host
    // En un Repeater con lista JS y propiedades required, Qt suministra
    // el dato de cada fila mediante la propiedad requerida modelData.
    // Referir modelData desde el padre no funciona en este contexto.
    required property string modelData
    readonly property string appName: modelData
    spacing: 1

    Timer {
        id: previewHoverDelay
        interval: 450
        repeat: false
        onTriggered: {
            if (taskButton.hovered && chip.host.demoWindowControlsEnabled &&
                !chip.host.usingRealTasks && chip.host.demoHasRunningWindows)
                previewPopup.open()
        }
    }

    IslandButton {
        id: taskButton
        inheritIslandFill: true
        taskDisplayMode: chip.host.taskDisplayMode
        taskFrameShape: chip.host.taskFrameShape
        taskFrameColor: chip.host.displayTaskFrameColor
        taskFrameOpacity: chip.host.taskFrameOpacity
        taskFrameWidth: chip.host.taskFrameWidth
        taskActiveGlowEnabled: chip.host.taskActiveGlowEnabled
        taskActiveDoubleBorderEnabled: chip.host.taskActiveDoubleBorderEnabled
        taskActiveBorderColor: chip.host.displayOutlineSoColor
        taskActiveBorderOpacity: chip.host.outlineConfig.soledad.opacity
        taskActiveBorderWidth: chip.host.outlineConfig.soledad.width
        activityEffect: chip.host.soActivityStyle
        activityColor: chip.host.displaySoActivityColor
        activityStroke: chip.host.soActivityStroke
        activityMotionAllowed: chip.host.soActivityMotion
        activityOrbitSpeed: chip.host.soActivityOrbitSpeed
        activityTrailPercent: chip.host.soActivityTrailPercent
        activityTrailStyle: chip.host.soActivityTrailStyle
        activityGlowColor: chip.host.displaySoActivityGlowColor
        activityGlowIntensity: chip.host.soActivityGlowIntensity
        activityGlowSpread: chip.host.soActivityGlowSpread
        activityPulseSpeed: chip.host.soActivityPulseSpeed
        activityPulseDepth: chip.host.soActivityPulseDepth
        activityGlowGradient: chip.host.soActivityGlowGradient
        frameShape: "task"
        taskIconSource: chip.host.demoIconForApp(chip.appName)
        taskIsActive: chip.host.demoHasRunningWindows &&
            chip.host.lastDemoSelection.length > 0 &&
            chip.appName === chip.host.lastDemoSelection
        text: chip.appName
        onClicked: {
            previewHoverDelay.stop()
            previewPopup.close()
            chip.host.selectDemoApp(chip.appName)
        }
        onHoveredChanged: {
            if (hovered && chip.host.demoWindowControlsEnabled && !chip.host.usingRealTasks)
                previewHoverDelay.restart()
            else
                previewHoverDelay.stop()
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                previewHoverDelay.stop()
                if (previewPopup.visible) previewPopup.close()
                else previewPopup.open()
            }
        }
        QQC2.ToolTip.visible: hovered && !previewPopup.visible
        QQC2.ToolTip.text: "Ventana simulada: " + chip.appName
    }

    QQC2.ToolButton {
        id: closeDemoChip
        visible: chip.host.demoWindowControlsEnabled && !chip.host.usingRealTasks
        text: "×"
        implicitWidth: 26
        implicitHeight: 34
        focusPolicy: Qt.StrongFocus
        Accessible.name: "Cerrar ventana simulada de " + chip.appName
        // Dos trazos forman una X visible sin depender de la tipografía
        // o del color de texto aplicado por el estilo de Qt.
        contentItem: Item {
            implicitWidth: 18
            implicitHeight: 18
            Rectangle {
                anchors.centerIn: parent
                width: 14
                height: 2
                radius: 1
                rotation: 45
                color: closeDemoChip.enabled ? "#ffffff" : "#91a8b8"
            }
            Rectangle {
                anchors.centerIn: parent
                width: 14
                height: 2
                radius: 1
                rotation: -45
                color: closeDemoChip.enabled ? "#ffffff" : "#91a8b8"
            }
        }
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: "Cerrar solo la ficha simulada de " + chip.appName
        onClicked: chip.host.closeDemoWindow(chip.appName)
    }

    // Esta ventana flotante no aumenta el grosor ni la fila de SO.
    // Se muestra por hover breve o clic derecho sobre la ficha agrupadora.
    // Solo presenta contenido FICTICIO, NO capturas de ventanas KDE.
    QQC2.Popup {
        id: previewPopup
        parent: chip
        modal: false
        focus: false
        padding: 8
        width: Math.min(440, 18 + 204 *
            Math.max(1, chip.host.demoInstancesForApp(chip.appName).length))
        height: 167
        y: chip.height + 6
        // Respetar ambos extremos de la superficie disponible.
        x: {
            const absX = chip.mapToItem(chip.host, 0, 0).x
            return Math.max(6 - absX,
                Math.min(0, chip.host.width - absX - width - 6))
        }
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
        background: Rectangle {
            color: "#142637"
            radius: 8
            border.color: "#7796a8"
            border.width: 1
        }
        contentItem: Column {
            spacing: 7
            Text {
                width: parent.width
                text: chip.appName + " · ventanas abiertas (simulación)"
                font.bold: true
                font.pixelSize: 12
                color: "#ffffff"
                elide: Text.ElideRight
            }
            Row {
                spacing: 6
                Repeater {
                    model: chip.host.demoInstancesForApp(chip.appName)
                    delegate: Rectangle {
                        required property var modelData
                        width: 198
                        height: 118
                        radius: 5
                        color: "#223f53"
                        border.color: "#567f97"
                        border.width: 1
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.right: exitSimulated.left
                            anchors.rightMargin: 3
                            anchors.top: parent.top
                            anchors.topMargin: 7
                            text: modelData.title
                            elide: Text.ElideRight
                            color: "white"
                            font.pixelSize: 11
                        }
                        QQC2.ToolButton {
                            id: exitSimulated
                            width: 26
                            height: 25
                            anchors.top: parent.top
                            anchors.right: parent.right
                            Accessible.name: "Cerrar " + modelData.title + " (simulada)"
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Cerrar solo esta ventana simulada"
                            contentItem: Item {
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12
                                    height: 2
                                    rotation: 45
                                    color: "white"
                                }
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12
                                    height: 2
                                    rotation: -45
                                    color: "white"
                                }
                            }
                            onClicked: {
                                const last = chip.host.demoInstancesForApp(chip.appName).length === 1
                                if (last) previewPopup.close()
                                chip.host.closeDemoWindowInstance(chip.appName, modelData.id)
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 33
                            anchors.bottom: parent.bottom
                            anchors.margins: 7
                            color: "#1a3040"
                            radius: 3
                            Text {
                                anchors.centerIn: parent
                                text: modelData.minimized
                                    ? "Minimizada · vista simulada"
                                    : "Vista simulada · sin captura real"
                                font.pixelSize: 11
                                color: "#c9dbe6"
                            }
                        }
                    }
                }
            }
        }
    }

}
