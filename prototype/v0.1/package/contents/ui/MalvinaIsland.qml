// Componente de isla Malvina independiente de Soledad.
// Solo presenta su superficie, búsqueda y menú contextual.
// La coordinación general (espacio, KWin, autoocultamiento) queda en SmartBarContent.
import QtQuick
import QtQuick.Controls as QQC2

Item {
    id: island
    property bool actuallyVisible: true
    property bool hoverEnabled: true
    property bool allowSearch: true
    property real islandHeight: 44
    property real minIslandWidth: 52
    property real cornerRadius: 22
    property string islandShape: "rounded"
    property color islandColor: "#101e31"
    property real islandOpacity: 1
    property bool gradientEnabled: false
    property color gradientEnd: "#445577"
    property string gradientDirection: "topBottom"
    property var outlineSettings: ({style:"solid",width:1,color:"#4e8499",opacity:1})
    property string googleTemplate: "https://www.google.com/search?q={query}"
    property string duckTemplate: "https://duckduckgo.com/?q={query}"
    property string yahooTemplate: "https://search.yahoo.com/search?p={query}"
    property string chatGptUrl: "https://chatgpt.com/"
    property string geminiUrl: "https://gemini.google.com/app"
    property string claudeUrl: "https://claude.ai/new"

    signal hoverStateChanged(bool hovered)
    signal settingsRequested()
    signal hideRequested()
    signal installedAppsRequested()
    readonly property bool hotspotHovered: mouseHover.hovered
    readonly property bool searchExpanded: search.expanded
    readonly property real desiredWidth: Math.max(search.implicitWidth + 10, minIslandWidth)
    width: desiredWidth
    height: islandHeight

    function focusSearch() { if (allowSearch) search.focusSearch() }
    function closeSearch() { search.closeSearch() }

    HoverHandler {
        id: mouseHover
        enabled: island.hoverEnabled
        onHoveredChanged: island.hoverStateChanged(hovered)
    }

    Rectangle {
        id: surface
        visible: island.actuallyVisible
        anchors.fill: parent
        radius: island.islandShape === "square" ? 0 :
                Math.max(0, Math.min(island.cornerRadius, height / 2))
        topLeftRadius: island.islandShape === "leftSquareRightRound" ? 0 : radius
        bottomLeftRadius: island.islandShape === "leftSquareRightRound" ? 0 : radius
        topRightRadius: island.islandShape === "leftRoundRightSquare" ? 0 : radius
        bottomRightRadius: island.islandShape === "leftRoundRightSquare" ? 0 : radius
        color: island.gradientEnabled ? "transparent" :
               Qt.rgba(island.islandColor.r, island.islandColor.g,
                       island.islandColor.b, island.islandOpacity)
        border.width: 0
        Rectangle {
            anchors.fill: parent
            visible: island.gradientEnabled
            radius: parent.radius
            topLeftRadius: parent.topLeftRadius
            bottomLeftRadius: parent.bottomLeftRadius
            topRightRadius: parent.topRightRadius
            bottomRightRadius: parent.bottomRightRadius
            gradient: Gradient {
                orientation: (island.gradientDirection === "leftRight" ||
                              island.gradientDirection === "rightLeft")
                    ? Gradient.Horizontal : Gradient.Vertical
                GradientStop {
                    position: 0
                    color: island.gradientDirection === "bottomTop" ||
                           island.gradientDirection === "rightLeft"
                        ? Qt.rgba(island.gradientEnd.r, island.gradientEnd.g,
                                  island.gradientEnd.b, island.islandOpacity)
                        : Qt.rgba(island.islandColor.r, island.islandColor.g,
                                  island.islandColor.b, island.islandOpacity)
                }
                GradientStop {
                    position: 1
                    color: island.gradientDirection === "bottomTop" ||
                           island.gradientDirection === "rightLeft"
                        ? Qt.rgba(island.islandColor.r, island.islandColor.g,
                                  island.islandColor.b, island.islandOpacity)
                        : Qt.rgba(island.gradientEnd.r, island.gradientEnd.g,
                                  island.gradientEnd.b, island.islandOpacity)
                }
            }
        }
        OutlineStyle {
            anchors.fill: parent
            lineStyle: island.outlineSettings.style
            lineWidth: island.outlineSettings.width
            lineColor: island.outlineSettings.color
            lineOpacity: island.outlineSettings.opacity
            topLeft: surface.topLeftRadius
            topRight: surface.topRightRadius
            bottomLeft: surface.bottomLeftRadius
            bottomRight: surface.bottomRightRadius
        }
        MalvinaSearch {
            id: search
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            googleTemplate: island.googleTemplate
            duckTemplate: island.duckTemplate
            yahooTemplate: island.yahooTemplate
            chatGptUrl: island.chatGptUrl
            geminiUrl: island.geminiUrl
            claudeUrl: island.claudeUrl
            onRequestSettings: island.settingsRequested()
            onRequestInstalledApps: island.installedAppsRequested()
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: contextMenu.popup()
            }
            QQC2.Menu {
                id: contextMenu
                QQC2.MenuItem {
                    text: "Configuración de Malvina…"
                    onTriggered: island.settingsRequested()
                }
                QQC2.MenuItem {
                    text: "Ocultar Malvina (isla 2)"
                    onTriggered: island.hideRequested()
                }
            }
        }
    }
}
