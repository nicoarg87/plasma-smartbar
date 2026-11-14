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
    // Isla 2 visible por defecto. Se oculta solo por elección del usuario.
    property bool launcherIslandVisible: true
    signal requestAutoReturnRightChange(bool newValue)
    signal requestLauncherIslandVisibilityChange(bool newValue)
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
    // Menú de muestra: NO representa las aplicaciones instaladas todavía.
    readonly property var demoInstalledApps: ["Dolphin", "Konsole", "Brave", "Firefox", "Configuración"]
    property bool soHoldTriggered: false

    // Reservar siempre espacio para la expansión MÁS ancha; abrir bandeja o SO
    // no debe empujar el agarre ni SO, aun después de un arrastre.
    readonly property real controlsReservation: root.previewMaximized
        ? windowControls.width + 6 : 0
    readonly property real maxIslandOffset: Math.max(
        0, root.width - (root.launcherIslandVisible ? launcherIsland.width : 0) - 460 - 12
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

        // Guardar la coordenada VISIBLE de la isla antes de modificar el
        // espacio reservado al grupo de controles. Compensar en AMBOS
        // sentidos (maximizar y desmaximizar), no solamente al quitarlo.
        const oldRightMargin = islandOffset + controlsReservation
        const wasAligned = alignRightSelected
        const nextReservation = value ? windowControls.width + 6 : 0
        previewMaximized = value

        if (value) {
            if (wasAligned) {
                // «Alinear a la derecha» seleccionada: ubicar SO al lado
                // de los controles fijos, tal como indica esa opción.
                alignRightNow()
            } else {
                // Alineación manual: preservar la coordenada visual previa.
                // Si invadiría los controles, ajustar SOLO lo imprescindible.
                setIslandOffset(oldRightMargin - nextReservation)
                alignRightSelected = false
            }
        } else if (root.autoReturnRight) {
            // Retorno al DESMAXIMIZAR, si la preferencia está habilitada.
            alignRightNow()
        } else {
            // Retorno desactivado: conservar la posición visual al quitar
            // los controles (inverso exacto del caso de maximización).
            setIslandOffset(oldRightMargin - nextReservation)
            alignRightSelected = islandOffset <= 0
        }

        console.log("SmartBar v0.1: maximizada simulada =", previewMaximized,
                    "retorno =", root.autoReturnRight,
                    "alineación =", alignRightSelected,
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
        if (installedAppsPopup.opened) {
            installedAppsPopup.close()
        }
        soExpanded = !soExpanded
        if (soExpanded) {
            trayExpanded = false
        }
    }

    function openInstalledLauncher() {
        soExpanded = false
        trayExpanded = false
        installedAppsSearch.text = ""
        installedAppsPopup.open()
        installedAppsSearch.forceActiveFocus()
        console.log("SmartBar v0.1: lanzador SO de muestra (sin abrir aplicaciones)")
    }

    function setLauncherIslandVisible(value) {
        requestLauncherIslandVisibilityChange(value)
        if (!value) {
            launcherPreview = false
        }
        console.log("SmartBar v0.1: isla 2 visible =", value)
    }

    function toggleTray() {
        installedAppsPopup.close()
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

    // Lanzador flotante de muestra, independiente del grosor de la barra.
    // NO enumera ni inicia aplicaciones instaladas; eso sigue pendiente.
    QQC2.Popup {
        id: installedAppsPopup
        parent: root
        x: Math.max(0, Math.min(root.width - width,
                    soButton.mapToItem(root, 0, 0).x + soButton.width - width))
        y: root.fixedHeight + 5
        width: 275
        height: 265
        padding: 10
        modal: false
        focus: true
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
        background: Rectangle {
            radius: 12
            color: "#102538"
            border.color: "#4e8499"
            border.width: 1
        }
        contentItem: Column {
            spacing: 7
            QQC2.Label {
                text: "Aplicaciones (simulación)"
                color: "#eaf7ff"
                font.bold: true
            }
            QQC2.TextField {
                id: installedAppsSearch
                width: 248
                placeholderText: "Buscar aplicación…"
                focus: true
            }
            Repeater {
                model: root.demoInstalledApps.filter(function(name) {
                    return name.toLowerCase().indexOf(installedAppsSearch.text.toLowerCase()) >= 0
                })
                delegate: QQC2.Button {
                    required property string modelData
                    text: modelData + "  · muestra"
                    width: 248
                    height: 28
                    onClicked: {
                        console.log("SmartBar: app simulada", modelData, "(no se ejecuta)")
                        installedAppsPopup.close()
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent

        // Isla 2: lanzador de ejemplo. Isla 3 sigue oculta por defecto.
        Rectangle {
            id: launcherIsland
            visible: root.launcherIslandVisible
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
                onClicked: root.openInstalledLauncher()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Isla 2: lanzador de muestra. Clic derecho: ocultar."

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: launcherContextMenu.popup()
                }
                QQC2.Menu {
                    id: launcherContextMenu
                    QQC2.MenuItem {
                        text: "Ocultar isla 2"
                        onTriggered: root.setLauncherIslandVisible(false)
                    }
                }
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

                    // Clic corto: ventanas abiertas. Mantener unos 400 ms:
                    // lanzador de muestra. El clic de soltado NO debe activar
                    // también SO después de una pulsación sostenida.
                    onPressed: {
                        root.soHoldTriggered = false
                        soHoldTimer.restart()
                    }
                    onReleased: soHoldTimer.stop()
                    onCanceled: soHoldTimer.stop()
                    onClicked: {
                        soHoldTimer.stop()
                        if (!root.soHoldTriggered) {
                            root.toggleSO()
                        }
                        root.soHoldTriggered = false
                    }
                    Timer {
                        id: soHoldTimer
                        interval: 400
                        repeat: false
                        onTriggered: {
                            root.soHoldTriggered = true
                            root.openInstalledLauncher()
                        }
                    }

                    // Clic derecho / tecla Menú: acceso alternativo al
                    // lanzador y opción para restaurar la isla 2 oculta.
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Menu) {
                            soContextMenu.popup()
                            event.accepted = true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: soContextMenu.popup()
                    }
                    QQC2.Menu {
                        id: soContextMenu
                        QQC2.MenuItem {
                            text: "Abrir lanzador de aplicaciones (muestra)"
                            onTriggered: root.openInstalledLauncher()
                        }
                        QQC2.MenuItem {
                            text: root.launcherIslandVisible ? "Ocultar isla 2" : "Mostrar isla 2"
                            onTriggered: root.setLauncherIslandVisible(!root.launcherIslandVisible)
                        }
                    }

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Clic: ventanas de muestra · mantener 0,4 s: apps · derecho: opciones"
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
