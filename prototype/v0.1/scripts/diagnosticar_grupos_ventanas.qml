// SPDX-License-Identifier: MIT
// Diagnóstico no invasivo: fotografía del MODELO ESTABILIZADO de Dolphin.
// No captura, activa, cierra ni modifica ventanas; UUID son efímeros.
import QtQuick
import org.kde.taskmanager 0.1 as TaskManager

Item {
    id: probe
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
        id: individuals
        model: individual
        delegate: Item {
            required property var model
            readonly property string appId: String(model.AppId || "")
            readonly property var winIds: model.WinIdList || []
        }
    }
    Repeater {
        id: groups
        model: grouped
        delegate: Item {
            required property var model
            readonly property string appId: String(model.AppId || "")
            readonly property bool isGroup: model.IsGroupParent === true
            readonly property int children: Number(model.ChildCount) || 0
            readonly property var winIds: model.WinIdList || []
        }
    }
    Timer {
        running: true
        repeat: false
        interval: 2500
        onTriggered: {
            var singles = 0
            var groupRows = 0
            for (var i = 0; i < individuals.count; ++i) {
                var item = individuals.itemAt(i)
                if (!item || item.appId !== "org.kde.dolphin")
                    continue
                singles++
                console.log("SmartBar grupos: Dolphin individual #" + singles +
                            "; UUID=" + (item.winIds.length ?
                                         String(item.winIds[0]) : "(no disponible)"))
            }
            for (var j = 0; j < groups.count; ++j) {
                var group = groups.itemAt(j)
                if (!group || group.appId !== "org.kde.dolphin")
                    continue
                groupRows++
                console.log("SmartBar grupos: Dolphin ficha #" + groupRows +
                            "; IsGroupParent=" + group.isGroup +
                            "; ChildCount=" + group.children +
                            "; WinIdList.length=" + group.winIds.length)
            }
            // Correlación exacta por UUID, sin depender del orden de filas.
            // Evita activar una ventana equivocada cuando TasksModel reordena.
            var allSingles = []
            for (var k = 0; k < individuals.count; ++k) {
                var one = individuals.itemAt(k)
                if (one && one.appId === "org.kde.dolphin" && one.winIds.length === 1)
                    allSingles.push(String(one.winIds[0]))
            }
            var missing = 0
            var extra = 0
            var duplicate = 0
            for (var m = 0; m < groups.count; ++m) {
                var groupedRow = groups.itemAt(m)
                if (!groupedRow || groupedRow.appId !== "org.kde.dolphin")
                    continue
                var observed = []
                for (var n = 0; n < groupedRow.winIds.length; ++n) {
                    var uuid = String(groupedRow.winIds[n])
                    if (observed.indexOf(uuid) !== -1)
                        duplicate++
                    observed.push(uuid)
                    if (allSingles.indexOf(uuid) === -1)
                        extra++
                }
                for (var o = 0; o < allSingles.length; ++o)
                    if (observed.indexOf(allSingles[o]) === -1)
                        missing++
            }
            console.log("SmartBar grupos: correlación UUID faltantes=" + missing +
                        ", ajenos=" + extra + ", duplicados=" + duplicate)
            console.log("SmartBar grupos: lectura FINAL fichas=" + groupRows +
                        ", ventanas individuales=" + singles)
            console.log("SmartBar grupos: solo lectura; no cambia KDE ni preferencias")
            Qt.quit()
        }
    }
}
