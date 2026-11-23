// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Ensayo AISLADO de Malvina siempre sobre ventanas comunes/maximizadas.
// La superficie nativa mide SOLO lo que ocupa Malvina. No instala un panel.
// Una detección KDE desconocida impide mostrar la ventana por seguridad.
// Esta prueba fuerza Malvina visible SOLO en memoria; no guarda preferencias.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import "package/contents/ui" as SmartBar

Window {
    id: probe
    objectName: "smartbarMalvinaTopProbe"
    property bool malvinaMaskProbe: true
    property bool bridgePrepared: false
    property bool fullscreenDetected: false
    property int stateSamples: 0
    visible: false
    title: "SmartBar — Malvina por encima, excepto fullscreen real"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    width: Math.max(1, Math.ceil(bar.actualMalvinaWidth))
    height: Math.max(1, Math.ceil(bar.actualMalvinaHeight))

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorLeft
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityNone
    LayerShell.Window.margins: ({left: 0, top: 0, right: 0, bottom: 0})

    function refreshInputRegion() {
        if (bar.actualMalvinaWidth <= 0 || bar.actualMalvinaHeight <= 0)
            return
        // El rectángulo de entrada solo comprende Malvina, no el escritorio.
        soledadInputMask.setIslandRect(0, 0, bar.actualMalvinaWidth,
                                      bar.actualMalvinaHeight)
    }

    function snapshotFullscreen() {
        for (let i = 0; i < observedWindows.count; ++i) {
            const item = observedWindows.itemAt(i)
            if (item !== null && item.taskFullScreen && !item.taskMinimized)
                return true
        }
        return false
    }

    function refreshVisibility() {
        if (!bridgePrepared) return
        // Si el modelo KDE todavía no contiene ventanas, no hay garantía
        // de que el fullscreen se haya detectado: permanecer invisible.
        if (kdeWindows.count === 0 || observedWindows.count < kdeWindows.count) {
            if (visible) visible = false
            return
        }
        const full = snapshotFullscreen()
        if (fullscreenDetected !== full) {
            fullscreenDetected = full
            console.log("SmartBar MALVINA fullscreen KDE:", full)
        }
        if (full) {
            if (visible) visible = false
        } else {
            refreshInputRegion()
            if (!visible) visible = true
        }
    }

    function scheduleCheck() {
        if (!bridgePrepared) return
        stateSamples = 0
        stateCheckTimer.restart()
        Qt.callLater(probe.refreshVisibility)
    }

    function bridgeReady() {
        // Lo llama C++ SOLO después de crear la ventana y fijar su máscara.
        bridgePrepared = true
        stateSamples = 0
        stateCheckTimer.restart()
        console.log("SmartBar MALVINA: esperando tareas KDE antes de mostrar")
    }

    Timer {
        id: stateCheckTimer
        interval: 250
        repeat: true
        running: false
        onTriggered: {
            probe.refreshVisibility()
            probe.stateSamples++
            if (probe.stateSamples >= 12) stop()
        }
    }

    TaskManager.TasksModel {
        id: kdeWindows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: probe.scheduleCheck()
    }

    Repeater {
        id: observedWindows
        model: kdeWindows
        onItemAdded: probe.scheduleCheck()
        onItemRemoved: probe.scheduleCheck()
        delegate: Item {
            required property var model
            width: 0
            height: 0
            visible: false
            readonly property bool taskFullScreen: model.IsFullScreen === true
            readonly property bool taskMinimized: model.IsMinimized === true
            onTaskFullScreenChanged: probe.scheduleCheck()
            onTaskMinimizedChanged: probe.scheduleCheck()
            Component.onCompleted: probe.scheduleCheck()
        }
    }

    SmartBar.SmartBarContent {
        id: bar
        // El contenido es compartido con Soledad: la ventana recorta
        // físicamente todo lo que quede a la derecha de Malvina.
        width: Math.max(760, probe.Screen.width)
        height: 48
        x: 0
        y: 0
        panelHeight: 48
        malvinaHeight: 44
        soledadHeight: 44
        launcherIslandVisible: true
        autoHideMalvina: false // SOLO el ensayo, no las preferencias guardadas
        positionMode: "right"
        demoWindowControlsEnabled: false
        themeScheduleRuntimeEnabled: false
        showBackground: false
        windowStateKnown: true
        hostMaximized: false
        hostFullscreen: probe.fullscreenDetected
        onActualMalvinaWidthChanged: probe.refreshInputRegion()
        onActualMalvinaHeightChanged: probe.refreshInputRegion()
    }

    Timer {
        interval: 90000
        repeat: false
        running: true
        onTriggered: {
            console.log("SmartBar MALVINA: autocierre del ensayo")
            probe.close()
        }
    }
}
