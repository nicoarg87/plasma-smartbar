// Borde de actividad del botón SO; fuera del contorno del logo.
// El Canvas coincide con el botón SO; el temporizador se activa
// solo cuando el estado configurado permite mostrar el borde móvil.
import QtQuick

Canvas {
    id: outline
    property string shape: "square"
    property color accentColor: "#35d7ff"
    property real strokeSize: 1.0
    property string effectStyle: "steady" // off, steady, orbit, glow, breathe, orbitGlow
    property bool activeForState: false
    property bool allowMotion: true
    // Velocidad en vueltas/segundo, longitud de la estela en % del borde.
    property real orbitSpeed: 1.0
    property int trailPercent: 22
    property string trailStyle: "solid" // solid, dotted, dashed
    // Efecto luminoso siempre sin tocar el GIF ni la geometría.
    property color glowColor: "#ffab52"
    property real glowIntensity: 0.7
    property real glowSpread: 5
    property real pulseSpeed: 0.6
    property bool glowGradient: true
    property real phase: 0
    property real pulsePhase: 0

    // La política de mostrar con/sin ventanas la calcula IslandButton.
    readonly property bool enabledEffect: activeForState && effectStyle !== "off"
    readonly property bool orbiting: effectStyle === "orbit" || effectStyle === "orbitGlow"
    readonly property bool pulsing: effectStyle === "breathe"
    readonly property bool glows: effectStyle === "glow" || pulsing || effectStyle === "orbitGlow"
    readonly property bool moving: enabledEffect && allowMotion && (orbiting || pulsing)
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
        if (shape === "rounded") {
            const radius = Math.min(12, (bottom - top) / 3)
            ctx.roundedRect(left, top, right-left, bottom-top, radius, radius)
        } else if (shape === "capsule") {
            const radius = (bottom - top) / 2
            ctx.roundedRect(left, top, right-left, bottom-top, radius, radius)
        } else if (shape === "oval") {
            ctx.ellipse(left, top, right-left, bottom-top)
        } else if (shape === "circle") {
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
    onActiveForStateChanged: requestPaint()
    onAllowMotionChanged: requestPaint()
    onOrbitSpeedChanged: requestPaint()
    onTrailPercentChanged: requestPaint()
    onTrailStyleChanged: requestPaint()
    onGlowColorChanged: requestPaint()
    onGlowIntensityChanged: requestPaint()
    onGlowSpreadChanged: requestPaint()
    onPulseSpeedChanged: requestPaint()
    onGlowGradientChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // ~30 repintados por segundo SOLO en el estado habilitado por la
    // configuración. Si se apaga el efecto o no corresponde al estado,
    // el temporizador no corre (aunque haya cero ventanas).
    Timer {
        interval: 50 // 20 fps máximo solo cuando el efecto lo necesita
        repeat: true
        running: outline.moving && outline.visible
        onTriggered: {
            if (outline.orbiting) {
                const speed = Math.max(0.1, Math.min(3, outline.orbitSpeed))
                outline.phase = (outline.phase + speed * interval / 1000) % 1
            }
            if (outline.pulsing) {
                const speed = Math.max(0.1, Math.min(3, outline.pulseSpeed))
                outline.pulsePhase = (outline.pulsePhase + speed * interval / 1000) % 1
            }
            outline.requestPaint()
        }
    }

    function perimeterForShape(margin) {
        const w = Math.max(1, width - 2 * margin)
        const h = Math.max(1, height - 2 * margin)
        const minSide = Math.min(w, h)
        if (shape === "circle") return Math.PI * minSide
        if (shape === "oval") {
            const a = w / 2
            const b = h / 2
            return Math.PI * (3 * (a + b) - Math.sqrt((3*a+b)*(a+3*b)))
        }
        if (shape === "diamond") return 2 * Math.hypot(w, h)
        if (shape === "star") {
            const outer = minSide * 0.48
            const inner = minSide * 0.22
            const side = Math.sqrt(outer*outer + inner*inner -
                                  2*outer*inner*Math.cos(Math.PI/5))
            return 10 * side
        }
        if (shape === "heart") return minSide * 3.2
        if (shape === "capsule" || shape === "rounded") {
            const radius = shape === "capsule" ? h/2 : Math.min(12, h/3)
            return 2 * (w + h - 4*radius) + 2*Math.PI*radius
        }
        return 2 * (w + h)
    }

    // Un solo patrón de guiones por vuelta: el segmento luminoso ocupa
    // trailPercent del contorno y el resto es un espacio transparente.
    // En punteado/guiones, dividir solo ese segmento en trozos discretos.
    function orbitDashPattern(perimeter, stroke) {
        const length = perimeter * Math.max(5, Math.min(85, trailPercent)) / 100
        const empty = perimeter - length
        if (trailStyle === "solid") return [length, empty]
        const dotted = trailStyle === "dotted"
        const mark = dotted ? Math.max(0.35, stroke * 0.45)
                            : Math.max(2, stroke * 4)
        const gap = dotted ? Math.max(2.5, stroke * 3.2)
                           : Math.max(2.5, stroke * 2.5)
        const pattern = []
        let left = length
        let count = 0
        while (left > 0.00001 && count < 150) {
            const segment = Math.min(mark, left)
            pattern.push(segment)
            left -= segment
            const interval = Math.min(gap, left)
            pattern.push(interval)
            left -= interval
            count++
        }
        // El último intervalo completa la vuelta sin duplicar la luz.
        pattern[pattern.length - 1] += empty
        return pattern
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        if (!enabledEffect || width < 6 || height < 6) return
        const stroke = Math.max(0.5, Math.min(2, strokeSize))
        const spread = Math.max(1, Math.min(8, glowSpread))
        // Luz contenida dentro de Canvas: nada modifica el tamaño del botón.
        const margin = glows ? spread + stroke / 2 + 1 : stroke / 2 + 1
        const intensity = Math.max(0, Math.min(1, glowIntensity))
        const pulse = pulsing && allowMotion
            ? 0.3 + 0.7 * (0.5 - 0.5 * Math.cos(2 * Math.PI * pulsePhase))
            : 1
        ctx.save()
        ctx.lineJoin = "round"
        ctx.lineCap = "round"
        if (glows && intensity > 0) {
            // Cinco capas concéntricas, intensas junto al borde y suaves afuera.
            for (let i = 0; i < 5; ++i) {
                const distance = i * spread / 4
                const near = 1 - i / 5
                const alpha = intensity * pulse * near * near * 0.28
                const color = glowGradient ? (i < 2 ? accentColor : glowColor) : glowColor
                ctx.strokeStyle = Qt.rgba(color.r, color.g, color.b, alpha)
                ctx.lineWidth = Math.max(0.8, stroke + (glowGradient ? near : 0))
                traceShape(ctx, Math.max(stroke / 2 + 0.7, margin - distance))
                ctx.stroke()
            }
        }
        ctx.lineWidth = stroke
        const baseColor = glows && glowGradient ? accentColor : (glows ? glowColor : accentColor)
        ctx.strokeStyle = Qt.rgba(baseColor.r, baseColor.g, baseColor.b,
                                  glows ? Math.min(1, 0.45 + intensity * pulse * 0.5) :
                                  orbiting ? 0.32 : 0.92)
        traceShape(ctx, margin)
        ctx.stroke()
        if (orbiting && allowMotion) {
            const perimeter = perimeterForShape(margin)
            ctx.setLineDash(orbitDashPattern(perimeter, stroke))
            ctx.lineDashOffset = -phase * perimeter
            ctx.strokeStyle = accentColor
            ctx.lineWidth = stroke
            traceShape(ctx, margin)
            ctx.stroke()
            ctx.setLineDash([])
        }
        ctx.restore()
    }
}
