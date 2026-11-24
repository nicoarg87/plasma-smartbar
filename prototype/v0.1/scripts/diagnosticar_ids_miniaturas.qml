// SPDX-License-Identifier: MIT
// Identificar UUID de ventanas KDE para futuras miniaturas.
// SOLO LECTURA: no crea ScreencastingRequest ni PipeWireSourceItem.
import QtQuick
import org.kde.taskmanager 0.1 as TaskManager

Item {
    id: root
    property int observed: 0
    TaskManager.TasksModel {
        id: windows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
    }
    Repeater {
        model: windows
        delegate: Item {
            required property var model
            readonly property string appName: String(model.AppName || "")
            readonly property string appId: String(model.AppId || "")
            readonly property var winIds: model.WinIdList || []
            Component.onCompleted: {
                if (appName.toLowerCase().includes("dolphin")) {
                    root.observed++
                    // Mostrar un identificador técnico, NO título de documento
                    // ni ruta de archivo; truncado evita IDs ilegibles.
                    console.log("SmartBar miniatura: Dolphin AppId=" + appId +
                        " ventanas=" + winIds.length +
                        " UUID=" + (winIds.length ? String(winIds[0]).slice(0, 80) : "(sin UUID)"))
                }
            }
        }
    }
    Timer {
        running: true
        interval: 1500
        repeat: false
        onTriggered: {
            if (root.observed === 0)
                console.log("SmartBar miniatura: no se observó Dolphin; abrí una ventana y repetí.")
            else
                console.log("SmartBar miniatura: lectura de UUID finalizada, SIN capturas.")
            Qt.quit()
        }
    }
}
