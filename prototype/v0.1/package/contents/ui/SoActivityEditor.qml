// Personalización del aviso de ventanas activas de Soledad.
// Es un indicador de contorno (no mueve el logo ni las fichas).
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: editor
    width: 390
    height: 470
    minimumWidth: 355
    minimumHeight: 440
    flags: Qt.Dialog
    title: "Contorno de actividad de SO"
    color: "#242236"
    visible: false

    property string effectStyle: "steady"  // off, steady, orbit
    property color accentColor: "#35d7ff"
    property real strokeSize: 1.0
    property bool allowMotion: true
    property bool simulateHasWindows: true
    property url logoSource: ""
    property bool logoAnimated: false
    property string logoShape: "square"

    signal saveRequested(string effect, string color, real stroke,
                         bool motionAllowed)

    function colorHex(c) {
        const h = function(v) {
            const n = Math.max(0, Math.min(255, Math.round(255*v))).toString(16)
            return n.length === 1 ? "0" + n : n
        }
        return "#" + h(c.r) + h(c.g) + h(c.b)
    }

    ColorDialog {
        id: chooseColor
        title: "Color luminoso de SO"
        onAccepted: editor.accentColor = selectedColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 13

        QQC2.Label {
            text: "Contorno luminoso cuando SO tiene ventanas"
            color: "white"
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 91
            radius: 12
            color: "#353b52"
            IslandButton {
                anchors.centerIn: parent
                text: "SO"
                accent: true
                iconSource: editor.logoSource
                iconAnimated: editor.logoAnimated
                iconShape: editor.logoShape
                activityCount: editor.simulateHasWindows ? 3 : 0
                activityEffect: editor.effectStyle
                activityColor: editor.accentColor
                activityStroke: editor.strokeSize
                activityMotionAllowed: editor.allowMotion
            }
        }
        QQC2.CheckBox {
            text: "Simular ventanas abiertas en esta vista previa"
            checked: editor.simulateHasWindows
            onToggled: editor.simulateHasWindows = checked
        }
        QQC2.Label {
            text: "Probá desmarcarla: el borde debe desaparecer por completo."
            color: "#d9d4e8"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        QQC2.Label { text: "Efecto"; color: "white" }
        QQC2.ComboBox {
            Layout.fillWidth: true
            model: ["Desactivado", "Borde brillante fijo", "Luz que recorre el contorno"]
            currentIndex: editor.effectStyle === "off" ? 0 :
                          editor.effectStyle === "orbit" ? 2 : 1
            onActivated: function(i) {
                editor.effectStyle = ["off","steady","orbit"][i]
            }
        }
        RowLayout {
            QQC2.Button {
                text: "Elegir color…"
                onClicked: {
                    chooseColor.selectedColor = editor.accentColor
                    chooseColor.open()
                }
            }
            Rectangle {
                width: 40
                height: 27
                radius: 6
                color: editor.accentColor
            }
            QQC2.Label { text: editor.colorHex(editor.accentColor); color: "white" }
        }
        RowLayout {
            QQC2.Label { text: "Grosor"; color: "white"; Layout.preferredWidth: 60 }
            QQC2.Slider {
                Layout.fillWidth: true
                from: 0.5
                to: 2
                stepSize: 0.25
                value: editor.strokeSize
                onMoved: editor.strokeSize = value
            }
            QQC2.Label {
                text: editor.strokeSize.toFixed(2) + " px"
                color: "white"
            }
        }
        QQC2.CheckBox {
            text: "Permitir movimiento sutil del borde"
            checked: editor.allowMotion
            onToggled: editor.allowMotion = checked
            enabled: editor.effectStyle === "orbit"
        }
        QQC2.Label {
            text: "Sin ventanas: sin contorno y sin temporizador. Con movimiento: hasta 15 cuadros/segundo en un lienzo muy pequeño. No se anima la isla."
            color: "#d9d4e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            QQC2.Button {
                text: "Restablecer"
                onClicked: {
                    editor.effectStyle = "steady"
                    editor.accentColor = "#35d7ff"
                    editor.strokeSize = 1
                    editor.allowMotion = true
                }
            }
            Item { Layout.fillWidth: true }
            QQC2.Button { text: "Cancelar"; onClicked: editor.close() }
            QQC2.Button {
                text: "Aplicar"
                highlighted: true
                onClicked: {
                    editor.saveRequested(editor.effectStyle,
                        editor.colorHex(editor.accentColor),
                        editor.strokeSize, editor.allowMotion)
                    editor.close()
                }
            }
        }
    }
}
