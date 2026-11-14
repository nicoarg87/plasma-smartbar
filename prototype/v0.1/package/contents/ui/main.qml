// Prototipo VISUAL. NO administra ventanas reales ni sustituye paneles.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    // El área de prueba es una sola franja. Abrir SO/bandeja NO cambia su altura.
    readonly property int fixedHeight: 48
    Layout.minimumWidth: 750
    Layout.preferredWidth: 960
    Layout.minimumHeight: fixedHeight
    Layout.preferredHeight: fixedHeight
    Layout.maximumHeight: fixedHeight
    implicitWidth: 960
    implicitHeight: fixedHeight

    property bool soExpanded: false
    property bool trayExpanded: false
    property bool launcherPreview: false
    property string lastDemoSelection: ""
    readonly property var demoApps: ["Dolphin", "Konsole", "Brave"]
    readonly property var demoTray: ["Wi-Fi", "Audio", "Bluetooth"]

    function toggleSO() {
        soExpanded = !soExpanded
        if (soExpanded) {
            trayExpanded = false
        }
    }

    function toggleTray() {
        trayExpanded = !trayExpanded
        if (trayExpanded) {
            soExpanded = false
        }
    }

    function selectDemoApp(appName) {
        lastDemoSelection = appName
        soExpanded = false // Comportamiento confirmado por defecto.
        console.log("Simulación: selección de", appName, "(no se activa ninguna ventana real)")
    }

    Item {
        anchors.fill: parent

        // Isla 2: lanzador izquierdo. La búsqueda real aún no está conectada.
        Rectangle {
            id: launcherIsland
            width: launcherButton.implicitWidth + 12
            height: 44
            radius: 22
            color: "#101e31"
            border.color: "#4e8499"
            border.width: 1
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            IslandButton {
                id: launcherButton
                anchors.centerIn: parent
                text: root.launcherPreview ? "Apps" : "◇"
                accent: true
                onClicked: root.launcherPreview = !root.launcherPreview
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Isla 2 — lanzador de muestra (no inicia programas)"
            }
        }

        // Isla 1: anclada a la derecha. Los elementos nuevos crecen a la
        // izquierda, mientras SO y el pequeño agarre permanecen en su lugar.
        Rectangle {
            id: systemIsland
            height: 44
            width: systemRow.implicitWidth + 12
            radius: 22
            color: "#101e31"
            border.color: "#4e8499"
            border.width: 1
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: systemRow
                spacing: 4
                anchors.centerIn: parent

                IslandButton {
                    text: root.trayExpanded ? "▶" : "◀"
                    onClicked: root.toggleTray()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Bandeja de muestra: abrir/cerrar a la izquierda"
                }

                // Simulación de contenidos de bandeja, no controles reales.
                Repeater {
                    model: root.trayExpanded ? root.demoTray : []
                    delegate: IslandButton {
                        text: modelData
                        enabled: false
                        QQC2.ToolTip.text: "Elemento simulado de bandeja"
                    }
                }

                // Simulación de una ficha por aplicación abierta.
                Repeater {
                    model: root.soExpanded ? root.demoApps : []
                    delegate: IslandButton {
                        text: modelData
                        onClicked: root.selectDemoApp(modelData)
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Simulación: seleccionar " + modelData
                    }
                }

                IslandButton {
                    id: soButton
                    text: "SO"
                    accent: true
                    onClicked: root.toggleSO()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: root.lastDemoSelection.length
                                           ? "SO · última simulación: " + root.lastDemoSelection
                                           : "SO · aplicaciones de ejemplo"
                }

                // Solo reserva visual. El arrastre real será otra etapa.
                IslandButton {
                    text: "⋮"
                    enabled: false
                    QQC2.ToolTip.text: "Agarre de arrastre pendiente de implementar"
                }
            }
        }
    }
}
