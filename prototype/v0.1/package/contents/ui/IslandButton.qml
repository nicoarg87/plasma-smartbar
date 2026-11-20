// Ficha compacta compartida. SO admite PNG/JPEG/WebP/SVG y GIF con
// encuadre sin recorte destructivo. Otras fichas continúan como texto.
import QtQuick
import QtQuick.Controls as QQC2

QQC2.Button {
    id: control
    property bool accent: false
    property bool customTextMode: false
    property color customTextColor: "#ffffff"
    property color customTextBackground: "#192536"
    property real customTextBackgroundOpacity: 0.9
    property string customTextFontFamily: "Sans Serif"
    property int customTextFontSize: 13
    property bool customTextBold: true
    property string customTextBackgroundImage: ""
    readonly property bool customTextBackgroundIsGif: customTextBackgroundImage.toLowerCase().endsWith(".gif")
    // Bandeja: mismo color y opacidad de la isla por defecto.
    // Cada categoría puede reemplazarlo desde Apariencia.
    // Fichas de ventanas sin color independiente: muestran el fondo de Soledad.
    property bool inheritIslandFill: false
    // La actividad de una ficha se determina fuera, por su modelo o por
    // una selección simulada; jamás se infiere por hover.
    property bool taskIsActive: false
    // Dos indicadores independientes; el borde doble hereda la línea
    // de contorno de Soledad. Ambos pueden apagarse.
    property bool taskActiveGlowEnabled: true
    property bool taskActiveDoubleBorderEnabled: false
    property color taskActiveBorderColor: "#4e8499"
    property real taskActiveBorderOpacity: 1
    property real taskActiveBorderWidth: 1
    property string taskDisplayMode: "icon" // text, both, icon
    property var taskIconSource: ""
    readonly property bool taskUsesIcon: inheritIslandFill && taskDisplayMode !== "text"
    readonly property bool taskUsesText: !inheritIslandFill || taskDisplayMode !== "icon"
    // Medir el texto independientemente del tamaño calculado del Button:
    // evita un ciclo entre ancho implícito, Text.Fit y anchors.fill.
    TextMetrics {
        id: taskLabelMetrics
        font.family: "Sans Serif"
        font.pixelSize: 13
        text: control.text
    }
    property string taskFrameShape: "rounded" // rounded, square, none
    property color taskFrameColor: "#ffffff"
    property real taskFrameOpacity: 0.12
    property real taskFrameWidth: 1
    property bool useTileColor: false
    property color tileColor: "#010111"
    property real tileOpacity: 0.5
    property string outlineStyle: "solid"
    property real outlineWidth: 1
    property color outlineColor: "#45647a"
    property real outlineOpacity: 1
    property url iconSource: ""
    property bool iconAnimated: false
    property bool iconAnimationEnabled: true
    // Fundido VISUAL del logo SO, sin duplicar botones ni modificar los temas
    // guardados. Las fichas de tareas nunca instancian estas capas.
    property bool previewArtworkEnabled: false
    property var previewArtworkA: ({})
    property var previewArtworkB: ({})
    property int previewArtworkLast: 0
    property int previewArtworkDurationMs: 3000
    property real previewArtworkOpacityA: 0
    property real previewArtworkOpacityB: 0
    property real renderedPreviewOpacityA: 0
    property real renderedPreviewOpacityB: 0
    property int previewArtworkGeneration: 0
    readonly property real previewArtworkBaseOpacity:
        Math.max(0, 1 - Math.min(1, renderedPreviewOpacityA + renderedPreviewOpacityB))
    function currentArtworkSnapshot() {
        return {
            mode: customTextMode ? "text" : "image",
            image: iconSource.toString(), animated: iconAnimated,
            animationAllowed: iconAnimationEnabled,
            shape: effectiveImageShape, fit: iconFitMode, zoom: iconZoom,
            panX: iconPanX, panY: iconPanY, rotation: iconRotation,
            label: text, textColor: String(customTextColor),
            textBackground: String(customTextBackground),
            textOpacity: customTextBackgroundOpacity,
            textBackgroundImage: customTextBackgroundImage,
            textFont: customTextFontFamily, textSize: customTextFontSize,
            textBold: customTextBold
        }
    }
    function beginArtworkPreview(art, durationMs) {
        if (!art || (art.mode !== "text" && !String(art.image || "").length))
            return false
        previewArtworkDurationMs = Math.max(1, Number(durationMs) || 3000)
        const slot = previewArtworkLast === 1 ? 2 : 1
        if (slot === 1) previewArtworkA = art
        else previewArtworkB = art
        previewArtworkEnabled = true
        previewArtworkLast = slot
        const generation = ++previewArtworkGeneration
        Qt.callLater(function() {
            if (generation !== previewArtworkGeneration) return
            previewArtworkOpacityA = slot === 1 ? 1 : 0
            previewArtworkOpacityB = slot === 2 ? 1 : 0
        })
        return true
    }
    function beginActualArtworkFade(durationMs) {
        // Se llama ANTES de aplicar el tema. Conserva arriba el aspecto
        // saliente mientras el botón real recibe el siguiente GIF/foto.
        if (!previewArtworkEnabled) {
            previewArtworkOpacityA = 1
            previewArtworkOpacityB = 0
            previewArtworkA = currentArtworkSnapshot()
            previewArtworkLast = 1
            previewArtworkEnabled = true
        }
        previewArtworkDurationMs = Math.max(1, Number(durationMs) || 3000)
        const generation = ++previewArtworkGeneration
        Qt.callLater(function() {
            if (generation !== previewArtworkGeneration) return
            previewArtworkOpacityA = 0
            previewArtworkOpacityB = 0
            artworkCleanupTimer.restart()
        })
    }
    function clearArtworkPreview() {
        ++previewArtworkGeneration
        artworkCleanupTimer.stop()
        previewArtworkEnabled = false
        previewArtworkLast = 0
        previewArtworkOpacityA = 0
        previewArtworkOpacityB = 0
        renderedPreviewOpacityA = 0
        renderedPreviewOpacityB = 0
        previewArtworkA = ({})
        previewArtworkB = ({})
    }
    Timer {
        id: artworkCleanupTimer
        interval: control.previewArtworkDurationMs + 100
        repeat: false
        onTriggered: control.clearArtworkPreview()
    }
    property string iconShape: "square"
    property string iconFitMode: "fit"
    property real iconZoom: 1
    property real iconPanX: 0
    property real iconPanY: 0
    property real iconRotation: 0
    // Sólo SO usa geometría ampliada; fichas de apps conservan medidas.
    property real preferredButtonWidth: 0
    property real preferredButtonHeight: 0
    // Predeterminado de fichas de texto: conservar redondeado. SO y
    // el botón de bandeja pueden solicitar esquinas cuadradas.
    property string frameShape: "rounded" // square, rectangle, rounded, capsule, oval, task
    readonly property string effectiveImageShape: frameShape === "square" ? iconShape : frameShape
    // SOLO el botón SO conecta cantidad y política de ventanas.
    // Valores seguros para los demás botones: ninguno se ilumina vacío.
    property int activityCount: 0
    property bool activityShowWhenEmpty: false
    property bool activityShowWhenOpen: true
    readonly property bool activityActiveForState: inheritIslandFill
        ? (taskIsActive && taskActiveGlowEnabled)
        : (activityCount > 0 ? activityShowWhenOpen : activityShowWhenEmpty)
    property string activityEffect: "steady"  // off, steady, orbit
    property color activityColor: "#35d7ff"
    property real activityStroke: 1.0
    property bool activityMotionAllowed: true
    property real activityOrbitSpeed: 1.0
    property int activityTrailPercent: 22
    property string activityTrailStyle: "solid"
    property color activityGlowColor: "#ffab52"
    property real activityGlowIntensity: 0.7
    property real activityGlowSpread: 5
    property real activityPulseSpeed: 0.6
    property real activityPulseDepth: 0.7
    property bool activityUseExternalPulse: false
    property real activityExternalPulsePhase: 0
    property bool activityGlowGradient: true
    // Presentación temporal de hora y fecha dentro de SO, sin popup ni
    // cambios de tamaño y sin interceptar gestos de ratón.
    property bool clockVisible: false
    property string clockPhase: "off"
    property string clockTime: ""
    property string clockDate: ""
    property string clockFontFamily: "Sans Serif"
    property int clockFontSize: 11
    property color clockTextColor: "#ffffff"

    implicitHeight: preferredButtonHeight > 0 ? preferredButtonHeight : 34
    // Reservar ancho para los nombres sin cambiar la altura de la barra.
    implicitWidth: preferredButtonWidth > 0 ? preferredButtonWidth :
        (inheritIslandFill
            ? (taskDisplayMode === "icon" ? 38 :
                Math.max(72, Math.ceil(taskLabelMetrics.advanceWidth) + (taskUsesIcon ? 44 : 18)))
            : (iconSource.toString().length > 0 ? 40 :
                Math.max(40, label.implicitWidth + 18)))
    // Evitar que el contenido temporal modifique el área útil del botón.
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        clip: true
        // Reutilizar EXACTAMENTE la máscara del logo normal.
        // Rectangle.clip recorta un rectángulo, NO sus esquinas redondeadas;
        // los Image/AnimatedImage anteriores desbordaban la cápsula.
        LogoArtwork {
            anchors.centerIn: parent
            width: Math.max(14, control.width - 12)
            height: Math.max(14, control.height - 6)
            visible: control.customTextMode &&
                     control.customTextBackgroundImage.length > 0
            opacity: control.previewArtworkBaseOpacity
            imageUrl: control.customTextBackgroundImage
            animateGif: control.customTextBackgroundIsGif
            animationAllowed: true
            cropShape: control.effectiveImageShape
            fitMode: "crop"
        }
        // Al mostrar imagen, la mascara y el indicador opcional de
        // actividad comparten la forma elegida. No dibujar ADEMAS
        // un borde redondo del boton: aparecian dos geometrías
        // superpuestas (círculo + cuadrado/rombo) sobre la huella.
        // Las fichas sin imagen mantienen su aspecto habitual.
        readonly property bool showsLogo: control.iconSource.toString().length > 0
        radius: control.inheritIslandFill
                ? (control.taskFrameShape === "rounded" ? Math.min(7, control.height / 4) : 0)
                : control.frameShape === "rectangle" ||
                  control.frameShape === "square" ? 0 :
                (control.frameShape === "task" ? Math.min(7, control.height / 4) :
                (control.frameShape === "rounded"
                    ? Math.min(17, control.height / 2)
                    : control.height / 2))
        color: control.inheritIslandFill
            ? (control.down ? "#30ffffff" :
               (control.hovered ? "#18ffffff" : "transparent"))
            : showsLogo ? "transparent" :
               control.customTextMode
                 ? Qt.rgba(control.customTextBackground.r,
                           control.customTextBackground.g,
                           control.customTextBackground.b,
                           control.customTextBackgroundOpacity) :
               (control.useTileColor
                 ? Qt.rgba(control.tileColor.r, control.tileColor.g,
                           control.tileColor.b, control.tileOpacity)
                 : (control.down ? "#254c61" :
                    (control.hovered ? "#24425a" :
                     (control.accent ? "#1f4e65" : "#14283d"))))
        border.width: control.inheritIslandFill &&
            control.taskFrameShape !== "none" ? control.taskFrameWidth : 0
        border.color: control.inheritIslandFill
            ? Qt.rgba(control.taskFrameColor.r, control.taskFrameColor.g,
                      control.taskFrameColor.b, control.taskFrameOpacity)
            : control.hovered && control.useTileColor ? "#86b3cc" :
                      (control.accent ? "#3dc6d4" : "#45647a")
    }

    // Contorno independiente del relleno y de su transparencia.
    OutlineStyle {
        parent: control.background
        anchors.fill: parent
        visible: !control.inheritIslandFill &&
                 control.iconSource.toString().length === 0 &&
                 lineStyle !== "off"
        lineStyle: control.outlineStyle
        lineWidth: control.outlineWidth
        lineColor: control.outlineColor
        lineOpacity: control.outlineOpacity
        topLeft: parent.radius
        topRight: parent.radius
        bottomLeft: parent.radius
        bottomRight: parent.radius
    }

    // Doble línea para indicar el foco aunque no se use luz; también
    // aparece cuando las fichas normales están en "Sin recuadro".
    OutlineStyle {
        parent: control.background
        anchors.fill: parent
        visible: control.inheritIslandFill && control.taskIsActive &&
                 control.taskActiveDoubleBorderEnabled
        lineStyle: "double"
        lineWidth: control.taskActiveBorderWidth
        lineColor: control.taskActiveBorderColor
        lineOpacity: control.taskActiveBorderOpacity
        topLeft: parent.radius
        topRight: parent.radius
        bottomLeft: parent.radius
        bottomRight: parent.radius
    }

    contentItem: Item {
        implicitWidth: 30
        implicitHeight: 28

        // Cargar efectos de máscara/animación solo si realmente hay logo.
        // Las fichas de ventanas y bandeja siguen siendo botones livianos.
        Loader {
            id: iconLoader
            opacity: control.previewArtworkBaseOpacity
            anchors.centerIn: parent
            width: Math.max(14, control.width - 12)
            height: Math.max(14, control.height - 6)
            // No descargar ni reiniciar el AnimatedImage al mostrar el reloj:
            // el GIF sigue cargado y reproduciéndose debajo del texto.
            active: control.iconSource.toString().length > 0
            sourceComponent: Component {
                LogoArtwork {
                    width: iconLoader.width
                    height: iconLoader.height
                    imageUrl: control.iconSource
                    animateGif: control.iconAnimated
                    animationAllowed: control.iconAnimationEnabled
                    cropShape: control.effectiveImageShape
                    imageRotation: control.iconRotation
                    fitMode: control.iconFitMode
                    zoom: control.iconZoom
                    panX: control.iconPanX
                    panY: control.iconPanY
                }
            }
        }

        // Dos superficies artísticas no interactivas para alternar fotos/GIF
        // de temas por horario. Se crean solo durante la transición de SO.
        Loader {
            id: themeArtworkLoader
            anchors.fill: parent
            active: control.previewArtworkEnabled
            sourceComponent: Component {
                Item {
                    Repeater {
                        model: 2
                        delegate: Item {
                            id: artworkLayer
                            readonly property var art: index === 0
                                ? control.previewArtworkA : control.previewArtworkB
                            anchors.centerIn: parent
                            width: Math.max(14, control.width - 12)
                            height: Math.max(14, control.height - 6)
                            opacity: index === 0
                                ? control.previewArtworkOpacityA
                                : control.previewArtworkOpacityB
                            onOpacityChanged: {
                                if (index === 0) control.renderedPreviewOpacityA = opacity
                                else control.renderedPreviewOpacityB = opacity
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: control.previewArtworkDurationMs
                                    easing.type: Easing.InOutCubic
                                }
                            }
                            LogoArtwork {
                                anchors.fill: parent
                                visible: artworkLayer.art.mode === "image"
                                imageUrl: artworkLayer.art.image || ""
                                animateGif: !!artworkLayer.art.animated
                                // Evitar reproducir GIFs transparentes o inactivos.
                                animationAllowed: artworkLayer.art.animationAllowed !== false &&
                                                  artworkLayer.opacity > 0.001
                                cropShape: artworkLayer.art.shape || "square"
                                fitMode: artworkLayer.art.fit || "fit"
                                zoom: artworkLayer.art.zoom || 1
                                panX: artworkLayer.art.panX || 0
                                panY: artworkLayer.art.panY || 0
                                imageRotation: artworkLayer.art.rotation || 0
                            }
                            Rectangle {
                                anchors.fill: parent
                                visible: artworkLayer.art.mode === "text"
                                radius: control.frameShape === "square" ||
                                        control.frameShape === "rectangle"
                                        ? 0 : height / 2
                                readonly property color surfaceColor:
                                    artworkLayer.art.textBackground || "#192536"
                                color: Qt.rgba(surfaceColor.r, surfaceColor.g,
                                               surfaceColor.b,
                                               artworkLayer.art.textOpacity === undefined
                                                   ? 0.9 : artworkLayer.art.textOpacity)
                            }
                            LogoArtwork {
                                anchors.fill: parent
                                visible: artworkLayer.art.mode === "text" &&
                                         !!artworkLayer.art.textBackgroundImage
                                imageUrl: artworkLayer.art.textBackgroundImage || ""
                                animateGif: String(artworkLayer.art.textBackgroundImage || "").toLowerCase().endsWith(".gif")
                                cropShape: artworkLayer.art.shape || "square"
                                fitMode: "crop"
                            }
                            Text {
                                anchors.fill: parent
                                visible: artworkLayer.art.mode === "text" && !control.clockVisible
                                text: artworkLayer.art.label || "SO"
                                color: artworkLayer.art.textColor || "#ffffff"
                                font.family: artworkLayer.art.textFont || "Sans Serif"
                                font.pixelSize: artworkLayer.art.textSize || 13
                                font.bold: artworkLayer.art.textBold !== false
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        // Cargar el contorno solo si el usuario eligió ese estado de
        // ventanas y el efecto no está apagado. Esto incluye cero ventanas.
        Loader {
            id: activityOutlineLoader
            anchors.centerIn: parent
            // El Canvas dispone de margen para pintar el halo FUERA de
            // la huella del botón, sin cambiar su tamaño ni el del GIF.
            width: Math.max(18, control.width + 16)
            height: Math.max(18, control.height + 16)
            // El reloj se superpone sobre el GIF; no descargar ni
            // apagar el contorno cuando aparece hora/fecha.
            // Su visibilidad sigue gobernada solo por el efecto y
            // la política de ventanas configurada.
            active: control.activityActiveForState &&
                    control.activityEffect !== "off"
            sourceComponent: Component {
                SoActivityOutline {
                    width: activityOutlineLoader.width
                    height: activityOutlineLoader.height
                    shape: control.inheritIslandFill
                        ? (control.taskFrameShape === "square"
                           ? "taskSquare" : "taskRounded")
                        : control.effectiveImageShape
                    // Los límites de la ficha coinciden con los del botón,
                    // aun si el marco normal se configuró "sin recuadro".
                    borderMarginX: control.inheritIslandFill ? 8 : 14
                    borderMarginY: control.inheritIslandFill ? 8 : 11
                    taskCornerRadius: 7
                    accentColor: control.activityColor
                    strokeSize: control.activityStroke
                    effectStyle: control.activityEffect
                    allowMotion: control.activityMotionAllowed
                    orbitSpeed: control.activityOrbitSpeed
                    trailPercent: control.activityTrailPercent
                    trailStyle: control.activityTrailStyle
                    glowColor: control.activityGlowColor
                    glowIntensity: control.activityGlowIntensity
                    glowSpread: control.activityGlowSpread
                    pulseSpeed: control.activityPulseSpeed
                    pulseDepth: control.activityPulseDepth
                    useExternalPulse: control.activityUseExternalPulse
                    externalPulsePhase: control.activityExternalPulsePhase
                    glowGradient: control.activityGlowGradient
                    activeForState: control.activityActiveForState
                }
            }
        }

        // Hora/fecha encima de la foto, SIN fondo opaco y SIN ocultar
        // ni recrear el GIF. Hora y fecha aparecen un segundo cada una.
        Item {
            id: clockOverlay
            anchors.fill: parent
            visible: control.clockVisible
            clip: true

            readonly property color contrastOutline:
                (control.clockTextColor.r * 0.299 +
                 control.clockTextColor.g * 0.587 +
                 control.clockTextColor.b * 0.114) > 0.5
                    ? "#e6000000" : "#eeffffff"
            // Una sola línea por etapa, sin fondo ni cambio de dimensiones.
            Text {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: control.clockPhase === "time" ? control.clockTime :
                      (control.clockPhase === "date" ? control.clockDate : "")
                font.family: control.clockFontFamily
                font.pixelSize: Math.max(9, control.clockFontSize)
                fontSizeMode: Text.Fit
                minimumPixelSize: 7
                font.bold: true
                color: control.clockTextColor
                style: Text.Outline
                styleColor: clockOverlay.contrastOutline
            }
        }

        Loader {
            id: taskIconLoader
            active: control.taskUsesIcon
            anchors.left: parent.left
            anchors.leftMargin: control.taskDisplayMode === "icon" ? 0 : 6
            anchors.verticalCenter: parent.verticalCenter
            width: control.taskDisplayMode === "icon" ? parent.width : 23
            height: 23
            sourceComponent: Component {
                TaskAppIcon {
                    width: taskIconLoader.width
                    height: taskIconLoader.height
                    iconSource: control.taskIconSource
                    fallbackLabel: control.text
                }
            }
        }

        Text {
            id: label
            anchors.fill: parent
            anchors.leftMargin: control.taskUsesIcon &&
                control.taskDisplayMode === "both" ? 31 : 0
            anchors.rightMargin: control.taskUsesIcon &&
                control.taskDisplayMode === "both" ? 5 : 0
            text: control.text
            opacity: control.previewArtworkBaseOpacity
            // Si la imagen no existe, nunca perder el control SO.
            // Para fichas SO no supeditar el texto al recurso del logo.
            visible: control.taskUsesText && !control.clockVisible &&
                     (control.inheritIslandFill ||
                      control.iconSource.toString().length === 0 ||
                      (iconLoader.item && iconLoader.item.loadError))
            color: control.customTextMode ? control.customTextColor :
                (control.enabled ? "#eaf7ff" : "#91a8b8")
            horizontalAlignment: control.inheritIslandFill &&
                control.taskDisplayMode === "both"
                ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: control.customTextMode ? control.customTextFontFamily : "Sans Serif"
            font.pixelSize: control.customTextMode ? control.customTextFontSize : 13
            fontSizeMode: Text.Fit
            minimumPixelSize: 8
            font.weight: control.customTextMode && control.customTextBold
                ? Font.Bold : (control.accent ? Font.DemiBold : Font.Normal)
            elide: Text.ElideRight
        }
    }
}
