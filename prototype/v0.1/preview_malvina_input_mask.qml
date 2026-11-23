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
    // Orden temporal del ensayo, independiente del visor y de KConfig.
    // Los gestos de arrastre NO cambian preferencias persistidas.
    property bool testWebFirst: true
    property string testWebOrder: "duck,yahoo,google"
    property string testAiOrder: "chatgpt,claude,gemini"
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
        // Aplicar inmediatamente la reordenación existente de Malvina.
        // Antes faltaba este receptor: el gesto emitía una señal sin
        // actualizar la lista en este visor aislado.
        malvinaWebFirst: probe.testWebFirst
        malvinaWebOrder: probe.testWebOrder
        malvinaAiOrder: probe.testAiOrder
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
            probe.testWebFirst = firstWeb
            probe.testWebOrder = webOrder
            probe.testAiOrder = aiOrder
            console.log("SmartBar MALVINA orden temporal:",
                        "Web=", webOrder, "IA=", aiOrder,
                        "(sin guardar preferencias)")
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
