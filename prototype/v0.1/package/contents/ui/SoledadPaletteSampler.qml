import QtQuick
import "PaletteExtractor.js" as PaletteExtractor

// Lectura de un fotograma del GIF solo cuando el usuario lo solicita.
    Canvas {
        id: sampler
        required property var settingsTarget
        readonly property var settings: settingsTarget
        required property int appearanceTargetIndex
        width: 64
        height: 64
        opacity: 0
        property string requestedUrl: ""
        property bool pending: false
        property string requestMode: "island"
        property int requestTargetIsland: 0
        onImageLoaded: {
            if (pending && isImageLoaded(requestedUrl)) requestPaint()
        }
        function suggestFromImage(mode) {
            requestMode = mode === "contour" ? "contour" : (mode === "theme" ? "theme" : "island")
            requestTargetIsland = appearanceTargetIndex
            requestedUrl = settings.logoMode === "text"
                ? (settings.soTextBackgroundImage.length
                    ? settings.soTextBackgroundImage
                    : settings.defaultImage.toString())
                : settings.selectedImage.toString()
            if (!requestedUrl.length) {
                settings.paletteFeedback = "No se eligió ninguna imagen."
                return
            }
            settings.paletteFeedback = "Leyendo un fotograma del GIF para ofrecer tres tonos…"
            pending = true
            paletteImageLoadTimeout.restart()
            // Releer el archivo incluso si un GIF fue reemplazado en la
            // misma ruta. Sin cachear un resultado de análisis anterior.
            if (isImageLoaded(requestedUrl)) unloadImage(requestedUrl)
            loadImage(requestedUrl)
        }
        onPaint: {
            if (!pending || !isImageLoaded(requestedUrl)) return
            pending = false
            paletteImageLoadTimeout.stop()
            const activeUrl = settings.logoMode === "text"
                ? (settings.soTextBackgroundImage.length
                    ? settings.soTextBackgroundImage
                    : settings.defaultImage.toString())
                : settings.selectedImage.toString()
            if (activeUrl !== requestedUrl) {
                settings.resetSampledColors()
                settings.paletteFeedback = "La imagen cambió durante el análisis. Volvé a analizar."
                return
            }
            try {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.drawImage(requestedUrl, 0, 0, width, height)
                const raw = ctx.getImageData(0, 0, width, height).data
                // Un solo análisis cuando el usuario lo pide; sin muestreo
                // por cada fotograma GIF ni trabajo continuo de CPU/GPU.
                const colors = PaletteExtractor.extractDominantColors(raw, 3)
                if (colors.length === 0) {
                    settings.resetSampledColors()
                    settings.paletteFeedback = "No se detectaron suficientes tonos cromáticos " +
                        "en este fotograma; podés elegir cualquier HEX manualmente."
                    return
                }
                if (requestMode === "contour") {
                    // El botón explícito del editor de CONTORNO solo altera
                    // acento y brillo, nunca fondos o degradados de islas.
                    settings.chooseCoordinatedPalette(
                        "GIF (contorno)", Qt.lighter(colors[0].hex, 1.35),
                        Qt.lighter(colors[Math.min(1, colors.length - 1)].hex, 1.2),
                        "", "")
                } else {
                    settings.sampledColors = colors.map(function(x) { return x.hex })
                    settings.sampledSource = requestedUrl
                    const first = colors[0].hex
                    const second = colors.length > 1 ? colors[1].hex : first
                    const third = colors.length > 2 ? colors[2].hex : second
                    // Selección inicial automática: dos colores y degradado
                    // activado SOLO en la isla desde la que se inició el análisis.
                    // No modificar el brillo SO ni la otra isla. No guardar
                    // los presets hasta que el usuario lo solicite.
                    if (requestTargetIsland === 1) {
                        settings.malvinaColor = first
                        settings.malvinaGradientEnd = second
                        settings.malvinaGradientThird = third
                        settings.malvinaGradientColorCount = 2
                        settings.malvinaGradientEnabled = true
                    } else {
                        settings.soledadColor = first
                        settings.soledadGradientEnd = second
                        settings.soledadGradientThird = third
                        settings.soledadGradientColorCount = 2
                        settings.soledadGradientEnabled = true
                    }
                    if (requestMode === "theme") {
                        settings.malvinaColor = first
                        settings.malvinaGradientEnd = second
                        settings.malvinaGradientThird = third
                        settings.malvinaGradientEnabled = true
                        settings.malvinaGradientColorCount = 2
                        settings.accentColor = first
                        settings.glowColor = second
                    }
                    settings.paletteFeedback = "Paleta del GIF aplicada al editor: " +
                        first + " → " + second + ". Degradado de 2 colores activo. " +
                        (colors.length > 2
                            ? "El tono 3 está disponible si elegís 3 colores. "
                            : "") +
                        "Podés cambiar cada tono y pulsar Aplicar para guardarlo."
                }
            } catch (e) {
                settings.paletteFeedback = "No se pudo analizar el GIF: " + e
                console.warn("SmartBar: error de análisis de paleta", e)
            }
        }
        Timer {
            id: paletteImageLoadTimeout
            interval: 3500
            repeat: false
            onTriggered: {
                if (!sampler.pending) return
                if (sampler.isImageLoaded(sampler.requestedUrl)) {
                    sampler.requestPaint()
                } else {
                    sampler.pending = false
                    settings.paletteFeedback = "No se pudo leer la imagen. Revisá la ruta GIF/PNG."
                }
            }
        }
    }
