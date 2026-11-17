// Contorno visual configurable. No interviene en mouse, foco ni geometría.
import QtQuick
Canvas {
    id: outline
    property color lineColor: "#4e8499"
    property real lineOpacity: 1
    property real lineWidth: 1
    property string lineStyle: "solid" // off, solid, double, dashed, dotted
    property real topLeft: 0
    property real topRight: 0
    property real bottomRight: 0
    property real bottomLeft: 0
    enabled: false
    visible: lineStyle !== "off" && lineWidth > 0 && lineOpacity > 0
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onLineOpacityChanged: requestPaint()
    onLineWidthChanged: requestPaint()
    onLineStyleChanged: requestPaint()
    onTopLeftChanged: requestPaint()
    onTopRightChanged: requestPaint()
    onBottomRightChanged: requestPaint()
    onBottomLeftChanged: requestPaint()

    function path(ctx, inset) {
        const w = Math.max(0, width - inset * 2)
        const h = Math.max(0, height - inset * 2)
        const cap = Math.min(w / 2, h / 2)
        const tl = Math.max(0, Math.min(cap, topLeft - inset))
        const tr = Math.max(0, Math.min(cap, topRight - inset))
        const br = Math.max(0, Math.min(cap, bottomRight - inset))
        const bl = Math.max(0, Math.min(cap, bottomLeft - inset))
        const x = inset, y = inset
        ctx.beginPath()
        ctx.moveTo(x + tl, y)
        ctx.lineTo(x + w - tr, y)
        ctx.quadraticCurveTo(x + w, y, x + w, y + tr)
        ctx.lineTo(x + w, y + h - br)
        ctx.quadraticCurveTo(x + w, y + h, x + w - br, y + h)
        ctx.lineTo(x + bl, y + h)
        ctx.quadraticCurveTo(x, y + h, x, y + h - bl)
        ctx.lineTo(x, y + tl)
        ctx.quadraticCurveTo(x, y, x + tl, y)
        ctx.closePath()
    }
    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        if (!visible || width <= 0 || height <= 0) return
        const sw = Math.max(0.5, Math.min(5, lineWidth))
        ctx.strokeStyle = Qt.rgba(lineColor.r, lineColor.g, lineColor.b,
                                  Math.max(0, Math.min(1, lineOpacity)))
        ctx.lineWidth = sw
        if (lineStyle === "dashed")
            ctx.setLineDash([sw * 4, sw * 2.5])
        else if (lineStyle === "dotted")
            ctx.setLineDash([sw, sw * 2])
        else
            ctx.setLineDash([])
        path(ctx, sw / 2 + 0.5)
        ctx.stroke()
        if (lineStyle === "double") {
            ctx.lineWidth = sw // ambos trazos deben tener exactamente el mismo grosor
            path(ctx, sw * 2 + 1)
            ctx.stroke()
        }
    }
}
