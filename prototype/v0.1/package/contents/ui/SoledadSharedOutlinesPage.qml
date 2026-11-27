import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

// Editor visual de contornos; los valores y la persistencia pertenecen a SoledadSettings.
QQC2.ScrollView {
    id: page
    required property var settingsTarget
    required property var outlineColorDialog
    readonly property var settings: settingsTarget
    property alias currentTargetIndex: outlineTarget.currentIndex
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.width: 16
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, page.availableWidth - 32)
                    spacing: 14
                    QQC2.Label {
                        text: "Editá el contorno de cada superficie por separado.\n" +
                              "Soledad, Malvina, bandeja y agarre conservan sus propios valores.\n" +
                              "Pulsá Aplicar para guardar sin cerrar."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Contorno de islas y botones"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.ComboBox {
                        id: outlineTarget
                        Layout.fillWidth: true
                        model: ["Soledad", "Malvina", "Botones de bandeja", "Agarre de seis puntos"]
                    }
                    QQC2.Label { text: "Tipo de línea"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Sin línea", "Simple continua", "Doble", "Discontinua", "Punteada"]
                        currentIndex: ["off", "solid", "double", "dashed", "dotted"].indexOf(settings.selectedOutline.style)
                        onActivated: function(i) { settings.setOutlineField("style", ["off","solid","double","dashed","dotted"][i]) }
                    }
                    QQC2.Label { text: "Grosor de línea"; color: "white" }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.5; to: 5; stepSize: 0.5
                            value: settings.selectedOutline.width
                            onMoved: settings.setOutlineField("width", value)
                        }
                        QQC2.Label {
                            text: settings.selectedOutline.width.toFixed(1) + " px"
                            color: "white"
                            Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Color del contorno…"
                            onClicked: {
                                outlineColorDialog.selectedColor = settings.selectedOutline.color
                                outlineColorDialog.open()
                            }
                        }
                        Rectangle { width: 34; height: 24; radius: 4; color: settings.selectedOutline.color }
                    }
                    QQC2.Label { text: "Transparencia del contorno"; color: "white" }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.selectedOutline.opacity
                            onMoved: settings.setOutlineField("opacity", value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.selectedOutline.opacity * 100) + "% visible"
                            color: "white"; Layout.preferredWidth: 90
                        }
                    }
                    QQC2.Button {
                        text: "Restablecer contorno seleccionado"
                        onClicked: {
                            settings.setOutlineField("style", "solid")
                            settings.setOutlineField("width", 1)
                            settings.setOutlineField("color",
                                settings.outlineTargetKey === "soledad" || settings.outlineTargetKey === "malvina" ? "#4e8499" : "#45647a")
                            settings.setOutlineField("opacity", 1)
                        }
                    }
                }
            }
