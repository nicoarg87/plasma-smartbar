// Plasma SmartBar v0.1 — diagnóstico de tareas REALES y SOLO LECTURA.
// Este archivo NO llama a requestActivate/requestClose/requestToggle*.
// No añade paneles, no instala nada, no cambia ni cierra ventanas.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.taskmanager 0.1 as TaskManager

QQC2.ApplicationWindow {
    id: window
    width: 950
    height: 610
    minimumWidth: 650
    minimumHeight: 360
    visible: true
    title: "Plasma SmartBar Islands — ventanas reales (solo lectura)"
    color: "#192b3a"

    TaskManager.TasksModel {
        id: tasks
        // Una ficha por aplicación por defecto, como el diseño aprobado.
        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false

        onCountChanged: console.log("SmartBar tareas reales: cantidad =", count)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 9

        QQC2.Label {
            Layout.fillWidth: true
            text: "Prueba de detección de ventanas de KDE Plasma 6"
            font.pixelSize: 19
            font.bold: true
            color: "#eaf7ff"
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: "SO todavía NO está conectado: esta lista comprueba primero que KDE nos entrega aplicaciones abiertas. Ninguna fila ejecuta acciones."
            wrapMode: Text.WordWrap
            color: "#bdd6e3"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            QQC2.Label {
                text: "Elementos del modelo: " + tasks.count
                color: "#eaf7ff"
            }

            QQC2.Label {
                text: "Agrupación: por aplicación"
                color: "#a9dce8"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#406074"
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: taskList
                model: tasks
                clip: true
                spacing: 5

                delegate: Rectangle {
                    // Las propiedades QML no pueden comenzar con mayúscula.
                    // KDE publica los roles AppName, IsActive, etc.; Qt los
                    // ofrece a través del objeto "model" de cada delegado.
                    required property var model
                    readonly property string appName: model.AppName || ""
                    readonly property bool isWindow: model.IsWindow === true
                    readonly property bool isGroupParent: model.IsGroupParent === true
                    readonly property int childCount: model.ChildCount || 0
                    readonly property bool isActive: model.IsActive === true
                    readonly property bool isMaximized: model.IsMaximized === true
                    readonly property bool isMinimized: model.IsMinimized === true

                    width: ListView.view ? ListView.view.width - 12 : 700
                    height: 58
                    radius: 10
                    color: isActive ? "#245168" : "#142638"
                    border.color: isActive ? "#52b7cb" : "#36546a"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 12
                        spacing: 12

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: appName.length > 0 ? appName : "(sin nombre de aplicación)"
                            color: "#f0f9ff"
                            font.bold: isActive
                            elide: Text.ElideRight
                        }

                        QQC2.Label {
                            text: isGroupParent ? (childCount + " ventanas") : (isWindow ? "Ventana" : "Otro")
                            color: "#b6d9e7"
                        }

                        QQC2.Label {
                            text: isActive ? "Activa" : (isMinimized ? "Minimizada" : (isMaximized ? "Maximizada" : "Normal"))
                            color: isActive ? "#94ffdd" : "#c1ccd5"
                        }
                    }
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: "#bdd6e3"
            text: "Prueba: abrí/cerrá una ventana de Dolphin o Konsole de la forma habitual y observá si la lista cambia. Cerrá esta ventana con X cuando termines. NO es un administrador de ventanas funcional."
        }
    }
}
