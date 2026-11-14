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
    property real iconZoom: 1
    property real iconPanX: 0
    property real iconPanY: 0

    implicitHeight: 34
    implicitWidth: iconSource.toString().length > 0
        ? 40 : Math.max(40, label.implicitWidth + 18)
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Rectangle {
        radius: 17
        color: control.down ? "#254c61" :
               (control.hovered ? "#24425a" :
                (control.accent ? "#1f4e65" : "#14283d"))
        border.width: 1
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
            width: 28
            height: 28
            active: control.iconSource.toString().length > 0
            sourceComponent: Component {
                LogoArtwork {
                    width: 28
                    height: 28
                    imageUrl: control.iconSource
                    animateGif: control.iconAnimated
                    animationAllowed: control.iconAnimationEnabled
                    cropShape: control.iconShape
                    zoom: control.iconZoom
                    panX: control.iconPanX
                    panY: control.iconPanY
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
