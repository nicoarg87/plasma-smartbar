// Fuente única para las islas y controles del prototipo visual.
// Los cambios de ancho se aplican a la geometría REAL de este Item.
// Prototipo VISUAL: los controles NO modifican ventanas reales.
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtCore as QtCore
import QtQuick.Controls as QQC2
import "ThemeSchedule.js" as ThemeSchedule
import "ThemePack.js" as ThemePack
import "WallpaperFadeDuration.js" as WallpaperFadeDuration
import "DemoWindows.js" as DemoWindows
import "SystemTrayModel.js" as SystemTrayModel
import "SystemTrayController.js" as SystemTrayController
import "SoledadExpansionPolicy.js" as SoledadExpansionPolicy
import "SoledadLauncherPlacement.js" as SoledadLauncherPlacement
import "SoledadTaskSizing.js" as SoledadTaskSizing
import "SoledadBreathingMath.js" as SoledadBreathingMath
import "DemoWindowInstances.js" as DemoWindowInstances
import "DemoAudioState.js" as DemoAudioState
import "SoledadPositionProfiles.js" as SoledadPositionProfiles
import "LayerShellDragCompensation.js" as LayerShellDragCompensation
import "RealActiveWindow.js" as RealActiveWindow
import "RuntimeAppearance.js" as RuntimeAppearance

Item {
    id: root
    focus: true // Teclas locales al enfocar el visor; no captura atajos globales KWin.
    property bool superKeyPending: false
    property bool soLauncherOpenOnLeftPress: false
    property bool soLauncherOpenOnRightPress: false
    Keys.onPressed: function(event) {
        // Detectar Super sola, sin activarla hasta soltar: evita abrir
        // launcher por Super+Espacio u otros atajos del escritorio.
        if (event.key === Qt.Key_Meta && !event.isAutoRepeat &&
                !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.ShiftModifier))) {
            root.superKeyPending = true
            event.accepted = true
        } else if (root.superKeyPending && event.key !== Qt.Key_Meta) {
            root.superKeyPending = false
        }
    }
    Keys.onReleased: function(event) {
        if (event.key === Qt.Key_Meta) {
            if (root.superKeyPending)
                root.openInstalledLauncher("so")
            root.superKeyPending = false
            event.accepted = true
        }
    }

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
    // Preferencia compartida por Web/IA; no cambia el navegador KDE global.
    property string malvinaBrowserId: "system"
    property var malvinaBrowserChoices: [
        {"id": "system", "name": "Predeterminado del sistema (KDE)"}
    ]
    property var malvinaBrowserBackend: null // solo ensayo nativo hasta integrar en plasmoide
    signal requestMalvinaBrowserChange(string browserId)
    property bool malvinaWebFirst: true
    property string malvinaWebOrder: "duck,yahoo,google"
    property string malvinaAiOrder: "chatgpt,claude,gemini"
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
    // Opt-in de las dos islas LayerShell: el visor normal y el plasmoide
    // conservan su circuito de Aplicar sin perfil compartido adicional.
    property bool runtimeAppearanceEnabled: false
    // La confirmación llega sincrónicamente desde la isla que ejecuta Qt.
    property bool runtimeLastAppearanceCommitOk: false
    signal requestRuntimeAppearancePatch(string patchJson)
    // Espacios locales de temas: no cambian posiciones ni permisos de Malvina.
    property string themeDayJson: ""
    property string themeDayPreviousJson: ""
    property string themeNightJson: ""
    property string themeCustomJson: ""
    // Lista ampliable de temas personales guardados por el usuario.
    property string themeLibraryJson: "[]"
    property bool personalDefaultAvailable: false
    property bool favoriteAppearanceAvailable: false
    signal requestRestorePersonalDefault()
    signal requestRestoreFavoriteAppearance()
    signal requestThemeSlotChange(string slot, string jsonData)
    // Programación diaria de temas. Valores personales y perfiles de 3/4 slots
    // independientes de los tres originales de fábrica inmutables.
    property string selectedThemePackId: ThemePack.DEFAULT_ID
    property string themePackLibraryJson: "[]"
    signal requestSelectedThemePackChange(string id)
    signal requestThemePackLibraryChange(string json)
    property bool themeScheduleRuntimeEnabled: false  // solo habilitado en el visor seguro
    property bool themeScheduleEnabled: true
    property int themeScheduleSlotCount: 4
    // El formato histórico sigue siendo exclusivamente el de Playa 24hs.
    // Los packs personales toman modo/3-4 franjas de su propia biblioteca.
    readonly property var activeCustomThemePack: ThemePack.find(
        ThemePack.parse(themePackLibraryJson), selectedThemePackId)
    readonly property bool activeThemeScheduleEnabled: activeCustomThemePack
        ? ThemePack.automatic(activeCustomThemePack, themeScheduleEnabled)
        : themeScheduleEnabled
    readonly property int activeThemeScheduleSlotCount: activeCustomThemePack
        ? ThemePack.slotCount(activeCustomThemePack, themeScheduleSlotCount)
        : themeScheduleSlotCount
    property string themeScheduleSlots3Json:
        ThemeSchedule.serialize(ThemeSchedule.defaults(3),3)
    property string themeScheduleSlots4Json:
        ThemeSchedule.serialize(ThemeSchedule.defaults(4),4)
    property string lastScheduledSlotKey: ""
    // Secuencia manual del pack: independiente de horarios y sin alterar
    // las instantáneas guardadas. Se reinicia al cambiar de pack.
    property int manualPackThemeIndex: -1
    property string runtimeThemePackJson: ""
    readonly property bool runtimeThemeSwitchAvailable:
        runtimeAppearanceEnabled && runtimeThemePackJson.length > 0
    // Confirmación sincrónica del helper nativo del ensayo LayerShell.
    // Sin wallpaper reconocido, los snapshots personales no inventan fondo.
    property bool runtimeWallpaperLastOk: false
    signal requestRuntimeWallpaperThemeChange(string themeName)
    signal requestRuntimeWallpaperUndo()

    function passToNextRuntimeTheme() {
        if (!runtimeThemeSwitchAvailable) return false
        let data
        try { data = JSON.parse(runtimeThemePackJson) }
        catch (error) { return false }
        if (!data || data.version !== 1 ||
            (data.packId !== "playa-24hs" &&
             !/^pack-[1-9][0-9]*$/.test(String(data.packId || ""))) ||
            !Array.isArray(data.themesSequence) ||
            data.themesSequence.length < 1 || data.themesSequence.length > 20 ||
            !data.themes) return false
        const count = data.themesSequence.length
        if (!count) return false
        const index = (manualPackThemeIndex + 1) % count
        const theme = data.themesSequence[index]
        const originalPatch = data.themes[theme]
        if (!originalPatch || typeof originalPatch !== "object" ||
            Object.keys(originalPatch).length < 55) return false
        // El 60 % pertenece exclusivamente a Playa 24hs.
        // Los packs personales conservan su propia opacidad guardada.
        const patch = RuntimeAppearance.withThemeOpacity(originalPatch,
                                                         data.packId)
        if (!patch) return false
        // Solo tres presets tienen wallpapers verificados. Un snapshot
        // personal sin fondo declarado cambia solo la apariencia guardada.
        const hasWallpaper = theme === "day" || theme === "sunset" ||
                             theme === "night"
        if (hasWallpaper) {
            runtimeWallpaperLastOk = false
            requestRuntimeWallpaperThemeChange(theme)
            if (!runtimeWallpaperLastOk) {
                console.warn("SmartBar: el wallpaper no cambió; " +
                             "se conservó el tema visual anterior")
                return false
            }
        }
        // Guardar la estética SOLO si KDE confirmó su fondo correspondiente.
        // Malvina relee el mismo perfil compartido. No tocar posiciones KWin.
        runtimeLastAppearanceCommitOk = false
        requestRuntimeAppearancePatch(JSON.stringify(patch))
        if (!runtimeLastAppearanceCommitOk) {
            if (hasWallpaper) requestRuntimeWallpaperUndo()
            console.warn("SmartBar: no se pudo aplicar el tema completo")
            return false
        }
        manualPackThemeIndex = index
        console.log("SmartBar: tema visual del pack aplicado", theme)
        return true
    }
    function passToNextPackTheme() {
        if (runtimeAppearanceEnabled) return passToNextRuntimeTheme()
        // El ensayo conjunto aún no dispone de persistencia integral de temas.
        // Nunca aplicar solo el wallpaper ni una parte de la estética.
        if (!themeScheduleRuntimeEnabled || soledadSettings.visible) return false
        syncSettingsFromRoot()
        const pack = activeCustomThemePack
        const count = pack ? pack.members.length : ThemePack.THEMES.length
        if (count <= 0) return false
        const index = (manualPackThemeIndex + 1) % count
        const member = pack ? pack.members[index] : null
        const theme = pack ? (member.kind === "preset" ? member.theme : "") :
                            ThemePack.THEMES[index]
        const slot = pack
            ? (member.kind === "preset" ? scheduledThemeSlot(member.theme) :
                "pack:" + index)
            : scheduledThemeSlot(theme)
        if (!slot) {
            console.warn("SmartBar temas: el siguiente tema no está disponible")
            return false
        }
        // Aplicación integral: preferencias del botón SO, Soledad y Malvina.
        if (!soledadSettings.activateTheme(slot)) return false
        // Al escoger manualmente, no permitir que el reloj lo revierta
        // en el siguiente tick. Se mantiene el esquema horario guardado.
        soledadSettings.setScheduleEnabled(false)
        // Los packs personales actualizan su JSON al desactivar el reloj:
        // registrar el índice DESPUÉS para no reiniciar la secuencia.
        manualPackThemeIndex = index
        lastScheduledSlotKey = ""
        if (theme) requestWallpaperThemeChange(theme)
        return true
    }
    signal requestThemeScheduleChange(bool enabled, int count, string slots3Json, string slots4Json)
    property int wallpaperFadeAmount: 3
    property string wallpaperFadeUnit: "seconds"
    signal requestWallpaperFadeChange(int amount, string unit)
    // Único acceso al ensayo visual: lo pueden invocar el visor y ambos
    // menús contextuales, pero nunca el panel KDE real sin motor de prueba.
    property bool themeWallpaperPreviewAvailable: false
    signal requestThemeWallpaperPreview()
    function triggerThemeWallpaperPreview() {
        if (!themeScheduleRuntimeEnabled || !themeWallpaperPreviewAvailable) return
        requestThemeWallpaperPreview()
    }
    property bool barThemeTransitionEnabled: true
    signal requestBarThemeTransitionChange(bool enabled)
    onSelectedThemePackIdChanged: { lastScheduledSlotKey = ""; manualPackThemeIndex = -1 }
    onThemePackLibraryJsonChanged: { lastScheduledSlotKey = ""; manualPackThemeIndex = -1 }
    onThemeScheduleEnabledChanged: lastScheduledSlotKey = ""
    onThemeScheduleSlotCountChanged: lastScheduledSlotKey = ""
    onThemeScheduleSlots3JsonChanged: lastScheduledSlotKey = ""
    onThemeScheduleSlots4JsonChanged: lastScheduledSlotKey = ""

    // El fin de cada franja coincide con el comienzo de la siguiente.
    // La hora siempre es local; al recuperar suspensión recalcular sin colas.
    Timer {
        interval: 15000
        running: root.themeScheduleRuntimeEnabled && root.activeThemeScheduleEnabled
        triggeredOnStart: true
        repeat: true
        onTriggered: root.checkThemeSchedule()
    }
    function scheduledThemeSlot(theme) {
        // Prioridad: fábrica auténtica > tema nombrado por el usuario >
        // respaldo histórico. Nunca inferir un tema por el wallpaper actual.
        const named = soledadSettings.namedThemeIndex(theme)
        if (theme === "day")
            return soledadSettings.factoryDayAvailable ? "dayOfficial" :
                named >= 0 ? "library:" + named : ""
        if (theme === "sunset")
            return soledadSettings.factorySunsetAvailable ? "sunset" :
                soledadSettings.provisionalSunsetJson.length ? "sunsetProvisional" :
                named >= 0 ? "library:" + named :
                (soledadSettings.themeDayJson.length ? "day" : "")
        if (theme === "night")
            return soledadSettings.factoryNightAvailable ? "night" :
                named >= 0 ? "library:" + named :
                (soledadSettings.themeNightJson.length ? "nightLegacy" : "")
        return ""
    }
    function checkThemeSchedule() {
        if (!themeScheduleRuntimeEnabled || !activeThemeScheduleEnabled ||
            soledadSettings.visible) return
        const customPack = activeCustomThemePack
        const json = activeThemeScheduleSlotCount === 3 ?
            themeScheduleSlots3Json : themeScheduleSlots4Json
        const now = new Date()
        const selected = customPack
            ? ThemePack.active(customPack, activeThemeScheduleSlotCount, now)
            : ThemeSchedule.activeNow(json, activeThemeScheduleSlotCount, now)
        if (!selected) return
        const themeKey = customPack ? selected.memberIndex : selected.theme
        const key = selectedThemePackId + ":" + activeThemeScheduleSlotCount + ":" +
                    selected.index + ":" + selected.start + ":" + themeKey
        if (key === lastScheduledSlotKey) return
        // Usar las preferencias actuales del visor; no tocar ningún panel KDE.
        syncSettingsFromRoot()
        const member = customPack ? selected.member : null
        const slot = customPack ?
            (member.kind === "preset" ? scheduledThemeSlot(member.theme) :
                "pack:" + selected.memberIndex) : scheduledThemeSlot(selected.theme)
        if (!slot) {
            // Nunca reemplazar un tema faltante por otro distinto.
            return
        }
        if (soledadSettings.activateTheme(slot)) {
            lastScheduledSlotKey = key
            // El wallpaper simulado solo conoce los tres fondos integrados.
            // Un snapshot personal no cambia el wallpaper a otro arbitrario.
            if (!customPack || member.kind === "preset")
                requestWallpaperThemeChange(customPack ? member.theme : selected.theme)
        }
    }

    signal requestWallpaperThemeChange(string themeName)
    signal requestThematicWallpaperVisibilityChange(bool enabled)
    property bool thematicWallpaperEnabled: true
    // SOLO PRESENTACIÓN: ninguna interpolación escribe los perfiles originales.
    // Los colores efectivos son bindings separadas de las preferencias.
    property bool barColorPreviewActive: false
    property var barPreviewColors: ({})
    property bool themeColorsTransitionActive: false
    readonly property int themeColorsDurationMs:
        WallpaperFadeDuration.durationMs(wallpaperFadeAmount, wallpaperFadeUnit)
    Timer {
        id: themeColorsTimer
        interval: root.themeColorsDurationMs
        repeat: false
        onTriggered: root.themeColorsTransitionActive = false
    }
    function beginThemeColorTransition() {
        themeColorsTimer.stop()
        themeColorsTransitionActive = themeScheduleRuntimeEnabled && barThemeTransitionEnabled
        if (themeColorsTransitionActive) themeColorsTimer.start()
    }
    function startActualThemeColorTransition() {
        // La señal llega antes de aplicar el tema: conservar la imagen
        // saliente de SO para fundirla sobre la nueva, sin alterar geometría.
        if (themeScheduleRuntimeEnabled && barThemeTransitionEnabled)
            soButton.beginActualArtworkFade(themeColorsDurationMs)
        else soButton.clearArtworkPreview()
        beginThemeColorTransition()
        barColorPreviewActive = false
    }
    function cancelBarColorPreview() {
        themeColorsTimer.stop()
        themeColorsTransitionActive = false
        barColorPreviewActive = false
        soButton.clearArtworkPreview()
    }
    function previewArtworkFromTheme(info) {
        const mode = info.logoMode || ""
        let image = ""
        if (mode === "default") image = String(defaultSoLogo)
        else if (mode === "custom")
            image = info.assetFile ? Qt.resolvedUrl("assets/" + info.assetFile).toString()
                                   : String(info.filePath || "")
        if (mode !== "text" && !image.length) return null
        if (mode !== "text" && mode !== "default" && mode !== "custom")
            return null
        const frame = String(info.soButtonFrameShape || soButton.frameShape)
        const isGif = mode === "default" || image.toLowerCase().endsWith(".gif")
        return {
            mode: mode === "text" ? "text" : "image",
            image: image, animated: isGif,
            animationAllowed: info.enableGif !== false,
            shape: frame === "square" ? String(info.shape || soLogoShape) : frame,
            fit: String(info.cropFitMode || soLogoFitMode),
            zoom: info.cropZoom === undefined ? soLogoZoom : Number(info.cropZoom),
            panX: info.cropPanX === undefined ? soLogoPanX : Number(info.cropPanX),
            panY: info.cropPanY === undefined ? soLogoPanY : Number(info.cropPanY),
            rotation: info.cropRotation === undefined ? soLogoRotation : Number(info.cropRotation),
            label: String(info.soTextLabel || "SO"),
            textColor: String(info.soTextColor || "#ffffff"),
            textBackground: String(info.soTextBackground || "#192536"),
            textOpacity: info.soTextBackgroundOpacity === undefined ? 0.9
                : Number(info.soTextBackgroundOpacity),
            textBackgroundImage: info.assetTextFile ?
                Qt.resolvedUrl("assets/" + info.assetTextFile).toString() :
                String(info.soTextBackgroundImage || ""),
            textFont: String(info.soTextFontFamily || "Sans Serif"),
            textSize: Number(info.soTextFontSize || 13),
            textBold: info.soTextBold !== false
        }
    }
    function previewThemeAvailable(theme) {
        syncSettingsFromRoot()
        const slot = scheduledThemeSlot(theme)
        if (!slot) return false
        try {
            const info = JSON.parse(soledadSettings.slotJson(slot))
            return !!info && info.version === 1 &&
                   !!previewArtworkFromTheme(info)
        } catch (_) { return false }
    }
    function previewBarThemeColors(theme) {
        if (!themeScheduleRuntimeEnabled || soledadSettings.visible) return false
        // Solo lectura del snapshot, NO activateTheme(), applyChanges()
        // ni modificación de preferencias; no se supone ninguna paleta.
        syncSettingsFromRoot()
        const slot = scheduledThemeSlot(theme)
        if (!slot) return false
        let info
        try { info = JSON.parse(soledadSettings.slotJson(slot)) }
        catch (_) { return false }
        if (!info || info.version !== 1) return false
        const art = previewArtworkFromTheme(info)
        // Si la persona apaga el fundido de islas, SO cambia sin
        // interpolación aunque el wallpaper conserve su propia duración.
        const artDuration = barThemeTransitionEnabled ? themeColorsDurationMs : 1
        if (!art || !soButton.beginArtworkPreview(art,artDuration))
            return false
        const palette = {}
        const names = ["soledadColor","malvinaColor","soledadGradientEnd","soledadGradientThird","malvinaGradientEnd","malvinaGradientThird","trayButtonColor","gripButtonColor","taskFrameColor","launcherSwitchColor","soTextBackground","soTextColor"]
        for (const key of names) if (info[key] !== undefined && info[key] !== null)
            palette[key] = String(info[key])
        // Nombres reales del contrato themeSnapshot(), no renombrar perfiles.
        if (info.accentColor) palette.soActivityColor = String(info.accentColor)
        if (info.glowColor) palette.soActivityGlowColor = String(info.glowColor)
        if (info.clockTextColor) palette.soClockTextColor = String(info.clockTextColor)
        if (info.outlineConfig && typeof info.outlineConfig === "object") {
            for (const name of ["soledad","malvina","tray","grip"]) {
                const record = info.outlineConfig[name]
                if (record && record.color)
                    palette[name === "soledad" ? "outlineSo"
                        : "outline"+name.charAt(0).toUpperCase()+name.slice(1)] =
                        String(record.color)
            }
        }
        beginThemeColorTransition()
        barPreviewColors = palette
        barColorPreviewActive = true
        return true
    }
    property color displaySoledadColor:
        root.barColorPreviewActive && root.barPreviewColors.soledadColor !== undefined
        ? root.barPreviewColors.soledadColor : root.soledadColor
    Behavior on displaySoledadColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayMalvinaColor:
        root.barColorPreviewActive && root.barPreviewColors.malvinaColor !== undefined
        ? root.barPreviewColors.malvinaColor : root.malvinaColor
    Behavior on displayMalvinaColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoledadGradientEnd:
        root.barColorPreviewActive && root.barPreviewColors.soledadGradientEnd !== undefined
        ? root.barPreviewColors.soledadGradientEnd : root.soledadGradientEnd
    Behavior on displaySoledadGradientEnd {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoledadGradientThird:
        root.barColorPreviewActive && root.barPreviewColors.soledadGradientThird !== undefined
        ? root.barPreviewColors.soledadGradientThird : root.soledadGradientThird
    Behavior on displaySoledadGradientThird {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayMalvinaGradientEnd:
        root.barColorPreviewActive && root.barPreviewColors.malvinaGradientEnd !== undefined
        ? root.barPreviewColors.malvinaGradientEnd : root.malvinaGradientEnd
    Behavior on displayMalvinaGradientEnd {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayMalvinaGradientThird:
        root.barColorPreviewActive && root.barPreviewColors.malvinaGradientThird !== undefined
        ? root.barPreviewColors.malvinaGradientThird : root.malvinaGradientThird
    Behavior on displayMalvinaGradientThird {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoActivityColor:
        root.barColorPreviewActive && root.barPreviewColors.soActivityColor !== undefined
        ? root.barPreviewColors.soActivityColor : root.soActivityColor
    Behavior on displaySoActivityColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoActivityGlowColor:
        root.barColorPreviewActive && root.barPreviewColors.soActivityGlowColor !== undefined
        ? root.barPreviewColors.soActivityGlowColor : root.soActivityGlowColor
    Behavior on displaySoActivityGlowColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayTrayButtonColor:
        root.barColorPreviewActive && root.barPreviewColors.trayButtonColor !== undefined
        ? root.barPreviewColors.trayButtonColor : root.trayButtonColor
    Behavior on displayTrayButtonColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayGripButtonColor:
        root.barColorPreviewActive && root.barPreviewColors.gripButtonColor !== undefined
        ? root.barPreviewColors.gripButtonColor : root.gripButtonColor
    Behavior on displayGripButtonColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayTaskFrameColor:
        root.barColorPreviewActive && root.barPreviewColors.taskFrameColor !== undefined
        ? root.barPreviewColors.taskFrameColor : root.taskFrameColor
    Behavior on displayTaskFrameColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayLauncherSwitchColor:
        root.barColorPreviewActive && root.barPreviewColors.launcherSwitchColor !== undefined
        ? root.barPreviewColors.launcherSwitchColor : root.launcherSwitchColor
    Behavior on displayLauncherSwitchColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoTextBackground:
        root.barColorPreviewActive && root.barPreviewColors.soTextBackground !== undefined
        ? root.barPreviewColors.soTextBackground : root.soTextBackground
    Behavior on displaySoTextBackground {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoTextColor:
        root.barColorPreviewActive && root.barPreviewColors.soTextColor !== undefined
        ? root.barPreviewColors.soTextColor : root.soTextColor
    Behavior on displaySoTextColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displaySoClockTextColor:
        root.barColorPreviewActive && root.barPreviewColors.soClockTextColor !== undefined
        ? root.barPreviewColors.soClockTextColor : root.soClockTextColor
    Behavior on displaySoClockTextColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayOutlineSoColor:
        root.barColorPreviewActive && root.barPreviewColors.outlineSo !== undefined
        ? root.barPreviewColors.outlineSo : root.outlineConfig.soledad.color
    Behavior on displayOutlineSoColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayOutlineMalvinaColor:
        root.barColorPreviewActive && root.barPreviewColors.outlineMalvina !== undefined
        ? root.barPreviewColors.outlineMalvina : root.outlineConfig.malvina.color
    Behavior on displayOutlineMalvinaColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayOutlineTrayColor:
        root.barColorPreviewActive && root.barPreviewColors.outlineTray !== undefined
        ? root.barPreviewColors.outlineTray : root.outlineConfig.tray.color
    Behavior on displayOutlineTrayColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }
    property color displayOutlineGripColor:
        root.barColorPreviewActive && root.barPreviewColors.outlineGrip !== undefined
        ? root.barPreviewColors.outlineGrip : root.outlineConfig.grip.color
    Behavior on displayOutlineGripColor {
        enabled: root.themeColorsTransitionActive
        ColorAnimation { duration: root.themeColorsDurationMs; easing.type: Easing.InOutCubic }
    }

    property string gripShape: "rounded"
    property string trayButtonShape: "rounded"
    property bool taskActiveGlowEnabled: true
    property bool taskActiveDoubleBorderEnabled: false
    signal requestTaskActiveIndicatorChange(bool glowEnabled, bool doubleBorderEnabled)
    // Inicio nuevo: icono y nombre legibles; los ajustes guardados prevalecen.
    property string taskDisplayMode: "both" // text, both, icon
    // "both" conserva el funcionamiento actual y los ajustes personales.
    // Los modos "preview" y "chip" nunca dejan sin acceso al cierre.
    property string taskCloseMode: "both"
    property string taskFrameShape: "rounded"
    property color taskFrameColor: "#ffffff"
    property real taskFrameOpacity: 0.12
    property real taskFrameWidth: 1
    signal requestTaskDisplayModeChange(string mode)
    signal requestTaskCloseModeChange(string mode)
    signal requestTaskFrameChange(string shape, string color, real opacity, real width)
    // El visor usa el icono instalado que declara el archivo .desktop.
    // Si no hay icono, TaskAppIcon muestra una inicial legible.
    function demoIconForApp(name) {
        const label = String(name || "").trim().toLowerCase()
        if (!label.length) return ""
        for (let i = 0; i < localAppCatalog.length; ++i) {
            const entry = localAppCatalog[i]
            if (!entry || !entry.name) continue
            const candidate = String(entry.name).toLowerCase()
            if (candidate !== label &&
                !(label === "brave" && candidate.startsWith("brave ")))
                continue
            const source = String(entry.iconSource || entry.icon || "")
            if (source.length) return source
        }
        return label === "dolphin" ? "org.kde.dolphin" : ""
    }
    property var outlineConfig: ({"soledad":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"malvina":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"tray":{"style":"solid","width":1,"color":"#45647a","opacity":1},"grip":{"style":"solid","width":1,"color":"#45647a","opacity":1}})
    signal requestOutlineChange(var updated)
    signal requestIslandGradientChange(bool soEnabled, string soEnd, string soDirection,
                                       bool malEnabled, string malEnd, string malDirection,
                                       int soCount, string soThird, int malCount, string malThird)
    signal requestGradientBreathingChange(bool synchronizedWithSO, real intensity,
                                         bool breathingEnabled, real speed, bool syncIntensity)
    signal requestMalvinaGradientBreathingChange(bool synchronizedWithSO, real intensity,
                                                bool breathingEnabled, real speed)
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
    // Después de iniciar una búsqueda, ocultar Malvina por esta ocasión,
    // incluso en el ensayo "siempre visible". La opción original del
    // usuario no se modifica: vuelve tras un nuevo hover o atajo.
    property bool malvinaDismissedAfterSearch: false
    property bool malvinaDismissRearmed: false
    function dismissMalvinaAfterSearch() {
        malvinaSearch.closeSearch()
        malvinaRevealTimer.stop()
        malvinaHideTimer.stop()
        malvinaHoverRevealed = false
        // Si el puntero seguía en la isla, exigir salir antes de volver
        // a entrar para no reabrirla por el mismo movimiento.
        malvinaDismissRearmed = !malvinaHotspotHover.hovered
        malvinaDismissedAfterSearch = true
    }
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
    // Malvina puede mostrarse por ENCIMA de ventanas normales y
    // maximizadas. Fullscreen real prevalece: nunca revelarla sobre vídeo,
    // juego o presentación en pantalla completa. Un estado externo aún
    // desconocido bloquea por seguridad; la preferencia de autoocultamiento
    // sigue siendo independiente.
    property bool windowStateKnown: true  // true solo en visor simulado
    property bool previewFullscreen: false
    property bool hostMaximized: false
    property bool hostFullscreen: false
    readonly property bool autoRevealBlocked:
        !windowStateKnown || previewFullscreen || hostFullscreen
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
                closeInstalledLauncher()
                malvinaSearch.expanded = false
            }
        }
    }
    readonly property bool malvinaPopupActive:
        malvinaSearch.expanded ||
        (soledadSettings.visible && soledadSettings.currentTab === 0 &&
         soledadSettings.currentIslandSubtab === 2)
    readonly property bool malvinaActuallyVisible:
        !autoRevealBlocked && launcherIslandVisible &&
        !malvinaDismissedAfterSearch &&
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
            malvinaDismissedAfterSearch = false
            malvinaDismissRearmed = false
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
            if (!root.autoRevealBlocked && root.launcherIslandVisible &&
                    malvinaHotspotHover.hovered &&
                    (root.autoHideMalvina || root.malvinaDismissedAfterSearch)) {
                if (root.malvinaDismissedAfterSearch) {
                    if (!root.malvinaDismissRearmed) return
                    root.malvinaDismissedAfterSearch = false
                    root.malvinaDismissRearmed = false
                }
                if (root.autoHideMalvina) root.malvinaHoverRevealed = true
            }
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
    // Cajón de ventanas abiertas: permanece expandido al seleccionar.
    // Contracción opcional desde la casilla del menú de seis puntos.
    property bool autoCollapseSO: false
    // El launcher de instaladas siempre se cierra al elegir un programa.
    // Es independiente del cajón SO de ventanas abiertas y de Archivos.
    // Estado deseado, independiente de la visibilidad del Popup.Item.
    // Evita que cerrar accidentalmente el popup oculte también su ventana
    // física LayerShell y haga imposible recuperarlo tras perder foco.
    property bool launcherRequestedOpen: false
    function closeInstalledLauncher() {
        launcherRequestedOpen = false
        installedAppsPopup.close()
    }
    // Corrección del mantenedor 18/11: izquierdo = cajón (ventanas abiertas),
    // derecho = launcher de aplicaciones. Es reversible en Configuración.
    property bool soLeftClickOpensLauncher: true
    property bool soTooltipSuppressed: false
    // Estética del launcher heredada de Soledad; solo el interruptor
    // tiene opciones independientes, desactivadas por defecto.
    property int launcherCategoryLayout: 0  // A = original, B = panel a la izquierda
    property string launcherSwitchShape: "capsule"
    property bool launcherSwitchColorOverride: false
    property color launcherSwitchColor: "#010111"
    property int launcherMaxSlots: 20
    property bool launcherOpacityOverride: false
    property real launcherOpacity: 0.9
    property bool launcherIconsWithNames: true
    property bool malvinaOptionsOpacityOverride: false
    property real malvinaOptionsOpacity: 0.9
    property real launcherAvailableHeight: 450
    // Predeterminado seguro: solo una sesión nativa autorizada puede ejecutar apps.
    property bool realAppLaunchEnabled: false
    // Alojamiento exclusivo del ensayo LayerShell: otra ventana física
    // acotada, colocada debajo de SO por el compositor y NO por x/y de Popup.
    property var layerShellLauncherHost: null
    readonly property bool installedLauncherPopupVisible:
        (realAppLaunchEnabled && layerShellLauncherHost !== null)
            ? launcherRequestedOpen : installedAppsPopup.visible
    readonly property real installedLauncherPopupWidth: installedAppsPopup.width
    readonly property real installedLauncherPopupHeight: installedAppsPopup.height
    readonly property real installedLauncherScreenLeft: calculateInstalledLauncherScreenLeft()
    function calculateInstalledLauncherScreenLeft() {
        const fromSo = installedLauncherSource === "so" || !launcherIslandVisible
        return SoledadLauncherPlacement.screenLeft({
            popupWidth: installedAppsPopup.width,
            screenWidth: root.width,
            requirePositiveScreenWidth: true,
            fromSo: fromSo,
            systemIslandX: systemIsland.x,
            systemIslandWidth: systemIsland.width,
            launcherCenter: fromSo ? 0 : launcherIsland.mapToItem(
                root, launcherIsland.width / 2, 0).x,
            categoryLayout: installedAppsPopup.categoryLayout,
            showCategoryPanel: installedAppsPopup.showCategoryPanel,
            filesMode: installedAppsPopup.filesMode,
            expandedCanvas: installedAppsPopup.expandedCanvas,
            primaryWidth: installedAppsPopup.primaryWidth
        })
    }
    signal requestLaunchDesktopEntry(string desktopId)
    // Exclusivo de la prueba KDE real; no ejecutar sobre el panel instalado.
    signal requestRealTaskActivation(int taskRow, bool taskActive, string windowUuid)
    // Solo el prototipo LayerShell muestra miniaturas reales.
    signal requestRealTaskPreview(string windowUuid, string appLabel, real left)
    signal requestHideRealTaskPreview(string windowUuid)
    // Selector de grupo: segunda superficie LayerShell, nunca otra fila en SO.
    signal requestRealTaskGroup(var windowIds, string appLabel, real centerX)
    signal requestHideRealTaskGroup()
    // Cierre normal KDE, solo en el ensayo nativo y por UUID vigente.
    signal requestRealTaskClose(var windowUuids)
    property bool realTaskPreviewEnabled: false
    property bool realTaskActivationEnabled: false
    property bool realTaskActivationDispatched: false
    function activateRealTask(taskRow, appId, appName, taskActive, windowUuid) {
        selectRealTaskApp(appId, appName)
        if (!realTaskActivationEnabled || !usingRealTasks) return
        if (!Number.isInteger(taskRow) || taskRow < 0 ||
            taskRow >= realTaskModel.count) return
        realTaskActivationDispatched = false
        requestRealTaskActivation(taskRow, taskActive === true, String(windowUuid || ""))
        console.log("SmartBar SO selección ficha:", appName,
                    "solicitada =", realTaskActivationDispatched,
                    "autocontraer cajón =", autoCollapseSO,
                    "launcher =", launcherRequestedOpen)
        if (realTaskActivationDispatched && autoCollapseSO) {
            console.log("SmartBar SO cierre: ficha seleccionada con preferencia activa")
            soExpanded = false
        }
    }
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
    property color soledadGradientThird: "#ee9852"
    property int soledadGradientColorCount: 2
    property string soledadGradientDirection: "topBottom"
    // Cada isla puede respirar junto a SO o con fase/velocidad propias.
    // No se modifica el color luminoso ni la paleta al cambiar el ritmo.
    property bool soledadGradientBreathingEnabled: true
    property bool soledadGradientSyncBreathing: false
    property bool soledadGradientSyncIntensity: false
    property real soledadGradientBreathingIntensity: 0.6
    property real soledadGradientBreathingSpeed: 0.6
    property bool malvinaGradientBreathingEnabled: true
    property bool malvinaGradientSyncBreathing: false
    property real malvinaGradientBreathingIntensity: 0.6
    property real malvinaGradientBreathingSpeed: 0.6
    property real sharedBreathingPhase: 0
    property real soledadIndependentBreathingPhase: 0
    property real malvinaIndependentBreathingPhase: 0
    readonly property real soledadEffectiveBreathingIntensity:
        soledadGradientSyncIntensity ? soActivityPulseDepth : soledadGradientBreathingIntensity
    readonly property bool soledadGradientBreathingActive:
        root.visible && soledadGradientEnabled &&
        soledadGradientBreathingEnabled && soledadEffectiveBreathingIntensity > 0
    readonly property bool malvinaGradientBreathingActive:
        root.visible && malvinaActuallyVisible && malvinaGradientEnabled &&
        malvinaGradientBreathingEnabled && malvinaGradientBreathingIntensity > 0
    readonly property bool sharedBreathingActive:
        (soledadGradientBreathingActive && soledadGradientSyncBreathing) ||
        (malvinaGradientBreathingActive && malvinaGradientSyncBreathing)
    readonly property bool anyGradientBreathingActive:
        soledadGradientBreathingActive || malvinaGradientBreathingActive
    function breathingFactor(intensity, phase) {
        return SoledadBreathingMath.breathingFactor(intensity, phase)
    }
    readonly property real gradientBreathingFactor:
        soledadGradientBreathingActive
            ? breathingFactor(soledadEffectiveBreathingIntensity,
                soledadGradientSyncBreathing
                    ? sharedBreathingPhase : soledadIndependentBreathingPhase)
            : 1
    readonly property real malvinaGradientBreathingFactor:
        malvinaGradientBreathingActive
            ? breathingFactor(malvinaGradientBreathingIntensity,
                malvinaGradientSyncBreathing
                    ? sharedBreathingPhase : malvinaIndependentBreathingPhase)
            : 1
    Timer {
        id: synchronizedBreathingTimer
        interval: 50
        repeat: true
        running: root.anyGradientBreathingActive
        onTriggered: {
            const dt = interval / 1000
            if (root.sharedBreathingActive)
                root.sharedBreathingPhase = SoledadBreathingMath.nextPhase(
                    root.sharedBreathingPhase, root.soActivityPulseSpeed, dt)
            if (root.soledadGradientBreathingActive && !root.soledadGradientSyncBreathing)
                root.soledadIndependentBreathingPhase = SoledadBreathingMath.nextPhase(
                    root.soledadIndependentBreathingPhase,
                    root.soledadGradientBreathingSpeed, dt)
            if (root.malvinaGradientBreathingActive && !root.malvinaGradientSyncBreathing)
                root.malvinaIndependentBreathingPhase = SoledadBreathingMath.nextPhase(
                    root.malvinaIndependentBreathingPhase,
                    root.malvinaGradientBreathingSpeed, dt)
        }
    }
    property bool malvinaGradientEnabled: false
    property color malvinaGradientEnd: "#445577"
    property color malvinaGradientThird: "#445577"
    property int malvinaGradientColorCount: 2
    property string malvinaGradientDirection: "topBottom"
    property color backgroundColor: "#202333"
    property real soledadOpacity: 0.9
    property real malvinaOpacity: 0.9
    property real backgroundOpacity: 0.9
    property bool showBackground: false
    // Bandeja y agarre heredan Soledad salvo que la persona elija un
    // color y opacidad independientes para cada tipo de botón.
    property bool trayButtonColorOverride: false
    property color trayButtonColor: "#010111"
    property real trayButtonOpacity: 0.9
    property bool gripButtonColorOverride: false
    property color gripButtonColor: "#010111"
    property real gripButtonOpacity: 0.9
    readonly property color effectiveTrayButtonColor: trayButtonColorOverride
        ? displayTrayButtonColor : displaySoledadColor
    readonly property real effectiveTrayButtonOpacity: trayButtonColorOverride
        ? trayButtonOpacity : soledadOpacity
    readonly property color effectiveGripButtonColor: gripButtonColorOverride
        ? displayGripButtonColor : displaySoledadColor
    readonly property real effectiveGripButtonOpacity: gripButtonColorOverride
        ? gripButtonOpacity : soledadOpacity

    // El visor puede inyectar el TasksModel REAL ya probado en CachyOS.
    // Si es null, se mantiene intacta la simulación habitual. Este
    // componente NO crea modelos KDE ni ejecuta acciones sobre ventanas.
    // Estado real OBSERVADO en el visor Qt; aún sin autorizar movimiento
    // ni modificación de ventanas de KDE desde SO.
    property string realObservedAppId: ""
    property bool realObservedMaximized: false
    // Última aplicación EXTERNA, conservada aunque qml6 reciba foco.
    // Solo cambia posiciones del visor Qt, no ventanas KDE.
    property string realTrackedAppId: ""
    property string realTrackedAppName: ""
    // Elegir ficha REAL en SO selecciona destino para recordar; nunca
    // activa la ventana KDE ni modifica su estado.
    property string realSelectedAppId: ""
    property string realSelectedAppName: ""
    function selectRealTaskApp(appId, appName) {
        if (!demoWindowControlsEnabled || !usingRealTasks) return
        realSelectedAppId = typeof appId === "string" ? appId.trim() : ""
        realSelectedAppName = typeof appName === "string" && appName.length > 0
            ? appName : "(aplicación sin nombre)"
        console.log("SO perfil elegido:", realSelectedAppName,
                    realSelectedAppId, "(sin activar ventanas KDE)")
    }
    onRealTrackedAppIdChanged: {
        // Al enfocar otra app REAL, liberar una selección anterior.
        // Pasar a qml6 no cambia realTrackedAppId: se conserva Steam.
        if (realSelectedAppName.length > 0 && realTrackedAppId.length > 0 &&
            realTrackedAppId !== realSelectedAppId) {
            realSelectedAppId = ""
            realSelectedAppName = ""
        }
    }
    onUsingRealTasksChanged: {
        if (!usingRealTasks) {
            realSelectedAppId = ""
            realSelectedAppName = ""
        } else {
            // En modo real no mostrar controles de maximización ficticios.
            previewMaximized = false
            previewFullscreen = false
        }
    }
    property bool realTrackedMaximized: false
    property bool realTrackedFullscreen: false
    property bool realTrackedKnown: false
    // Observación separada del foco: sigue habiendo una ventana MAXIMIZADA
    // aunque el usuario cambie a una ventana normal o al propio menú.
    property bool realAnyVisibleMaximized: false
    property string realPositionProfilesJson: "{}"
    // La referencia general tiene prioridad por debajo de los perfiles por app.
    // En el visor histórico no se escribe ni se habilita por sí sola.
    property real generalSoledadOffset: 0
    signal requestGeneralSoledadOffsetChange(real offset)
    signal requestRealPositionProfilesChange(string json)
    function saveGeneralSoledadPosition() {
        if (!usingRealTasks || !demoWindowControlsEnabled ||
            positionMode !== "right" || draggingIslandGrip) return
        requestGeneralSoledadOffsetChange(islandOffset)
        console.log("SmartBar: posición general solicitada", islandOffset)
    }
    function storeRealPositionFor(appId, offset) {
        if (!usingRealTasks || !demoWindowControlsEnabled || positionMode !== "right") return
        const next = SoledadPositionProfiles.saveProfile(
            realPositionProfilesJson, appId, offset, maxIslandOffset)
        if (next !== null) requestRealPositionProfilesChange(next)
    }
    function forgetRealPositionFor(appId) {
        if (!usingRealTasks || !demoWindowControlsEnabled || positionMode !== "right") return
        const next = SoledadPositionProfiles.removeProfile(realPositionProfilesJson, appId)
        if (next !== null) requestRealPositionProfilesChange(next)
    }
    readonly property var realProfileTarget: RealActiveWindow.profileTarget(
        realSelectedAppId, realSelectedAppName,
        { appId: realTrackedAppId, appName: realTrackedAppName,
          maximized: realTrackedMaximized, fullscreen: realTrackedFullscreen,
          known: realTrackedKnown })
    readonly property bool realProfileContextReady:
        demoWindowControlsEnabled && usingRealTasks &&
        positionMode === "right" &&
        SoledadPositionProfiles.validAppId(realProfileTarget.appId).length > 0
    readonly property bool realProfileExists:
        demoWindowControlsEnabled && usingRealTasks &&
        positionMode === "right" && realProfileTarget.appId.length > 0 &&
        Object.prototype.hasOwnProperty.call(
            SoledadPositionProfiles.readProfiles(realPositionProfilesJson),
            realProfileTarget.appId)
    // «Volver a posición» debe consultar la aplicación EXTERNA activa,
    // no una ficha de SO seleccionada anteriormente ni el foco del popup.
    readonly property bool activeRealAppHasSavedPosition:
        demoWindowControlsEnabled && usingRealTasks &&
        positionMode === "right" && realTrackedKnown &&
        !realTrackedFullscreen &&
        realTrackedAppId.length > 0 &&
        Object.prototype.hasOwnProperty.call(
            SoledadPositionProfiles.readProfiles(realPositionProfilesJson),
            realTrackedAppId)
    function applyRealPositionProfile() {
        if (!demoWindowControlsEnabled || !usingRealTasks ||
            positionMode !== "right" || gripDrag.active) return
        // El retorno al escritorio normal tiene prioridad por encima de
        // cualquier perfil guardado (incluido el general y Brave/Steam).
        // No interpretar fullscreen como escritorio normal.
        if (realTrackedFullscreen) return
        if (!realAnyVisibleMaximized) {
            if (autoReturnRight) {
                setIslandOffset(0)
                alignRightSelected = true
                ensureExpansionFits()
            }
            return
        }
        // Si otra maximizada sigue detrás, su posición la elige el
        // observador de KWin según StackingOrder, NO el foco normal.
        if (!realTrackedKnown || !realTrackedMaximized) return
        const next = SoledadPositionProfiles.resolveForApp(
            realPositionProfilesJson, realTrackedAppId, true,
            generalSoledadOffset, maxIslandOffset)
        setIslandOffset(next)
        alignRightSelected = next === 0
        ensureExpansionFits()
    }
    function saveRealPositionProfile() {
        if (!realProfileContextReady) return
        storeRealPositionFor(realProfileTarget.appId, islandOffset)
    }
    function deleteRealPositionProfile() {
        if (!realProfileExists) return
        forgetRealPositionFor(realProfileTarget.appId)
        applyRealPositionProfile()
    }
    onRealPositionProfilesJsonChanged: {
        if (usingRealTasks && !gripDrag.active)
            applyRealPositionProfile()
    }
    onGeneralSoledadOffsetChanged: {
        if (usingRealTasks && !gripDrag.active && !realTrackedFullscreen)
            applyRealPositionProfile()
    }
    property var realTaskModel: null
    readonly property bool usingRealTasks: realTaskModel !== null
    property bool demoHasRunningWindows: true
    // Controles interactivos solamente en el visor Qt; el plasmoide real
    // mantiene sus fichas simuladas pasivas y su TaskManager solo lectura.
    property bool demoWindowControlsEnabled: false
    // Solo un popup de previsualización FICTICIA puede quedar abierto.
    // Estado efímero: nunca se guarda en temas ni preferencias.
    property string activeDemoPreviewApp: ""
    property var demoOpenedApps: demoApps.slice()
    // Estado efímero de ventanas ficticias; dos Dolphin simuladas para ensayo.
    property var demoWindowInstances: DemoWindowInstances.initial()
    // Cada aplicación FICTICIA tiene su silencio independiente. No representa
    // flujos reales de PipeWire: no mutear dispositivos globales del usuario.
    property var demoMutedApps: ({})
    // Valores de muestra por aplicación, independientes del sonido real.
    // La vista previa y su ficha agrupada leen el mismo estado.
    property var demoAppVolumes: ({})
    // Historial de cierres SOLO del simulador; no implica reabrir programas
    // reales ni recuperar documentos de aplicaciones externas.
    property var demoClosedHistory: []
    readonly property int soWindowCount: usingRealTasks
        ? realTaskModel.count
        : (demoHasRunningWindows ? demoOpenedApps.length : 0)
    // Con cero ventanas, el brillo atrae la atención hacia el lanzador.
    // Con ventanas abiertas, permanece apagado por defecto.
    property string soActivityStyle: "breathe"  // off, steady, orbit
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
    property real soActivityPulseSpeed: 0.3
    property real soActivityPulseDepth: 0.7
    property bool soActivityGlowGradient: true
    // KDE puede reconstruir momentáneamente TasksModel al activar una
    // ventana. No tratar ese cero transitorio como orden de contraer SO.
    Timer {
        id: verifyEmptySoModel
        interval: 450
        repeat: false
        onTriggered: {
            if (root.soWindowCount !== 0 || !root.soExpanded ||
                (root.demoWindowControlsEnabled && !root.usingRealTasks)) return
            console.log("SmartBar SO cierre: modelo estable sin ventanas")
            root.soExpanded = false
        }
    }
    onSoWindowCountChanged: {
        console.log("SmartBar SO conteo:", soWindowCount,
                    "expandido =", soExpanded)
        if (soWindowCount === 0) verifyEmptySoModel.restart()
        else verifyEmptySoModel.stop()
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

    // Preferencia local del prototipo: ensanchar nombres SO sin achicar fuente.
    // Solo cambia ancho horizontal y se guarda al soltar el separador.
    QtCore.Settings {
        id: taskWidthSettings
        category: "plasma-smartbar-v01-task-chip-width"
    }
    property int taskNameExtraWidth: Math.max(0, Math.min(160,
        Number(taskWidthSettings.value("extraWidth", 0)) || 0))
    property real taskResizeStartX: 0
    property int taskResizeStartWidth: 0
    property int taskResizeChipCount: 1
    function updateTaskNameExtraWidth(value) {
        const count = usingRealTasks ? realTaskModel.count : demoOpenedApps.length
        taskNameExtraWidth = SoledadTaskSizing.resizedExtraWidth(
            taskNameExtraWidth, value, count, availableIslandWidth,
            naturalIslandWidth)
    }
    function saveTaskNameExtraWidth() {
        taskWidthSettings.setValue("extraWidth", taskNameExtraWidth)
        taskWidthSettings.sync()
    }
    property bool soExpanded: false
    onSoExpandedChanged: console.log("SmartBar SO cambio cajón:",
                                     soExpanded ? "abierto" : "cerrado",
                                     "autocontraer =", autoCollapseSO,
                                     "ventanas =", soWindowCount,
                                     "launcher =", launcherRequestedOpen)
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
    // Observación de solo lectura para ensayos externos de posición:
    // nunca aplicar cambios automáticos durante un arrastre del agarre.
    readonly property bool draggingIslandGrip: gripDrag.active
    property real offsetAtDragStart: 0
    // Solo para una ventana LayerShellQt ACOTADA que se mueve durante
    // el agarre. El visor principal y el plasmoide mantienen el cálculo
    // original: no alterar funcionalidad probada ni posiciones guardadas.
    property bool layerShellDragCompensation: false
    property real layerShellDragSceneStartX: 0
    property string lastDemoSelection: ""
    // Ensayo local aislado: sin control de ventanas KDE ni cambios de temas.
    property string demoPositionProfilesJson: "{}"
    signal requestDemoPositionProfilesChange(string json)
    readonly property bool demoProfileContextReady:
        demoWindowControlsEnabled && !usingRealTasks && previewMaximized &&
        positionMode === "right" && lastDemoSelection.length > 0 &&
        demoOpenedApps.indexOf(lastDemoSelection) >= 0
    readonly property bool demoProfileExists: demoProfileContextReady &&
        Object.prototype.hasOwnProperty.call(
            SoledadPositionProfiles.readProfiles(demoPositionProfilesJson),
            lastDemoSelection)
    function applyDemoPositionProfile() {
        if (!demoWindowControlsEnabled || usingRealTasks ||
            positionMode !== "right") return
        const next = SoledadPositionProfiles.resolveOffset(
            demoPositionProfilesJson, lastDemoSelection,
            lastDemoSelection.length > 0 &&
                demoOpenedApps.indexOf(lastDemoSelection) >= 0,
            previewMaximized, 0, maxIslandOffset)
        setIslandOffset(next)
        alignRightSelected = next === 0
        ensureExpansionFits()
    }
    function saveDemoPositionProfile() {
        if (!demoProfileContextReady) return
        const updated = SoledadPositionProfiles.saveProfile(
            demoPositionProfilesJson, lastDemoSelection, islandOffset, maxIslandOffset)
        if (updated !== null) requestDemoPositionProfilesChange(updated)
    }
    function deleteDemoPositionProfile() {
        if (!demoProfileExists) return
        const updated = SoledadPositionProfiles.removeProfile(
            demoPositionProfilesJson, lastDemoSelection)
        if (updated !== null) {
            requestDemoPositionProfilesChange(updated)
            setIslandOffset(0)
            alignRightSelected = true
        }
    }
    // Responder al cambio de ficha desde QML, sin acoplar el modelo
    // de ventanas ficticias a los perfiles. La prueba aislada puede
    // ejecutar closeDemoWindow sin depender de propiedades del visor.
    onLastDemoSelectionChanged: {
        if (demoWindowControlsEnabled && !usingRealTasks && previewMaximized)
            applyDemoPositionProfile()
    }
    onDemoPositionProfilesJsonChanged: {
        if (demoProfileContextReady && !gripDrag.active)
            applyDemoPositionProfile()
    }
    readonly property var demoApps: ["Dolphin", "Konsole", "Brave"]
    // Las fichas abiertas son un estado temporal y reversible del visor.
    // Nunca se guardan como preferencias ni afectan a las tareas reales.
    function demoInstancesForApp(appName) {
        return DemoWindowInstances.forApp(demoWindowInstances, appName)
    }
    // Fachada pública sin cambios: la política de audio ficticio vive en
    // DemoAudioState.js; aquí se conservan los controles de acceso del visor.
    function demoAppVolume(appName) {
        return DemoAudioState.volume(demoAppVolumes, appName)
    }
    function setDemoAppVolume(appName, value) {
        if (!demoWindowControlsEnabled || usingRealTasks ||
            !demoHasRunningWindows || demoOpenedApps.indexOf(appName) < 0)
            return false
        const result = DemoAudioState.setVolume(
            demoMutedApps, demoAppVolumes, appName, value)
        demoAppVolumes = result.volumes
        demoMutedApps = result.muted
        return true
    }
    function demoAppIsMuted(appName) {
        return DemoAudioState.isMuted(demoMutedApps, demoAppVolumes, appName)
    }
    function toggleDemoAppMute(appName) {
        if (!demoWindowControlsEnabled || usingRealTasks ||
            !demoHasRunningWindows || demoOpenedApps.indexOf(appName) < 0)
            return false
        const result = DemoAudioState.toggleMute(
            demoMutedApps, demoAppVolumes, appName)
        demoMutedApps = result.muted
        // Mantener la señal de cambio de volumen solo cuando cambia el nivel.
        if (result.volumes !== demoAppVolumes)
            demoAppVolumes = result.volumes
        return true
    }
    function openDemoWindow(appName) {
        if (!demoWindowControlsEnabled || usingRealTasks) return false
        const updated = DemoWindows.open(demoOpenedApps, demoApps, appName)
        if (updated.length === demoOpenedApps.length && demoHasRunningWindows)
            return false
        demoWindowInstances = DemoWindowInstances.reopen(demoWindowInstances, appName)
        // Una nueva app ficticia comienza con sonido simulado habilitado.
        const muted = Object.assign({}, demoMutedApps)
        delete muted[appName]
        demoMutedApps = muted
        const volumes = Object.assign({}, demoAppVolumes)
        delete volumes[appName]
        demoAppVolumes = volumes
        demoOpenedApps = updated
        demoHasRunningWindows = true
        return true
    }
    function closeDemoWindow(appName) {
        if (!demoWindowControlsEnabled || usingRealTasks ||
            !demoHasRunningWindows) return false
        const updated = DemoWindows.close(demoOpenedApps, appName)
        if (updated.length === demoOpenedApps.length) return false
        const record = DemoWindowInstances.snapshot(demoWindowInstances, appName)
        if (record) demoClosedHistory = demoClosedHistory.concat([record])
        demoWindowInstances = DemoWindowInstances.withoutApp(demoWindowInstances, appName)
        const muted = Object.assign({}, demoMutedApps)
        delete muted[appName]
        demoMutedApps = muted
        const volumes = Object.assign({}, demoAppVolumes)
        delete volumes[appName]
        demoAppVolumes = volumes
        demoOpenedApps = updated
        if (lastDemoSelection === appName) lastDemoSelection = ""
        return true
    }
    // Cierre individual solo de muestra, nunca KDE/KWin.
    function closeDemoWindowInstance(appName, windowId) {
        if (!demoWindowControlsEnabled || usingRealTasks ||
            !demoHasRunningWindows || demoOpenedApps.indexOf(appName) < 0)
            return false
        const current = demoInstancesForApp(appName)
        if (!current.some(item => item.id === windowId)) return false
        if (current.length === 1) return closeDemoWindow(appName)
        const record = DemoWindowInstances.snapshot(demoWindowInstances, appName, windowId)
        if (record) demoClosedHistory = demoClosedHistory.concat([record])
        demoWindowInstances = DemoWindowInstances.close(demoWindowInstances, appName, windowId)
        return true
    }
    function reopenNextDemoWindow() {
        if (!demoWindowControlsEnabled || usingRealTasks) return false
        if (!demoHasRunningWindows) {
            demoClosedHistory = []
            demoMutedApps = ({})
            demoAppVolumes = ({})
            demoWindowInstances = DemoWindowInstances.initial()
            demoOpenedApps = demoApps.slice()
            demoHasRunningWindows = true
            return true
        }
        // Prioridad: deshacer el ÚLTIMO cierre individual. Una app con otra
        // ventana abierta (Dolphin) debe poder recuperar la segunda tarjeta.
        if (demoClosedHistory.length > 0) {
            const record = demoClosedHistory[demoClosedHistory.length - 1]
            demoWindowInstances = DemoWindowInstances.restore(demoWindowInstances, record)
            if (demoOpenedApps.indexOf(record.appName) < 0)
                demoOpenedApps = DemoWindows.open(demoOpenedApps, demoApps, record.appName)
            demoClosedHistory = demoClosedHistory.slice(0, -1)
            demoHasRunningWindows = true
            return true
        }
        const next = DemoWindows.firstClosed(demoOpenedApps, demoApps)
        return next.length > 0 && openDemoWindow(next)
    }
    readonly property var demoTray: SystemTrayModel.demoEntries()
    // Menú de muestra: NO representa las aplicaciones instaladas todavía.
    readonly property var demoInstalledApps: ["Dolphin", "Konsole", "Brave", "Firefox", "Configuración"]
    property bool soHoldTriggered: false
    // Origen del lanzador compartido: cada isla lo abre debajo de sí misma.
    property string installedLauncherSource: "so"

    // Reservar siempre espacio para la expansión MÁS ancha; abrir bandeja o SO
    // no debe empujar el agarre ni SO, aun después de un arrastre.
    // Ensayos de ventanas externas: reserva inyectada desde una lectura KDE
    // de solo lectura. Por defecto es 0: visor y plasmoide NO cambian.
    property real externalWindowControlsReserve: 0
    readonly property real controlsReservation: Math.max(
        root.previewMaximized ? windowControls.width + 6 : 0,
        Math.max(0, root.externalWindowControlsReserve))
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
    // Ancho efectivo de Malvina para las máscaras nativas de entrada
    // experimentales; solo lectura, no cambia geometría ni preferencias.
    // Solo el ensayo LayerShell puede indicar el ancho externo disponible
    // para el menú Web/IA; con 0 se conserva el visor/plasmoide actual.
    property real malvinaOptionsViewportWidth: 0
    readonly property real actualMalvinaWidth: malvinaHotspot.width
    readonly property real actualMalvinaHeight: malvinaHotspot.height
    // Las dos superficies Popup de Malvina son el editor y Web/IA.
    // Coordenadas respecto del contenido compartido; los límites nativos
    // recortarán su máscara a la ventana visible, sin bloquear el resto.
    readonly property real malvinaFieldInputX:
        malvinaHotspot.x + malvinaSearch.x + malvinaSearch.fieldRegionX
    readonly property real malvinaFieldInputY:
        malvinaHotspot.y + malvinaSearch.y + malvinaSearch.fieldRegionY
    readonly property real malvinaFieldInputWidth: malvinaSearch.fieldRegionWidth
    readonly property real malvinaFieldInputHeight: malvinaSearch.fieldRegionHeight
    readonly property real malvinaOptionsInputX:
        malvinaHotspot.x + malvinaSearch.x + malvinaSearch.optionsRegionX
    readonly property real malvinaOptionsInputY:
        malvinaHotspot.y + malvinaSearch.y + malvinaSearch.optionsRegionY
    readonly property real malvinaOptionsInputWidth: malvinaSearch.optionsRegionWidth
    readonly property real malvinaOptionsInputHeight: malvinaSearch.optionsRegionHeight
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
        if (positionMode === "center") {
            alignCenterNow()
        } else if (activeRealAppHasSavedPosition) {
            // Si Brave/Steam sigue maximizada, «volver» equivale al anclaje
            // guardado de ESA aplicación; el extremo derecho físico solo
            // corresponde al escritorio general o a apps sin perfil.
            soExpanded = false
            trayExpanded = false
            applyRealPositionProfile()
            console.log("SmartBar v0.1: restaurada posición de",
                        realTrackedAppName, "(perfil real)")
        } else if (usingRealTasks && positionMode === "right") {
            setIslandOffset(generalSoledadOffset)
            alignRightSelected = islandOffset === 0
        } else {
            alignRightNow()
        }
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

        if (value && demoWindowControlsEnabled && !usingRealTasks &&
            lastDemoSelection.length > 0)
            applyDemoPositionProfile()
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
        // La política es independiente de QML, bandeja y ventanas KDE.
        // Aplicar únicamente cambios reales evita repintados innecesarios.
        const next = SoledadExpansionPolicy.fit({
            centeredPresentation: centeredPresentation,
            soExpanded: soExpanded,
            trayExpanded: trayExpanded,
            lastExpandedMode: lastExpandedMode,
            naturalIslandWidth: naturalIslandWidth,
            physicalIslandLimit: physicalIslandLimit,
            systemIslandX: systemIsland.x,
            systemIslandWidth: systemIsland.width,
            leftReserved: leftReserved,
            rightReserved: rightReserved,
            width: root.width,
            availableIslandWidth: availableIslandWidth
        })
        if (next.soExpanded !== soExpanded) soExpanded = next.soExpanded
        if (next.trayExpanded !== trayExpanded) trayExpanded = next.trayExpanded
        if (next.centeredOverflow)
            console.warn("Soledad: expansion centrada fuera de limites; contraida")
    }

    function toggleOpenWindowsFromSO() {
        // El selector de ventanas y el lanzador son independientes.
        // Un clic con launcher visible cierra SOLO el launcher. Nunca
        // debe alternar al mismo tiempo la lista de ventanas abiertas.
        if (installedAppsPopup.visible || launcherRequestedOpen) {
            console.log("SmartBar SO: launcher cerrado desde botón; cajón sin cambios")
            closeInstalledLauncher()
            return
        }
        // No enviar al lanzador por falta de ventanas: el gesto elegido
        // para "ventanas abiertas" conserva su significado.
        if (soWindowCount === 0 &&
            !(demoWindowControlsEnabled && !usingRealTasks)) {
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

    function triggerSOButton(leftClick, wasOpenAtPress) {
        console.log("SmartBar SO botón:", leftClick ? "izquierdo" : "derecho",
                    "launcher =", launcherRequestedOpen,
                    "cajón =", soExpanded,
                    "mapeo launcher izquierdo =", soLeftClickOpensLauncher)
        // Launcher y cajón SO no comparten la operación de selección.
        if (!leftClick && installedLauncherSource === "so" &&
            (installedAppsPopup.visible || launcherRequestedOpen)) {
            closeInstalledLauncher()
            return
        }
        const launch = leftClick === soLeftClickOpensLauncher
        if (launch) {
            // El estado se captura al PRESIONAR; un CloseOnPressOutside
            // no puede transformar el mismo gesto de cierre en reapertura.
            if (wasOpenAtPress)
                closeInstalledLauncher()
            else
                openInstalledLauncher("so")
        } else {
            toggleOpenWindowsFromSO()
        }
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
        onActivated: {
            root.superKeyPending = false
            malvinaSearch.focusSearch()
        }
    }
    function openInstalledLauncher(source) {
        // El launcher de aplicaciones instaladas pertenece SOLO a Soledad.
        // Malvina conserva su buscador web/IA, pero nunca abre este popup.
        if (source === "malvina") return
        const requestedSource = "so"
        // Un segundo clic sobre SO cierra el popup existente.
        if ((installedAppsPopup.visible || launcherRequestedOpen) &&
            installedLauncherSource === requestedSource) {
            closeInstalledLauncher()
            return
        }
        installedLauncherSource = requestedSource
        launcherRequestedOpen = true
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
        closeInstalledLauncher()
        const next = SystemTrayController.toggle(trayExpanded, lastExpandedMode)
        lastExpandedMode = next.lastExpandedMode
        trayExpanded = next.expanded
        // Si hay espacio, SO permanece abierto: sin autocontracción cruzada.
        if (next.ensureFits) ensureExpansionFits()
    }

    function selectDemoApp(appName) {
        if (usingRealTasks || !demoHasRunningWindows ||
            demoOpenedApps.indexOf(appName) < 0) return
        lastDemoSelection = appName
        if (previewMaximized) applyDemoPositionProfile()
        // Elegir ficha: mantener abierto solo si la preferencia lo pide.
        if (autoCollapseSO) {
            soExpanded = false
        }
        console.log("Soledad: ficha simulada", appName,
                    "autocontraer SO =", autoCollapseSO,
                    "(sin controlar ventanas reales)")
    }

    function selectDemoTray(iconName) {
        // El módulo decide la contracción sin tocar SO ni aplicaciones.
        // Todavía son indicadores SIMULADOS, sin acciones sobre KDE.
        trayExpanded = SystemTrayController.afterIconSelection(
            trayExpanded, autoCollapseTray)
        console.log("Soledad: icono de bandeja simulado", iconName,
                    "autocontraer bandeja =", autoCollapseTray,
                    "(sin acciones reales)")
    }

    onMaxIslandOffsetChanged: setIslandOffset(islandOffset)

    // Mismo mapeo de preferencias que el diálogo de configuración.
    // Reutilizado por el reloj sin abrir nuevas ventanas ni tocar panel KDE.
    // Captura local sin controles en la UI: se usa únicamente desde el
    // comando de mantenimiento, antes de sellar el Día oficial.
    function snapshotFromLiveAppearance() {
        syncSettingsFromRoot()
        return soledadSettings.themeSnapshot()
    }

    function syncSettingsFromRoot() {
        soledadSettings.logoMode = root.soLogoMode
        soledadSettings.themeDayJson = root.themeDayJson
        soledadSettings.themeDayPreviousJson = root.themeDayPreviousJson
        soledadSettings.themeNightJson = root.themeNightJson
        soledadSettings.themeCustomJson = root.themeCustomJson
        soledadSettings.themeLibraryJson = root.themeLibraryJson
        soledadSettings.themePackLibraryJson = root.themePackLibraryJson
        soledadSettings.selectedThemePackId = root.selectedThemePackId
        soledadSettings.playaScheduleEnabled = root.themeScheduleEnabled
        soledadSettings.playaScheduleSlotCount = root.themeScheduleSlotCount
        soledadSettings.themeScheduleEnabled = root.activeThemeScheduleEnabled
        soledadSettings.themeScheduleSlotCount = root.activeThemeScheduleSlotCount
            soledadSettings.themeScheduleSlots3Json = root.themeScheduleSlots3Json
            soledadSettings.themeScheduleSlots4Json = root.themeScheduleSlots4Json
        soledadSettings.barThemeTransitionEnabled = root.barThemeTransitionEnabled
        soledadSettings.wallpaperFadeAmount = root.wallpaperFadeAmount
        soledadSettings.wallpaperFadeUnit = root.wallpaperFadeUnit
        soledadSettings.thematicWallpaperEnabled = root.thematicWallpaperEnabled
        soledadSettings.personalDefaultAvailable = root.personalDefaultAvailable
        soledadSettings.favoriteAppearanceAvailable = root.favoriteAppearanceAvailable
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
        soledadSettings.malvinaBrowserId = root.malvinaBrowserId
        soledadSettings.malvinaBrowserChoices = root.malvinaBrowserChoices
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
        soledadSettings.taskCloseMode = root.taskCloseMode
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
        soledadSettings.soledadGradientThird = root.soledadGradientThird
        soledadSettings.soledadGradientColorCount = root.soledadGradientColorCount
        soledadSettings.soledadGradientDirection = root.soledadGradientDirection
        soledadSettings.soledadGradientSyncBreathing = root.soledadGradientSyncBreathing
        soledadSettings.soledadGradientSyncIntensity = root.soledadGradientSyncIntensity
        soledadSettings.soledadGradientBreathingEnabled = root.soledadGradientBreathingEnabled
        soledadSettings.soledadGradientBreathingIntensity = root.soledadGradientBreathingIntensity
        soledadSettings.soledadGradientBreathingSpeed = root.soledadGradientBreathingSpeed
        soledadSettings.malvinaGradientSyncBreathing = root.malvinaGradientSyncBreathing
        soledadSettings.malvinaGradientBreathingEnabled = root.malvinaGradientBreathingEnabled
        soledadSettings.malvinaGradientBreathingIntensity = root.malvinaGradientBreathingIntensity
        soledadSettings.malvinaGradientBreathingSpeed = root.malvinaGradientBreathingSpeed
        soledadSettings.malvinaGradientEnabled = root.malvinaGradientEnabled
        soledadSettings.malvinaGradientEnd = root.malvinaGradientEnd
        soledadSettings.malvinaGradientThird = root.malvinaGradientThird
        soledadSettings.malvinaGradientColorCount = root.malvinaGradientColorCount
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
    }

    function openSoledadSettings(tabIndex, islandSubtabIndex) {
        root.cancelBarColorPreview()
        // Un solo centro. Leer valores guardados al abrir, no al cambiar
        // pestaña ni al pulsar Aplicar: la ventana permanece visible.
        if (!soledadSettings.visible) {
            root.syncSettingsFromRoot()
            soledadSettings.currentTab = tabIndex
            soledadSettings.refreshOutlinePreview()
            // Leer el estado completo SOLO tras cargar las 139 preferencias del
            // modelo. Cancelar/X no toca KConfig ni el perfil local guardado.
            soledadSettings.captureSettingsBaseline()
        }
        // Engranaje SO → portada Temas; engranaje Malvina → sus buscadores.
        // Nunca reutilizar la pestaña de otra isla que quedó abierta antes.
        if (islandSubtabIndex === 2)
            soledadSettings.showMalvinaProviders()
        else if (tabIndex === 0)
            soledadSettings.showThemes()
        else
            soledadSettings.currentTab = tabIndex
        // Si el usuario la minimizó para probar Malvina, el engranaje
        // recupera la misma ventana y conserva sus cambios ya aplicados.
        if (soledadSettings.visibility === Window.Minimized)
            soledadSettings.showNormal()
        else
            soledadSettings.show()
        soledadSettings.raise()
        soledadSettings.requestActivate()
    }

    SoledadSettings {
        id: soledadSettings
        // Al cerrar el editor, ejecutar enseguida la franja vigente si el
        // usuario eligió Playa 24hs automático; no esperar al siguiente tick.
        onVisibleChanged: {
            if (!visible && root.activeThemeScheduleEnabled && root.themeScheduleRuntimeEnabled)
                Qt.callLater(function() { root.checkThemeSchedule() })
        }
        onSettingsApplied: {
            root.requestPersistCurrentSettings()
            if (root.runtimeAppearanceEnabled) {
                // Registrar el intento incluso si un cambio no llega al disco.
                // No imprimir el perfil privado, URL, logos ni colores.
                const diff = RuntimeAppearance.captureChanges(soledadSettings)
                const unmanaged = RuntimeAppearance.unmappedChanges(soledadSettings)
                const count = Object.keys(diff).length
                console.log("SmartBar Aplicar: intento de persistencia",
                            "baseline=" + soledadSettings.baselineLoaded,
                            "claves=" + count,
                            "sinIntegrar=" + unmanaged.length,
                            "opacidadSO=" + soledadSettings.soledadOpacity,
                            "opacidadMalvina=" + soledadSettings.malvinaOpacity)
                if (!soledadSettings.baselineLoaded) {
                    soledadSettings.runtimeApplyFailed = true
                    soledadSettings.runtimeApplyNote =
                        "No se pudo verificar el estado previo; abrí otra vez Configuración."
                    console.warn("SmartBar Aplicar: sin línea base, no confirmar guardado")
                    return
                }
                soledadSettings.runtimeApplyFailed = false
                soledadSettings.runtimeApplyNote = ""
                if (count > 0) {
                    root.runtimeLastAppearanceCommitOk = false
                    root.requestRuntimeAppearancePatch(JSON.stringify(diff))
                    if (root.runtimeLastAppearanceCommitOk) {
                        // Efecto INMEDIATO además de sincronizar ambos procesos:
                        // el usuario no debe esperar el siguiente timer.
                        RuntimeAppearance.applyToBar(root, diff)
                        console.log("SmartBar Aplicar confirmado:", count,
                                    "preferencias de interfaz")
                    } else {
                        soledadSettings.runtimeApplyFailed = true
                        soledadSettings.runtimeApplyNote =
                            "No se pudo guardar la apariencia. Revisá los logs de esta isla."
                        console.warn("SmartBar Aplicar: guardado local NO confirmado")
                    }
                }
                if (count === 0 && unmanaged.length === 0)
                    console.log("SmartBar Aplicar: no hay cambios respecto del último Aplicar")
                if (unmanaged.length > 0) {
                    const message = "Sin integración en este ensayo: " +
                                    unmanaged.join(", ")
                    soledadSettings.runtimeApplyNote +=
                        (soledadSettings.runtimeApplyNote ? " " : "") + message
                    console.warn("SmartBar Aplicar: opciones pendientes de integrar:",
                                 unmanaged.join(", "))
                }
            }
        }
        onRestorePersonalDefaultRequested: root.requestRestorePersonalDefault()
        onRestoreFavoriteAppearanceRequested: root.requestRestoreFavoriteAppearance()
        onSaveThemeSlotRequested: function(slot, data) {
            root.requestThemeSlotChange(slot, data)
        }
        onWallpaperThemeSelected: function(themeName) {
            root.requestWallpaperThemeChange(themeName)
        }
        onSaveThemeScheduleRequested: function(enabled, count, slots3Json, slots4Json) {
            root.requestThemeScheduleChange(enabled, count, slots3Json, slots4Json)
        }
        onSaveThemePackSelectionRequested: function(id) {
            root.requestSelectedThemePackChange(id)
        }
        onSaveThemePackLibraryRequested: function(json) {
            root.requestThemePackLibraryChange(json)
        }
        onSaveWallpaperFadeRequested: function(amount, unit) {
            root.requestWallpaperFadeChange(amount,unit)
        }
        onSaveBarThemeTransitionRequested: function(enabled) {
            root.requestBarThemeTransitionChange(enabled)
            if (!enabled) root.themeColorsTransitionActive = false
        }
        onThemeVisualTransitionRequested: root.startActualThemeColorTransition()
        onThematicWallpaperVisibilityRequested: function(enabled) {
            root.requestThematicWallpaperVisibilityChange(enabled)
        }
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
        onSaveMalvinaBrowserRequested: function(browserId) {
            root.requestMalvinaBrowserChange(browserId)
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
        onSaveGradientBreathingRequested: function(syncToSO, intensity, active, speed, syncIntensity) {
            root.requestGradientBreathingChange(syncToSO, intensity, active, speed, syncIntensity)
        }
        onSaveMalvinaGradientBreathingRequested: function(syncToSO, intensity, active, speed) {
            root.requestMalvinaGradientBreathingChange(syncToSO, intensity, active, speed)
        }
        onSaveIslandGradientRequested: function(a, b, c, d, e, f, g, h, i, j) {
            root.requestIslandGradientChange(a, b, c, d, e, f, g, h, i, j)
        }
        onSaveTaskActiveIndicatorRequested: function(glowEnabled, doubleBorderEnabled) {
            root.requestTaskActiveIndicatorChange(glowEnabled, doubleBorderEnabled)
        }
        onSaveTaskDisplayModeRequested: function(mode) {
            root.requestTaskDisplayModeChange(mode)
        }
        onSaveTaskCloseModeRequested: function(mode) {
            root.requestTaskCloseModeChange(mode)
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
        // En el ensayo real Wayland, Popup.Window debe tener como parent
        // el BOTÓN que lo abrió, igual que gripMenu (que KWin sí ubica
        // debajo de los seis puntos). Con parent:root, la superficie de
        // LayerShell de 44 px hacía que el popup apareciera desde y=0,
        // cubriendo SO aunque y fuese root.fixedHeight+8.
        // El visor/maqueta mantienen su anclaje original, sin cambios.
        // LayerShell real: el popup Item vive en el Window flotante propio.
        // El visor Qt anterior conserva su alojamiento original.
        parent: root.layerShellLauncherHost
            ? root.layerShellLauncherHost.contentItem
            : (root.realAppLaunchEnabled
               ? ((root.installedLauncherSource === "so" || !root.launcherIslandVisible)
                  ? soButton : launcherIsland)
               : root)
        x: {
            if (root.layerShellLauncherHost) return 0
            const fromSo = root.installedLauncherSource === "so" ||
                           !root.launcherIslandVisible
            // Misma política de coordenada física que la ventana LayerShell.
            // Solo la conversión a origen LOCAL sigue siendo trabajo de QML.
            const left = SoledadLauncherPlacement.screenLeft({
                popupWidth: width,
                screenWidth: root.width,
                requirePositiveScreenWidth: false,
                fromSo: fromSo,
                systemIslandX: systemIsland.x,
                systemIslandWidth: systemIsland.width,
                launcherCenter: fromSo ? 0 : launcherIsland.mapToItem(
                    root, launcherIsland.width / 2, 0).x,
                categoryLayout: categoryLayout,
                showCategoryPanel: showCategoryPanel,
                filesMode: filesMode,
                expandedCanvas: expandedCanvas,
                primaryWidth: primaryWidth
            })
            if (!root.realAppLaunchEnabled) return left
            const anchor = fromSo ? soButton : launcherIsland
            return left - anchor.mapToItem(root, 0, 0).x
        }
        // Y relativo al botón ancla; no usar la altura del Window
        // LayerShell: no es el mismo sistema de coordenadas que Popup.Window.
        // En modo visor tradicional se preserva el posicionamiento anterior.
        y: root.layerShellLauncherHost ? 0 :
           (root.realAppLaunchEnabled
            ? ((root.installedLauncherSource === "so" || !root.launcherIslandVisible)
               ? soButton.height + 8 : launcherIsland.height + 8)
            : root.fixedHeight + 8)
        popupHeightLimit: root.realAppLaunchEnabled
            ? Math.max(270, Math.min(root.launcherAvailableHeight, 760))
            : root.launcherAvailableHeight
        categoryLayout: root.launcherCategoryLayout
        availableScreenWidth: root.width
        maxVisibleSlots: root.launcherMaxSlots
        iconsWithNames: root.launcherIconsWithNames
        switchShape: root.launcherSwitchShape
        switchCustomColor: root.launcherSwitchColorOverride
        switchColor: root.displayLauncherSwitchColor
        islandColor: root.displaySoledadColor
        islandGradientEnd: root.displaySoledadGradientEnd
        islandGradientThird: root.displaySoledadGradientThird
        islandGradientColorCount: root.soledadGradientColorCount
        islandOpacity: root.launcherOpacityOverride
            ? root.launcherOpacity : root.soledadOpacity
        islandGradientEnabled: root.soledadGradientEnabled
        islandGradientDirection: root.soledadGradientDirection
        islandBreathingFactor: root.gradientBreathingFactor
        outlineColor: root.displayOutlineSoColor
        outlineOpacity: root.outlineConfig.soledad.opacity
        outlineWidth: root.outlineConfig.soledad.width
        outlineStyle: root.outlineConfig.soledad.style
        malvinaVisible: root.launcherIslandVisible
        installedApplications: root.localAppCatalog
        catalogIsReal: root.localCatalogReady
        realLaunchEnabled: root.realAppLaunchEnabled
        autoCollapseOnSelection: true
        layerSurfaceHosted: root.realAppLaunchEnabled &&
                            root.layerShellLauncherHost !== null
        onLaunchDesktopEntry: function(desktopId) {
            // Desmontar ambas superficies ANTES de solicitar el inicio KDE.
            root.closeInstalledLauncher()
            console.log("SmartBar launcher: aplicación elegida; caja cerrada")
            root.requestLaunchDesktopEntry(desktopId)
        }
        onRequestDismiss: root.closeInstalledLauncher()
        triggerButtonHovered: root.installedLauncherSource === "so" && soButton.hovered
        onRequestShowMalvina: {
            root.setLauncherIslandVisible(true)
            root.closeInstalledLauncher()
        }
        onAppSelected: function(name, realCatalog) {
            root.closeInstalledLauncher()
            // En maqueta hacer visible la selección, sin ejecutar procesos.
            if (!realCatalog && root.demoOpenedApps.indexOf(name) >= 0)
                root.selectDemoApp(name)
            console.log("SmartBar: aplicación seleccionada:",
                        realCatalog ? "(catálogo sin ID ejecutable)" : "(simulación)",
                        name)
        }
        onClosed: {
            if (root.autoHideMalvina && !malvinaHotspotHover.hovered)
                malvinaHideTimer.restart()
        }
    }

    Item {
        anchors.fill: parent

        // Sin barra continua: solo se dibujan las islas flotantes.
        // Este Item no tiene MouseArea y deja pasar los clics fuera de ellas.

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
            // Ambas islas alineadas al borde superior, sin margen visual.
            // Mantener sus alturas independientes y el grosor general fijo.
            anchors.top: parent.top

            HoverHandler {
                id: malvinaHotspotHover
                // Margen pasivo: más fácil encontrar la isla escondida,
                // sin hacer más gruesa la barra ni ensanchar Malvina.
                margin: 18
                // Seguir leyendo hover también en modo siempre visible:
                // al buscar desde ese modo necesitamos saber si el cursor
                // seguía sobre la isla para evitar reaparecer de inmediato.
                enabled: !root.autoRevealBlocked && root.launcherIslandVisible
                onHoveredChanged: {
                    if (hovered) {
                        malvinaHideTimer.stop()
                        if (root.malvinaDismissedAfterSearch &&
                                !root.malvinaDismissRearmed) return
                        if (!root.autoRevealBlocked &&
                                (root.autoHideMalvina || root.malvinaDismissedAfterSearch))
                            malvinaRevealTimer.restart()
                    } else {
                        malvinaRevealTimer.stop()
                        if (root.malvinaDismissedAfterSearch)
                            root.malvinaDismissRearmed = true
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
                Qt.rgba(root.displayMalvinaColor.r, root.displayMalvinaColor.g,
                        root.displayMalvinaColor.b, root.malvinaOpacity * root.malvinaGradientBreathingFactor)
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
                        color: {
                            const reversed = root.malvinaGradientDirection === "rightLeft" ||
                                             root.malvinaGradientDirection === "bottomTop"
                            const value = reversed
                                ? (root.malvinaGradientColorCount === 3
                                   ? root.displayMalvinaGradientThird : root.displayMalvinaGradientEnd)
                                : root.displayMalvinaColor
                            return Qt.rgba(value.r, value.g, value.b,
                                root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                        }
                    }
                    GradientStop {
                        position: root.malvinaGradientColorCount === 3 ? 0.5 : 1
                        color: {
                            const reversed = root.malvinaGradientDirection === "rightLeft" ||
                                             root.malvinaGradientDirection === "bottomTop"
                            const value = root.malvinaGradientColorCount === 3
                                ? root.displayMalvinaGradientEnd
                                : (reversed ? root.displayMalvinaColor : root.displayMalvinaGradientEnd)
                            return Qt.rgba(value.r, value.g, value.b,
                                root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                        }
                    }
                    GradientStop {
                        position: 1
                        color: {
                            const reversed = root.malvinaGradientDirection === "rightLeft" ||
                                             root.malvinaGradientDirection === "bottomTop"
                            const value = reversed ? root.displayMalvinaColor
                                : (root.malvinaGradientColorCount === 3
                                   ? root.displayMalvinaGradientThird : root.displayMalvinaGradientEnd)
                            return Qt.rgba(value.r, value.g, value.b,
                                root.malvinaOpacity * root.malvinaGradientBreathingFactor)
                        }
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
                    function onDisplayMalvinaColorChanged() { malvinaTipSurface.requestPaint() }
                    function onDisplayMalvinaGradientEndChanged() { malvinaTipSurface.requestPaint() }
                    function onDisplayMalvinaGradientThirdChanged() { malvinaTipSurface.requestPaint() }
                    function onDisplayOutlineMalvinaColorChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientEnabledChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientEndChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientThirdChanged() { malvinaTipSurface.requestPaint() }
                    function onMalvinaGradientColorCountChanged() { malvinaTipSurface.requestPaint() }
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
                        // La dirección ya está dada por las coordenadas.
                        // No invertir además los colores: invertir dos veces
                        // anulaba el efecto de derecha→izquierda.
                        g.addColorStop(0, Qt.rgba(root.displayMalvinaColor.r,
                            root.displayMalvinaColor.g, root.displayMalvinaColor.b, alpha))
                        if (root.malvinaGradientColorCount === 3) {
                            g.addColorStop(0.5, Qt.rgba(root.displayMalvinaGradientEnd.r,
                                root.displayMalvinaGradientEnd.g, root.displayMalvinaGradientEnd.b, alpha))
                            g.addColorStop(1, Qt.rgba(root.displayMalvinaGradientThird.r,
                                root.displayMalvinaGradientThird.g, root.displayMalvinaGradientThird.b, alpha))
                        } else {
                            g.addColorStop(1, Qt.rgba(root.displayMalvinaGradientEnd.r,
                                root.displayMalvinaGradientEnd.g, root.displayMalvinaGradientEnd.b, alpha))
                        }
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(root.displayMalvinaColor.r, root.displayMalvinaColor.g,
                                                root.displayMalvinaColor.b, alpha)
                    }
                    ctx.fill()
                    const outline = root.outlineConfig.malvina
                    if (outline && outline.style !== "none" && outline.width > 0) {
                        ctx.lineWidth = outline.width
                        const c = root.displayOutlineMalvinaColor.toString()
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
                lineColor: root.displayOutlineMalvinaColor
                lineOpacity: root.outlineConfig.malvina.opacity
                topLeft: launcherIsland.topLeftRadius
                topRight: launcherIsland.topRightRadius
                bottomLeft: launcherIsland.bottomLeftRadius
                bottomRight: launcherIsland.bottomRightRadius
            }
            MalvinaSearch {
                id: malvinaSearch
                optionsViewportWidthOverride: root.malvinaOptionsViewportWidth
                gearButtonShape: root.malvinaGearButtonShape
                searchButtonShape: root.malvinaSearchButtonShape
                islandShape: root.malvinaShape
                islandRadius: root.malvinaRadius
                islandColor: root.displayMalvinaColor
                islandOpacity: root.malvinaOpacity * root.malvinaGradientBreathingFactor
                optionsPanelOpacity: root.malvinaOptionsOpacityOverride
                    ? root.malvinaOptionsOpacity : root.malvinaOpacity
                optionsPanelBreathingFactor: root.malvinaGradientBreathingFactor
                islandGradientEnabled: root.malvinaGradientEnabled
                islandGradientEnd: root.displayMalvinaGradientEnd
                islandGradientThird: root.displayMalvinaGradientThird
                islandGradientColorCount: root.malvinaGradientColorCount
                islandGradientDirection: root.malvinaGradientDirection
                islandOutlineColor: root.displayOutlineMalvinaColor
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
                taskFrameColor: root.displayTaskFrameColor
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
                onExpandedChanged: {
                    // Reapertura explícita por lupa/teclado: mostrarla.
                    if (expanded) {
                        root.malvinaDismissedAfterSearch = false
                        root.malvinaDismissRearmed = false
                    }
                }
                onRequestOpenUrl: function(url) {
                    // Respeta la opción de un navegador para toda Malvina.
                    // Si el ejecutable elegido desaparece, avisar y usar KDE.
                    let choice = "system"
                    for (let i = 0; i < root.malvinaBrowserChoices.length; ++i) {
                        if (root.malvinaBrowserChoices[i].id === root.malvinaBrowserId) {
                            choice = root.malvinaBrowserId
                            break
                        }
                    }
                    let accepted = false
                    if (root.malvinaBrowserBackend !== null &&
                        typeof root.malvinaBrowserBackend.launchWebUrl === "function") {
                        accepted = root.malvinaBrowserBackend.launchWebUrl(choice, url)
                    } else {
                        // El plasmoide/visor QML aún no incluye puente nativo.
                        // Conservar apertura KDE; no fingir selección específica.
                        accepted = Qt.openUrlExternally(url)
                    }
                    if (accepted) {
                        root.dismissMalvinaAfterSearch()
                    } else {
                        console.warn("Malvina: no se pudo iniciar el navegador:", choice)
                    }
                }
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
                    // La misma acción de la prueba del visor, sin duplicar
                    // temporizadores, lógica ni botones en la barra.
                    QQC2.MenuItem {
                        visible: root.themeScheduleRuntimeEnabled
                        text: "siguiente tema y wallpaper"
                        enabled: root.themeWallpaperPreviewAvailable
                        onTriggered: root.triggerThemeWallpaperPreview()
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
                    function onDisplaySoledadColorChanged() { islandSurface.requestPaint() }
                    function onDisplaySoledadGradientEndChanged() { islandSurface.requestPaint() }
                    function onDisplaySoledadGradientThirdChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientEnabledChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientEndChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientThirdChanged() { islandSurface.requestPaint() }
                    function onSoledadGradientColorCountChanged() { islandSurface.requestPaint() }
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
                        g.addColorStop(0, Qt.rgba(root.displaySoledadColor.r, root.displaySoledadColor.g,
                                                   root.displaySoledadColor.b, root.soledadOpacity * root.gradientBreathingFactor))
                        if (root.soledadGradientColorCount === 3) {
                            g.addColorStop(0.5, Qt.rgba(root.displaySoledadGradientEnd.r,
                                root.displaySoledadGradientEnd.g, root.displaySoledadGradientEnd.b,
                                root.soledadOpacity * root.gradientBreathingFactor))
                            g.addColorStop(1, Qt.rgba(root.displaySoledadGradientThird.r,
                                root.displaySoledadGradientThird.g, root.displaySoledadGradientThird.b,
                                root.soledadOpacity * root.gradientBreathingFactor))
                        } else {
                            g.addColorStop(1, Qt.rgba(root.displaySoledadGradientEnd.r,
                                root.displaySoledadGradientEnd.g, root.displaySoledadGradientEnd.b,
                                root.soledadOpacity * root.gradientBreathingFactor))
                        }
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(root.displaySoledadColor.r, root.displaySoledadColor.g,
                                                root.displaySoledadColor.b, root.soledadOpacity)
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
                lineColor: root.displayOutlineSoColor
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
            // La isla, en cambio, empieza en y=0 como Malvina.
            anchors.top: parent.top

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
                    function onDisplaySoledadColorChanged() { soTipBackground.requestPaint() }
                    function onDisplaySoledadGradientEndChanged() { soTipBackground.requestPaint() }
                    function onDisplaySoledadGradientThirdChanged() { soTipBackground.requestPaint() }
                    function onSoledadGradientEnabledChanged() { soTipBackground.requestPaint() }
                    function onSoledadGradientEndChanged() { soTipBackground.requestPaint() }
                    function onSoledadGradientThirdChanged() { soTipBackground.requestPaint() }
                    function onSoledadGradientColorCountChanged() { soTipBackground.requestPaint() }
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
                        g.addColorStop(0, Qt.rgba(root.displaySoledadColor.r, root.displaySoledadColor.g,
                                                  root.displaySoledadColor.b, root.soledadOpacity * root.gradientBreathingFactor))
                        if (root.soledadGradientColorCount === 3) {
                            g.addColorStop(0.5, Qt.rgba(root.displaySoledadGradientEnd.r,
                                root.displaySoledadGradientEnd.g, root.displaySoledadGradientEnd.b,
                                root.soledadOpacity * root.gradientBreathingFactor))
                            g.addColorStop(1, Qt.rgba(root.displaySoledadGradientThird.r,
                                root.displaySoledadGradientThird.g, root.displaySoledadGradientThird.b,
                                root.soledadOpacity * root.gradientBreathingFactor))
                        } else {
                            g.addColorStop(1, Qt.rgba(root.displaySoledadGradientEnd.r,
                                root.displaySoledadGradientEnd.g, root.displaySoledadGradientEnd.b,
                                root.soledadOpacity * root.gradientBreathingFactor))
                        }
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(root.displaySoledadColor.r, root.displaySoledadColor.g,
                                                root.displaySoledadColor.b, root.soledadOpacity)
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

                SoledadTrayToggle {
                    id: trayToggle
                    host: root
                }

                // Repeater modular: iconos siguen siendo hijos directos de
                // systemRow; no cambiar ancho, posición ni transparencias.
                SystemTrayView {
                    sourceEntries: SystemTrayModel.visibleEntries(
                        root.demoTray, root.trayExpanded)
                    expanded: root.trayExpanded
                    trayColor: root.effectiveTrayButtonColor
                    trayOpacity: root.effectiveTrayButtonOpacity
                    trayOutlineStyle: root.outlineConfig.tray.style
                    trayOutlineWidth: root.outlineConfig.tray.width
                    trayOutlineColor: root.displayOutlineTrayColor
                    trayOutlineOpacity: root.outlineConfig.tray.opacity
                    onIconActivated: function(iconName) {
                        root.selectDemoTray(iconName)
                    }
                }

                // Separación mínima y legible entre iconos de bandeja y
                // fichas SO, solamente cuando ambas expansiones están
                // visibles. Se incluye naturalmente en el ancho medido.
                SoledadTaskWidthSeparator {
                    host: root
                }

                // Modo histórico de maqueta: NO se altera la prueba de
                // fichas ficticias ni su autocontracción configurada.
                Repeater {
                    model: root.positionMode === "right" && root.soExpanded &&
                           !root.usingRealTasks && root.demoHasRunningWindows
                           ? root.demoOpenedApps : []
                    delegate: DemoTaskChip {
                        // modelData se inyecta en la propiedad requerida
                        // del componente; no es un nombre contextual aquí.
                        host: root
                    }
                }
                // Único control de reapertura en el mismo cajón de fichas SO.
                // Nunca se muestra con TasksModel real ni modifica KDE.
                SoledadDemoReopenButton {
                    host: root
                    presentationMode: "right"
                }


                // Nuevo ensayo: KDE TasksModel de solo lectura, inyectado
                // únicamente por el visor Qt. El Repeater actualiza las
                // fichas al abrir/cerrar ventanas; no llama a requestActivate,
                // requestClose ni métodos para minimizar o alterar ventanas.
                // Repetición horizontal dentro del mismo Row, sin otra fila.
                Repeater {
                    model: root.positionMode === "right" && root.soExpanded &&
                           root.usingRealTasks ? root.realTaskModel : null
                    delegate: SoledadRealTaskChip {
                        host: root
                    }
                }

                IslandButton {
                    id: soButton
                    text: root.soLogoMode === "text" ? root.soTextLabel : "SO"
                    customTextMode: root.soLogoMode === "text"
                    customTextColor: root.displaySoTextColor
                    customTextBackground: root.displaySoTextBackground
                    customTextBackgroundOpacity: root.soTextBackgroundOpacity
                    customTextFontFamily: root.soTextFontFamily
                    customTextFontSize: root.soTextFontSize
                    customTextBold: root.soTextBold
                    customTextBackgroundImage: root.soTextBackgroundImage
                    accent: true
                    activityCount: root.soWindowCount
                    activityEffect: root.soActivityStyle
                    activityColor: root.displaySoActivityColor
                    activityStroke: root.soActivityStroke
                    activityMotionAllowed: root.soActivityMotion
                    activityOrbitSpeed: root.soActivityOrbitSpeed
                    activityTrailPercent: root.soActivityTrailPercent
                    activityTrailStyle: root.soActivityTrailStyle
                    activityGlowColor: root.displaySoActivityGlowColor
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
                    // Durante la demostración el logo de fondo queda oculto;
                    // no reproducir un segundo GIF innecesariamente.
                    iconAnimationEnabled: root.soLogoAnimate && !root.barColorPreviewActive
                    clockVisible: root.soClockVisible
                    clockPhase: root.soClockPhase
                    clockTime: root.soClockTime
                    clockDate: root.soClockDate
                    clockFontFamily: root.soClockFontFamily
                    clockFontSize: root.soClockFontSize
                    clockTextColor: root.displaySoClockTextColor
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
                        root.soLauncherOpenOnLeftPress = installedAppsPopup.visible &&
                            root.installedLauncherSource === "so"
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
                            root.triggerSOButton(true, root.soLauncherOpenOnLeftPress)
                        }
                        root.soLauncherOpenOnLeftPress = false
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
                        onPressed: {
                            root.soTooltipSuppressed = true
                            root.soLauncherOpenOnRightPress = installedAppsPopup.visible &&
                                root.installedLauncherSource === "so"
                        }
                        onClicked: {
                            root.triggerSOButton(false, root.soLauncherOpenOnRightPress)
                            root.soLauncherOpenOnRightPress = false
                        }
                    }

                    QQC2.ToolTip.visible: false
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
                                       root.soledadGradientEnabled &&
                                       !root.gripButtonColorOverride
                                           ? 0 : root.effectiveGripButtonOpacity)
                        border.width: 0
                        OutlineStyle {
                            anchors.fill: parent
                            lineStyle: root.outlineConfig.grip.style
                            lineWidth: root.outlineConfig.grip.width
                            lineColor: root.displayOutlineGripColor
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
                    QQC2.ToolTip.visible: false
                    QQC2.ToolTip.delay: 850
                    QQC2.ToolTip.text: root.launcherIslandVisible
                        ? "Izquierdo: arrastrar o cerrar menú · Derecho: opciones"
                        : "Izquierdo: arrastrar o cerrar menú · Derecho: opciones"

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
                                if (root.layerShellDragCompensation) {
                                    // Coordenada del puntero RELATIVA al Window,
                                    // no al Item que cambia de x al mover la isla.
                                    root.layerShellDragSceneStartX =
                                        gripDrag.centroid.scenePosition.x
                                }
                            }
                            root.soExpanded = false
                            root.trayExpanded = false
                            moveGrip.draggedDuringPress = true
                            moveGrip.suppressGripTooltip = true
                        }
                        onActiveTranslationChanged: {
                            if (active && (root.layerShellDragCompensation ||
                                          Math.abs(activeTranslation.x) > 1)) {
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
                                } else if (root.layerShellDragCompensation) {
                                    // Mientras LayerShellQt mueve el Window, la
                                    // activeTranslation acumulada toma como
                                    // origen una escena que también se mueve:
                                    // realimentarla causa saltos y bloqueos.
                                    // La desviación respecto de la coordenada
                                    // inicial DEL PUNTERO dentro del Window
                                    // es la corrección relativa estable.
                                    const result =
                                        LayerShellDragCompensation.nextWithEdgeRebase(
                                            root.islandOffset,
                                            root.layerShellDragSceneStartX,
                                            gripDrag.centroid.scenePosition.x,
                                            root.maxIslandOffset)
                                    // No acumular sobre-recorrido en los extremos.
                                    // Dejar que volver en sentido contrario
                                    // responda desde el primer movimiento.
                                    root.layerShellDragSceneStartX =
                                        result.anchorSceneX
                                    root.setIslandOffset(result.offset)
                                } else {
                                    // Modo original sin cambios: ventanas Qt
                                    // estáticas, maqueta y plasmoide.
                                    root.setIslandOffset(
                                        root.offsetAtDragStart - activeTranslation.x)
                                }
                            }
                        }
                    }

                    SoledadPositionEditor {
                        id: soPositionEditor
                        parent: moveGrip
                        x: Math.min(0, moveGrip.width - width)
                        y: moveGrip.height + 10
                        realTasksModel: root.realTaskModel
                        profilesJson: root.realPositionProfilesJson
                        generalOffset: root.generalSoledadOffset
                        currentOffset: root.islandOffset
                        maxOffset: root.maxIslandOffset
                        onPreviewRequested: function(offset) {
                            root.setIslandOffset(offset)
                            root.alignRightSelected = offset === 0
                        }
                        onSaveRequested: function(appId, offset) {
                            root.storeRealPositionFor(appId, offset)
                        }
                        onRemoveRequested: function(appId) {
                            root.forgetRealPositionFor(appId)
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
                        // La visibilidad de Malvina se administra únicamente
                        // desde Configuración, sin acciones duplicadas aquí.
                        QQC2.MenuItem {
                            text: "Configuración de Soledad…"
                            // Logo, colores, contorno, autocontracción,
                            // islas y posición comparten ventana con pestañas.
                            onTriggered: root.openSoledadSettings(0)
                        }
                        // Acceso contextual al tema siguiente del pack activo,
                        // aplicando también su apariencia SO/islas y su fondo.
                        // Reemplaza el atajo anterior que solo previsualizaba.
                        QQC2.MenuItem {
                            visible: root.themeScheduleRuntimeEnabled ||
                                     root.runtimeAppearanceEnabled
                            text: "Pasar al tema siguiente"
                            enabled: root.themeScheduleRuntimeEnabled ||
                                     root.runtimeThemeSwitchAvailable
                            onTriggered: root.passToNextPackTheme()
                        }
                        QQC2.MenuItem {
                            text: "Autocontraer cajón SO al elegir ventana"
                            checkable: true
                            checked: root.autoCollapseSO
                            onTriggered: {
                                console.log("SmartBar SO casilla cajón: solicitar",
                                            !root.autoCollapseSO)
                                root.requestAutoCollapseSOChange(!root.autoCollapseSO)
                            }
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            enabled: !root.usingRealTasks
                            text: root.usingRealTasks
                                ? "SO conectado a tareas reales (solo lectura)"
                                : (root.demoHasRunningWindows
                                   ? "Simular SO SIN ventanas (0)"
                                   : "Simular SO CON ventanas (3)")
                            onTriggered: {
                                if (root.demoHasRunningWindows) {
                                    root.demoHasRunningWindows = false
                                } else {
                                    root.demoClosedHistory = []
                                    root.demoMutedApps = ({})
                                    root.demoWindowInstances = DemoWindowInstances.initial()
                                     root.demoOpenedApps = root.demoApps.slice()
                                    root.demoHasRunningWindows = true
                                }
                            }
                        }
                        QQC2.MenuItem {
                            visible: !root.usingRealTasks && root.demoHasRunningWindows
                            text: "Simular escritorio vacío (fichas sin resaltar)"
                            onTriggered: root.lastDemoSelection = ""
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            text: "Simular ventana maximizada"
                            visible: !root.usingRealTasks
                            checkable: true
                            checked: root.previewMaximized
                            onTriggered: root.setPreviewMaximized(!root.previewMaximized)
                        }
                        QQC2.MenuItem {
                            text: "Simular pantalla completa (bloquea Malvina)"
                            visible: !root.usingRealTasks
                            checkable: true
                            checked: root.previewFullscreen
                            onTriggered: root.previewFullscreen = !root.previewFullscreen
                        }
                        // Un único control por aplicación: su etiqueta y su
                        // acción dependen exclusivamente del perfil guardado.
                        // No cambiar la lógica de almacenamiento ni posiciones.
                        QQC2.MenuItem {
                            visible: root.demoProfileContextReady
                            text: root.demoProfileExists
                                ? "Olvidar posición de " + root.lastDemoSelection
                                : "Fijar esta posición para " + root.lastDemoSelection
                            onTriggered: {
                                if (root.demoProfileExists)
                                    root.deleteDemoPositionProfile()
                                else
                                    root.saveDemoPositionProfile()
                            }
                        }
                        QQC2.MenuItem {
                            visible: root.demoWindowControlsEnabled &&
                                     root.usingRealTasks &&
                                     root.positionMode === "right" &&
                                     root.realProfileTarget.appName.length > 0
                            enabled: root.realProfileContextReady
                            text: !root.realProfileContextReady
                                ? root.realProfileTarget.appName + ": KDE no informa su ID"
                                : root.realProfileExists
                                    ? "Olvidar posición de " + root.realProfileTarget.appName
                                    : "Fijar esta posición para " + root.realProfileTarget.appName
                            onTriggered: {
                                if (root.realProfileExists)
                                    root.deleteRealPositionProfile()
                                else
                                    root.saveRealPositionProfile()
                            }
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            visible: root.usingRealTasks
                            enabled: root.positionMode === "right"
                            text: "Fijar esta posición para todas las aplicaciones"
                            onTriggered: root.saveGeneralSoledadPosition()
                        }
                        QQC2.MenuItem {
                            visible: root.usingRealTasks
                            text: "Personalizar posición por aplicación…"
                            onTriggered: {
                                soPositionEditor.openFor(root.realTrackedAppId,
                                                         root.realTrackedAppName)
                            }
                        }
                        // Atajo contextual del agarre: respeta la preferencia
                        // elegida en Islas y posición, sin cambiar de modo.
                        QQC2.MenuItem {
                            // MISMA acción existente, con etiqueta contextual:
                            // no prometer «derecha» si hay perfil de Brave/Steam.
                            text: root.positionMode === "center"
                                ? "Centrar isla 1 ahora"
                                : (root.activeRealAppHasSavedPosition
                                    ? "Volver a posición de " + root.realTrackedAppName
                                    : "Alinear isla 1 a la derecha ahora")
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
                           ? root.demoOpenedApps : []
                    delegate: DemoTaskChip {
                        // modelData se inyecta en la propiedad requerida
                        // del componente; no es un nombre contextual aquí.
                        host: root
                    }
                }
                // Único control de reapertura en el mismo cajón de fichas SO.
                // Nunca se muestra con TasksModel real ni modifica KDE.
                SoledadDemoReopenButton {
                    host: root
                    presentationMode: "center"
                }


                // Nuevo ensayo: KDE TasksModel de solo lectura, inyectado
                // únicamente por el visor Qt. El Repeater actualiza las
                // fichas al abrir/cerrar ventanas; no llama a requestActivate,
                // requestClose ni métodos para minimizar o alterar ventanas.
                // Repetición horizontal dentro del mismo Row, sin otra fila.
                Repeater {
                    model: root.positionMode === "center" && root.soExpanded &&
                           root.usingRealTasks ? root.realTaskModel : null
                    delegate: SoledadRealTaskChip {
                        host: root
                    }
                }


            }
        }

        // Independientes de la isla 1: NO acompañan el arrastre del agarre.
        // El margen derecho es cero en cualquier posición de SO y bandeja.
        // Esto es solo la simulación: no controla ventanas reales de KDE.
        SoledadDemoWindowControls {
            id: windowControls
            visible: root.previewMaximized
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
