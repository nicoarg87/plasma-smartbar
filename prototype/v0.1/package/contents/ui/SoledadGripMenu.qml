import QtQuick
import QtQuick.Controls as QQC2
import "DemoWindowInstances.js" as DemoWindowInstances

// Menú del agarre: conserva opciones, acciones y ventana flotante originales.
QQC2.Menu {
    id: menu
    required property var host
    required property var gripTarget
    required property var positionEditor
    required property var clockRevealTimer
                        title: "Opciones de Soledad"
                        // No apagar el reloj al abrir el menú contextual.
                        // Un clic derecho rápido puede abrirlo antes de que
                        // venza el retraso inicial de 180 ms.
                        onOpened: {
                            if (clockRevealTimer.running) {
                                clockRevealTimer.stop()
                                host.showSoClock()
                            }
                        }
                        // Anclar el menú directamente al agarre que lo abrió,
                        // NO al contenedor raíz: el cálculo anterior con su ancho - width
                        // podía desplazarlo hasta Malvina (extremo izquierdo).
                        // En Qt, x/y son relativos al parent del Popup.
                        parent: gripTarget
                        // Qt 6.8+: ventana flotante para no recortar el menú
                        // al superar la altura de la ventana de ensayo.
                        popupType: QQC2.Popup.Window
                        // Si cambia la posición horizontal por arrastre, el
                        // Popup de ventana se cierra antes de mover Soledad.
                        // No queda desacoplado en su ubicación anterior.
                        // El borde derecho del menú coincide con el agarre,
                        // por lo que aparece cerca del puntero incluso cuando
                        // Soledad se arrastra. Ancho explícito: no depender de
                        // la medida inicial del popup al abrirse.
                        width: 380
                        x: gripTarget.width - width
                        // El botón está centrado verticalmente en la isla;
                        // sumar su alto y un margen deja el menú DEBAJO.
                        y: gripTarget.height + 10
                        // Sin cierre previo al presionar el mismo botón:
                        // el segundo clic derecho debe cerrar, no reabrir.
                        closePolicy: QQC2.Popup.CloseOnEscape
                            | QQC2.Popup.CloseOnPressOutsideParent
                        // La visibilidad de Malvina se administra únicamente
                        // desde Configuración, sin acciones duplicadas aquí.
                        QQC2.MenuItem {
                            text: "Configuración de Soledad…"
                            // Logo, colores, contorno, autocontracción,
                            // islas y posición comparten ventana con pestañas.
                            onTriggered: host.openSoledadSettings(0)
                        }
                        // Acceso contextual al tema siguiente del pack activo,
                        // aplicando también su apariencia SO/islas y su fondo.
                        // Reemplaza el atajo anterior que solo previsualizaba.
                        QQC2.MenuItem {
                            visible: host.themeScheduleRuntimeEnabled ||
                                     host.runtimeAppearanceEnabled
                            text: "Pasar al tema siguiente"
                            enabled: host.themeScheduleRuntimeEnabled ||
                                     host.runtimeThemeSwitchAvailable
                            onTriggered: host.passToNextPackTheme()
                        }
                        QQC2.MenuItem {
                            text: "Autocontraer cajón SO al elegir ventana"
                            checkable: true
                            checked: host.autoCollapseSO
                            onTriggered: {
                                console.log("SmartBar SO casilla cajón: solicitar",
                                            !host.autoCollapseSO)
                                host.requestAutoCollapseSOChange(!host.autoCollapseSO)
                            }
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            enabled: !host.usingRealTasks
                            text: host.usingRealTasks
                                ? "SO conectado a tareas reales (solo lectura)"
                                : (host.demoHasRunningWindows
                                   ? "Simular SO SIN ventanas (0)"
                                   : "Simular SO CON ventanas (3)")
                            onTriggered: {
                                if (host.demoHasRunningWindows) {
                                    host.demoHasRunningWindows = false
                                } else {
                                    host.demoClosedHistory = []
                                    host.demoMutedApps = ({})
                                    host.demoWindowInstances = DemoWindowInstances.initial()
                                     host.demoOpenedApps = host.demoApps.slice()
                                    host.demoHasRunningWindows = true
                                }
                            }
                        }
                        QQC2.MenuItem {
                            visible: !host.usingRealTasks && host.demoHasRunningWindows
                            text: "Simular escritorio vacío (fichas sin resaltar)"
                            onTriggered: host.lastDemoSelection = ""
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            text: "Simular ventana maximizada"
                            visible: !host.usingRealTasks
                            checkable: true
                            checked: host.previewMaximized
                            onTriggered: host.setPreviewMaximized(!host.previewMaximized)
                        }
                        QQC2.MenuItem {
                            text: "Simular pantalla completa (bloquea Malvina)"
                            visible: !host.usingRealTasks
                            checkable: true
                            checked: host.previewFullscreen
                            onTriggered: host.previewFullscreen = !host.previewFullscreen
                        }
                        // Un único control por aplicación: su etiqueta y su
                        // acción dependen exclusivamente del perfil guardado.
                        // No cambiar la lógica de almacenamiento ni posiciones.
                        QQC2.MenuItem {
                            visible: host.demoProfileContextReady
                            text: host.demoProfileExists
                                ? "Olvidar posición de " + host.lastDemoSelection
                                : "Fijar esta posición para " + host.lastDemoSelection
                            onTriggered: {
                                if (host.demoProfileExists)
                                    host.deleteDemoPositionProfile()
                                else
                                    host.saveDemoPositionProfile()
                            }
                        }
                        QQC2.MenuItem {
                            visible: host.demoWindowControlsEnabled &&
                                     host.usingRealTasks &&
                                     host.positionMode === "right" &&
                                     host.realProfileTarget.appName.length > 0
                            enabled: host.realProfileContextReady
                            text: !host.realProfileContextReady
                                ? host.realProfileTarget.appName + ": KDE no informa su ID"
                                : host.realProfileExists
                                    ? "Olvidar posición de " + host.realProfileTarget.appName
                                    : "Fijar esta posición para " + host.realProfileTarget.appName
                            onTriggered: {
                                if (host.realProfileExists)
                                    host.deleteRealPositionProfile()
                                else
                                    host.saveRealPositionProfile()
                            }
                        }
                        QQC2.MenuSeparator {}
                        QQC2.MenuItem {
                            visible: host.usingRealTasks
                            enabled: host.positionMode === "right"
                            text: "Fijar esta posición para todas las aplicaciones"
                            onTriggered: host.saveGeneralSoledadPosition()
                        }
                        QQC2.MenuItem {
                            visible: host.usingRealTasks
                            text: "Personalizar posición por aplicación…"
                            onTriggered: {
                                positionEditor.openFor(host.realTrackedAppId,
                                                         host.realTrackedAppName)
                            }
                        }
                        // Atajo contextual del agarre: respeta la preferencia
                        // elegida en Islas y posición, sin cambiar de modo.
                        QQC2.MenuItem {
                            // MISMA acción existente, con etiqueta contextual:
                            // no prometer «derecha» si hay perfil de Brave/Steam.
                            text: host.positionMode === "center"
                                ? "Centrar isla 1 ahora"
                                : (host.activeRealAppHasSavedPosition
                                    ? "Volver a posición de " + host.realTrackedAppName
                                    : "Alinear isla 1 a la derecha ahora")
                            onTriggered: host.returnToConfiguredPosition()
                        }
                        QQC2.MenuItem {
                            visible: host.positionMode === "right"
                            text: "Volver a la derecha al desmaximizar"
                            checkable: true
                            checked: host.autoReturnRight
                            onTriggered: host.setAutoReturnRight(
                                !host.autoReturnRight)
                        }

                    }
