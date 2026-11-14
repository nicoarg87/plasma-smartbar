// Editor visual e independiente del panel instalado.
// Cambia únicamente parámetros de encuadre: NO edita el archivo del usuario.
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: editor
    width: 420
    height: 675
    minimumWidth: 360
    minimumHeight: 580
    title: "Personalizar el logo del botón SO"
    flags: Qt.Dialog
    color: "#242236"
    visible: false

    property string logoMode: "default" // default | custom | text
    property string filePath: ""
    property string shape: "square"
    property string cropFitMode: "fit"
    property real cropZoom: 1
    property real cropPanX: 0
    property real cropPanY: 0
    property bool enableGif: true
    property url defaultImage: ""

    readonly property url selectedImage: logoMode === "text" ? "" :
        (logoMode === "custom" && filePath.length > 0 ? filePath : defaultImage)
    readonly property bool isGif: logoMode === "custom" &&
        filePath.toLowerCase().endsWith(".gif")

    signal saveRequested(string mode, string path, string shape, string fitMode,
                         real zoom, real panX, real panY, bool allowGif)

    FileDialog {
        id: chooseImage
        title: "Elegir fotografía, logo o GIF"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.webp *.svg *.gif *.bmp)",
                      "Todos los archivos (*)"]
        onAccepted: {
            editor.filePath = selectedFile.toString()
            editor.logoMode = "custom"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        QQC2.Label {
            text: "Logo de SO · vista previa"
            font.bold: true
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 226
            height: 226
            radius: 12
            color: "#394258"
            border.color: "#798399"
            LogoArtwork {
                id: previewImage
                anchors.centerIn: parent
                width: 204
                height: 204
                imageUrl: editor.selectedImage
                animateGif: editor.isGif
                animationAllowed: editor.enableGif
                cropShape: editor.shape
                fitMode: editor.cropFitMode
                zoom: editor.cropZoom
                panX: editor.cropPanX
                panY: editor.cropPanY
                visible: editor.logoMode !== "text"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    property real lastX: 0
                    property real lastY: 0
                    onPressed: function(mouse) { lastX = mouse.x; lastY = mouse.y }
                    onPositionChanged: function(mouse) {
                        if (!pressed) return
                        // Mover dentro del encuadre. Zoom mínimo = 1:
                        // el movimiento puede no apreciarse sin ampliación.
                        editor.cropPanX = Math.max(-1, Math.min(1,
                            editor.cropPanX + (mouse.x - lastX) / 100))
                        editor.cropPanY = Math.max(-1, Math.min(1,
                            editor.cropPanY + (mouse.y - lastY) / 100))
                        lastX = mouse.x
                        lastY = mouse.y
                    }
                }
            }
            QQC2.Label {
                anchors.centerIn: parent
                text: "SO"
                visible: editor.logoMode === "text"
                color: "white"
                font.pixelSize: 40
            }
        }

        QQC2.Label {
            text: "Arrastrá la imagen para elegir qué parte mostrar."
            color: "#d9d4e8"
            Layout.alignment: Qt.AlignHCenter
        }
        RowLayout {
            QQC2.ComboBox {
                id: modeChooser
                Layout.fillWidth: true
                model: ["Huella predeterminada", "Imagen propia", "Texto SO"]
                currentIndex: editor.logoMode === "text" ? 2 :
                              (editor.logoMode === "custom" ? 1 : 0)
                onActivated: function(i) {
                    editor.logoMode = i === 2 ? "text" : (i === 1 ? "custom" : "default")
                }
            }
            QQC2.Button {
                text: "Elegir archivo…"
                onClicked: chooseImage.open()
            }
        }
        QQC2.Label {
            text: "Forma del recorte"
            color: "#efeafb"
        }
        QQC2.ComboBox {
            Layout.fillWidth: true
            model: ["Cuadrado", "Círculo", "Rombo ♦", "Corazón ♥", "Estrella ★"]
            currentIndex: ["square","circle","diamond","heart","star"].indexOf(editor.shape)
            onActivated: function(i) {
                editor.shape = ["square","circle","diamond","heart","star"][i]
            }
        }

        QQC2.ComboBox {
            Layout.fillWidth: true
            model: ["Imagen completa (encajar)", "Rellenar forma (recortar)"]
            currentIndex: editor.cropFitMode === "crop" ? 1 : 0
            onActivated: function(i) { editor.cropFitMode = i === 1 ? "crop" : "fit" }
        }
        RowLayout {
            QQC2.Label { text: "Escala"; color: "white"; Layout.preferredWidth: 72 }
            QQC2.Slider {
                Layout.fillWidth: true
                from: 1
                to: 4
                value: editor.cropZoom
                onMoved: editor.cropZoom = value
            }
            QQC2.Label { text: Math.round(editor.cropZoom * 100) + "%"; color: "white" }
        }
        RowLayout {
            QQC2.Label { text: "Horizontal"; color: "white"; Layout.preferredWidth: 72 }
            QQC2.Slider {
                Layout.fillWidth: true
                from: -1
                to: 1
                value: editor.cropPanX
                onMoved: editor.cropPanX = value
            }
        }
        RowLayout {
            QQC2.Label { text: "Vertical"; color: "white"; Layout.preferredWidth: 72 }
            QQC2.Slider {
                Layout.fillWidth: true
                from: -1
                to: 1
                value: editor.cropPanY
                onMoved: editor.cropPanY = value
            }
        }
        QQC2.CheckBox {
            text: "Reproducir GIF animados"
            checked: editor.enableGif
            onToggled: editor.enableGif = checked
        }
        RowLayout {
            QQC2.Button {
                text: "Restablecer encuadre"
                onClicked: {
                    editor.cropZoom = 1
                    editor.cropPanX = 0
                    editor.cropPanY = 0
                    editor.shape = "square"
                    editor.cropFitMode = "fit"
                }
            }
            Item { Layout.fillWidth: true }
            QQC2.Button { text: "Cancelar"; onClicked: editor.close() }
            QQC2.Button {
                text: "Aplicar"
                highlighted: true
                onClicked: {
                    editor.saveRequested(editor.logoMode, editor.filePath, editor.shape,
                        editor.cropFitMode, editor.cropZoom, editor.cropPanX,
                        editor.cropPanY, editor.enableGif)
                    editor.close()
                }
            }
        }
    }
}
