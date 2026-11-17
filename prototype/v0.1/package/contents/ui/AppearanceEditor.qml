// Fondo opcional y tonalidades por isla. Ventana de preferencias
// separada: mantiene el grosor fijo, no crea otra fila ni otra isla de control.
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: editor
    width: 400
    height: 435
    minimumWidth: 350
    minimumHeight: 400
    visible: false
    flags: Qt.Dialog
    title: "Apariencia de Soledad, Malvina y fondo"
    color: "#242236"

    property color soledadColor: "#101e31"
    property color malvinaColor: "#101e31"
    property color backgroundColor: "#202333"
    property real soledadOpacity: 1
    property real malvinaOpacity: 1
    property real backgroundOpacity: 0.5
    property bool showBackground: false

    readonly property color activeColor: target.currentIndex === 0 ? soledadColor :
        (target.currentIndex === 1 ? malvinaColor : backgroundColor)
    readonly property real activeOpacity: target.currentIndex === 0 ? soledadOpacity :
        (target.currentIndex === 1 ? malvinaOpacity : backgroundOpacity)

    signal saveRequested(string soledadColor, real soledadOpacity,
                         string malvinaColor, real malvinaOpacity,
                         bool showBackground, string backgroundColor,
                         real backgroundOpacity)

    function toHex(col) {
        // Guardar sólo RGB; la transparencia se guarda por separado.
        const h = function(v) {
            const n = Math.max(0, Math.min(255, Math.round(v * 255))).toString(16)
            return n.length === 1 ? "0" + n : n
        }
        return "#" + h(col.r) + h(col.g) + h(col.b)
    }

    function chooseOpacity(value) {
        if (target.currentIndex === 0) soledadOpacity = value
        else if (target.currentIndex === 1) malvinaOpacity = value
        else backgroundOpacity = value
    }

    ColorDialog {
        id: colorDialog
        title: "Elegí un color y su tonalidad"
        onAccepted: {
            if (target.currentIndex === 0) editor.soledadColor = selectedColor
            else if (target.currentIndex === 1) editor.malvinaColor = selectedColor
            else editor.backgroundColor = selectedColor
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        QQC2.Label {
            text: "Personalización de colores"
            font.bold: true
            color: "white"
        }
        QQC2.Label {
            text: "Elegí una isla o el fondo opcional de toda la barra."
            color: "#ddd6e8"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        QQC2.ComboBox {
            id: target
            Layout.fillWidth: true
            model: ["Soledad (isla 1)", "Malvina (isla 2)", "Fondo opcional"]
        }
        RowLayout {
            Rectangle {
                width: 54
                height: 42
                radius: 8
                border.color: "#abc4d1"
                color: Qt.rgba(editor.activeColor.r, editor.activeColor.g,
                               editor.activeColor.b, editor.activeOpacity)
            }
            QQC2.Button {
                text: "Elegir color…"
                onClicked: {
                    colorDialog.selectedColor = editor.activeColor
                    colorDialog.open()
                }
            }
            QQC2.Label {
                text: editor.toHex(editor.activeColor)
                color: "#eeeaf7"
            }
        }
        QQC2.Label { text: "Transparencia"; color: "white" }
        RowLayout {
            QQC2.Slider {
                Layout.fillWidth: true
                from: 0
                to: 1
                stepSize: 0.05
                value: editor.activeOpacity
                onMoved: editor.chooseOpacity(value)
            }
            QQC2.Label {
                text: Math.round(editor.activeOpacity * 100) + "% opacidad"
                color: "white"
                Layout.preferredWidth: 95
            }
        }
        QQC2.CheckBox {
            text: "Mostrar fondo opcional de toda la barra"
            checked: editor.showBackground
            onToggled: editor.showBackground = checked
        }
        QQC2.Label {
            text: "Por defecto no hay fondo continuo. Activarlo sólo dibuja una capa detrás de las islas, sin cambiar su grosor ni mover ventanas."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: "#ddd6e8"
        }
        Item { Layout.fillHeight: true }
        RowLayout {
            QQC2.Button {
                text: "Restablecer colores"
                onClicked: {
                    editor.soledadColor = "#101e31"
                    editor.malvinaColor = "#101e31"
                    editor.backgroundColor = "#202333"
                    editor.soledadOpacity = 1
                    editor.malvinaOpacity = 1
                    editor.backgroundOpacity = 0.5
                    editor.showBackground = false
                }
            }
            Item { Layout.fillWidth: true }
            QQC2.Button { text: "Cancelar"; onClicked: editor.close() }
            QQC2.Button {
                text: "Aplicar"
                highlighted: true
                onClicked: {
                    editor.saveRequested(editor.toHex(editor.soledadColor),
                        editor.soledadOpacity,
                        editor.toHex(editor.malvinaColor), editor.malvinaOpacity,
                        editor.showBackground, editor.toHex(editor.backgroundColor),
                        editor.backgroundOpacity)
                    editor.close()
                }
            }
        }
    }
}
