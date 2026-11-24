// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Ensayo AISLADO de Malvina siempre sobre ventanas comunes/maximizadas.
// La superficie nativa mide SOLO lo que ocupa Malvina. No instala un panel.
// Una detección KDE desconocida impide mostrar la ventana por seguridad.
// Esta prueba fuerza Malvina visible SOLO en memoria; no guarda preferencias.
import QtQuick
import QtQuick.Window
import QtCore as QtCore
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import "package/contents/ui" as SmartBar

Window {
    id: probe
    objectName: "smartbarMalvinaTopProbe"
    property bool malvinaMaskProbe: true
    property bool bridgePrepared: false
    property bool fullscreenDetected: false
    property int stateSamples: 0
    // Preferencia EXCLUSIVA del ensayo conjunto: prioridad Web/IA persistente.
    // El visor Qt y KConfig tienen su almacenamiento propio y NO se tocan.
    // En el ensayo aislado (sin SMARTBAR_CONTINUOUS) el orden sigue en memoria.
    QtCore.Settings {
        id: malvinaOrderSettings
        category: "plasma-smartbar-v01-malvina-layer-probe-order"
    }
    function validOrder(raw, required) {
        if (typeof raw !== "string") return false
        const entries = raw.split(",")
        if (entries.length !== required.length) return false
        for (let i = 0; i < required.length; ++i)
            if (entries.indexOf(required[i]) < 0) return false
        return new Set(entries).size === required.length
    }
    property bool testWebFirst: smartbarContinuousMode
        ? String(malvinaOrderSettings.value("webFirstV1", true)).toLowerCase() === "true"
        : true
    property string testWebOrder: {
        const value = smartbarContinuousMode
            ? String(malvinaOrderSettings.value("webOrderV1", "duck,yahoo,google"))
            : "duck,yahoo,google"
        return validOrder(value, ["duck","yahoo","google"]) ? value : "duck,yahoo,google"
    }
    property string testAiOrder: {
        const value = smartbarContinuousMode
            ? String(malvinaOrderSettings.value("aiOrderV1", "chatgpt,claude,gemini"))
            : "chatgpt,claude,gemini"
        return validOrder(value, ["chatgpt","claude","gemini"]) ? value : "chatgpt,claude,gemini"
    }
    // Visibilidad y habilitación Web: preferencias independientes del orden.
    // Nunca reutilizar el estado de consentimientos IA ni el navegador KDE.
    QtCore.Settings {
        id: malvinaWebSettings
        category: "plasma-smartbar-v01-malvina-layer-probe-web"
    }
    function storedWebEnabled(key) {
        return smartbarContinuousMode
            ? String(malvinaWebSettings.value(key, true)).toLowerCase() === "true"
            : true
    }
    function sanitizeHidden(raw, allowed) {
        const ids = String(raw || "").split(",").filter(x => allowed.indexOf(x) >= 0)
        return allowed.filter(x => ids.indexOf(x) >= 0).join(",")
    }
    property bool testGoogleEnabled: storedWebEnabled("googleEnabledV1")
    property bool testDuckEnabled: storedWebEnabled("duckEnabledV1")
    property bool testYahooEnabled: storedWebEnabled("yahooEnabledV1")
    property string testHiddenWeb: smartbarContinuousMode
        ? sanitizeHidden(malvinaWebSettings.value("hiddenWebV1", ""), ["google","duck","yahoo"])
        : ""
    property string testHiddenAi: smartbarContinuousMode
        ? sanitizeHidden(malvinaWebSettings.value("hiddenAiV1", ""), ["chatgpt","claude","gemini"])
        : ""
    // Solo estos tres permisos se conservan entre ejecuciones después de
    // pulsar Aplicar. No compartir categoría con el visor, panel ni temas.
    // La primera ejecución sigue desactivada; revocar + Aplicar guarda false.
    QtCore.Settings {
        id: malvinaConsentSettings
        category: "plasma-smartbar-v01-malvina-layer-probe-consents"
    }
    property bool testAllowChatGpt:
        String(malvinaConsentSettings.value("chatGptConsentV1", false)).toLowerCase() === "true"
    property bool testAllowGemini:
        String(malvinaConsentSettings.value("geminiConsentV1", false)).toLowerCase() === "true"
    property bool testAllowClaude:
        String(malvinaConsentSettings.value("claudeConsentV1", false)).toLowerCase() === "true"
    // Navegador de Malvina, independiente del predeterminado KDE.
    QtCore.Settings {
        id: malvinaBrowserSettings
        category: "plasma-smartbar-v01-malvina-layer-probe-browser"
    }
    property string testBrowserId:
        String(malvinaBrowserSettings.value("selectedBrowserV1", "system"))
    visible: false
    title: "SmartBar — Malvina por encima, excepto fullscreen real"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    // La ventana nativa aumenta SOLO cuando Malvina abre el editor o
    // Web/IA. Los píxeles del resto de la ventana siguen sin entrada.
    width: Math.max(1, Math.ceil(bar.actualMalvinaWidth),
                    Math.ceil(bar.malvinaFieldInputX +
                              bar.malvinaFieldInputWidth),
                    Math.ceil(bar.malvinaOptionsInputX +
                              bar.malvinaOptionsInputWidth))
    height: Math.max(1, Math.ceil(bar.actualMalvinaHeight),
                     Math.ceil(bar.malvinaFieldInputY +
                               bar.malvinaFieldInputHeight),
                     Math.ceil(bar.malvinaOptionsInputY +
                               bar.malvinaOptionsInputHeight))
    // Reactivar la máscara al completar el resize Wayland, no antes.
    // Evita que el campo visible quede fuera de la región clicable.
    readonly property string inputGeometrySignature: [
        width, height, bar.actualMalvinaWidth, bar.actualMalvinaHeight,
        bar.malvinaFieldInputX, bar.malvinaFieldInputY,
        bar.malvinaFieldInputWidth, bar.malvinaFieldInputHeight,
        bar.malvinaOptionsInputX, bar.malvinaOptionsInputY,
        bar.malvinaOptionsInputWidth, bar.malvinaOptionsInputHeight
    ].join("|")
    onInputGeometrySignatureChanged: Qt.callLater(probe.refreshInputRegion)
    onWidthChanged: Qt.callLater(probe.refreshInputRegion)
    onHeightChanged: Qt.callLater(probe.refreshInputRegion)

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorLeft
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    // El modo None impedía escribir: Qt podía dibujar el TextArea, pero
    // KWin no le permitía recibir foco. OnDemand permite foco al clicar
    // sin apropiarse permanentemente del teclado del escritorio.
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityOnDemand
    LayerShell.Window.margins: ({left: 0, top: 0, right: 0, bottom: 0})

    function refreshInputRegion() {
        if (bar.actualMalvinaWidth <= 0 || bar.actualMalvinaHeight <= 0)
            return
        // Una región para la isla y otras para los Popups existentes.
        // Nada fuera de ellas captura clics sobre Brave, Steam o pestañas.
        soledadInputMask.setMalvinaInputRegions(
            bar.actualMalvinaWidth, bar.actualMalvinaHeight,
            bar.malvinaFieldInputX, bar.malvinaFieldInputY,
            bar.malvinaFieldInputWidth, bar.malvinaFieldInputHeight,
            bar.malvinaOptionsInputX, bar.malvinaOptionsInputY,
            bar.malvinaOptionsInputWidth, bar.malvinaOptionsInputHeight)
    }

    function snapshotFullscreen() {
        for (let i = 0; i < observedWindows.count; ++i) {
            const item = observedWindows.itemAt(i)
            if (item !== null && item.taskFullScreen && !item.taskMinimized)
                return true
        }
        return false
    }

    function refreshVisibility() {
        if (!bridgePrepared) return
        // Si el modelo KDE todavía no contiene ventanas, no hay garantía
        // de que el fullscreen se haya detectado: permanecer invisible.
        if (kdeWindows.count === 0 || observedWindows.count < kdeWindows.count) {
            if (visible) visible = false
            if (stateSamples === 8)
                console.warn("SmartBar MALVINA: aun sin estado KDE fiable;",
                             "se mantiene oculta, sin riesgo de tapar fullscreen")
            return
        }
        const full = snapshotFullscreen()
        if (fullscreenDetected !== full) {
            fullscreenDetected = full
            console.log("SmartBar MALVINA fullscreen KDE:", full)
        }
        if (full) {
            if (visible) visible = false
        } else {
            refreshInputRegion()
            if (!visible) {
                visible = true
                console.log("SmartBar MALVINA: visible sobre ventanas,",
                            "sin fullscreen KDE; ancho=", width)
            }
        }
    }

    function scheduleCheck() {
        if (!bridgePrepared) return
        stateSamples = 0
        stateCheckTimer.restart()
        Qt.callLater(probe.refreshVisibility)
    }

    function bridgeReady() {
        // Lo llama C++ SOLO después de crear la ventana y fijar su máscara.
        bridgePrepared = true
        stateSamples = 0
        stateCheckTimer.restart()
        console.log("SmartBar MALVINA: esperando tareas KDE antes de mostrar")
    }

    Timer {
        id: stateCheckTimer
        interval: 250
        repeat: true
        running: false
        onTriggered: {
            probe.refreshVisibility()
            probe.stateSamples++
            if (probe.stateSamples >= 12) stop()
        }
    }

    TaskManager.TasksModel {
        id: kdeWindows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: probe.scheduleCheck()
    }

    Repeater {
        id: observedWindows
        model: kdeWindows
        onItemAdded: probe.scheduleCheck()
        onItemRemoved: probe.scheduleCheck()
        delegate: Item {
            required property var model
            width: 0
            height: 0
            visible: false
            readonly property bool taskFullScreen: model.IsFullScreen === true
            readonly property bool taskMinimized: model.IsMinimized === true
            onTaskFullScreenChanged: probe.scheduleCheck()
            onTaskMinimizedChanged: probe.scheduleCheck()
            Component.onCompleted: probe.scheduleCheck()
        }
    }

    // Launcher separado de la ventana de 44 px: KWin recibe una superficie
    // LayerShell acotada con margen físico bajo la isla, no un xdg_popup
    // cuya posición puede terminar en y=0.
    SmartBar.LayerShellLauncherWindow {
        id: launcherHost
        ownerBar: bar
        runtimeActive: smartbarContinuousMode
        topOffset: probe.height + 8
    }

    SmartBar.RuntimeAppearanceBridge {
        id: appearanceBridge
        target: bar
        backend: soledadInputMask
        appearanceActive: smartbarContinuousMode
    }

    SmartBar.SmartBarContent {
        id: bar
        // El contenido es compartido con Soledad: la ventana recorta
        // físicamente todo lo que quede a la derecha de Malvina.
        width: Math.max(760, probe.Screen.width)
        // No usar el ancho dinámico de probe para calcular optionsWidth:
        // dependería del propio Popup y generaría un bucle QML.
        malvinaOptionsViewportWidth: width
        height: 48
        x: 0
        y: 0
        panelHeight: 48
        malvinaHeight: 44
        soledadHeight: 44
        launcherIslandVisible: true
        // La prueba breve mantiene Malvina visible. La sesión conjunta usa
        // el autoocultamiento de fábrica sin modificar KConfig del usuario.
        autoHideMalvina: smartbarContinuousMode
        realAppLaunchEnabled: smartbarContinuousMode
        layerShellLauncherHost: smartbarContinuousMode ? launcherHost : null
        launcherAvailableHeight: Math.max(260,
            Math.min(760, probe.Screen.height - probe.height - 32))
        runtimeAppearanceEnabled: smartbarContinuousMode
        onRequestRuntimeAppearancePatch: function(json) {
            // Qt signals son sincrónicas: confirmar el resultado antes de
            // que Aplicar avance la línea base de Cancelar.
            bar.runtimeLastAppearanceCommitOk = appearanceBridge.commitPatch(json)
        }
        onRequestLaunchDesktopEntry: function(desktopId) {
            if (soledadInputMask.launchDesktopEntry(desktopId))
                console.log("SmartBar Malvina: aplicación KDE iniciada por ID", desktopId)
            else
                console.warn("SmartBar Malvina: no se pudo iniciar ID", desktopId)
        }
        // Aplicar inmediatamente la reordenación existente de Malvina.
        // Antes faltaba este receptor: el gesto emitía una señal sin
        // actualizar la lista en este visor aislado.
        malvinaWebFirst: probe.testWebFirst
        malvinaWebOrder: probe.testWebOrder
        malvinaAiOrder: probe.testAiOrder
        malvinaWebGoogleEnabled: probe.testGoogleEnabled
        malvinaWebDuckEnabled: probe.testDuckEnabled
        malvinaWebYahooEnabled: probe.testYahooEnabled
        malvinaHiddenWeb: probe.testHiddenWeb
        malvinaHiddenAi: probe.testHiddenAi
        onRequestMalvinaWebEnabledChange: function(google, duck, yahoo) {
            probe.testGoogleEnabled = google
            probe.testDuckEnabled = duck
            probe.testYahooEnabled = yahoo
            if (smartbarContinuousMode) {
                malvinaWebSettings.setValue("googleEnabledV1", google)
                malvinaWebSettings.setValue("duckEnabledV1", duck)
                malvinaWebSettings.setValue("yahooEnabledV1", yahoo)
                malvinaWebSettings.sync()
                console.log("SmartBar MALVINA Web habilitación guardada:",
                            "Google=", google, "DuckDuckGo=", duck, "Yahoo=", yahoo)
            }
        }
        onRequestMalvinaExtrasChange: function(webJson, aiJson, hiddenWeb, hiddenAi, compactAi) {
            // En este ensayo únicamente se integran los controles de
            // visibilidad canónicos. No sobrescribir opciones personalizadas
            // ni afirmar que están persistidas.
            const nextWeb = probe.sanitizeHidden(hiddenWeb, ["google","duck","yahoo"])
            const nextAi = probe.sanitizeHidden(hiddenAi, ["chatgpt","claude","gemini"])
            probe.testHiddenWeb = nextWeb
            probe.testHiddenAi = nextAi
            if (smartbarContinuousMode) {
                malvinaWebSettings.setValue("hiddenWebV1", nextWeb)
                malvinaWebSettings.setValue("hiddenAiV1", nextAi)
                malvinaWebSettings.sync()
                console.log("SmartBar MALVINA visibilidad guardada:",
                            "Web ocultos=", nextWeb, "IA ocultos=", nextAi)
            }
        }
        malvinaBrowserId: probe.testBrowserId
        malvinaBrowserChoices: soledadInputMask.availableBrowsers()
        malvinaBrowserBackend: soledadInputMask
        onRequestMalvinaBrowserChange: function(browserId) {
            // Guardar únicamente el ID de un navegador detectado.
            const choices = soledadInputMask.availableBrowsers()
            let permitted = false
            for (let i = 0; i < choices.length; ++i) {
                if (choices[i].id === browserId) {
                    permitted = true
                    break
                }
            }
            if (!permitted) {
                console.warn("SmartBar MALVINA: navegador no instalado")
                return
            }
            probe.testBrowserId = browserId
            malvinaBrowserSettings.setValue("selectedBrowserV1", browserId)
            malvinaBrowserSettings.sync()
            console.log("SmartBar MALVINA navegador guardado:", browserId)
        }
        onRequestMalvinaOrderChange: function(firstWeb, webOrder, aiOrder) {
            if (!probe.validOrder(webOrder, ["duck","yahoo","google"]) ||
                !probe.validOrder(aiOrder, ["chatgpt","claude","gemini"])) {
                console.warn("SmartBar MALVINA: prioridad inválida, no se guardó")
                return
            }
            probe.testWebFirst = firstWeb
            probe.testWebOrder = webOrder
            probe.testAiOrder = aiOrder
            if (smartbarContinuousMode) {
                // El arrastre de fichas es una elección explícita: guardar
                // inmediatamente igual que la selección de navegador.
                malvinaOrderSettings.setValue("webFirstV1", firstWeb)
                malvinaOrderSettings.setValue("webOrderV1", webOrder)
                malvinaOrderSettings.setValue("aiOrderV1", aiOrder)
                malvinaOrderSettings.sync()
                console.log("SmartBar MALVINA orden guardado:",
                            "Web=", webOrder, "IA=", aiOrder,
                            "primeraFilaWeb=", firstWeb)
            } else {
                console.log("SmartBar MALVINA orden temporal:",
                            "Web=", webOrder, "IA=", aiOrder,
                            "(ensayo aislado, sin guardar)")
            }
        }
        // Aplicar y sólo Aplicar confirma estos tres consentimientos.
        // Nunca se escribe el texto buscado, cookies ni datos del navegador.
        malvinaAllowChatGpt: probe.testAllowChatGpt
        malvinaAllowGemini: probe.testAllowGemini
        malvinaAllowClaude: probe.testAllowClaude
        onRequestMalvinaConsentsChange: function(chatGpt, gemini, claude) {
            probe.testAllowChatGpt = chatGpt
            probe.testAllowGemini = gemini
            probe.testAllowClaude = claude
            malvinaConsentSettings.setValue("chatGptConsentV1", chatGpt)
            malvinaConsentSettings.setValue("geminiConsentV1", gemini)
            malvinaConsentSettings.setValue("claudeConsentV1", claude)
            malvinaConsentSettings.sync()
            console.log("SmartBar MALVINA permisos IA guardados:",
                        "ChatGPT=", chatGpt, "Gemini=", gemini,
                        "Claude=", claude)
        }
        positionMode: "right"
        demoWindowControlsEnabled: false
        themeScheduleRuntimeEnabled: false
        showBackground: false
        windowStateKnown: true
        hostMaximized: false
        hostFullscreen: probe.fullscreenDetected
        // Los nuevos popup/ventana pueden redimensionarse después del
        // cambio de binding; la firma geométrica de la Window actualiza
        // la región final cuando Wayland acepta las nuevas dimensiones.
    }

    Timer {
        // Tiempo de ensayo ampliado a 3 min para probar búsqueda y
        // arrastre; sigue cerrándose sin dejar superficies permanentes.
        interval: 180000
        repeat: false
        running: !smartbarContinuousMode
        onTriggered: {
            console.log("SmartBar MALVINA: autocierre del ensayo")
            probe.close()
        }
    }
}
