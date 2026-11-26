import QtQuick
import QtQuick.Controls as QQC2

// Ficha de tareas reales compartida por presentación derecha y centrada.
// El host conserva modelo, solicitudes a KDE y configuración. No introduce acciones nuevas.
IslandButton {
                        id: realTaskChip
                        required property var host
                        inheritIslandFill: true
                        taskDisplayMode: host.taskDisplayMode
                        taskFrameShape: host.taskFrameShape
                        taskFrameColor: host.displayTaskFrameColor
                        taskFrameOpacity: host.taskFrameOpacity
                        taskFrameWidth: host.taskFrameWidth
                        taskActiveGlowEnabled: host.taskActiveGlowEnabled
                        taskActiveDoubleBorderEnabled: host.taskActiveDoubleBorderEnabled
                        taskActiveBorderColor: host.displayOutlineSoColor
                        taskActiveBorderOpacity: host.outlineConfig.soledad.opacity
                        taskActiveBorderWidth: host.outlineConfig.soledad.width
                        activityEffect: host.soActivityStyle
                        activityColor: host.displaySoActivityColor
                        activityStroke: host.soActivityStroke
                        activityMotionAllowed: host.soActivityMotion
                        activityOrbitSpeed: host.soActivityOrbitSpeed
                        activityTrailPercent: host.soActivityTrailPercent
                        activityTrailStyle: host.soActivityTrailStyle
                        activityGlowColor: host.displaySoActivityGlowColor
                        activityGlowIntensity: host.soActivityGlowIntensity
                        activityGlowSpread: host.soActivityGlowSpread
                        activityPulseSpeed: host.soActivityPulseSpeed
                        activityPulseDepth: host.soActivityPulseDepth
                        activityGlowGradient: host.soActivityGlowGradient
                        frameShape: "task"
                        required property var model
                        taskIsActive: model.IsActive === true &&
                            model.IsMinimized !== true
                        taskIconSource: model.decoration || host.demoIconForApp(appName)
                        readonly property string appName:
                            model.AppName || "(aplicación sin nombre)"
                        readonly property bool isGrouped: model.IsGroupParent === true
                        readonly property int windowCount: Number(model.ChildCount) || 0
                        text: appName + (isGrouped && windowCount > 1
                                        ? " (" + windowCount + ")" : "")
                        // Clic izquierdo: solicitar foco a KDE en sesión nativa
                        // y conservar selección de perfil para el menú existente.
                        readonly property string appId: String(model.AppId || "")
                        required property int index
                        // Un grupo con más de una ventana necesita selector
                        // secundario (pendiente): nunca capturar una al azar.
                        readonly property var taskWindowIds: model.WinIdList || []
                        readonly property string previewUuid:
                            taskWindowIds.length === 1 ? String(taskWindowIds[0]) : ""
                        // El selector configurado se aplica también a tareas REALES.
                        // La X pertenece a la ficha, no al cuerpo de la miniatura.
                        taskTrailingControlWidth: taskCloseVisible ? 30 : 0
                        taskNameExtraWidth: host.taskNameExtraWidth
                        taskCloseVisible: host.realTaskActivationEnabled &&
                            host.taskCloseMode !== "preview" &&
                            taskWindowIds.length > 0
                        onTaskCloseRequested: {
                            host.requestRealTaskClose(
                                Array.from(taskWindowIds, function(uuid) {
                                    return String(uuid)
                                }))
                        }
                        Timer {
                            id: realTaskHoverDelay
                            interval: 420
                            repeat: false
                            onTriggered: {
                                if (!host.realTaskPreviewEnabled || !realTaskChip.hovered ||
                                    host.realTrackedFullscreen ||
                                    host.installedLauncherPopupVisible) return
                                const local = realTaskChip.mapToItem(root, 0, 0).x
                                if (realTaskChip.isGrouped && realTaskChip.taskWindowIds.length > 1) {
                                    host.requestRealTaskGroup(
                                        Array.from(realTaskChip.taskWindowIds, function(id) {
                                            return String(id)
                                        }),
                                        realTaskChip.appName,
                                        local + realTaskChip.width / 2)
                                } else if (host.taskCloseMode !== "chip" &&
                                           realTaskChip.previewUuid.length > 0) {
                                    const maxLeft = Math.max(0, host.width - 246)
                                    host.requestRealTaskPreview(realTaskChip.previewUuid,
                                        realTaskChip.appName,
                                        Math.max(0, Math.min(maxLeft,
                                            local + realTaskChip.width / 2 - 123)))
                                }
                            }
                        }
                        onHoveredChanged: {
                            if (hovered && host.realTaskPreviewEnabled &&
                                (previewUuid.length > 0 ||
                                 (isGrouped && taskWindowIds.length > 1))) {
                                host.requestHideRealTaskGroup()
                                realTaskHoverDelay.restart()
                            } else {
                                realTaskHoverDelay.stop()
                                if (previewUuid.length > 0)
                                    host.requestHideRealTaskPreview(previewUuid)
                                if (isGrouped && taskWindowIds.length > 1)
                                    host.requestHideRealTaskGroup()
                            }
                        }
                        onClicked: {
                            // Un grupo se previsualiza al posar el puntero.
                            // El clic nunca elige una de sus ventanas arbitrariamente.
                            if (isGrouped && taskWindowIds.length > 1) return
                            realTaskHoverDelay.stop()
                            if (previewUuid.length > 0)
                                host.requestHideRealTaskPreview(previewUuid)
                            host.requestHideRealTaskGroup()
                            host.activateRealTask(index, appId, appName, model.IsActive === true && model.IsMinimized !== true, previewUuid)
                        }
                        // No mostrar etiquetas flotantes encima de las miniaturas.
                        QQC2.ToolTip.visible: false
                        QQC2.ToolTip.text: "Ventana real de KDE: " + appName
                            + (model.IsActive === true ? " · activa" : "")
                            + (model.IsMaximized === true ? " · maximizada" : "")
                            + (isGrouped ? " · grupo de ventanas" : "")
                            + (host.realTaskActivationEnabled
                               ? " · clic para activar ventana" : " · SOLO LECTURA")
                    }
