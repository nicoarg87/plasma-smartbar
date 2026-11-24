// SPDX-License-Identifier: MIT
// Diagnóstico de grupos de Dolphin en KWin/Wayland: SOLO LECTURA.
// No captura miniaturas, no modifica ventanas ni almacena UUID.
import QtQuick
import org.kde.taskmanager 0.1 as TaskManager

Item {
    id: probe
    property int singleCount: 0
    property int groupCount: 0
    property int groupChildren: 0

    TaskManager.TasksModel {
        id: individual
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
    }
    TaskManager.TasksModel {
        id: grouped
        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
    }

    Repeater {
        model: individual
        delegate: Item {
            required property var model
            readonly property string appId: String(model.AppId || "")
            readonly property var winIds: model.WinIdList || []
            Component.onCompleted: {
                if (appId === "org.kde.dolphin") {
                    probe.singleCount++
                    console.log("SmartBar grupos: Dolphin individual; UUID=" +
                                (winIds.length ? String(winIds[0]) : "(no disponible)"))
                }
            }
        }
    }
    Repeater {
        model: grouped
        delegate: Item {
            required property var model
            readonly property string appId: String(model.AppId || "")
            Component.onCompleted: {
                if (appId === "org.kde.dolphin") {
                    probe.groupCount++
                    probe.groupChildren = Number(model.ChildCount) || 0
                    console.log("SmartBar grupos: Dolphin ficha agrupada; " +
                                "IsGroupParent=" + (model.IsGroupParent === true) +
                                "; ChildCount=" + probe.groupChildren)
                }
            }
        }
    }
    Timer {
        running: true
        repeat: false
        interval: 1700
        onTriggered: {
            console.log("SmartBar grupos: resumen fichas=" + probe.groupCount +
                        ", ventanas individuales=" + probe.singleCount +
                        ", ChildCount=" + probe.groupChildren)
            console.log("SmartBar grupos: solo lectura, sin capturas ni acciones sobre KDE")
            Qt.quit()
        }
    }
}
