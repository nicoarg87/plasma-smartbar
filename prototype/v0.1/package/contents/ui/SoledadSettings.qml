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
    property int clockFontSize: 16
    property color clockTextColor: "#ffffff"
    readonly property url selectedImage: logoMode === "text" ? "" :
        (logoMode === "custom" && filePath.length > 0 ? filePath : defaultImage)
    // El recurso predeterminado es ahora un GIF original. La vista previa
    // debe animarlo, no solo animar GIF cargados desde un archivo propio.
    readonly property bool isGif: logoMode === "default" ||
        (logoMode === "custom" && filePath.toLowerCase().endsWith(".gif"))

    property color soledadColor: "#010111"
    property color malvinaColor: "#101e31"
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
    property int trailPercent: 75 // porcentaje del perímetro
    property string trailStyle: "dashed" // solid, dotted, dashed
    property bool showOutlineWhenEmpty: true
    property bool showOutlineWhenOpen: false
    property bool simulateHasWindows: false

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
    property string gripShape: "square"
    property string trayButtonShape: "rounded"
    // No reinterpretar un arrastre posterior como una orden de alineación.
    property bool alignmentEdited: false

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
        saveClockAppearanceRequested(clockFontFamily, clockFontSize,
                                     toHex(clockTextColor))
        saveLogoRequested(logoMode, filePath, shape, cropFitMode,
                          cropZoom, cropPanX, cropPanY, enableGif, cropRotation)
        saveGeometryRequested(panelHeight,
                              Math.min(soledadHeight, panelHeight - 4),
                              Math.min(malvinaHeight, panelHeight - 4),
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
                            text: "Elegir archivo…"
                            onClicked: chooseImage.open()
                        }
                    }
                    QQC2.Label { text: "Forma del botón SO y del recorte"; color: "white" }
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
                    QQC2.Label { text: "Ajuste de la imagen"; color: "white" }
                    QQC2.ComboBox {
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
                    QQC2.Label { text: "Ancho de los formatos horizontales"; color: "white"; font.bold: true }
                    RowLayout {
                        Layout.fillWidth: true
                        enabled: settings.soButtonFrameShape !== "square"
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
                        text: "Elegí todas las formas desde el mismo desplegable. Estirar mantiene la deformación al aumentar el zoom. El archivo original no se modifica; una imagen pequeña no gana detalle al ampliarse."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
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
                        text: "Dejá el cursor brevemente sobre los seis puntos: SO muestra la hora y fecha durante tres segundos, sin desplazar la barra ni cambiar sus gestos."
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
                        text: "Restablecer tipografía y color de la hora"
                        onClicked: {
                            settings.clockFontFamily = "Sans Serif"
                            settings.clockFontSize = 16
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

            // 2. Contorno: solo si hay ventanas, respetando forma y rendimiento.
            QQC2.ScrollView {
                id: outlineScroll
                clip: true
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: outlineScroll.availableWidth - 8
                    spacing: 13
                    QQC2.Label {
                        text: "Contorno de actividad del botón SO"
                        color: "white"
                        font.bold: true
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
                        radius: 12
                        color: "#353b52"
                        IslandButton {
                            anchors.centerIn: parent
                            text: "SO"
                            accent: true
                            iconSource: settings.selectedImage
                            iconAnimated: settings.isGif
                            iconAnimationEnabled: settings.enableGif
                            iconShape: settings.shape
                            frameShape: settings.soButtonFrameShape
                            preferredButtonWidth: settings.soButtonFrameShape === "square" ? 40 : settings.soButtonWidth
                            preferredButtonHeight: Math.max(30, Math.min(settings.soledadHeight, settings.panelHeight - 4) - 10)
                            iconRotation: settings.cropRotation
                            iconFitMode: settings.cropFitMode
                            iconZoom: settings.cropZoom
                            iconPanX: settings.cropPanX
                            iconPanY: settings.cropPanY
                            activityCount: settings.simulateHasWindows ? 3 : 0
                            activityEffect: settings.effectStyle
                            activityColor: settings.accentColor
                            activityStroke: settings.strokeSize
                            activityMotionAllowed: settings.allowMotion
                            activityOrbitSpeed: settings.orbitSpeed
                            activityTrailPercent: settings.trailPercent
                            activityTrailStyle: settings.trailStyle
                            activityShowWhenEmpty: settings.showOutlineWhenEmpty
                            activityShowWhenOpen: settings.showOutlineWhenOpen
                        }
                    }
                    QQC2.CheckBox {
                        text: "Simular ventanas abiertas en esta vista previa"
                        checked: settings.simulateHasWindows
                        onToggled: settings.simulateHasWindows = checked
                    }
                    QQC2.Label {
                        text: "Elegí cuándo mostrar el contorno. Sin ventanas, la luz puede invitar a abrir aplicaciones; con ventanas, podés ocultarla."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        text: "Mostrar contorno cuando NO hay ventanas (predeterminado)"
                        checked: settings.showOutlineWhenEmpty
                        onToggled: settings.showOutlineWhenEmpty = checked
                    }
                    QQC2.CheckBox {
                        text: "Mostrar contorno cuando HAY ventanas"
                        checked: settings.showOutlineWhenOpen
                        onToggled: settings.showOutlineWhenOpen = checked
                    }
                    QQC2.Label {
                        text: "Podés activar ambos estados, uno solo o ninguno. El efecto «Desactivado» apaga el contorno en todos los casos."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label { text: "Efecto"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Desactivado", "Borde brillante fijo", "Luz que recorre el contorno"]
                        currentIndex: settings.effectStyle === "off" ? 0 :
                            (settings.effectStyle === "orbit" ? 2 : 1)
                        onActivated: function(i) {
                            settings.effectStyle = ["off","steady","orbit"][i]
                        }
                    }
                    RowLayout {
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
                        QQC2.Label { text: "Grosor"; color: "white"; Layout.preferredWidth: 80 }
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
                        text: "Ajustes de la luz que recorre el contorno"
                        color: "white"
                        font.bold: true
                    }
                    RowLayout {
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
                            enabled: settings.effectStyle === "orbit" && settings.allowMotion
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
                            enabled: settings.effectStyle === "orbit" && settings.allowMotion
                            value: settings.trailPercent
                            onValueModified: settings.trailPercent = value
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Qué porcentaje del contorno ocupa la luz móvil"
                        }
                    }
                    QQC2.Label {
                        text: "Trazo de la luz móvil"
                        color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        enabled: settings.effectStyle === "orbit" && settings.allowMotion
                        model: ["Línea continua", "Punteado", "Guiones"]
                        currentIndex: settings.trailStyle === "dotted" ? 1 :
                            (settings.trailStyle === "dashed" ? 2 : 0)
                        onActivated: function(i) {
                            settings.trailStyle = ["solid", "dotted", "dashed"][i]
                        }
                    }
                    QQC2.CheckBox {
                        text: "Permitir movimiento sutil del borde"
                        checked: settings.allowMotion
                        enabled: settings.effectStyle === "orbit"
                        onToggled: settings.allowMotion = checked
                    }
                    QQC2.Label {
                        text: "El movimiento del borde es opcional. No se anima la isla."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
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
                            settings.showOutlineWhenEmpty = true
                            settings.showOutlineWhenOpen = false
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
                    QQC2.Label { text: "Opacidad"; color: "white" }
                    RowLayout {
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
                    QQC2.CheckBox {
                        text: "Mostrar fondo continuo opcional"
                        checked: settings.showBackground
                        onToggled: settings.showBackground = checked
                    }
                    QQC2.Label {
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
                        text: "Ocultar Malvina automáticamente (predeterminado)"
                        checked: settings.autoHideMalvina
                        onToggled: settings.autoHideMalvina = checked
                    }
                    QQC2.Label {
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
                        text: "Volver a la derecha al desmaximizar"
                        checked: settings.autoReturnRight
                        onToggled: settings.autoReturnRight = checked
                    }
                    QQC2.Label {
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
                    QQC2.Label { text: "Forma de Malvina"; color: "white" }
                    QQC2.ComboBox {
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
                        model: ["Cuadrado (inicial)", "Redondeado"]
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
                        text: "La altura elegida es constante durante el uso. Las dos islas pueden tener medidas y esquinas diferentes."
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
                            onMoved: settings.soledadHeight = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.soledadHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 32; to: 120; stepSize: 2
                            value: settings.malvinaHeight
                            onMoved: settings.malvinaHeight = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
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
                            settings.gripShape = "square"
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
