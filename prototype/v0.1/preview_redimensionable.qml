// Ventana independiente para validar el redimensionado con el MISMO
// SmartBarContent que usa el plasmoide. No instala nada ni toca paneles.
import QtQuick
import QtQuick.Window
import QtCore as QtCore
import QtQuick.Controls as QQC2
import org.kde.taskmanager 0.1 as TaskManager
import "package/contents/ui"

Window {
    id: previewWindow
    width: 1000
    height: 530 // Visor más alto para mostrar completos los dos cuadros del launcher.
    minimumWidth: 760
    minimumHeight: 465
    visible: true
    title: "Plasma SmartBar v0.1 — MENÚS SOLEDAD · MALVINA · COMPARTIDAS / 18-11 (sin panel)"
    color: "#242236"


    // Persistencia local SOLO del visor Qt: no modifica ningún panel KDE.
    // Se guardan los valores elegidos, no una estética inventada en GitHub.
    property bool appearanceRestored: false
    // Temas son ranuras aparte del último aspecto, favorito y default personal:
    // restaurar favoritos NO destruye los temas Día/Noche guardados.
    property string demoThemeDayJson: String(localPreviewSettings.value("themeDayJson", ""))
    property string demoThemeNightJson: String(localPreviewSettings.value("themeNightJson", ""))
    property string demoThemeCustomJson: String(localPreviewSettings.value("themeCustomJson", ""))
    readonly property var appearanceKeys: ["demoAutoReturnRight","demoLauncherIslandVisible","demoAutoHideMalvina","demoAutoCollapseSO","demoSoLeftClickOpensLauncher","demoLauncherCategoryLayout","demoLauncherSwitchShape","demoLauncherSwitchColorOverride","demoLauncherSwitchColor","demoLauncherMaxSlots","demoLauncherOpacityOverride","demoLauncherOpacity","demoLauncherIconsWithNames","demoMalvinaOptionsOpacityOverride","demoMalvinaOptionsOpacity","demoAutoCollapseTray","demoSoLogoMode","demoSoLogoPath","demoSoLogoShape","demoSoLogoFitMode","demoSoLogoZoom","demoSoLogoPanX","demoSoLogoPanY","demoSoLogoRotation","demoSoLogoAnimate","demoSoClockFontFamily","demoSoClockFontSize","demoSoClockTextColor","demoOutlineConfig","demoPanelHeight","demoSoledadHeight","demoMalvinaHeight","demoSoledadRadius","demoMalvinaRadius","demoSoledadMinWidth","demoMalvinaWidth","demoSoledadShape","demoMalvinaShape","demoMalvinaGearButtonShape","demoMalvinaSearchButtonShape","demoGripShape","demoTrayButtonShape","demoSoButtonFrameShape","demoSoButtonWidth","demoSoledadColor","demoMalvinaColor","demoBackgroundColor","demoSoledadOpacity","demoMalvinaOpacity","demoBackgroundOpacity","demoShowBackground","demoTrayButtonColorOverride","demoTrayButtonColor","demoTrayButtonOpacity","demoGripButtonColorOverride","demoGripButtonColor","demoGripButtonOpacity","demoSoActivityStyle","demoSoActivityColor","demoSoActivityStroke","demoSoActivityMotion","demoSoActivityOrbitSpeed","demoSoActivityTrailPercent","demoSoActivityTrailStyle","demoSoActivityShowWhenEmpty","demoSoActivityShowWhenOpen","demoSoActivityGlowColor","demoSoActivityGlowIntensity","demoSoActivityGlowSpread","demoSoActivityPulseSpeed","demoSoActivityGlowGradient","demoSoledadGradientEnabled","demoSoledadGradientEnd","demoSoledadGradientDirection","demoMalvinaGradientEnabled","demoMalvinaGradientEnd","demoMalvinaGradientDirection","demoSoActivityPulseDepth","demoSoledadGradientSyncBreathing","demoSoledadGradientBreathingIntensity","demoMalvinaGradientSyncBreathing","demoMalvinaGradientBreathingIntensity","demoSoTextLabel","demoSoTextColor","demoSoTextBackground","demoSoTextBackgroundOpacity","demoSoTextFontFamily","demoSoTextFontSize","demoSoTextBold","demoPositionMode","demoSoTextBackgroundImage","demoTaskFrameShape","demoTaskFrameColor","demoTaskFrameOpacity","demoTaskFrameWidth","demoTaskDisplayMode","demoTaskActiveGlowEnabled","demoTaskActiveDoubleBorderEnabled","demoMalvinaGoogleUrl","demoMalvinaDuckUrl","demoMalvinaYahooUrl","demoMalvinaChatGptUrl","demoMalvinaGeminiUrl","demoMalvinaClaudeUrl","demoMalvinaWebFirst","demoMalvinaWebOrder","demoMalvinaAiOrder","demoMalvinaExtraWeb","demoMalvinaExtraAi","demoMalvinaHiddenWeb","demoMalvinaHiddenAi","demoMalvinaCompactAi","demoMalvinaGoogleName","demoMalvinaDuckName","demoMalvinaYahooName","demoMalvinaChatGptName","demoMalvinaGeminiName","demoMalvinaClaudeName","demoMalvinaAllowChatGpt","demoMalvinaAllowGemini","demoMalvinaAllowClaude","demoMalvinaWebGoogleEnabled","demoMalvinaWebDuckEnabled","demoMalvinaWebYahooEnabled"]
    QtCore.Settings {
        id: localPreviewSettings
        category: "plasma-smartbar-v01-preview-appearance"
    }
    Timer {
        id: saveAppearanceTimer
        interval: 180
        repeat: false
        onTriggered: previewWindow.saveAppearancePreset()
    }
    function synchronizeIslandPalette() {
        // Malvina utiliza la pareja cromática de Soledad. No tocar
        // dirección, geometría ni sus archivos personales.
        demoMalvinaColor = demoSoledadColor
        demoMalvinaGradientEnd = demoSoledadGradientEnd
        demoMalvinaGradientEnabled = demoSoledadGradientEnabled
        demoMalvinaGradientSyncBreathing = demoSoledadGradientSyncBreathing
    }
    function collectAppearancePreset() {
        synchronizeIslandPalette()
        const values = {}
        for (const key of appearanceKeys) {
            const value = previewWindow[key]
            values[key] = key === "demoOutlineConfig"
                ? JSON.parse(JSON.stringify(value))
                : (key.endsWith("Color") || key.endsWith("Background") || key.endsWith("GradientEnd") ||
                   key === "demoSoClockTextColor" ? String(value) : value)
        }
        return JSON.stringify(values)
    }
    function saveAppearancePreset() {
        if (!appearanceRestored) return
        localPreviewSettings.setValue("appearanceV1", collectAppearancePreset())
        localPreviewSettings.sync()
    }
    function saveFavoriteAppearance() {
        if (!appearanceRestored) return
        saveAppearanceTimer.stop()
        const current = collectAppearancePreset()
        localPreviewSettings.setValue("favoriteSoledadV1", current)
        localPreviewSettings.setValue("appearanceV1", current)
        localPreviewSettings.sync()
        console.log("SmartBar: estética favorita guardada localmente")
    }
    // Instantánea personal elegida por el usuario. No se sube al repositorio,
    // ni se reemplaza por los valores por defecto del código.
    function savePersonalDefault() {
        if (!appearanceRestored) return
        saveAppearanceTimer.stop()
        const current = collectAppearancePreset()
        localPreviewSettings.setValue("personalDefaultV1", current)
        localPreviewSettings.setValue("appearanceV1", current)
        localPreviewSettings.sync()
        console.log("SmartBar: configuración completa fijada como predeterminada personal local")
    }
    function restorePersonalDefault() {
        if (!appearanceRestored) return
        const raw = localPreviewSettings.value("personalDefaultV1", "")
        if (typeof raw !== "string" || !raw.length) {
            console.warn("SmartBar: todavía no hay una predeterminada personal guardada")
            return
        }
        try {
            const values = JSON.parse(raw)
            for (const key of appearanceKeys)
                if (Object.prototype.hasOwnProperty.call(values,key))
                    previewWindow[key] = values[key]
            saveAppearanceTimer.stop()
            saveAppearancePreset()
            console.log("SmartBar: predeterminada personal restaurada")
        } catch(e) {
            console.warn("SmartBar: no se pudo restaurar predeterminada personal:",e)
        }
    }
    function restoreFavoriteAppearance() {
        if (!appearanceRestored) return
        const raw = localPreviewSettings.value("favoriteSoledadV1", "")
        if (typeof raw !== "string" || raw.length === 0) {
            console.warn("SmartBar: todavía no hay estética favorita guardada")
            return
        }
        try {
            const values = JSON.parse(raw)
            for (const key of appearanceKeys) {
                if (Object.prototype.hasOwnProperty.call(values, key))
                    previewWindow[key] = values[key]
            }
            saveAppearancePreset()
            console.log("SmartBar: estética favorita restaurada")
        } catch (e) {
            console.warn("SmartBar: no se pudo recuperar la estética favorita:", e)
        }
    }
    function restoreAppearancePreset() {
        const raw = localPreviewSettings.value("appearanceV1", "")
        if (typeof raw === "string" && raw.length > 0) {
            try {
                const values = JSON.parse(raw)
                for (const key of appearanceKeys) {
                    if (Object.prototype.hasOwnProperty.call(values, key))
                        previewWindow[key] = values[key]
                }
                console.log("SmartBar: apariencia local recuperada")
            } catch (e) {
                console.warn("SmartBar: no se pudo leer apariencia guardada:", e)
            }
        }
        synchronizeIslandPalette()
        appearanceRestored = true
    }
    Component.onCompleted: restoreAppearancePreset()
    // Al cerrar, guardar incluso cambios recientes que todavía no alcanzaron
    // el intervalo del temporizador de autoguardado.
    onClosing: function(close) {
        saveAppearanceTimer.stop()
        saveAppearancePreset()
        console.log("SmartBar: configuración actual sincronizada al cerrar el visor")
    }

    // Solo este visor Qt utiliza la opción real. El plasmoide sigue
    // sin conexión a ventanas y el panel instalado no se modifica.
    property bool useRealWindowTasks: false

    // Misma configuración ya validada por el mantenedor en el
    // diagnóstico preview_ventanas_reales.qml.
    TaskManager.TasksModel {
        id: kdeTasks
        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: {
            if (previewWindow.useRealWindowTasks)
                console.log("SmartBar SO: grupos reales visibles =", count)
        }
    }

    property bool demoTaskActiveGlowEnabled: true
    property bool demoTaskActiveDoubleBorderEnabled: false
    property string demoMalvinaGoogleUrl: "https://www.google.com/search?q={query}"
    property string demoMalvinaDuckUrl: "https://duckduckgo.com/?q={query}"
    property string demoMalvinaYahooUrl: "https://search.yahoo.com/search?p={query}"
    property string demoMalvinaChatGptUrl: "https://chatgpt.com/"
    property string demoMalvinaGeminiUrl: "https://gemini.google.com/app"
    property string demoMalvinaClaudeUrl: "https://claude.ai/new"
    property bool demoMalvinaWebFirst: true
    property string demoMalvinaWebOrder: "google,duck,yahoo"
    property string demoMalvinaAiOrder: "chatgpt,gemini,claude"
    property string demoMalvinaExtraWeb: "[]"
    property string demoMalvinaExtraAi: "[]"
    property string demoMalvinaHiddenWeb: ""
    property string demoMalvinaHiddenAi: ""
    property bool demoMalvinaCompactAi: false
    property string demoMalvinaGoogleName: "Google"
    property string demoMalvinaDuckName: "DuckDuckGo"
    property string demoMalvinaYahooName: "Yahoo"
    property string demoMalvinaChatGptName: "ChatGPT"
    property string demoMalvinaGeminiName: "Gemini"
    property string demoMalvinaClaudeName: "Claude"
    property bool demoMalvinaWebGoogleEnabled: true
    property bool demoMalvinaWebDuckEnabled: true
    property bool demoMalvinaWebYahooEnabled: true
    property bool demoMalvinaAllowChatGpt: false
    property bool demoMalvinaAllowGemini: false
    property bool demoMalvinaAllowClaude: false
    property string demoTaskDisplayMode: "icon"
    property string demoTaskFrameShape: "rounded"
    property color demoTaskFrameColor: "#ffffff"
    property real demoTaskFrameOpacity: 0.12
    property real demoTaskFrameWidth: 1
    property bool demoAutoReturnRight: true
    property string demoPositionMode: "right"
    property bool demoLauncherIslandVisible: true
    property bool demoAutoHideMalvina: true
    property bool demoAutoCollapseSO: true
    property bool demoSoLeftClickOpensLauncher: false
    property int demoLauncherCategoryLayout: 0
    property string demoLauncherSwitchShape: "capsule"
    property bool demoLauncherSwitchColorOverride: false
    property color demoLauncherSwitchColor: "#010111"
    property int demoLauncherMaxSlots: 20
    property bool demoLauncherOpacityOverride: false
    property real demoLauncherOpacity: 1
    property bool demoLauncherIconsWithNames: true
    property bool demoMalvinaOptionsOpacityOverride: false
    property real demoMalvinaOptionsOpacity: 1
    property bool demoAutoCollapseTray: false
    // Estados de sesión de la maqueta (el panel KDE no se instala).
    property string demoSoLogoMode: "default"
    property string demoSoTextLabel: "SO"
    property color demoSoTextColor: "#ffffff"
    property color demoSoTextBackground: "#192536"
    property real demoSoTextBackgroundOpacity: 0.9
    property string demoSoTextFontFamily: "Sans Serif"
    property int demoSoTextFontSize: 13
    property bool demoSoTextBold: true
    property string demoSoTextBackgroundImage: ""
    property string demoSoLogoPath: ""
    property string demoSoLogoShape: "square"
    property string demoSoLogoFitMode: "stretch"
    property real demoSoLogoZoom: 1
    property real demoSoLogoPanX: 0
    property real demoSoLogoPanY: 0
    property real demoSoLogoRotation: 0
    property bool demoSoLogoAnimate: true
    property string demoSoClockFontFamily: "Sans Serif"
    property int demoSoClockFontSize: 11
    property color demoSoClockTextColor: "#ffffff"
    property var demoOutlineConfig: ({"soledad":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"malvina":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"tray":{"style":"solid","width":1,"color":"#45647a","opacity":1},"grip":{"style":"solid","width":1,"color":"#45647a","opacity":1}})
    property real demoPanelHeight: 48
    property real demoSoledadHeight: 44
    property real demoMalvinaHeight: 44
    property real demoSoledadRadius: 22
    property real demoMalvinaRadius: 22
    property real demoSoledadMinWidth: 0
    property real demoMalvinaWidth: 52
    property string demoSoledadShape: "leftRoundRightSquare"
    property string demoMalvinaShape: "rounded"
    property string demoMalvinaGearButtonShape: "square"
    property string demoMalvinaSearchButtonShape: "square"
    property string demoGripShape: "rounded"
    property string demoTrayButtonShape: "rounded"
    property string demoSoButtonFrameShape: "capsule"
    property real demoSoButtonWidth: 96
    property color demoSoledadColor: "#010111"
    property color demoMalvinaColor: "#101e31"
    property bool demoSoledadGradientEnabled: false
    property color demoSoledadGradientEnd: "#ee9852"
    property string demoSoledadGradientDirection: "topBottom"
    property bool demoSoledadGradientSyncBreathing: false
    property real demoSoledadGradientBreathingIntensity: 0.6
    property bool demoMalvinaGradientSyncBreathing: false
    property real demoMalvinaGradientBreathingIntensity: 0.6
    property bool demoMalvinaGradientEnabled: false
    property color demoMalvinaGradientEnd: "#445577"
    property string demoMalvinaGradientDirection: "topBottom"
    property color demoBackgroundColor: "#202333"
    property real demoSoledadOpacity: 0.5
    property real demoMalvinaOpacity: 1
    property real demoBackgroundOpacity: 0.5
    property bool demoShowBackground: false
    property bool demoTrayButtonColorOverride: false
    property color demoTrayButtonColor: "#010111"
    property real demoTrayButtonOpacity: 0.5
    property bool demoGripButtonColorOverride: false
    property color demoGripButtonColor: "#010111"
    property real demoGripButtonOpacity: 0.5
    property string demoSoActivityStyle: "orbit"
    property color demoSoActivityColor: "#35d7ff"
    property real demoSoActivityStroke: 0.75
    property bool demoSoActivityMotion: true
    property real demoSoActivityOrbitSpeed: 1.5
    property int demoSoActivityTrailPercent: 75
    property string demoSoActivityTrailStyle: "dashed"
    property color demoSoActivityGlowColor: "#ffab52"
    property real demoSoActivityGlowIntensity: 0.7
    property real demoSoActivityGlowSpread: 5
    property real demoSoActivityPulseSpeed: 0.6
    property real demoSoActivityPulseDepth: 0.7
    property bool demoSoActivityGlowGradient: true
    property bool demoSoActivityShowWhenEmpty: true
    property bool demoSoActivityShowWhenOpen: false

    SmartBarContent {
        id: bar
        realTaskModel: previewWindow.useRealWindowTasks ? kdeTasks : null
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: fixedHeight
        taskActiveGlowEnabled: previewWindow.demoTaskActiveGlowEnabled
        taskActiveDoubleBorderEnabled: previewWindow.demoTaskActiveDoubleBorderEnabled
        onRequestTaskActiveIndicatorChange: function(glowEnabled, doubleBorderEnabled) {
            previewWindow.demoTaskActiveGlowEnabled = glowEnabled
            previewWindow.demoTaskActiveDoubleBorderEnabled = doubleBorderEnabled
        }
        malvinaGoogleName: previewWindow.demoMalvinaGoogleName
        malvinaDuckName: previewWindow.demoMalvinaDuckName
        malvinaYahooName: previewWindow.demoMalvinaYahooName
        malvinaChatGptName: previewWindow.demoMalvinaChatGptName
        malvinaGeminiName: previewWindow.demoMalvinaGeminiName
        malvinaClaudeName: previewWindow.demoMalvinaClaudeName
        onRequestMalvinaNamesChange: function(google, duck, yahoo, chatGpt, gemini, claude) {
            previewWindow.demoMalvinaGoogleName = google
            previewWindow.demoMalvinaDuckName = duck
            previewWindow.demoMalvinaYahooName = yahoo
            previewWindow.demoMalvinaChatGptName = chatGpt
            previewWindow.demoMalvinaGeminiName = gemini
            previewWindow.demoMalvinaClaudeName = claude
        }
        malvinaExtraWeb: previewWindow.demoMalvinaExtraWeb
        malvinaExtraAi: previewWindow.demoMalvinaExtraAi
        malvinaHiddenWeb: previewWindow.demoMalvinaHiddenWeb
        malvinaHiddenAi: previewWindow.demoMalvinaHiddenAi
        malvinaCompactAi: previewWindow.demoMalvinaCompactAi
        onRequestMalvinaExtrasChange: function(webJson, aiJson, hiddenWeb, hiddenAi, compactAi) {
            previewWindow.demoMalvinaExtraWeb = webJson
            previewWindow.demoMalvinaExtraAi = aiJson
            previewWindow.demoMalvinaHiddenWeb = hiddenWeb
            previewWindow.demoMalvinaHiddenAi = hiddenAi
            previewWindow.demoMalvinaCompactAi = compactAi
        }
        malvinaWebFirst: previewWindow.demoMalvinaWebFirst
        malvinaWebOrder: previewWindow.demoMalvinaWebOrder
        malvinaAiOrder: previewWindow.demoMalvinaAiOrder
        onRequestMalvinaOrderChange: function(firstWeb, webOrder, aiOrder) {
            previewWindow.demoMalvinaWebFirst = firstWeb
            previewWindow.demoMalvinaWebOrder = webOrder
            previewWindow.demoMalvinaAiOrder = aiOrder
        }
        malvinaGoogleUrl: previewWindow.demoMalvinaGoogleUrl
        malvinaDuckUrl: previewWindow.demoMalvinaDuckUrl
        malvinaYahooUrl: previewWindow.demoMalvinaYahooUrl
        malvinaChatGptUrl: previewWindow.demoMalvinaChatGptUrl
        malvinaGeminiUrl: previewWindow.demoMalvinaGeminiUrl
        malvinaClaudeUrl: previewWindow.demoMalvinaClaudeUrl
        malvinaWebGoogleEnabled: previewWindow.demoMalvinaWebGoogleEnabled
        malvinaWebDuckEnabled: previewWindow.demoMalvinaWebDuckEnabled
        malvinaWebYahooEnabled: previewWindow.demoMalvinaWebYahooEnabled
        onRequestMalvinaWebEnabledChange: function(google, duck, yahoo) {
            previewWindow.demoMalvinaWebGoogleEnabled = google
            previewWindow.demoMalvinaWebDuckEnabled = duck
            previewWindow.demoMalvinaWebYahooEnabled = yahoo
        }
        malvinaAllowChatGpt: previewWindow.demoMalvinaAllowChatGpt
        malvinaAllowGemini: previewWindow.demoMalvinaAllowGemini
        malvinaAllowClaude: previewWindow.demoMalvinaAllowClaude
        onRequestMalvinaConsentsChange: function(chatGpt, gemini, claude) {
            previewWindow.demoMalvinaAllowChatGpt = chatGpt
            previewWindow.demoMalvinaAllowGemini = gemini
            previewWindow.demoMalvinaAllowClaude = claude
        }
        onRequestMalvinaProvidersChange: function(google, duck, yahoo, chatGpt, gemini, claude) {
            previewWindow.demoMalvinaGoogleUrl = google
            previewWindow.demoMalvinaDuckUrl = duck
            previewWindow.demoMalvinaYahooUrl = yahoo
            previewWindow.demoMalvinaChatGptUrl = chatGpt
            previewWindow.demoMalvinaGeminiUrl = gemini
            previewWindow.demoMalvinaClaudeUrl = claude
        }
        taskDisplayMode: previewWindow.demoTaskDisplayMode
        onRequestTaskDisplayModeChange: function(mode) {
            previewWindow.demoTaskDisplayMode = mode
        }
        taskFrameShape: previewWindow.demoTaskFrameShape
        taskFrameColor: previewWindow.demoTaskFrameColor
        taskFrameOpacity: previewWindow.demoTaskFrameOpacity
        taskFrameWidth: previewWindow.demoTaskFrameWidth
        onRequestTaskFrameChange: function(shape, color, opacity, width) {
            previewWindow.demoTaskFrameShape = shape
            previewWindow.demoTaskFrameColor = color
            previewWindow.demoTaskFrameOpacity = opacity
            previewWindow.demoTaskFrameWidth = width
        }
        outlineConfig: previewWindow.demoOutlineConfig
        onRequestOutlineChange: function(updated) {
            previewWindow.demoOutlineConfig = JSON.parse(JSON.stringify(updated))
        }
        panelHeight: previewWindow.demoPanelHeight
        soledadHeight: previewWindow.demoSoledadHeight
        malvinaHeight: previewWindow.demoMalvinaHeight
        soledadRadius: previewWindow.demoSoledadRadius
        malvinaRadius: previewWindow.demoMalvinaRadius
        soledadMinWidth: previewWindow.demoSoledadMinWidth
        malvinaWidth: previewWindow.demoMalvinaWidth
        soledadShape: previewWindow.demoSoledadShape
        malvinaShape: previewWindow.demoMalvinaShape
        malvinaGearButtonShape: previewWindow.demoMalvinaGearButtonShape
        malvinaSearchButtonShape: previewWindow.demoMalvinaSearchButtonShape
        // Aplicar solicita guardado inmediato de TODOS los valores, no solo
        // los que tenían on...Changed histórico.
        onRequestPersistCurrentSettings: previewWindow.saveAppearancePreset()
        onRequestMalvinaButtonShapesChange: function(gearShape, searchShape) {
            previewWindow.demoMalvinaGearButtonShape = gearShape
            previewWindow.demoMalvinaSearchButtonShape = searchShape
        }
        gripShape: previewWindow.demoGripShape
        trayButtonShape: previewWindow.demoTrayButtonShape
        soButtonFrameShape: previewWindow.demoSoButtonFrameShape
        soButtonWidth: previewWindow.demoSoButtonWidth

        autoReturnRight: previewWindow.demoAutoReturnRight
        positionMode: previewWindow.demoPositionMode
        onRequestPositionModeChange: function(mode) {
            previewWindow.demoPositionMode = mode
        }
        launcherIslandVisible: previewWindow.demoLauncherIslandVisible
        autoHideMalvina: previewWindow.demoAutoHideMalvina
        // El visor es la propia superficie de ensayo: maximizar ESTA
        // ventana no equivale a tener un juego ajeno maximizado debajo.
        // Para probar protección, usar las opciones explícitas del agarre.
        // En pantalla completa REAL del visor se conserva el bloqueo.
        windowStateKnown: true
        hostMaximized: false
        hostFullscreen: previewWindow.visibility === Window.FullScreen
        autoCollapseSO: previewWindow.demoAutoCollapseSO
        soLeftClickOpensLauncher: previewWindow.demoSoLeftClickOpensLauncher
        themeDayJson: previewWindow.demoThemeDayJson
        themeNightJson: previewWindow.demoThemeNightJson
        themeCustomJson: previewWindow.demoThemeCustomJson
        launcherCategoryLayout: previewWindow.demoLauncherCategoryLayout
        launcherSwitchShape: previewWindow.demoLauncherSwitchShape
        launcherSwitchColorOverride: previewWindow.demoLauncherSwitchColorOverride
        launcherSwitchColor: previewWindow.demoLauncherSwitchColor
        launcherMaxSlots: previewWindow.demoLauncherMaxSlots
        launcherOpacityOverride: previewWindow.demoLauncherOpacityOverride
        launcherOpacity: previewWindow.demoLauncherOpacity
        launcherIconsWithNames: previewWindow.demoLauncherIconsWithNames
        malvinaOptionsOpacityOverride: previewWindow.demoMalvinaOptionsOpacityOverride
        malvinaOptionsOpacity: previewWindow.demoMalvinaOptionsOpacity
        launcherAvailableHeight: Math.max(160, previewWindow.height - bar.fixedHeight - 28)
        autoCollapseTray: previewWindow.demoAutoCollapseTray
        soLogoMode: previewWindow.demoSoLogoMode
        soTextLabel: previewWindow.demoSoTextLabel
        soTextColor: previewWindow.demoSoTextColor
        soTextBackground: previewWindow.demoSoTextBackground
        soTextBackgroundOpacity: previewWindow.demoSoTextBackgroundOpacity
        soTextFontFamily: previewWindow.demoSoTextFontFamily
        soTextFontSize: previewWindow.demoSoTextFontSize
        soTextBold: previewWindow.demoSoTextBold
        soTextBackgroundImage: previewWindow.demoSoTextBackgroundImage
        soLogoPath: previewWindow.demoSoLogoPath
        soLogoShape: previewWindow.demoSoLogoShape
        soLogoFitMode: previewWindow.demoSoLogoFitMode
        soLogoZoom: previewWindow.demoSoLogoZoom
        soLogoPanX: previewWindow.demoSoLogoPanX
        soLogoPanY: previewWindow.demoSoLogoPanY
        soLogoRotation: previewWindow.demoSoLogoRotation
        soLogoAnimate: previewWindow.demoSoLogoAnimate
        soClockFontFamily: previewWindow.demoSoClockFontFamily
        soClockFontSize: previewWindow.demoSoClockFontSize
        soClockTextColor: previewWindow.demoSoClockTextColor
        onRequestSoClockAppearanceChange: function(family, size, color) {
            previewWindow.demoSoClockFontFamily = family
            previewWindow.demoSoClockFontSize = size
            previewWindow.demoSoClockTextColor = color
        }
        soledadColor: previewWindow.demoSoledadColor
        malvinaColor: previewWindow.demoSoledadColor
        soledadGradientEnabled: previewWindow.demoSoledadGradientEnabled
        soledadGradientEnd: previewWindow.demoSoledadGradientEnd
        soledadGradientDirection: previewWindow.demoSoledadGradientDirection
        soledadGradientSyncBreathing: previewWindow.demoSoledadGradientSyncBreathing
        soledadGradientBreathingIntensity: previewWindow.demoSoledadGradientBreathingIntensity
        malvinaGradientSyncBreathing: previewWindow.demoMalvinaGradientSyncBreathing
        malvinaGradientBreathingIntensity: previewWindow.demoMalvinaGradientBreathingIntensity
        malvinaGradientEnabled: previewWindow.demoMalvinaGradientEnabled
        malvinaGradientEnd: previewWindow.demoSoledadGradientEnd
        malvinaGradientDirection: previewWindow.demoMalvinaGradientDirection
        backgroundColor: previewWindow.demoBackgroundColor
        soledadOpacity: previewWindow.demoSoledadOpacity
        malvinaOpacity: previewWindow.demoMalvinaOpacity
        backgroundOpacity: previewWindow.demoBackgroundOpacity
        showBackground: previewWindow.demoShowBackground
        trayButtonColorOverride: previewWindow.demoTrayButtonColorOverride
        trayButtonColor: previewWindow.demoTrayButtonColor
        trayButtonOpacity: previewWindow.demoTrayButtonOpacity
        gripButtonColorOverride: previewWindow.demoGripButtonColorOverride
        gripButtonColor: previewWindow.demoGripButtonColor
        gripButtonOpacity: previewWindow.demoGripButtonOpacity
        soActivityStyle: previewWindow.demoSoActivityStyle
        soActivityColor: previewWindow.demoSoActivityColor
        soActivityStroke: previewWindow.demoSoActivityStroke
        soActivityMotion: previewWindow.demoSoActivityMotion
        soActivityOrbitSpeed: previewWindow.demoSoActivityOrbitSpeed
        soActivityTrailPercent: previewWindow.demoSoActivityTrailPercent
        soActivityTrailStyle: previewWindow.demoSoActivityTrailStyle
        soActivityGlowColor: previewWindow.demoSoActivityGlowColor
        soActivityGlowIntensity: previewWindow.demoSoActivityGlowIntensity
        soActivityGlowSpread: previewWindow.demoSoActivityGlowSpread
        soActivityPulseSpeed: previewWindow.demoSoActivityPulseSpeed
        soActivityPulseDepth: previewWindow.demoSoActivityPulseDepth
        soActivityGlowGradient: previewWindow.demoSoActivityGlowGradient
        soActivityShowWhenEmpty: previewWindow.demoSoActivityShowWhenEmpty
        soActivityShowWhenOpen: previewWindow.demoSoActivityShowWhenOpen
        onRequestAutoHideMalvinaChange: function(newValue) {
            previewWindow.demoAutoHideMalvina = newValue
        }
        onRequestSoGlowChange: function(color, intensity, spread, speed, depth, gradient) {
            previewWindow.demoSoActivityGlowColor = color
            previewWindow.demoSoActivityGlowIntensity = intensity
            previewWindow.demoSoActivityGlowSpread = spread
            previewWindow.demoSoActivityPulseSpeed = speed
            previewWindow.demoSoActivityPulseDepth = depth
            previewWindow.demoSoActivityGlowGradient = gradient
        }
        onRequestSoActivityChange: function(style, color, stroke, allowMotion,
                                             speed, tailLength, lineStyle,
                                             showWhenEmpty, showWhenOpen) {
            previewWindow.demoSoActivityStyle = style
            previewWindow.demoSoActivityColor = color
            previewWindow.demoSoActivityStroke = stroke
            previewWindow.demoSoActivityMotion = allowMotion
            previewWindow.demoSoActivityOrbitSpeed = speed
            previewWindow.demoSoActivityTrailPercent = tailLength
            previewWindow.demoSoActivityTrailStyle = lineStyle
            previewWindow.demoSoActivityShowWhenEmpty = showWhenEmpty
            previewWindow.demoSoActivityShowWhenOpen = showWhenOpen
        }
        onRequestSoTextChange: function(label, textColor, background, opacity, fontFamily, fontSize, bold, image) {
            previewWindow.demoSoTextLabel = label
            previewWindow.demoSoTextColor = textColor
            previewWindow.demoSoTextBackground = background
            previewWindow.demoSoTextBackgroundOpacity = opacity
            previewWindow.demoSoTextFontFamily = fontFamily
            previewWindow.demoSoTextFontSize = fontSize
            previewWindow.demoSoTextBold = bold
            previewWindow.demoSoTextBackgroundImage = image
        }
        onRequestSoLogoChange: function(mode, path, shape, fitMode, zoom, panX, panY, allowGif, rotation) {
            previewWindow.demoSoLogoMode = mode
            previewWindow.demoSoLogoPath = path
            previewWindow.demoSoLogoShape = shape
            previewWindow.demoSoLogoFitMode = fitMode
            previewWindow.demoSoLogoZoom = zoom
            previewWindow.demoSoLogoPanX = panX
            previewWindow.demoSoLogoPanY = panY
            previewWindow.demoSoLogoAnimate = allowGif
            previewWindow.demoSoLogoRotation = rotation
        }
        onRequestGeometryChange: function(panel, soH, malH, soRadius, malRadius,
                                          soWidth, malWidth, buttonShape, buttonWidth,
                                          soShape, malShape, gripButtonShape, trayShape) {
            previewWindow.demoPanelHeight = panel
            previewWindow.demoSoledadHeight = soH
            previewWindow.demoMalvinaHeight = malH
            previewWindow.demoSoledadRadius = soRadius
            previewWindow.demoMalvinaRadius = malRadius
            previewWindow.demoSoledadMinWidth = soWidth
            previewWindow.demoMalvinaWidth = malWidth
            previewWindow.demoSoButtonFrameShape = buttonShape
            previewWindow.demoSoButtonWidth = buttonWidth
            previewWindow.demoSoledadShape = soShape
            previewWindow.demoMalvinaShape = malShape
            previewWindow.demoGripShape = gripButtonShape
            previewWindow.demoTrayButtonShape = trayShape
        }
        onRequestGradientBreathingChange: function(enabled, intensity) {
            previewWindow.demoSoledadGradientSyncBreathing = enabled
            previewWindow.demoSoledadGradientBreathingIntensity = intensity
        }
        onRequestMalvinaGradientBreathingChange: function(enabled, intensity) {
            previewWindow.demoMalvinaGradientSyncBreathing = enabled
            previewWindow.demoMalvinaGradientBreathingIntensity = intensity
        }
        onRequestIslandGradientChange: function(a, b, c, d, e, f) {
            previewWindow.demoSoledadGradientEnabled = a
            previewWindow.demoSoledadGradientEnd = b
            previewWindow.demoSoledadGradientDirection = c
            previewWindow.demoMalvinaGradientEnabled = d
            previewWindow.demoMalvinaGradientEnd = b
            previewWindow.demoMalvinaGradientDirection = f
        }
        onRequestAppearanceChange: function(a, alphaA, b, alphaB, shown, bg,
                                            alphaBg, trayOverride, trayColor,
                                            trayOpacity, gripOverride,
                                            gripColor, gripOpacity) {
            previewWindow.demoSoledadColor = a
            previewWindow.demoSoledadOpacity = alphaA
            previewWindow.demoMalvinaColor = a
            previewWindow.demoMalvinaOpacity = alphaB
            previewWindow.demoShowBackground = shown
            previewWindow.demoBackgroundColor = bg
            previewWindow.demoBackgroundOpacity = alphaBg
            previewWindow.demoTrayButtonColorOverride = trayOverride
            previewWindow.demoTrayButtonColor = trayColor
            previewWindow.demoTrayButtonOpacity = trayOpacity
            previewWindow.demoGripButtonColorOverride = gripOverride
            previewWindow.demoGripButtonColor = gripColor
            previewWindow.demoGripButtonOpacity = gripOpacity
        }
        onRequestAutoReturnRightChange: function(newValue) {
            previewWindow.demoAutoReturnRight = newValue
        }
        onRequestLauncherIslandVisibilityChange: function(newValue) {
            previewWindow.demoLauncherIslandVisible = newValue
        }
        onRequestAutoCollapseSOChange: function(newValue) {
            previewWindow.demoAutoCollapseSO = newValue
        }
        onRequestSoClickMappingChange: function(leftOpensLauncher) {
            previewWindow.demoSoLeftClickOpensLauncher = leftOpensLauncher
        }
        onRequestThemeSlotChange: function(slot, data) {
            // Guardado inmediato sin tocar appearanceV1 ni favoriteSoledadV1.
            if (slot === "day") previewWindow.demoThemeDayJson = data
            else if (slot === "night") previewWindow.demoThemeNightJson = data
            else if (slot === "custom") previewWindow.demoThemeCustomJson = data
            else return
            localPreviewSettings.setValue("theme" +
                (slot === "day" ? "Day" : slot === "night" ? "Night" : "Custom") +
                "Json", data)
            localPreviewSettings.sync()
        }
        onRequestLauncherStyleChange: function(layoutMode, shape, ownColor, color, slots) {
            previewWindow.demoLauncherCategoryLayout = layoutMode
            previewWindow.demoLauncherSwitchShape = shape
            previewWindow.demoLauncherSwitchColorOverride = ownColor
            previewWindow.demoLauncherSwitchColor = color
            previewWindow.demoLauncherMaxSlots = slots
        }
        onRequestLauncherOpacityChange: function(customOpacity, opacityValue) {
            previewWindow.demoLauncherOpacityOverride = customOpacity
            previewWindow.demoLauncherOpacity = opacityValue
        }
        onRequestLauncherIconDisplayChange: function(iconsWithNames) {
            previewWindow.demoLauncherIconsWithNames = iconsWithNames
        }
        onRequestMalvinaOptionsOpacityChange: function(customOpacity, opacityValue) {
            previewWindow.demoMalvinaOptionsOpacityOverride = customOpacity
            previewWindow.demoMalvinaOptionsOpacity = opacityValue
        }
        onRequestAutoCollapseTrayChange: function(newValue) {
            previewWindow.demoAutoCollapseTray = newValue
        }
    }

    QQC2.CheckBox {
        id: realTasksSwitch
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.top: bar.bottom
        anchors.topMargin: 12
        text: "Usar ventanas reales de KDE en SO (solo lectura)"
        checked: previewWindow.useRealWindowTasks
        onToggled: previewWindow.useRealWindowTasks = checked
    }

    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: realTasksSwitch.bottom
        anchors.topMargin: 12
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        wrapMode: Text.WordWrap
        color: "#f4edf9"
        text: previewWindow.useRealWindowTasks
              ? "Modo KDE REAL (solo lectura): SO muestra aplicaciones abiertas. " +
                "No activa, minimiza ni cierra ventanas. Probá abrir/cerrar Dolphin o Konsole; " +
                "la fila de SO se actualiza manteniendo el botón a la derecha."
              : "Modo SIMULADO: conserva todas las pruebas anteriores. Arrastrá " +
                "el borde de la ventana o maximizala; Malvina queda a la izquierda " +
                (bar.positionMode === "center"
                    ? "y SO centrado: fichas a derecha sin mover el GIF."
                    : "y Soledad a la derecha.")
    }

    // Diagnóstico visible EXCLUSIVAMENTE en esta ventana de prueba;
    // no es parte de la barra ni del plasmoide final.
    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: widthLabel.top
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 8
        color: "#c7bad8"
        font.pixelSize: 11
        wrapMode: Text.WordWrap
        text: (previewWindow.useRealWindowTasks
                ? "Grupos reales KDE (solo lectura): "
                : "Ventanas de muestra: ") + bar.soWindowCount +
              " · efecto SO: " + bar.soActivityStyle +
              " · " + (bar.soExpanded ? "SO abierto" : "SO cerrado") +
              " · " + (bar.trayExpanded ? "bandeja abierta" : "bandeja cerrada") +
              " · Malvina: " + (bar.malvinaActuallyVisible ? "visible" : "oculta") +
              (bar.autoRevealBlocked
                ? " (BLOQUEADA: simulación maximizada/fullscreen)"
                : (!bar.launcherIslandVisible
                   ? " (deshabilitada en opciones)"
                   : (bar.autoHideMalvina
                      ? " (esperando cursor 0,6 s en esquina izquierda)"
                      : " (autoocultamiento desactivado)"))) +
              " · SO autocierre: " + (bar.autoCollapseSO ? "sí" : "no") +
              " · bandeja autocierre: " + (bar.autoCollapseTray ? "sí" : "no") +
              "\nAncho Soledad: " + Math.round(bar.actualIslandWidth) +
              " / espacio disponible: " + Math.round(bar.availableIslandWidth) +
              " px lógicos · prioridad: " + (bar.lastExpandedMode === "so" ? "SO" : "bandeja")
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 18
        anchors.bottomMargin: 6
        spacing: 8
        QQC2.Button {
            text: "Fijar actual como predeterminada"
            onClicked: previewWindow.savePersonalDefault()
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Guarda todos los ajustes actuales como referencia local permanente"
        }
        QQC2.Button {
            text: "Restaurar predeterminada"
            onClicked: previewWindow.restorePersonalDefault()
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Recupera tu configuración personal sin usar valores de fábrica"
        }
        QQC2.Button {
            text: "Guardar estética favorita"
            onClicked: previewWindow.saveFavoriteAppearance()
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Guarda una copia local independiente de los próximos cambios"
        }
        QQC2.Button {
            text: "Restaurar estética favorita"
            onClicked: previewWindow.restoreFavoriteAppearance()
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Recupera la estética que guardaste como favorita"
        }
    }

    QQC2.Label {
        id: widthLabel
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.bottomMargin: 12
        color: "#c7bad8"
        text: "Ancho del contenido: " + Math.round(bar.width) + " px lógicos"
    }

    onDemoPositionModeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoTaskActiveGlowEnabledChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoTaskActiveDoubleBorderEnabledChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaGoogleUrlChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaDuckUrlChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaYahooUrlChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaChatGptUrlChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaGeminiUrlChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaClaudeUrlChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoTaskDisplayModeChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoTaskFrameShapeChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoTaskFrameColorChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoTaskFrameOpacityChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoTaskFrameWidthChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoAutoReturnRightChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoLauncherIslandVisibleChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoAutoHideMalvinaChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoAutoCollapseSOChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLeftClickOpensLauncherChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoLauncherCategoryLayoutChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherSwitchShapeChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherSwitchColorOverrideChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherSwitchColorChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherMaxSlotsChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherOpacityOverrideChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherOpacityChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoLauncherIconsWithNamesChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaOptionsOpacityOverrideChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoMalvinaOptionsOpacityChanged: { if (appearanceRestored) saveAppearanceTimer.restart() }
    onDemoAutoCollapseTrayChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextLabelChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextBackgroundChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextBackgroundOpacityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextFontFamilyChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextFontSizeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextBackgroundImageChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoTextBoldChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoModeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoPathChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoFitModeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoZoomChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoPanXChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoPanYChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoRotationChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoLogoAnimateChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoClockFontFamilyChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoClockFontSizeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoClockTextColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoOutlineConfigChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoPanelHeightChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadHeightChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaHeightChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadRadiusChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaRadiusChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadMinWidthChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWidthChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoGripShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoButtonFrameShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoButtonWidthChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoBackgroundColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadOpacityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaOpacityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoBackgroundOpacityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoShowBackgroundChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonColorOverrideChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonOpacityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoGripButtonColorOverrideChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoGripButtonColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoGripButtonOpacityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityStyleChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityStrokeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityMotionChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityOrbitSpeedChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityTrailPercentChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityTrailStyleChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityShowWhenEmptyChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityShowWhenOpenChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }

    onDemoSoActivityGlowColorChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityGlowIntensityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityGlowSpreadChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityPulseSpeedChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityGlowGradientChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }

    onDemoSoledadGradientEnabledChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientEndChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientDirectionChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientEnabledChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientEndChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientDirectionChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoActivityPulseDepthChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientSyncBreathingChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientBreathingIntensityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    // Evitar pérdida de cambios de preferencias incorporadas en nuevas revisiones.
    onDemoMalvinaWebFirstChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebOrderChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAiOrderChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaExtraWebChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaExtraAiChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaHiddenWebChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaHiddenAiChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaCompactAiChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGoogleNameChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaDuckNameChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaYahooNameChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaChatGptNameChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGeminiNameChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaClaudeNameChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebGoogleEnabledChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebDuckEnabledChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebYahooEnabledChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAllowChatGptChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAllowGeminiChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAllowClaudeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGearButtonShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaSearchButtonShapeChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientSyncBreathingChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientBreathingIntensityChanged: {
        if (appearanceRestored) saveAppearanceTimer.restart()
    }
    onWidthChanged: console.log("SmartBar ventana independiente: ancho =", width)
}
