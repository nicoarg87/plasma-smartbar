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
    // Preferencias independientes: no contraer por abrir la otra sección
    // cuando ambas caben. SO se cierra tras seleccionar, por defecto.
    property bool autoCollapseSO: true
    property bool autoCollapseTray: false
    signal requestAutoReturnRightChange(bool newValue)
    signal requestLauncherIslandVisibilityChange(bool newValue)
    signal requestAutoCollapseSOChange(bool newValue)
    signal requestAutoCollapseTrayChange(bool newValue)
    onWidthChanged: console.log("SmartBar v0.1: ancho útil de las islas =", width)

    property bool soExpanded: false
    property bool trayExpanded: false
    // Última expansión iniciada por el usuario: gana si falta espacio.
    property string lastExpandedMode: "so"
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
    // Origen del lanzador compartido: cada isla lo abre debajo de sí misma.
    property string installedLauncherSource: "so"

    // Reservar siempre espacio para la expansión MÁS ancha; abrir bandeja o SO
    // no debe empujar el agarre ni SO, aun después de un arrastre.
    readonly property real controlsReservation: root.previewMaximized
        ? windowControls.width + 6 : 0
    readonly property real maxIslandOffset: Math.max(
        0, root.width - (root.launcherIslandVisible ? launcherIsland.width : 0) - 460 - 12
           - controlsReservation
    )
    // Espacio físico desde el borde izquierdo libre hasta la derecha de
    // Soledad. Se calcula en el ancho REAL, respetando Malvina si está visible.
    readonly property real availableIslandWidth: Math.max(
        0, root.width - islandOffset - controlsReservation
           - (launcherIslandVisible ? launcherIsland.width + 12 : 12)
    )
    // Sólo lectura para el visor Qt de pruebas: mostrar cuánto ocupa
    // Soledad frente al espacio real disponible, sin alterar su aspecto.
    readonly property real actualIslandWidth: systemIsland.width
    onAvailableIslandWidthChanged: ensureExpansionFits()

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

    function ensureExpansionFits() {
        if (!soExpanded || !trayExpanded) {
            return
        }
        // La anchura visible de la fila mide exactamente ambos conjuntos.
        // Solo contraer uno si juntos invadirían el espacio de Malvina
        // o superarían el borde disponible de la ventana.
        if (systemIsland.width > availableIslandWidth + 0.5) {
            if (lastExpandedMode === "tray") {
                soExpanded = false
            } else {
                trayExpanded = false
            }
            console.log("Soledad: falta espacio para ambas",
                        "ancho requerido =", actualIslandWidth,
                        "disponible =", availableIslandWidth,
                        "se conserva =", lastExpandedMode)
        }
    }

    function toggleSO() {
        // Si el lanzador flotante está visible, el clic breve en SO
        // cierra SOLO ese menú. Las fichas SO y la bandeja conservan
        // su estado: no alternar soExpanded en el mismo clic.
        if (installedAppsPopup.visible) {
            installedAppsPopup.close()
            return
        }
        if (soExpanded) {
            soExpanded = false
        } else {
            lastExpandedMode = "so"
            soExpanded = true
            // Si entra la bandeja junto a SO, conservar ambos.
            // systemIsland.onWidthChanged calcula la colisión real.
            ensureExpansionFits()
        }
    }

    function openInstalledLauncher(source) {
        const requestedSource = source === "malvina" ? "malvina" : "so"
        // Un segundo clic sobre Malvina debe cerrar el popup existente.
        // Sólo cambiar la isla de origen cuando realmente cambia de botón.
        if (installedAppsPopup.visible && installedLauncherSource === requestedSource) {
            installedAppsPopup.close()
            return
        }
        installedLauncherSource = requestedSource
        // El lanzador es un panel FLOTANTE independiente de las fichas de
        // SO y los iconos de bandeja: abrirlo desde cualquiera de las islas
        // NO debe modificar soExpanded ni trayExpanded.
        // Sólo la selección, el cierre manual y la falta real de espacio
        // pueden contraer las expansiones según sus reglas propias.
        installedAppsSearch.text = ""
        installedAppsPopup.open()
        installedAppsSearch.forceActiveFocus()
        console.log("SmartBar v0.1: lanzador simulado desde",
                    installedLauncherSource, "(sin iniciar aplicaciones)")
    }

    function setLauncherIslandVisible(value) {
        requestLauncherIslandVisibilityChange(value)
        if (!value) {
            launcherPreview = false
        }
        console.log("SmartBar v0.1: isla 2 visible =", value)
    }

    function toggleGripMenu() {
        // Abrir opciones solo por clic DERECHO o tecla de menú.
        // El clic izquierdo queda libre para arrastrar Soledad.
        if (gripMenu.visible) {
            gripMenu.close()
        } else {
            gripMenu.popup()
        }
    }

    function toggleTray() {
        installedAppsPopup.close()
        if (trayExpanded) {
            trayExpanded = false
        } else {
            lastExpandedMode = "tray"
            trayExpanded = true
            // Si hay espacio suficiente, la expansión SO queda abierta.
            ensureExpansionFits()
        }
    }

    function selectDemoApp(appName) {
        lastDemoSelection = appName
        // Elegir ficha: mantener abierto solo si la preferencia lo pide.
        if (autoCollapseSO) {
            soExpanded = false
        }
        console.log("Soledad: ficha simulada", appName,
                    "autocontraer SO =", autoCollapseSO,
                    "(sin controlar ventanas reales)")
    }

    function selectDemoTray(iconName) {
        // La bandeja sigue siendo SIMULADA; ninguna acción del sistema.
        if (autoCollapseTray) {
            trayExpanded = false
        }
        console.log("Soledad: icono de bandeja simulado", iconName,
                    "autocontraer bandeja =", autoCollapseTray,
                    "(sin acciones reales)")
    }

    onMaxIslandOffsetChanged: setIslandOffset(islandOffset)

    // Lanzador flotante de muestra, independiente del grosor de la barra.
    // NO enumera ni inicia aplicaciones instaladas; eso sigue pendiente.
    QQC2.Popup {
        id: installedAppsPopup
        parent: root
        // Un solo lanzador, dos puntos de apertura. El origen es reactivo
        // tanto al arrastre de Soledad como al ancho del contenedor.
        // Malvina queda a la izquierda: el popup abre DEBAJO de Malvina,
        // no bajo SO a la derecha. Los bordes siempre se respetan.
        x: Math.max(0, Math.min(Math.max(0, root.width - width),
               root.installedLauncherSource === "malvina" && root.launcherIslandVisible
               ? launcherIsland.x + (launcherIsland.width - width) / 2
               : systemIsland.x + (systemIsland.width - width) / 2))
        y: root.fixedHeight + 5
        width: 275
        height: 265
        padding: 10
        modal: false
        focus: true
        // CloseOnPressOutside cerraba al PRESIONAR Malvina antes de que
        // onClicked comprobara el estado. Luego onClicked lo reabría:
        // parecía imposible cerrar el lanzador pulsando M de nuevo.
        // El botón está DENTRO del padre root; preservar ese evento y
        // cerrar por botón, Escape o clic fuera de la zona de la barra.
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent
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
            // Recuperación visible incluso cuando Malvina está oculta:
            // mantener SO y pulsar una sola opción, sin clic derecho.
            QQC2.Button {
                visible: !root.launcherIslandVisible
                width: 248
                height: 30
                text: "Mostrar Malvina (isla 2)"
                onClicked: {
                    root.setLauncherIslandVisible(true)
                    installedAppsPopup.close()
                }
            }
            QQC2.ScrollView {
                width: 248
                height: root.launcherIslandVisible ? 162 : 128
                clip: true
                ListView {
                    model: root.demoInstalledApps.filter(function(name) {
                        return name.toLowerCase().indexOf(installedAppsSearch.text.toLowerCase()) >= 0
                    })
                    spacing: 4
                    clip: true
                    delegate: QQC2.Button {
                        required property string modelData
                        text: modelData + "  · muestra"
                        width: 240
                        height: 28
                        onClicked: {
                            console.log("SmartBar: app simulada", modelData, "(no se ejecuta)")
                            installedAppsPopup.close()
                        }
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
                text: root.launcherPreview ? "Apps" : "M"
                accent: true
                onClicked: root.openInstalledLauncher("malvina")
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Malvina: clic abre/cierra lanzador; derecho: ocultar."

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: launcherContextMenu.popup()
                }
                QQC2.Menu {
                    id: launcherContextMenu
                    QQC2.MenuItem {
                        text: "Ocultar Malvina (isla 2)"
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
            // Al cambiar fichas o espacio por arrastre, mantener ambas
            // expansiones salvo que realmente dejen de caber.
            onWidthChanged: root.ensureExpansionFits()
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
                        onClicked: root.selectDemoTray(modelData)
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Bandeja simulada: " + modelData
                             + " (no modifica el sistema)"
                    }
                }

                // Separación mínima y legible entre iconos de bandeja y
                // fichas SO, solamente cuando ambas expansiones están
                // visibles. Se incluye naturalmente en el ancho medido.
                Rectangle {
                    id: traySOSeparator
                    visible: root.trayExpanded && root.soExpanded
                    width: 2
                    height: 24
                    radius: 1
                    color: "#7594a8"
                    y: (systemRow.height - height) / 2
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
                            root.openInstalledLauncher("so")
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
                            onTriggered: root.openInstalledLauncher("so")
                        }
                        QQC2.MenuItem {
                            text: root.launcherIslandVisible ? "Ocultar Malvina (isla 2)" : "Mostrar Malvina (isla 2)"
                            onTriggered: root.setLauncherIslandVisible(!root.launcherIslandVisible)
                        }
                    }

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: root.launcherIslandVisible
                        ? "Soledad · clic: ventanas · mantener 0,4 s: apps · derecho: opciones"
                        : "Malvina oculta · seis puntos: Mostrar Malvina · mantener SO: apps"
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
                    // NO abrir el menú por clic izquierdo: ese botón sirve
                    // exclusivamente para agarrar y mover Soledad.
                    // Clic derecho alterna abrir/cerrar opciones. El handler
                    // no acepta el botón izquierdo ni intercepta el arrastre.
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: root.toggleGripMenu()
                    }
                    Keys.onPressed: function(event) {
                        // Acceso de teclado: tecla Menú o Mayús+F10.
                        if (event.key === Qt.Key_Menu ||
                            (event.key === Qt.Key_F10 &&
                             (event.modifiers & Qt.ShiftModifier))) {
                            root.toggleGripMenu()
                            event.accepted = true
                        }
                    }
                    QQC2.ToolTip.visible: hovered && !gripDrag.active
                    QQC2.ToolTip.delay: 850
                    QQC2.ToolTip.text: root.launcherIslandVisible
                        ? "Arrastrar: botón izquierdo · Opciones: clic derecho"
                        : "Malvina oculta · Clic derecho acá → Mostrar Malvina"

                    // target=null: el gesto modifica el margen, nunca la
                    // geometría vertical ni el panel real de KDE.
                    DragHandler {
                        id: gripDrag
                        target: null
                        // Reservar el botón derecho a las opciones.
                        acceptedButtons: Qt.LeftButton
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
                        title: "Opciones de Soledad"
                        // Sin cierre previo al presionar el mismo botón:
                        // el segundo clic derecho debe cerrar, no reabrir.
                        closePolicy: QQC2.Popup.CloseOnEscape
                            | QQC2.Popup.CloseOnPressOutsideParent
                        // La recuperación de Malvina debe ser fácil de
                        // descubrir aun si no queda ningún botón a la
                        // izquierda. El agarre siempre sigue visible.
                        QQC2.MenuItem {
                            id: gripMalvinaVisibility
                            text: root.launcherIslandVisible
                                ? "Ocultar Malvina (isla 2)"
                                : "Mostrar Malvina (isla 2)"
                            onTriggered: root.setLauncherIslandVisible(
                                !root.launcherIslandVisible
                            )
                        }
                        QQC2.MenuSeparator {}
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
                        QQC2.Menu {
                            title: "Configuración de autocontracción"
                            QQC2.MenuItem {
                                id: autoCollapseSOMenu
                                text: "SO: contraer tras elegir ventana"
                                checkable: true
                                Binding {
                                    target: autoCollapseSOMenu
                                    property: "checked"
                                    value: root.autoCollapseSO
                                }
                                onTriggered: root.requestAutoCollapseSOChange(!root.autoCollapseSO)
                            }
                            QQC2.MenuItem {
                                id: autoCollapseTrayMenu
                                text: "Bandeja: contraer tras usar icono"
                                checkable: true
                                Binding {
                                    target: autoCollapseTrayMenu
                                    property: "checked"
                                    value: root.autoCollapseTray
                                }
                                onTriggered: root.requestAutoCollapseTrayChange(!root.autoCollapseTray)
                            }
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
