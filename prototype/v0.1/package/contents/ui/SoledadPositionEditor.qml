// Editor de anclajes de Soledad. Configura SOLO posiciones; no mueve ventanas KDE.
// Aparece a petición del usuario mediante el menú existente del agarre (seis puntos).
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "SoledadPositionProfiles.js" as PositionProfiles

QQC2.Dialog {
    id: editor
    title: "Posición de Soledad por aplicación"
    popupType: QQC2.Popup.Window
    width: 460
    height: 465
    padding: 12
    modal: false
    focus: true
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent

    property var realTasksModel: null
    property string profilesJson: "{}"
    property real generalOffset: 0
    property real currentOffset: 0
    property real maxOffset: 0
    property string selectedId: ""
    property string selectedName: ""
    property real previousOffset: 0
    property bool changesSaved: false
    readonly property var savedProfiles: PositionProfiles.readProfiles(profilesJson)
    readonly property var savedIds: Object.keys(savedProfiles).sort()

    signal previewRequested(real offset)
    signal saveRequested(string appId, real offset)
    signal removeRequested(string appId)

    function choose(id, name) {
        const valid = PositionProfiles.validAppId(String(id || ""))
        if (!valid) return
        selectedId = valid
        selectedName = String(name || valid)
        appIdField.text = valid
        positionSlider.value = Object.prototype.hasOwnProperty.call(savedProfiles, valid)
            ? PositionProfiles.clampOffset(savedProfiles[valid], maxOffset)
            : PositionProfiles.clampOffset(generalOffset, maxOffset)
    }
    function openFor(id, name) {
        previousOffset = currentOffset
        changesSaved = false
        selectedId = ""
        selectedName = ""
        appIdField.text = ""
        positionSlider.value = PositionProfiles.clampOffset(currentOffset, maxOffset)
        if (PositionProfiles.validAppId(id)) choose(id, name)
        open()
    }
    onClosed: {
        // La vista previa no es una preferencia: cancelar recupera el lugar.
        if (!changesSaved) previewRequested(previousOffset)
    }

    contentItem: ColumnLayout {
        spacing: 9
        QQC2.Label {
            Layout.fillWidth: true
            text: "Elegí una aplicación abierta o un perfil guardado."
            wrapMode: Text.WordWrap
        }
        QQC2.Label {
            Layout.fillWidth: true
            text: "Aplicaciones abiertas"
            font.bold: true
        }
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 112
            clip: true
            ListView {
                id: runningApps
                model: editor.realTasksModel
                spacing: 2
                clip: true
                delegate: QQC2.ItemDelegate {
                    required property var model
                    width: runningApps.width - 6
                    readonly property string appId: String(model.AppId || "")
                    text: String(model.AppName || appId)
                    enabled: PositionProfiles.validAppId(appId).length > 0
                    highlighted: editor.selectedId === appId
                    onClicked: editor.choose(appId, text)
                }
            }
        }
        QQC2.RowLayout {
            Layout.fillWidth: true
            QQC2.Label { text: "Perfiles guardados" }
            QQC2.ComboBox {
                Layout.fillWidth: true
                model: editor.savedIds
                enabled: editor.savedIds.length > 0
                onActivated: function(index) {
                    editor.choose(editor.savedIds[index], editor.savedIds[index])
                }
            }
        }
        QQC2.Label {
            text: "ID de aplicación (permite configurar una que no esté abierta)"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        QQC2.TextField {
            id: appIdField
            Layout.fillWidth: true
            placeholderText: "Ej.: org.kde.dolphin"
            onTextEdited: {
                editor.selectedId = PositionProfiles.validAppId(text)
                editor.selectedName = editor.selectedId
            }
        }
        QQC2.Label {
            Layout.fillWidth: true
            text: "Posición horizontal: " + Math.round(positionSlider.value) +
                  " px desde el borde derecho"
            wrapMode: Text.WordWrap
        }
        QQC2.Slider {
            id: positionSlider
            Layout.fillWidth: true
            from: 0
            to: Math.max(1, editor.maxOffset)
            stepSize: 1
            onMoved: editor.previewRequested(value)
        }
        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "0 = extremo derecho. Arrastrá el control para previsualizar. " +
                  "Guardar crea una excepción solo para esta aplicación; " +
                  "las demás conservan la posición general."
        }
        QQC2.RowLayout {
            Layout.fillWidth: true
            spacing: 6
            QQC2.Button {
                text: "Guardar para esta app"
                enabled: editor.selectedId.length > 0
                onClicked: {
                    editor.changesSaved = true
                    // Quitar previsualización temporal antes de aplicar el
                    // nuevo perfil; si la app está activa, KWin lo aplicará.
                    editor.previewRequested(editor.previousOffset)
                    editor.saveRequested(editor.selectedId, positionSlider.value)
                    editor.close()
                }
            }
            QQC2.Button {
                text: "Quitar excepción"
                enabled: editor.selectedId.length > 0 &&
                    Object.prototype.hasOwnProperty.call(editor.savedProfiles, editor.selectedId)
                onClicked: {
                    editor.changesSaved = true
                    editor.removeRequested(editor.selectedId)
                    editor.close()
                }
            }
            QQC2.Button {
                text: "Cancelar"
                onClicked: editor.close()
            }
        }
    }
}
