// Prueba temporal de la Soledad auténtica mediante SmartBarContent.qml.
// No es instalación del plasmoide, ni reemplaza el panel del usuario.
// El Window mide SOLO el rectángulo de la isla: NO hay banda pasante.
// Las esquinas transparentes aún requieren validar región de entrada.
// El agarre ya existente controla bar.islandOffset; el contenedor solicita
// su nueva posición al compositor mediante el margen derecho LayerShellQt.
// No se leen ni guardan preferencias personales en este ensayo.
import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import "package/contents/ui" as SmartBar

Window {
    id: probe
    visible: true
    title: "SmartBar — Soledad AUTÉNTICA, ensayo temporal"
    color: "transparent"
    // La superficie física comprende solo Soledad, no toda la pantalla.
    // Nunca crear un Window ancho de pantalla que bloquee clics ajenos.
    width: Math.max(1, Math.ceil(bar.actualIslandWidth))
    height: 44
    flags: Qt.Window | Qt.FramelessWindowHint
    property int lastReportedOffset: 0

    LayerShell.Window.anchors: LayerShell.Window.AnchorTop |
                               LayerShell.Window.AnchorRight
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.exclusionZone: -1
    LayerShell.Window.keyboardInteractivity:
        LayerShell.Window.KeyboardInteractivityNone
    // La única variable de anclaje es la posición que calcula el
    // DragHandler ORIGINAL del agarre. No mover aplicaciones externas.
    LayerShell.Window.margins: ({
        left: 0, top: 6,
        right: 12 + Math.round(bar.islandOffset), bottom: 0
    })

    SmartBar.SmartBarContent {
        id: bar
        // SmartBarContent calcula geometría en todo el ancho disponible.
        // Se recorta la imagen a systemIsland para que únicamente su isla
        // dibuje y reciba clics dentro del pequeño Window real.
        width: Math.max(760, probe.Screen.width)
        height: probe.height
        // systemIsland.x = root.width - systemIsland.width - islandOffset
        // en modo derecho, con controles ficticios deshabilitados.
        // Compensar esa x dentro del Window, sin crear otra isla/botón.
        x: -(width - actualIslandWidth - islandOffset - controlsReservation)
        y: 0

        positionMode: "right"
        panelHeight: 48
        soledadHeight: 44
        // Malvina queda apagada SOLO en esta instancia, porque la prueba
        // evalúa Soledad; no altera la configuración real del usuario.
        launcherIslandVisible: false
        showBackground: false
        previewMaximized: false
        demoWindowControlsEnabled: false
        // Reutilizar IslandButton, GIF, caja y grip del componente real.
        // Valores temporales predeterminados: ninguna preferencia se escribe.
        soLogoMode: "default"
        themeScheduleRuntimeEnabled: false
        // El visor principal NO activa esto: solo compensa la ventana
        // LayerShellQt que cambia de posición durante el propio gesto.
        layerShellDragCompensation: true

        // Evitar cientos de escrituras de Konsole por segundo: el log
        // continuo durante un arrastre puede introducir pausas visibles.
        onIslandOffsetChanged: {
            if (Math.abs(Math.round(islandOffset) -
                    probe.lastReportedOffset) >= 80) {
                probe.lastReportedOffset = Math.round(islandOffset)
                console.log("SmartBar SO REAL visual: desplazamiento =",
                            probe.lastReportedOffset, "px lógicos")
            }
        }
        onActualIslandWidthChanged: console.log(
            "SmartBar SO REAL visual: ancho de isla =",
            Math.round(actualIslandWidth), "px lógicos")
    }

    Timer {
        running: true
        repeat: false
        interval: 90000
        onTriggered: {
            console.log("SmartBar SO REAL visual: autocierre de prueba")
            probe.close()
        }
    }
    Component.onCompleted: console.log(
        "SmartBar SO REAL visual: MISMO SmartBarContent.qml / IslandButton",
        "Compensación de arrastre en Window móvil: EXPERIMENTAL.",
        "y agarre de seis puntos; isla SÓLIDA, no click-through.",
        "Solo es un ensayo: NO guarda posición ni copia preferencias personales.",
        "No se instaló ni se reemplazó ningún panel KDE.",
        "Mover solo desde el agarre; cierre automático 90s o Ctrl+C.")
}
