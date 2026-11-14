import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_autoReturnRight: resetRight.checked

    QQC2.CheckBox {
        id: resetRight
        text: "Volver automáticamente a la derecha al desmaximizar"
        checked: true
    }

    QQC2.Label {
        text: "La v0.1 simula la maximización: todavía no consulta a KWin."
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
}
