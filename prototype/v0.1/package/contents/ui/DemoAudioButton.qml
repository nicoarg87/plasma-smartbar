// Control de SILENCIO SIMULADO para fichas ficticias de SO.
// No usa audio real: ni PipeWire, ni PulseAudio, ni KWin/TaskManager.
// Un mismo nombre de aplicación agrupa todas sus ventanas de muestra.
import QtQuick
import QtQuick.Controls as QQC2

QQC2.ToolButton {
    id: control
    required property var host
    required property string appName
    readonly property bool demoMuted: host.demoAppIsMuted(appName)

    visible: host.demoWindowControlsEnabled && !host.usingRealTasks &&
             host.demoHasRunningWindows
    implicitWidth: 28
    implicitHeight: 34
    focusPolicy: Qt.StrongFocus
    Accessible.name: (demoMuted ? "Activar" : "Silenciar") +
                     " audio simulado de " + appName
    QQC2.ToolTip.visible: false
    QQC2.ToolTip.text: (demoMuted ? "Reactivar" : "Silenciar") +
                       " sonido simulado de " + appName +
                       " (no modifica audio real)"

    onClicked: host.toggleDemoAppMute(appName)

    // Dibujamos el parlante y las ondas en Canvas: independientemente de
    // glifos Unicode o temas de íconos instalados en Qt/CachyOS.
    onDemoMutedChanged: { if (iconCanvas) iconCanvas.requestPaint() }
    contentItem: Item {
        Canvas {
            id: iconCanvas
            anchors.centerIn: parent
            width: 19
            height: 19
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                ctx.lineWidth = 1.7
                ctx.strokeStyle = control.demoMuted ? "#f6baba" : "#ffffff"
                ctx.fillStyle = control.demoMuted ? "#f6baba" : "#ffffff"
                // Cuerpo + bocina.
                ctx.beginPath()
                ctx.moveTo(2, 7)
                ctx.lineTo(5.5, 7)
                ctx.lineTo(10, 3.5)
                ctx.lineTo(10, 15.5)
                ctx.lineTo(5.5, 12)
                ctx.lineTo(2, 12)
                ctx.closePath()
                ctx.fill()
                if (control.demoMuted) {
                    // Una línea diagonal indica silenciado.
                    ctx.beginPath()
                    ctx.moveTo(12.5, 7)
                    ctx.lineTo(18, 12.5)
                    ctx.moveTo(18, 7)
                    ctx.lineTo(12.5, 12.5)
                    ctx.stroke()
                } else {
                    // Ondas saliendo del parlante.
                    ctx.beginPath()
                    ctx.arc(10.5, 9.5, 4, -0.85, 0.85)
                    ctx.moveTo(12.5 + 5.8 * Math.cos(-0.95),
                               9.5 + 5.8 * Math.sin(-0.95))
                    ctx.arc(10.5, 9.5, 7, -0.75, 0.75)
                    ctx.stroke()
                }
            }
        }
    }
}
