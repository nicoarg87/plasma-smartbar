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
import "package/contents/ui/SoledadPositionProfiles.js" as SoledadPositionProfiles

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
        smartbarContinuousMode ? LayerShell.Window.KeyboardInteractivityOnDemand
                               : LayerShell.Window.KeyboardInteractivityNone
    // Alineación al borde físico superior: sin el hueco previo de 6 px.
    // El Window continúa fijo; la máscara de entrada solo cubre Soledad.
    LayerShell.Window.margins: ({ left: 0, top: 0, right: 0, bottom: 0 })

    // Reutilizar la LÓGICA de perfiles del visor Qt, pero con preferencias
    // separadas para este ejecutable experimental. No tocar los perfiles
    // del visor, temas, GIF ni ajustes del panel KDE.
    // Los cambios se escriben SOLO al elegir «Recordar esta posición…».
    QtCore.Settings {
        id: profileSettings
        category: "plasma-smartbar-v01-fixed-input-positions"
    }
    property string positionProfilesJson:
        String(profileSettings.value("soledadRealPositionProfilesV1", "{}"))
    // El valor general arranca desde la ubicación histórica de Brave
    // hasta que el usuario fija explícitamente otra. No se escriben datos al leer.
    property real generalOffset: SoledadPositionProfiles.baselineFromSettings(
        profileSettings.value("generalSoledadOffsetV1", ""), positionProfilesJson)

    // Solo diagnóstico de lectura: comparar AppId de Steam/Brave con las
    // claves efectivamente guardadas. Nunca crear/borrar perfiles aquí.
    function logPositionStorage(reason) {
        const saved = SoledadPositionProfiles.readProfiles(positionProfilesJson)
        const ids = Object.keys(saved)
        const id = SoledadPositionProfiles.validAppId(trackedAppId)
        const found = id.length > 0 &&
            Object.prototype.hasOwnProperty.call(saved, id)
        console.log("SmartBar DIAGNOSTICO memoria:", reason,
                    "perfiles=" + ids.length,
                    "IDs guardados=" + JSON.stringify(ids),
                    "AppId observado=" + (id || "(ninguno)"),
                    "coincidencia=" + found,
                    "desplazamiento guardado=" + (found ? saved[id] : "(ninguno)"),
                    "maximizada=" + trackedMaximized)
    }

    // Estado de la última ventana EXTERNA identificada. El popup/agarre
    // no debe borrar Brave/Steam al perderse transitoriamente el foco.
    property string trackedAppId: ""
    property string trackedAppName: ""
    property bool trackedMaximized: false
    property bool trackedFullscreen: false
    property bool trackedKnown: false
    // Estado REAL del conjunto de ventanas de KWin, no del foco actual.
    property bool anyVisibleMaximized: false
    // Mantener la posición visible durante cambios de FOCO hacia una
    // ventana restaurada con otra maximizada detrás. No es un perfil.
    property string heldNormalFocusAppId: ""
    // Versiona acciones diferidas para evitar que un evento KDE antiguo
    // aplique un perfil cuando ya cambió la ventana o su maximización.
    property int positionTransitionRevision: 0
    property string lastTopMaximizedSignature: ""
    // Memoria VISUAL y efímera: NO es otro perfil por aplicación.
    // El último desplazamiento estable antes de fullscreen debe volver
    // al salir, aunque un chat auxiliar reciba foco sin maximizar.
    property real lastVisibleIslandOffset: 0
    property bool lastVisibleIslandKnown: false
    property real fullscreenSavedIslandOffset: 0
    property bool fullscreenObserved: false
    property bool fullscreenAnchorHeld: false
    property bool fullscreenExited: false
    property string fullscreenPriorAppId: ""
    property var fullscreenTransitionFocusIds: ({})
    property bool fullscreenFocusSettled: false
    Timer {
        id: fullscreenFocusTimer
        interval: 1800
        repeat: false
        running: false
        onTriggered: probe.fullscreenFocusSettled = true
    }
    function allPositionProfiles(rows) {
        return SoledadPositionProfiles.withGeneralBaseline(
            rows, positionProfilesJson, generalOffset)
    }
    function recoverInitialMaximizedAnchor(rows) {
        // Arranque desde Konsole: identificar la maximizada VISIBLE más
        // alta según StackingOrder, aunque existan otras maximizadas detrás.
        // No elegir arbitrariamente si KDE no informó el orden.
        if (lastVisibleIslandKnown || fullscreenObserved ||
                fullscreenAnchorHeld || bar.draggingIslandGrip ||
                bar.width <= 0 || bar.actualIslandWidth <= 0 ||
                bar.maxIslandOffset <= 0) return false
        const candidate = RealActiveWindow.topmostMaximizedProfile(
            rows, allPositionProfiles(rows))
        if (candidate.kind !== "profile") return false
        const offset = Math.min(bar.maxIslandOffset,
                                Math.max(0, candidate.offset))
        bar.setIslandOffset(offset)
        bar.alignRightSelected = offset === 0
        bar.ensureExpansionFits()
        lastVisibleIslandOffset = offset
        lastVisibleIslandKnown = true
        refreshInputRegion()
        console.log("SmartBar inicio anclaje: maximizada superior",
                    candidate.appId, "offset=", offset, "(sin escribir perfiles)")
        return true
    }
    function rememberVisibleIslandOffset() {
        if (bar.draggingIslandGrip) {
            lastVisibleIslandOffset = bar.islandOffset
            lastVisibleIslandKnown = true
            if (fullscreenExited) {
                // Movimiento explícito del usuario: nueva posición manual.
                fullscreenAnchorHeld = false
                fullscreenExited = false
            }
        } else if (!fullscreenAnchorHeld && !fullscreenObserved &&
                   trackedKnown && trackedMaximized && !trackedFullscreen) {
            lastVisibleIslandOffset = bar.islandOffset
            lastVisibleIslandKnown = true
        }
    }
    function restoreLastFullscreenPosition() {
        if (!fullscreenAnchorHeld || !fullscreenExited ||
                bar.draggingIslandGrip) return
        const offset = Math.min(bar.maxIslandOffset,
                                Math.max(0, fullscreenSavedIslandOffset))
        if (Math.abs(bar.islandOffset - offset) < 0.1) return
        bar.setIslandOffset(offset)
        bar.alignRightSelected = offset === 0
        bar.ensureExpansionFits()
        refreshInputRegion()
        console.log("SmartBar retorno fullscreen: ultima posicion visible",
                    "offset=", offset, "(sin guardar perfiles)")
    }
    // Solo diagnostico del ENSAYO: cambios observables de tareas,
    // sin titulos ni texto de ventanas y sin consultas a APIs privadas.
    property string lastKdeStateSignature: ""
    function reportKdeState(reason, force) {
        const rows = snapshotRealWindows()
        const saved = SoledadPositionProfiles.readProfiles(positionProfilesJson)
        const visible = rows.filter(function(row) {
            return row.active || row.maximized || row.fullscreen ||
                Object.prototype.hasOwnProperty.call(saved, row.appId)
        }).map(function(row) {
            return {
                appId: row.appId || "(sin ID)",
                active: row.active === true,
                maximized: row.maximized === true,
                minimized: row.minimized === true,
                fullscreen: row.fullscreen === true,
                stackingOrder: row.stackingOrder,
                hasProfile: Object.prototype.hasOwnProperty.call(saved, row.appId)
            }
        })
        visible.sort(function(a, b) {
            return a.appId < b.appId ? -1 : (a.appId > b.appId ? 1 : 0)
        })
        const signature = JSON.stringify(visible)
        if (force !== true && signature === lastKdeStateSignature) return
        lastKdeStateSignature = signature
        console.log("SmartBar ESTADO KDE:", reason,
                    "ventanas=" + rows.length,
                    "estados=" + signature,
                    "seguimiento=" + (trackedAppId || "(ninguno)"),
                    "appPreviaFullscreen=" + (fullscreenPriorAppId || "(ninguno)"),
                    "posicionAntesFullscreen=" + fullscreenSavedIslandOffset,
                    "restauracionActiva=" + fullscreenAnchorHeld,
                    "SoledadOffset=" + bar.islandOffset)
    }

    // Temporizador SOLO DE DIAGNOSTICO: observa cada segundo los estados
    // en los 90s del ensayo; no mueve isla, no escribe preferencias,
    // no modifica ventanas ni se incorpora al plasmoide o visor.
    Timer {
        id: diagnosticWatch
        interval: 1000
        repeat: true
        running: true
        onTriggered: probe.reportKdeState("auditoria sin clic", false)
    }
    // Durante arranque y cambios de fullscreen KWin puede actualizar sus
    // roles después de crear/eliminar las ventanas. Releer unos segundos,
    // sin controlar ventanas ni usar polling permanente.
    property int remainingStateRechecks: 0
    function scheduleWindowRecheck(reason) {
        Qt.callLater(probe.refreshExternalWindow)
        if (typeof reason === "string" && reason.length > 0)
            Qt.callLater(function() {
                probe.reportKdeState("senal " + reason, true)
            })
        remainingStateRechecks = 12
        stateRecheckTimer.restart()
    }

    Timer {
        id: stateRecheckTimer
        interval: 250
        repeat: true
        running: false
        onTriggered: {
            probe.refreshExternalWindow()
            probe.recoverProfileAfterSettling()
            probe.restoreLastFullscreenPosition()
            probe.remainingStateRechecks--
            if (probe.remainingStateRechecks <= 0) stop()
        }
    }

    // Si la aplicación activa ya se conoce y tiene perfil, aplicar de
    // nuevo SOLO mientras se estabiliza KWin, si SO quedó en cero (derecha).
    // Nunca reemplazar un arrastre manual que dejó otro desplazamiento.
    function recoverProfileAfterSettling() {
        if (fullscreenAnchorHeld || !trackedKnown || !trackedMaximized ||
                trackedFullscreen || bar.draggingIslandGrip ||
                bar.islandOffset !== 0 || !bar.activeRealAppHasSavedPosition)
            return
        const rows = snapshotRealWindows()
        const top = RealActiveWindow.topmostMaximizedProfile(
            rows, allPositionProfiles(rows))
        if (top.kind !== "profile" || top.appId !== trackedAppId) return
        console.log("SmartBar sincronizacion:", trackedAppName,
                    "recuperando perfil tras evento KDE")
        bar.applyRealPositionProfile()
    }

    function snapshotRealWindows() {
        const rows = []
        for (let i = 0; i < kdeWindowObservers.count; ++i) {
            const item = kdeWindowObservers.itemAt(i)
            if (item !== null) rows.push(item.snapshot())
        }
        return rows
    }

    TaskManager.TasksModel {
        id: kdeWindows
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: probe.scheduleWindowRecheck("cantidad ventanas")
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
        onItemAdded: probe.scheduleWindowRecheck("ventana agregada")
        onItemRemoved: probe.scheduleWindowRecheck("ventana retirada")
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
            // Rol oficial de KDE: -1 cuando el orden Wayland es desconocido.
            readonly property var taskStackingOrder: model.StackingOrder
            function snapshot() {
                return { appId: appId, appName: appName,
                    active: taskActive, maximized: taskMaximized,
                    minimized: taskMinimized, fullscreen: taskFullScreen,
                    stackingOrder: taskStackingOrder }
            }
            onAppIdChanged: probe.scheduleWindowRecheck()
            onTaskActiveChanged: probe.scheduleWindowRecheck("foco")
            onTaskMaximizedChanged: probe.scheduleWindowRecheck("maximizada")
            onTaskMinimizedChanged: probe.scheduleWindowRecheck("minimizada")
            onTaskFullScreenChanged: probe.scheduleWindowRecheck("fullscreen")
            onTaskStackingOrderChanged: probe.scheduleWindowRecheck("apilamiento")
            Component.onCompleted: probe.scheduleWindowRecheck()
        }
    }

    function refreshExternalWindow() {
        const rows = snapshotRealWindows()
        const active = RealActiveWindow.resolve(rows)
        const anyFullscreen = rows.some(function(row) {
            return row.fullscreen && !row.minimized
        })
        anyVisibleMaximized = rows.some(function(row) {
            return row.maximized === true && row.minimized !== true &&
                   row.fullscreen !== true
        })
        if (anyFullscreen && !fullscreenObserved) {
            // Capturar posición visual previa, no el estado de maximización
            // de un chat u otra ventana secundaria creada por Big Picture.
            fullscreenSavedIslandOffset = lastVisibleIslandKnown
                ? lastVisibleIslandOffset : bar.islandOffset
            fullscreenPriorAppId = trackedAppId
            fullscreenTransitionFocusIds = ({})
            fullscreenFocusSettled = false
            fullscreenFocusTimer.stop()
            fullscreenObserved = true
            fullscreenAnchorHeld = true
            fullscreenExited = false
            console.log("SmartBar fullscreen: ingreso, posicion visual=",
                        fullscreenSavedIslandOffset)
        } else if (!anyFullscreen && fullscreenObserved) {
            fullscreenObserved = false
            fullscreenExited = true
            fullscreenTransitionFocusIds = ({})
            if (fullscreenPriorAppId.length > 0)
                fullscreenTransitionFocusIds[fullscreenPriorAppId] = true
            if (active.known)
                fullscreenTransitionFocusIds[active.appId] = true
            fullscreenFocusSettled = false
            fullscreenFocusTimer.restart()
            console.log("SmartBar fullscreen: salida, restaurando posicion visual=",
                        fullscreenSavedIslandOffset)
            Qt.callLater(probe.restoreLastFullscreenPosition)
        }
        // La memoria visual de salida fullscreen NO puede bloquear una
        // aplicación DIFERENTE, explícitamente activa y maximizada: el
        // perfil de Brave prevalece aunque Steam continúe maximizado atrás
        // y aunque el cambio suceda durante los 1,8 s de estabilización.
        // Un chat NO maximizado no anula la posición recuperada de Steam.
        if (fullscreenAnchorHeld && fullscreenExited && active.known &&
                active.maximized && !active.fullscreen &&
                active.appId !== fullscreenPriorAppId) {
            fullscreenAnchorHeld = false
            fullscreenExited = false
            fullscreenFocusTimer.stop()
            fullscreenTransitionFocusIds = ({})
            console.log("SmartBar fullscreen: nueva aplicacion maximizada",
                        active.appId, "retomando perfiles normales")
        } else if (fullscreenAnchorHeld && fullscreenExited && active.known) {
            // Durante los primeros eventos de cierre de fullscreen pueden
            // reaparecer ventanas auxiliares sin maximizar. No asumir que
            // pertenecen a otra app ni crear perfiles para ellas.
            if (!fullscreenFocusSettled) {
                fullscreenTransitionFocusIds[active.appId] = true
            } else if (!fullscreenTransitionFocusIds[active.appId]) {
                fullscreenAnchorHeld = false
                fullscreenExited = false
                console.log("SmartBar fullscreen: nuevo foco de aplicacion",
                            active.appId)
            }
        }
        const previousId = trackedAppId
        const previousMaximized = trackedMaximized
        const previousFullscreen = trackedFullscreen
        const previousKnown = trackedKnown
        const previousHeldNormalFocusId = heldNormalFocusAppId
        const previousTopSignature = lastTopMaximizedSignature
        const topmost = RealActiveWindow.topmostMaximizedProfile(
            rows, allPositionProfiles(rows))
        const topSignature = topmost.kind + ":" + topmost.appId +
                             ":" + topmost.offset
        lastTopMaximizedSignature = topSignature
        // Primer arranque y observación tardía de TasksModel: una única
        // ventana maximizada y perfil guardado puede sembrar el anclaje,
        // aun si la aplicación activa es Konsole o Steam restaurada.
        const initialAnchorRestored = !anyFullscreen && !active.maximized &&
            recoverInitialMaximizedAnchor(rows)
        const activeExternal = active.known &&
            active.appId !== "org.qt-project.qml6" &&
            active.appId !== "smartbar_input_mask_probe"
        // Excepción aprobada exclusivamente en la transición maximizada
        // → restaurada de la MISMA aplicación activa. No cambia la
        // retención anterior por un cambio de foco entre aplicaciones.
        const unmaximizeFallback = activeExternal && !anyFullscreen &&
            !fullscreenAnchorHeld
            ? RealActiveWindow.fallbackAfterActiveUnmaximize(
                rows, active, previousId, previousMaximized,
                allPositionProfiles(rows))
            : {kind: "normal", appId: "", offset: 0}

        if (activeExternal) {
            // El CAMBIO de foco hacia una ventana normal no es una orden
            // de desmaximizar Brave/Steam. Si otra sigue maximizada detrás,
            // conservar la coordenada visible hasta un cambio relevante.
            const holdNormalFocus = !fullscreenAnchorHeld && !anyFullscreen &&
                RealActiveWindow.shouldKeepNormalFocusPosition(
                    rows, active, previousId, previousHeldNormalFocusId)
            heldNormalFocusAppId = (holdNormalFocus || initialAnchorRestored ||
                                    unmaximizeFallback.kind !== "normal")
                ? active.appId : ""
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
            previousKnown !== trackedKnown ||
            previousHeldNormalFocusId !== heldNormalFocusAppId ||
            previousTopSignature !== topSignature
        if (changed) {
            positionTransitionRevision++
            const eventRevision = positionTransitionRevision
            const eventAppId = trackedAppId
            const eventTopSignature = topSignature
            console.log("SmartBar perfil real:", trackedAppName || "(sin aplicación)",
                        "AppId:", trackedAppId || "(ninguno)",
                        "maximizada:", trackedMaximized,
                        "fullscreen:", trackedFullscreen,
                        "ventana identificada:", trackedKnown)
            logPositionStorage("cambio de ventana/estado")
            Qt.callLater(function() {
                if (probe.positionTransitionRevision !== eventRevision ||
                        probe.trackedAppId !== eventAppId) return
                if (!probe.fullscreenAnchorHeld) {
                    // Prioridad de diseño confirmada: seguir la ventana
                    // MAXIMIZADA más alta de KWin, no el foco de una ventana
                    // restaurada ni una maximizada arbitraria del fondo.
                    // Revalidar tras Qt.callLater para descartar eventos viejos.
                    const currentRows = probe.snapshotRealWindows()
                    const currentTop = RealActiveWindow.topmostMaximizedProfile(
                        currentRows, probe.allPositionProfiles(currentRows))
                    const currentSignature = currentTop.kind + ":" +
                        currentTop.appId + ":" + currentTop.offset
                    if (currentSignature !== eventTopSignature) {
                        probe.scheduleWindowRecheck("apilamiento cambiado")
                        return
                    }
                    if (currentTop.kind === "profile") {
                        if (bar.draggingIslandGrip) return
                        const offset = Math.min(bar.maxIslandOffset,
                                                Math.max(0, currentTop.offset))
                        if (Math.abs(bar.islandOffset - offset) >= 0.1) {
                            bar.setIslandOffset(offset)
                            bar.alignRightSelected = offset === 0
                            bar.ensureExpansionFits()
                            probe.refreshInputRegion()
                        }
                        probe.lastVisibleIslandOffset = bar.islandOffset
                        probe.lastVisibleIslandKnown = true
                        console.log("SmartBar maximizada superior:",
                                    currentTop.appId, "offset=", bar.islandOffset,
                                    "(perfil existente, sin guardar)")
                        return
                    }
                    if (currentTop.kind === "hold") {
                        // Con alguna maximizada en pantalla pero sin orden
                        // inequívoco, conservar posición sin inventar ganador.
                        console.log("SmartBar apilamiento ambiguo:",
                                    "conservando offset=", bar.islandOffset)
                        return
                    }
                    if (currentTop.kind === "none") {
                        // No hay ninguna ventana maximizada. La preferencia
                        // de retorno tiene prioridad por encima del anclaje
                        // general y de TODAS las excepciones guardadas.
                        if (bar.autoReturnRight && !bar.draggingIslandGrip) {
                            bar.setIslandOffset(0)
                            bar.alignRightSelected = true
                            bar.ensureExpansionFits()
                            probe.refreshInputRegion()
                            probe.lastVisibleIslandOffset = 0
                            probe.lastVisibleIslandKnown = true
                            probe.heldNormalFocusAppId = ""
                            console.log("SmartBar escritorio normal: retorno a la derecha")
                        }
                        return
                    }
                    if (probe.heldNormalFocusAppId.length > 0 &&
                            probe.heldNormalFocusAppId === probe.trackedAppId &&
                            !probe.trackedMaximized) {
                        // No aplicar offset=0 por un simple cambio de foco;
                        // respetar la coordenada anterior, sin guardar nada.
                        console.log("SmartBar foco restaurado: conserva posicion",
                                    probe.trackedAppId, "offset=", bar.islandOffset)
                    } else if (probe.trackedKnown) bar.applyRealPositionProfile()
                    else if (!bar.draggingIslandGrip) {
                        bar.setIslandOffset(probe.generalOffset)
                        bar.alignRightSelected = bar.islandOffset === 0
                        probe.refreshInputRegion()
                    }
                } else {
                    probe.restoreLastFullscreenPosition()
                }
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
        realAppLaunchEnabled: smartbarContinuousMode
        onRequestLaunchDesktopEntry: function(desktopId) {
            if (soledadInputMask.launchDesktopEntry(desktopId))
                console.log("SmartBar SO: aplicación KDE iniciada por ID", desktopId)
            else
                console.warn("SmartBar SO: no se pudo iniciar ID", desktopId)
        }
        realTrackedAppId: probe.trackedAppId
        realTrackedAppName: probe.trackedAppName
        realTrackedMaximized: probe.trackedMaximized
        realTrackedFullscreen: probe.trackedFullscreen
        realTrackedKnown: probe.trackedKnown
        realAnyVisibleMaximized: probe.anyVisibleMaximized
        realPositionProfilesJson: probe.positionProfilesJson
        generalSoledadOffset: probe.generalOffset
        onRequestGeneralSoledadOffsetChange: function(offset) {
            probe.generalOffset = SoledadPositionProfiles.clampOffset(offset, bar.maxIslandOffset)
            profileSettings.setValue("generalSoledadOffsetV1", probe.generalOffset)
            profileSettings.sync()
            console.log("SmartBar: anclaje general guardado", probe.generalOffset)
        }
        onRequestRealPositionProfilesChange: function(json) {
            // Persistencia SOLO por clic explícito sobre menú existente.
            probe.positionProfilesJson = json
            profileSettings.setValue("soledadRealPositionProfilesV1", json)
            profileSettings.sync()
            console.log("SmartBar: posición guardada por aplicación real")
            probe.logPositionStorage("guardado explicito")
        }
        // No inventar ancho de botones de Brave/Steam. El usuario posiciona
        // libremente y fija por aplicación; general: extremo derecho.
        externalWindowControlsReserve: 0
        soLogoMode: "default"
        themeScheduleRuntimeEnabled: false
        // Mantener el DragHandler ORIGINAL: ventana/escena permanecen FIJAS.
        layerShellDragCompensation: false

        onIslandOffsetChanged: {
            probe.refreshInputRegion()
            probe.rememberVisibleIslandOffset()
        }
        onActualIslandWidthChanged: probe.refreshInputRegion()
        onControlsReservationChanged: probe.refreshInputRegion()
        onSoExpandedChanged: probe.refreshInputRegion()
        onTrayExpandedChanged: probe.refreshInputRegion()
    }

    // Límite del ensayo. La aplicación termina con la última ventana.
    Timer {
        interval: 90000
        running: !smartbarContinuousMode
        repeat: false
        onTriggered: {
            console.log("SmartBar región fija: cierre automático, sin cambios")
            probe.close()
        }
    }
    Component.onCompleted: {
        // Sin estado KDE confirmado, iniciar en escritorio normal a derecha;
        // el primer TaskManager estable aplicará la general o específica
        // únicamente si detecta una ventana maximizada.
        bar.setIslandOffset(0)
        refreshInputRegion()
        probe.scheduleWindowRecheck("inicio")
        Qt.callLater(function() { probe.logPositionStorage("inicio del ensayo") })
        console.log(
        "SmartBar: ventana LayerShellQt FIJA, input limitado por QWindow::setMask.",
        "Arrastrar SOLO los seis puntos de la Soledad auténtica;",
        "el espacio invisible fuera de la isla debería dejar usar Brave.",
        "Sin margen fijo por controles de Brave.",
        "Clic derecho en el agarre: Recordar esta posición para [aplicación].",
        "Los perfiles se guardan solo en ESTE ensayo, sin tocar el visor Qt.",
        "Autocierre 90 s / Ctrl+C.")
    }
}
