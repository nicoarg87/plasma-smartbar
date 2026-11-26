import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

// Diálogo informativo; nunca sobrescribe temas oficiales ni guarda valores.
QQC2.Dialog {
    id: exportDialog
    required property var settingsTarget
    readonly property var settings: settingsTarget
        title: "Copiar apariencia exacta para " + (settings.factoryExportTarget === "sunset" ? "Atardecer" : "Noche") + " de fábrica"
        modal: true
        width: Math.min(740, settings.width - 80)
        height: Math.min(560, settings.height - 90)
        standardButtons: QQC2.Dialog.Close
        contentItem: ColumnLayout {
            spacing: 8
            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Copiá este JSON y aportá el GIF o imagen original del logo. " +
                      "La captura incluye los valores visuales exactos actuales y no escribe en la fábrica."
            }
            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                QQC2.TextArea {
                    id: factoryNightExportText
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.WrapAnywhere
                    text: settings.factoryNightCandidateJson()
                }
            }
            QQC2.Button {
                text: "Copiar JSON actual"
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    factoryNightExportText.selectAll()
                    factoryNightExportText.copy()
                    factoryNightExportText.deselect()
                }
            }
        }
    }
