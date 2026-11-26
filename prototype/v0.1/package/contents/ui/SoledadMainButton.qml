import QtQuick
import QtQuick.Controls as QQC2

// Botón SO: conservamos clic izquierdo/derecho, pulsación larga y apariencia.
IslandButton {
    id: button
    required property var host
    required property var islandTarget
    required property var launcherPopup
                    text: host.soLogoMode === "text" ? host.soTextLabel : "SO"
                    customTextMode: host.soLogoMode === "text"
                    customTextColor: host.displaySoTextColor
                    customTextBackground: host.displaySoTextBackground
                    customTextBackgroundOpacity: host.soTextBackgroundOpacity
                    customTextFontFamily: host.soTextFontFamily
                    customTextFontSize: host.soTextFontSize
                    customTextBold: host.soTextBold
                    customTextBackgroundImage: host.soTextBackgroundImage
                    accent: true
                    activityCount: host.soWindowCount
                    activityEffect: host.soActivityStyle
                    activityColor: host.displaySoActivityColor
                    activityStroke: host.soActivityStroke
                    activityMotionAllowed: host.soActivityMotion
                    activityOrbitSpeed: host.soActivityOrbitSpeed
                    activityTrailPercent: host.soActivityTrailPercent
                    activityTrailStyle: host.soActivityTrailStyle
                    activityGlowColor: host.displaySoActivityGlowColor
                    activityGlowIntensity: host.soActivityGlowIntensity
                    activityGlowSpread: host.soActivityGlowSpread
                    activityPulseSpeed: host.soActivityPulseSpeed
                    activityPulseDepth: host.soActivityPulseDepth
                    activityUseExternalPulse: host.sharedBreathingActive
                    activityExternalPulsePhase: host.sharedBreathingPhase
                    activityGlowGradient: host.soActivityGlowGradient
                    activityShowWhenEmpty: host.soActivityShowWhenEmpty
                    activityShowWhenOpen: host.soActivityShowWhenOpen
                    iconSource: host.activeSoLogo
                    iconAnimated: host.activeSoLogoIsGif
                    // Durante la demostración el logo de fondo queda oculto;
                    // no reproducir un segundo GIF innecesariamente.
                    iconAnimationEnabled: host.soLogoAnimate && !host.barColorPreviewActive
                    clockVisible: host.soClockVisible
                    clockPhase: host.soClockPhase
                    clockTime: host.soClockTime
                    clockDate: host.soClockDate
                    clockFontFamily: host.soClockFontFamily
                    clockFontSize: host.soClockFontSize
                    clockTextColor: host.displaySoClockTextColor
                    iconShape: host.soLogoShape
                    iconFitMode: host.soLogoFitMode
                    iconZoom: host.soLogoZoom
                    iconPanX: host.soLogoPanX
                    iconPanY: host.soLogoPanY
                    iconRotation: host.soLogoRotation
                    frameShape: host.soButtonFrameShape
                    preferredButtonHeight: Math.max(30, islandTarget.height - 10)
                    preferredButtonWidth: host.soButtonFrameShape === "square"
                        ? Math.max(40, islandTarget.height - 8)
                        : Math.max(44, host.soButtonWidth)

                    // Clic corto: por defecto lanzador de apps; la opción
                    // inversa muestra ventanas abiertas. Mantener ~400 ms
                    // conserva el lanzador sin disparar el clic al soltar.
                    onPressed: {
                        host.soTooltipSuppressed = true
                        host.soHoldTriggered = false
                        host.soLauncherOpenOnLeftPress = launcherPopup.visible &&
                            host.installedLauncherSource === "so"
                        soHoldTimer.restart()
                    }
                    onHoveredChanged: {
                        if (!hovered) host.soTooltipSuppressed = false
                    }
                    onReleased: soHoldTimer.stop()
                    onCanceled: soHoldTimer.stop()
                    onClicked: {
                        soHoldTimer.stop()
                        if (!host.soHoldTriggered) {
                            host.triggerSOButton(true, host.soLauncherOpenOnLeftPress)
                        }
                        host.soLauncherOpenOnLeftPress = false
                        host.soHoldTriggered = false
                    }
                    Timer {
                        id: soHoldTimer
                        interval: 400
                        repeat: false
                        onTriggered: {
                            host.soHoldTriggered = true
                            host.openInstalledLauncher("so")
                        }
                    }

                    // Derecho sobre SO usa la acción configurada, por
                    // defecto ventanas abiertas. Las preferencias siguen
                    // exclusivamente en los seis puntos de Soledad.
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Menu ||
                            (event.key === Qt.Key_F10 &&
                             (event.modifiers & Qt.ShiftModifier))) {
                            host.triggerSOButton(false)
                            event.accepted = true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressed: {
                            host.soTooltipSuppressed = true
                            host.soLauncherOpenOnRightPress = launcherPopup.visible &&
                                host.installedLauncherSource === "so"
                        }
                        onClicked: {
                            host.triggerSOButton(false, host.soLauncherOpenOnRightPress)
                            host.soLauncherOpenOnRightPress = false
                        }
                    }

                    QQC2.ToolTip.visible: false
                    QQC2.ToolTip.delay: 900
                    QQC2.ToolTip.text: host.soLeftClickOpensLauncher
                        ? "Clic izquierdo: Launcher de aplicaciones\nClic derecho: Cajón de aplicaciones"
                        : "Clic izquierdo: Cajón de aplicaciones\nClic derecho: Launcher de aplicaciones"
                }
