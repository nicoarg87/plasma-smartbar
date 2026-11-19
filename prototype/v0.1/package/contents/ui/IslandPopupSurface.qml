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
                    color: surface.gradientDirection === "bottomTop" ||
                           surface.gradientDirection === "rightLeft"
                        ? Qt.rgba(surface.visibleEndColor.r, surface.visibleEndColor.g,
                                  surface.visibleEndColor.b, surface.effectiveAlpha)
                        : Qt.rgba(surface.visibleBaseColor.r, surface.visibleBaseColor.g,
                                  surface.visibleBaseColor.b, surface.effectiveAlpha)
                }
                GradientStop {
                    position: 1
                    color: surface.gradientDirection === "bottomTop" ||
                           surface.gradientDirection === "rightLeft"
                        ? Qt.rgba(surface.visibleBaseColor.r, surface.visibleBaseColor.g,
                                  surface.visibleBaseColor.b, surface.effectiveAlpha)
                        : Qt.rgba(surface.visibleEndColor.r, surface.visibleEndColor.g,
                                  surface.visibleEndColor.b, surface.effectiveAlpha)
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
