// SPDX-License-Identifier: MIT
// Prueba aislada de miniatura REAL de Dolphin en KDE/Wayland.
// Solo lee las ventanas KDE y solicita capturar UNA ventana Dolphin existente.
// No se incorpora a Soledad ni modifica paneles, posiciones o audio.
import QtQuick
import QtQuick.Window
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.pipewire as KPipeWire

Window {
    id: probe
    width: 420
    height: 290
    minimumWidth: 320
    minimumHeight: 220
    visible: true
    color: "#19212b"
    title: "Plasma SmartBar — miniatura Dolphin (ensayo aislado)"

    property string dolphinUuid: ""
    property bool receivedNode: false

    TaskManager.TasksModel {
        id: kdeWindows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
    }

    Repeater {
        model: kdeWindows
        delegate: Item {
            required property var model
            width: 0
            height: 0
            visible: false
            readonly property string appId: String(model.AppId || "")
            readonly property string appName: String(model.AppName || "")
            readonly property var winIds: model.WinIdList || []
            Component.onCompleted: {
                if (!probe.dolphinUuid &&
                    (appId === "org.kde.dolphin" ||
                     appName.toLowerCase() === "dolphin") &&
                    winIds.length > 0) {
                    probe.dolphinUuid = String(winIds[0])
                    console.log("SmartBar miniatura: ventana Dolphin encontrada; UUID temporal listo")
                }
            }
        }
    }

    // Solo se inicia un screencast al conocer el UUID de una ventana Dolphin.
    // No hay captura de pantalla completa ni de otras aplicaciones.
    TaskManager.ScreencastingRequest {
        id: screencast
        uuid: probe.dolphinUuid
        onNodeIdChanged: {
            if (nodeId > 0) {
                probe.receivedNode = true
                console.log("SmartBar miniatura: KWin entregó nodo PipeWire para Dolphin")
            } else {
                probe.receivedNode = false
                console.log("SmartBar miniatura: no hay nodo activo")
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 12
        radius: 10
        color: "#283341"
        border.color: "#77889c"
        clip: true

        KPipeWire.PipeWireSourceItem {
            id: image
            anchors.fill: parent
            nodeId: screencast.nodeId
            visible: probe.receivedNode
        }

        Text {
            anchors.centerIn: parent
            width: parent.width - 24
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "white"
            font.pixelSize: 14
            visible: !probe.receivedNode
            text: probe.dolphinUuid
                  ? "Solicitando miniatura de Dolphin a KWin…"
                  : "Abrí una ventana de Dolphin para comenzar."
        }
    }
    Timer {
        running: true
        repeat: false
        interval: 25000
        onTriggered: {
            console.log("SmartBar miniatura: ensayo concluido; liberando captura")
            probe.close()
        }
    }
    onClosing: {
        console.log("SmartBar miniatura: finalizando ensayo aislado")
    }
}
