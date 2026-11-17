// Ficha compacta compartida. SO admite PNG/JPEG/WebP/SVG y GIF con
// encuadre sin recorte destructivo. Otras fichas continúan como texto.
import QtQuick
import QtQuick.Controls as QQC2

QQC2.Button {
    id: control
    property bool accent: false
    // Bandeja: mismo color y opacidad de la isla por defecto.
    // Cada categoría puede reemplazarlo desde Apariencia.
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
    property string frameShape: "rounded" // square, rectangle, rounded, capsule, oval
    readonly property string effectiveImageShape: frameShape === "square" ? iconShape : frameShape
    // SOLO el botón SO conecta cantidad y política de ventanas.
    // Valores seguros para los demás botones: ninguno se ilumina vacío.
    property int activityCount: 0
    property bool activityShowWhenEmpty: false
    property bool activityShowWhenOpen: true
    readonly property bool activityActiveForState: activityCount > 0
        ? activityShowWhenOpen : activityShowWhenEmpty
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
    implicitWidth: preferredButtonWidth > 0 ? preferredButtonWidth :
        (iconSource.toString().length > 0 ? 40 :
         Math.max(40, label.implicitWidth + 18))
    // Evitar que el contenido temporal modifique el área útil del botón.
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        // Al mostrar imagen, la mascara y el indicador opcional de
        // actividad comparten la forma elegida. No dibujar ADEMAS
        // un borde redondo del boton: aparecian dos geometrías
        // superpuestas (círculo + cuadrado/rombo) sobre la huella.
        // Las fichas sin imagen mantienen su aspecto habitual.
        readonly property bool showsLogo: control.iconSource.toString().length > 0
        radius: control.frameShape === "rectangle" ||
                control.frameShape === "square" ? 0 :
                (control.frameShape === "rounded"
                    ? Math.min(17, control.height / 2)
                    : control.height / 2)
        color: showsLogo ? "transparent" :
               (control.useTileColor
                 ? Qt.rgba(control.tileColor.r, control.tileColor.g,
                           control.tileColor.b, control.tileOpacity)
                 : (control.down ? "#254c61" :
                    (control.hovered ? "#24425a" :
                     (control.accent ? "#1f4e65" : "#14283d"))))
        border.width: 0
        border.color: control.hovered && control.useTileColor ? "#86b3cc" :
                      (control.accent ? "#3dc6d4" : "#45647a")
    }

    // Contorno independiente del relleno y de su transparencia.
    OutlineStyle {
        parent: control.background
        anchors.fill: parent
        visible: control.iconSource.toString().length === 0 && lineStyle !== "off"
        lineStyle: control.outlineStyle
        lineWidth: control.outlineWidth
        lineColor: control.outlineColor
        lineOpacity: control.outlineOpacity
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

        // Cargar el contorno solo si el usuario eligió ese estado de
        // ventanas y el efecto no está apagado. Esto incluye cero ventanas.
        Loader {
            id: activityOutlineLoader
            anchors.centerIn: parent
            // El Canvas dispone de margen para pintar el halo FUERA de
            // la huella del botón, sin cambiar su tamaño ni el del GIF.
            width: Math.max(18, control.width + 16)
            height: Math.max(18, control.height + 16)
            active: !control.clockVisible &&
                    control.activityActiveForState &&
                    control.activityEffect !== "off"
            sourceComponent: Component {
                SoActivityOutline {
                    width: activityOutlineLoader.width
                    height: activityOutlineLoader.height
                    shape: control.effectiveImageShape
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

        Text {
            id: label
            anchors.fill: parent
            text: control.text
            // Si la imagen no existe, nunca perder el control SO.
            visible: !control.clockVisible &&
                     (control.iconSource.toString().length === 0 ||
                      (iconLoader.item && iconLoader.item.loadError))
            color: control.enabled ? "#eaf7ff" : "#91a8b8"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            font.weight: control.accent ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }
    }
}
