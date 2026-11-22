// Ensayo de DOS superficies LayerShellQt, temporal y reversible.
// NO es la implementación de Soledad ni una solución a pestañas tapadas.
// La ventana amplia deja pasar todos los clics; una superficie separada
// y mínima comprueba si el compositor entrega clics a un control Qt.
// No instala un panel, no guarda ajustes y no controla Brave ni Steam.
import QtQuick
import QtQuick.Window
import QtQml
import org.kde.layershell 1.0 as LayerShell

QtObject {
    id: experiment
    property int receivedClicks: 0
    property bool pointerInsideControl: false

    // Franja de prueba: clics pasantes. Su fondo no tapa las pestañas;
    // solo un contorno ligero y una etiqueta marcan el área de ensayo.
    property Window passThrough: Window {
        title: "SmartBar - ZONA PASANTE de prueba"
        width: 348
        height: 42
        visible: true
        color: "transparent"
        flags: Qt.FramelessWindowHint |
               Qt.WindowTransparentForInput |
               Qt.WindowDoesNotAcceptFocus

        LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                                   LayerShell.Window.AnchorRight
        LayerShell.Window.layer: LayerShell.Window.LayerTop
        LayerShell.Window.exclusionZone: -1
        LayerShell.Window.keyboardInteractivity:
            LayerShell.Window.KeyboardInteractivityNone
        // Deja a la derecha un lugar independiente para el control.
        LayerShell.Window.margins: ({left: 0, top: 6, right: 76, bottom: 0})

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: 6
            border.color: "#659edbd3"
            border.width: 1
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: "#d6eefa"
                font.bold: true
                font.pixelSize: 10
                text: "PASANTE · clics al navegador"
            }
        }
    }

    // Superficie clickeable separada: solo este pequeño rectángulo
    // recibe clics, con lo cual se distingue del área pasante.
    property Window interactive: Window {
        title: "SmartBar - CONTROL INTERACTIVO de prueba"
        width: 52
        height: 42
        visible: true
        color: "transparent"
        // Solo en la ventana INTERACTIVA: no marcarla como sin
        // entrada. La región clickeable corresponde a sus 52x42 px.
        flags: Qt.Window | Qt.FramelessWindowHint

        LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                                   LayerShell.Window.AnchorRight
        LayerShell.Window.layer: LayerShell.Window.LayerTop
        LayerShell.Window.exclusionZone: -1
        LayerShell.Window.keyboardInteractivity:
            LayerShell.Window.KeyboardInteractivityNone
        LayerShell.Window.margins: ({left: 0, top: 6, right: 12, bottom: 0})

        Rectangle {
            anchors.fill: parent
            radius: 10
            clip: true
            color: "#194d76"
            border.color: experiment.pointerInsideControl ? "#ffffff" : "#b3ddf7"
            border.width: experiment.pointerInsideControl ? 2 : 1

            // GIF original del proyecto, sin modificar los recursos.
            AnimatedImage {
                id: testSoGif
                anchors.fill: parent
                source: Qt.resolvedUrl("package/contents/ui/assets/so-tropical.gif")
                fillMode: Image.PreserveAspectCrop
                playing: true
            }
            Text {
                anchors.centerIn: parent
                visible: testSoGif.status !== Image.Ready
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 12
                text: "SO"
            }
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: 19
                height: 17
                radius: 5
                color: "#e7192939"
                border.color: "#ffffff"
                Text {
                    anchors.centerIn: parent
                    text: String(experiment.receivedClicks)
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 11
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                experiment.pointerInsideControl = true
                console.log("SmartBar ensayo MIXTO: puntero SOBRE SO")
            }
            onExited: experiment.pointerInsideControl = false
            // Contar al presionar, sin depender de release.
            onPressed: function(mouse) {
                experiment.receivedClicks += 1
                console.log("SmartBar ensayo MIXTO: pulsación SO =",
                            experiment.receivedClicks,
                            "botón:", mouse.button)
            }
        }
    }

    // El modo no pide foco ni puede cerrarse por teclado: garantiza
    // autocierre del PROCESO a los 60 s, o Ctrl+C desde Konsole.
    property Timer timeout: Timer {
        interval: 60000
        running: true
        repeat: false
        onTriggered: {
            experiment.passThrough.close()
            experiment.interactive.close()
            console.log("SmartBar ensayo MIXTO: cierre automático, sin cambios")
            Qt.quit()
        }
    }
    Component.onCompleted: console.log(
        "SmartBar MIXTO: 2 superficies separadas; zona pasante 348x42",
        "y control SO 52x42, ambas arriba a la derecha; sin zona exclusiva.",
        "Clic izquierdo o derecho en GIF SO suma un contador;",
        "si no cambia, revisar puntero y región de entrada en KWin.",
        "Prueba de comportamiento, no aprobación de pestañas/controles finales.",
        "Cierre 60 s / Ctrl+C.")
}
