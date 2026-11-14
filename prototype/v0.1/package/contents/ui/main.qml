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
    Layout.minimumHeight: 48
    Layout.preferredHeight: 48
    Layout.maximumHeight: 48
    implicitWidth: 960
    implicitHeight: 48

    onWidthChanged: console.log("SmartBar v0.1: ancho del applet Plasma =", width)

    SmartBarContent {
        id: demo
        anchors.fill: parent

        // La configuración de Plasma se mantiene en el envoltorio;
        // SmartBarContent no depende de Plasmoid y es reutilizable.
        autoReturnRight: Plasmoid.configuration.autoReturnRight
        launcherIslandVisible: Plasmoid.configuration.showLauncherIsland
        autoCollapseSO: Plasmoid.configuration.autoCollapseSO
        autoCollapseTray: Plasmoid.configuration.autoCollapseTray
        soLogoMode: Plasmoid.configuration.soLogoMode
        soLogoPath: Plasmoid.configuration.soLogoPath
        soLogoShape: Plasmoid.configuration.soLogoShape
        soLogoFitMode: Plasmoid.configuration.soLogoFitMode
        soLogoZoom: Plasmoid.configuration.soLogoZoom
        soLogoPanX: Plasmoid.configuration.soLogoPanX
        soLogoPanY: Plasmoid.configuration.soLogoPanY
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
        onRequestSoActivityChange: function(style, color, stroke, allowMotion) {
            Plasmoid.configuration.soActivityStyle = style
            Plasmoid.configuration.soActivityColor = color
            Plasmoid.configuration.soActivityStroke = stroke
            Plasmoid.configuration.soActivityMotion = allowMotion
        }
        onRequestSoLogoChange: function(mode, path, shape, fitMode, zoom, panX, panY, allowGif) {
            Plasmoid.configuration.soLogoMode = mode
            Plasmoid.configuration.soLogoPath = path
            Plasmoid.configuration.soLogoShape = shape
            Plasmoid.configuration.soLogoFitMode = fitMode
            Plasmoid.configuration.soLogoZoom = zoom
            Plasmoid.configuration.soLogoPanX = panX
            Plasmoid.configuration.soLogoPanY = panY
            Plasmoid.configuration.soLogoAnimate = allowGif
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
        onRequestAutoCollapseSOChange: function(newValue) {
            Plasmoid.configuration.autoCollapseSO = newValue
        }
        onRequestAutoCollapseTrayChange: function(newValue) {
            Plasmoid.configuration.autoCollapseTray = newValue
        }
    }
}
