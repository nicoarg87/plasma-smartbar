// Superficie para el logo de SO: imagen fija o GIF + encuadre no destructivo.
// La máscara se renderiza con QtQuick.Effects (Qt 6), sin exportar ni
// reescribir el archivo elegido por la persona.
import QtQuick
import QtQuick.Effects

Item {
    id: artwork
    property url imageUrl: ""
    property bool animateGif: false
    property bool animationAllowed: true
    property string cropShape: "square" // square, circle, diamond, heart, star
    property string fitMode: "crop" // crop=rellenar, fit=mostrar imagen completa
    property real zoom: 1.0
    property real panX: 0.0 // -1 a 1
    property real panY: 0.0
    readonly property bool loadError: animateGif
        ? animatedSource.status === Image.Error
        : staticSource.status === Image.Error

    clip: true

    // El mismo recorte se aplica a una foto o a TODOS los cuadros del GIF.
    // Conservar fuente original: sólo se escala al renderizar, sin generar
    // archivo recortado ni bajar permanentemente su resolución.
    Item {
        id: imageStage
        anchors.fill: parent

        Image {
            id: staticSource
            source: !artwork.animateGif ? artwork.imageUrl : ""
            visible: !artwork.animateGif
            width: imageStage.width * Math.max(1, artwork.zoom)
            height: imageStage.height * Math.max(1, artwork.zoom)
            x: (imageStage.width - width) / 2 +
               artwork.panX * Math.max(0, width - imageStage.width) / 2
            y: (imageStage.height - height) / 2 +
               artwork.panY * Math.max(0, height - imageStage.height) / 2
            fillMode: artwork.fitMode === "fit" ? Image.PreserveAspectFit : Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
        }

        AnimatedImage {
            id: animatedSource
            source: artwork.animateGif ? artwork.imageUrl : ""
            visible: artwork.animateGif
            width: imageStage.width * Math.max(1, artwork.zoom)
            height: imageStage.height * Math.max(1, artwork.zoom)
            x: (imageStage.width - width) / 2 +
               artwork.panX * Math.max(0, width - imageStage.width) / 2
            y: (imageStage.height - height) / 2 +
               artwork.panY * Math.max(0, height - imageStage.height) / 2
            fillMode: artwork.fitMode === "fit" ? Image.PreserveAspectFit : Image.PreserveAspectCrop
            smooth: true
            cache: false
            playing: visible && artwork.visible && artwork.animationAllowed
        }
    }

    ShaderEffectSource {
        id: renderedSource
        sourceItem: imageStage
        hideSource: true
        live: true
        recursive: true
        anchors.fill: parent
        visible: false
    }

    Canvas {
        id: shapeCanvas
        anchors.fill: parent
        visible: false
        renderTarget: Canvas.Image
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            const w = width
            const h = height
            ctx.clearRect(0, 0, w, h)
            ctx.fillStyle = "white"
            ctx.beginPath()
            if (artwork.cropShape === "circle") {
                ctx.arc(w / 2, h / 2, Math.min(w, h) / 2, 0, Math.PI * 2)
            } else if (artwork.cropShape === "diamond") {
                ctx.moveTo(w / 2, 0)
                ctx.lineTo(w, h / 2)
                ctx.lineTo(w / 2, h)
                ctx.lineTo(0, h / 2)
            } else if (artwork.cropShape === "heart") {
                ctx.moveTo(w / 2, h * 0.94)
                ctx.bezierCurveTo(w * 0.18, h * 0.70, 0, h * 0.44,
                                  w * 0.09, h * 0.24)
                ctx.bezierCurveTo(w * 0.19, h * 0.01, w * 0.42, h * 0.09,
                                  w / 2, h * 0.27)
                ctx.bezierCurveTo(w * 0.64, h * 0.03, w * 0.85, h * 0.03,
                                  w * 0.94, h * 0.23)
                ctx.bezierCurveTo(w * 1.04, h * 0.46, w * 0.83, h * 0.73,
                                  w / 2, h * 0.94)
            } else if (artwork.cropShape === "star") {
                for (let i = 0; i < 10; i++) {
                    const angle = -Math.PI / 2 + i * Math.PI / 5
                    const radius = (i % 2 === 0 ? 0.49 : 0.22) * Math.min(w, h)
                    const px = w / 2 + Math.cos(angle) * radius
                    const py = h / 2 + Math.sin(angle) * radius
                    if (i === 0) ctx.moveTo(px, py)
                    else ctx.lineTo(px, py)
                }
            } else {
                ctx.rect(0, 0, w, h)
            }
            ctx.closePath()
            ctx.fill()
        }
        Connections {
            target: artwork
            function onCropShapeChanged() { shapeCanvas.requestPaint() }
        }
    }

    ShaderEffectSource {
        id: maskTexture
        sourceItem: shapeCanvas
        hideSource: true
        live: true
        anchors.fill: parent
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: renderedSource
        maskEnabled: artwork.cropShape !== "square"
        maskSource: maskTexture
        autoPaddingEnabled: false
    }
}
