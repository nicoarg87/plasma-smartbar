// Ficha compacta compartida. SO admite PNG/JPEG/WebP/SVG y GIF con
// encuadre sin recorte destructivo. Otras fichas continúan como texto.
import QtQuick
import QtQuick.Controls as QQC2

QQC2.Button {
    id: control
    property bool accent: false
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
    // SOLO Soledad conecta esto a la cantidad real de ventanas.
    // Sin ventanas se destruye el lienzo, evitando animación y consumo.
    property int activityCount: 0
    property string activityEffect: "steady"  // off, steady, orbit
    property color activityColor: "#35d7ff"
    property real activityStroke: 1.0
    property bool activityMotionAllowed: true
    property real activityOrbitSpeed: 1.0
    property int activityTrailPercent: 22
    property string activityTrailStyle: "solid"

    implicitHeight: preferredButtonHeight > 0 ? preferredButtonHeight : 34
    implicitWidth: preferredButtonWidth > 0 ? preferredButtonWidth :
        (iconSource.toString().length > 0 ? 40 :
         Math.max(40, label.implicitWidth + 18))
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
               (control.down ? "#254c61" :
                (control.hovered ? "#24425a" :
                 (control.accent ? "#1f4e65" : "#14283d")))
        border.width: showsLogo ? 0 : 1
        border.color: control.accent ? "#3dc6d4" : "#45647a"
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

        // El contorno rodea la forma elegida del logo. Se carga solo
        // si hay una ventana real (en la maqueta, ficha de muestra).
        Loader {
            id: activityOutlineLoader
            anchors.centerIn: parent
            width: Math.max(18, control.width - 8)
            height: Math.max(18, control.height - 2)
            active: control.activityCount > 0 &&
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
                    hasWindows: control.activityCount > 0
                }
            }
        }

        Text {
            id: label
            anchors.fill: parent
            text: control.text
            // Si la imagen no existe, nunca perder el control SO.
            visible: control.iconSource.toString().length === 0 ||
                     (iconLoader.item && iconLoader.item.loadError)
            color: control.enabled ? "#eaf7ff" : "#91a8b8"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            font.weight: control.accent ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }
    }
}
