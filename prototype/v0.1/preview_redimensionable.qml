// Ventana independiente para validar el redimensionado con el MISMO
// SmartBarContent que usa el plasmoide. No instala nada ni toca paneles.
import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
import org.kde.taskmanager 0.1 as TaskManager
import "package/contents/ui"

Window {
    id: previewWindow
    width: 1000
    height: 320
    minimumWidth: 760
    minimumHeight: 210
    visible: true
    title: "Plasma SmartBar Islands v0.1 — prueba redimensionable (sin panel)"
    color: "#242236"

    // Solo este visor Qt utiliza la opción real. El plasmoide sigue
    // sin conexión a ventanas y el panel instalado no se modifica.
    property bool useRealWindowTasks: false

    // Misma configuración ya validada por el mantenedor en el
    // diagnóstico preview_ventanas_reales.qml.
    TaskManager.TasksModel {
        id: kdeTasks
        groupMode: TaskManager.TasksModel.GroupApplications
        sortMode: TaskManager.TasksModel.SortAlpha
        launcherList: []
        filterByVirtualDesktop: false
        filterByActivity: false
        filterByScreen: false
        onCountChanged: {
            if (previewWindow.useRealWindowTasks)
                console.log("SmartBar SO: grupos reales visibles =", count)
        }
    }

    property bool demoAutoReturnRight: true
    property bool demoLauncherIslandVisible: true
    property bool demoAutoHideMalvina: true
    property bool demoAutoCollapseSO: true
    property bool demoAutoCollapseTray: false
    // Estados de sesión de la maqueta (el panel KDE no se instala).
    property string demoSoLogoMode: "default"
    property string demoSoLogoPath: ""
    property string demoSoLogoShape: "square"
    property string demoSoLogoFitMode: "stretch"
    property real demoSoLogoZoom: 1
    property real demoSoLogoPanX: 0
    property real demoSoLogoPanY: 0
    property real demoSoLogoRotation: 0
    property bool demoSoLogoAnimate: true
    property string demoSoClockFontFamily: "Sans Serif"
    property int demoSoClockFontSize: 11
    property color demoSoClockTextColor: "#ffffff"
    property real demoPanelHeight: 48
    property real demoSoledadHeight: 44
    property real demoMalvinaHeight: 44
    property real demoSoledadRadius: 22
    property real demoMalvinaRadius: 22
    property real demoSoledadMinWidth: 0
    property real demoMalvinaWidth: 52
    property string demoSoledadShape: "leftRoundRightSquare"
    property string demoMalvinaShape: "rounded"
    property string demoGripShape: "rounded"
    property string demoTrayButtonShape: "rounded"
    property string demoSoButtonFrameShape: "capsule"
    property real demoSoButtonWidth: 96
    property color demoSoledadColor: "#010111"
    property color demoMalvinaColor: "#101e31"
    property color demoBackgroundColor: "#202333"
    property real demoSoledadOpacity: 0.5
    property real demoMalvinaOpacity: 1
    property real demoBackgroundOpacity: 0.5
    property bool demoShowBackground: false
    property bool demoTrayButtonColorOverride: false
    property color demoTrayButtonColor: "#010111"
    property real demoTrayButtonOpacity: 0.5
    property bool demoGripButtonColorOverride: false
    property color demoGripButtonColor: "#010111"
    property real demoGripButtonOpacity: 0.5
    property string demoSoActivityStyle: "orbit"
    property color demoSoActivityColor: "#35d7ff"
    property real demoSoActivityStroke: 0.75
    property bool demoSoActivityMotion: true
    property real demoSoActivityOrbitSpeed: 1.5
    property int demoSoActivityTrailPercent: 75
    property string demoSoActivityTrailStyle: "dashed"
    property bool demoSoActivityShowWhenEmpty: true
    property bool demoSoActivityShowWhenOpen: false

    SmartBarContent {
        id: bar
        realTaskModel: previewWindow.useRealWindowTasks ? kdeTasks : null
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: fixedHeight
        panelHeight: previewWindow.demoPanelHeight
        soledadHeight: previewWindow.demoSoledadHeight
        malvinaHeight: previewWindow.demoMalvinaHeight
        soledadRadius: previewWindow.demoSoledadRadius
        malvinaRadius: previewWindow.demoMalvinaRadius
        soledadMinWidth: previewWindow.demoSoledadMinWidth
        malvinaWidth: previewWindow.demoMalvinaWidth
        soledadShape: previewWindow.demoSoledadShape
        malvinaShape: previewWindow.demoMalvinaShape
        gripShape: previewWindow.demoGripShape
        trayButtonShape: previewWindow.demoTrayButtonShape
        soButtonFrameShape: previewWindow.demoSoButtonFrameShape
        soButtonWidth: previewWindow.demoSoButtonWidth

        autoReturnRight: previewWindow.demoAutoReturnRight
        launcherIslandVisible: previewWindow.demoLauncherIslandVisible
        autoHideMalvina: previewWindow.demoAutoHideMalvina
        // El visor es la propia superficie de ensayo: maximizar ESTA
        // ventana no equivale a tener un juego ajeno maximizado debajo.
        // Para probar protección, usar las opciones explícitas del agarre.
        // En pantalla completa REAL del visor se conserva el bloqueo.
        windowStateKnown: true
        hostMaximized: false
        hostFullscreen: previewWindow.visibility === Window.FullScreen
        autoCollapseSO: previewWindow.demoAutoCollapseSO
        autoCollapseTray: previewWindow.demoAutoCollapseTray
        soLogoMode: previewWindow.demoSoLogoMode
        soLogoPath: previewWindow.demoSoLogoPath
        soLogoShape: previewWindow.demoSoLogoShape
        soLogoFitMode: previewWindow.demoSoLogoFitMode
        soLogoZoom: previewWindow.demoSoLogoZoom
        soLogoPanX: previewWindow.demoSoLogoPanX
        soLogoPanY: previewWindow.demoSoLogoPanY
        soLogoRotation: previewWindow.demoSoLogoRotation
        soLogoAnimate: previewWindow.demoSoLogoAnimate
        soClockFontFamily: previewWindow.demoSoClockFontFamily
        soClockFontSize: previewWindow.demoSoClockFontSize
        soClockTextColor: previewWindow.demoSoClockTextColor
        onRequestSoClockAppearanceChange: function(family, size, color) {
            previewWindow.demoSoClockFontFamily = family
            previewWindow.demoSoClockFontSize = size
            previewWindow.demoSoClockTextColor = color
        }
        soledadColor: previewWindow.demoSoledadColor
        malvinaColor: previewWindow.demoMalvinaColor
        backgroundColor: previewWindow.demoBackgroundColor
        soledadOpacity: previewWindow.demoSoledadOpacity
        malvinaOpacity: previewWindow.demoMalvinaOpacity
        backgroundOpacity: previewWindow.demoBackgroundOpacity
        showBackground: previewWindow.demoShowBackground
        trayButtonColorOverride: previewWindow.demoTrayButtonColorOverride
        trayButtonColor: previewWindow.demoTrayButtonColor
        trayButtonOpacity: previewWindow.demoTrayButtonOpacity
        gripButtonColorOverride: previewWindow.demoGripButtonColorOverride
        gripButtonColor: previewWindow.demoGripButtonColor
        gripButtonOpacity: previewWindow.demoGripButtonOpacity
        soActivityStyle: previewWindow.demoSoActivityStyle
        soActivityColor: previewWindow.demoSoActivityColor
        soActivityStroke: previewWindow.demoSoActivityStroke
        soActivityMotion: previewWindow.demoSoActivityMotion
        soActivityOrbitSpeed: previewWindow.demoSoActivityOrbitSpeed
        soActivityTrailPercent: previewWindow.demoSoActivityTrailPercent
        soActivityTrailStyle: previewWindow.demoSoActivityTrailStyle
        soActivityShowWhenEmpty: previewWindow.demoSoActivityShowWhenEmpty
        soActivityShowWhenOpen: previewWindow.demoSoActivityShowWhenOpen
        onRequestAutoHideMalvinaChange: function(newValue) {
            previewWindow.demoAutoHideMalvina = newValue
        }
        onRequestSoActivityChange: function(style, color, stroke, allowMotion,
                                             speed, tailLength, lineStyle,
                                             showWhenEmpty, showWhenOpen) {
            previewWindow.demoSoActivityStyle = style
            previewWindow.demoSoActivityColor = color
            previewWindow.demoSoActivityStroke = stroke
            previewWindow.demoSoActivityMotion = allowMotion
            previewWindow.demoSoActivityOrbitSpeed = speed
            previewWindow.demoSoActivityTrailPercent = tailLength
            previewWindow.demoSoActivityTrailStyle = lineStyle
            previewWindow.demoSoActivityShowWhenEmpty = showWhenEmpty
            previewWindow.demoSoActivityShowWhenOpen = showWhenOpen
        }
        onRequestSoLogoChange: function(mode, path, shape, fitMode, zoom, panX, panY, allowGif, rotation) {
            previewWindow.demoSoLogoMode = mode
            previewWindow.demoSoLogoPath = path
            previewWindow.demoSoLogoShape = shape
            previewWindow.demoSoLogoFitMode = fitMode
            previewWindow.demoSoLogoZoom = zoom
            previewWindow.demoSoLogoPanX = panX
            previewWindow.demoSoLogoPanY = panY
            previewWindow.demoSoLogoAnimate = allowGif
            previewWindow.demoSoLogoRotation = rotation
        }
        onRequestGeometryChange: function(panel, soH, malH, soRadius, malRadius,
                                          soWidth, malWidth, buttonShape, buttonWidth,
                                          soShape, malShape, gripButtonShape, trayShape) {
            previewWindow.demoPanelHeight = panel
            previewWindow.demoSoledadHeight = soH
            previewWindow.demoMalvinaHeight = malH
            previewWindow.demoSoledadRadius = soRadius
            previewWindow.demoMalvinaRadius = malRadius
            previewWindow.demoSoledadMinWidth = soWidth
            previewWindow.demoMalvinaWidth = malWidth
            previewWindow.demoSoButtonFrameShape = buttonShape
            previewWindow.demoSoButtonWidth = buttonWidth
            previewWindow.demoSoledadShape = soShape
            previewWindow.demoMalvinaShape = malShape
            previewWindow.demoGripShape = gripButtonShape
            previewWindow.demoTrayButtonShape = trayShape
        }
        onRequestAppearanceChange: function(a, alphaA, b, alphaB, shown, bg,
                                            alphaBg, trayOverride, trayColor,
                                            trayOpacity, gripOverride,
                                            gripColor, gripOpacity) {
            previewWindow.demoSoledadColor = a
            previewWindow.demoSoledadOpacity = alphaA
            previewWindow.demoMalvinaColor = b
            previewWindow.demoMalvinaOpacity = alphaB
            previewWindow.demoShowBackground = shown
            previewWindow.demoBackgroundColor = bg
            previewWindow.demoBackgroundOpacity = alphaBg
            previewWindow.demoTrayButtonColorOverride = trayOverride
            previewWindow.demoTrayButtonColor = trayColor
            previewWindow.demoTrayButtonOpacity = trayOpacity
            previewWindow.demoGripButtonColorOverride = gripOverride
            previewWindow.demoGripButtonColor = gripColor
            previewWindow.demoGripButtonOpacity = gripOpacity
        }
        onRequestAutoReturnRightChange: function(newValue) {
            previewWindow.demoAutoReturnRight = newValue
        }
        onRequestLauncherIslandVisibilityChange: function(newValue) {
            previewWindow.demoLauncherIslandVisible = newValue
        }
        onRequestAutoCollapseSOChange: function(newValue) {
            previewWindow.demoAutoCollapseSO = newValue
        }
        onRequestAutoCollapseTrayChange: function(newValue) {
            previewWindow.demoAutoCollapseTray = newValue
        }
    }

    QQC2.CheckBox {
        id: realTasksSwitch
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.top: bar.bottom
        anchors.topMargin: 12
        text: "Usar ventanas reales de KDE en SO (solo lectura)"
        checked: previewWindow.useRealWindowTasks
        onToggled: previewWindow.useRealWindowTasks = checked
    }

    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: realTasksSwitch.bottom
        anchors.topMargin: 12
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        wrapMode: Text.WordWrap
        color: "#f4edf9"
        text: previewWindow.useRealWindowTasks
              ? "Modo KDE REAL (solo lectura): SO muestra aplicaciones abiertas. " +
                "No activa, minimiza ni cierra ventanas. Probá abrir/cerrar Dolphin o Konsole; " +
                "la fila de SO se actualiza manteniendo el botón a la derecha."
              : "Modo SIMULADO: conserva todas las pruebas anteriores. Arrastrá " +
                "el borde de la ventana o maximizala; Malvina queda a la izquierda " +
                "y Soledad a la derecha."
    }

    // Diagnóstico visible EXCLUSIVAMENTE en esta ventana de prueba;
    // no es parte de la barra ni del plasmoide final.
    QQC2.Label {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: widthLabel.top
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 8
        color: "#c7bad8"
        font.pixelSize: 11
        wrapMode: Text.WordWrap
        text: (previewWindow.useRealWindowTasks
                ? "Grupos reales KDE (solo lectura): "
                : "Ventanas de muestra: ") + bar.soWindowCount +
              " · efecto SO: " + bar.soActivityStyle +
              " · " + (bar.soExpanded ? "SO abierto" : "SO cerrado") +
              " · " + (bar.trayExpanded ? "bandeja abierta" : "bandeja cerrada") +
              " · Malvina: " + (bar.malvinaActuallyVisible ? "visible" : "oculta") +
              (bar.autoRevealBlocked
                ? " (BLOQUEADA: simulación maximizada/fullscreen)"
                : (!bar.launcherIslandVisible
                   ? " (deshabilitada en opciones)"
                   : (bar.autoHideMalvina
                      ? " (esperando cursor 0,6 s en esquina izquierda)"
                      : " (autoocultamiento desactivado)"))) +
              " · SO autocierre: " + (bar.autoCollapseSO ? "sí" : "no") +
              " · bandeja autocierre: " + (bar.autoCollapseTray ? "sí" : "no") +
              "\nAncho Soledad: " + Math.round(bar.actualIslandWidth) +
              " / espacio disponible: " + Math.round(bar.availableIslandWidth) +
              " px lógicos · prioridad: " + (bar.lastExpandedMode === "so" ? "SO" : "bandeja")
    }

    QQC2.Label {
        id: widthLabel
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.bottomMargin: 12
        color: "#c7bad8"
        text: "Ancho del contenido: " + Math.round(bar.width) + " px lógicos"
    }

    onWidthChanged: console.log("SmartBar ventana independiente: ancho =", width)
}
