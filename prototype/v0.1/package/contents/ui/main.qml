// Prototipo VISUAL: los controles NO modifican ventanas reales.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    // Una sola franja de alto fijo, tanto con SO como con la bandeja abiertos.
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
    property bool previewMaximized: false  // ¡Simulación! No se consulta KWin.
    property real islandOffset: 0          // Distancia horizontal desde la derecha.
    property real offsetAtDragStart: 0
    property string lastDemoSelection: ""
    readonly property var demoApps: ["Dolphin", "Konsole", "Brave"]
    readonly property var demoTray: ["Wi-Fi", "Audio", "Bluetooth"]

    // Reservar siempre espacio para la expansión MÁS ancha; abrir bandeja o SO
    // no debe empujar el agarre ni SO, aun después de un arrastre.
    readonly property real maxIslandOffset: Math.max(
        0, root.width - launcherIsland.width - 460 - 12
    )

    function setIslandOffset(offset) {
        islandOffset = Math.max(0, Math.min(maxIslandOffset, offset))
    }

    function setPreviewMaximized(value) {
        previewMaximized = value
        if (!previewMaximized && Plasmoid.configuration.autoReturnRight) {
            setIslandOffset(0)
        }
    }

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
        soExpanded = false
        console.log("SO simulado:", appName, "(sin controlar ventanas reales)")
    }

    onMaxIslandOffsetChanged: setIslandOffset(islandOffset)

    Item {
        anchors.fill: parent

        // Isla 2: lanzador de ejemplo. Isla 3 sigue oculta por defecto.
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
                QQC2.ToolTip.text: "Isla 2: lanzador de ejemplo, no inicia aplicaciones"
            }
        }

        // Isla 1: anclaje propio desplazable, independiente de su expansión.
        Rectangle {
            id: systemIsland
            height: 44
            width: systemRow.implicitWidth + 12
            radius: 22
            color: "#101e31"
            border.color: "#4e8499"
            border.width: 1
            anchors.right: parent.right
            anchors.rightMargin: root.islandOffset
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: systemRow
                spacing: 4
                anchors.centerIn: parent

                IslandButton {
                    text: root.trayExpanded ? "▶" : "◀"
                    onClicked: root.toggleTray()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Abrir/cerrar bandeja simulada"
                }

                Repeater {
                    model: root.trayExpanded ? root.demoTray : []
                    delegate: IslandButton {
                        text: modelData
                        enabled: false
                    }
                }

                Repeater {
                    model: root.soExpanded ? root.demoApps : []
                    delegate: IslandButton {
                        text: modelData
                        onClicked: root.selectDemoApp(modelData)
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Ficha ficticia: " + modelData
                    }
                }

                IslandButton {
                    id: soButton
                    text: "SO"
                    accent: true
                    onClicked: root.toggleSO()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: root.lastDemoSelection.length
                        ? "SO · última prueba: " + root.lastDemoSelection
                        : "SO · ventanas de ejemplo"
                }

                // ¡Agarre ACTIVO! Seis puntos (2 × 3), siempre INMEDIATAMENTE a la
                // derecha de SO, antes de los controles de la ventana.
                QQC2.Button {
                    id: moveGrip
                    // Seis puntos reales, en dos columnas y tres filas;
                    // no dependemos de un glifo de tipografía.
                    implicitWidth: 30
                    implicitHeight: 34
                    hoverEnabled: true
                    focusPolicy: Qt.StrongFocus
                    background: Rectangle {
                        radius: 17
                        color: moveGrip.hovered ? "#24425a" : "#14283d"
                        border.width: 1
                        border.color: "#45647a"
                    }
                    contentItem: Item {
                        Grid {
                            anchors.centerIn: parent
                            columns: 2
                            rowSpacing: 3
                            columnSpacing: 3
                            Repeater {
                                model: 6
                                delegate: Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: "#eaf7ff"
                                }
                            }
                        }
                    }
                    onClicked: gripMenu.popup()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Arrastrar isla 1 horizontalmente. Clic: opciones de prueba."

                    // target=null: el gesto modifica el margen, nunca la
                    // geometría vertical ni el panel real de KDE.
                    DragHandler {
                        id: gripDrag
                        target: null
                        xAxis.enabled: true
                        yAxis.enabled: false
                        cursorShape: Qt.SizeHorCursor
                        onActiveChanged: {
                            if (active) {
                                root.offsetAtDragStart = root.islandOffset
                            } else if (!root.previewMaximized &&
                                       Plasmoid.configuration.autoReturnRight) {
                                root.setIslandOffset(0)
                            }
                        }
                        onActiveTranslationChanged: {
                            if (active) {
                                root.setIslandOffset(
                                    root.offsetAtDragStart - activeTranslation.x
                                )
                            }
                        }
                    }

                    QQC2.Menu {
                        id: gripMenu
                        title: "Opciones de prueba"
                        QQC2.MenuItem {
                            text: "Simular ventana maximizada"
                            checkable: true
                            checked: root.previewMaximized
                            onTriggered: root.setPreviewMaximized(!root.previewMaximized)
                        }
                        QQC2.MenuItem {
                            text: "Volver automáticamente a la derecha"
                            checkable: true
                            checked: Plasmoid.configuration.autoReturnRight
                            onTriggered: {
                                Plasmoid.configuration.autoReturnRight =
                                    !Plasmoid.configuration.autoReturnRight
                                if (Plasmoid.configuration.autoReturnRight &&
                                    !root.previewMaximized) {
                                    root.setIslandOffset(0)
                                }
                            }
                        }
                        QQC2.MenuItem {
                            text: "Restablecer isla a la derecha ahora"
                            onTriggered: root.setIslandOffset(0)
                        }
                    }
                }

                // Los botones aparecen solo al SIMULAR maximización.
                // Aún NO hay integración con controles de ventanas reales.
                Repeater {
                    model: root.previewMaximized ? ["−", "□", "×"] : []
                    delegate: IslandButton {
                        text: modelData
                        enabled: false
                        QQC2.ToolTip.text: "Control de ventana simulado"
                    }
                }
            }
        }
    }
}
