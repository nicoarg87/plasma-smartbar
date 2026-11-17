// Icono de aplicación del tema KDE o del modelo de tareas reales.
// DecorationRole devuelve normalmente QIcon; Kirigami.Icon acepta
// tanto objetos icono como nombres de iconos del tema.
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root
    property var iconSource: ""
    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.min(24, parent.width - 4)
        height: Math.min(24, parent.height - 2)
        source: root.iconSource || "application-x-executable"
        fallback: "application-x-executable"
        isMask: false
    }
}
