// Ventana independiente para validar el redimensionado con el MISMO
// SmartBarContent que usa el plasmoide. No instala nada ni toca paneles.
import QtQuick
import QtQuick.Window
import QtCore as QtCore
import QtQuick.Controls as QQC2
import org.kde.taskmanager 0.1 as TaskManager
import "package/contents/ui"
import "package/contents/ui/ThemeSchedule.js" as ThemeSchedule
import "package/contents/ui/WallpaperFadeDuration.js" as WallpaperFadeDuration

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
    // Inhibe autoguardados de estados parciales al restaurar muchos campos.
    property bool appearanceWriteSuspended: false
    // Solo el script guardar_dia_actual.sh solicita esta captura UNA vez.
    // El reloj automático no interviene durante la recuperación de Día.
    property bool captureDayOnce:
        String(localPreviewSettings.value("captureDayOnce", false)).toLowerCase() === "true"

    // Temas son ranuras aparte del último aspecto, favorito y default personal:
    // restaurar favoritos NO destruye los temas Día/Noche guardados.
    property string demoThemeDayJson: String(localPreviewSettings.value("themeDayJson", ""))
    property string demoThemeDayPreviousJson: String(localPreviewSettings.value("themeDayPreviousJson", ""))
    property string demoThemeNightJson: String(localPreviewSettings.value("themeNightJson", ""))
    property string demoThemeCustomJson: String(localPreviewSettings.value("themeCustomJson", ""))
    property string demoThemeLibraryJson: String(localPreviewSettings.value("themeLibraryJson", "[]"))
    // Preferencias HORARIAS locales, no incluidas en las instantáneas de los temas.
    property bool demoThemeScheduleEnabled:
        String(localPreviewSettings.value("themeScheduleEnabled", true)).toLowerCase() !== "false"
    // Encendido por defecto. Una decisión de apagarlo se recuerda.
    property bool demoBarThemeTransitionEnabled:
        String(localPreviewSettings.value("barThemeTransitionEnabled", true)).toLowerCase() !== "false"
    property int demoThemeScheduleSlotCount:
        Number(localPreviewSettings.value("themeScheduleSlotCount", 4)) === 3 ? 3 : 4
    property string demoThemeScheduleSlots3Json:
        String(localPreviewSettings.value("themeScheduleSlots3Json",
            ThemeSchedule.serialize(ThemeSchedule.defaults(3),3)))
    property string demoThemeScheduleSlots4Json:
        String(localPreviewSettings.value("themeScheduleSlots4Json",
            ThemeSchedule.serialize(ThemeSchedule.defaults(4),4)))
    // Preferencia del fundido: independiente de temas, horarios y apariencia.
    property string demoWallpaperFadeUnit:
        WallpaperFadeDuration.normalizeUnit(
            String(localPreviewSettings.value("wallpaperFadeUnit","seconds")))
    property int demoWallpaperFadeAmount:
        WallpaperFadeDuration.normalizeAmount(
            Number(localPreviewSettings.value("wallpaperFadeAmount",3)),
            demoWallpaperFadeUnit)
    property bool demoHasPersonalDefault: String(localPreviewSettings.value("personalDefaultV1", "")).length > 0
    property bool demoHasFavoriteAppearance: String(localPreviewSettings.value("favoriteSoledadV1", "")).length > 0
    readonly property var appearanceKeys: ["demoAutoReturnRight","demoLauncherIslandVisible","demoAutoHideMalvina","demoAutoCollapseSO","demoSoLeftClickOpensLauncher","demoLauncherCategoryLayout","demoLauncherSwitchShape","demoLauncherSwitchColorOverride","demoLauncherSwitchColor","demoLauncherMaxSlots","demoLauncherOpacityOverride","demoLauncherOpacity","demoLauncherIconsWithNames","demoMalvinaOptionsOpacityOverride","demoMalvinaOptionsOpacity","demoAutoCollapseTray","demoSoLogoMode","demoSoLogoPath","demoSoLogoShape","demoSoLogoFitMode","demoSoLogoZoom","demoSoLogoPanX","demoSoLogoPanY","demoSoLogoRotation","demoSoLogoAnimate","demoSoClockFontFamily","demoSoClockFontSize","demoSoClockTextColor","demoOutlineConfig","demoPanelHeight","demoSoledadHeight","demoMalvinaHeight","demoSoledadRadius","demoMalvinaRadius","demoSoledadMinWidth","demoMalvinaWidth","demoSoledadShape","demoMalvinaShape","demoMalvinaGearButtonShape","demoMalvinaSearchButtonShape","demoGripShape","demoTrayButtonShape","demoSoButtonFrameShape","demoSoButtonWidth","demoSoledadColor","demoMalvinaColor","demoBackgroundColor","demoSoledadOpacity","demoMalvinaOpacity","demoBackgroundOpacity","demoShowBackground","demoTrayButtonColorOverride","demoTrayButtonColor","demoTrayButtonOpacity","demoGripButtonColorOverride","demoGripButtonColor","demoGripButtonOpacity","demoSoActivityStyle","demoSoActivityColor","demoSoActivityStroke","demoSoActivityMotion","demoSoActivityOrbitSpeed","demoSoActivityTrailPercent","demoSoActivityTrailStyle","demoSoActivityShowWhenEmpty","demoSoActivityShowWhenOpen","demoSoActivityGlowColor","demoSoActivityGlowIntensity","demoSoActivityGlowSpread","demoSoActivityPulseSpeed","demoSoActivityGlowGradient","demoSoledadGradientEnabled","demoSoledadGradientEnd","demoSoledadGradientThird","demoSoledadGradientColorCount","demoSoledadGradientDirection","demoMalvinaGradientEnabled","demoMalvinaGradientEnd","demoMalvinaGradientThird","demoMalvinaGradientColorCount","demoMalvinaGradientDirection","demoSoActivityPulseDepth","demoSoledadGradientSyncBreathing","demoSoledadGradientSyncIntensity","demoSoledadGradientBreathingEnabled","demoSoledadGradientBreathingIntensity","demoSoledadGradientBreathingSpeed","demoMalvinaGradientSyncBreathing","demoMalvinaGradientBreathingEnabled","demoMalvinaGradientBreathingIntensity","demoMalvinaGradientBreathingSpeed","demoSoTextLabel","demoSoTextColor","demoSoTextBackground","demoSoTextBackgroundOpacity","demoSoTextFontFamily","demoSoTextFontSize","demoSoTextBold","demoPositionMode","demoSoTextBackgroundImage","demoTaskFrameShape","demoTaskFrameColor","demoTaskFrameOpacity","demoTaskFrameWidth","demoTaskDisplayMode","demoTaskCloseMode","demoTaskActiveGlowEnabled","demoTaskActiveDoubleBorderEnabled","demoMalvinaGoogleUrl","demoMalvinaDuckUrl","demoMalvinaYahooUrl","demoMalvinaChatGptUrl","demoMalvinaGeminiUrl","demoMalvinaClaudeUrl","demoMalvinaWebFirst","demoMalvinaWebOrder","demoMalvinaAiOrder","demoMalvinaExtraWeb","demoMalvinaExtraAi","demoMalvinaHiddenWeb","demoMalvinaHiddenAi","demoMalvinaCompactAi","demoMalvinaGoogleName","demoMalvinaDuckName","demoMalvinaYahooName","demoMalvinaChatGptName","demoMalvinaGeminiName","demoMalvinaClaudeName","demoMalvinaAllowChatGpt","demoMalvinaAllowGemini","demoMalvinaAllowClaude","demoMalvinaWebGoogleEnabled","demoMalvinaWebDuckEnabled","demoMalvinaWebYahooEnabled"]
    QtCore.Settings {
        id: localPreviewSettings
        category: "plasma-smartbar-v01-preview-appearance"
    }
    // Wallpaper del escritorio SIMULADO exclusivamente: nunca usa KWin
    // ni escribe la configuración del fondo del escritorio KDE.
    property string simulatedWallpaperTheme:
        String(localPreviewSettings.value("simulatedWallpaperTheme", "day"))
    property bool simulatedWallpaperEnabled:
        String(localPreviewSettings.value("simulatedWallpaperEnabled", true)).toLowerCase() !== "false"
    // Solo la ventana de simulación posee transición de imagen.
    // El tema activo y las preferencias Qt siguen siendo independientes
    // del botón de demostración (no se guardan cambios al probar).
    readonly property int wallpaperFadeDurationMs:
        WallpaperFadeDuration.durationMs(demoWallpaperFadeAmount,demoWallpaperFadeUnit)
    // Inicialización independiente: NO hacer un binding al valor elegido.
    // De lo contrario un cambio automático actualiza wallpaperShownTheme
    // antes de iniciar el fundido y la animación se saltea.
    property string wallpaperShownTheme:
        String(localPreviewSettings.value("simulatedWallpaperTheme", "day"))
    property string wallpaperPrimaryTheme:
        String(localPreviewSettings.value("simulatedWallpaperTheme", "day"))
    property string wallpaperSecondaryTheme: ""
    property string wallpaperIncomingTheme: ""
    property string wallpaperQueuedTheme: ""
    property string wallpaperActiveLayer: "primary"
    property string wallpaperIncomingLayer: ""
    property bool wallpaperFadeBusy: false
    property string wallpaperDemoPendingTheme: ""

    function wallpaperForTheme(theme) {
        const name = theme === "night" ? "night.png" :
                     theme === "sunset" ? "sunset.png" : "day.png"
        return Qt.resolvedUrl("package/contents/ui/assets/wallpapers/" + name)
    }
    function startWallpaperFadeIfReady() {
        if (!wallpaperFadeBusy || !wallpaperIncomingTheme.length ||
            wallpaperFade.running) return
        const target = wallpaperIncomingLayer === "primary"
            ? simulatedDesktopWallpaper : incomingWallpaper
        if (target.status === Image.Ready) {
            // Coordinación del ensayo: ambas animaciones arrancan recién
            // cuando el PNG entrante está cargado, no antes.
            if (wallpaperDemoPendingTheme === wallpaperIncomingTheme) {
                if (!bar.previewBarThemeColors(wallpaperIncomingTheme)) {
                    console.warn("SmartBar: falta un tema con imagen SO válida para " +
                                 wallpaperIncomingTheme + "; no se funde wallpaper solo")
                    abortWallpaperFade()
                    return
                }
                wallpaperDemoPendingTheme = ""
            }
            wallpaperFade.target = target
            wallpaperFade.start()
        }
    }
    // Solo se modifica el fondo del visor. Nunca toca QSettings de los
    // presets, instantáneas, GIF, colores ni el estado del reloj.
    function changeSimulatedWallpaper(theme, saveSelection) {
        if (["day","sunset","night"].indexOf(theme) < 0) return
        // Ante un nuevo tema real, la selección tiene prioridad aun cuando
        // el fundido anterior dure minutos u horas. No dejarlo en cola.
        if (saveSelection) wallpaperDemoPendingTheme = ""
        if (saveSelection && wallpaperFadeBusy) {
            // Descartar cualquier solicitud obsoleta, no iniciar un
            // segundo fundido al abortar el anterior.
            wallpaperQueuedTheme = ""
            abortWallpaperFade()
        }
        if (saveSelection) {
            simulatedWallpaperTheme = theme
            localPreviewSettings.setValue("simulatedWallpaperTheme", theme)
            localPreviewSettings.sync()
        }
        if (wallpaperFadeBusy) {
            wallpaperQueuedTheme = theme
            return
        }
        if (wallpaperShownTheme === theme) return
        if (!simulatedWallpaperEnabled) {
            wallpaperShownTheme = theme
            wallpaperPrimaryTheme = theme
            wallpaperActiveLayer = "primary"
            simulatedDesktopWallpaper.opacity = 1
            incomingWallpaper.opacity = 0
            return
        }
        wallpaperIncomingTheme = theme
        wallpaperIncomingLayer = wallpaperActiveLayer === "primary"
            ? "secondary" : "primary"
        wallpaperFadeBusy = true
        const target = wallpaperIncomingLayer === "primary"
            ? simulatedDesktopWallpaper : incomingWallpaper
        target.opacity = 0
        if (wallpaperIncomingLayer === "primary") wallpaperPrimaryTheme = theme
        else wallpaperSecondaryTheme = theme
        Qt.callLater(function() { previewWindow.startWallpaperFadeIfReady() })
    }
    function finishWallpaperFade() {
        if (!wallpaperFadeBusy) return
        // Mantener el PNG cargado como capa principal hasta el próximo cambio;
        // no intercambiar source al terminar (evita flashes negros).
        const incoming = wallpaperIncomingLayer === "primary"
            ? simulatedDesktopWallpaper : incomingWallpaper
        const outgoing = wallpaperIncomingLayer === "primary"
            ? incomingWallpaper : simulatedDesktopWallpaper
        incoming.opacity = 1
        outgoing.opacity = 0
        wallpaperActiveLayer = wallpaperIncomingLayer
        wallpaperShownTheme = wallpaperIncomingTheme
        wallpaperFadeBusy = false
        wallpaperIncomingTheme = ""
        wallpaperIncomingLayer = ""
        if (wallpaperQueuedTheme.length) {
            const next = wallpaperQueuedTheme
            wallpaperQueuedTheme = ""
            Qt.callLater(function() { previewWindow.changeSimulatedWallpaper(next,false) })
        }
    }
    function abortWallpaperFade() {
        if (!wallpaperFadeBusy) return
        wallpaperDemoPendingTheme = ""
        wallpaperFade.stop()
        const incoming = wallpaperIncomingLayer === "primary"
            ? simulatedDesktopWallpaper : incomingWallpaper
        incoming.opacity = 0
        wallpaperFadeBusy = false
        wallpaperIncomingTheme = ""
        wallpaperIncomingLayer = ""
        if (wallpaperQueuedTheme.length) {
            const next = wallpaperQueuedTheme
            wallpaperQueuedTheme = ""
            Qt.callLater(function() { previewWindow.changeSimulatedWallpaper(next,false) })
        }
    }
    function previewNextWallpaper() {
        if (wallpaperFadeBusy || !simulatedWallpaperEnabled) return
        const order = ["day","sunset","night"]
        const i = order.indexOf(wallpaperShownTheme)
        const next = order[(i + 1) % order.length]
        // Requerir el perfil exacto de ese horario para no mostrar una foto
        // de Atardecer con el logo de Noche. Los originales nunca se inventan.
        if (!bar.previewThemeAvailable(next)) {
            console.warn("SmartBar: guardá primero el tema " + next +
                         " con su imagen/GIF SO para probar la transición conjunta")
            return
        }
        // Un clic = un fundido de wallpaper + paleta + imagen/GIF de SO.
        // Esperar el PNG entrante para iniciar los efectos simultáneamente.
        wallpaperDemoPendingTheme = next
        changeSimulatedWallpaper(next, false)
    }
    onSimulatedWallpaperEnabledChanged: {
        if (!simulatedWallpaperEnabled) wallpaperDemoPendingTheme = ""
        if (!simulatedWallpaperEnabled && wallpaperFadeBusy) {
            wallpaperFade.stop()
            finishWallpaperFade()
        }
        if (simulatedWallpaperEnabled && wallpaperShownTheme !== simulatedWallpaperTheme &&
            !wallpaperFadeBusy) changeSimulatedWallpaper(simulatedWallpaperTheme,false)
    }

    Timer {
        id: saveAppearanceTimer
        interval: 180
        repeat: false
        onTriggered: previewWindow.saveAppearancePreset()
    }
    function collectAppearancePreset() {
        const values = {}
        for (const key of appearanceKeys) {
            const value = previewWindow[key]
            values[key] = key === "demoOutlineConfig"
                ? JSON.parse(JSON.stringify(value))
                : (key.endsWith("Color") || key.endsWith("Background") || key.endsWith("GradientEnd") || key.endsWith("GradientThird") ||
                   key === "demoSoClockTextColor" ? String(value) : value)
        }
        return JSON.stringify(values)
    }
    function saveAppearancePreset() {
        if (!appearanceRestored || appearanceWriteSuspended) return
        saveAppearanceTimer.stop()
        localPreviewSettings.setValue("appearanceV1", collectAppearancePreset())
        localPreviewSettings.sync()
    }
    function saveFavoriteAppearance() {
        if (!appearanceRestored) return
        saveAppearanceTimer.stop()
        const current = collectAppearancePreset()
        localPreviewSettings.setValue("favoriteSoledadV1", current)
        demoHasFavoriteAppearance = true
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
        demoHasPersonalDefault = true
        localPreviewSettings.sync()
        console.log("SmartBar: configuración completa fijada como predeterminada personal local")
    }
    // Los tres espacios son independientes. Restaurar copia a la apariencia
    // activa al final, no a otros perfiles, y solo hace una escritura completa.
    function restoreSavedAppearance(key, label) {
        if (!appearanceRestored) return
        const raw = localPreviewSettings.value(key, "")
        if (typeof raw !== "string" || !raw.length) {
            console.warn("SmartBar: todavía no hay " + label + " guardada")
            return
        }
        let values
        try {
            values = JSON.parse(raw)
            if (!values || typeof values !== "object" || Array.isArray(values))
                throw new Error("Instantánea inválida")
        } catch(e) {
            console.warn("SmartBar: no se pudo leer " + label + ":", e)
            return
        }
        saveAppearanceTimer.stop()
        const before = JSON.parse(collectAppearancePreset())
        let restored = false
        appearanceWriteSuspended = true
        try {
            for (const field of appearanceKeys) {
                if (Object.prototype.hasOwnProperty.call(values, field))
                    previewWindow[field] = values[field]
            }
            restored = true
        } catch(e) {
            console.warn("SmartBar: error al restaurar " + label + ":", e)
            // No persistir una restauración incompleta.
            for (const field of appearanceKeys) {
                try { previewWindow[field] = before[field] }
                catch(rollbackError) {
                    console.warn("SmartBar: fallo al recuperar " + field, rollbackError)
                }
            }
        } finally {
            appearanceWriteSuspended = false
        }
        if (!restored) return
        saveAppearancePreset()
        console.log("SmartBar: " + label + " restaurada a apariencia activa")
    }
    function restorePersonalDefault() {
        restoreSavedAppearance("personalDefaultV1", "predeterminada personal")
    }
    function restoreFavoriteAppearance() {
        restoreSavedAppearance("favoriteSoledadV1", "estética favorita")
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
        appearanceRestored = true
    }
    function captureDayFromSavedAppearance() {
        if (!appearanceRestored) {
            console.warn("SMARTBAR_DAY_CAPTURE_ERROR=No se restauró la apariencia.")
            Qt.quit()
            return
        }
        if (simulatedWallpaperTheme !== "day") {
            console.warn("SMARTBAR_DAY_CAPTURE_ERROR=El tema visible no es Día. Elegilo antes de cerrar la maqueta.")
            localPreviewSettings.setValue("captureDayOnce", false)
            localPreviewSettings.sync()
            Qt.quit()
            return
        }
        // Guardar el estado COMPLETO tal cual estaba antes de imponer 90 %.
        const originalAppearance = collectAppearancePreset()
        const originalLibrary = demoThemeLibraryJson
        let items = []
        try {
            const parsed = JSON.parse(originalLibrary)
            if (!Array.isArray(parsed)) throw new Error("biblioteca inválida")
            items = parsed
            if (items.length >= 200) throw new Error("biblioteca llena")
        } catch (error) {
            console.warn("SMARTBAR_DAY_CAPTURE_ERROR=No se modificó la biblioteca: " + error)
            localPreviewSettings.setValue("captureDayOnce", false)
            localPreviewSettings.sync()
            Qt.quit()
            return
        }
        // Se modifica SOLO opacidad: paleta, GIF, animaciones y geometría
        // vienen de las preferencias activas del visor, sin estimaciones.
        demoSoledadOpacity = 0.9
        demoMalvinaOpacity = 0.9
        demoLauncherOpacity = 0.9
        demoMalvinaOptionsOpacity = 0.9
        demoTrayButtonOpacity = 0.9
        demoGripButtonOpacity = 0.9
        demoBackgroundOpacity = 0.9
        let snapshot = ""
        let captured
        try {
            snapshot = bar.snapshotFromLiveAppearance()
            captured = JSON.parse(snapshot)
            if (captured.version !== 1 ||
                (captured.logoMode === "custom" && !captured.filePath))
                throw new Error("snapshot incompleto")
        } catch (error) {
            // Restaurar la vista original si la captura falla:
            // no transformar el Día activo en un estado parcial.
            const before = JSON.parse(originalAppearance)
            for (const key of ["demoSoledadOpacity","demoMalvinaOpacity",
                               "demoLauncherOpacity","demoMalvinaOptionsOpacity",
                               "demoTrayButtonOpacity","demoGripButtonOpacity",
                               "demoBackgroundOpacity"]) {
                if (before[key] !== undefined) previewWindow[key] = before[key]
            }
            console.warn("SMARTBAR_DAY_CAPTURE_ERROR=No se escribió Día: " + error)
            localPreviewSettings.setValue("captureDayOnce", false)
            localPreviewSettings.sync()
            Qt.quit()
            return
        }
        const stamp = new Date().toISOString().replace(/[:.]/g, "-")
        const oldIndex = items.findIndex(function(item) {
            const name = item && String(item.name || "").trim().toLowerCase()
            return name === "día" || name === "dia"
        })
        // Se mantiene la copia anterior restaurable en la biblioteca.
        if (oldIndex >= 0) {
            items.push({name: "Día · respaldo " + stamp.slice(0, 16),
                        jsonData: items[oldIndex].jsonData})
            items[oldIndex] = {name: "Día", jsonData: snapshot}
        } else items.push({name: "Día", jsonData: snapshot})
        // La copia original y la biblioteca anterior nunca se sobrescriben
        // dentro de los originales oficiales Factory*Theme.js.
        localPreviewSettings.setValue("dayCapturedAppearanceBefore90V1", originalAppearance)
        localPreviewSettings.setValue("dayCapturedLibraryBeforeV1", originalLibrary)
        localPreviewSettings.setValue("themeLibraryJson", JSON.stringify(items))
        demoThemeLibraryJson = JSON.stringify(items)
        saveAppearancePreset()
        localPreviewSettings.setValue("captureDayOnce", false)
        localPreviewSettings.sync()
        console.log("SMARTBAR_DAY_CAPTURE_JSON=" + JSON.stringify({
            capturedAt: stamp, theme: captured, appearanceBefore90: JSON.parse(originalAppearance),
            previousLibrary: JSON.parse(originalLibrary)
        }))
        Qt.quit()
    }
    Component.onCompleted: {
        restoreAppearancePreset()
        if (captureDayOnce)
            Qt.callLater(function() { previewWindow.captureDayFromSavedAppearance() })
    }
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
    // Perfiles nuevos: ícono y nombre. Respetar los perfiles ya guardados.
    property string demoTaskDisplayMode: "both"
    property string demoTaskCloseMode: "both"
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
    property real demoLauncherOpacity: 0.9
    property bool demoLauncherIconsWithNames: true
    property bool demoMalvinaOptionsOpacityOverride: false
    property real demoMalvinaOptionsOpacity: 0.9
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
    property color demoSoledadGradientThird: "#ee9852"
    property int demoSoledadGradientColorCount: 2
    property string demoSoledadGradientDirection: "topBottom"
    property bool demoSoledadGradientSyncBreathing: false
    property bool demoSoledadGradientSyncIntensity: false
    property bool demoSoledadGradientBreathingEnabled: true
    property real demoSoledadGradientBreathingIntensity: 0.6
    property real demoSoledadGradientBreathingSpeed: 0.6
    property bool demoMalvinaGradientSyncBreathing: false
    property bool demoMalvinaGradientBreathingEnabled: true
    property real demoMalvinaGradientBreathingIntensity: 0.6
    property real demoMalvinaGradientBreathingSpeed: 0.6
    property bool demoMalvinaGradientEnabled: false
    property color demoMalvinaGradientEnd: "#445577"
    property color demoMalvinaGradientThird: "#445577"
    property int demoMalvinaGradientColorCount: 2
    property string demoMalvinaGradientDirection: "topBottom"
    property color demoBackgroundColor: "#202333"
    property real demoSoledadOpacity: 0.9
    property real demoMalvinaOpacity: 0.9
    property real demoBackgroundOpacity: 0.9
    property bool demoShowBackground: false
    property bool demoTrayButtonColorOverride: false
    property color demoTrayButtonColor: "#010111"
    property real demoTrayButtonOpacity: 0.9
    property bool demoGripButtonColorOverride: false
    property color demoGripButtonColor: "#010111"
    property real demoGripButtonOpacity: 0.9
    property string demoSoActivityStyle: "breathe"
    property color demoSoActivityColor: "#35d7ff"
    property real demoSoActivityStroke: 0.75
    property bool demoSoActivityMotion: true
    property real demoSoActivityOrbitSpeed: 1.5
    property int demoSoActivityTrailPercent: 75
    property string demoSoActivityTrailStyle: "dashed"
    property color demoSoActivityGlowColor: "#ffab52"
    property real demoSoActivityGlowIntensity: 0.7
    property real demoSoActivityGlowSpread: 5
    property real demoSoActivityPulseSpeed: 0.3
    property real demoSoActivityPulseDepth: 0.7
    property bool demoSoActivityGlowGradient: true
    property bool demoSoActivityShowWhenEmpty: true
    property bool demoSoActivityShowWhenOpen: false

    // Doble búfer: el anterior sigue cargado mientras el entrante se
    // desvanece encima; ambos son puramente decorativos y no capturan clics.
    Image {
        id: simulatedDesktopWallpaper
        anchors.fill: parent
        z: previewWindow.wallpaperIncomingLayer === "primary" ? -0.9 : -1
        source: previewWindow.wallpaperForTheme(previewWindow.wallpaperPrimaryTheme)
        opacity: 1
        fillMode: Image.Stretch
        asynchronous: true
        cache: true
        smooth: true
        visible: previewWindow.simulatedWallpaperEnabled && status === Image.Ready
        onStatusChanged: {
            if (status === Image.Ready && previewWindow.wallpaperIncomingLayer === "primary")
                previewWindow.startWallpaperFadeIfReady()
            if (status === Image.Error && previewWindow.wallpaperIncomingLayer === "primary") {
                console.warn("SmartBar: no se pudo cargar nuevo wallpaper:", source)
                previewWindow.abortWallpaperFade()
            }
        }
    }
    Image {
        id: incomingWallpaper
        anchors.fill: parent
        z: previewWindow.wallpaperIncomingLayer === "secondary" ? -0.9 : -1
        source: previewWindow.wallpaperSecondaryTheme.length
            ? previewWindow.wallpaperForTheme(previewWindow.wallpaperSecondaryTheme) : ""
        opacity: 0
        fillMode: Image.Stretch
        asynchronous: true
        cache: true
        smooth: true
        visible: previewWindow.simulatedWallpaperEnabled && status === Image.Ready
        onStatusChanged: {
            if (status === Image.Ready && previewWindow.wallpaperIncomingLayer === "secondary")
                previewWindow.startWallpaperFadeIfReady()
            if (status === Image.Error && previewWindow.wallpaperIncomingLayer === "secondary") {
                console.warn("SmartBar: no se pudo cargar nuevo wallpaper:", source)
                previewWindow.abortWallpaperFade()
            }
        }
    }
    NumberAnimation {
        id: wallpaperFade
        property: "opacity"
        from: 0
        to: 1
        duration: previewWindow.wallpaperFadeDurationMs
        easing.type: Easing.InOutCubic
        onFinished: previewWindow.finishWallpaperFade()
    }

    SmartBarContent {
        id: bar
        // No empezar el reloj antes de restaurar los ajustes locales.
        themeScheduleRuntimeEnabled: previewWindow.appearanceRestored && !previewWindow.captureDayOnce
        themeScheduleEnabled: previewWindow.demoThemeScheduleEnabled
        themeScheduleSlotCount: previewWindow.demoThemeScheduleSlotCount
        themeScheduleSlots3Json: previewWindow.demoThemeScheduleSlots3Json
        themeScheduleSlots4Json: previewWindow.demoThemeScheduleSlots4Json
        barThemeTransitionEnabled: previewWindow.demoBarThemeTransitionEnabled
        wallpaperFadeAmount: previewWindow.demoWallpaperFadeAmount
        wallpaperFadeUnit: previewWindow.demoWallpaperFadeUnit
        themeWallpaperPreviewAvailable: previewWindow.simulatedWallpaperEnabled &&
                                      !previewWindow.wallpaperFadeBusy
        onRequestThemeWallpaperPreview: previewWindow.previewNextWallpaper()
        realTaskModel: previewWindow.useRealWindowTasks ? kdeTasks : null
        // Abrir/cerrar fichas ficticias solo en esta ventana de ensayo.
        demoWindowControlsEnabled: true
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
        taskCloseMode: previewWindow.demoTaskCloseMode
        onRequestTaskCloseModeChange: function(mode) {
            previewWindow.demoTaskCloseMode = ["both", "preview", "chip"].indexOf(mode) >= 0
                ? mode : "both"
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
        thematicWallpaperEnabled: previewWindow.simulatedWallpaperEnabled
        onRequestThematicWallpaperVisibilityChange: function(enabled) {
            previewWindow.simulatedWallpaperEnabled = enabled
            localPreviewSettings.setValue("simulatedWallpaperEnabled", enabled)
            localPreviewSettings.sync()
        }
        onRequestThemeScheduleChange: function(enabled, count, slots3Json, slots4Json) {
            previewWindow.demoThemeScheduleEnabled = enabled
            previewWindow.demoThemeScheduleSlotCount = count
            previewWindow.demoThemeScheduleSlots3Json = slots3Json
            previewWindow.demoThemeScheduleSlots4Json = slots4Json
            localPreviewSettings.setValue("themeScheduleEnabled", enabled)
            localPreviewSettings.setValue("themeScheduleSlotCount", count)
            localPreviewSettings.setValue("themeScheduleSlots3Json", slots3Json)
            localPreviewSettings.setValue("themeScheduleSlots4Json", slots4Json)
            localPreviewSettings.sync()
        }
        onRequestWallpaperFadeChange: function(amount, unit) {
            if (!WallpaperFadeDuration.valid(amount,unit)) return
            previewWindow.demoWallpaperFadeUnit = unit
            previewWindow.demoWallpaperFadeAmount = amount
            localPreviewSettings.setValue("wallpaperFadeAmount",amount)
            localPreviewSettings.setValue("wallpaperFadeUnit",unit)
            localPreviewSettings.sync()
        }
        onRequestBarThemeTransitionChange: function(enabled) {
            previewWindow.demoBarThemeTransitionEnabled = enabled
            localPreviewSettings.setValue("barThemeTransitionEnabled",enabled)
            localPreviewSettings.sync()
        }
        onRequestWallpaperThemeChange: function(themeName) {
            previewWindow.changeSimulatedWallpaper(themeName, true)
        }
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
        themeDayPreviousJson: previewWindow.demoThemeDayPreviousJson
        themeNightJson: previewWindow.demoThemeNightJson
        themeCustomJson: previewWindow.demoThemeCustomJson
        themeLibraryJson: previewWindow.demoThemeLibraryJson
        personalDefaultAvailable: previewWindow.demoHasPersonalDefault
        favoriteAppearanceAvailable: previewWindow.demoHasFavoriteAppearance
        onRequestRestorePersonalDefault: previewWindow.restorePersonalDefault()
        onRequestRestoreFavoriteAppearance: previewWindow.restoreFavoriteAppearance()
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
        malvinaColor: previewWindow.demoMalvinaColor
        soledadGradientEnabled: previewWindow.demoSoledadGradientEnabled
        soledadGradientEnd: previewWindow.demoSoledadGradientEnd
        soledadGradientThird: previewWindow.demoSoledadGradientThird
        soledadGradientColorCount: previewWindow.demoSoledadGradientColorCount
        soledadGradientDirection: previewWindow.demoSoledadGradientDirection
        soledadGradientSyncBreathing: previewWindow.demoSoledadGradientSyncBreathing
        soledadGradientSyncIntensity: previewWindow.demoSoledadGradientSyncIntensity
        soledadGradientBreathingEnabled: previewWindow.demoSoledadGradientBreathingEnabled
        soledadGradientBreathingIntensity: previewWindow.demoSoledadGradientBreathingIntensity
        soledadGradientBreathingSpeed: previewWindow.demoSoledadGradientBreathingSpeed
        malvinaGradientSyncBreathing: previewWindow.demoMalvinaGradientSyncBreathing
        malvinaGradientBreathingEnabled: previewWindow.demoMalvinaGradientBreathingEnabled
        malvinaGradientBreathingIntensity: previewWindow.demoMalvinaGradientBreathingIntensity
        malvinaGradientBreathingSpeed: previewWindow.demoMalvinaGradientBreathingSpeed
        malvinaGradientEnabled: previewWindow.demoMalvinaGradientEnabled
        malvinaGradientEnd: previewWindow.demoMalvinaGradientEnd
        malvinaGradientThird: previewWindow.demoMalvinaGradientThird
        malvinaGradientColorCount: previewWindow.demoMalvinaGradientColorCount
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
        onRequestGradientBreathingChange: function(sync, intensity, active, speed, syncIntensity) {
            previewWindow.demoSoledadGradientSyncBreathing = sync
            previewWindow.demoSoledadGradientBreathingIntensity = intensity
            previewWindow.demoSoledadGradientBreathingEnabled = active
            previewWindow.demoSoledadGradientBreathingSpeed = speed
            previewWindow.demoSoledadGradientSyncIntensity = syncIntensity
        }
        onRequestMalvinaGradientBreathingChange: function(sync, intensity, active, speed) {
            previewWindow.demoMalvinaGradientSyncBreathing = sync
            previewWindow.demoMalvinaGradientBreathingIntensity = intensity
            previewWindow.demoMalvinaGradientBreathingEnabled = active
            previewWindow.demoMalvinaGradientBreathingSpeed = speed
        }
        onRequestIslandGradientChange: function(a, b, c, d, e, f, g, h, i, j) {
            previewWindow.demoSoledadGradientEnabled = a
            previewWindow.demoSoledadGradientEnd = b
            previewWindow.demoSoledadGradientDirection = c
            previewWindow.demoMalvinaGradientEnabled = d
            previewWindow.demoMalvinaGradientEnd = e
            previewWindow.demoMalvinaGradientDirection = f
            previewWindow.demoSoledadGradientColorCount = g
            previewWindow.demoSoledadGradientThird = h
            previewWindow.demoMalvinaGradientColorCount = i
            previewWindow.demoMalvinaGradientThird = j
        }
        onRequestAppearanceChange: function(a, alphaA, b, alphaB, shown, bg,
                                            alphaBg, trayOverride, trayColor,
                                            trayOpacity, gripOverride,
                                            gripColor, gripOpacity) {
            previewWindow.demoSoledadColor = a
            previewWindow.demoSoledadOpacity = alphaA
            previewWindow.demoMalvinaColor = b
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
            else if (slot === "dayPrevious") previewWindow.demoThemeDayPreviousJson = data
            else if (slot === "night") previewWindow.demoThemeNightJson = data
            else if (slot === "custom") previewWindow.demoThemeCustomJson = data
            else if (slot === "library") previewWindow.demoThemeLibraryJson = data
            else return
            const storageKey = slot === "library" ? "themeLibraryJson" :
                "theme" + (slot === "day" ? "Day" : slot === "dayPrevious" ? "DayPrevious" :
                           slot === "night" ? "Night" : "Custom") + "Json"
            localPreviewSettings.setValue(storageKey, data)
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
              " · fichas: " + (bar.taskDisplayMode === "both"
                    ? "ícono y nombre" : (bar.taskDisplayMode === "text"
                        ? "solo nombre" : "solo ícono")) +
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

    // Una prueba por clic: funde la foto y los colores VISUALES de la barra,
    // sin aplicar ni guardar temas, tocar horarios o el escritorio KDE.
    QQC2.Button {
        id: wallpaperDemoButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.bottomMargin: 48
        text: "siguiente tema y wallpaper"
        enabled: bar.themeScheduleRuntimeEnabled &&
                 bar.themeWallpaperPreviewAvailable
        // Misma entrada que los menús contextuales de Soledad y Malvina.
        onClicked: bar.triggerThemeWallpaperPreview()
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: "Un fundido por clic. Duración: " +
            previewWindow.demoWallpaperFadeAmount + " " +
            (previewWindow.demoWallpaperFadeUnit === "hours" ? "hora(s)" :
             previewWindow.demoWallpaperFadeUnit === "minutes" ? "minuto(s)" : "segundo(s)") +
            ". Configuración → Temas → Con horarios."
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
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoTaskActiveGlowEnabledChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskActiveDoubleBorderEnabledChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaGoogleUrlChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaDuckUrlChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaYahooUrlChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaChatGptUrlChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaGeminiUrlChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaClaudeUrlChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskDisplayModeChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskCloseModeChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskFrameShapeChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskFrameColorChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskFrameOpacityChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoTaskFrameWidthChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoAutoReturnRightChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoLauncherIslandVisibleChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoAutoHideMalvinaChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoAutoCollapseSOChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLeftClickOpensLauncherChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoLauncherCategoryLayoutChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherSwitchShapeChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherSwitchColorOverrideChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherSwitchColorChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherMaxSlotsChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherOpacityOverrideChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherOpacityChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoLauncherIconsWithNamesChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaOptionsOpacityOverrideChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoMalvinaOptionsOpacityChanged: { if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart() }
    onDemoAutoCollapseTrayChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextLabelChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextBackgroundChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextBackgroundOpacityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextFontFamilyChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextFontSizeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextBackgroundImageChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoTextBoldChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoModeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoPathChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoFitModeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoZoomChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoPanXChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoPanYChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoRotationChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoLogoAnimateChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoClockFontFamilyChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoClockFontSizeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoClockTextColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoOutlineConfigChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoPanelHeightChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadHeightChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaHeightChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadRadiusChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaRadiusChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadMinWidthChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWidthChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoGripShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoButtonFrameShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoButtonWidthChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoBackgroundColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadOpacityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaOpacityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoBackgroundOpacityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoShowBackgroundChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonColorOverrideChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoTrayButtonOpacityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoGripButtonColorOverrideChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoGripButtonColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoGripButtonOpacityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityStyleChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityStrokeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityMotionChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityOrbitSpeedChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityTrailPercentChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityTrailStyleChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityShowWhenEmptyChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityShowWhenOpenChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }

    onDemoSoActivityGlowColorChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityGlowIntensityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityGlowSpreadChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityPulseSpeedChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityGlowGradientChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }

    onDemoSoledadGradientEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientEndChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientThirdChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientColorCountChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientDirectionChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientEndChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientThirdChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientColorCountChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientBreathingEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientBreathingSpeedChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientBreathingEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientBreathingSpeedChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientDirectionChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoActivityPulseDepthChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientSyncBreathingChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientSyncIntensityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoSoledadGradientBreathingIntensityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    // Evitar pérdida de cambios de preferencias incorporadas en nuevas revisiones.
    onDemoMalvinaWebFirstChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebOrderChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAiOrderChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaExtraWebChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaExtraAiChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaHiddenWebChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaHiddenAiChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaCompactAiChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGoogleNameChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaDuckNameChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaYahooNameChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaChatGptNameChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGeminiNameChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaClaudeNameChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebGoogleEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebDuckEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaWebYahooEnabledChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAllowChatGptChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAllowGeminiChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaAllowClaudeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGearButtonShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaSearchButtonShapeChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientSyncBreathingChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onDemoMalvinaGradientBreathingIntensityChanged: {
        if (appearanceRestored && !appearanceWriteSuspended) saveAppearanceTimer.restart()
    }
    onWidthChanged: console.log("SmartBar ventana independiente: ancho =", width)
}
