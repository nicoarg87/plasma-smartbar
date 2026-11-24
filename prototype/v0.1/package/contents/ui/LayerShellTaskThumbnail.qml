// SPDX-License-Identifier: MIT
// Miniatura real, temporal, de UNA ventana KDE bajo la isla Soledad.
// El UUID se obtiene de TasksModel actual; no se persiste ni se reutiliza.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.pipewire as KPipeWire

Window {
    id: preview
    property bool runtimeActive: false
    property bool requested: false
    property string windowUuid: ""
    property string appLabel: ""
    property real leftOffset: 0
    property real topOffset: 52
    // Entrar en la miniatura no activa ni enfoca otra ventana.
    signal cursorEntered()
    signal cursorExited()

    visible: runtimeActive && requested && windowUuid.length > 0
    // Reducción visual del 25 % aprobada: 328×222 → 246×166.
    width: 246
    height: 166
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus
    transientParent: null
    title: "Plasma SmartBar — vista previa de ventana"

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorLeft
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.margins: ({
        left: Math.max(0, Math.round(leftOffset)),
        top: Math.max(48, Math.round(topOffset)),
        right: 0, bottom: 0
    })

    TaskManager.ScreencastingRequest {
        id: request
        uuid: preview.visible ? preview.windowUuid : ""
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#172331"
        border.color: "#5d7c90"
        border.width: 1
        clip: true

        KPipeWire.PipeWireSourceItem {
            anchors.fill: parent
            anchors.margins: 5
            nodeId: preview.visible ? request.nodeId : 0
            visible: preview.visible && request.nodeId > 0
        }
        Text {
            anchors.centerIn: parent
            width: parent.width - 30
            text: "Cargando miniatura…"
            color: "#eff7ff"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            visible: preview.visible && request.nodeId <= 0
        }
        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            elide: Text.ElideRight
            text: preview.appLabel
            font.pixelSize: 12
            color: "white"
            style: Text.Outline
            styleColor: "#172331"
        }
        HoverHandler {
            onHoveredChanged: {
                if (hovered) preview.cursorEntered()
                else preview.cursorExited()
            }
        }
    }
    onVisibleChanged: {
        if (visible) console.log("SmartBar SO miniatura: solicitud para", appLabel)
    }
}
