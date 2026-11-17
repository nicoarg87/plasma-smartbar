// Contorno decorativo reutilizable, sin capturar clics ni alterar geometría.
// Dibujar solo cuando cambien tamaño o preferencias, sin animación.
import QtQuick

Item {
    id: outline
    property color strokeColor: "#4e8499"
    property real strokeOpacity: 1
    property real strokeWidth: 1
    property string strokeStyle: "solid" // off, solid, dashed, dotted, double
    property real topLeftCorner: 8
    property real topRightCorner: 8
    property real bottomLeftCorner: 8
    property real bottomRightCorner: 8
    visible: strokeStyle !== "off" && strokeOpacity > 0 && strokeWidth > 0
    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
        Connections {
            target: outline
            function onStrokeColorChanged() { canvas.requestPaint() }
            function onStrokeOpacityChanged() { canvas.requestPaint() }
            function onStrokeWidthChanged() { canvas.requestPaint() }
            function onStrokeStyleChanged() { canvas.requestPaint() }
            function onTopLeftCornerChanged() { canvas.requestPaint() }
            function onTopRightCornerChanged() { canvas.requestPaint() }
            function onBottomLeftCornerChanged() { canvas.requestPaint() }
            function onBottomRightCornerChanged() { canvas.requestPaint() }
        }
        function shape(ctx, inset) {
            const w = width - 2 * inset
            const h = height - 2 * inset
            if (w <= 1 || h <= 1) return
            const cap = Math.max(0, Math.min(w, h) / 2)
            const tl = Math.min(outline.topLeftCorner, cap)
            const tr = Math.min(outline.topRightCorner, cap)
            const br = Math.min(outline.bottomRightCorner, cap)
            const bl = Math.min(outline.bottomLeftCorner, cap)
            ctx.beginPath()
            ctx.moveTo(inset + tl, inset)
            ctx.lineTo(inset + w - tr, inset)
            ctx.quadraticCurveTo(inset + w, inset, inset + w, inset + tr)
            ctx.lineTo(inset + w, inset + h - br)
            ctx.quadraticCurveTo(inset + w, inset + h, inset + w - br, inset + h)
            ctx.lineTo(inset + bl, inset + h)
            ctx.quadraticCurveTo(inset, inset + h, inset, inset + h - bl)
            ctx.lineTo(inset, inset + tl)
            ctx.quadraticCurveTo(inset, inset, inset + tl, inset)
            ctx.closePath()
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const t = Math.max(0.5, Math.min(5, outline.strokeWidth))
            const c = Qt.rgba(outline.strokeColor.r, outline.strokeColor.g,
                              outline.strokeColor.b, outline.strokeOpacity)
            ctx.strokeStyle = c
            ctx.lineWidth = t
            ctx.setLineDash(outline.strokeStyle === "dashed" ? [6, 4] :
                            outline.strokeStyle === "dotted" ? [1, 3] : [])
            const first = t / 2 + 0.5
            shape(ctx, first)
            ctx.stroke()
            if (outline.strokeStyle === "double") {
                ctx.setLineDash([])
                shape(ctx, first + t + 2)
                ctx.stroke()
            }
        }
    }
}
