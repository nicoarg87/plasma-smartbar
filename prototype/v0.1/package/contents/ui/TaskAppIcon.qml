// Icono de aplicación del tema KDE o del modelo de tareas reales.
// DecorationRole devuelve normalmente QIcon; Kirigami.Icon acepta
// tanto objetos icono como nombres de iconos del tema.
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root
    property var iconSource: ""
    property string fallbackLabel: ""
    Kirigami.Icon {
        id: appIcon
        anchors.centerIn: parent
        width: Math.max(18, Math.min(27, parent.width - 2))
        height: Math.max(18, Math.min(27, parent.height - 2))
        // Icono de KDE o de la entrada .desktop instalada.
        source: root.iconSource
        fallback: ""
        isMask: false
        visible: root.iconSource !== "" && valid
    }
    Text {
        // Si falta el icono temático, mantener identidad mediante inicial.
        anchors.fill: parent
        visible: !appIcon.visible
        text: root.fallbackLabel.length ? root.fallbackLabel.slice(0, 1).toUpperCase() : "?"
        font.family: "Sans Serif"
        font.bold: true
        font.pixelSize: 20
        fontSizeMode: Text.Fit
        minimumPixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#ffffff"
    }
}
