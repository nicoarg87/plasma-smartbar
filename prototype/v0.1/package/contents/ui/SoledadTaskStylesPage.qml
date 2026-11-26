// Editor de estilos de ventanas SO. Mismas opciones, sin duplicar estado.
// El anfitrión SoledadSettings sigue siendo el dueño del estado y de Aplicar.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

QQC2.ScrollView {
    id: page
    // El editor central conserva propiedad, persistencia y Aplicar.
    property var settingsTarget: null
    property var colorDialog: null
    clip: true
    contentWidth: Math.max(0, availableWidth - 32)
    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
    QQC2.ScrollBar.vertical.width: 16
    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
    ColumnLayout {
        width: Math.max(0, taskStylesScroll.availableWidth - 32)
        spacing: 14
        QQC2.Label {
            text: "Presentación de aplicaciones y líneas"
            font.bold: true
            color: "white"
        }
        QQC2.Label {
            text: "Indicador de aplicación activa"
            font.bold: true
            color: "white"
        }
        QQC2.CheckBox {
            text: "Iluminar la aplicación activa con el efecto de SO"
            checked: page.settingsTarget.taskActiveGlowEnabled
            onToggled: page.settingsTarget.taskActiveGlowEnabled = checked
        }
        QQC2.CheckBox {
            text: "Marcar la aplicación activa con doble línea"
            checked: page.settingsTarget.taskActiveDoubleBorderEnabled
            onToggled: page.settingsTarget.taskActiveDoubleBorderEnabled = checked
        }
        QQC2.Label {
            text: "La luz usa el efecto del botón SO. La doble línea usa el color, grosor y transparencia del contorno de Soledad. Podés activar ambos, uno solo o ninguno."
            color: "#ddd6e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        QQC2.Label {
            text: "Cómo mostrar cada aplicación"
            color: "white"
        }
        QQC2.ComboBox {
            Layout.fillWidth: true
            model: ["Solo nombre", "Icono y nombre", "Solo icono"]
            currentIndex: Math.max(0, ["text", "both", "icon"]
                .indexOf(page.settingsTarget.taskDisplayMode))
            onActivated: function(i) {
                page.settingsTarget.taskDisplayMode = ["text", "both", "icon"][i]
            }
        }
        QQC2.Label {
            text: "En Solo icono, al pasar el cursor aparece el nombre de la aplicación."
            visible: page.settingsTarget.taskDisplayMode === "icon"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: "#ddd6e8"
        }
        QQC2.Label {
            text: "Fichas de aplicaciones abiertas en SO"
            font.bold: true
            color: "white"
        }
        QQC2.Label {
            text: "Dónde mostrar el cierre de ventanas"
            color: "white"
        }
        QQC2.ComboBox {
            id: taskClosePlacement
            Layout.fillWidth: true
            model: ["X en ficha y vista previa",
                    "Solo vista previa (sin X en ficha)",
                    "Solo X en ficha (sin vista previa)"]
            currentIndex: Math.max(0, ["both", "preview", "chip"]
                .indexOf(page.settingsTarget.taskCloseMode))
            onActivated: function(i) {
                page.settingsTarget.taskCloseMode = ["both", "preview", "chip"][i]
            }
            Accessible.name: "Ubicación del cierre de ventanas SO"
        }
        QQC2.Label {
            text: "Siempre queda una forma de cerrar. " +
                  "En modo vista previa, cada ventana tiene su propia X; " +
                  "en modo ficha, la X cierra la ficha agrupada. " +
                  "Las ventanas reales siguen sin control desde el prototipo."
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: "#ddd6e8"
        }
        QQC2.Label {
            text: "El interior de las fichas conserva el degradado de Soledad. Configurá únicamente su marco."
            color: "#ddd6e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        QQC2.Label { text: "Forma de las fichas"; color: "white" }
        QQC2.ComboBox {
            Layout.fillWidth: true
            model: ["Rectángulo con esquinas redondeadas",
                    "Rectángulo cuadrado", "Sin recuadro"]
            currentIndex: Math.max(0, ["rounded", "square", "none"]
                .indexOf(page.settingsTarget.taskFrameShape))
            onActivated: function(i) {
                page.settingsTarget.taskFrameShape = ["rounded", "square", "none"][i]
            }
        }
        QQC2.Label {
            text: "Color de las líneas"
            color: "white"
            visible: page.settingsTarget.taskFrameShape !== "none"
        }
        RowLayout {
            visible: page.settingsTarget.taskFrameShape !== "none"
            Layout.fillWidth: true
            QQC2.Button {
                text: "Elegir color de línea…"
                onClicked: {
                    page.colorDialog.selectedColor = page.settingsTarget.taskFrameColor
                    page.colorDialog.open()
                }
            }
            Rectangle {
                width: 34; height: 24; radius: 4
                color: page.settingsTarget.taskFrameColor
            }
        }
        QQC2.Label {
            text: "Intensidad de las líneas"
            color: "white"
            visible: page.settingsTarget.taskFrameShape !== "none"
        }
        RowLayout {
            visible: page.settingsTarget.taskFrameShape !== "none"
            Layout.fillWidth: true
            QQC2.Slider {
                Layout.fillWidth: true
                from: 0; to: 1; stepSize: 0.05
                value: page.settingsTarget.taskFrameOpacity
                onMoved: page.settingsTarget.taskFrameOpacity = value
            }
            QQC2.Label {
                text: Math.round(page.settingsTarget.taskFrameOpacity * 100) + "%"
                color: "white"
            }
        }
        QQC2.Label {
            text: "Grosor de línea"
            color: "white"
            visible: page.settingsTarget.taskFrameShape !== "none"
        }
        RowLayout {
            visible: page.settingsTarget.taskFrameShape !== "none"
            Layout.fillWidth: true
            QQC2.Slider {
                Layout.fillWidth: true
                from: 0.5; to: 3; stepSize: 0.5
                value: page.settingsTarget.taskFrameWidth
                onMoved: page.settingsTarget.taskFrameWidth = value
            }
            QQC2.Label {
                text: page.settingsTarget.taskFrameWidth.toFixed(1) + " px"
                color: "white"
            }
        }

    }
}
