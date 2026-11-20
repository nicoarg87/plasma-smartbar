// Ficha de ventana FICTICIA. El botón × solo cambia el modelo local del visor.
// No referencia TaskManager ni solicita cerrar ventanas KDE.
import QtQuick
import QtQuick.Controls as QQC2

Row {
    id: chip
    required property var host
    required property string appName
    spacing: 1

    IslandButton {
        inheritIslandFill: true
        taskDisplayMode: chip.host.effectiveTaskDisplayMode
        taskFrameShape: chip.host.taskFrameShape
        taskFrameColor: chip.host.displayTaskFrameColor
        taskFrameOpacity: chip.host.taskFrameOpacity
        taskFrameWidth: chip.host.taskFrameWidth
        taskActiveGlowEnabled: chip.host.taskActiveGlowEnabled
        taskActiveDoubleBorderEnabled: chip.host.taskActiveDoubleBorderEnabled
        taskActiveBorderColor: chip.host.displayOutlineSoColor
        taskActiveBorderOpacity: chip.host.outlineConfig.soledad.opacity
        taskActiveBorderWidth: chip.host.outlineConfig.soledad.width
        activityEffect: chip.host.soActivityStyle
        activityColor: chip.host.displaySoActivityColor
        activityStroke: chip.host.soActivityStroke
        activityMotionAllowed: chip.host.soActivityMotion
        activityOrbitSpeed: chip.host.soActivityOrbitSpeed
        activityTrailPercent: chip.host.soActivityTrailPercent
        activityTrailStyle: chip.host.soActivityTrailStyle
        activityGlowColor: chip.host.displaySoActivityGlowColor
        activityGlowIntensity: chip.host.soActivityGlowIntensity
        activityGlowSpread: chip.host.soActivityGlowSpread
        activityPulseSpeed: chip.host.soActivityPulseSpeed
        activityPulseDepth: chip.host.soActivityPulseDepth
        activityGlowGradient: chip.host.soActivityGlowGradient
        frameShape: "task"
        taskIconSource: chip.host.demoIconForApp(chip.appName)
        taskIsActive: chip.host.demoHasRunningWindows &&
            chip.host.lastDemoSelection.length > 0 &&
            chip.appName === chip.host.lastDemoSelection
        text: chip.appName
        onClicked: chip.host.selectDemoApp(chip.appName)
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: "Ventana simulada: " + chip.appName
    }

    QQC2.ToolButton {
        visible: chip.host.demoWindowControlsEnabled && !chip.host.usingRealTasks
        text: "×"
        implicitWidth: 22
        implicitHeight: 34
        focusPolicy: Qt.StrongFocus
        Accessible.name: "Cerrar ventana simulada de " + chip.appName
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: "Cerrar solo la ficha simulada de " + chip.appName
        onClicked: chip.host.closeDemoWindow(chip.appName)
    }
}
