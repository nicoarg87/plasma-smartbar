import QtQuick
import QtQuick.Controls as QQC2

// Interruptor de bandeja en la fila única de Soledad.
IslandButton {
                    id: trayToggleButton
                    required property var host
                    text: host.trayExpanded ? "▶" : "◀"
                    frameShape: host.trayButtonShape
                    useTileColor: true
                    tileColor: host.effectiveTrayButtonColor
                    // Si usa la paleta heredada, dejar ver el degradado
                    // debajo de la bandeja. Un color propio explícito se
                    // mantiene intacto.
                    tileOpacity: host.soledadGradientEnabled &&
                                 !host.trayButtonColorOverride
                        ? 0 : host.effectiveTrayButtonOpacity
                    outlineStyle: host.outlineConfig.tray.style
                    outlineWidth: host.outlineConfig.tray.width
                    outlineColor: host.displayOutlineTrayColor
                    outlineOpacity: host.outlineConfig.tray.opacity
                    onClicked: host.toggleTray()
                    QQC2.ToolTip.visible: false
                    QQC2.ToolTip.text: "Cajón de sistema: abrir/cerrar bandeja"
                }
