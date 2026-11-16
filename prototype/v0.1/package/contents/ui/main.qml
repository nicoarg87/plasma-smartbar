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
        autoReturnRight: Plasmoid.configuration.autoReturnRight
        launcherIslandVisible: Plasmoid.configuration.showLauncherIsland
        autoHideMalvina: Plasmoid.configuration.autoHideMalvina
        autoCollapseSO: Plasmoid.configuration.autoCollapseSO
        autoCollapseTray: Plasmoid.configuration.autoCollapseTray
        soLogoMode: Plasmoid.configuration.soLogoMode
        soLogoPath: Plasmoid.configuration.soLogoPath
        soLogoShape: Plasmoid.configuration.soLogoShape
        soLogoFitMode: Plasmoid.configuration.soLogoFitMode
        soLogoZoom: Plasmoid.configuration.soLogoZoom
        soLogoPanX: Plasmoid.configuration.soLogoPanX
        soLogoPanY: Plasmoid.configuration.soLogoPanY
        soLogoRotation: Plasmoid.configuration.soLogoRotation
        soLogoAnimate: Plasmoid.configuration.soLogoAnimate
        soledadColor: Plasmoid.configuration.soledadColor
        malvinaColor: Plasmoid.configuration.malvinaColor
        backgroundColor: Plasmoid.configuration.backgroundColor
        soledadOpacity: Plasmoid.configuration.soledadOpacity
        malvinaOpacity: Plasmoid.configuration.malvinaOpacity
        backgroundOpacity: Plasmoid.configuration.backgroundOpacity
        showBackground: Plasmoid.configuration.showBackground
        soActivityStyle: Plasmoid.configuration.soActivityStyle
        soActivityColor: Plasmoid.configuration.soActivityColor
        soActivityStroke: Plasmoid.configuration.soActivityStroke
        soActivityMotion: Plasmoid.configuration.soActivityMotion
        soActivityOrbitSpeed: Plasmoid.configuration.soActivityOrbitSpeed
        soActivityTrailPercent: Plasmoid.configuration.soActivityTrailPercent
        soActivityTrailStyle: Plasmoid.configuration.soActivityTrailStyle
        soActivityShowWhenEmpty: Plasmoid.configuration.soActivityShowWhenEmpty
        soActivityShowWhenOpen: Plasmoid.configuration.soActivityShowWhenOpen
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
        onRequestAppearanceChange: function(a, alphaA, b, alphaB, shown, bg, alphaBg) {
            Plasmoid.configuration.soledadColor = a
            Plasmoid.configuration.soledadOpacity = alphaA
            Plasmoid.configuration.malvinaColor = b
            Plasmoid.configuration.malvinaOpacity = alphaB
            Plasmoid.configuration.showBackground = shown
            Plasmoid.configuration.backgroundColor = bg
            Plasmoid.configuration.backgroundOpacity = alphaBg
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
