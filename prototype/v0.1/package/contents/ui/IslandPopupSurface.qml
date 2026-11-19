// Superficie flotante que hereda color, opacidad, degradado, respiración
// y trazo de la isla correspondiente. No captura ratón ni modifica tamaño.
import QtQuick

Item {
    id: surface
    property color baseColor: "#010111"
    property color endColor: "#ee9852"
    property color thirdColor: "#ee9852"
    property int gradientColorCount: 2
    property bool gradientEnabled: false
    property string gradientDirection: "topBottom"
    property real baseOpacity: 1
    property real breathingFactor: 1
    // Con 100 % de opacidad, respirar cambia sutilmente la luminosidad
    // pero NO vuelve transparente el fondo. Solo se activa en paneles
    // flotantes que lo solicitan; no altera la isla ni su configuración.
    property bool opaqueAtMaximum: false
    readonly property real effectiveAlpha: Math.max(0, Math.min(1,
        opaqueAtMaximum && baseOpacity >= 0.999 ? 1 : baseOpacity * breathingFactor))
    readonly property real effectiveBrightness: opaqueAtMaximum && baseOpacity >= 0.999
        ? 1 + (1 - Math.max(0, Math.min(1, breathingFactor))) * 0.24 : 1
    readonly property color visibleBaseColor: Qt.lighter(baseColor, effectiveBrightness)
    readonly property color visibleEndColor: Qt.lighter(endColor, effectiveBrightness)
    readonly property color visibleThirdColor: Qt.lighter(thirdColor, effectiveBrightness)
    property color outlineColor: "#4e8499"
    property real outlineOpacity: 1
    property real outlineWidth: 1
    property string outlineStyle: "solid"
    property real cornerRadius: 12

    Rectangle {
        id: fillSurface
        anchors.fill: parent
        radius: Math.max(0, Math.min(surface.cornerRadius, height / 2))
        color: surface.gradientEnabled ? "transparent" :
            Qt.rgba(surface.visibleBaseColor.r, surface.visibleBaseColor.g,
                    surface.visibleBaseColor.b, surface.effectiveAlpha)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: surface.gradientEnabled
            gradient: Gradient {
                orientation: surface.gradientDirection === "leftRight" ||
                             surface.gradientDirection === "rightLeft"
                    ? Gradient.Horizontal : Gradient.Vertical
                GradientStop {
                    position: 0
                    color: {
                        const reverse = surface.gradientDirection === "bottomTop" ||
                                        surface.gradientDirection === "rightLeft"
                        const col = reverse
                            ? (surface.gradientColorCount === 3
                               ? surface.visibleThirdColor : surface.visibleEndColor)
                            : surface.visibleBaseColor
                        return Qt.rgba(col.r, col.g, col.b, surface.effectiveAlpha)
                    }
                }
                GradientStop {
                    position: surface.gradientColorCount === 3 ? 0.5 : 1
                    color: {
                        const reverse = surface.gradientDirection === "bottomTop" ||
                                        surface.gradientDirection === "rightLeft"
                        const col = surface.gradientColorCount === 3
                            ? surface.visibleEndColor
                            : (reverse ? surface.visibleBaseColor : surface.visibleEndColor)
                        return Qt.rgba(col.r, col.g, col.b, surface.effectiveAlpha)
                    }
                }
                GradientStop {
                    position: 1
                    color: {
                        const reverse = surface.gradientDirection === "bottomTop" ||
                                        surface.gradientDirection === "rightLeft"
                        const col = reverse ? surface.visibleBaseColor
                            : (surface.gradientColorCount === 3
                               ? surface.visibleThirdColor : surface.visibleEndColor)
                        return Qt.rgba(col.r, col.g, col.b, surface.effectiveAlpha)
                    }
                }
            }
        }
    }
    OutlineStyle {
        anchors.fill: parent
        lineColor: surface.outlineColor
        lineOpacity: surface.outlineOpacity
        lineWidth: surface.outlineWidth
        lineStyle: surface.outlineStyle
        topLeft: fillSurface.radius
        topRight: fillSurface.radius
        bottomLeft: fillSurface.radius
        bottomRight: fillSurface.radius
    }
}
