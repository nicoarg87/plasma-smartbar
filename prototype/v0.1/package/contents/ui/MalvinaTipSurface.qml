import QtQuick

// Superficie triangular aislada; no altera la geometría ni los controles del host.
Canvas {
    id: canvas
    required property var host
                visible: host.malvinaShape === "leftTip"
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: if (visible) requestPaint()
                Connections {
                    target: host
                    function onMalvinaColorChanged() { canvas.requestPaint() }
                    function onDisplayMalvinaColorChanged() { canvas.requestPaint() }
                    function onDisplayMalvinaGradientEndChanged() { canvas.requestPaint() }
                    function onDisplayMalvinaGradientThirdChanged() { canvas.requestPaint() }
                    function onDisplayOutlineMalvinaColorChanged() { canvas.requestPaint() }
                    function onMalvinaGradientEnabledChanged() { canvas.requestPaint() }
                    function onMalvinaGradientEndChanged() { canvas.requestPaint() }
                    function onMalvinaGradientThirdChanged() { canvas.requestPaint() }
                    function onMalvinaGradientColorCountChanged() { canvas.requestPaint() }
                    function onMalvinaGradientDirectionChanged() { canvas.requestPaint() }
                    function onMalvinaOpacityChanged() { canvas.requestPaint() }
                    function onMalvinaShapeChanged() { canvas.requestPaint() }
                    function onMalvinaGradientBreathingFactorChanged() { canvas.requestPaint() }
                    function onOutlineConfigChanged() { canvas.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    if (!visible || width < 30 || height < 4) return
                    ctx.beginPath()
                    ctx.moveTo(1, height / 2)
                    ctx.lineTo(24, 1)
                    ctx.lineTo(width - 1, 1)
                    ctx.lineTo(width - 1, height - 1)
                    ctx.lineTo(24, height - 1)
                    ctx.closePath()
                    const alpha = host.malvinaOpacity * host.malvinaGradientBreathingFactor
                    if (host.malvinaGradientEnabled) {
                        const dir = host.malvinaGradientDirection
                        const g = ctx.createLinearGradient(
                            dir === "leftRight" ? 0 : dir === "rightLeft" ? width : 0,
                            dir === "topBottom" ? 0 : dir === "bottomTop" ? height : 0,
                            dir === "leftRight" ? width : dir === "rightLeft" ? 0 : 0,
                            dir === "topBottom" ? height : dir === "bottomTop" ? 0 : 0)
                        // La dirección ya está dada por las coordenadas.
                        // No invertir además los colores: invertir dos veces
                        // anulaba el efecto de derecha→izquierda.
                        g.addColorStop(0, Qt.rgba(host.displayMalvinaColor.r,
                            host.displayMalvinaColor.g, host.displayMalvinaColor.b, alpha))
                        if (host.malvinaGradientColorCount === 3) {
                            g.addColorStop(0.5, Qt.rgba(host.displayMalvinaGradientEnd.r,
                                host.displayMalvinaGradientEnd.g, host.displayMalvinaGradientEnd.b, alpha))
                            g.addColorStop(1, Qt.rgba(host.displayMalvinaGradientThird.r,
                                host.displayMalvinaGradientThird.g, host.displayMalvinaGradientThird.b, alpha))
                        } else {
                            g.addColorStop(1, Qt.rgba(host.displayMalvinaGradientEnd.r,
                                host.displayMalvinaGradientEnd.g, host.displayMalvinaGradientEnd.b, alpha))
                        }
                        ctx.fillStyle = g
                    } else {
                        ctx.fillStyle = Qt.rgba(host.displayMalvinaColor.r, host.displayMalvinaColor.g,
                                                host.displayMalvinaColor.b, alpha)
                    }
                    ctx.fill()
                    const outline = host.outlineConfig.malvina
                    if (outline && outline.style !== "none" && outline.width > 0) {
                        ctx.lineWidth = outline.width
                        const c = host.displayOutlineMalvinaColor.toString()
                        ctx.strokeStyle = c
                        ctx.globalAlpha = outline.opacity
                        ctx.stroke()
                        ctx.globalAlpha = 1
                    }
                }
            }
