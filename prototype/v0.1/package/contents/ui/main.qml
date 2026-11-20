// Empaquetado KDE Plasma 6. La interfaz es compartida con la prueba Qt.
// El tamaño del contenido depende de lo que entregue el contenedor de KDE.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: plasmoidRoot

    Layout.fillWidth: true
    Layout.minimumWidth: 750    // Solo requisito de la maqueta horizontal.
    Layout.preferredWidth: 960  // Sugerencia, no ancho máximo.
    // El plasmoide solicita la altura elegida; Plasma puede limitarla
    // según el panel anfitrión. Nunca modificar un panel existente.
    Layout.minimumHeight: Plasmoid.configuration.panelHeight
    Layout.preferredHeight: Plasmoid.configuration.panelHeight
    Layout.maximumHeight: Plasmoid.configuration.panelHeight
    implicitWidth: 960
    implicitHeight: Plasmoid.configuration.panelHeight

    onWidthChanged: console.log("SmartBar v0.1: ancho del applet Plasma =", width)
    SmartBarContent {
        id: demo
        // La programación se guarda también en KConfig, pero no se ejecuta
        // sobre el panel real hasta validar el visor en CachyOS.
        themeScheduleRuntimeEnabled: false
        wallpaperFadeAmount: Plasmoid.configuration.wallpaperFadeAmount
        wallpaperFadeUnit: Plasmoid.configuration.wallpaperFadeUnit
        barThemeTransitionEnabled: Plasmoid.configuration.barThemeTransitionEnabled
        onRequestBarThemeTransitionChange: function(enabled) {
            Plasmoid.configuration.barThemeTransitionEnabled = enabled
        }
        onRequestWallpaperFadeChange: function(amount, unit) {
            Plasmoid.configuration.wallpaperFadeAmount = amount
            Plasmoid.configuration.wallpaperFadeUnit = unit
        }
        themeScheduleEnabled: Plasmoid.configuration.themeScheduleEnabled
        themeScheduleSlotCount: Plasmoid.configuration.themeScheduleSlotCount
        themeScheduleSlots3Json: Plasmoid.configuration.themeScheduleSlots3Json
        themeScheduleSlots4Json: Plasmoid.configuration.themeScheduleSlots4Json
        onRequestThemeScheduleChange: function(enabled, count, slots3Json, slots4Json) {
            Plasmoid.configuration.themeScheduleEnabled = enabled
            Plasmoid.configuration.themeScheduleSlotCount = count
            Plasmoid.configuration.themeScheduleSlots3Json = slots3Json
            Plasmoid.configuration.themeScheduleSlots4Json = slots4Json
        }
        thematicWallpaperEnabled: Plasmoid.configuration.thematicWallpaperEnabled
        // Guarda solo la preferencia. El plasmoide NO cambia el escritorio KDE.
        onRequestThematicWallpaperVisibilityChange: function(enabled) {
            Plasmoid.configuration.thematicWallpaperEnabled = enabled
        }
        anchors.fill: parent
        panelHeight: Plasmoid.configuration.panelHeight
        soledadHeight: Plasmoid.configuration.soledadHeight
        malvinaHeight: Plasmoid.configuration.malvinaHeight
        soledadRadius: Plasmoid.configuration.soledadRadius
        malvinaRadius: Plasmoid.configuration.malvinaRadius
        soledadMinWidth: Plasmoid.configuration.soledadMinWidth
        malvinaWidth: Plasmoid.configuration.malvinaWidth
        soledadShape: Plasmoid.configuration.soledadShape
        malvinaShape: Plasmoid.configuration.malvinaShape
        malvinaGearButtonShape: Plasmoid.configuration.malvinaGearButtonShape
        malvinaSearchButtonShape: Plasmoid.configuration.malvinaSearchButtonShape
        onRequestMalvinaButtonShapesChange: function(gearShape, searchShape) {
            Plasmoid.configuration.malvinaGearButtonShape = gearShape
            Plasmoid.configuration.malvinaSearchButtonShape = searchShape
        }
        gripShape: Plasmoid.configuration.gripShape
        trayButtonShape: Plasmoid.configuration.trayButtonShape
        soButtonFrameShape: Plasmoid.configuration.soButtonFrameShape
        soButtonWidth: Plasmoid.configuration.soButtonWidth

        // La configuración de Plasma se mantiene en el envoltorio;
        // SmartBarContent no depende de Plasmoid y es reutilizable.
        taskActiveGlowEnabled: Plasmoid.configuration.taskActiveGlowEnabled
        taskActiveDoubleBorderEnabled: Plasmoid.configuration.taskActiveDoubleBorderEnabled
        onRequestTaskActiveIndicatorChange: function(glowEnabled, doubleBorderEnabled) {
            Plasmoid.configuration.taskActiveGlowEnabled = glowEnabled
            Plasmoid.configuration.taskActiveDoubleBorderEnabled = doubleBorderEnabled
        }
        malvinaGoogleName: Plasmoid.configuration.malvinaGoogleName
        malvinaDuckName: Plasmoid.configuration.malvinaDuckName
        malvinaYahooName: Plasmoid.configuration.malvinaYahooName
        malvinaChatGptName: Plasmoid.configuration.malvinaChatGptName
        malvinaGeminiName: Plasmoid.configuration.malvinaGeminiName
        malvinaClaudeName: Plasmoid.configuration.malvinaClaudeName
        onRequestMalvinaNamesChange: function(google, duck, yahoo, chatGpt, gemini, claude) {
            Plasmoid.configuration.malvinaGoogleName = google
            Plasmoid.configuration.malvinaDuckName = duck
            Plasmoid.configuration.malvinaYahooName = yahoo
            Plasmoid.configuration.malvinaChatGptName = chatGpt
            Plasmoid.configuration.malvinaGeminiName = gemini
            Plasmoid.configuration.malvinaClaudeName = claude
        }
        malvinaExtraWeb: Plasmoid.configuration.malvinaExtraWeb
        malvinaExtraAi: Plasmoid.configuration.malvinaExtraAi
        malvinaHiddenWeb: Plasmoid.configuration.malvinaHiddenWeb
        malvinaHiddenAi: Plasmoid.configuration.malvinaHiddenAi
        malvinaCompactAi: Plasmoid.configuration.malvinaCompactAi
        onRequestMalvinaExtrasChange: function(webJson, aiJson, hiddenWeb, hiddenAi, compactAi) {
            Plasmoid.configuration.malvinaExtraWeb = webJson
            Plasmoid.configuration.malvinaExtraAi = aiJson
            Plasmoid.configuration.malvinaHiddenWeb = hiddenWeb
            Plasmoid.configuration.malvinaHiddenAi = hiddenAi
            Plasmoid.configuration.malvinaCompactAi = compactAi
        }
        malvinaWebFirst: Plasmoid.configuration.malvinaWebFirst
        malvinaWebOrder: Plasmoid.configuration.malvinaWebOrder
        malvinaAiOrder: Plasmoid.configuration.malvinaAiOrder
        onRequestMalvinaOrderChange: function(firstWeb, webOrder, aiOrder) {
            Plasmoid.configuration.malvinaWebFirst = firstWeb
            Plasmoid.configuration.malvinaWebOrder = webOrder
            Plasmoid.configuration.malvinaAiOrder = aiOrder
        }
        malvinaGoogleUrl: Plasmoid.configuration.malvinaGoogleUrl
        malvinaDuckUrl: Plasmoid.configuration.malvinaDuckUrl
        malvinaYahooUrl: Plasmoid.configuration.malvinaYahooUrl
        malvinaChatGptUrl: Plasmoid.configuration.malvinaChatGptUrl
        malvinaGeminiUrl: Plasmoid.configuration.malvinaGeminiUrl
        malvinaClaudeUrl: Plasmoid.configuration.malvinaClaudeUrl
        malvinaWebGoogleEnabled: Plasmoid.configuration.malvinaWebGoogleEnabled
        malvinaWebDuckEnabled: Plasmoid.configuration.malvinaWebDuckEnabled
        malvinaWebYahooEnabled: Plasmoid.configuration.malvinaWebYahooEnabled
        onRequestMalvinaWebEnabledChange: function(google, duck, yahoo) {
            Plasmoid.configuration.malvinaWebGoogleEnabled = google
            Plasmoid.configuration.malvinaWebDuckEnabled = duck
            Plasmoid.configuration.malvinaWebYahooEnabled = yahoo
        }
        malvinaAllowChatGpt: Plasmoid.configuration.malvinaAllowChatGpt
        malvinaAllowGemini: Plasmoid.configuration.malvinaAllowGemini
        malvinaAllowClaude: Plasmoid.configuration.malvinaAllowClaude
        onRequestMalvinaConsentsChange: function(chatGpt, gemini, claude) {
            Plasmoid.configuration.malvinaAllowChatGpt = chatGpt
            Plasmoid.configuration.malvinaAllowGemini = gemini
            Plasmoid.configuration.malvinaAllowClaude = claude
        }
        onRequestMalvinaProvidersChange: function(google, duck, yahoo, chatGpt, gemini, claude) {
            Plasmoid.configuration.malvinaGoogleUrl = google
            Plasmoid.configuration.malvinaDuckUrl = duck
            Plasmoid.configuration.malvinaYahooUrl = yahoo
            Plasmoid.configuration.malvinaChatGptUrl = chatGpt
            Plasmoid.configuration.malvinaGeminiUrl = gemini
            Plasmoid.configuration.malvinaClaudeUrl = claude
        }
        taskDisplayMode: Plasmoid.configuration.taskDisplayMode
        onRequestTaskDisplayModeChange: function(mode) {
            Plasmoid.configuration.taskDisplayMode = mode
        }
        taskCloseMode: Plasmoid.configuration.taskCloseMode
        onRequestTaskCloseModeChange: function(mode) {
            Plasmoid.configuration.taskCloseMode =
                ["both", "preview", "chip"].indexOf(mode) >= 0 ? mode : "both"
        }
        taskFrameShape: Plasmoid.configuration.taskFrameShape
        taskFrameColor: Plasmoid.configuration.taskFrameColor
        taskFrameOpacity: Plasmoid.configuration.taskFrameOpacity
        taskFrameWidth: Plasmoid.configuration.taskFrameWidth
        onRequestTaskFrameChange: function(shape, color, opacity, width) {
            Plasmoid.configuration.taskFrameShape = shape
            Plasmoid.configuration.taskFrameColor = color
            Plasmoid.configuration.taskFrameOpacity = opacity
            Plasmoid.configuration.taskFrameWidth = width
        }
        autoReturnRight: Plasmoid.configuration.autoReturnRight
        positionMode: Plasmoid.configuration.positionMode
        onRequestPositionModeChange: function(mode) {
            Plasmoid.configuration.positionMode = mode
        }
        launcherIslandVisible: Plasmoid.configuration.showLauncherIsland
        autoHideMalvina: Plasmoid.configuration.autoHideMalvina
        // Seguridad: sin consulta real a KWin todavía, NO revelar islas
        // por hover sobre otras aplicaciones. Evitar interrupciones.
        windowStateKnown: false
        autoCollapseSO: Plasmoid.configuration.autoCollapseSO
        soLeftClickOpensLauncher: Plasmoid.configuration.soLeftClickOpensLauncher
        themeDayJson: Plasmoid.configuration.themeDayJson
        themeDayPreviousJson: Plasmoid.configuration.themeDayPreviousJson
        themeNightJson: Plasmoid.configuration.themeNightJson
        themeCustomJson: Plasmoid.configuration.themeCustomJson
        themeLibraryJson: Plasmoid.configuration.themeLibraryJson
        launcherCategoryLayout: Plasmoid.configuration.launcherCategoryLayout
        launcherSwitchShape: Plasmoid.configuration.launcherSwitchShape
        launcherSwitchColorOverride: Plasmoid.configuration.launcherSwitchColorOverride
        launcherSwitchColor: Plasmoid.configuration.launcherSwitchColor
        launcherMaxSlots: Plasmoid.configuration.launcherMaxSlots
        launcherOpacityOverride: Plasmoid.configuration.launcherOpacityOverride
        launcherOpacity: Plasmoid.configuration.launcherOpacity
        launcherIconsWithNames: Plasmoid.configuration.launcherIconsWithNames
        malvinaOptionsOpacityOverride: Plasmoid.configuration.malvinaOptionsOpacityOverride
        malvinaOptionsOpacity: Plasmoid.configuration.malvinaOptionsOpacity
        autoCollapseTray: Plasmoid.configuration.autoCollapseTray
        soLogoMode: Plasmoid.configuration.soLogoMode
        soTextLabel: Plasmoid.configuration.soTextLabel
        soTextColor: Plasmoid.configuration.soTextColor
        soTextBackground: Plasmoid.configuration.soTextBackground
        soTextBackgroundOpacity: Plasmoid.configuration.soTextBackgroundOpacity
        soTextFontFamily: Plasmoid.configuration.soTextFontFamily
        soTextFontSize: Plasmoid.configuration.soTextFontSize
        soTextBold: Plasmoid.configuration.soTextBold
        soTextBackgroundImage: Plasmoid.configuration.soTextBackgroundImage
        soLogoPath: Plasmoid.configuration.soLogoPath
        soLogoShape: Plasmoid.configuration.soLogoShape
        soLogoFitMode: Plasmoid.configuration.soLogoFitMode
        soLogoZoom: Plasmoid.configuration.soLogoZoom
        soLogoPanX: Plasmoid.configuration.soLogoPanX
        soLogoPanY: Plasmoid.configuration.soLogoPanY
        soLogoRotation: Plasmoid.configuration.soLogoRotation
        soLogoAnimate: Plasmoid.configuration.soLogoAnimate
        soClockFontFamily: Plasmoid.configuration.soClockFontFamily
        soClockFontSize: Plasmoid.configuration.soClockFontSize
        soClockTextColor: Plasmoid.configuration.soClockTextColor
        onRequestSoClockAppearanceChange: function(family, size, color) {
            Plasmoid.configuration.soClockFontFamily = family
            Plasmoid.configuration.soClockFontSize = size
            Plasmoid.configuration.soClockTextColor = color
        }
        soledadColor: Plasmoid.configuration.soledadColor
        malvinaColor: Plasmoid.configuration.malvinaColor
        soledadGradientEnabled: Plasmoid.configuration.soledadGradientEnabled
        soledadGradientEnd: Plasmoid.configuration.soledadGradientEnd
        soledadGradientThird: Plasmoid.configuration.soledadGradientThird
        soledadGradientColorCount: Plasmoid.configuration.soledadGradientColorCount
        soledadGradientDirection: Plasmoid.configuration.soledadGradientDirection
        soledadGradientSyncBreathing: Plasmoid.configuration.soledadGradientSyncBreathing
        soledadGradientSyncIntensity: Plasmoid.configuration.soledadGradientSyncIntensity
        soledadGradientBreathingEnabled: Plasmoid.configuration.soledadGradientBreathingEnabled
        soledadGradientBreathingIntensity: Plasmoid.configuration.soledadGradientBreathingIntensity
        soledadGradientBreathingSpeed: Plasmoid.configuration.soledadGradientBreathingSpeed
        malvinaGradientSyncBreathing: Plasmoid.configuration.malvinaGradientSyncBreathing
        malvinaGradientBreathingEnabled: Plasmoid.configuration.malvinaGradientBreathingEnabled
        malvinaGradientBreathingIntensity: Plasmoid.configuration.malvinaGradientBreathingIntensity
        malvinaGradientBreathingSpeed: Plasmoid.configuration.malvinaGradientBreathingSpeed
        malvinaGradientEnabled: Plasmoid.configuration.malvinaGradientEnabled
        malvinaGradientEnd: Plasmoid.configuration.malvinaGradientEnd
        malvinaGradientThird: Plasmoid.configuration.malvinaGradientThird
        malvinaGradientColorCount: Plasmoid.configuration.malvinaGradientColorCount
        malvinaGradientDirection: Plasmoid.configuration.malvinaGradientDirection
        backgroundColor: Plasmoid.configuration.backgroundColor
        soledadOpacity: Plasmoid.configuration.soledadOpacity
        malvinaOpacity: Plasmoid.configuration.malvinaOpacity
        backgroundOpacity: Plasmoid.configuration.backgroundOpacity
        showBackground: Plasmoid.configuration.showBackground
        trayButtonColorOverride: Plasmoid.configuration.trayButtonColorOverride
        trayButtonColor: Plasmoid.configuration.trayButtonColor
        trayButtonOpacity: Plasmoid.configuration.trayButtonOpacity
        gripButtonColorOverride: Plasmoid.configuration.gripButtonColorOverride
        gripButtonColor: Plasmoid.configuration.gripButtonColor
        gripButtonOpacity: Plasmoid.configuration.gripButtonOpacity
        soActivityStyle: Plasmoid.configuration.soActivityStyle
        soActivityColor: Plasmoid.configuration.soActivityColor
        soActivityStroke: Plasmoid.configuration.soActivityStroke
        soActivityMotion: Plasmoid.configuration.soActivityMotion
        soActivityOrbitSpeed: Plasmoid.configuration.soActivityOrbitSpeed
        soActivityTrailPercent: Plasmoid.configuration.soActivityTrailPercent
        soActivityTrailStyle: Plasmoid.configuration.soActivityTrailStyle
        soActivityGlowColor: Plasmoid.configuration.soActivityGlowColor
        soActivityGlowIntensity: Plasmoid.configuration.soActivityGlowIntensity
        soActivityGlowSpread: Plasmoid.configuration.soActivityGlowSpread
        soActivityPulseSpeed: Plasmoid.configuration.soActivityPulseSpeed
        soActivityPulseDepth: Plasmoid.configuration.soActivityPulseDepth
        soActivityGlowGradient: Plasmoid.configuration.soActivityGlowGradient
        soActivityShowWhenEmpty: Plasmoid.configuration.soActivityShowWhenEmpty
        soActivityShowWhenOpen: Plasmoid.configuration.soActivityShowWhenOpen
        onRequestSoGlowChange: function(color, intensity, spread, speed, depth, gradient) {
            Plasmoid.configuration.soActivityGlowColor = color
            Plasmoid.configuration.soActivityGlowIntensity = intensity
            Plasmoid.configuration.soActivityGlowSpread = spread
            Plasmoid.configuration.soActivityPulseSpeed = speed
            Plasmoid.configuration.soActivityPulseDepth = depth
            Plasmoid.configuration.soActivityGlowGradient = gradient
        }
        onRequestSoActivityChange: function(style, color, stroke, allowMotion,
                                             speed, tailLength, lineStyle,
                                             showWhenEmpty, showWhenOpen) {
            Plasmoid.configuration.soActivityStyle = style
            Plasmoid.configuration.soActivityColor = color
            Plasmoid.configuration.soActivityStroke = stroke
            Plasmoid.configuration.soActivityMotion = allowMotion
            Plasmoid.configuration.soActivityOrbitSpeed = speed
            Plasmoid.configuration.soActivityTrailPercent = tailLength
            Plasmoid.configuration.soActivityTrailStyle = lineStyle
            Plasmoid.configuration.soActivityShowWhenEmpty = showWhenEmpty
            Plasmoid.configuration.soActivityShowWhenOpen = showWhenOpen
        }
        onRequestSoTextChange: function(label, textColor, background, opacity, fontFamily, fontSize, bold, image) {
            Plasmoid.configuration.soTextLabel = label
            Plasmoid.configuration.soTextColor = textColor
            Plasmoid.configuration.soTextBackground = background
            Plasmoid.configuration.soTextBackgroundOpacity = opacity
            Plasmoid.configuration.soTextFontFamily = fontFamily
            Plasmoid.configuration.soTextFontSize = fontSize
            Plasmoid.configuration.soTextBold = bold
            Plasmoid.configuration.soTextBackgroundImage = image
        }
        onRequestSoLogoChange: function(mode, path, shape, fitMode, zoom, panX, panY, allowGif, rotation) {
            Plasmoid.configuration.soLogoMode = mode
            Plasmoid.configuration.soLogoPath = path
            Plasmoid.configuration.soLogoShape = shape
            Plasmoid.configuration.soLogoFitMode = fitMode
            Plasmoid.configuration.soLogoZoom = zoom
            Plasmoid.configuration.soLogoPanX = panX
            Plasmoid.configuration.soLogoPanY = panY
            Plasmoid.configuration.soLogoAnimate = allowGif
            Plasmoid.configuration.soLogoRotation = rotation
        }
        onRequestGeometryChange: function(panel, soH, malH, soRadius, malRadius,
                                          soWidth, malWidth, buttonShape, buttonWidth,
                                          soShape, malShape, gripButtonShape, trayShape) {
            Plasmoid.configuration.panelHeight = panel
            Plasmoid.configuration.soledadHeight = soH
            Plasmoid.configuration.malvinaHeight = malH
            Plasmoid.configuration.soledadRadius = soRadius
            Plasmoid.configuration.malvinaRadius = malRadius
            Plasmoid.configuration.soledadMinWidth = soWidth
            Plasmoid.configuration.malvinaWidth = malWidth
            Plasmoid.configuration.soButtonFrameShape = buttonShape
            Plasmoid.configuration.soButtonWidth = buttonWidth
            Plasmoid.configuration.soledadShape = soShape
            Plasmoid.configuration.malvinaShape = malShape
            Plasmoid.configuration.gripShape = gripButtonShape
            Plasmoid.configuration.trayButtonShape = trayShape
        }
        onRequestGradientBreathingChange: function(sync, intensity, active, speed, syncIntensity) {
            Plasmoid.configuration.soledadGradientSyncBreathing = sync
            Plasmoid.configuration.soledadGradientBreathingIntensity = intensity
            Plasmoid.configuration.soledadGradientBreathingEnabled = active
            Plasmoid.configuration.soledadGradientBreathingSpeed = speed
            Plasmoid.configuration.soledadGradientSyncIntensity = syncIntensity
        }
        onRequestMalvinaGradientBreathingChange: function(sync, intensity, active, speed) {
            Plasmoid.configuration.malvinaGradientSyncBreathing = sync
            Plasmoid.configuration.malvinaGradientBreathingIntensity = intensity
            Plasmoid.configuration.malvinaGradientBreathingEnabled = active
            Plasmoid.configuration.malvinaGradientBreathingSpeed = speed
        }
        onRequestIslandGradientChange: function(a, b, c, d, e, f, g, h, i, j) {
            Plasmoid.configuration.soledadGradientEnabled = a
            Plasmoid.configuration.soledadGradientEnd = b
            Plasmoid.configuration.soledadGradientDirection = c
            Plasmoid.configuration.malvinaGradientEnabled = d
            Plasmoid.configuration.malvinaGradientEnd = e
            Plasmoid.configuration.malvinaGradientDirection = f
            Plasmoid.configuration.soledadGradientColorCount = g
            Plasmoid.configuration.soledadGradientThird = h
            Plasmoid.configuration.malvinaGradientColorCount = i
            Plasmoid.configuration.malvinaGradientThird = j
        }
        onRequestAppearanceChange: function(a, alphaA, b, alphaB, shown, bg,
                                            alphaBg, trayOverride, trayColor,
                                            trayOpacity, gripOverride,
                                            gripColor, gripOpacity) {
            Plasmoid.configuration.soledadColor = a
            Plasmoid.configuration.soledadOpacity = alphaA
            Plasmoid.configuration.malvinaColor = b
            Plasmoid.configuration.malvinaOpacity = alphaB
            Plasmoid.configuration.showBackground = shown
            Plasmoid.configuration.backgroundColor = bg
            Plasmoid.configuration.backgroundOpacity = alphaBg
            Plasmoid.configuration.trayButtonColorOverride = trayOverride
            Plasmoid.configuration.trayButtonColor = trayColor
            Plasmoid.configuration.trayButtonOpacity = trayOpacity
            Plasmoid.configuration.gripButtonColorOverride = gripOverride
            Plasmoid.configuration.gripButtonColor = gripColor
            Plasmoid.configuration.gripButtonOpacity = gripOpacity
        }
        onRequestAutoReturnRightChange: function(newValue) {
            Plasmoid.configuration.autoReturnRight = newValue
        }
        onRequestLauncherIslandVisibilityChange: function(newValue) {
            Plasmoid.configuration.showLauncherIsland = newValue
        }
        onRequestAutoHideMalvinaChange: function(newValue) {
            Plasmoid.configuration.autoHideMalvina = newValue
        }
        onRequestAutoCollapseSOChange: function(newValue) {
            Plasmoid.configuration.autoCollapseSO = newValue
        }
        onRequestSoClickMappingChange: function(leftOpensLauncher) {
            Plasmoid.configuration.soLeftClickOpensLauncher = leftOpensLauncher
        }
        onRequestThemeSlotChange: function(slot, data) {
            if (slot === "day") Plasmoid.configuration.themeDayJson = data
            else if (slot === "dayPrevious") Plasmoid.configuration.themeDayPreviousJson = data
            else if (slot === "night") Plasmoid.configuration.themeNightJson = data
            else if (slot === "custom") Plasmoid.configuration.themeCustomJson = data
            else if (slot === "library") Plasmoid.configuration.themeLibraryJson = data
        }
        onRequestLauncherStyleChange: function(layoutMode, shape, ownColor, color, slots) {
            Plasmoid.configuration.launcherCategoryLayout = layoutMode
            Plasmoid.configuration.launcherSwitchShape = shape
            Plasmoid.configuration.launcherSwitchColorOverride = ownColor
            Plasmoid.configuration.launcherSwitchColor = color
            Plasmoid.configuration.launcherMaxSlots = slots
        }
        onRequestLauncherOpacityChange: function(customOpacity, opacityValue) {
            Plasmoid.configuration.launcherOpacityOverride = customOpacity
            Plasmoid.configuration.launcherOpacity = opacityValue
        }
        onRequestLauncherIconDisplayChange: function(iconsWithNames) {
            Plasmoid.configuration.launcherIconsWithNames = iconsWithNames
        }
        onRequestMalvinaOptionsOpacityChange: function(customOpacity, opacityValue) {
            Plasmoid.configuration.malvinaOptionsOpacityOverride = customOpacity
            Plasmoid.configuration.malvinaOptionsOpacity = opacityValue
        }
        onRequestAutoCollapseTrayChange: function(newValue) {
            Plasmoid.configuration.autoCollapseTray = newValue
        }
    }
}
