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
    // Altura fijada por usuario: nunca cambia al expandir SO/bandeja.
    property real panelHeight: 48
    readonly property real fixedHeight: Math.max(40, Math.min(120, panelHeight))
    property real soledadHeight: 44
    property real malvinaHeight: 44
    property real soledadRadius: 22
    property real malvinaRadius: 22
    property real soledadMinWidth: 0 // 0 = automático según fichas
    property real malvinaWidth: 52
    property string soledadShape: "leftRoundRightSquare"
    property string malvinaShape: "rounded"
    property string gripShape: "square"
    property string trayButtonShape: "rounded"
    // Logo SO panorámico: cápsula, imagen tropical estirada de origen.
    property string soButtonFrameShape: "capsule"
    property real soButtonWidth: 96
    implicitHeight: fixedHeight
    property bool autoReturnRight: true
    // Malvina está disponible por defecto, pero su superficie se oculta
    // cuando no se usa. El usuario puede desactivar el autoocultamiento.
    property bool launcherIslandVisible: true
    property bool autoHideMalvina: true
    property bool malvinaHoverRevealed: false
    // Política general para islas que se autoactivan: nunca aparecer sobre
    // una superficie maximizada/fullscreen. Si KWin aún NO informó estado
    // real, bloquear por seguridad (fail-closed) en el plasmoide.
    property bool windowStateKnown: true  // true solo en visor simulado
    property bool previewFullscreen: false
    property bool hostMaximized: false
    property bool hostFullscreen: false
    readonly property bool autoRevealBlocked:
        !windowStateKnown || previewMaximized || previewFullscreen ||
        hostMaximized || hostFullscreen
    onAutoRevealBlockedChanged: {
        if (autoRevealBlocked) {
            malvinaRevealTimer.stop()
            malvinaHideTimer.stop()
            malvinaHoverRevealed = false
            if (malvinaPopupActive)
                installedAppsPopup.close()
        }
    }
    readonly property bool malvinaPopupActive:
        installedAppsPopup.visible && installedLauncherSource === "malvina"
    readonly property bool malvinaActuallyVisible:
        !autoRevealBlocked && launcherIslandVisible &&
        (!autoHideMalvina || malvinaHoverRevealed || malvinaPopupActive)
    onLauncherIslandVisibleChanged: {
        if (!launcherIslandVisible) {
            malvinaRevealTimer.stop()
            malvinaHideTimer.stop()
            malvinaHoverRevealed = false
        }
    }
    onAutoHideMalvinaChanged: {
        if (!autoHideMalvina) {
            malvinaRevealTimer.stop()
            malvinaHideTimer.stop()
            malvinaHoverRevealed = false
        }
    }
    Timer {
        id: malvinaRevealTimer
        interval: 600
        repeat: false
        onTriggered: {
            // El puntero debe permanecer todo el intervalo sobre el lugar
            // de la isla. No usar un MouseArea que capture clics.
            if (!root.autoRevealBlocked && root.autoHideMalvina &&
                    root.launcherIslandVisible && malvinaHotspotHover.hovered)
                root.malvinaHoverRevealed = true
        }
    }
    Timer {
        id: malvinaHideTimer
        interval: 250
        repeat: false
        onTriggered: {
            if (root.autoHideMalvina && !malvinaHotspotHover.hovered &&
                    !root.malvinaPopupActive)
                root.malvinaHoverRevealed = false
        }
    }
    // Preferencias independientes: no contraer por abrir la otra sección
    // cuando ambas caben. SO se cierra tras seleccionar, por defecto.
    property bool autoCollapseSO: true
    property bool autoCollapseTray: false

    // Identidad visual configurable del botón SO. El archivo original nunca
    // se recorta ni se sobrescribe: guardar sólo encuadre/forma/escala.
    property string soLogoMode: "default"  // default/custom/text
    property string soLogoPath: ""
    property string soLogoShape: "square"
    property string soLogoFitMode: "stretch"
    property real soLogoZoom: 1
    property real soLogoPanX: 0
    property real soLogoPanY: 0
    property real soLogoRotation: 0
    property bool soLogoAnimate: true
    // Reloj breve en SO, activado por hover sobre el agarre de seis puntos.
    property bool soClockVisible: false
    property string soClockPhase: "off" // off, time, date
    property string soClockTime: ""
    property string soClockDate: ""
    property string soClockFontFamily: "Sans Serif"
    property int soClockFontSize: 11
    property color soClockTextColor: "#ffffff"

    function dismissSoClock() {
        soClockRevealTimer.stop()
        soClockReturnTimer.stop()
        soClockVisible = false
        soClockPhase = "off"
    }
    function showSoClock() {
        if (!moveGrip.hovered || moveGrip.pressed || gripDrag.active ||
                gripMenu.visible)
            return
        const now = new Date()
        soClockTime = Qt.formatTime(now, "HH:mm")
        soClockDate = Qt.formatDate(now, "dd/MM/yyyy")
        soClockPhase = "time"
        soClockVisible = true
        soClockReturnTimer.restart()
    }
    Timer {
        id: soClockRevealTimer
        interval: 180 // breve espera para distinguir hover del arrastre
        repeat: false
        onTriggered: root.showSoClock()
    }
    Timer {
        id: soClockReturnTimer
        interval: 1000 // hora 1 segundo, después fecha 1 segundo
        repeat: false
        onTriggered: {
            if (root.soClockPhase === "time") {
                root.soClockPhase = "date"
                restart()
            } else {
                root.soClockVisible = false
                root.soClockPhase = "off"
            }
        }
    }
    // Imagen tropical elegida por el mantenedor: archivo local en assets/.
    // Si aún no se copió al ensayo, el botón conserva respaldo de texto SO.
    // No incluir logos externos sin derechos acreditados.
    // GIF original elegido y validado visualmente por el mantenedor.
    // El recurso es independiente de MIT; ver licencias gráficas.
    readonly property url defaultSoLogo: Qt.resolvedUrl("assets/so-tropical.gif")
    readonly property url activeSoLogo: soLogoMode === "text" ? "" :
        (soLogoMode === "custom" && soLogoPath.length > 0
         ? soLogoPath : defaultSoLogo)
    // El GIF debe reproducirse también en el modo "Predeterminada".
    // Antes solo se activaba AnimatedImage al elegir un GIF personalizado.
    readonly property bool activeSoLogoIsGif: soLogoMode === "default" ||
        (soLogoMode === "custom" && soLogoPath.toLowerCase().endsWith(".gif"))

    // Colores y opacidad por isla; fondo continuo opcional y APAGADO.
    // Es una capa de fondo y no sustituye la isla 3 buscadora pendiente.
    property color soledadColor: "#010111"
    property color malvinaColor: "#101e31"
    property color backgroundColor: "#202333"
    property real soledadOpacity: 0.5
    property real malvinaOpacity: 1
    property real backgroundOpacity: 0.5
    property bool showBackground: false
    // Bandeja y agarre heredan Soledad salvo que la persona elija un
    // color y opacidad independientes para cada tipo de botón.
    property bool trayButtonColorOverride: false
    property color trayButtonColor: "#010111"
    property real trayButtonOpacity: 0.5
    property bool gripButtonColorOverride: false
    property color gripButtonColor: "#010111"
    property real gripButtonOpacity: 0.5
    readonly property color effectiveTrayButtonColor: trayButtonColorOverride
        ? trayButtonColor : soledadColor
    readonly property real effectiveTrayButtonOpacity: trayButtonColorOverride
        ? trayButtonOpacity : soledadOpacity
    readonly property color effectiveGripButtonColor: gripButtonColorOverride
        ? gripButtonColor : soledadColor
    readonly property real effectiveGripButtonOpacity: gripButtonColorOverride
        ? gripButtonOpacity : soledadOpacity

    // El visor puede inyectar el TasksModel REAL ya probado en CachyOS.
    // Si es null, se mantiene intacta la simulación habitual. Este
    // componente NO crea modelos KDE ni ejecuta acciones sobre ventanas.
    property var realTaskModel: null
    readonly property bool usingRealTasks: realTaskModel !== null
    property bool demoHasRunningWindows: true
    readonly property int soWindowCount: usingRealTasks
        ? realTaskModel.count
        : (demoHasRunningWindows ? demoApps.length : 0)
    // Con cero ventanas, el brillo atrae la atención hacia el lanzador.
    // Con ventanas abiertas, permanece apagado por defecto.
    property string soActivityStyle: "orbit"  // off, steady, orbit
    property bool soActivityShowWhenEmpty: true
    property bool soActivityShowWhenOpen: false
    property color soActivityColor: "#35d7ff"
    property real soActivityStroke: 0.75
    property bool soActivityMotion: true
    // Valores iniciales PROVISORIOS para revisión visual del mantenedor.
    property real soActivityOrbitSpeed: 1.5
    property int soActivityTrailPercent: 75
    property string soActivityTrailStyle: "dashed"
    onSoWindowCountChanged: {
        if (soWindowCount === 0) soExpanded = false
    }
    signal requestSoActivityChange(string style, string color,
                                   real stroke, bool allowMotion,
                                   real speed, int tailLength, string lineStyle,
                                   bool showWhenEmpty, bool showWhenOpen)

    signal requestSoClockAppearanceChange(string fontFamily, int fontSize,
                                          string textColor)
    signal requestSoLogoChange(string mode, string path, string shape,
                               string fitMode, real zoom, real panX, real panY,
                               bool allowGif, real rotation)
    signal requestGeometryChange(real panelHeight, real soledadHeight,
                                 real malvinaHeight, real soledadRadius,
                                 real malvinaRadius, real soledadWidth,
                                 real malvinaWidth, string buttonShape,
                                 real buttonWidth, string soShape,
                                 string malShape, string gripButtonShape,
                                 string trayShape)
    signal requestAppearanceChange(string soledadColor, real soledadOpacity,
                                   string malvinaColor, real malvinaOpacity,
                                   bool showBackground, string backgroundColor,
                                   real backgroundOpacity, bool trayOverride,
                                   string trayColor, real trayOpacity,
                                   bool gripOverride, string gripColor,
                                   real gripOpacity)

    signal requestAutoReturnRightChange(bool newValue)
    signal requestLauncherIslandVisibilityChange(bool newValue)
    signal requestAutoHideMalvinaChange(bool newValue)
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
        0, root.width - (root.launcherIslandVisible ? launcherIsland.width : 0)
           - 460 - Math.max(0, soButton.implicitWidth - 40) - 12
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
        // Sin ventanas: un clic breve en SO lleva directamente al
        // buscador de apps, sin desplegar una fila vacía.
        if (soWindowCount === 0) {
            openInstalledLauncher("so")
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
        // No permitir abrir lanzadores por autoaparición sobre un juego,
        // video o ventana maximizada: la protección va antes del popup.
        if (requestedSource === "malvina" && autoRevealBlocked)
            return
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
        // El menú se posiciona debajo de Soledad, NO en el cursor ni
        // encima del agarre. "open()" respeta x/y definidos en gripMenu.
        // Clic derecho o teclado lo alternan; izquierdo permite arrastrar.
        if (gripMenu.visible) {
            gripMenu.close()
        } else {
            gripMenu.open()
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

    function openSoledadSettings(tabIndex) {
        // Un solo centro. Leer valores guardados al abrir, no al cambiar
        // pestaña ni al pulsar Aplicar: la ventana permanece visible.
        if (!soledadSettings.visible) {
            soledadSettings.logoMode = root.soLogoMode
            soledadSettings.filePath = root.soLogoPath
            soledadSettings.shape = root.soLogoShape
            soledadSettings.cropFitMode = root.soLogoFitMode
            soledadSettings.cropZoom = root.soLogoZoom
            soledadSettings.cropPanX = root.soLogoPanX
            soledadSettings.cropPanY = root.soLogoPanY
            soledadSettings.cropRotation = root.soLogoRotation
            soledadSettings.enableGif = root.soLogoAnimate
            soledadSettings.clockFontFamily = root.soClockFontFamily
            soledadSettings.clockFontSize = root.soClockFontSize
            soledadSettings.clockTextColor = root.soClockTextColor
            soledadSettings.panelHeight = root.fixedHeight
            soledadSettings.soledadHeight = root.soledadHeight
            soledadSettings.malvinaHeight = root.malvinaHeight
            soledadSettings.soledadRadius = root.soledadRadius
            soledadSettings.malvinaRadius = root.malvinaRadius
            soledadSettings.soledadMinWidth = root.soledadMinWidth
            soledadSettings.malvinaWidth = root.malvinaWidth
            soledadSettings.soledadShape = root.soledadShape
            soledadSettings.malvinaShape = root.malvinaShape
            soledadSettings.gripShape = root.gripShape
            soledadSettings.trayButtonShape = root.trayButtonShape
            soledadSettings.soButtonFrameShape = root.soButtonFrameShape
            soledadSettings.soButtonWidth = root.soButtonWidth
            soledadSettings.soledadColor = root.soledadColor
            soledadSettings.malvinaColor = root.malvinaColor
            soledadSettings.backgroundColor = root.backgroundColor
            soledadSettings.soledadOpacity = root.soledadOpacity
            soledadSettings.malvinaOpacity = root.malvinaOpacity
            soledadSettings.backgroundOpacity = root.backgroundOpacity
            soledadSettings.showBackground = root.showBackground
            soledadSettings.trayButtonColorOverride = root.trayButtonColorOverride
            soledadSettings.trayButtonColor = root.trayButtonColor
            soledadSettings.trayButtonOpacity = root.trayButtonOpacity
            soledadSettings.gripButtonColorOverride = root.gripButtonColorOverride
            soledadSettings.gripButtonColor = root.gripButtonColor
            soledadSettings.gripButtonOpacity = root.gripButtonOpacity
            soledadSettings.effectStyle = root.soActivityStyle
            soledadSettings.accentColor = root.soActivityColor
            soledadSettings.strokeSize = root.soActivityStroke
            soledadSettings.allowMotion = root.soActivityMotion
            soledadSettings.orbitSpeed = root.soActivityOrbitSpeed
            soledadSettings.trailPercent = root.soActivityTrailPercent
            soledadSettings.trailStyle = root.soActivityTrailStyle
            soledadSettings.showOutlineWhenEmpty = root.soActivityShowWhenEmpty
            soledadSettings.showOutlineWhenOpen = root.soActivityShowWhenOpen
            soledadSettings.autoCollapseSO = root.autoCollapseSO
            soledadSettings.autoCollapseTray = root.autoCollapseTray
            soledadSettings.autoReturnRight = root.autoReturnRight
            soledadSettings.launcherIslandVisible = root.launcherIslandVisible
            soledadSettings.autoHideMalvina = root.autoHideMalvina
            soledadSettings.alignedRight = root.alignRightSelected
            soledadSettings.alignmentEdited = false
            soledadSettings.currentTab = tabIndex
        }
        soledadSettings.show()
        soledadSettings.raise()
        soledadSettings.requestActivate()
    }

    SoledadSettings {
        id: soledadSettings
        defaultImage: root.defaultSoLogo
        onSaveClockAppearanceRequested: function(family, size, color) {
            root.requestSoClockAppearanceChange(family, size, color)
        }
        onSaveLogoRequested: function(mode, path, shape, fitMode, zoom, panX, panY,
                                      animate, rotation) {
            root.requestSoLogoChange(mode, path, shape, fitMode,
                                     zoom, panX, panY, animate, rotation)
        }
        onSaveGeometryRequested: function(panel, soH, malH, soRadius, malRadius,
                                          soWidth, malWidth, buttonShape, buttonWidth,
                                          soShape, malShape, gripButtonShape, trayShape) {
            root.requestGeometryChange(panel, soH, malH, soRadius,
                                       malRadius, soWidth, malWidth,
                                       buttonShape, buttonWidth,
                                       soShape, malShape, gripButtonShape, trayShape)
        }
        onSaveAppearanceRequested: function(soColor, soOpacity, malColor,
                                             malOpacity, backgroundShown,
                                             bgColor, bgOpacity, trayOverride,
                                             trayColor, trayOpacity,
                                             gripOverride, gripColor, gripOpacity) {
            root.requestAppearanceChange(soColor, soOpacity, malColor,
                                         malOpacity, backgroundShown, bgColor,
                                         bgOpacity, trayOverride, trayColor,
                                         trayOpacity, gripOverride, gripColor,
                                         gripOpacity)
        }
        onSaveActivityRequested: function(style, color, stroke, motion,
                                          speed, tailLength, lineStyle,
                                          showWhenEmpty, showWhenOpen) {
            root.requestSoActivityChange(style, color, stroke, motion,
                                         speed, tailLength, lineStyle,
                                         showWhenEmpty, showWhenOpen)
        }
        onSaveAutoHideMalvinaRequested: function(value) {
            if (value !== root.autoHideMalvina)
                root.requestAutoHideMalvinaChange(value)
        }
        onSaveBehaviorRequested: function(collapseSO, collapseTray,
                                          returnRight, showMalvina, alignRight,
                                          alignmentEdited) {
            if (collapseSO !== root.autoCollapseSO)
                root.requestAutoCollapseSOChange(collapseSO)
            if (collapseTray !== root.autoCollapseTray)
                root.requestAutoCollapseTrayChange(collapseTray)
            if (showMalvina !== root.launcherIslandVisible)
                root.setLauncherIslandVisible(showMalvina)
            if (returnRight !== root.autoReturnRight)
                root.setAutoReturnRight(returnRight)
            // El usuario puede haber movido Soledad mientras el diálogo
            // está abierto. No forzar un retorno si no tocó esta casilla.
            if (alignmentEdited && alignRight !== root.alignRightSelected) {
                if (alignRight) root.alignRightNow()
                else root.alignRightSelected = false
            }
        }
        onAlignNowRequested: root.alignRightNow()
    }

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
        onClosed: {
            if (root.autoHideMalvina && !malvinaHotspotHover.hovered)
                malvinaHideTimer.restart()
        }
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

        // Capa decorativa opcional, siempre detrás de las islas.
        // No crea una nueva fila ni modifica su grosor constante.
        Rectangle {
            anchors.fill: parent
            visible: root.showBackground
            color: Qt.rgba(root.backgroundColor.r, root.backgroundColor.g,
                           root.backgroundColor.b, root.backgroundOpacity)
        }

        // Zona pasiva de hover: no captura clics ni modifica el grosor.
        // Esta zona siempre existe para detectar la posición de Malvina.
        // El paso efectivo de clics a ventanas ajenas requiere validar KWin.
        Item {
            id: malvinaHotspot
            width: Math.max(launcherButton.implicitWidth + 12, root.malvinaWidth)
            height: Math.max(32, Math.min(root.fixedHeight - 4, root.malvinaHeight))
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            HoverHandler {
                id: malvinaHotspotHover
                enabled: !root.autoRevealBlocked &&
                         root.launcherIslandVisible && root.autoHideMalvina
                onHoveredChanged: {
                    if (hovered) {
                        malvinaHideTimer.stop()
                        if (!root.autoRevealBlocked)
                            malvinaRevealTimer.restart()
                    } else {
                        malvinaRevealTimer.stop()
                        if (!root.malvinaPopupActive)
                            malvinaHideTimer.restart()
                    }
                }
            }

            Rectangle {
            id: launcherIsland
            visible: root.malvinaActuallyVisible
            anchors.fill: parent
            radius: root.malvinaShape === "square" ? 0 :
                Math.max(0, Math.min(root.malvinaRadius, height / 2))
            topLeftRadius: root.malvinaShape === "leftSquareRightRound" ? 0 : radius
            bottomLeftRadius: root.malvinaShape === "leftSquareRightRound" ? 0 : radius
            topRightRadius: root.malvinaShape === "leftRoundRightSquare" ? 0 : radius
            bottomRightRadius: root.malvinaShape === "leftRoundRightSquare" ? 0 : radius
            color: Qt.rgba(root.malvinaColor.r, root.malvinaColor.g,
                           root.malvinaColor.b, root.malvinaOpacity)
            border.color: "#4e8499"
            border.width: 1
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
        }

        // Isla 1: anclaje propio desplazable, independiente de su expansión.
        Rectangle {
            id: systemIsland
            height: Math.max(32, Math.min(root.fixedHeight - 4, root.soledadHeight))
            width: Math.max(systemRow.implicitWidth + 12 +
                            (root.soledadShape === "leftTip" ? 28 : 0),
                            root.soledadMinWidth)
            // Al cambiar fichas o espacio por arrastre, mantener ambas
            // expansiones salvo que realmente dejen de caber.
            onWidthChanged: root.ensureExpansionFits()
            radius: root.soledadShape === "square" ||
                    root.soledadShape === "leftTip" ? 0 :
                    Math.max(0, Math.min(root.soledadRadius, height / 2))
            topLeftRadius: root.soledadShape === "leftSquareRightRound" ? 0 : radius
            bottomLeftRadius: root.soledadShape === "leftSquareRightRound" ? 0 : radius
            topRightRadius: root.soledadShape === "leftRoundRightSquare" ? 0 : radius
            bottomRightRadius: root.soledadShape === "leftRoundRightSquare" ? 0 : radius
            color: root.soledadShape === "leftTip" ? "transparent" :
                Qt.rgba(root.soledadColor.r, root.soledadColor.g,
                           root.soledadColor.b, root.soledadOpacity)
            border.color: "#4e8499"
            border.width: root.soledadShape === "leftTip" ? 0 : 1
            anchors.right: parent.right
            // Los controles de ventana quedan en el extremo derecho INMÓVILES.
            // La isla 1 se arrastra solo a la izquierda del espacio reservado.
            anchors.rightMargin: root.islandOffset + root.controlsReservation
            anchors.verticalCenter: parent.verticalCenter

            // Punta triangular opcional. Solo se pinta cuando cambia algo,
            // sin animación ni una fila extra. Botón de bandeja queda a la
            // derecha de la zona estrecha para conservar el área de clic.
            Canvas {
                id: soTipBackground
                anchors.fill: parent
                visible: root.soledadShape === "leftTip"
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                Connections {
                    target: root
                    function onSoledadColorChanged() { soTipBackground.requestPaint() }
                    function onSoledadOpacityChanged() { soTipBackground.requestPaint() }
                    function onSoledadShapeChanged() { soTipBackground.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.beginPath()
                    ctx.moveTo(1, height / 2)
                    ctx.lineTo(24, 1)
                    ctx.lineTo(width - 1, 1)
                    ctx.lineTo(width - 1, height - 1)
                    ctx.lineTo(24, height - 1)
                    ctx.closePath()
                    ctx.fillStyle = Qt.rgba(root.soledadColor.r, root.soledadColor.g,
                                            root.soledadColor.b, root.soledadOpacity)
                    ctx.strokeStyle = "#4e8499"
                    ctx.lineWidth = 1
                    ctx.fill()
                    ctx.stroke()
                }
            }
            Row {
                id: systemRow
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - width) / 2 +
                    (root.soledadShape === "leftTip" ? 12 : 0)

                IslandButton {
                    text: root.trayExpanded ? "▶" : "◀"
                    frameShape: root.trayButtonShape
                    useTileColor: true
                    tileColor: root.effectiveTrayButtonColor
                    tileOpacity: root.effectiveTrayButtonOpacity
                    onClicked: root.toggleTray()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Abrir/cerrar bandeja simulada"
                }

                Repeater {
                    model: root.trayExpanded ? root.demoTray : []
                    delegate: IslandButton {
                        text: modelData
                        useTileColor: true
                        tileColor: root.effectiveTrayButtonColor
                        tileOpacity: root.effectiveTrayButtonOpacity
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

                // Modo histórico de maqueta: NO se altera la prueba de
                // fichas ficticias ni su autocontracción configurada.
                Repeater {
                    model: root.soExpanded && !root.usingRealTasks &&
                           root.demoHasRunningWindows ? root.demoApps : []
                    delegate: IslandButton {
                        text: modelData
                        onClicked: root.selectDemoApp(modelData)
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Ficha ficticia: " + modelData
                    }
                }

                // Nuevo ensayo: KDE TasksModel de solo lectura, inyectado
                // únicamente por el visor Qt. El Repeater actualiza las
                // fichas al abrir/cerrar ventanas; no llama a requestActivate,
                // requestClose ni métodos para minimizar o alterar ventanas.
                // Repetición horizontal dentro del mismo Row, sin otra fila.
                Repeater {
                    model: root.soExpanded && root.usingRealTasks
                        ? root.realTaskModel : null
                    delegate: IslandButton {
                        required property var model
                        readonly property string appName:
                            model.AppName || "(aplicación sin nombre)"
                        readonly property bool isGrouped: model.IsGroupParent === true
                        readonly property int windowCount: Number(model.ChildCount) || 0
                        text: appName + (isGrouped && windowCount > 1
                                        ? " (" + windowCount + ")" : "")
                        // Se deja deliberadamente sin acción sobre KDE.
                        // El clic solo informa en Konsole que es una prueba.
                        onClicked: console.log("SO solo lectura: ", appName,
                                               "(sin activar ventanas)")
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Ventana real de KDE: " + appName
                            + (model.IsActive === true ? " · activa" : "")
                            + (model.IsMaximized === true ? " · maximizada" : "")
                            + (isGrouped ? " · grupo de ventanas" : "")
                            + " · SOLO LECTURA"
                    }
                }

                IslandButton {
                    id: soButton
                    text: "SO"
                    accent: true
                    activityCount: root.soWindowCount
                    activityEffect: root.soActivityStyle
                    activityColor: root.soActivityColor
                    activityStroke: root.soActivityStroke
                    activityMotionAllowed: root.soActivityMotion
                    activityOrbitSpeed: root.soActivityOrbitSpeed
                    activityTrailPercent: root.soActivityTrailPercent
                    activityTrailStyle: root.soActivityTrailStyle
                    activityShowWhenEmpty: root.soActivityShowWhenEmpty
                    activityShowWhenOpen: root.soActivityShowWhenOpen
                    iconSource: root.activeSoLogo
                    iconAnimated: root.activeSoLogoIsGif
                    iconAnimationEnabled: root.soLogoAnimate
                    clockVisible: root.soClockVisible
                    clockPhase: root.soClockPhase
                    clockTime: root.soClockTime
                    clockDate: root.soClockDate
                    clockFontFamily: root.soClockFontFamily
                    clockFontSize: root.soClockFontSize
                    clockTextColor: root.soClockTextColor
                    iconShape: root.soLogoShape
                    iconFitMode: root.soLogoFitMode
                    iconZoom: root.soLogoZoom
                    iconPanX: root.soLogoPanX
                    iconPanY: root.soLogoPanY
                    iconRotation: root.soLogoRotation
                    frameShape: root.soButtonFrameShape
                    preferredButtonHeight: Math.max(30, systemIsland.height - 10)
                    preferredButtonWidth: root.soButtonFrameShape === "square"
                        ? Math.max(40, systemIsland.height - 8)
                        : Math.max(44, root.soButtonWidth)

                    // Clic corto: ventanas abiertas si hay alguna; con cero
                    // ventanas, abrir el lanzador. Mantener unos 400 ms:
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

                    // Derecho sobre SO abre DIRECTAMENTE el lanzador
                    // (en v0.1, aplicaciones de muestra). Las opciones,
                    // incluida Mostrar/Ocultar Malvina, pertenecen SOLO
                    // al menú de los seis puntos. Teclado conserva acceso.
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Menu ||
                            (event.key === Qt.Key_F10 &&
                             (event.modifiers & Qt.ShiftModifier))) {
                            root.openInstalledLauncher("so")
                            event.accepted = true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: root.openInstalledLauncher("so")
                    }

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: root.soWindowCount === 0
                        ? "SO: izquierdo abre buscador de apps · derecho o mantener pulsado también"
                        : (root.launcherIslandVisible
                           ? "SO: izquierdo ventanas · derecho o mantener 0,4 s lanzador"
                           : "SO: derecho o mantener pulsado abre apps · seis puntos: Mostrar Malvina")
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
                    property bool draggedDuringPress: false
                    // Evitar que la ayuda quede flotando en la posición vieja
                    // cuando el agarre se desplaza o hay un menú abierto.
                    property bool suppressGripTooltip: false
                    onHoveredChanged: {
                        if (hovered && !pressed && !gripDrag.active &&
                                !gripMenu.visible) {
                            soClockRevealTimer.restart()
                        } else {
                            soClockRevealTimer.stop()
                        }
                        if (!hovered) suppressGripTooltip = false
                    }
                    onPressed: {
                        root.dismissSoClock()
                        draggedDuringPress = false
                        suppressGripTooltip = true
                        // Cerrar ANTES de iniciar el arrastre. Si el menú
                        // sigue como ventana separada puede capturar el ratón
                        // o permanecer atrás en su coordenada original.
                        if (gripMenu.visible) gripMenu.close()
                    }
                    // Clic izquierdo BREVE: si las opciones ya estaban
                    // abiertas, cerrarlas sin reabrir. Si estaban cerradas,
                    // no hacer nada: la apertura sigue siendo por derecho.
                    // Si hubo arrastre, no interpretarlo como clic de cierre.
                    onClicked: {
                        if (gripMenu.visible && !draggedDuringPress) {
                            gripMenu.close()
                        }
                    }
                    background: Rectangle {
                        radius: root.gripShape === "square" ? 0 : 17
                        color: Qt.rgba(root.effectiveGripButtonColor.r,
                                       root.effectiveGripButtonColor.g,
                                       root.effectiveGripButtonColor.b,
                                       root.effectiveGripButtonOpacity)
                        border.width: 1
                        border.color: moveGrip.hovered ? "#86b3cc" : "#45647a"
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
                    // El izquierdo solo puede CERRAR opciones ya abiertas.
                    // El derecho alterna abrir/cerrar y no intercepta
                    // el arrastre horizontal del botón izquierdo.
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
                    QQC2.ToolTip.visible: hovered && !root.soClockVisible &&
                        !moveGrip.pressed &&
                        !gripDrag.active && !gripMenu.visible &&
                        !moveGrip.suppressGripTooltip
                    QQC2.ToolTip.delay: 850
                    QQC2.ToolTip.text: root.launcherIslandVisible
                        ? "Izquierdo: arrastrar o cerrar menú · Derecho: opciones"
                        : "Malvina oculta · Derecho: opciones → Mostrar Malvina"

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
                                root.dismissSoClock()
                                moveGrip.draggedDuringPress = true
                                moveGrip.suppressGripTooltip = true
                                // Resguardo para los casos en que Qt entregue
                                // el gesto directamente al DragHandler.
                                if (gripMenu.visible) gripMenu.close()
                                // Tomar el margen actual justo al iniciar
                                // el gesto; no volver a una posición antigua.
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
                        onOpened: root.dismissSoClock()
                        // Anclar el menú directamente al agarre que lo abrió,
                        // NO a root: el cálculo anterior con root.width - width
                        // podía desplazarlo hasta Malvina (extremo izquierdo).
                        // En Qt, x/y son relativos al parent del Popup.
                        parent: moveGrip
                        // Qt 6.8+: ventana flotante para no recortar el menú
                        // al superar la altura de la ventana de ensayo.
                        popupType: QQC2.Popup.Window
                        // Si cambia la posición horizontal por arrastre, el
                        // Popup de ventana se cierra antes de mover Soledad.
                        // No queda desacoplado en su ubicación anterior.
                        // El borde derecho del menú coincide con el agarre,
                        // por lo que aparece cerca del puntero incluso cuando
                        // Soledad se arrastra. Ancho explícito: no depender de
                        // la medida inicial del popup al abrirse.
                        width: 380
                        x: moveGrip.width - width
                        // El botón está centrado verticalmente en la isla;
                        // sumar su alto y un margen deja el menú DEBAJO.
                        y: moveGrip.height + 10
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
                            text: "Configuración de Soledad…"
                            // Logo, colores, contorno, autocontracción,
                            // islas y posición comparten ventana con pestañas.
                            onTriggered: root.openSoledadSettings(0)
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            enabled: !root.usingRealTasks
                            text: root.usingRealTasks
                                ? "SO conectado a tareas reales (solo lectura)"
                                : (root.demoHasRunningWindows
                                   ? "Simular SO SIN ventanas (0)"
                                   : "Simular SO CON ventanas (3)")
                            onTriggered: root.demoHasRunningWindows = !root.demoHasRunningWindows
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            text: "Simular ventana maximizada"
                            checkable: true
                            checked: root.previewMaximized
                            onTriggered: root.setPreviewMaximized(!root.previewMaximized)
                        }
                        QQC2.MenuItem {
                            text: "Simular pantalla completa (bloquea Malvina)"
                            checkable: true
                            checked: root.previewFullscreen
                            onTriggered: root.previewFullscreen = !root.previewFullscreen
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
