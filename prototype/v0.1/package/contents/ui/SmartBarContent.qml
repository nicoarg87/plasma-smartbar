// Fuente única para las islas y controles del prototipo visual.
// Los cambios de ancho se aplican a la geometría REAL de este Item.
// Prototipo VISUAL: los controles NO modifican ventanas reales.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

Item {
    id: root

    // Componente compartido: puede vivir tanto en un plasmoide de KDE
    // como en una ventana Qt de prueba. Solo dibuja islas, no banda continua.
    readonly property int fixedHeight: 48
    implicitHeight: fixedHeight
    property bool autoReturnRight: true
    signal requestAutoReturnRightChange(bool newValue)
    onWidthChanged: console.log("SmartBar v0.1: ancho útil de las islas =", width)

    property bool soExpanded: false
    property bool trayExpanded: false
    property bool launcherPreview: false
    property bool previewMaximized: false  // ¡Simulación! No se consulta KWin.
    // Indica la selección manual de «Alinear a la derecha», independiente
    // de la preferencia de retorno al desmaximizar.
    property bool alignRightSelected: true
    property real islandOffset: 0          // Distancia horizontal desde la derecha.
    property real offsetAtDragStart: 0
    property string lastDemoSelection: ""
    readonly property var demoApps: ["Dolphin", "Konsole", "Brave"]
    readonly property var demoTray: ["Wi-Fi", "Audio", "Bluetooth"]

    // Reservar siempre espacio para la expansión MÁS ancha; abrir bandeja o SO
    // no debe empujar el agarre ni SO, aun después de un arrastre.
    readonly property real controlsReservation: root.previewMaximized
        ? windowControls.width + 6 : 0
    readonly property real maxIslandOffset: Math.max(
        0, root.width - launcherIsland.width - 460 - 12
           - controlsReservation
    )

    function setIslandOffset(offset) {
        islandOffset = Math.max(0, Math.min(maxIslandOffset, offset))
    }

    function alignRightNow() {
        setIslandOffset(0)
        alignRightSelected = true
        console.log("SmartBar v0.1: isla 1 alineada a la derecha")
    }

    function setPreviewMaximized(value) {
        if (previewMaximized === value) {
            return
        }

        // Posición física anterior respecto del borde derecho del visor:
        // desplazamiento manual + espacio de los controles de ventana.
        // Si no hay retorno automático, esa coordenada debe conservarse
        // al desaparecer los controles; de otro modo la isla salta.
        const oldRightMargin = islandOffset + controlsReservation
        previewMaximized = value

        if (!previewMaximized) {
            if (root.autoReturnRight) {
                alignRightNow()
            } else {
                // Respetar la posición que eligió el usuario. Solo mover
                // si los límites de pantalla exigen corregir el margen.
                setIslandOffset(oldRightMargin - controlsReservation)
                alignRightSelected = islandOffset <= 0
            }
        }
        // Al maximizar sí se reserva sitio para los controles fijos.
        console.log("SmartBar v0.1: maximizada simulada =", previewMaximized,
                    "retorno =", root.autoReturnRight,
                    "desplazamiento =", islandOffset,
                    "margen visual =", islandOffset + controlsReservation)
    }

    function setAutoReturnRight(value) {
        requestAutoReturnRightChange(value)
        // Si la persona activa esta preferencia con la isla desplazada,
        // devolverla AHORA a su posición predeterminada (también si la
        // simulación sigue maximizada). Al desmaximizar volverá de nuevo.
        if (value) {
            alignRightNow()
        }
        console.log("SmartBar v0.1: retorno automático =", value,
                    "desplazamiento =", islandOffset)
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
            // Los controles de ventana quedan en el extremo derecho INMÓVILES.
            // La isla 1 se arrastra solo a la izquierda del espacio reservado.
            anchors.rightMargin: root.islandOffset + root.controlsReservation
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
                            }
                            // Al soltar la isla, mantenerla donde el usuario
                            // la dejó; NO aplicar aquí el retorno automático.
                        }
                        onActiveTranslationChanged: {
                            if (active && Math.abs(activeTranslation.x) > 1) {
                                // El gesto del usuario destilda de inmediato
                                // «Alinear a la derecha» sin tocar el retorno
                                // automático al desmaximizar.
                                root.alignRightSelected = false
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
                            id: alignRightMenuItem
                            text: "Alinear isla 1 a la derecha"
                            checkable: true
                            // Binding dedicado: evita que el control conserve
                            // un checked antiguo tras arrastrar el agarre.
                            Binding {
                                target: alignRightMenuItem
                                property: "checked"
                                value: root.alignRightSelected
                            }
                            onTriggered: {
                                if (root.alignRightSelected) {
                                    // El usuario destilda sin mover todavía.
                                    root.alignRightSelected = false
                                } else {
                                    // Tildar vuelve a colocar la isla AHORA.
                                    root.alignRightNow()
                                }
                            }
                        }
                        QQC2.MenuItem {
                            text: "Volver a la derecha al desmaximizar"
                            checkable: true
                            checked: root.autoReturnRight
                            onTriggered: root.setAutoReturnRight(
                                !root.autoReturnRight
                            )
                        }
                        QQC2.MenuItem {
                            text: "Mover isla 1 a la derecha AHORA"
                            onTriggered: root.alignRightNow()
                        }
                    }
                }

            }
        }

        // Independientes de la isla 1: NO acompañan el arrastre del agarre.
        // El margen derecho es cero en cualquier posición de SO y bandeja.
        // Esto es solo la simulación: no controla ventanas reales de KDE.
        Rectangle {
            id: windowControls
            visible: root.previewMaximized
            width: windowControlsRow.implicitWidth + 12
            height: 44
            radius: 22
            color: "#101e31"
            border.color: "#4e8499"
            border.width: 1
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

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
    }
}
