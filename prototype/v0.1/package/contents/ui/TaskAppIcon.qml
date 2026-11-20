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
        width: Math.max(12, Math.min(24, parent.width - 4))
        height: Math.max(12, Math.min(24, parent.height - 2))
        // Preferir el icono REAL del tema KDE (o QIcon del TasksModel).
        // No usar un glifo genérico que oculte que el tema no lo encuentra.
        source: root.iconSource
        fallback: ""
        isMask: false
        visible: valid
    }
    Text {
        // Respaldo local legible; nunca fingir un icono oficial inexistente.
        // Kirigami.Icon.valid informa si hay icono que se pueda mostrar.
        anchors.centerIn: parent
        visible: !appIcon.valid
        text: root.fallbackLabel.length ? root.fallbackLabel.slice(0, 1).toUpperCase() : "?"
        font.bold: true
        font.pixelSize: 16
        color: "#eaf7ff"
    }
}
