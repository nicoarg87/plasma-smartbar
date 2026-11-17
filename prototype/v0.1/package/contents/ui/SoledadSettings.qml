// Centro unificado de configuracion de Soledad (prototipo Qt 6).
// Las pestañas comparten una ventana. Aplicar guarda y NO cierra.
// Cada pestaña tiene desplazamiento vertical para pantallas reducidas.
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs

Window {
    id: settings
    visible: false
    flags: Qt.Dialog
    title: "Configuración de Soledad"
    color: "#242236"

    // Tamaño de referencia: el editor de logo es la pestaña más alta.
    // Si la pantalla es pequeña, las pestañas permiten desplazamiento.
    width: Screen.desktopAvailableWidth > 0
        ? Math.min(750, Math.max(420, Screen.desktopAvailableWidth - 64)) : 750
    height: Screen.desktopAvailableHeight > 0
        ? Math.min(850, Math.max(510, Screen.desktopAvailableHeight - 64)) : 850
    minimumWidth: 420
    minimumHeight: 510

    property alias currentTab: tabs.currentIndex
    property url defaultImage: ""

    // Valores de trabajo. Se copian desde SmartBarContent al abrir.
    property string logoMode: "default"
    property string filePath: ""
    property string shape: "square"
    property string cropFitMode: "stretch"
    property real cropZoom: 1
    property real cropPanX: 0
    property real cropPanY: 0
    property real cropRotation: 0
    property string soButtonFrameShape: "capsule"
    property real soButtonWidth: 96
    property bool enableGif: true
    property string clockFontFamily: "Sans Serif"
    property int clockFontSize: 11
    property color clockTextColor: "#ffffff"
    readonly property url selectedImage: logoMode === "text" ? "" :
        (logoMode === "custom" && filePath.length > 0 ? filePath : defaultImage)
    // El recurso predeterminado es ahora un GIF original. La vista previa
    // debe animarlo, no solo animar GIF cargados desde un archivo propio.
    readonly property bool isGif: logoMode === "default" ||
        (logoMode === "custom" && filePath.toLowerCase().endsWith(".gif"))

    property color soledadColor: "#010111"
    property color malvinaColor: "#101e31"
    property bool soledadGradientEnabled: false
    property color soledadGradientEnd: "#ee9852"
    property string soledadGradientDirection: "topBottom"
    property bool soledadGradientSyncBreathing: false
    property real soledadGradientBreathingIntensity: 0.6
    property bool malvinaGradientEnabled: false
    property color malvinaGradientEnd: "#445577"
    property string malvinaGradientDirection: "topBottom"
    property color backgroundColor: "#202333"
    property real soledadOpacity: 0.5
    property real malvinaOpacity: 1
    property real backgroundOpacity: 0.5
    property bool showBackground: false
    property bool trayButtonColorOverride: false
    property color trayButtonColor: "#010111"
    property real trayButtonOpacity: 0.5
    property bool gripButtonColorOverride: false
    property color gripButtonColor: "#010111"
    property real gripButtonOpacity: 0.5
    readonly property color activeColor:
        appearanceTarget.currentIndex === 0 ? soledadColor :
        appearanceTarget.currentIndex === 1 ? malvinaColor :
        appearanceTarget.currentIndex === 2 ? backgroundColor :
        appearanceTarget.currentIndex === 3
            ? (trayButtonColorOverride ? trayButtonColor : soledadColor)
            : (gripButtonColorOverride ? gripButtonColor : soledadColor)
    readonly property real activeOpacity:
        appearanceTarget.currentIndex === 0 ? soledadOpacity :
        appearanceTarget.currentIndex === 1 ? malvinaOpacity :
        appearanceTarget.currentIndex === 2 ? backgroundOpacity :
        appearanceTarget.currentIndex === 3
            ? (trayButtonColorOverride ? trayButtonOpacity : soledadOpacity)
            : (gripButtonColorOverride ? gripButtonOpacity : soledadOpacity)
    readonly property bool appearanceCanEdit:
        appearanceTarget.currentIndex < 3 ||
        (appearanceTarget.currentIndex === 3 ? trayButtonColorOverride
                                              : gripButtonColorOverride)
    function setAppearanceOverride(enabled) {
        if (appearanceTarget.currentIndex === 3) {
            if (enabled && !trayButtonColorOverride) {
                trayButtonColor = soledadColor
                trayButtonOpacity = soledadOpacity
            }
            trayButtonColorOverride = enabled
        } else if (appearanceTarget.currentIndex === 4) {
            if (enabled && !gripButtonColorOverride) {
                gripButtonColor = soledadColor
                gripButtonOpacity = soledadOpacity
            }
            gripButtonColorOverride = enabled
        }
    }

    property string effectStyle: "orbit"
    property color accentColor: "#35d7ff"
    property real strokeSize: 0.75
    property bool allowMotion: true
    // Valores de contorno provisoriamente elegidos para esta prueba.
    property real orbitSpeed: 1.5 // vueltas por segundo
    property color glowColor: "#ffab52"
    property real glowIntensity: 0.7
    property real glowSpread: 5
    property real pulseSpeed: 0.6
    property real pulseDepth: 0.7
    property bool glowGradient: true
    property int trailPercent: 75 // porcentaje del perímetro
    property string trailStyle: "dashed" // solid, dotted, dashed
    property bool showOutlineWhenEmpty: true
    property bool showOutlineWhenOpen: false
    property bool simulateHasWindows: false
    // Copia de los valores realmente aplicados: nunca seguir ediciones pendientes.
    property var appliedOutlinePreview: ({})
    function refreshOutlinePreview() {
        appliedOutlinePreview = {
            iconSource: selectedImage,
            iconAnimated: isGif,
            iconAnimationEnabled: enableGif,
            iconShape: shape,
            frameShape: soButtonFrameShape,
            frameWidth: soButtonWidth,
            frameHeight: Math.max(30, Math.min(soledadHeight, panelHeight - 4) - 10),
            iconRotation: cropRotation,
            iconFitMode: cropFitMode,
            iconZoom: cropZoom,
            iconPanX: cropPanX,
            iconPanY: cropPanY,
            activityCount: simulateHasWindows ? 3 : 0,
            activityEffect: effectStyle,
            activityColor: accentColor,
            activityStroke: strokeSize,
            activityMotionAllowed: allowMotion,
            activityOrbitSpeed: orbitSpeed,
            activityTrailPercent: trailPercent,
            activityTrailStyle: trailStyle,
            activityGlowColor: glowColor,
            activityGlowIntensity: glowIntensity,
            activityGlowSpread: glowSpread,
            activityPulseSpeed: pulseSpeed,
            activityPulseDepth: pulseDepth,
            activityGlowGradient: glowGradient,
            activityShowWhenEmpty: showOutlineWhenEmpty,
            activityShowWhenOpen: showOutlineWhenOpen
        }
    }
    readonly property bool outlineIsOrbit: effectStyle === "orbit" || effectStyle === "orbitGlow"
    readonly property bool outlineUsesGlow: effectStyle === "glow" || effectStyle === "breathe" || effectStyle === "orbitGlow"
    readonly property bool outlineCanMove: outlineIsOrbit || effectStyle === "breathe"

    property bool autoCollapseSO: true
    property bool autoCollapseTray: false
    property bool autoReturnRight: true
    property bool launcherIslandVisible: true
    property bool autoHideMalvina: true
    property bool alignedRight: true
    property real panelHeight: 48
    property real soledadHeight: 44
    property real malvinaHeight: 44
    property real soledadRadius: 22
    property real malvinaRadius: 22
    property real soledadMinWidth: 0
    property real malvinaWidth: 52
    property string soledadShape: "leftRoundRightSquare"
    property string malvinaShape: "rounded"
    property string gripShape: "rounded"
    property string trayButtonShape: "rounded"
    // No reinterpretar un arrastre posterior como una orden de alineación.
    property bool alignmentEdited: false
    property var outlineConfig: ({"soledad":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"malvina":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"tray":{"style":"solid","width":1,"color":"#45647a","opacity":1},"grip":{"style":"solid","width":1,"color":"#45647a","opacity":1}})
    readonly property string outlineTargetKey: ["soledad","malvina","tray","grip"][outlineTarget.currentIndex]
    readonly property var selectedOutline: outlineConfig[outlineTargetKey]
    function setOutlineField(field, value) {
        const next = JSON.parse(JSON.stringify(outlineConfig))
        next[outlineTargetKey][field] = value
        outlineConfig = next
    }
    signal saveOutlineRequested(var updated)
    signal saveGradientBreathingRequested(bool enabled, real intensity)
    signal saveIslandGradientRequested(bool soEnabled, string soEnd, string soDirection,
                                       bool malEnabled, string malEnd, string malDirection)

    signal saveClockAppearanceRequested(string family, int size,
                                        string textColor)
    signal saveLogoRequested(string mode, string path, string shape,
                             string fitMode, real zoom, real panX,
                             real panY, bool animate, real rotation)
    signal saveGeometryRequested(real panel, real soledadHeight,
                                 real malvinaHeight, real soledadRadius,
                                 real malvinaRadius, real soledadWidth,
                                 real malvinaWidth, string buttonShape,
                                 real buttonWidth, string soShape,
                                 string malShape, string gripButtonShape,
                                 string trayShape)
    signal saveAppearanceRequested(string soColor, real soOpacity,
                                   string malColor, real malOpacity,
                                   bool backgroundShown, string bgColor,
                                   real bgOpacity, bool trayOverride,
                                   string trayColor, real trayOpacity,
                                   bool gripOverride, string gripColor,
                                   real gripOpacity)
    signal saveGlowRequested(string color, real intensity, real spread,
                             real pulseSpeed, real pulseDepth, bool gradient)
    signal saveActivityRequested(string style, string color,
                                 real stroke, bool motion, real speed,
                                 int tailLength, string lineStyle,
                                 bool showWhenEmpty, bool showWhenOpen)
    signal saveAutoHideMalvinaRequested(bool enabled)
    signal saveBehaviorRequested(bool collapseSO, bool collapseTray,
                                 bool returnRight, bool showMalvina,
                                 bool alignRight, bool alignmentEdited)
    signal alignNowRequested()

    function toHex(c) {
        const part = function(v) {
            const h = Math.max(0, Math.min(255, Math.round(v * 255))).toString(16)
            return h.length === 1 ? "0" + h : h
        }
        return "#" + part(c.r) + part(c.g) + part(c.b)
    }
    function chooseOpacity(value) {
        if (appearanceTarget.currentIndex === 0) soledadOpacity = value
        else if (appearanceTarget.currentIndex === 1) malvinaOpacity = value
        else if (appearanceTarget.currentIndex === 2) backgroundOpacity = value
        else if (appearanceTarget.currentIndex === 3 && trayButtonColorOverride)
            trayButtonOpacity = value
        else if (appearanceTarget.currentIndex === 4 && gripButtonColorOverride)
            gripButtonOpacity = value
    }
    function applyChanges() {
        // Ajustar la altura general solo al aplicar cambios de geometría.
        panelHeight = Math.min(120, Math.max(panelHeight, soledadHeight + 4, malvinaHeight + 4))
        soledadHeight = Math.min(soledadHeight, panelHeight - 4)
        malvinaHeight = Math.min(malvinaHeight, panelHeight - 4)
        saveOutlineRequested(JSON.parse(JSON.stringify(outlineConfig)))
        refreshOutlinePreview()
        saveGradientBreathingRequested(soledadGradientSyncBreathing,
                                     soledadGradientBreathingIntensity)
        saveIslandGradientRequested(soledadGradientEnabled, toHex(soledadGradientEnd),
                                   soledadGradientDirection, malvinaGradientEnabled,
                                   toHex(malvinaGradientEnd), malvinaGradientDirection)
        saveClockAppearanceRequested(clockFontFamily, clockFontSize,
                                     toHex(clockTextColor))
        saveLogoRequested(logoMode, filePath, shape, cropFitMode,
                          cropZoom, cropPanX, cropPanY, enableGif, cropRotation)
        saveGeometryRequested(panelHeight,
                               soledadHeight,
                               malvinaHeight,
                              soledadRadius, malvinaRadius, soledadMinWidth,
                              malvinaWidth, soButtonFrameShape, soButtonWidth,
                              soledadShape, malvinaShape, gripShape,
                              trayButtonShape)
        saveAppearanceRequested(toHex(soledadColor), soledadOpacity,
                                toHex(malvinaColor), malvinaOpacity,
                                showBackground, toHex(backgroundColor),
                                backgroundOpacity, trayButtonColorOverride,
                                toHex(trayButtonColor), trayButtonOpacity,
                                gripButtonColorOverride,
                                toHex(gripButtonColor), gripButtonOpacity)
        saveGlowRequested(toHex(glowColor), glowIntensity, glowSpread,
                          pulseSpeed, pulseDepth, glowGradient)
        saveActivityRequested(effectStyle, toHex(accentColor),
                              strokeSize, allowMotion, orbitSpeed,
                              trailPercent, trailStyle,
                              showOutlineWhenEmpty, showOutlineWhenOpen)
        saveAutoHideMalvinaRequested(autoHideMalvina)
        saveBehaviorRequested(autoCollapseSO, autoCollapseTray,
                              autoReturnRight, launcherIslandVisible,
                              alignedRight, alignmentEdited)
        alignmentEdited = false
        appliedLabel.text = "Cambios aplicados. Podés seguir configurando."
        // NO llamar settings.close(): Aplicar no debe cerrar la ventana.
    }

    FileDialog {
        id: chooseImage
        title: "Elegir fotografía, logo o GIF"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.webp *.svg *.gif *.bmp)",
                      "Todos los archivos (*)"]
        onAccepted: {
            settings.filePath = selectedFile.toString()
            settings.logoMode = "custom"
        }
    }
    ColorDialog {
        id: islandColorDialog
        property int editingTarget: 0
        title: "Elegir color y tonalidad"
        onAccepted: {
            if (editingTarget === 0) settings.soledadColor = selectedColor
            else if (editingTarget === 1) settings.malvinaColor = selectedColor
            else if (editingTarget === 2) settings.backgroundColor = selectedColor
            else if (editingTarget === 3 && settings.trayButtonColorOverride)
                settings.trayButtonColor = selectedColor
            else if (editingTarget === 4 && settings.gripButtonColorOverride)
                settings.gripButtonColor = selectedColor
        }
    }
    ColorDialog {
        id: islandGradientEndDialog
        title: "Segundo color del degradado"
        property int target: 0
        onAccepted: {
            if (target === 0) settings.soledadGradientEnd = selectedColor
            else settings.malvinaGradientEnd = selectedColor
        }
    }
    ColorDialog {
        id: glowColorDialog
        title: "Color del brillo exterior SO"
        onAccepted: settings.glowColor = selectedColor
    }
    FontDialog {
        id: clockFontDialog
        title: "Elegir tipografía para la hora y fecha"
        onAccepted: {
            settings.clockFontFamily = selectedFont.family
        }
    }
    ColorDialog {
        id: clockColorDialog
        title: "Color del texto de hora y fecha"
        onAccepted: settings.clockTextColor = selectedColor
    }
    ColorDialog {
        id: islandOutlineColorDialog
        title: "Color del contorno seleccionado"
        onAccepted: settings.setOutlineField("color", settings.toHex(selectedColor))
    }
    ColorDialog {
        id: outlineColorDialog
        title: "Elegir color del contorno"
        onAccepted: settings.accentColor = selectedColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        QQC2.Label {
            text: "Configuración de Soledad y sus islas"
            font.bold: true
            font.pixelSize: 17
            color: "white"
            Layout.fillWidth: true
        }

        QQC2.TabBar {
            id: tabs
            Layout.fillWidth: true
            QQC2.TabButton { text: "Logo SO"; width: implicitWidth }
            QQC2.TabButton { text: "Contorno"; width: implicitWidth }
            QQC2.TabButton { text: "Apariencia"; width: implicitWidth }
            QQC2.TabButton { text: "Islas y posición"; width: implicitWidth }
            QQC2.TabButton { text: "Autocontracción"; width: implicitWidth }
            QQC2.TabButton { text: "Acerca de"; width: implicitWidth }
        }

        StackLayout {
            id: pages
            currentIndex: tabs.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 1. Logo: se conserva encuadre visual y recorte no destructivo.
            QQC2.ScrollView {
                id: logoScroll
                clip: true
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: logoScroll.availableWidth - 8
                    spacing: 10
                    QQC2.Label {
                        text: "Imagen del botón SO · vista previa"
                        color: "white"
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 226
                        Layout.preferredHeight: 226
                        radius: 12
                        color: "#394258"
                        border.color: "#798399"
                        LogoArtwork {
                            anchors.centerIn: parent
                            width: 204
                            // La vista previa de las figuras anchas mantiene la
                            // misma proporción del botón SO real, no una miniatura cuadrada.
                            height: settings.soButtonFrameShape === "square" ? 204 :
                                Math.max(54, Math.min(204,
                                    204 * Math.max(30, settings.soledadHeight - 10) /
                                    Math.max(44, settings.soButtonWidth)))
                            imageUrl: settings.selectedImage
                            animateGif: settings.isGif
                            animationAllowed: settings.enableGif
                            cropShape: settings.soButtonFrameShape === "square"
                                ? settings.shape : settings.soButtonFrameShape
                            imageRotation: settings.cropRotation
                            fitMode: settings.cropFitMode
                            zoom: settings.cropZoom
                            panX: settings.cropPanX
                            panY: settings.cropPanY
                            visible: settings.logoMode !== "text" && settings.selectedImage.toString().length > 0
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.SizeAllCursor
                                property real lastX: 0
                                property real lastY: 0
                                onPressed: function(mouse) {
                                    lastX = mouse.x
                                    lastY = mouse.y
                                }
                                onPositionChanged: function(mouse) {
                                    if (!pressed) return
                                    settings.cropPanX = Math.max(-1, Math.min(1,
                                        settings.cropPanX + (mouse.x - lastX) / 100))
                                    settings.cropPanY = Math.max(-1, Math.min(1,
                                        settings.cropPanY + (mouse.y - lastY) / 100))
                                    lastX = mouse.x
                                    lastY = mouse.y
                                }
                            }
                        }
                        QQC2.Label {
                            anchors.centerIn: parent
                            text: "SO"
                            visible: settings.logoMode === "text" || settings.selectedImage.toString().length === 0
                            color: "white"
                            font.pixelSize: 40
                        }
                    }
                    QQC2.Label {
                        visible: settings.logoMode !== "text" && settings.selectedImage.toString().length > 0
                        text: "Arrastrá la foto o el GIF para elegir qué parte mostrar."
                        color: "#ddd6e8"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.ComboBox {
                            Layout.fillWidth: true
                            model: ["Predeterminada tropical", "Imagen propia", "Texto SO"]
                            currentIndex: settings.logoMode === "text" ? 2 :
                                (settings.logoMode === "custom" ? 1 : 0)
                            onActivated: function(i) {
                                settings.logoMode = i === 2 ? "text" :
                                    (i === 1 ? "custom" : "default")
                            }
                        }
                        QQC2.Button {
                            visible: settings.logoMode === "custom"
                            text: "Elegir archivo…"
                            onClicked: chooseImage.open()
                        }
                    }
                    QQC2.Label {
                        text: "Forma del botón SO y del recorte";
                        color: "white"
                        visible: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Cuadrado", "Círculo", "Rombo ♦", "Corazón ♥", "Estrella ★",
                                "Rectángulo recto", "Rectángulo redondeado",
                                "Cápsula horizontal", "Óvalo horizontal"]
                        currentIndex: ["square", "circle", "diamond", "heart", "star",
                                       "rectangle", "rounded", "capsule", "oval"]
                            .indexOf(settings.soButtonFrameShape === "square"
                                     ? settings.shape : settings.soButtonFrameShape)
                        onActivated: function(i) {
                            const choice = ["square", "circle", "diamond", "heart", "star",
                                            "rectangle", "rounded", "capsule", "oval"][i]
                            if (i < 5) {
                                settings.shape = choice
                                settings.soButtonFrameShape = "square"
                            } else {
                                settings.shape = "square"
                                settings.soButtonFrameShape = choice
                            }
                        }
                    }
                    QQC2.Label {
                        text: "Ajuste de la imagen";
                        color: "white"
                        visible: settings.logoMode !== "text"
                    }
                    QQC2.ComboBox {
                        visible: settings.logoMode !== "text"
                        Layout.fillWidth: true
                        model: ["Imagen completa (encajar)", "Rellenar forma (recortar)",
                                "Estirar (deformar la imagen)"]
                        currentIndex: settings.cropFitMode === "stretch" ? 2 :
                            (settings.cropFitMode === "crop" ? 1 : 0)
                        onActivated: function(i) {
                            settings.cropFitMode = ["fit", "crop", "stretch"][i]
                        }
                    }
                    RowLayout {
                        visible: settings.logoMode !== "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Escala"; color: "white"; Layout.preferredWidth: 90 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 1; to: 4
                            value: settings.cropZoom
                            onMoved: settings.cropZoom = value
                        }
                        QQC2.Label {
                            text: Math.round(settings.cropZoom * 100) + "%"
                            color: "white"
                        }
                    }
                    RowLayout {
                        visible: settings.logoMode !== "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Horizontal"; color: "white"; Layout.preferredWidth: 90 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: -1; to: 1
                            value: settings.cropPanX
                            onMoved: settings.cropPanX = value
                        }
                    }
                    RowLayout {
                        visible: settings.logoMode !== "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Vertical"; color: "white"; Layout.preferredWidth: 90 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: -1; to: 1
                            value: settings.cropPanY
                            onMoved: settings.cropPanY = value
                        }
                    }
                    RowLayout {
                        visible: settings.logoMode !== "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Rotación"; color: "white"; Layout.preferredWidth: 90 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: -180; to: 180; stepSize: 1
                            value: settings.cropRotation
                            onMoved: settings.cropRotation = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.cropRotation) + "°"
                            color: "white"
                            Layout.preferredWidth: 52
                        }
                    }
                    QQC2.Label {
                        text: "Ancho de los formatos horizontales";
                        color: "white";
                        font.bold: true
                        visible: settings.soButtonFrameShape !== "square"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        visible: settings.soButtonFrameShape !== "square"
                        QQC2.Label { text: "Ancho SO"; color: "white"; Layout.preferredWidth: 90 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 44; to: 180; stepSize: 2
                            value: settings.soButtonWidth
                            onMoved: settings.soButtonWidth = value
                        }
                        QQC2.Label {
                            text: Math.round(settings.soButtonWidth) + " px"
                            color: "white"
                            Layout.preferredWidth: 56
                        }
                    }
                    QQC2.Label {
                        visible: settings.logoMode !== "text"
                        text: "Elegí todas las formas desde el mismo desplegable. Estirar mantiene la deformación al aumentar el zoom. El archivo original no se modifica; una imagen pequeña no gana detalle al ampliarse."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        visible: settings.logoMode !== "text" && settings.isGif
                        text: "Reproducir GIF animados"
                        checked: settings.enableGif
                        onToggled: settings.enableGif = checked
                    }
                    QQC2.Label {
                        text: "Hora y fecha en SO"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.Label {
                        text: "Al posar el cursor sobre los seis puntos, aparece la hora 1 segundo y después la fecha 1 segundo. El GIF permanece debajo sin reiniciarse."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Fuente: " + settings.clockFontFamily
                            color: "white"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        QQC2.Button {
                            text: "Elegir fuente…"
                            onClicked: {
                                clockFontDialog.selectedFont = Qt.font({
                                    family: settings.clockFontFamily,
                                    pixelSize: settings.clockFontSize
                                })
                                clockFontDialog.open()
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Tamaño del reloj (px)"
                            color: "white"
                            Layout.fillWidth: true
                        }
                        QQC2.SpinBox {
                            from: 9; to: 28; stepSize: 1
                            editable: true
                            value: settings.clockFontSize
                            onValueModified: settings.clockFontSize = value
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Color del texto"
                            color: "white"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 36
                            height: 25
                            radius: 4
                            color: settings.clockTextColor
                            border.color: "#91a8b8"
                        }
                        QQC2.Label {
                            text: settings.toHex(settings.clockTextColor)
                            color: "white"
                        }
                        QQC2.Button {
                            text: "Elegir color…"
                            onClicked: {
                                clockColorDialog.selectedColor = settings.clockTextColor
                                clockColorDialog.open()
                            }
                        }
                    }
                    QQC2.Button {
                        text: "Restablecer texto del reloj (11 px, blanco)"
                        onClicked: {
                            settings.clockFontFamily = "Sans Serif"
                            settings.clockFontSize = 11
                            settings.clockTextColor = "#ffffff"
                        }
                    }
                    QQC2.Button {
                        text: "Restablecer logo y formato"
                        onClicked: {
                            settings.logoMode = "default"
                            settings.filePath = ""
                            settings.soButtonFrameShape = "capsule"
                            settings.soButtonWidth = 96
                            settings.cropRotation = 0
                            settings.enableGif = true
                            settings.cropZoom = 1
                            settings.cropPanX = 0
                            settings.cropPanY = 0
                            settings.shape = "square"
                            settings.cropFitMode = "stretch"
                        }
                    }
                }
            }

            // 2. Contorno con vista previa fija y opciones contextuales.
            ColumnLayout {
                spacing: 8
                QQC2.Label { text: "Contorno de actividad del botón SO"; color: "white"; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
                        radius: 12
                        color: "#353b52"
                        IslandButton {
                            anchors.centerIn: parent
                            // Zoom exclusivamente visual de la muestra;
                            // no modifica el tamaño real de Soledad.
                            scale: 1.45
                            text: "SO"
                            accent: true
                            iconSource: settings.appliedOutlinePreview.iconSource
                            iconAnimated: settings.appliedOutlinePreview.iconAnimated
                            iconAnimationEnabled: settings.appliedOutlinePreview.iconAnimationEnabled
                            iconShape: settings.appliedOutlinePreview.iconShape
                            frameShape: settings.appliedOutlinePreview.frameShape
                            preferredButtonWidth: settings.appliedOutlinePreview.frameShape === "square" ? 40 : (settings.appliedOutlinePreview.frameWidth || 96)
                            preferredButtonHeight: settings.appliedOutlinePreview.frameHeight || 34
                            iconRotation: settings.appliedOutlinePreview.iconRotation
                            iconFitMode: settings.appliedOutlinePreview.iconFitMode
                            iconZoom: settings.appliedOutlinePreview.iconZoom
                            iconPanX: settings.appliedOutlinePreview.iconPanX
                            iconPanY: settings.appliedOutlinePreview.iconPanY
                            activityCount: settings.appliedOutlinePreview.activityCount
                            activityEffect: settings.appliedOutlinePreview.activityEffect
                            activityColor: settings.appliedOutlinePreview.activityColor
                            activityStroke: settings.appliedOutlinePreview.activityStroke
                            activityMotionAllowed: settings.appliedOutlinePreview.activityMotionAllowed
                            activityOrbitSpeed: settings.appliedOutlinePreview.activityOrbitSpeed
                            activityTrailPercent: settings.appliedOutlinePreview.activityTrailPercent
                            activityTrailStyle: settings.appliedOutlinePreview.activityTrailStyle
                            activityGlowColor: settings.appliedOutlinePreview.activityGlowColor
                            activityGlowIntensity: settings.appliedOutlinePreview.activityGlowIntensity
                            activityGlowSpread: settings.appliedOutlinePreview.activityGlowSpread
                            activityPulseSpeed: settings.appliedOutlinePreview.activityPulseSpeed
                            activityPulseDepth: settings.appliedOutlinePreview.activityPulseDepth
                            activityGlowGradient: settings.appliedOutlinePreview.activityGlowGradient
                            activityShowWhenEmpty: settings.appliedOutlinePreview.activityShowWhenEmpty
                            activityShowWhenOpen: settings.appliedOutlinePreview.activityShowWhenOpen
                        }
                    }

                QQC2.Label {
                    text: "Muestra de los últimos ajustes aplicados. Pulsá Aplicar para ver los cambios."
                    color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                }
                QQC2.ScrollView {
                    id: outlineScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                    ColumnLayout {
                        width: outlineScroll.availableWidth - 8
                        spacing: 13
                    QQC2.CheckBox {
                        visible: settings.effectStyle !== "off"
                        text: "Simular ventanas abiertas en esta vista previa"
                        checked: settings.simulateHasWindows
                        onToggled: settings.simulateHasWindows = checked
                    }
                    QQC2.Label {
                        visible: settings.effectStyle !== "off"
                        text: "Elegí cuándo mostrar el contorno. Sin ventanas, la luz puede invitar a abrir aplicaciones; con ventanas, podés ocultarla."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        visible: settings.effectStyle !== "off"
                        text: "Mostrar contorno cuando NO hay ventanas (predeterminado)"
                        checked: settings.showOutlineWhenEmpty
                        onToggled: settings.showOutlineWhenEmpty = checked
                    }
                    QQC2.CheckBox {
                        visible: settings.effectStyle !== "off"
                        text: "Mostrar contorno cuando HAY ventanas"
                        checked: settings.showOutlineWhenOpen
                        onToggled: settings.showOutlineWhenOpen = checked
                    }
                    QQC2.Label {
                        visible: settings.effectStyle !== "off"
                        text: "Podés activar ambos estados, uno solo o ninguno. El efecto «Desactivado» apaga el contorno en todos los casos."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label { text: "Efecto"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Desactivado", "Borde fijo clásico", "Luz móvil clásica",
                                "Brillo exterior fijo", "Respiración luminosa",
                                "Luz móvil con resplandor"]
                        currentIndex: Math.max(0, ["off","steady","orbit","glow","breathe","orbitGlow"]
                            .indexOf(settings.effectStyle))
                        onActivated: function(i) {
                            settings.effectStyle = ["off","steady","orbit","glow","breathe","orbitGlow"][i]
                            if (i >= 3 && settings.toHex(settings.accentColor).toLowerCase() === "#35d7ff")
                                settings.accentColor = "#ffd27a"
                        }
                    }
                    RowLayout {
                        visible: settings.effectStyle !== "off"
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Elegir color…"
                            onClicked: {
                                outlineColorDialog.selectedColor = settings.accentColor
                                outlineColorDialog.open()
                            }
                        }
                        Rectangle {
                            width: 40; height: 27
                            radius: 6
                            color: settings.accentColor
                        }
                        QQC2.Label {
                            text: settings.toHex(settings.accentColor)
                            color: "white"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Grosor";
                            color: "white";
                            Layout.preferredWidth: 80
                            visible: settings.effectStyle !== "off"
                        }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.5; to: 2; stepSize: 0.25
                            value: settings.strokeSize
                            onMoved: settings.strokeSize = value
                        }
                        QQC2.Label {
                            text: settings.strokeSize.toFixed(2) + " px"
                            color: "white"
                        }
                    }
                    QQC2.Label {
                        visible: settings.outlineIsOrbit && settings.allowMotion
                        text: "Ajustes de la luz que recorre el contorno"
                        color: "white"
                        font.bold: true
                    }
                    RowLayout {
                        visible: settings.outlineIsOrbit && settings.allowMotion
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Velocidad (vueltas/segundo)"
                            color: "white"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        QQC2.SpinBox {
                            id: orbitSpeedInput
                            from: 1; to: 30; stepSize: 1
                            editable: true
                            // SpinBox usa IntValidator por defecto; permitir "1.5" y
                            // "1,5" con un decimal, sin alterar su valor interno.
                            validator: RegularExpressionValidator {
                                regularExpression: /^([0-3]|[0-2][.,][0-9]|3[.,]0)?$/
                            }
                            enabled: (settings.effectStyle === "orbit" || settings.effectStyle === "orbitGlow") && settings.allowMotion
                            value: Math.round(settings.orbitSpeed * 10)
                            textFromValue: function(v, locale) {
                                return (v / 10).toFixed(1)
                            }
                            valueFromText: function(t, locale) {
                                const n = Number(String(t).trim().replace(",", "."))
                                return isNaN(n) ? value : Math.round(n * 10)
                            }
                            onValueModified: settings.orbitSpeed = value / 10
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "1,0 = una vuelta por segundo; hasta 3,0"
                        }
                    }
                    RowLayout {
                        visible: settings.outlineIsOrbit && settings.allowMotion
                        Layout.fillWidth: true
                        QQC2.Label {
                            text: "Longitud de la cola (% del borde)"
                            color: "white"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        QQC2.SpinBox {
                            from: 5; to: 85; stepSize: 1
                            editable: true
                            enabled: (settings.effectStyle === "orbit" || settings.effectStyle === "orbitGlow") && settings.allowMotion
                            value: settings.trailPercent
                            onValueModified: settings.trailPercent = value
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Qué porcentaje del contorno ocupa la luz móvil"
                        }
                    }
                    QQC2.Label {
                        visible: settings.outlineIsOrbit && settings.allowMotion
                        text: "Trazo de la luz móvil"
                        color: "white"
                    }
                    QQC2.ComboBox {
                        visible: settings.outlineIsOrbit && settings.allowMotion
                        Layout.fillWidth: true
                        enabled: (settings.effectStyle === "orbit" || settings.effectStyle === "orbitGlow") && settings.allowMotion
                        model: ["Línea continua", "Punteado", "Guiones"]
                        currentIndex: settings.trailStyle === "dotted" ? 1 :
                            (settings.trailStyle === "dashed" ? 2 : 0)
                        onActivated: function(i) {
                            settings.trailStyle = ["solid", "dotted", "dashed"][i]
                        }
                    }
                    QQC2.CheckBox {
                        visible: settings.outlineCanMove
                        text: "Permitir movimiento sutil del borde"
                        checked: settings.allowMotion
                        enabled: settings.effectStyle === "orbit" || settings.effectStyle === "orbitGlow" || settings.effectStyle === "breathe"
                        onToggled: settings.allowMotion = checked
                    }
                    QQC2.Label {
                        visible: settings.outlineCanMove
                        text: "El movimiento del borde es opcional. No se anima la isla."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.outlineUsesGlow
                        text: "Iluminación exterior y degradado"
                        color: "white"
                        font.bold: true
                    }
                    RowLayout {
                        visible: settings.outlineUsesGlow
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Color exterior…"
                            onClicked: {
                                glowColorDialog.selectedColor = settings.glowColor
                                glowColorDialog.open()
                            }
                        }
                        Rectangle { width: 36; height: 25; radius: 5; color: settings.glowColor }
                        QQC2.Label { text: settings.toHex(settings.glowColor); color: "white" }
                    }
                    QQC2.CheckBox {
                        visible: settings.outlineUsesGlow
                        text: "Degradado: centro brillante y exterior más suave"
                        checked: settings.glowGradient
                        onToggled: settings.glowGradient = checked
                    }
                    QQC2.Label {
                        visible: settings.outlineUsesGlow
                        text: "El color principal se elige arriba. El color exterior se elige aquí; en el degradado se combinan ambos."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.outlineUsesGlow
                        text: "Usar colores cálidos (dorado y naranja)"
                        onClicked: {
                            settings.accentColor = "#ffd27a"
                            settings.glowColor = "#ff963c"
                        }
                    }
                    QQC2.Label {
                        text: "Intensidad del brillo"
                        color: "white"
                        visible: settings.outlineUsesGlow
                    }
                    RowLayout {
                        visible: settings.outlineUsesGlow
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.glowIntensity
                            onMoved: settings.glowIntensity = value
                        }
                        QQC2.Label { text: Math.round(settings.glowIntensity * 100) + "%"; color: "white" }
                    }
                    QQC2.Label {
                        text: "Difusión del brillo"
                        color: "white"
                        visible: settings.outlineUsesGlow
                    }
                    RowLayout {
                        visible: settings.outlineUsesGlow
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 1; to: 8; stepSize: 0.5
                            value: settings.glowSpread
                            onMoved: settings.glowSpread = value
                        }
                        QQC2.Label { text: settings.glowSpread.toFixed(1) + " px"; color: "white" }
                    }
                    QQC2.Label {
                        text: "Velocidad de respiración"
                        color: "white"
                        visible: settings.effectStyle === "breathe" && settings.allowMotion
                    }
                    RowLayout {
                        visible: settings.effectStyle === "breathe" && settings.allowMotion
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.1; to: 3; stepSize: 0.1
                            enabled: settings.effectStyle === "breathe" && settings.allowMotion
                            value: settings.pulseSpeed
                            onMoved: settings.pulseSpeed = value
                        }
                        QQC2.Label { text: settings.pulseSpeed.toFixed(1) + " ciclos/s"; color: "white" }
                    }
                    QQC2.Label {
                        text: "Profundidad de la respiración"
                        color: "white"
                        visible: settings.effectStyle === "breathe" && settings.allowMotion
                    }
                    RowLayout {
                        visible: settings.effectStyle === "breathe" && settings.allowMotion
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            enabled: settings.effectStyle === "breathe"
                            value: settings.pulseDepth
                            onMoved: settings.pulseDepth = value
                        }
                        QQC2.Label {
                            text: Math.round(settings.pulseDepth * 100) + "%"
                            color: "white"
                        }
                    }
                    QQC2.Button {
                        text: "Restablecer contorno"
                        onClicked: {
                            settings.effectStyle = "orbit"
                            settings.accentColor = "#35d7ff"
                            settings.strokeSize = 0.75
                            settings.allowMotion = true
                            settings.orbitSpeed = 1.5
                            settings.trailPercent = 75
                            settings.trailStyle = "dashed"
                            settings.glowColor = "#ffab52"
                            settings.glowIntensity = 0.7
                            settings.glowSpread = 5
                            settings.pulseSpeed = 0.6
                            settings.pulseDepth = 0.7
                            settings.glowGradient = true
                            settings.showOutlineWhenEmpty = true
                            settings.showOutlineWhenOpen = false
                        }
                    }
                }
                }
            }

            // 3. Apariencia: las islas mantienen sus preferencias independientes.
            QQC2.ScrollView {
                id: appearanceScroll
                clip: true
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: appearanceScroll.availableWidth - 8
                    spacing: 14
                    QQC2.Label {
                        text: "Colores y transparencia"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: "Color por isla y fondo; bandeja y agarre heredan Soledad salvo personalización."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.ComboBox {
                        id: appearanceTarget
                        Layout.fillWidth: true
                        model: ["Soledad (isla 1)", "Malvina (isla 2)", "Fondo opcional",
                                "Botones de bandeja", "Botón de seis puntos (agarre)"]
                    }
                    QQC2.CheckBox {
                        Layout.fillWidth: true
                        visible: appearanceTarget.currentIndex >= 3
                        text: "Usar color y opacidad propios (sin heredar de Soledad)"
                        checked: appearanceTarget.currentIndex === 3
                            ? settings.trayButtonColorOverride
                            : settings.gripButtonColorOverride
                        onToggled: settings.setAppearanceOverride(checked)
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        visible: appearanceTarget.currentIndex >= 3 &&
                                 !settings.appearanceCanEdit
                        text: "Este botón usa automáticamente el color y la opacidad actuales de Soledad."
                        color: "#ddd6e8"
                        wrapMode: Text.WordWrap
                    }
                    RowLayout {
                        visible: settings.appearanceCanEdit
                        Layout.fillWidth: true
                        Rectangle {
                            width: 54
                            height: 42
                            radius: 8
                            border.color: "#abc4d1"
                            color: Qt.rgba(settings.activeColor.r, settings.activeColor.g,
                                           settings.activeColor.b, settings.activeOpacity)
                        }
                        QQC2.Button {
                            text: "Elegir color…"
                            enabled: settings.appearanceCanEdit
                            onClicked: {
                                islandColorDialog.editingTarget = appearanceTarget.currentIndex
                                islandColorDialog.selectedColor = settings.activeColor
                                islandColorDialog.open()
                            }
                        }
                        QQC2.Label {
                            text: settings.toHex(settings.activeColor)
                            color: "#eeeaf7"
                        }
                    }
                    QQC2.Label {
                        text: "Opacidad";
                        color: "white"
                        visible: settings.appearanceCanEdit
                    }
                    RowLayout {
                        visible: settings.appearanceCanEdit
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            enabled: settings.appearanceCanEdit
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.activeOpacity
                            onMoved: settings.chooseOpacity(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.activeOpacity * 100) + "%"
                            color: "white"
                            Layout.preferredWidth: 65
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Degradado de dos colores por isla"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Soledad y Malvina conservan sus colores uniformes mientras el degradado está desactivado. Los botones transparentes dejan ver el degradado cuando está activo."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Activar degradado de la isla seleccionada"
                        checked: appearanceTarget.currentIndex === 0
                            ? settings.soledadGradientEnabled : settings.malvinaGradientEnabled
                        onToggled: {
                            if (appearanceTarget.currentIndex === 0)
                                settings.soledadGradientEnabled = checked
                            else settings.malvinaGradientEnabled = checked
                        }
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex <= 1 && (appearanceTarget.currentIndex === 0 ? settings.soledadGradientEnabled : settings.malvinaGradientEnabled)
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Segundo color…"
                            onClicked: {
                                islandGradientEndDialog.target = appearanceTarget.currentIndex
                                islandGradientEndDialog.selectedColor =
                                    appearanceTarget.currentIndex === 0
                                    ? settings.soledadGradientEnd : settings.malvinaGradientEnd
                                islandGradientEndDialog.open()
                            }
                        }
                        Rectangle {
                            width: 36; height: 24; radius: 5
                            color: appearanceTarget.currentIndex === 0
                                ? settings.soledadGradientEnd : settings.malvinaGradientEnd
                        }
                    }
                    QQC2.Label {
                        text: "Dirección del degradado";
                        color: "white"
                        visible: appearanceTarget.currentIndex <= 1 && (appearanceTarget.currentIndex === 0 ? settings.soledadGradientEnabled : settings.malvinaGradientEnabled)
                    }
                    QQC2.ComboBox {
                        visible: appearanceTarget.currentIndex <= 1 && (appearanceTarget.currentIndex === 0 ? settings.soledadGradientEnabled : settings.malvinaGradientEnabled)
                        Layout.fillWidth: true
                        model: ["Arriba → abajo", "Abajo → arriba",
                                "Izquierda → derecha", "Derecha → izquierda"]
                        currentIndex: Math.max(0,
                            ["topBottom","bottomTop","leftRight","rightLeft"].indexOf(
                                appearanceTarget.currentIndex === 0
                                    ? settings.soledadGradientDirection
                                    : settings.malvinaGradientDirection))
                        onActivated: function(i) {
                            const d = ["topBottom","bottomTop","leftRight","rightLeft"][i]
                            if (appearanceTarget.currentIndex === 0)
                                settings.soledadGradientDirection = d
                            else settings.malvinaGradientDirection = d
                        }
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex === 0 && settings.soledadGradientEnabled
                        text: "Sincronizar respiración del degradado de Soledad con SO"
                        enabled: settings.soledadGradientEnabled
                        checked: settings.soledadGradientSyncBreathing
                        onToggled: settings.soledadGradientSyncBreathing = checked
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.soledadGradientEnabled &&
                                 settings.soledadGradientSyncBreathing
                        text: "Requiere Respiración luminosa activa en el contorno SO. Ambas comparten velocidad y fase; se activa con Aplicar."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Intensidad de respiración del degradado"
                        color: "white"
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.soledadGradientEnabled &&
                                 settings.soledadGradientSyncBreathing
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.soledadGradientEnabled &&
                                 settings.soledadGradientSyncBreathing
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.soledadGradientBreathingIntensity
                            onMoved: settings.soledadGradientBreathingIntensity = value
                        }
                        QQC2.Label {
                            text: Math.round(settings.soledadGradientBreathingIntensity * 100) + "%"
                            color: "white"
                        }
                    }
                    QQC2.Label {
                        text: "Contorno de islas y botones"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.ComboBox {
                        id: outlineTarget
                        Layout.fillWidth: true
                        model: ["Soledad", "Malvina", "Botones de bandeja", "Agarre de seis puntos"]
                    }
                    QQC2.Label { text: "Tipo de línea"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Sin línea", "Simple continua", "Doble", "Discontinua", "Punteada"]
                        currentIndex: ["off", "solid", "double", "dashed", "dotted"].indexOf(settings.selectedOutline.style)
                        onActivated: function(i) { settings.setOutlineField("style", ["off","solid","double","dashed","dotted"][i]) }
                    }
                    QQC2.Label { text: "Grosor de línea"; color: "white" }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.5; to: 5; stepSize: 0.5
                            value: settings.selectedOutline.width
                            onMoved: settings.setOutlineField("width", value)
                        }
                        QQC2.Label {
                            text: settings.selectedOutline.width.toFixed(1) + " px"
                            color: "white"
                            Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Color del contorno…"
                            onClicked: {
                                islandOutlineColorDialog.selectedColor = settings.selectedOutline.color
                                islandOutlineColorDialog.open()
                            }
                        }
                        Rectangle { width: 34; height: 24; radius: 4; color: settings.selectedOutline.color }
                    }
                    QQC2.Label { text: "Transparencia del contorno"; color: "white" }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.selectedOutline.opacity
                            onMoved: settings.setOutlineField("opacity", value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.selectedOutline.opacity * 100) + "% visible"
                            color: "white"; Layout.preferredWidth: 90
                        }
                    }
                    QQC2.Button {
                        text: "Restablecer contorno seleccionado"
                        onClicked: {
                            settings.setOutlineField("style", "solid")
                            settings.setOutlineField("width", 1)
                            settings.setOutlineField("color",
                                settings.outlineTargetKey === "soledad" || settings.outlineTargetKey === "malvina" ? "#4e8499" : "#45647a")
                            settings.setOutlineField("opacity", 1)
                        }
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex === 2
                        text: "Mostrar fondo continuo opcional"
                        checked: settings.showBackground
                        onToggled: settings.showBackground = checked
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 2
                        text: "El fondo está desactivado por defecto. No cambia la altura ni reemplaza una isla."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Restablecer colores"
                        onClicked: {
                            settings.soledadColor = "#010111"
                            settings.malvinaColor = "#101e31"
                            settings.soledadGradientEnabled = false
                            settings.soledadGradientSyncBreathing = false
                            settings.soledadGradientBreathingIntensity = 0.6
                            settings.soledadGradientEnd = "#ee9852"
                            settings.soledadGradientDirection = "topBottom"
                            settings.malvinaGradientEnabled = false
                            settings.malvinaGradientEnd = "#445577"
                            settings.malvinaGradientDirection = "topBottom"
                            settings.backgroundColor = "#202333"
                            settings.soledadOpacity = 0.5
                            settings.malvinaOpacity = 1
                            settings.backgroundOpacity = 0.5
                            settings.showBackground = false
                            settings.trayButtonColorOverride = false
                            settings.trayButtonColor = "#010111"
                            settings.trayButtonOpacity = 0.5
                            settings.gripButtonColorOverride = false
                            settings.gripButtonColor = "#010111"
                            settings.gripButtonOpacity = 0.5
                        }
                    }
                }
            }

            // 4. Islas y posición de isla y posición, sin añadir isla extra.
            QQC2.ScrollView {
                id: positionScroll
                clip: true
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: positionScroll.availableWidth - 8
                    spacing: 16
                    QQC2.Label {
                        text: "Islas y posición"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        text: "Mostrar Malvina (isla 2)"
                        checked: settings.launcherIslandVisible
                        onToggled: settings.launcherIslandVisible = checked
                    }
                    QQC2.CheckBox {
                        visible: settings.launcherIslandVisible
                        text: "Ocultar Malvina automáticamente (predeterminado)"
                        checked: settings.autoHideMalvina
                        onToggled: settings.autoHideMalvina = checked
                    }
                    QQC2.Label {
                        visible: settings.launcherIslandVisible
                        text: "Con esta opción activada, Malvina aparece solo si dejás el cursor 0,6 segundos en su ubicación. Al salir vuelve a ocultarse. Si desactivás esta opción, permanece a la vista. «Mostrar Malvina» permite habilitarla o quitarla por completo."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        text: "Alinear isla 1 a la derecha"
                        checked: settings.alignedRight
                        onToggled: settings.alignedRight = checked
                        onClicked: settings.alignmentEdited = true
                    }
                    QQC2.CheckBox {
                        visible: settings.alignedRight
                        text: "Volver a la derecha al desmaximizar"
                        checked: settings.autoReturnRight
                        onToggled: settings.autoReturnRight = checked
                    }
                    QQC2.Label {
                        visible: settings.alignedRight
                        text: "El regreso al desmaximizar está activado por defecto. No impide mover Soledad manualmente."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Mover isla 1 a la derecha AHORA"
                        onClicked: {
                            settings.alignNowRequested()
                            settings.alignedRight = true
                            settings.alignmentEdited = false
                        }
                    }
                    QQC2.Label {
                        text: "Mover ahora es una acción inmediata; no requiere Aplicar. La posición por aplicación sigue pendiente de desarrollo."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Terminaciones visuales"
                        color: "white"; font.bold: true
                    }
                    QQC2.Label {
                        text: "Soledad: el modelo inicial conserva la izquierda redondeada y termina recto a la derecha."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                    QQC2.Label { text: "Forma de Soledad"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Izquierda redondeada / derecha recta (inicial)",
                                "Toda redondeada", "Toda cuadrada",
                                "Izquierda recta / derecha redondeada",
                                "Punta triangular izquierda / derecha recta"]
                        currentIndex: ["leftRoundRightSquare","rounded","square",
                                       "leftSquareRightRound","leftTip"]
                            .indexOf(settings.soledadShape)
                        onActivated: function(i) {
                            settings.soledadShape = ["leftRoundRightSquare","rounded",
                                "square","leftSquareRightRound","leftTip"][i]
                        }
                    }
                    QQC2.Label {
                        text: "Forma de Malvina";
                        color: "white"
                        visible: settings.launcherIslandVisible
                    }
                    QQC2.ComboBox {
                        visible: settings.launcherIslandVisible
                        Layout.fillWidth: true
                        model: ["Redondeada (inicial)", "Cuadrada",
                                "Izquierda redondeada / derecha recta",
                                "Izquierda recta / derecha redondeada"]
                        currentIndex: ["rounded","square","leftRoundRightSquare",
                                       "leftSquareRightRound"].indexOf(settings.malvinaShape)
                        onActivated: function(i) {
                            settings.malvinaShape = ["rounded","square",
                                "leftRoundRightSquare","leftSquareRightRound"][i]
                        }
                    }
                    QQC2.Label { text: "Agarre de seis puntos"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Cuadrado", "Cuadrado con bordes redondeados (inicial)"]
                        currentIndex: settings.gripShape === "rounded" ? 1 : 0
                        onActivated: function(i) {
                            settings.gripShape = i === 1 ? "rounded" : "square"
                        }
                    }
                    QQC2.Label { text: "Botón de bandeja simulada"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Redondeado (inicial)", "Cuadrado"]
                        currentIndex: settings.trayButtonShape === "square" ? 1 : 0
                        onActivated: function(i) {
                            settings.trayButtonShape = i === 1 ? "square" : "rounded"
                        }
                    }
                    QQC2.Label { text: "Geometría de las islas"; color: "white"; font.bold: true }
                    QQC2.Label {
                        text: "La altura elegida es constante durante el uso. Al aumentar una isla, Aplicar también aumenta la altura general si hace falta (máximo 120 px, con 4 px de margen)."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura general"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 40; to: 120; stepSize: 2
                            value: settings.panelHeight
                            onMoved: settings.panelHeight = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.panelHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura Soledad"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 32; to: 120; stepSize: 2
                            value: settings.soledadHeight
                            onMoved: settings.soledadHeight = Math.min(116, Math.round(value))
                        }
                        QQC2.Label {
                            text: Math.round(settings.soledadHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.launcherIslandVisible
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 32; to: 120; stepSize: 2
                            value: settings.malvinaHeight
                            onMoved: settings.malvinaHeight = Math.min(116, Math.round(value))
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.soledadShape !== "square" && settings.soledadShape !== "leftTip"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Esquinas Soledad"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 60; stepSize: 2
                            value: settings.soledadRadius
                            onMoved: settings.soledadRadius = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.soledadRadius) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.launcherIslandVisible && settings.malvinaShape !== "square"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Esquinas Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 60; stepSize: 2
                            value: settings.malvinaRadius
                            onMoved: settings.malvinaRadius = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaRadius) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label { text: "Ancho mínimo Soledad"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 420; stepSize: 2
                            value: settings.soledadMinWidth
                            onMoved: settings.soledadMinWidth = Math.round(value)
                        }
                        QQC2.Label {
                            text: settings.soledadMinWidth === 0 ? "Auto" : Math.round(settings.soledadMinWidth) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.launcherIslandVisible
                        Layout.fillWidth: true
                        QQC2.Label { text: "Ancho Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 52; to: 220; stepSize: 2
                            value: settings.malvinaWidth
                            onMoved: settings.malvinaWidth = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaWidth) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    QQC2.Label {
                        text: "Si la altura de una isla supera la altura general, se limita al espacio disponible. El ancho mínimo de Soledad no reemplaza la expansión automática de fichas."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Restablecer islas y posición"
                        onClicked: {
                            settings.launcherIslandVisible = true
                            settings.autoReturnRight = true
                            settings.alignedRight = true
                            settings.alignmentEdited = true
                            settings.panelHeight = 48
                            settings.soledadHeight = 44
                            settings.malvinaHeight = 44
                            settings.soledadRadius = 22
                            settings.malvinaRadius = 22
                            settings.soledadMinWidth = 0
                            settings.malvinaWidth = 52
                            settings.soledadShape = "leftRoundRightSquare"
                            settings.malvinaShape = "rounded"
                            settings.gripShape = "rounded"
                            settings.trayButtonShape = "rounded"
                        }
                    }
                }
            }
            // 5. Autocontracción: preferencias distintas; sin temporizador.
            QQC2.ScrollView {
                id: collapseScroll
                clip: true
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: collapseScroll.availableWidth - 8
                    spacing: 16
                    QQC2.Label {
                        text: "Autocontracción"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        text: "SO: contraer después de elegir una ventana"
                        checked: settings.autoCollapseSO
                        onToggled: settings.autoCollapseSO = checked
                    }
                    QQC2.Label {
                        text: "Activado por defecto. Podés dejar SO abierto desmarcando esta opción."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        text: "Bandeja: contraer después de utilizar un icono"
                        checked: settings.autoCollapseTray
                        onToggled: settings.autoCollapseTray = checked
                    }
                    QQC2.Label {
                        text: "Desactivado por defecto. La apertura del lanzador no contrae ninguna sección."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Sin temporizador de inactividad: el cierre solo se dispara por la acción aprobada o por falta de espacio."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Restablecer autocontracción"
                        onClicked: {
                            settings.autoCollapseSO = true
                            settings.autoCollapseTray = false
                        }
                    }
                }
            }

            // 6. Acerca de: contacto publicado con autorización del
            // mantenedor. Sin botones ni referencias a donaciones.
            QQC2.ScrollView {
                id: aboutScroll
                clip: true
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: aboutScroll.availableWidth - 8
                    spacing: 16
                    QQC2.Label {
                        text: "Acerca de Plasma SmartBar Islands"
                        color: "white"; font.bold: true; font.pixelSize: 18
                    }
                    QQC2.Label { text: "Autor: nicoarg87"; color: "white" }
                    QQC2.Label {
                        text: "Contacto para consultas: nicoarg87@gmail.com"
                        color: "white"
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAnywhere
                    }
                    QQC2.Button {
                        text: "Enviar una consulta por correo"
                        onClicked: Qt.openUrlExternally("mailto:nicoarg87@gmail.com")
                    }
                    QQC2.Label {
                        text: "Repositorio oficial: github.com/nicoarg87/plasma-smartbar"
                        color: "#9bdfff"
                        wrapMode: Text.WrapAnywhere
                        Layout.fillWidth: true
                    }
                    QQC2.Button {
                        text: "Abrir repositorio oficial"
                        onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar")
                    }
                    QQC2.Label {
                        text: "Plasma SmartBar es software libre: código y documentación propios bajo licencia MIT. Permite uso, modificación, redistribución y comercialización, conservando los avisos de copyright y licencia. Los recursos gráficos se licencian por separado."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "SIN NINGUNA GARANTÍA: el programa se distribuye tal cual, sin garantía de comerciabilidad ni de adecuación para un propósito particular, en la medida permitida por la legislación aplicable. Consultá el texto completo de MIT."
                        color: "#ffd6aa"
                        font.bold: true
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Leer licencia MIT"
                        onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar/blob/main/LICENSE")
                    }
                    QQC2.Label {
                        text: "Imágenes: licencias independientes. El GIF tropical de OpenAI es el recurso predeterminado de SO (CC0 1.0 según los derechos disponibles). La imagen exacta se distribuye en el ZIP de prueba hasta incorporarla al repositorio. Golden Dog sigue excluido."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Licencias de recursos gráficos"
                        onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar/blob/main/docs/LICENCIAS_RECURSOS_GRAFICOS.md")
                    }

                }
            }
        }

        // Pie fijo: ninguna pestaña puede ocultar Aplicar ni Cerrar.
        RowLayout {
            Layout.fillWidth: true
            QQC2.Label {
                id: appliedLabel
                text: ""
                color: "#b6ebdf"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            QQC2.Button {
                text: "Aplicar"
                highlighted: true
                onClicked: settings.applyChanges()
            }
            QQC2.Button {
                text: "Cerrar"
                onClicked: settings.close()
            }
        }
    }
}
