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
        taskDisplayMode: Plasmoid.configuration.taskDisplayMode
        onRequestTaskDisplayModeChange: function(mode) {
            Plasmoid.configuration.taskDisplayMode = mode
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
        soledadGradientDirection: Plasmoid.configuration.soledadGradientDirection
        soledadGradientSyncBreathing: Plasmoid.configuration.soledadGradientSyncBreathing
        soledadGradientBreathingIntensity: Plasmoid.configuration.soledadGradientBreathingIntensity
        malvinaGradientEnabled: Plasmoid.configuration.malvinaGradientEnabled
        malvinaGradientEnd: Plasmoid.configuration.malvinaGradientEnd
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
        onRequestGradientBreathingChange: function(enabled, intensity) {
            Plasmoid.configuration.soledadGradientSyncBreathing = enabled
            Plasmoid.configuration.soledadGradientBreathingIntensity = intensity
        }
        onRequestIslandGradientChange: function(a, b, c, d, e, f) {
            Plasmoid.configuration.soledadGradientEnabled = a
            Plasmoid.configuration.soledadGradientEnd = b
            Plasmoid.configuration.soledadGradientDirection = c
            Plasmoid.configuration.malvinaGradientEnabled = d
            Plasmoid.configuration.malvinaGradientEnd = e
            Plasmoid.configuration.malvinaGradientDirection = f
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
        onRequestAutoCollapseTrayChange: function(newValue) {
            Plasmoid.configuration.autoCollapseTray = newValue
        }
    }
}
