import QtQuick
import QtQuick.Controls as QQC2

// Isla Malvina de la maqueta y ensayo conjunto; mantiene sus acciones originales.
Item {
    id: malvinaHotspot
    required property var host
    required property var revealTimerTarget
    required property var hideTimerTarget
    property alias searchTarget: malvinaSearch
    property alias launcherTarget: launcherIsland
    property alias hoverTarget: malvinaHotspotHover
            // Geometría visual original intacta. Solo ampliamos el margen
            // sensible del HoverHandler, no el ancho de Malvina.
            width: Math.max(malvinaSearch.implicitWidth +
                            (host.malvinaShape === "leftTip" ? 34 : 10),
                            host.malvinaWidth)
            height: Math.max(32, Math.min(host.fixedHeight - 4, host.malvinaHeight))
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
                enabled: !host.autoRevealBlocked && host.launcherIslandVisible
                onHoveredChanged: {
                    if (hovered) {
                        hideTimerTarget.stop()
                        if (host.malvinaDismissedAfterSearch &&
                                !host.malvinaDismissRearmed) return
                        if (!host.autoRevealBlocked &&
                                (host.autoHideMalvina || host.malvinaDismissedAfterSearch))
                            revealTimerTarget.restart()
                    } else {
                        revealTimerTarget.stop()
                        if (host.malvinaDismissedAfterSearch)
                            host.malvinaDismissRearmed = true
                        if (!host.malvinaPopupActive)
                            hideTimerTarget.restart()
                    }
                }
            }

            Rectangle {
            id: launcherIsland
            visible: host.malvinaActuallyVisible
            anchors.fill: parent
            radius: host.malvinaShape === "square" || host.malvinaShape === "leftTip" ? 0 :
                host.malvinaShape === "capsule" ? height / 2 :
                Math.max(0, Math.min(host.malvinaRadius, height / 2))
            topLeftRadius: host.malvinaShape === "leftSquareRightRound" ? 0 : radius
            bottomLeftRadius: host.malvinaShape === "leftSquareRightRound" ? 0 : radius
            topRightRadius: host.malvinaShape === "leftRoundRightSquare" ? 0 : radius
            bottomRightRadius: host.malvinaShape === "leftRoundRightSquare" ? 0 : radius
            color: host.malvinaShape === "leftTip" || host.malvinaGradientEnabled ? "transparent" :
                Qt.rgba(host.displayMalvinaColor.r, host.displayMalvinaColor.g,
                        host.displayMalvinaColor.b, host.malvinaOpacity * host.malvinaGradientBreathingFactor)
            Rectangle {
                anchors.fill: parent
                visible: host.malvinaGradientEnabled && host.malvinaShape !== "leftTip"
                radius: parent.radius
                topLeftRadius: parent.topLeftRadius
                topRightRadius: parent.topRightRadius
                bottomLeftRadius: parent.bottomLeftRadius
                bottomRightRadius: parent.bottomRightRadius
                gradient: Gradient {
                    orientation: (host.malvinaGradientDirection === "leftRight" ||
                                  host.malvinaGradientDirection === "rightLeft")
                        ? Gradient.Horizontal : Gradient.Vertical
                    GradientStop {
                        position: 0
                        color: {
                            const reversed = host.malvinaGradientDirection === "rightLeft" ||
                                             host.malvinaGradientDirection === "bottomTop"
                            const value = reversed
                                ? (host.malvinaGradientColorCount === 3
                                   ? host.displayMalvinaGradientThird : host.displayMalvinaGradientEnd)
                                : host.displayMalvinaColor
                            return Qt.rgba(value.r, value.g, value.b,
                                host.malvinaOpacity * host.malvinaGradientBreathingFactor)
                        }
                    }
                    GradientStop {
                        position: host.malvinaGradientColorCount === 3 ? 0.5 : 1
                        color: {
                            const reversed = host.malvinaGradientDirection === "rightLeft" ||
                                             host.malvinaGradientDirection === "bottomTop"
                            const value = host.malvinaGradientColorCount === 3
                                ? host.displayMalvinaGradientEnd
                                : (reversed ? host.displayMalvinaColor : host.displayMalvinaGradientEnd)
                            return Qt.rgba(value.r, value.g, value.b,
                                host.malvinaOpacity * host.malvinaGradientBreathingFactor)
                        }
                    }
                    GradientStop {
                        position: 1
                        color: {
                            const reversed = host.malvinaGradientDirection === "rightLeft" ||
                                             host.malvinaGradientDirection === "bottomTop"
                            const value = reversed ? host.displayMalvinaColor
                                : (host.malvinaGradientColorCount === 3
                                   ? host.displayMalvinaGradientThird : host.displayMalvinaGradientEnd)
                            return Qt.rgba(value.r, value.g, value.b,
                                host.malvinaOpacity * host.malvinaGradientBreathingFactor)
                        }
                    }
                }
            }
            border.width: 0
            // Misma punta izquierda que Soledad. La zona estrecha queda libre
            // de botones para mantener clics y foco dentro de superficies útiles.
            MalvinaTipSurface {
                host: root
                anchors.fill: parent
            }
            OutlineStyle {
                visible: host.malvinaShape !== "leftTip"
                anchors.fill: parent
                lineStyle: host.outlineConfig.malvina.style
                lineWidth: host.outlineConfig.malvina.width
                lineColor: host.displayOutlineMalvinaColor
                lineOpacity: host.outlineConfig.malvina.opacity
                topLeft: launcherIsland.topLeftRadius
                topRight: launcherIsland.topRightRadius
                bottomLeft: launcherIsland.bottomLeftRadius
                bottomRight: launcherIsland.bottomRightRadius
            }
            MalvinaSearch {
                id: malvinaSearch
                optionsViewportWidthOverride: host.malvinaOptionsViewportWidth
                gearButtonShape: host.malvinaGearButtonShape
                searchButtonShape: host.malvinaSearchButtonShape
                islandShape: host.malvinaShape
                islandRadius: host.malvinaRadius
                islandColor: host.displayMalvinaColor
                islandOpacity: host.malvinaOpacity * host.malvinaGradientBreathingFactor
                optionsPanelOpacity: host.malvinaOptionsOpacityOverride
                    ? host.malvinaOptionsOpacity : host.malvinaOpacity
                optionsPanelBreathingFactor: host.malvinaGradientBreathingFactor
                islandGradientEnabled: host.malvinaGradientEnabled
                islandGradientEnd: host.displayMalvinaGradientEnd
                islandGradientThird: host.displayMalvinaGradientThird
                islandGradientColorCount: host.malvinaGradientColorCount
                islandGradientDirection: host.malvinaGradientDirection
                islandOutlineColor: host.displayOutlineMalvinaColor
                islandOutlineOpacity: host.outlineConfig.malvina.opacity
                islandOutlineWidth: host.outlineConfig.malvina.width
                islandOutlineStyle: host.outlineConfig.malvina.style
                anchors.left: parent.left
                anchors.leftMargin: host.malvinaShape === "leftTip" ? 27 : 5
                anchors.verticalCenter: parent.verticalCenter
                // Los 73 px de botones también cuentan en el límite de media ventana.
                maximumSearchWidth: Math.max(180, Math.min(520, host.width / 2 - 82))
                webGoogleEnabled: host.malvinaWebGoogleEnabled
                webDuckEnabled: host.malvinaWebDuckEnabled
                webYahooEnabled: host.malvinaWebYahooEnabled
                googleName: host.malvinaGoogleName
                duckName: host.malvinaDuckName
                yahooName: host.malvinaYahooName
                chatGptName: host.malvinaChatGptName
                geminiName: host.malvinaGeminiName
                claudeName: host.malvinaClaudeName
                extraWeb: host.malvinaExtraWeb
                extraAi: host.malvinaExtraAi
                hiddenWeb: host.malvinaHiddenWeb
                hiddenAi: host.malvinaHiddenAi
                compactAi: host.malvinaCompactAi
                taskFrameShape: host.taskFrameShape
                taskFrameColor: host.displayTaskFrameColor
                taskFrameOpacity: host.taskFrameOpacity
                taskFrameWidth: host.taskFrameWidth
                webFirst: host.malvinaWebFirst
                webOrder: host.malvinaWebOrder
                aiOrder: host.malvinaAiOrder
                onRequestOrderChange: function(firstWeb, webOrder, aiOrder) {
                    host.requestMalvinaOrderChange(firstWeb, webOrder, aiOrder)
                }
                googleTemplate: host.malvinaGoogleUrl
                duckTemplate: host.malvinaDuckUrl
                yahooTemplate: host.malvinaYahooUrl
                allowChatGptPrefill: host.malvinaAllowChatGpt
                allowGeminiPrefill: host.malvinaAllowGemini
                allowClaudePrefill: host.malvinaAllowClaude
                chatGptUrl: host.malvinaChatGptUrl
                geminiUrl: host.malvinaGeminiUrl
                claudeUrl: host.malvinaClaudeUrl
                onExpandedChanged: {
                    // Reapertura explícita por lupa/teclado: mostrarla.
                    if (expanded) {
                        host.malvinaDismissedAfterSearch = false
                        host.malvinaDismissRearmed = false
                    }
                }
                onRequestOpenUrl: function(url) {
                    // Respeta la opción de un navegador para toda Malvina.
                    // Si el ejecutable elegido desaparece, avisar y usar KDE.
                    let choice = "system"
                    for (let i = 0; i < host.malvinaBrowserChoices.length; ++i) {
                        if (host.malvinaBrowserChoices[i].id === host.malvinaBrowserId) {
                            choice = host.malvinaBrowserId
                            break
                        }
                    }
                    let accepted = false
                    if (host.malvinaBrowserBackend !== null &&
                        typeof host.malvinaBrowserBackend.launchWebUrl === "function") {
                        accepted = host.malvinaBrowserBackend.launchWebUrl(choice, url)
                    } else {
                        // El plasmoide/visor QML aún no incluye puente nativo.
                        // Conservar apertura KDE; no fingir selección específica.
                        accepted = Qt.openUrlExternally(url)
                    }
                    if (accepted) {
                        host.dismissMalvinaAfterSearch()
                    } else {
                        console.warn("Malvina: no se pudo iniciar el navegador:", choice)
                    }
                }
                onRequestSettings: host.openMalvinaSettings()
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: launcherContextMenu.popup()
                }
                QQC2.Menu {
                    id: launcherContextMenu
                    QQC2.MenuItem {
                        text: "Configuración de Malvina…"
                        onTriggered: host.openMalvinaSettings()
                    }
                    // La misma acción de la prueba del visor, sin duplicar
                    // temporizadores, lógica ni botones en la barra.
                    QQC2.MenuItem {
                        visible: host.themeScheduleRuntimeEnabled
                        text: "siguiente tema y wallpaper"
                        enabled: host.themeWallpaperPreviewAvailable
                        onTriggered: host.triggerThemeWallpaperPreview()
                    }
                    QQC2.MenuItem {
                        text: "Ocultar Malvina (isla 2)"
                        onTriggered: host.setLauncherIslandVisible(false)
                    }
                }
            }
            }
        }
