// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Experimento de ventana ESTABLE + máscara de entrada Qt6 en la isla real.
// NO crear una banda interactiva sobre Brave; mask excluye todo salvo Soledad.
// No se instalan plasmoides ni se leen/modifican preferencias personales.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import org.kde.taskmanager 0.1 as TaskManager
import QtCore as QtCore
import "package/contents/ui" as SmartBar
import "package/contents/ui/RealActiveWindow.js" as RealActiveWindow

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

    // Reutilizar ÚNICAMENTE la clave de perfiles reales ya usada por el
    // visor Qt. Nunca leer ni sobrescribir temas, GIF ni ajustes del panel KDE.
    // Los cambios se escriben SOLO al elegir «Recordar esta posición…».
    QtCore.Settings {
        id: profileSettings
        category: "plasma-smartbar-v01-preview-appearance"
    }
    property string positionProfilesJson:
        String(profileSettings.value("soledadRealPositionProfilesV1", "{}"))

    // Estado de la última ventana EXTERNA identificada. El popup/agarre
    // no debe borrar Brave/Steam al perderse transitoriamente el foco.
    property string trackedAppId: ""
    property string trackedAppName: ""
    property bool trackedMaximized: false
    property bool trackedFullscreen: false
    property bool trackedKnown: false

    TaskManager.TasksModel {
        id: kdeWindows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: Qt.callLater(probe.refreshExternalWindow)
    }

    // El cajón SO conserva agrupación por aplicación; el segundo modelo
    // sin agrupar es SOLO para observar una ventana real concreta.
    TaskManager.TasksModel {
        id: groupedKdeWindows
        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
    }

    Repeater {
        id: kdeWindowObservers
        model: kdeWindows
        onItemAdded: Qt.callLater(probe.refreshExternalWindow)
        onItemRemoved: Qt.callLater(probe.refreshExternalWindow)
        delegate: Item {
            required property var model
            width: 0
            height: 0
            visible: false
            readonly property string appId: String(model.AppId || "")
            readonly property string appName: String(model.AppName || "")
            readonly property bool taskActive: model.IsActive === true
            readonly property bool taskMaximized: model.IsMaximized === true
            readonly property bool taskMinimized: model.IsMinimized === true
            readonly property bool taskFullScreen: model.IsFullScreen === true
            function snapshot() {
                return { appId: appId, appName: appName,
                    active: taskActive, maximized: taskMaximized,
                    minimized: taskMinimized, fullscreen: taskFullScreen }
            }
            onAppIdChanged: Qt.callLater(probe.refreshExternalWindow)
            onTaskActiveChanged: Qt.callLater(probe.refreshExternalWindow)
            onTaskMaximizedChanged: Qt.callLater(probe.refreshExternalWindow)
            onTaskMinimizedChanged: Qt.callLater(probe.refreshExternalWindow)
            onTaskFullScreenChanged: Qt.callLater(probe.refreshExternalWindow)
            Component.onCompleted: Qt.callLater(probe.refreshExternalWindow)
        }
    }

    function refreshExternalWindow() {
        const rows = []
        for (let i = 0; i < kdeWindowObservers.count; ++i) {
            const item = kdeWindowObservers.itemAt(i)
            if (item !== null) rows.push(item.snapshot())
        }
        const active = RealActiveWindow.resolve(rows)
        const previousId = trackedAppId
        const previousMaximized = trackedMaximized
        const previousFullscreen = trackedFullscreen
        const previousKnown = trackedKnown

        if (active.known && active.appId !== "org.qt-project.qml6" &&
                active.appId !== "smartbar_input_mask_probe") {
            // Activación de una ventana externa: perfil de ESA aplicación.
            trackedAppId = active.appId
            trackedAppName = active.appName
            trackedMaximized = active.maximized
            trackedFullscreen = active.fullscreen
            trackedKnown = true
        } else if (trackedKnown) {
            // Al abrir un menú la aplicación de fondo pierde foco, pero
            // NO se minimiza: conservar su perfil mientras siga maximizada.
            const stillThere = rows.filter(function(row) {
                return row.appId === trackedAppId
            })
            if (stillThere.length > 0) {
                trackedMaximized = stillThere.some(function(row) {
                    return row.maximized && !row.minimized && !row.fullscreen
                })
                trackedFullscreen = stillThere.some(function(row) {
                    return row.fullscreen && !row.minimized
                })
            } else if (kdeWindows.count > 0) {
                // La última ventana conocida ya no está: retorno general.
                trackedAppId = ""
                trackedAppName = ""
                trackedMaximized = false
                trackedFullscreen = false
                trackedKnown = false
            }
        }
        const changed = previousId !== trackedAppId ||
            previousMaximized !== trackedMaximized ||
            previousFullscreen !== trackedFullscreen ||
            previousKnown !== trackedKnown
        if (changed) {
            console.log("SmartBar perfil real:", trackedAppName || "(sin aplicación)",
                        "AppId:", trackedAppId || "(ninguno)",
                        "maximizada:", trackedMaximized,
                        "fullscreen:", trackedFullscreen,
                        "perfil guardado:", trackedKnown)
            Qt.callLater(function() {
                if (probe.trackedKnown) bar.applyRealPositionProfile()
                else if (!bar.draggingIslandGrip) bar.alignRightNow()
            })
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
        // Activar el menú CONTEXTUAL ya existente de «Recordar posición…»
        // sin crear botones ni controlar ventanas externas.
        demoWindowControlsEnabled: true
        realTaskModel: groupedKdeWindows
        realTrackedAppId: probe.trackedAppId
        realTrackedAppName: probe.trackedAppName
        realTrackedMaximized: probe.trackedMaximized
        realTrackedFullscreen: probe.trackedFullscreen
        realTrackedKnown: probe.trackedKnown
        realPositionProfilesJson: probe.positionProfilesJson
        onRequestRealPositionProfilesChange: function(json) {
            // Persistencia SOLO por clic explícito sobre menú existente.
            probe.positionProfilesJson = json
            profileSettings.setValue("soledadRealPositionProfilesV1", json)
            profileSettings.sync()
            console.log("SmartBar: posición guardada por aplicación real")
        }
        // No inventar ancho de botones de Brave/Steam. El usuario posiciona
        // libremente y fija por aplicación; general: extremo derecho.
        externalWindowControlsReserve: 0
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
        Qt.callLater(probe.refreshExternalWindow)
        console.log(
        "SmartBar: ventana LayerShellQt FIJA, input limitado por QWindow::setMask.",
        "Arrastrar SOLO los seis puntos de la Soledad auténtica;",
        "el espacio invisible fuera de la isla debería dejar usar Brave.",
        "Sin margen fijo por controles de Brave.",
        "Clic derecho en el agarre: Recordar esta posición para [aplicación].",
        "Se conserva memoria real del visor Qt, SIN cambiar temas ni panel.",
        "Autocierre 90 s / Ctrl+C.")
    }
}
