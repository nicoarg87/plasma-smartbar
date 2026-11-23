// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Experimento de ventana ESTABLE + máscara de entrada Qt6 en la isla real.
// NO crear una banda interactiva sobre Brave; mask excluye todo salvo Soledad.
// No se instalan plasmoides ni se leen/modifican preferencias personales.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import "package/contents/ui" as SmartBar

Window {
    id: probe
    objectName: "smartbarFixedInputProbe"
    visible: false // C++ aplica QWindow::setMask ANTES de mostrar la ventana
    title: "SmartBar — Soledad fija con región de entrada limitada"
    width: Screen.width
    height: 44
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    // Anclaje permanente: NO modificar margins ni geometría Window al mover.
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorLeft |
                               LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.margins: ({ left: 0, top: 6, right: 0, bottom: 0 })

    // DIAGNÓSTICO provisional: no es la medida real de los botones de Brave.
    // Solo se aplica si KDE informa una ventana EXTERNA activa maximizada.
    // El objetivo es verificar si la reserva evita la superposición sin
    // reconfigurar el Window fijo ni tocar ventanas o preferencias.
    readonly property real trialControlsReservePx: 176
    property bool externalActiveMaximized: false

    TaskManager.TasksModel {
        id: kdeWindows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: Qt.callLater(probe.refreshExternalMaximized)
    }

    // Delegados INVISIBLES: observan roles de KDE. No pintan nada,
    // no participan del mouse y no activan/minimizan/cierran ventanas.
    Repeater {
        id: kdeWindowObservers
        model: kdeWindows
        onItemAdded: Qt.callLater(probe.refreshExternalMaximized)
        onItemRemoved: Qt.callLater(probe.refreshExternalMaximized)
        delegate: Item {
            required property var model
            width: 0
            height: 0
            visible: false
            readonly property bool taskWindow: model.IsWindow === true
            readonly property bool taskActive: model.IsActive === true
            readonly property bool taskMaximized: model.IsMaximized === true
            readonly property bool taskFullScreen: model.IsFullScreen === true
            readonly property string taskName: String(model.AppName || "")
            onTaskWindowChanged: Qt.callLater(probe.refreshExternalMaximized)
            onTaskActiveChanged: Qt.callLater(probe.refreshExternalMaximized)
            onTaskMaximizedChanged: Qt.callLater(probe.refreshExternalMaximized)
            onTaskFullScreenChanged: Qt.callLater(probe.refreshExternalMaximized)
            Component.onCompleted: Qt.callLater(probe.refreshExternalMaximized)
        }
    }

    function refreshExternalMaximized() {
        let activeMaximized = false
        let activeName = ""
        for (let i = 0; i < kdeWindowObservers.count; ++i) {
            const task = kdeWindowObservers.itemAt(i)
            if (task && task.taskWindow && task.taskActive &&
                    task.taskMaximized && !task.taskFullScreen) {
                activeMaximized = true
                activeName = task.taskName
                break
            }
        }
        if (externalActiveMaximized !== activeMaximized) {
            externalActiveMaximized = activeMaximized
            console.log("SmartBar KDE solo lectura:",
                        activeMaximized ? "ventana maximizada" : "sin maximizada activa",
                        activeName,
                        "reserva provisional =", activeMaximized
                            ? trialControlsReservePx : 0, "px")
        }
    }

    function refreshInputRegion() {
        // En esta variante solo el Item cambia de x, el Window NO se mueve.
        // El mismo cálculo que usa systemIsland.x en SmartBarContent.
        if (!bar || bar.actualIslandWidth <= 0 || probe.width <= 0)
            return
        const x = bar.width - bar.actualIslandWidth -
                  bar.islandOffset - bar.controlsReservation
        soledadInputMask.setIslandRect(
            x, 0, bar.actualIslandWidth, probe.height)
    }
    onWidthChanged: refreshInputRegion()
    onHeightChanged: refreshInputRegion()

    SmartBar.SmartBarContent {
        id: bar
        objectName: "smartbarFixedInputRealSoledad"
        width: probe.width
        height: probe.height
        x: 0
        y: 0

        // Componente REAL, agarre y GIF tropical existentes.
        // Esta ventana nueva no carga Qt Settings ni perfiles del usuario.
        positionMode: "right"
        panelHeight: 48
        soledadHeight: 44
        launcherIslandVisible: false
        showBackground: false
        previewMaximized: false
        demoWindowControlsEnabled: false
        // Solo este ensayo inyecta la reserva; el visor normal conserva 0.
        externalWindowControlsReserve: probe.externalActiveMaximized
            ? probe.trialControlsReservePx : 0
        soLogoMode: "default"
        themeScheduleRuntimeEnabled: false
        // Mantener el DragHandler ORIGINAL: ventana/escena permanecen FIJAS.
        layerShellDragCompensation: false

        onIslandOffsetChanged: probe.refreshInputRegion()
        onActualIslandWidthChanged: probe.refreshInputRegion()
        onControlsReservationChanged: probe.refreshInputRegion()
        onSoExpandedChanged: probe.refreshInputRegion()
        onTrayExpandedChanged: probe.refreshInputRegion()
    }

    // Límite del ensayo. La aplicación termina con la última ventana.
    Timer {
        interval: 90000
        running: true
        repeat: false
        onTriggered: {
            console.log("SmartBar región fija: cierre automático, sin cambios")
            probe.close()
        }
    }
    Component.onCompleted: {
        Qt.callLater(probe.refreshExternalMaximized)
        console.log(
        "SmartBar: ventana LayerShellQt FIJA, input limitado por QWindow::setMask.",
        "Arrastrar SOLO los seis puntos de la Soledad auténtica;",
        "el espacio invisible fuera de la isla debería dejar usar Brave.",
        "Reserva de prueba:", trialControlsReservePx,
        "px SOLO para ventana externa activa y maximizada.",
        "Sin perfiles ni instalación de panel. Autocierre 90 s / Ctrl+C.")
    }
}
