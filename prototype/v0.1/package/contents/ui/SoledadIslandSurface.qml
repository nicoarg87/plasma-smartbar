import QtQuick

// Fondo de Soledad: conserva relleno, degradado y recortes de bandeja/agarre.
Canvas {
    id: canvas
    required property var host
    required property var rowTarget
    required property var islandTarget
    required property var gripTarget
                visible: host.soledadShape !== "leftTip"
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onVisibleChanged: requestPaint()
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
                    function onSoledadRadiusChanged() { canvas.requestPaint() }
                    function onTrayExpandedChanged() { canvas.requestPaint() }
                    function onSoExpandedChanged() { canvas.requestPaint() }
                    function onTrayButtonColorOverrideChanged() { canvas.requestPaint() }
                    function onGripButtonColorOverrideChanged() { canvas.requestPaint() }
                }
                Connections {
                    target: rowTarget
                    function onWidthChanged() { canvas.requestPaint() }
                    function onXChanged() { canvas.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)
                    if (width <= 0 || height <= 0 || !visible) return
                    const tl = islandTarget.topLeftRadius
                    const tr = islandTarget.topRightRadius
                    const bl = islandTarget.bottomLeftRadius
                    const br = islandTarget.bottomRightRadius
                    ctx.beginPath()
                    ctx.moveTo(tl, 0)
                    ctx.lineTo(width - tr, 0)
                    ctx.quadraticCurveTo(width, 0, width, tr)
                    ctx.lineTo(width, height - br)
                    ctx.quadraticCurveTo(width, height, width - br, height)
                    ctx.lineTo(bl, height)
                    ctx.quadraticCurveTo(0, height, 0, height - bl)
                    ctx.lineTo(0, tl)
                    ctx.quadraticCurveTo(0, 0, tl, 0)
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
                    ctx.fill()
                    // Retirar el relleno SOLO detrás de los controles cuyo
                    // color/opacidad es independiente; no tocar zonas SO.
                    if (!host.soledadGradientEnabled) {
                    ctx.globalCompositeOperation = "destination-out"
                    ctx.fillStyle = "#ffffffff" // vaciar totalmente el fondo, incluso al 0%
                    for (let i = 0; i < rowTarget.children.length; ++i) {
                        const child = rowTarget.children[i]
                        if (!child || !child.visible) continue
                        const tray = child.useTileColor === true
                        const grip = child === gripTarget
                        if ((tray && !host.trayButtonColorOverride) ||
                            (grip && !host.gripButtonColorOverride) ||
                            (!tray && !grip)) continue
                        const x = rowTarget.x + child.x
                        const y = rowTarget.y + child.y
                        const w = child.width
                        const h = child.height
                        if (w <= 0 || h <= 0) continue
                        const radius = tray
                            ? (host.trayButtonShape === "square" ? 0 : Math.min(17, h/2))
                            : (host.gripShape === "square" ? 0 : 8)
                        const q = Math.min(radius, w/2, h/2)
                        ctx.beginPath()
                        ctx.moveTo(x+q, y)
                        ctx.lineTo(x+w-q, y)
                        ctx.quadraticCurveTo(x+w,y,x+w,y+q)
                        ctx.lineTo(x+w,y+h-q)
                        ctx.quadraticCurveTo(x+w,y+h,x+w-q,y+h)
                        ctx.lineTo(x+q,y+h)
                        ctx.quadraticCurveTo(x,y+h,x,y+h-q)
                        ctx.lineTo(x,y+q)
                        ctx.quadraticCurveTo(x,y,x+q,y)
                        ctx.closePath()
                        ctx.fill()
                    }
                    ctx.globalCompositeOperation = "source-over"
                    }
                }
            }
