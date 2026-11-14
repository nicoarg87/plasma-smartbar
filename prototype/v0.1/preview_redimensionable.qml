// Ventana independiente para validar el redimensionado con el MISMO
// SmartBarContent que usa el plasmoide. No instala nada ni toca paneles.
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import "package/contents/ui"

Window {
    id: previewWindow
    width: 1000
    height: 320
    minimumWidth: 760
    minimumHeight: 210
    visible: true
    title: "Plasma SmartBar v0.1 — prueba redimensionable (sin panel)"
    color: "#242236"

    property bool demoAutoReturnRight: true

    SmartBarContent {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: fixedHeight

        autoReturnRight: previewWindow.demoAutoReturnRight
        onRequestAutoReturnRightChange: function(newValue) {
            previewWindow.demoAutoReturnRight = newValue
        }
    }

    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: bar.bottom
        anchors.topMargin: 28
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        wrapMode: Text.WordWrap
        color: "#f4edf9"
        text: "Vista independiente: arrastrá el borde de esta ventana o maximizala. " +
              "Isla 2 debe quedar a la izquierda; isla 1, SO y los controles de " +
              "muestra siguen el borde derecho. El fondo es solamente de la ventana de prueba."
    }

    QQC2.Label {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.bottomMargin: 12
        color: "#c7bad8"
        text: "Ancho del contenido: " + Math.round(bar.width) + " px lógicos"
    }

    onWidthChanged: console.log("SmartBar ventana independiente: ancho =", width)
}
