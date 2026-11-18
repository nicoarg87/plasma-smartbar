// Superficie flotante que hereda color, opacidad, degradado, respiración
// y trazo de la isla correspondiente. No captura ratón ni modifica tamaño.
import QtQuick

Item {
    id: surface
    property color baseColor: "#010111"
    property color endColor: "#ee9852"
    property bool gradientEnabled: false
    property string gradientDirection: "topBottom"
    property real baseOpacity: 1
    property real breathingFactor: 1
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
            Qt.rgba(surface.baseColor.r, surface.baseColor.g, surface.baseColor.b,
                    Math.max(0, Math.min(1, surface.baseOpacity * surface.breathingFactor)))
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
                    color: surface.gradientDirection === "bottomTop" ||
                           surface.gradientDirection === "rightLeft"
                        ? Qt.rgba(surface.endColor.r, surface.endColor.g, surface.endColor.b,
                                  Math.max(0, Math.min(1, surface.baseOpacity * surface.breathingFactor)))
                        : Qt.rgba(surface.baseColor.r, surface.baseColor.g, surface.baseColor.b,
                                  Math.max(0, Math.min(1, surface.baseOpacity * surface.breathingFactor)))
                }
                GradientStop {
                    position: 1
                    color: surface.gradientDirection === "bottomTop" ||
                           surface.gradientDirection === "rightLeft"
                        ? Qt.rgba(surface.baseColor.r, surface.baseColor.g, surface.baseColor.b,
                                  Math.max(0, Math.min(1, surface.baseOpacity * surface.breathingFactor)))
                        : Qt.rgba(surface.endColor.r, surface.endColor.g, surface.endColor.b,
                                  Math.max(0, Math.min(1, surface.baseOpacity * surface.breathingFactor)))
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
