// Control horizontal de volumen de MUESTRA para vistas previas de SO.
// Compartido entre las ventanas simuladas de una misma aplicación.
// No consulta ni modifica PipeWire, PulseAudio o tareas reales de KDE.
import QtQuick
import QtQuick.Controls as QQC2

Item {
    id: control
    required property var host
    required property string appName
    implicitWidth: 198
    implicitHeight: 34
    readonly property int volume: host.demoAppVolume(appName)

    Row {
        anchors.fill: parent
        spacing: 4

        QQC2.ToolButton {
            id: volumeDown
            implicitWidth: 24
            implicitHeight: 34
            focusPolicy: Qt.StrongFocus
            Accessible.name: "Bajar volumen simulado de " + control.appName
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Bajar volumen simulado un 5 %"
            contentItem: Text {
                text: "−"
                color: "white"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: control.host.setDemoAppVolume(
                control.appName, control.volume - 5)
        }

        QQC2.Slider {
            id: volumeSlider
            width: Math.max(60, parent.width - volumeDown.width -
                            volumeUp.width - volumeLabel.width -
                            parent.spacing * 3)
            height: 34
            from: 0
            to: 100
            stepSize: 1
            value: control.volume
            focusPolicy: Qt.StrongFocus
            Accessible.name: "Volumen simulado de " + control.appName +
                             " (común a todas sus ventanas)"
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Volumen simulado · no modifica el sistema"
            onMoved: control.host.setDemoAppVolume(control.appName, value)
        }

        QQC2.ToolButton {
            id: volumeUp
            implicitWidth: 24
            implicitHeight: 34
            focusPolicy: Qt.StrongFocus
            Accessible.name: "Subir volumen simulado de " + control.appName
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Subir volumen simulado un 5 %"
            contentItem: Text {
                text: "+"
                color: "white"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: control.host.setDemoAppVolume(
                control.appName, control.volume + 5)
        }

        Text {
            id: volumeLabel
            width: 34
            height: 34
            color: "white"
            font.pixelSize: 11
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            text: control.volume + "%"
        }
    }
}
