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
    title: "Plasma SmartBar — ventanas reales (solo lectura)"
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
                    required property int index
                    required property string AppName
                    required property bool IsWindow
                    required property bool IsGroupParent
                    required property int ChildCount
                    required property bool IsActive
                    required property bool IsMaximized
                    required property bool IsMinimized

                    width: ListView.view ? ListView.view.width - 12 : 700
                    height: 58
                    radius: 10
                    color: IsActive ? "#245168" : "#142638"
                    border.color: IsActive ? "#52b7cb" : "#36546a"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 12
                        spacing: 12

                        QQC2.Label {
                            Layout.fillWidth: true
                            text: AppName.length > 0 ? AppName : "(sin nombre de aplicación)"
                            color: "#f0f9ff"
                            font.bold: IsActive
                            elide: Text.ElideRight
                        }

                        QQC2.Label {
                            text: IsGroupParent ? (ChildCount + " ventanas") : (IsWindow ? "Ventana" : "Otro")
                            color: "#b6d9e7"
                        }

                        QQC2.Label {
                            text: IsActive ? "Activa" : (IsMinimized ? "Minimizada" : (IsMaximized ? "Maximizada" : "Normal"))
                            color: IsActive ? "#94ffdd" : "#c1ccd5"
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
