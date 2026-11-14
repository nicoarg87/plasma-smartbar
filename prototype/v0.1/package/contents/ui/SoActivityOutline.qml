// Borde de actividad del botón SO; fuera del contorno del logo.
// Los trazos se dibujan en un Canvas diminuto (32x32). Timer activo
// SOLO cuando hay ventanas y el usuario eligió animación opcional.
import QtQuick

Canvas {
    id: outline
    property string shape: "square"
    property color accentColor: "#35d7ff"
    property real strokeSize: 1.0
    property string effectStyle: "steady" // off, steady, orbit
    property bool hasWindows: false
    property bool allowMotion: true
    property real phase: 0

    readonly property bool enabledEffect: hasWindows && effectStyle !== "off"
    readonly property bool moving: enabledEffect && allowMotion && effectStyle === "orbit"
    visible: enabledEffect
    antialiasing: true
    renderTarget: Canvas.Image

    function traceShape(ctx, margin) {
        const w = width
        const h = height
        const minSize = Math.min(w, h)
        const left = margin
        const top = margin
        const right = w - margin
        const bottom = h - margin
        ctx.beginPath()
        if (shape === "circle") {
            ctx.arc(w/2, h/2, minSize/2 - margin, 0, Math.PI * 2)
        } else if (shape === "diamond") {
            ctx.moveTo(w/2, top)
            ctx.lineTo(right, h/2)
            ctx.lineTo(w/2, bottom)
            ctx.lineTo(left, h/2)
        } else if (shape === "heart") {
            const rw = right - left
            const rh = bottom - top
            ctx.moveTo(w/2, top + rh*0.95)
            ctx.bezierCurveTo(left + rw*0.18, top + rh*0.70,
                              left, top + rh*0.44,
                              left + rw*0.09, top + rh*0.24)
            ctx.bezierCurveTo(left + rw*0.19, top + rh*0.01,
                              left + rw*0.42, top + rh*0.09,
                              w/2, top + rh*0.27)
            ctx.bezierCurveTo(left + rw*0.64, top + rh*0.03,
                              left + rw*0.85, top + rh*0.03,
                              left + rw*0.94, top + rh*0.23)
            ctx.bezierCurveTo(left + rw*1.04, top + rh*0.46,
                              left + rw*0.83, top + rh*0.73,
                              w/2, top + rh*0.95)
        } else if (shape === "star") {
            for (let i = 0; i < 10; i++) {
                const angle = -Math.PI/2 + i*Math.PI/5
                const radius = (i%2 === 0 ? 0.48 : 0.22) * (minSize - 2*margin)
                const px = w/2 + Math.cos(angle)*radius
                const py = h/2 + Math.sin(angle)*radius
                if (i === 0) ctx.moveTo(px, py)
                else ctx.lineTo(px, py)
            }
        } else {
            ctx.rect(left, top, right-left, bottom-top)
        }
        ctx.closePath()
    }

    onShapeChanged: requestPaint()
    onAccentColorChanged: requestPaint()
    onStrokeSizeChanged: requestPaint()
    onEffectStyleChanged: requestPaint()
    onHasWindowsChanged: requestPaint()
    onAllowMotionChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Timer {
        interval: 66   // ~15 cuadros/segundo; suficiente para un detalle sutil
        repeat: true
        running: outline.moving && outline.visible
        onTriggered: {
            outline.phase = (outline.phase + 0.009) % 1
            outline.requestPaint()
        }
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        if (!enabledEffect) return

        const stroke = Math.max(0.5, Math.min(2, strokeSize))
        const margin = stroke/2 + 1
        ctx.save()
        ctx.lineWidth = stroke
        ctx.lineJoin = "round"
        ctx.lineCap = "round"
        // Contorno de baja intensidad para indicar actividad sin parpadear.
        traceShape(ctx, margin)
        ctx.strokeStyle = Qt.rgba(accentColor.r, accentColor.g,
                                  accentColor.b, effectStyle === "orbit" ? 0.32 : 0.92)
        ctx.stroke()

        if (effectStyle === "orbit" && allowMotion) {
            // Desplazar un tramo luminoso por el perímetro, SIN girar el
            // logo ni alterar la geometría. Qt Quick Context2D soporta
            // setLineDash y lineDashOffset desde hace varias versiones.
            const side = Math.min(width, height) - 2*margin
            const perimeter = shape === "circle" ? Math.PI*side :
                shape === "diamond" ? 2*Math.SQRT2*side :
                shape === "star" ? side*7 :
                shape === "heart" ? side*3.2 : side*4
            ctx.setLineDash([perimeter*0.22, perimeter*0.78])
            ctx.lineDashOffset = -phase * perimeter
            ctx.shadowColor = accentColor
            ctx.shadowBlur = 1.5
            ctx.strokeStyle = accentColor
            traceShape(ctx, margin)
            ctx.stroke()
        }
        ctx.restore()
    }
}
