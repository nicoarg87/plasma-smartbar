import QtQuick
import QtQuick.Controls as QQC2
import "LayerShellDragCompensation.js" as LayerShellDragCompensation

// Agarre Soledad: conserva el DragHandler y su compensación LayerShell/KWin.
QQC2.Button {
    id: grip
    required property var host
    required property var islandTarget
    required property var soButtonTarget
    required property var clockRevealTimerTarget
    property alias dragTarget: gripDrag
    property alias menuTarget: gripMenu
                    // Seis puntos reales, en dos columnas y tres filas;
                    // no dependemos de un glifo de tipografía.
                    implicitWidth: 30
                    implicitHeight: 34
                    hoverEnabled: true
                    focusPolicy: Qt.StrongFocus
                    property bool draggedDuringPress: false
                    // Evitar que la ayuda quede flotando en la posición vieja
                    // cuando el agarre se desplaza o hay un menú abierto.
                    property bool suppressGripTooltip: false
                    onHoveredChanged: {
                        if (hovered && !host.soClockVisible) {
                            clockRevealTimerTarget.restart()
                        } else if (!hovered) {
                            // Si todavía no comenzó, cancelar el hover.
                            // Si ya está mostrando hora/fecha, dejar que
                            // finalice independientemente del puntero.
                            clockRevealTimerTarget.stop()
                        }
                        if (!hovered) suppressGripTooltip = false
                    }
                    onPressed: {
                        // Si había un hover esperando su breve demora,
                        // iniciar la secuencia ANTES de que abrir un popup
                        // o mover la isla haga desaparecer el hover.
                        if (clockRevealTimerTarget.running) {
                            clockRevealTimerTarget.stop()
                            host.showSoClock()
                        }
                        // Presionar, abrir opciones o arrastrar no detiene
                        // el reloj ni resetea su fase de fecha.
                        draggedDuringPress = false
                        suppressGripTooltip = true
                        // Cerrar ANTES de iniciar el arrastre. Si el menú
                        // sigue como ventana separada puede capturar el ratón
                        // o permanecer atrás en su coordenada original.
                        if (gripMenu.visible) gripMenu.close()
                    }
                    // Clic izquierdo BREVE: si las opciones ya estaban
                    // abiertas, cerrarlas sin reabrir. Si estaban cerradas,
                    // no hacer nada: la apertura sigue siendo por derecho.
                    // Si hubo arrastre, no interpretarlo como clic de cierre.
                    onClicked: {
                        if (gripMenu.visible && !draggedDuringPress) {
                            gripMenu.close()
                        }
                    }
                    background: Rectangle {
                        radius: host.gripShape === "square" ? 0 : 8
                        color: Qt.rgba(host.effectiveGripButtonColor.r,
                                       host.effectiveGripButtonColor.g,
                                       host.effectiveGripButtonColor.b,
                                       host.soledadGradientEnabled &&
                                       !host.gripButtonColorOverride
                                           ? 0 : host.effectiveGripButtonOpacity)
                        border.width: 0
                        OutlineStyle {
                            anchors.fill: parent
                            lineStyle: host.outlineConfig.grip.style
                            lineWidth: host.outlineConfig.grip.width
                            lineColor: host.displayOutlineGripColor
                            lineOpacity: host.outlineConfig.grip.opacity
                            topLeft: parent.radius
                            topRight: parent.radius
                            bottomLeft: parent.radius
                            bottomRight: parent.radius
                        }
                    }
                    contentItem: Item {
                        Grid {
                            anchors.centerIn: parent
                            columns: 2
                            rowSpacing: 3
                            columnSpacing: 3
                            Repeater {
                                model: 6
                                delegate: Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: "#eaf7ff"
                                }
                            }
                        }
                    }
                    // El izquierdo solo puede CERRAR opciones ya abiertas.
                    // El derecho alterna abrir/cerrar y no intercepta
                    // el arrastre horizontal del botón izquierdo.
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: host.toggleGripMenu()
                    }
                    Keys.onPressed: function(event) {
                        // Acceso de teclado: tecla Menú o Mayús+F10.
                        if (event.key === Qt.Key_Menu ||
                            (event.key === Qt.Key_F10 &&
                             (event.modifiers & Qt.ShiftModifier))) {
                            host.toggleGripMenu()
                            event.accepted = true
                        }
                    }
                    QQC2.ToolTip.visible: false
                    QQC2.ToolTip.delay: 850
                    QQC2.ToolTip.text: host.launcherIslandVisible
                        ? "Izquierdo: arrastrar o cerrar menú · Derecho: opciones"
                        : "Izquierdo: arrastrar o cerrar menú · Derecho: opciones"

                    // target=null: el gesto modifica el margen, nunca la
                    // geometría vertical ni el panel real de KDE.
                    DragHandler {
                        id: gripDrag
                        target: null
                        // Reservar el botón derecho a las opciones.
                        acceptedButtons: Qt.LeftButton
                        xAxis.enabled: true
                        yAxis.enabled: false
                        cursorShape: Qt.SizeHorCursor
                        onActiveChanged: {
                            if (!active) return
                            // Centro visible de SO, antes de cerrar los cajones.
                            const visualSoX = soButtonTarget.mapToItem(host, soButtonTarget.width / 2, 0).x
                            if (gripMenu.visible) gripMenu.close()
                            if (host.centeredPresentation) {
                                host.manualSoCenterX = visualSoX
                                host.centeredPositionDragged = true
                                host.dragStartSoCenterX = visualSoX
                            } else {
                                host.offsetAtDragStart = host.islandOffset
                                if (host.layerShellDragCompensation) {
                                    // Coordenada del puntero RELATIVA al Window,
                                    // no al Item que cambia de x al mover la isla.
                                    host.layerShellDragSceneStartX =
                                        gripDrag.centroid.scenePosition.x
                                }
                            }
                            host.soExpanded = false
                            host.trayExpanded = false
                            grip.draggedDuringPress = true
                            grip.suppressGripTooltip = true
                        }
                        onActiveTranslationChanged: {
                            if (active && (host.layerShellDragCompensation ||
                                          Math.abs(activeTranslation.x) > 1)) {
                                // El gesto del usuario destilda de inmediato
                                // «Alinear a la derecha» sin tocar el retorno
                                // automático al desmaximizar.
                                host.alignRightSelected = false
                                if (host.centeredPresentation) {
                                    // Mover la referencia del botón SO, sin
                                    // cambiar el anclaje ni el orden de iconos.
                                    const anchorLeft = (6 +
                                        (host.soledadShape === "leftTip" ? 12 : 0)) +
                                        soButtonTarget.x + soButtonTarget.width / 2
                                    // Reservar los extremos REALES de la isla,
                                    // incluida la bandeja a la izquierda y
                                    // las fichas/agarre a la derecha.
                                    const minX = host.leftReserved + anchorLeft
                                    const maxX = host.width - host.rightReserved -
                                        (islandTarget.width - anchorLeft)
                                    if (maxX >= minX) {
                                        host.manualSoCenterX = Math.max(minX,
                                            Math.min(maxX, host.dragStartSoCenterX +
                                                activeTranslation.x))
                                    }
                                } else if (host.layerShellDragCompensation) {
                                    // Mientras LayerShellQt mueve el Window, la
                                    // activeTranslation acumulada toma como
                                    // origen una escena que también se mueve:
                                    // realimentarla causa saltos y bloqueos.
                                    // La desviación respecto de la coordenada
                                    // inicial DEL PUNTERO dentro del Window
                                    // es la corrección relativa estable.
                                    const result =
                                        LayerShellDragCompensation.nextWithEdgeRebase(
                                            host.islandOffset,
                                            host.layerShellDragSceneStartX,
                                            gripDrag.centroid.scenePosition.x,
                                            host.maxIslandOffset)
                                    // No acumular sobre-recorrido en los extremos.
                                    // Dejar que volver en sentido contrario
                                    // responda desde el primer movimiento.
                                    host.layerShellDragSceneStartX =
                                        result.anchorSceneX
                                    host.setIslandOffset(result.offset)
                                } else {
                                    // Modo original sin cambios: ventanas Qt
                                    // estáticas, maqueta y plasmoide.
                                    host.setIslandOffset(
                                        host.offsetAtDragStart - activeTranslation.x)
                                }
                            }
                        }
                    }

                    SoledadPositionEditor {
                        id: soPositionEditor
                        parent: grip
                        x: Math.min(0, grip.width - width)
                        y: grip.height + 10
                        realTasksModel: host.realTaskModel
                        profilesJson: host.realPositionProfilesJson
                        generalOffset: host.generalSoledadOffset
                        currentOffset: host.islandOffset
                        maxOffset: host.maxIslandOffset
                        onPreviewRequested: function(offset) {
                            host.setIslandOffset(offset)
                            host.alignRightSelected = offset === 0
                        }
                        onSaveRequested: function(appId, offset) {
                            host.storeRealPositionFor(appId, offset)
                        }
                        onRemoveRequested: function(appId) {
                            host.forgetRealPositionFor(appId)
                        }
                    }

                    SoledadGripMenu {
                        id: gripMenu
                        host: grip.host
                        gripTarget: grip
                        positionEditor: soPositionEditor
                        clockRevealTimer: clockRevealTimerTarget
                    }
                }
