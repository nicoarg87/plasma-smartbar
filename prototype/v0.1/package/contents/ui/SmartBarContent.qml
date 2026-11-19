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
    property string malvinaGoogleUrl: "https://www.google.com/search?q={query}"
    property string malvinaDuckUrl: "https://duckduckgo.com/?q={query}"
    property string malvinaYahooUrl: "https://search.yahoo.com/search?p={query}"
    property string malvinaChatGptUrl: "https://chatgpt.com/"
    property string malvinaGeminiUrl: "https://gemini.google.com/app"
    property string malvinaClaudeUrl: "https://claude.ai/new"
    property bool malvinaWebFirst: true
    property string malvinaWebOrder: "google,duck,yahoo"
    property string malvinaAiOrder: "chatgpt,gemini,claude"
    property string malvinaExtraWeb: "[]"
    property string malvinaExtraAi: "[]"
    property string malvinaHiddenWeb: ""
    property string malvinaHiddenAi: ""
    property bool malvinaCompactAi: false
    signal requestMalvinaExtrasChange(string webJson, string aiJson,
                                      string hiddenWeb, string hiddenAi, bool compactAi)
    signal requestMalvinaOrderChange(bool firstWeb, string webOrder, string aiOrder)
    property string malvinaGoogleName: "Google"
    property string malvinaDuckName: "DuckDuckGo"
    property string malvinaYahooName: "Yahoo"
    property string malvinaChatGptName: "ChatGPT"
    property string malvinaGeminiName: "Gemini"
    property string malvinaClaudeName: "Claude"
    signal requestMalvinaNamesChange(string google, string duck, string yahoo,
                                     string chatGpt, string gemini, string claude)
    // Consentimiento futuro para envío directo; nunca habilita envíos por sí mismo.
    property bool malvinaWebGoogleEnabled: true
    property bool malvinaWebDuckEnabled: true
    property bool malvinaWebYahooEnabled: true
    signal requestMalvinaWebEnabledChange(bool google, bool duck, bool yahoo)
    property bool malvinaAllowChatGpt: false
    property bool malvinaAllowGemini: false
    property bool malvinaAllowClaude: false
    signal requestMalvinaConsentsChange(bool chatGpt, bool gemini, bool claude)
    signal requestMalvinaProvidersChange(string google, string duck, string yahoo,
                                         string chatGpt, string gemini, string claude)
    property string soledadShape: "leftRoundRightSquare"
    property string malvinaShape: "rounded"
    property string malvinaGearButtonShape: "square"
    property string malvinaSearchButtonShape: "square"
    signal requestMalvinaButtonShapesChange(string gearShape, string searchShape)
    signal requestPersistCurrentSettings()
    property string gripShape: "rounded"
    property string trayButtonShape: "rounded"
    property bool taskActiveGlowEnabled: true
    property bool taskActiveDoubleBorderEnabled: false
    signal requestTaskActiveIndicatorChange(bool glowEnabled, bool doubleBorderEnabled)
    property string taskDisplayMode: "icon" // text, both, icon
    property string taskFrameShape: "rounded"
    property color taskFrameColor: "#ffffff"
    property real taskFrameOpacity: 0.12
    property real taskFrameWidth: 1
    signal requestTaskDisplayModeChange(string mode)
    signal requestTaskFrameChange(string shape, string color, real opacity, real width)
    function demoIconForApp(name) {
        const label = String(name).toLowerCase()
        if (label.includes("brave")) return "brave-browser"
        if (label.includes("dolphin")) return "system-file-manager"
        if (label.includes("konsole")) return "utilities-terminal"
        if (label.includes("plasma")) return "plasma"
        if (label.includes("qt")) return "qtcreator"
        return "application-x-executable"
    }
    property var outlineConfig: ({"soledad":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"malvina":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"tray":{"style":"solid","width":1,"color":"#45647a","opacity":1},"grip":{"style":"solid","width":1,"color":"#45647a","opacity":1}})
    signal requestOutlineChange(var updated)
    signal requestIslandGradientChange(bool soEnabled, string soEnd, string soDirection,
                                       bool malEnabled, string malEnd, string malDirection)
    signal requestGradientBreathingChange(bool enabled, real intensity)
    signal requestMalvinaGradientBreathingChange(bool enabled, real intensity)
    // Logo SO panorámico: cápsula, imagen tropical estirada de origen.
    property string soButtonFrameShape: "capsule"
    property real soButtonWidth: 96
    property string soTextLabel: "SO"
    property color soTextColor: "#ffffff"
    property color soTextBackground: "#192536"
    property real soTextBackgroundOpacity: 0.9
    property string soTextFontFamily: "Sans Serif"
    property int soTextFontSize: 13
    property bool soTextBold: true
    property string soTextBackgroundImage: ""
    implicitHeight: fixedHeight
    property bool autoReturnRight: true
    // Malvina permanece ACTIVADA por defecto, pero NO siempre visible.
    // launcherIslandVisible es la clave histórica KConfig de habilitación;
    // no cambiar su nombre para conservar preferencias previas. Visibilidad
    // automática es el valor inicial; siempre visible es opción explícita.
    property bool launcherIslandVisible: true
    property bool autoHideMalvina: true
    property bool malvinaHoverRevealed: false
    // Confirmación breve de la acción Mostrar/Ocultar del menú de seis puntos.
    // Es visible solo en el visor permitido; no añade animaciones ni altura.
    property bool malvinaVisibilityCue: false
    property bool malvinaPendingHide: false
    Timer {
        id: malvinaVisibilityCueTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (root.malvinaPendingHide)
                root.requestLauncherIslandVisibilityChange(false)
            root.malvinaPendingHide = false
            root.malvinaVisibilityCue = false
        }
    }
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
            malvinaVisibilityCueTimer.stop()
            if (malvinaPendingHide)
                requestLauncherIslandVisibilityChange(false)
            malvinaPendingHide = false
            malvinaVisibilityCue = false
            malvinaRevealTimer.stop()
            malvinaHideTimer.stop()
            malvinaHoverRevealed = false
            if (malvinaPopupActive) {
                installedAppsPopup.close()
                malvinaSearch.expanded = false
            }
        }
    }
    readonly property bool malvinaPopupActive:
        (installedAppsPopup.visible && installedLauncherSource === "malvina") ||
        malvinaSearch.expanded ||
        (soledadSettings.visible && soledadSettings.currentTab === 0 &&
         soledadSettings.currentIslandSubtab === 2)
    readonly property bool malvinaActuallyVisible:
        !autoRevealBlocked && launcherIslandVisible &&
        (!autoHideMalvina || malvinaHoverRevealed || malvinaPopupActive ||
         malvinaVisibilityCue)
    onLauncherIslandVisibleChanged: {
        if (!launcherIslandVisible) {
            malvinaVisibilityCueTimer.stop()
            malvinaPendingHide = false
            malvinaVisibilityCue = false
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
    // Cada Popup gestiona sus clics exteriores mediante closePolicy de Qt.
    // No cerrar globalmente desde Overlay.onPressed: ese evento también
    // llegaba al pulsar controles DENTRO del launcher en CachyOS.
    // Preferencias independientes: no contraer por abrir la otra sección
    // cuando ambas caben. SO se cierra tras seleccionar, por defecto.
    property bool autoCollapseSO: true
    // Corrección del mantenedor 18/11: izquierdo = cajón (ventanas abiertas),
    // derecho = launcher de aplicaciones. Es reversible en Configuración.
    property bool soLeftClickOpensLauncher: false
    property bool soTooltipSuppressed: false
    // Estética del launcher heredada de Soledad; solo el interruptor
    // tiene opciones independientes, desactivadas por defecto.
    property int launcherCategoryLayout: 0  // A = original, B = panel a la izquierda
    property string launcherSwitchShape: "capsule"
    property bool launcherSwitchColorOverride: false
    property color launcherSwitchColor: "#010111"
    property int launcherMaxSlots: 20
    property bool launcherOpacityOverride: false
    property real launcherOpacity: 1
    property bool launcherIconsWithNames: true
    property bool malvinaOptionsOpacityOverride: false
    property real malvinaOptionsOpacity: 1
    property real launcherAvailableHeight: 450
    property var localAppCatalog: []
    property bool localCatalogReady: false
    // El visor carga metadatos .desktop locales de solo lectura, si existen.
    // El plasmoide no ejecuta archivos ni comandos a través de este catálogo.
    function loadLocalAppCatalog() {
        const req = new XMLHttpRequest()
        req.onreadystatechange = function() {
            if (req.readyState !== XMLHttpRequest.DONE) return
            if (req.status === 200 || req.status === 0) {
                try {
                    const data = JSON.parse(req.responseText)
                    if (Array.isArray(data) && data.length > 0) {
                        root.localAppCatalog = data
                        root.localCatalogReady = true
                    }
                } catch(e) { console.warn("SmartBar: catálogo local no legible", e) }
            }
        }
        req.open("GET", Qt.resolvedUrl(".smartbar-app-catalog-preview.json"), true)
        req.send()
    }
    Component.onCompleted: loadLocalAppCatalog()
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
        // Una vez iniciado el gesto de acercarse al agarre, los clics,
        // el arrastre y el Popup NO cancelan la secuencia hora/fecha.
        // Tampoco reiniciarla en mitad de una secuencia en curso.
        if (soClockVisible) return
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
    property bool soledadGradientEnabled: false
    property color soledadGradientEnd: "#ee9852"
    property string soledadGradientDirection: "topBottom"
    property bool soledadGradientSyncBreathing: false
    property real soledadGradientBreathingIntensity: 0.6
    property real sharedBreathingPhase: 0
    // Una sola fase: Soledad y Malvina pueden sumarse de forma independiente.
    readonly property bool soBreathingSourceActive:
        soActivityStyle === "breathe" && soActivityMotion &&
        (soWindowCount > 0 ? soActivityShowWhenOpen : soActivityShowWhenEmpty)
    readonly property bool soledadGradientBreathingActive:
        soBreathingSourceActive && soledadGradientEnabled && soledadGradientSyncBreathing
    readonly property bool malvinaGradientBreathingActive:
        soBreathingSourceActive && malvinaGradientEnabled && malvinaGradientSyncBreathing
    readonly property bool sharedBreathingActive:
        soledadGradientBreathingActive || malvinaGradientBreathingActive
    function breathingFactor(intensity) {
        const wave = 0.5 - 0.5 * Math.cos(2 * Math.PI * sharedBreathingPhase)
        const depth = Math.max(0, Math.min(1, soActivityPulseDepth))
        return 1 - Math.max(0, Math.min(1, intensity)) * depth * (1 - wave)
    }
    readonly property real gradientBreathingFactor:
        soledadGradientBreathingActive ? breathingFactor(soledadGradientBreathingIntensity) : 1
    readonly property real malvinaGradientBreathingFactor:
        malvinaGradientBreathingActive ? breathingFactor(malvinaGradientBreathingIntensity) : 1
    Timer {
        id: synchronizedBreathingTimer
        interval: 50
        repeat: true
        running: root.sharedBreathingActive
        onTriggered: {
            const speed = Math.max(0.1, Math.min(3, root.soActivityPulseSpeed))
            root.sharedBreathingPhase = (root.sharedBreathingPhase + speed * interval / 1000) % 1
        }
    }
    property bool malvinaGradientSyncBreathing: false
    property real malvinaGradientBreathingIntensity: 0.6
    property bool malvinaGradientEnabled: false
    property color malvinaGradientEnd: "#445577"
    property string malvinaGradientDirection: "topBottom"
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
    property color soActivityGlowColor: "#ffab52"
    property real soActivityGlowIntensity: 0.7
    property real soActivityGlowSpread: 5
    property real soActivityPulseSpeed: 0.6
    property real soActivityPulseDepth: 0.7
    property bool soActivityGlowGradient: true
    onSoWindowCountChanged: {
        if (soWindowCount === 0) soExpanded = false
    }
    signal requestSoActivityChange(string style, string color,
                                   real stroke, bool allowMotion,
                                   real speed, int tailLength, string lineStyle,
                                   bool showWhenEmpty, bool showWhenOpen)

    signal requestSoGlowChange(string glowColor, real intensity, real spread,
                               real pulseSpeed, real pulseDepth, bool gradient)
    signal requestSoClockAppearanceChange(string fontFamily, int fontSize,
                                          string textColor)
    signal requestSoTextChange(string label, string textColor,
                               string background, real opacity,
                               string fontFamily, int fontSize, bool bold,
                               string backgroundImage)
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
    signal requestSoClickMappingChange(bool leftOpensLauncher)
    signal requestLauncherStyleChange(int layoutMode, string switchShape,
                                     bool switchCustomColor, string switchColor,
                                     int maxVisibleSlots)
    signal requestLauncherOpacityChange(bool overrideOpacity, real opacityValue)
    signal requestLauncherIconDisplayChange(bool iconsWithNames)
    signal requestMalvinaOptionsOpacityChange(bool overrideOpacity, real opacityValue)
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
    // Variante opcional. El modo tradicional conserva expansión a izquierda.
    property string positionMode: "right" // right, center
    property bool centeredPositionDragged: false
    readonly property bool centeredPresentation: positionMode === "center"
    property real manualSoCenterX: 0
    property real dragStartSoCenterX: 0
    readonly property real soAnchorCenterX: centeredPositionDragged
        ? manualSoCenterX : root.width / 2
    // El centro se calcula con la isla CONTRAÍDA: al abrir SO la
    // esquina izquierda permanece fija y las fichas crecen a derecha.
    readonly property real centerBaseWidth: Math.max(soledadMinWidth,
        12 + (soledadShape === "leftTip" ? 28 : 0) +
        trayToggle.implicitWidth + soButton.implicitWidth +
        moveGrip.implicitWidth + systemRow.spacing * 2)
    signal requestPositionModeChange(string mode)
    onPositionModeChanged: {
        centeredPositionDragged = false
        if (positionMode === "center") {
            soExpanded = false
            trayExpanded = false
            alignRightSelected = false
        }
    }
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
    // Zona reservada para Malvina aunque esté oculta temporalmente:
    // su hotspot debe quedar alcanzable con el puntero.
    readonly property real leftReserved: launcherIslandVisible
        ? malvinaHotspot.width + 12 : 8
    readonly property real rightReserved: controlsReservation + 8
    readonly property real maxIslandOffset: Math.max(0,
        root.width - leftReserved - rightReserved -
        Math.max(0, systemIsland.width))
    readonly property real naturalIslandWidth:
        systemRow.implicitWidth + 12 + (soledadShape === "leftTip" ? 28 : 0)
    // Máximo que puede ocupar una isla sin invadir Malvina ni controles.
    readonly property real physicalIslandLimit: Math.max(0,
        root.width - leftReserved - rightReserved)
    // Espacio físico desde el borde izquierdo libre hasta la derecha de
    // Soledad. Se calcula en el ancho REAL, respetando Malvina si está visible.
    readonly property real availableIslandWidth: centeredPresentation
        ? physicalIslandLimit
        : Math.max(0, root.width - islandOffset -
                     leftReserved - rightReserved)
    // Sólo lectura para el visor Qt de pruebas: mostrar cuánto ocupa
    // Soledad frente al espacio real disponible, sin alterar su aspecto.
    readonly property real actualIslandWidth: systemIsland.width
    onAvailableIslandWidthChanged: ensureExpansionFits()

    function setIslandOffset(offset) {
        islandOffset = Math.max(0, Math.min(maxIslandOffset, offset))
    }

    function alignRightNow() {
        // Cambiar de referencia no debe transportar una isla expandida.
        soExpanded = false
        trayExpanded = false
        if (positionMode !== "right") requestPositionModeChange("right")
        centeredPositionDragged = false
        setIslandOffset(0)
        alignRightSelected = true
        console.log("SmartBar v0.1: isla 1 alineada a la derecha")
    }

    function alignCenterNow() {
        if (positionMode !== "center") requestPositionModeChange("center")
        soExpanded = false
        trayExpanded = false
        centeredPositionDragged = false
        alignRightSelected = false
    }

    function returnToConfiguredPosition() {
        // El menú no cambia la preferencia right/center.
        if (positionMode === "center") alignCenterNow()
        else alignRightNow()
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

        if (root.centeredPresentation) {
            // El centro permanece centrado; controles maximizados
            // continúan anclados al extremo derecho.
        } else if (value) {
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
            if (root.positionMode === "center") alignCenterNow()
            else alignRightNow()
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
            if (positionMode === "center") alignCenterNow()
            else alignRightNow()
        }
        console.log("SmartBar v0.1: retorno automático =", value,
                    "desplazamiento =", islandOffset)
    }

    function ensureExpansionFits() {
        if (centeredPresentation) {
            if (!soExpanded && !trayExpanded) return
            const leftLimit = leftReserved
            const rightLimit = root.width - rightReserved
            if (naturalIslandWidth > physicalIslandLimit + 0.5 ||
                systemIsland.x < leftLimit - 0.5 ||
                systemIsland.x + systemIsland.width > rightLimit + 0.5) {
                if (soExpanded && trayExpanded) {
                    if (lastExpandedMode === "so") trayExpanded = false
                    else soExpanded = false
                } else if (soExpanded) soExpanded = false
                else if (trayExpanded) trayExpanded = false
                console.warn("Soledad: expansion centrada fuera de limites; contraida")
            }
            return
        }
        if (!soExpanded || !trayExpanded) return
        if (naturalIslandWidth > availableIslandWidth + 0.5) {
            if (lastExpandedMode === "tray") soExpanded = false
            else trayExpanded = false
        }
    }

    function toggleOpenWindowsFromSO() {
        // El selector de ventanas y el lanzador son independientes.
        // Si cambia el gesto mientras el lanzador está abierto,
        // permitir abrir las ventanas en el MISMO clic.
        if (installedAppsPopup.visible)
            installedAppsPopup.close()
        // No enviar al lanzador por falta de ventanas: el gesto elegido
        // para "ventanas abiertas" conserva su significado.
        if (soWindowCount === 0) {
            soExpanded = false
            return
        }
        if (soExpanded) {
            soExpanded = false
        } else {
            lastExpandedMode = "so"
            soExpanded = true
            ensureExpansionFits()
        }
    }

    function triggerSOButton(leftClick) {
        const launch = leftClick === soLeftClickOpensLauncher
        if (launch)
            openInstalledLauncher("so")
        else
            toggleOpenWindowsFromSO()
    }

    function toggleSO() { toggleOpenWindowsFromSO() }

    function openMalvinaSettings() {
        root.openSoledadSettings(0, 2)
    }
    // Solo funciona dentro de la ventana Qt que ya tenga el foco.
    // Meta+Espacio GLOBAL necesita una acción KF6/KGlobalAccel posterior.
    Shortcut {
        sequence: "Meta+Space"
        context: Qt.WindowShortcut
        enabled: root.launcherIslandVisible && !root.autoRevealBlocked
        onActivated: malvinaSearch.focusSearch()
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
        installedAppsPopup.resetAndFocus()
        installedAppsPopup.open()
        installedAppsPopup.focusInput()
        console.log("SmartBar v0.1: lanzador simulado desde",
                    installedLauncherSource, "(sin iniciar aplicaciones)")
    }

    function setLauncherIslandVisible(value, previewForNovice) {
        malvinaVisibilityCueTimer.stop()
        malvinaPendingHide = false
        malvinaVisibilityCue = false
        if (!previewForNovice || autoRevealBlocked) {
            requestLauncherIslandVisibilityChange(value)
            if (!value) launcherPreview = false
            return
        }
        if (value) {
            requestLauncherIslandVisibilityChange(true)
            // Mostrar un segundo la isla para señalar dónde se encuentra.
            // Si el usuario desactivó autoocultamiento, permanece visible.
            if (autoHideMalvina) {
                malvinaVisibilityCue = true
                malvinaVisibilityCueTimer.restart()
            }
        } else if (launcherIslandVisible) {
            // Si estaba autooculta, volver a mostrarla un segundo para que
            // se comprenda qué control se está deshabilitando.
            malvinaVisibilityCue = true
            malvinaPendingHide = true
            malvinaVisibilityCueTimer.restart()
        } else {
            requestLauncherIslandVisibilityChange(false)
        }
        if (!value) launcherPreview = false
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

    function openSoledadSettings(tabIndex, islandSubtabIndex) {
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
            soledadSettings.malvinaGoogleUrl = root.malvinaGoogleUrl
            soledadSettings.malvinaDuckUrl = root.malvinaDuckUrl
            soledadSettings.malvinaYahooUrl = root.malvinaYahooUrl
            soledadSettings.malvinaChatGptUrl = root.malvinaChatGptUrl
            soledadSettings.malvinaGeminiUrl = root.malvinaGeminiUrl
            soledadSettings.malvinaClaudeUrl = root.malvinaClaudeUrl
            soledadSettings.malvinaWebFirst = root.malvinaWebFirst
            soledadSettings.malvinaWebOrder = root.malvinaWebOrder
            soledadSettings.malvinaAiOrder = root.malvinaAiOrder
            soledadSettings.malvinaExtraWeb = root.malvinaExtraWeb
            soledadSettings.malvinaExtraAi = root.malvinaExtraAi
            soledadSettings.malvinaHiddenWeb = root.malvinaHiddenWeb
            soledadSettings.malvinaHiddenAi = root.malvinaHiddenAi
            soledadSettings.malvinaCompactAi = root.malvinaCompactAi
            soledadSettings.malvinaGoogleName = root.malvinaGoogleName
            soledadSettings.malvinaDuckName = root.malvinaDuckName
            soledadSettings.malvinaYahooName = root.malvinaYahooName
            soledadSettings.malvinaChatGptName = root.malvinaChatGptName
            soledadSettings.malvinaGeminiName = root.malvinaGeminiName
            soledadSettings.malvinaClaudeName = root.malvinaClaudeName
            soledadSettings.malvinaWebGoogleEnabled = root.malvinaWebGoogleEnabled
            soledadSettings.malvinaWebDuckEnabled = root.malvinaWebDuckEnabled
            soledadSettings.malvinaWebYahooEnabled = root.malvinaWebYahooEnabled
            soledadSettings.malvinaAllowChatGpt = root.malvinaAllowChatGpt
            soledadSettings.malvinaAllowGemini = root.malvinaAllowGemini
            soledadSettings.malvinaAllowClaude = root.malvinaAllowClaude
            soledadSettings.soledadShape = root.soledadShape
            soledadSettings.malvinaShape = root.malvinaShape
            soledadSettings.malvinaGearButtonShape = root.malvinaGearButtonShape
            soledadSettings.malvinaSearchButtonShape = root.malvinaSearchButtonShape
            soledadSettings.outlineConfig = JSON.parse(JSON.stringify(root.outlineConfig))
            soledadSettings.taskActiveGlowEnabled = root.taskActiveGlowEnabled
            soledadSettings.taskActiveDoubleBorderEnabled = root.taskActiveDoubleBorderEnabled
            soledadSettings.taskDisplayMode = root.taskDisplayMode
            soledadSettings.taskFrameShape = root.taskFrameShape
            soledadSettings.taskFrameColor = root.taskFrameColor
            soledadSettings.taskFrameOpacity = root.taskFrameOpacity
            soledadSettings.taskFrameWidth = root.taskFrameWidth
            soledadSettings.gripShape = root.gripShape
            soledadSettings.trayButtonShape = root.trayButtonShape
            soledadSettings.soButtonFrameShape = root.soButtonFrameShape
            soledadSettings.soButtonWidth = root.soButtonWidth
            soledadSettings.soTextLabel = root.soTextLabel
            soledadSettings.soTextColor = root.soTextColor
            soledadSettings.soTextBackground = root.soTextBackground
            soledadSettings.soTextBackgroundOpacity = root.soTextBackgroundOpacity
            soledadSettings.soTextFontFamily = root.soTextFontFamily
            soledadSettings.soTextFontSize = root.soTextFontSize
            soledadSettings.soTextBold = root.soTextBold
            soledadSettings.soTextBackgroundImage = root.soTextBackgroundImage
            soledadSettings.soledadColor = root.soledadColor
            soledadSettings.malvinaColor = root.malvinaColor
            soledadSettings.soledadGradientEnabled = root.soledadGradientEnabled
            soledadSettings.soledadGradientEnd = root.soledadGradientEnd
            soledadSettings.soledadGradientDirection = root.soledadGradientDirection
            soledadSettings.soledadGradientSyncBreathing = root.soledadGradientSyncBreathing
            soledadSettings.soledadGradientBreathingIntensity = root.soledadGradientBreathingIntensity
            soledadSettings.malvinaGradientSyncBreathing = root.malvinaGradientSyncBreathing
            soledadSettings.malvinaGradientBreathingIntensity = root.malvinaGradientBreathingIntensity
            soledadSettings.malvinaGradientEnabled = root.malvinaGradientEnabled
            soledadSettings.malvinaGradientEnd = root.malvinaGradientEnd
            soledadSettings.malvinaGradientDirection = root.malvinaGradientDirection
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
            soledadSettings.glowColor = root.soActivityGlowColor
            soledadSettings.glowIntensity = root.soActivityGlowIntensity
            soledadSettings.glowSpread = root.soActivityGlowSpread
            soledadSettings.pulseSpeed = root.soActivityPulseSpeed
            soledadSettings.pulseDepth = root.soActivityPulseDepth
            soledadSettings.glowGradient = root.soActivityGlowGradient
            soledadSettings.showOutlineWhenEmpty = root.soActivityShowWhenEmpty
            soledadSettings.showOutlineWhenOpen = root.soActivityShowWhenOpen
            soledadSettings.autoCollapseSO = root.autoCollapseSO
            soledadSettings.soLeftClickOpensLauncher = root.soLeftClickOpensLauncher
            soledadSettings.launcherCategoryLayout = root.launcherCategoryLayout
            soledadSettings.launcherSwitchShape = root.launcherSwitchShape
            soledadSettings.launcherSwitchColorOverride = root.launcherSwitchColorOverride
            soledadSettings.launcherSwitchColor = root.launcherSwitchColor
            soledadSettings.launcherMaxSlots = root.launcherMaxSlots
            soledadSettings.launcherOpacityOverride = root.launcherOpacityOverride
            soledadSettings.launcherOpacity = root.launcherOpacity
            soledadSettings.launcherIconsWithNames = root.launcherIconsWithNames
            soledadSettings.malvinaOptionsOpacityOverride = root.malvinaOptionsOpacityOverride
            soledadSettings.malvinaOptionsOpacity = root.malvinaOptionsOpacity
            soledadSettings.autoCollapseTray = root.autoCollapseTray
            soledadSettings.autoReturnRight = root.autoReturnRight
            soledadSettings.launcherIslandVisible = root.launcherIslandVisible
            soledadSettings.autoHideMalvina = root.autoHideMalvina
            soledadSettings.alignedRight = root.alignRightSelected
            soledadSettings.positionMode = root.positionMode
            soledadSettings.alignmentEdited = false
            soledadSettings.currentTab = tabIndex
            soledadSettings.refreshOutlinePreview()
        }
        if (islandSubtabIndex !== undefined)
            soledadSettings.currentIslandSubtab = islandSubtabIndex
        soledadSettings.currentTab = tabIndex
        soledadSettings.show()
        soledadSettings.raise()
        soledadSettings.requestActivate()
    }

    SoledadSettings {
        id: soledadSettings
        onSettingsApplied: root.requestPersistCurrentSettings()
        onSaveMalvinaProvidersRequested: function(google, duck, yahoo, chatGpt, gemini, claude) {
            root.requestMalvinaProvidersChange(google, duck, yahoo,
                                               chatGpt, gemini, claude)
        }
        onSaveMalvinaWebEnabledRequested: function(google, duck, yahoo) {
            root.requestMalvinaWebEnabledChange(google, duck, yahoo)
        }
        onSaveMalvinaNamesRequested: function(google, duck, yahoo, chatGpt, gemini, claude) {
            root.requestMalvinaNamesChange(google, duck, yahoo, chatGpt, gemini, claude)
        }
        onSaveMalvinaExtrasRequested: function(webJson, aiJson, hiddenWeb, hiddenAi, compactAi) {
            root.requestMalvinaExtrasChange(webJson, aiJson, hiddenWeb, hiddenAi, compactAi)
        }
        onSaveMalvinaOrderRequested: function(firstWeb, webOrder, aiOrder) {
            root.requestMalvinaOrderChange(firstWeb, webOrder, aiOrder)
        }
        onSaveMalvinaConsentsRequested: function(chatGpt, gemini, claude) {
            root.requestMalvinaConsentsChange(chatGpt, gemini, claude)
        }
        onSaveMalvinaButtonShapesRequested: function(gearShape, searchShape) {
            root.requestMalvinaButtonShapesChange(gearShape, searchShape)
        }
        defaultImage: root.defaultSoLogo
        onSaveClockAppearanceRequested: function(family, size, color) {
            root.requestSoClockAppearanceChange(family, size, color)
        }
        onSaveSoTextRequested: function(label, color, background, opacity, fontFamily, fontSize, bold, image) {
            root.requestSoTextChange(label, color, background, opacity, fontFamily, fontSize, bold, image)
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
        onSaveGradientBreathingRequested: function(enabled, intensity) {
            root.requestGradientBreathingChange(enabled, intensity)
        }
        onSaveMalvinaGradientBreathingRequested: function(enabled, intensity) {
            root.requestMalvinaGradientBreathingChange(enabled, intensity)
        }
        onSaveIslandGradientRequested: function(a, b, c, d, e, f) {
            root.requestIslandGradientChange(a, b, c, d, e, f)
        }
        onSaveTaskActiveIndicatorRequested: function(glowEnabled, doubleBorderEnabled) {
            root.requestTaskActiveIndicatorChange(glowEnabled, doubleBorderEnabled)
        }
        onSaveTaskDisplayModeRequested: function(mode) {
            root.requestTaskDisplayModeChange(mode)
        }
        onSaveTaskFrameRequested: function(shape, color, opacity, width) {
            root.requestTaskFrameChange(shape, color, opacity, width)
        }
        onSaveOutlineRequested: function(updated) {
            root.requestOutlineChange(updated)
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
        onSaveGlowRequested: function(color, intensity, spread, speed, depth, gradient) {
            root.requestSoGlowChange(color, intensity, spread, speed, depth, gradient)
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
        onSaveSoClickMappingRequested: function(leftOpensLauncher) {
            if (leftOpensLauncher !== root.soLeftClickOpensLauncher)
                root.requestSoClickMappingChange(leftOpensLauncher)
        }
        onSaveLauncherStyleRequested: function(layoutMode, switchShape, customColor,
                                               switchColor, maxVisibleSlots) {
            root.requestLauncherStyleChange(layoutMode, switchShape, customColor,
                                            switchColor, maxVisibleSlots)
        }
        onSaveLauncherOpacityRequested: function(customOpacity, opacityValue) {
            root.requestLauncherOpacityChange(customOpacity, opacityValue)
        }
        onSaveLauncherIconDisplayRequested: function(iconsWithNames) {
            root.requestLauncherIconDisplayChange(iconsWithNames)
        }
        onSaveMalvinaOptionsOpacityRequested: function(customOpacity, opacityValue) {
            root.requestMalvinaOptionsOpacityChange(customOpacity, opacityValue)
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
        onSavePositionModeRequested: function(mode) {
            // Aplicar colores no debe mover una isla arrastrada manualmente.
            if (mode !== root.positionMode) {
                if (mode === "center") root.alignCenterNow()
                else root.alignRightNow()
            }
        }
        onAlignCenterNowRequested: root.alignCenterNow()
        onAlignNowRequested: root.alignRightNow()
    }

    // Lanzador aislado debajo de la barra: no modifica grosor ni ventanas externas.
    SoLauncherPopup {
        id: installedAppsPopup
        parent: root
        x: {
            const center = root.installedLauncherSource === "malvina" &&
                root.launcherIslandVisible
                ? launcherIsland.x + launcherIsland.width / 2
                : systemIsland.x + systemIsland.width / 2
            if (categoryLayout === 1 && (showCategoryPanel || (filesMode && expandedCanvas))) {
                // B: conservar el borde derecho del cuadro principal en
                // su sitio; el segundo cuadro ocupa espacio a la izquierda.
                const baseX = Math.max(0, Math.min(
                    Math.max(0, root.width - primaryWidth), center - primaryWidth / 2))
                return Math.max(0, Math.min(Math.max(0, root.width - width),
                    baseX - (width - primaryWidth)))
            }
            // A: mismo cálculo centrado del lanzador original (aprobado).
            return Math.max(0, Math.min(Math.max(0, root.width - width),
                center - width / 2))
        }
        y: root.fixedHeight + 5
        popupHeightLimit: root.launcherAvailableHeight
        categoryLayout: root.launcherCategoryLayout
        maxVisibleSlots: root.launcherMaxSlots
        iconsWithNames: root.launcherIconsWithNames
        switchShape: root.launcherSwitchShape
        switchCustomColor: root.launcherSwitchColorOverride
        switchColor: root.launcherSwitchColor
        islandColor: root.soledadColor
        islandGradientEnd: root.soledadGradientEnd
        islandOpacity: root.launcherOpacityOverride
            ? root.launcherOpacity : root.soledadOpacity
        islandGradientEnabled: root.soledadGradientEnabled
        islandGradientDirection: root.soledadGradientDirection
        islandBreathingFactor: root.gradientBreathingFactor
        outlineColor: root.outlineConfig.soledad.color
        outlineOpacity: root.outlineConfig.soledad.opacity
        outlineWidth: root.outlineConfig.soledad.width
        outlineStyle: root.outlineConfig.soledad.style
        malvinaVisible: root.launcherIslandVisible
        installedApplications: root.localAppCatalog
        catalogIsReal: root.localCatalogReady
        onRequestShowMalvina: {
            root.setLauncherIslandVisible(true)
            installedAppsPopup.close()
        }
        onAppSelected: function(name, realCatalog) {
            // La v0.1 es solo lectura. No cerramos el launcher al
            // seleccionar una app porque aún NO la ejecutamos.
            console.log("SmartBar: aplicación seleccionada:", name,
                        realCatalog ? "(identificada en el equipo, no se ejecuta)"
                                    : "(muestra, no se ejecuta)")
        }
        onClosed: {
            if (root.autoHideMalvina && !malvinaHotspotHover.hovered)
                malvinaHideTimer.restart()
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
            // Geometría visual original intacta. Solo ampliamos el margen
            // sensible del HoverHandler, no el ancho de Malvina.
            width: Math.max(malvinaSearch.implicitWidth +
                            (root.malvinaShape === "leftTip" ? 34 : 10),
                            root.malvinaWidth)
            height: Math.max(32, Math.min(root.fixedHeight - 4, root.malvinaHeight))
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            HoverHandler {
                id: malvinaHotspotHover
                // Margen pasivo: más fácil encontrar la isla escondida,
                // sin hacer más gruesa la barra ni ensanchar Malvina.
                margin: 18
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
            radius: root.malvinaShape === "square" || root.malvinaShape === "leftTip" ? 0 :
                root.malvinaShape === "capsule" ? height / 2 :
                Math.max(0, Math.min(root.malvinaRadius, height / 2))
            topLeftRadius: root.malvinaShape === "leftSquareRightRound" ? 0 : radius
            bottomLeftRadius: root.malvinaShape === "leftSquareRightRound" ? 0 : radius
            topRightRadius: root.malvinaShape === "leftRoundRightSquare" ? 0 : radius
            bottomRightRadius: root.malvinaShape === "leftRoundRightSquare" ? 0 : radius
            color: root.malvinaShape === "leftTip" || root.malvinaGradientEnabled ? "transparent" :
                Qt.rgba(root.malvinaColor.r, root.malvinaColor.g,
                        root.malvinaColor.b, root.malvinaOpacity * root.malvinaGradientBreathingFactor)
            Rectangle {
                anchors.fill: parent
                visible: root.malvinaGradientEnabled && root.malvinaShape !== "leftTip"
                radius: parent.radius
                topLeftRadius: parent.topLeftRadius
                topRightRadius: parent.topRightRadius
                bottomLeftRadius: parent.bottomLeftRadius
                bottomRightRadius: parent.bottomRightRadius
                gradient: Gradient {
                    orientation: (root.malvinaGradientDirection === "leftRight" ||
                                  root.malvinaGradientDirection === "rightLeft")
                        ? Gradient.Horizontal : Gradient.Vertical
                    GradientStop {
                        position: 0
                        color: root.malvinaGradientDirection === "bottomTop" ||
                               root.malvinaGradientDirection === "rightLeft"
                            ? Qt.rgba(root.malvinaGradientEnd.r, root.malvinaGradientEnd.g,
                                      root.malvinaGradientEnd.b, root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                            : Qt.rgba(root.malvinaColor.r, root.malvinaColor.g,
                                      root.malvinaColor.b, root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                    }
                    GradientStop {
                        position: 1
                        color: root.malvinaGradientDirection === "bottomTop" ||
                               root.malvinaGradientDirection === "rightLeft"
                            ? Qt.rgba(root.malvinaColor.r, root.malvinaColor.g,
                                      root.malvinaColor.b, root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                            : Qt.rgba(root.malvinaGradientEnd.r, root.malvinaGradientEnd.g,
                                      root.malvinaGradientEnd.b, root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                    }
                }
            }
            border.width: 0
            // Misma punta izquierda que Soledad. La zona estrecha queda libre
            // de botones para mantener clics y foco dentro de superficies útiles.
            Canvas {
                id: malvinaTipSurface
                anchors.fill: parent
                visible: root.malvinaShape === "leftTip"
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                Connections {
                    target: root
                    function onMalvinaColorChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientEnabledChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientEndChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientDirectionChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaOpacityChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaShapeChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientBreathingFactorChanged() { malvinaTipSurface.requestPaint() }
                    function onOutlineConfigChanged() { malvinaTipSurface.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    if (!visible || width < 30 || height < 4) return
                    ctx.beginPath()
                    ctx.moveTo(1, height / 2)
                    ctx.lineTo(24, 1)
                    ctx.lineTo(width - 1, 1)
                    ctx.lineTo(width - 1, height - 1)
                    ctx.lineTo(24, height - 1)
                    ctx.closePath()
                    const alpha = root.malvinaOpacity * root.malvinaGradientBreathingFactor
                    if (root.malvinaGradientEnabled) {
                        const dir = root.malvinaGradientDirection
                        const g = ctx.createLinearGradient(
                            dir === "leftRight" ? 0 : dir === "rightLeft" ? width : 0,
                            dir === "topBottom" ? 0 : dir === "bottomTop" ? height : 0,
                            dir === "leftRight" ? width : dir === "rightLeft" ? 0 : 0,
                            dir === "topBottom" ? height : dir === "bottomTop" ? 0 : 0)
                        const first = dir === "rightLeft" || dir === "bottomTop"
                            ? root.malvinaGradientEnd : root.malvinaColor
                        const last = dir === "rightLeft" || dir === "bottomTop"
                            ? root.malvinaColor : root.malvinaGradientEnd
                        g.addColorStop(0, Qt.rgba(first.r, first.g, first.b, alpha))
                        g.addColorStop(1, Qt.rgba(last.r, last.g, last.b, alpha))
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(root.malvinaColor.r, root.malvinaColor.g,
                                                root.malvinaColor.b, alpha)
                    }
                    ctx.fill()
                    const outline = root.outlineConfig.malvina
                    if (outline && outline.style !== "none" && outline.width > 0) {
                        ctx.lineWidth = outline.width
                        const c = outline.color
                        ctx.strokeStyle = c
                        ctx.globalAlpha = outline.opacity
                        ctx.stroke()
                        ctx.globalAlpha = 1
                    }
                }
            }
            OutlineStyle {
                visible: root.malvinaShape !== "leftTip"
                anchors.fill: parent
                lineStyle: root.outlineConfig.malvina.style
                lineWidth: root.outlineConfig.malvina.width
                lineColor: root.outlineConfig.malvina.color
                lineOpacity: root.outlineConfig.malvina.opacity
                topLeft: launcherIsland.topLeftRadius
                topRight: launcherIsland.topRightRadius
                bottomLeft: launcherIsland.bottomLeftRadius
                bottomRight: launcherIsland.bottomRightRadius
            }
            MalvinaSearch {
                id: malvinaSearch
                gearButtonShape: root.malvinaGearButtonShape
                searchButtonShape: root.malvinaSearchButtonShape
                islandShape: root.malvinaShape
                islandRadius: root.malvinaRadius
                islandColor: root.malvinaColor
                islandOpacity: root.malvinaOpacity * root.malvinaGradientBreathingFactor
                optionsPanelOpacity: root.malvinaOptionsOpacityOverride
                    ? root.malvinaOptionsOpacity : root.malvinaOpacity
                optionsPanelBreathingFactor: root.malvinaGradientBreathingFactor
                islandGradientEnabled: root.malvinaGradientEnabled
                islandGradientEnd: root.malvinaGradientEnd
                islandGradientDirection: root.malvinaGradientDirection
                islandOutlineColor: root.outlineConfig.malvina.color
                islandOutlineOpacity: root.outlineConfig.malvina.opacity
                islandOutlineWidth: root.outlineConfig.malvina.width
                islandOutlineStyle: root.outlineConfig.malvina.style
                anchors.left: parent.left
                anchors.leftMargin: root.malvinaShape === "leftTip" ? 27 : 5
                anchors.verticalCenter: parent.verticalCenter
                // Los 73 px de botones también cuentan en el límite de media ventana.
                maximumSearchWidth: Math.max(180, Math.min(520, root.width / 2 - 82))
                webGoogleEnabled: root.malvinaWebGoogleEnabled
                webDuckEnabled: root.malvinaWebDuckEnabled
                webYahooEnabled: root.malvinaWebYahooEnabled
                googleName: root.malvinaGoogleName
                duckName: root.malvinaDuckName
                yahooName: root.malvinaYahooName
                chatGptName: root.malvinaChatGptName
                geminiName: root.malvinaGeminiName
                claudeName: root.malvinaClaudeName
                extraWeb: root.malvinaExtraWeb
                extraAi: root.malvinaExtraAi
                hiddenWeb: root.malvinaHiddenWeb
                hiddenAi: root.malvinaHiddenAi
                compactAi: root.malvinaCompactAi
                taskFrameShape: root.taskFrameShape
                taskFrameColor: root.taskFrameColor
                taskFrameOpacity: root.taskFrameOpacity
                taskFrameWidth: root.taskFrameWidth
                webFirst: root.malvinaWebFirst
                webOrder: root.malvinaWebOrder
                aiOrder: root.malvinaAiOrder
                onRequestOrderChange: function(firstWeb, webOrder, aiOrder) {
                    root.requestMalvinaOrderChange(firstWeb, webOrder, aiOrder)
                }
                googleTemplate: root.malvinaGoogleUrl
                duckTemplate: root.malvinaDuckUrl
                yahooTemplate: root.malvinaYahooUrl
                allowChatGptPrefill: root.malvinaAllowChatGpt
                allowGeminiPrefill: root.malvinaAllowGemini
                allowClaudePrefill: root.malvinaAllowClaude
                chatGptUrl: root.malvinaChatGptUrl
                geminiUrl: root.malvinaGeminiUrl
                claudeUrl: root.malvinaClaudeUrl
                onRequestSettings: root.openMalvinaSettings()
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: launcherContextMenu.popup()
                }
                QQC2.Menu {
                    id: launcherContextMenu
                    QQC2.MenuItem {
                        text: "Configuración de Malvina…"
                        onTriggered: root.openMalvinaSettings()
                    }
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
            // Centro: ancho natural de los botones (sin mínimo histórico
            // que podía dejar 593 px incluso con SO y bandeja cerrados).
            // Derecha: conserva exactamente el ancho mínimo configurado.
            width: Math.min(root.physicalIslandLimit,
                root.centeredPresentation ? root.naturalIslandWidth
                : Math.max(root.naturalIslandWidth, root.soledadMinWidth))
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
            // El relleno se pinta con huecos bajo bandeja/agarre: de lo
            // contrario, un botón al 0% deja ver el fondo de Soledad y
            // parece que la transparencia no se aplicó.
            color: "transparent"
            border.width: 0
            Canvas {
                id: islandSurface
                anchors.fill: parent
                visible: root.soledadShape !== "leftTip"
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: requestPaint()
                Connections {
                    target: root
                    function onSoledadColorChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientEnabledChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientEndChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientDirectionChanged() { islandSurface.requestPaint() }
                    function onGradientBreathingFactorChanged() {
                        if (root.soledadGradientEnabled) islandSurface.requestPaint()
                    }
                    function onSoledadOpacityChanged() { islandSurface.requestPaint() }
                    function onSoledadShapeChanged() { islandSurface.requestPaint() }
                    function onSoledadRadiusChanged() { islandSurface.requestPaint() }
                    function onTrayExpandedChanged() { islandSurface.requestPaint() }
                    function onSoExpandedChanged() { islandSurface.requestPaint() }
                    function onTrayButtonColorOverrideChanged() { islandSurface.requestPaint() }
                    function onGripButtonColorOverrideChanged() { islandSurface.requestPaint() }
                }
                Connections {
                    target: systemRow
                    function onWidthChanged() { islandSurface.requestPaint() }
                    function onXChanged() { islandSurface.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)
                    if (width <= 0 || height <= 0 || !visible) return
                    const tl = systemIsland.topLeftRadius
                    const tr = systemIsland.topRightRadius
                    const bl = systemIsland.bottomLeftRadius
                    const br = systemIsland.bottomRightRadius
                    ctx.beginPath()
                    ctx.moveTo(tl, 0)
                    ctx.lineTo(width - tr, 0)
                    ctx.quadraticCurveTo(width, 0, width, tr)
                    ctx.lineTo(width, height - br)
                    ctx.quadraticCurveTo(width, height, width - br, height)
                    ctx.lineTo(bl, height)
                    ctx.quadraticCurveTo(0, height, 0, height - bl)
                    ctx.lineTo(0, tl)
                    ctx.quadraticCurveTo(0, 0, tl, 0)
                    ctx.closePath()
                    if (root.soledadGradientEnabled) {
                        const dir = root.soledadGradientDirection
                        const g = ctx.createLinearGradient(
                            dir === "leftRight" ? 0 : dir === "rightLeft" ? width : 0,
                            dir === "topBottom" ? 0 : dir === "bottomTop" ? height : 0,
                            dir === "leftRight" ? width : dir === "rightLeft" ? 0 : 0,
                            dir === "topBottom" ? height : dir === "bottomTop" ? 0 : 0)
                        g.addColorStop(0, Qt.rgba(root.soledadColor.r, root.soledadColor.g,
                                                   root.soledadColor.b, root.soledadOpacity * root.gradientBreathingFactor))
                        g.addColorStop(1, Qt.rgba(root.soledadGradientEnd.r,
                                                   root.soledadGradientEnd.g,
                                                   root.soledadGradientEnd.b,
                                                   root.soledadOpacity * root.gradientBreathingFactor))
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(root.soledadColor.r, root.soledadColor.g,
                                                root.soledadColor.b, root.soledadOpacity)
                    }
                    ctx.fill()
                    // Retirar el relleno SOLO detrás de los controles cuyo
                    // color/opacidad es independiente; no tocar zonas SO.
                    if (!root.soledadGradientEnabled) {
                    ctx.globalCompositeOperation = "destination-out"
                    ctx.fillStyle = "#ffffffff" // vaciar totalmente el fondo, incluso al 0%
                    for (let i = 0; i < systemRow.children.length; ++i) {
                        const child = systemRow.children[i]
                        if (!child || !child.visible) continue
                        const tray = child.useTileColor === true
                        const grip = child === moveGrip
                        if ((tray && !root.trayButtonColorOverride) ||
                            (grip && !root.gripButtonColorOverride) ||
                            (!tray && !grip)) continue
                        const x = systemRow.x + child.x
                        const y = systemRow.y + child.y
                        const w = child.width
                        const h = child.height
                        if (w <= 0 || h <= 0) continue
                        const radius = tray
                            ? (root.trayButtonShape === "square" ? 0 : Math.min(17, h/2))
                            : (root.gripShape === "square" ? 0 : 8)
                        const q = Math.min(radius, w/2, h/2)
                        ctx.beginPath()
                        ctx.moveTo(x+q, y)
                        ctx.lineTo(x+w-q, y)
                        ctx.quadraticCurveTo(x+w,y,x+w,y+q)
                        ctx.lineTo(x+w,y+h-q)
                        ctx.quadraticCurveTo(x+w,y+h,x+w-q,y+h)
                        ctx.lineTo(x+q,y+h)
                        ctx.quadraticCurveTo(x,y+h,x,y+h-q)
                        ctx.lineTo(x,y+q)
                        ctx.quadraticCurveTo(x,y,x+q,y)
                        ctx.closePath()
                        ctx.fill()
                    }
                    ctx.globalCompositeOperation = "source-over"
                    }
                }
            }
            OutlineStyle {
                anchors.fill: parent
                visible: root.soledadShape !== "leftTip" && lineStyle !== "off"
                lineStyle: root.outlineConfig.soledad.style
                lineWidth: root.outlineConfig.soledad.width
                lineColor: root.outlineConfig.soledad.color
                lineOpacity: root.outlineConfig.soledad.opacity
                topLeft: systemIsland.topLeftRadius
                topRight: systemIsland.topRightRadius
                bottomLeft: systemIsland.bottomLeftRadius
                bottomRight: systemIsland.bottomRightRadius
            }
            // Posición horizontal EXCLUSIVA, sin anchors.left/right dinámicos:
            // cambiar un anchor a undefined podía conservar ambas anclas
            // activas y estirar la isla a TODO el ancho de la ventana.
            // Centro = posición del propio botón SO, no del borde de la isla.
            x: root.centeredPresentation
                ? root.soAnchorCenterX - systemRow.x -
                  soButton.x - soButton.width / 2
                : root.width - width - root.islandOffset -
                  root.controlsReservation
            // Controles maximizados permanecen fijos al extremo derecho.
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
                    function onSoledadGradientEnabledChanged() { soTipBackground.requestPaint() }
                    function onSoledadGradientEndChanged() { soTipBackground.requestPaint() }
                    function onSoledadGradientDirectionChanged() { soTipBackground.requestPaint() }
                    function onGradientBreathingFactorChanged() {
                        if (root.soledadGradientEnabled) soTipBackground.requestPaint()
                    }
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
                    if (root.soledadGradientEnabled) {
                        const dir = root.soledadGradientDirection
                        const g = ctx.createLinearGradient(
                            dir === "leftRight" ? 0 : dir === "rightLeft" ? width : 0,
                            dir === "topBottom" ? 0 : dir === "bottomTop" ? height : 0,
                            dir === "leftRight" ? width : dir === "rightLeft" ? 0 : 0,
                            dir === "topBottom" ? height : dir === "bottomTop" ? 0 : 0)
                        g.addColorStop(0, Qt.rgba(root.soledadColor.r, root.soledadColor.g,
                                                  root.soledadColor.b, root.soledadOpacity * root.gradientBreathingFactor))
                        g.addColorStop(1, Qt.rgba(root.soledadGradientEnd.r, root.soledadGradientEnd.g,
                                                  root.soledadGradientEnd.b, root.soledadOpacity * root.gradientBreathingFactor))
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(root.soledadColor.r, root.soledadColor.g,
                                                root.soledadColor.b, root.soledadOpacity)
                    }
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
                    id: trayToggle
                    text: root.trayExpanded ? "▶" : "◀"
                    frameShape: root.trayButtonShape
                    useTileColor: true
                    tileColor: root.effectiveTrayButtonColor
                    tileOpacity: root.effectiveTrayButtonOpacity
                    outlineStyle: root.outlineConfig.tray.style
                    outlineWidth: root.outlineConfig.tray.width
                    outlineColor: root.outlineConfig.tray.color
                    outlineOpacity: root.outlineConfig.tray.opacity
                    onClicked: root.toggleTray()
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Cajón de sistema: abrir/cerrar bandeja"
                }

                Repeater {
                    model: root.trayExpanded ? root.demoTray : []
                    delegate: IslandButton {
                        text: modelData
                        useTileColor: true
                        tileColor: root.effectiveTrayButtonColor
                        tileOpacity: root.effectiveTrayButtonOpacity
                    outlineStyle: root.outlineConfig.tray.style
                    outlineWidth: root.outlineConfig.tray.width
                    outlineColor: root.outlineConfig.tray.color
                    outlineOpacity: root.outlineConfig.tray.opacity
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
                    model: root.positionMode === "right" && root.soExpanded &&
                           !root.usingRealTasks && root.demoHasRunningWindows
                           ? root.demoApps : []
                    delegate: IslandButton {
                        // El propio relleno de la isla aparece debajo:
                        // no añadir otra cápsula azul sobre el degradado.
                        inheritIslandFill: true
                        taskDisplayMode: root.taskDisplayMode
                        taskFrameShape: root.taskFrameShape
                        taskFrameColor: root.taskFrameColor
                        taskFrameOpacity: root.taskFrameOpacity
                        taskFrameWidth: root.taskFrameWidth
                        taskActiveGlowEnabled: root.taskActiveGlowEnabled
                        taskActiveDoubleBorderEnabled: root.taskActiveDoubleBorderEnabled
                        taskActiveBorderColor: root.outlineConfig.soledad.color
                        taskActiveBorderOpacity: root.outlineConfig.soledad.opacity
                        taskActiveBorderWidth: root.outlineConfig.soledad.width
                        activityEffect: root.soActivityStyle
                        activityColor: root.soActivityColor
                        activityStroke: root.soActivityStroke
                        activityMotionAllowed: root.soActivityMotion
                        activityOrbitSpeed: root.soActivityOrbitSpeed
                        activityTrailPercent: root.soActivityTrailPercent
                        activityTrailStyle: root.soActivityTrailStyle
                        activityGlowColor: root.soActivityGlowColor
                        activityGlowIntensity: root.soActivityGlowIntensity
                        activityGlowSpread: root.soActivityGlowSpread
                        activityPulseSpeed: root.soActivityPulseSpeed
                        activityPulseDepth: root.soActivityPulseDepth
                        activityGlowGradient: root.soActivityGlowGradient
                        frameShape: "task"
                        taskIconSource: root.demoIconForApp(modelData)
                        taskIsActive: root.demoHasRunningWindows &&
                            root.lastDemoSelection.length > 0 &&
                            modelData === root.lastDemoSelection
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
                    model: root.positionMode === "right" && root.soExpanded &&
                           root.usingRealTasks ? root.realTaskModel : null
                    delegate: IslandButton {
                        inheritIslandFill: true
                        taskDisplayMode: root.taskDisplayMode
                        taskFrameShape: root.taskFrameShape
                        taskFrameColor: root.taskFrameColor
                        taskFrameOpacity: root.taskFrameOpacity
                        taskFrameWidth: root.taskFrameWidth
                        taskActiveGlowEnabled: root.taskActiveGlowEnabled
                        taskActiveDoubleBorderEnabled: root.taskActiveDoubleBorderEnabled
                        taskActiveBorderColor: root.outlineConfig.soledad.color
                        taskActiveBorderOpacity: root.outlineConfig.soledad.opacity
                        taskActiveBorderWidth: root.outlineConfig.soledad.width
                        activityEffect: root.soActivityStyle
                        activityColor: root.soActivityColor
                        activityStroke: root.soActivityStroke
                        activityMotionAllowed: root.soActivityMotion
                        activityOrbitSpeed: root.soActivityOrbitSpeed
                        activityTrailPercent: root.soActivityTrailPercent
                        activityTrailStyle: root.soActivityTrailStyle
                        activityGlowColor: root.soActivityGlowColor
                        activityGlowIntensity: root.soActivityGlowIntensity
                        activityGlowSpread: root.soActivityGlowSpread
                        activityPulseSpeed: root.soActivityPulseSpeed
                        activityPulseDepth: root.soActivityPulseDepth
                        activityGlowGradient: root.soActivityGlowGradient
                        frameShape: "task"
                        required property var model
                        taskIsActive: model.IsActive === true &&
                            model.IsMinimized !== true
                        taskIconSource: model.decoration || root.demoIconForApp(appName)
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
                    text: root.soLogoMode === "text" ? root.soTextLabel : "SO"
                    customTextMode: root.soLogoMode === "text"
                    customTextColor: root.soTextColor
                    customTextBackground: root.soTextBackground
                    customTextBackgroundOpacity: root.soTextBackgroundOpacity
                    customTextFontFamily: root.soTextFontFamily
                    customTextFontSize: root.soTextFontSize
                    customTextBold: root.soTextBold
                    customTextBackgroundImage: root.soTextBackgroundImage
                    accent: true
                    activityCount: root.soWindowCount
                    activityEffect: root.soActivityStyle
                    activityColor: root.soActivityColor
                    activityStroke: root.soActivityStroke
                    activityMotionAllowed: root.soActivityMotion
                    activityOrbitSpeed: root.soActivityOrbitSpeed
                    activityTrailPercent: root.soActivityTrailPercent
                    activityTrailStyle: root.soActivityTrailStyle
                    activityGlowColor: root.soActivityGlowColor
                    activityGlowIntensity: root.soActivityGlowIntensity
                    activityGlowSpread: root.soActivityGlowSpread
                    activityPulseSpeed: root.soActivityPulseSpeed
                    activityPulseDepth: root.soActivityPulseDepth
                    activityUseExternalPulse: root.sharedBreathingActive
                    activityExternalPulsePhase: root.sharedBreathingPhase
                    activityGlowGradient: root.soActivityGlowGradient
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

                    // Clic corto: por defecto lanzador de apps; la opción
                    // inversa muestra ventanas abiertas. Mantener ~400 ms
                    // conserva el lanzador sin disparar el clic al soltar.
                    onPressed: {
                        root.soTooltipSuppressed = true
                        root.soHoldTriggered = false
                        soHoldTimer.restart()
                    }
                    onHoveredChanged: {
                        if (!hovered) root.soTooltipSuppressed = false
                    }
                    onReleased: soHoldTimer.stop()
                    onCanceled: soHoldTimer.stop()
                    onClicked: {
                        soHoldTimer.stop()
                        if (!root.soHoldTriggered) {
                            root.triggerSOButton(true)
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

                    // Derecho sobre SO usa la acción configurada, por
                    // defecto ventanas abiertas. Las preferencias siguen
                    // exclusivamente en los seis puntos de Soledad.
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Menu ||
                            (event.key === Qt.Key_F10 &&
                             (event.modifiers & Qt.ShiftModifier))) {
                            root.triggerSOButton(false)
                            event.accepted = true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressed: root.soTooltipSuppressed = true
                        onClicked: root.triggerSOButton(false)
                    }

                    QQC2.ToolTip.visible: hovered && !root.soTooltipSuppressed &&
                        !installedAppsPopup.visible && !root.soExpanded
                    QQC2.ToolTip.delay: 900
                    QQC2.ToolTip.text: root.soLeftClickOpensLauncher
                        ? "Clic izquierdo: Launcher de aplicaciones\nClic derecho: Cajón de aplicaciones"
                        : "Clic izquierdo: Cajón de aplicaciones\nClic derecho: Launcher de aplicaciones"
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
                        if (hovered && !root.soClockVisible) {
                            soClockRevealTimer.restart()
                        } else if (!hovered) {
                            // Si todavía no comenzó, cancelar el hover.
                            // Si ya está mostrando hora/fecha, dejar que
                            // finalice independientemente del puntero.
                            soClockRevealTimer.stop()
                        }
                        if (!hovered) suppressGripTooltip = false
                    }
                    onPressed: {
                        // Si había un hover esperando su breve demora,
                        // iniciar la secuencia ANTES de que abrir un popup
                        // o mover la isla haga desaparecer el hover.
                        if (soClockRevealTimer.running) {
                            soClockRevealTimer.stop()
                            root.showSoClock()
                        }
                        // Presionar, abrir opciones o arrastrar no detiene
                        // el reloj ni resetea su fase de fecha.
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
                        radius: root.gripShape === "square" ? 0 : 8
                        color: Qt.rgba(root.effectiveGripButtonColor.r,
                                       root.effectiveGripButtonColor.g,
                                       root.effectiveGripButtonColor.b,
                                       root.effectiveGripButtonOpacity)
                        border.width: 0
                        OutlineStyle {
                            anchors.fill: parent
                            lineStyle: root.outlineConfig.grip.style
                            lineWidth: root.outlineConfig.grip.width
                            lineColor: root.outlineConfig.grip.color
                            lineOpacity: root.outlineConfig.grip.opacity
                            topLeft: parent.radius
                            topRight: parent.radius
                            bottomLeft: parent.radius
                            bottomRight: parent.radius
                        }
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
                        : "Malvina desactivada · Derecho: opciones → Activar Malvina"

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
                            if (!active) return
                            // Centro visible de SO, antes de cerrar los cajones.
                            const visualSoX = soButton.mapToItem(root, soButton.width / 2, 0).x
                            if (gripMenu.visible) gripMenu.close()
                            if (root.centeredPresentation) {
                                root.manualSoCenterX = visualSoX
                                root.centeredPositionDragged = true
                                root.dragStartSoCenterX = visualSoX
                            } else {
                                root.offsetAtDragStart = root.islandOffset
                            }
                            root.soExpanded = false
                            root.trayExpanded = false
                            moveGrip.draggedDuringPress = true
                            moveGrip.suppressGripTooltip = true
                        }
                        onActiveTranslationChanged: {
                            if (active && Math.abs(activeTranslation.x) > 1) {
                                // El gesto del usuario destilda de inmediato
                                // «Alinear a la derecha» sin tocar el retorno
                                // automático al desmaximizar.
                                root.alignRightSelected = false
                                if (root.centeredPresentation) {
                                    // Mover la referencia del botón SO, sin
                                    // cambiar el anclaje ni el orden de iconos.
                                    const anchorLeft = (6 +
                                        (root.soledadShape === "leftTip" ? 12 : 0)) +
                                        soButton.x + soButton.width / 2
                                    // Reservar los extremos REALES de la isla,
                                    // incluida la bandeja a la izquierda y
                                    // las fichas/agarre a la derecha.
                                    const minX = root.leftReserved + anchorLeft
                                    const maxX = root.width - root.rightReserved -
                                        (systemIsland.width - anchorLeft)
                                    if (maxX >= minX) {
                                        root.manualSoCenterX = Math.max(minX,
                                            Math.min(maxX, root.dragStartSoCenterX +
                                                activeTranslation.x))
                                    }
                                } else {
                                    root.setIslandOffset(
                                        root.offsetAtDragStart - activeTranslation.x)
                                }
                            }
                        }
                    }

                    QQC2.Menu {
                        id: gripMenu
                        title: "Opciones de Soledad"
                        // No apagar el reloj al abrir el menú contextual.
                        // Un clic derecho rápido puede abrirlo antes de que
                        // venza el retraso inicial de 180 ms.
                        onOpened: {
                            if (soClockRevealTimer.running) {
                                soClockRevealTimer.stop()
                                root.showSoClock()
                            }
                        }
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
                                ? "Desactivar Malvina (isla 2)"
                                : "Activar Malvina (isla 2)"
                            onTriggered: root.setLauncherIslandVisible(
                                !root.launcherIslandVisible, true
                            )
                        }
                        QQC2.MenuItem {
                            text: "Mantener Malvina siempre visible"
                            checkable: true
                            checked: !root.autoHideMalvina
                            enabled: root.launcherIslandVisible
                            onTriggered: root.requestAutoHideMalvinaChange(
                                !root.autoHideMalvina
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
                        QQC2.MenuItem {
                            visible: !root.usingRealTasks && root.demoHasRunningWindows
                            text: "Simular escritorio vacío (fichas sin resaltar)"
                            onTriggered: root.lastDemoSelection = ""
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
                        // Atajo contextual del agarre: respeta la preferencia
                        // elegida en Islas y posición, sin cambiar de modo.
                        QQC2.MenuItem {
                            text: root.positionMode === "center"
                                ? "Centrar isla 1 ahora"
                                : "Alinear isla 1 a la derecha ahora"
                            onTriggered: root.returnToConfiguredPosition()
                        }
                        QQC2.MenuItem {
                            visible: root.positionMode === "right"
                            text: "Volver a la derecha al desmaximizar"
                            checkable: true
                            checked: root.autoReturnRight
                            onTriggered: root.setAutoReturnRight(
                                !root.autoReturnRight)
                        }

                    }
                }

                // Modo histórico de maqueta: NO se altera la prueba de
                // fichas ficticias ni su autocontracción configurada.
                Repeater {
                    model: root.positionMode === "center" && root.soExpanded &&
                           !root.usingRealTasks && root.demoHasRunningWindows
                           ? root.demoApps : []
                    delegate: IslandButton {
                        // El propio relleno de la isla aparece debajo:
                        // no añadir otra cápsula azul sobre el degradado.
                        inheritIslandFill: true
                        taskDisplayMode: root.taskDisplayMode
                        taskFrameShape: root.taskFrameShape
                        taskFrameColor: root.taskFrameColor
                        taskFrameOpacity: root.taskFrameOpacity
                        taskFrameWidth: root.taskFrameWidth
                        taskActiveGlowEnabled: root.taskActiveGlowEnabled
                        taskActiveDoubleBorderEnabled: root.taskActiveDoubleBorderEnabled
                        taskActiveBorderColor: root.outlineConfig.soledad.color
                        taskActiveBorderOpacity: root.outlineConfig.soledad.opacity
                        taskActiveBorderWidth: root.outlineConfig.soledad.width
                        activityEffect: root.soActivityStyle
                        activityColor: root.soActivityColor
                        activityStroke: root.soActivityStroke
                        activityMotionAllowed: root.soActivityMotion
                        activityOrbitSpeed: root.soActivityOrbitSpeed
                        activityTrailPercent: root.soActivityTrailPercent
                        activityTrailStyle: root.soActivityTrailStyle
                        activityGlowColor: root.soActivityGlowColor
                        activityGlowIntensity: root.soActivityGlowIntensity
                        activityGlowSpread: root.soActivityGlowSpread
                        activityPulseSpeed: root.soActivityPulseSpeed
                        activityPulseDepth: root.soActivityPulseDepth
                        activityGlowGradient: root.soActivityGlowGradient
                        frameShape: "task"
                        taskIconSource: root.demoIconForApp(modelData)
                        taskIsActive: root.demoHasRunningWindows &&
                            root.lastDemoSelection.length > 0 &&
                            modelData === root.lastDemoSelection
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
                    model: root.positionMode === "center" && root.soExpanded &&
                           root.usingRealTasks ? root.realTaskModel : null
                    delegate: IslandButton {
                        inheritIslandFill: true
                        taskDisplayMode: root.taskDisplayMode
                        taskFrameShape: root.taskFrameShape
                        taskFrameColor: root.taskFrameColor
                        taskFrameOpacity: root.taskFrameOpacity
                        taskFrameWidth: root.taskFrameWidth
                        taskActiveGlowEnabled: root.taskActiveGlowEnabled
                        taskActiveDoubleBorderEnabled: root.taskActiveDoubleBorderEnabled
                        taskActiveBorderColor: root.outlineConfig.soledad.color
                        taskActiveBorderOpacity: root.outlineConfig.soledad.opacity
                        taskActiveBorderWidth: root.outlineConfig.soledad.width
                        activityEffect: root.soActivityStyle
                        activityColor: root.soActivityColor
                        activityStroke: root.soActivityStroke
                        activityMotionAllowed: root.soActivityMotion
                        activityOrbitSpeed: root.soActivityOrbitSpeed
                        activityTrailPercent: root.soActivityTrailPercent
                        activityTrailStyle: root.soActivityTrailStyle
                        activityGlowColor: root.soActivityGlowColor
                        activityGlowIntensity: root.soActivityGlowIntensity
                        activityGlowSpread: root.soActivityGlowSpread
                        activityPulseSpeed: root.soActivityPulseSpeed
                        activityPulseDepth: root.soActivityPulseDepth
                        activityGlowGradient: root.soActivityGlowGradient
                        frameShape: "task"
                        required property var model
                        taskIsActive: model.IsActive === true &&
                            model.IsMinimized !== true
                        taskIconSource: model.decoration || root.demoIconForApp(appName)
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
