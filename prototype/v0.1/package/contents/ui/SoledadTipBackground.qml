import QtQuick

// Superficie triangular aislada; no altera la geometría ni los controles del host.
Canvas {
    id: canvas
    required property var host
                visible: host.soledadShape === "leftTip"
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                Connections {
                    target: host
                    function onSoledadColorChanged() { canvas.requestPaint() }
                    function onDisplaySoledadColorChanged() { canvas.requestPaint() }
                    function onDisplaySoledadGradientEndChanged() { canvas.requestPaint() }
                    function onDisplaySoledadGradientThirdChanged() { canvas.requestPaint() }
                    function onSoledadGradientEnabledChanged() { canvas.requestPaint() }
                    function onSoledadGradientEndChanged() { canvas.requestPaint() }
                    function onSoledadGradientThirdChanged() { canvas.requestPaint() }
                    function onSoledadGradientColorCountChanged() { canvas.requestPaint() }
                    function onSoledadGradientDirectionChanged() { canvas.requestPaint() }
                    function onGradientBreathingFactorChanged() {
                        if (host.soledadGradientEnabled) canvas.requestPaint()
                    }
                    function onSoledadOpacityChanged() { canvas.requestPaint() }
                    function onSoledadShapeChanged() { canvas.requestPaint() }
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
                    if (host.soledadGradientEnabled) {
                        const dir = host.soledadGradientDirection
                        const g = ctx.createLinearGradient(
                            dir === "leftRight" ? 0 : dir === "rightLeft" ? width : 0,
                            dir === "topBottom" ? 0 : dir === "bottomTop" ? height : 0,
                            dir === "leftRight" ? width : dir === "rightLeft" ? 0 : 0,
                            dir === "topBottom" ? height : dir === "bottomTop" ? 0 : 0)
                        g.addColorStop(0, Qt.rgba(host.displaySoledadColor.r, host.displaySoledadColor.g,
                                                  host.displaySoledadColor.b, host.soledadOpacity * host.gradientBreathingFactor))
                        if (host.soledadGradientColorCount === 3) {
                            g.addColorStop(0.5, Qt.rgba(host.displaySoledadGradientEnd.r,
                                host.displaySoledadGradientEnd.g, host.displaySoledadGradientEnd.b,
                                host.soledadOpacity * host.gradientBreathingFactor))
                            g.addColorStop(1, Qt.rgba(host.displaySoledadGradientThird.r,
                                host.displaySoledadGradientThird.g, host.displaySoledadGradientThird.b,
                                host.soledadOpacity * host.gradientBreathingFactor))
                        } else {
                            g.addColorStop(1, Qt.rgba(host.displaySoledadGradientEnd.r,
                                host.displaySoledadGradientEnd.g, host.displaySoledadGradientEnd.b,
                                host.soledadOpacity * host.gradientBreathingFactor))
                        }
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(host.displaySoledadColor.r, host.displaySoledadColor.g,
                                                host.displaySoledadColor.b, host.soledadOpacity)
                    }
                    ctx.strokeStyle = "#4e8499"
                    ctx.lineWidth = 1
                    ctx.fill()
                    ctx.stroke()
                }
            }
