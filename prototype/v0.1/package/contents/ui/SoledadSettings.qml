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
    width: Math.min(750, Math.max(420, Screen.desktopAvailableWidth - 64))
    height: Math.min(850, Math.max(510, Screen.desktopAvailableHeight - 64))
    minimumWidth: 420
    minimumHeight: 510

    property alias currentTab: tabs.currentIndex
    property url defaultImage: ""

    // Valores de trabajo. Se copian desde SmartBarContent al abrir.
    property string logoMode: "default"
    property string filePath: ""
    property string shape: "square"
    property string cropFitMode: "fit"
    property real cropZoom: 1
    property real cropPanX: 0
    property real cropPanY: 0
    property bool enableGif: true
    readonly property url selectedImage: logoMode === "text" ? "" :
        (logoMode === "custom" && filePath.length > 0 ? filePath : defaultImage)
    readonly property bool isGif: logoMode === "custom" &&
        filePath.toLowerCase().endsWith(".gif")

    property color soledadColor: "#101e31"
    property color malvinaColor: "#101e31"
    property color backgroundColor: "#202333"
    property real soledadOpacity: 1
    property real malvinaOpacity: 1
    property real backgroundOpacity: 0.5
    property bool showBackground: false
    readonly property color activeColor: appearanceTarget.currentIndex === 0 ? soledadColor :
        (appearanceTarget.currentIndex === 1 ? malvinaColor : backgroundColor)
    readonly property real activeOpacity: appearanceTarget.currentIndex === 0 ? soledadOpacity :
        (appearanceTarget.currentIndex === 1 ? malvinaOpacity : backgroundOpacity)

    property string effectStyle: "steady"
    property color accentColor: "#35d7ff"
    property real strokeSize: 1
    property bool allowMotion: true
    property bool simulateHasWindows: true

    property bool autoCollapseSO: true
    property bool autoCollapseTray: false
    property bool autoReturnRight: true
    property bool launcherIslandVisible: true
    property bool alignedRight: true

    signal saveLogoRequested(string mode, string path, string shape,
                             string fitMode, real zoom, real panX,
                             real panY, bool animate)
    signal saveAppearanceRequested(string soColor, real soOpacity,
                                   string malColor, real malOpacity,
                                   bool backgroundShown, string bgColor,
                                   real bgOpacity)
    signal saveActivityRequested(string style, string color,
                                 real stroke, bool motion)
    signal saveBehaviorRequested(bool collapseSO, bool collapseTray,
                                 bool returnRight, bool showMalvina,
                                 bool alignRight)
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
        else backgroundOpacity = value
    }
    function applyChanges() {
        saveLogoRequested(logoMode, filePath, shape, cropFitMode,
                          cropZoom, cropPanX, cropPanY, enableGif)
        saveAppearanceRequested(toHex(soledadColor), soledadOpacity,
                                toHex(malvinaColor), malvinaOpacity,
                                showBackground, toHex(backgroundColor),
                                backgroundOpacity)
        saveActivityRequested(effectStyle, toHex(accentColor),
                              strokeSize, allowMotion)
        saveBehaviorRequested(autoCollapseSO, autoCollapseTray,
                              autoReturnRight, launcherIslandVisible,
                              alignedRight)
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
            else settings.backgroundColor = selectedColor
        }
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
            QQC2.TabButton { text: "Logo SO" }
            QQC2.TabButton { text: "Apariencia" }
            QQC2.TabButton { text: "Contorno" }
            QQC2.TabButton { text: "Autocontracción" }
            QQC2.TabButton { text: "Islas y posición" }
            onCurrentIndexChanged: appliedLabel.text = ""
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
                            height: 204
                            imageUrl: settings.selectedImage
                            animateGif: settings.isGif
                            animationAllowed: settings.enableGif
                            cropShape: settings.shape
                            fitMode: settings.cropFitMode
                            zoom: settings.cropZoom
                            panX: settings.cropPanX
                            panY: settings.cropPanY
                            visible: settings.logoMode !== "text"
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
                            visible: settings.logoMode === "text"
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
                            model: ["Huella predeterminada", "Imagen propia", "Texto SO"]
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
                    QQC2.Label { text: "Forma de recorte"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Cuadrado", "Círculo", "Rombo ♦", "Corazón ♥", "Estrella ★"]
                        currentIndex: ["square","circle","diamond","heart","star"].indexOf(settings.shape)
                        onActivated: function(i) {
                            settings.shape = ["square","circle","diamond","heart","star"][i]
                        }
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Imagen completa (encajar)", "Rellenar forma (recortar)"]
                        currentIndex: settings.cropFitMode === "crop" ? 1 : 0
                        onActivated: function(i) { settings.cropFitMode = i === 1 ? "crop" : "fit" }
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
                    QQC2.CheckBox {
                        text: "Reproducir GIF animados"
                        checked: settings.enableGif
                        onToggled: settings.enableGif = checked
                    }
                    QQC2.Button {
                        text: "Restablecer encuadre"
                        onClicked: {
                            settings.cropZoom = 1
                            settings.cropPanX = 0
                            settings.cropPanY = 0
                            settings.shape = "square"
                            settings.cropFitMode = "fit"
                        }
                    }
                }
            }

            // 2. Apariencia: las islas mantienen sus preferencias independientes.
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
                        text: "Elegí Soledad, Malvina o el fondo continuo opcional."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.ComboBox {
                        id: appearanceTarget
                        Layout.fillWidth: true
                        model: ["Soledad (isla 1)", "Malvina (isla 2)", "Fondo opcional"]
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
                            settings.soledadColor = "#101e31"
                            settings.malvinaColor = "#101e31"
                            settings.backgroundColor = "#202333"
                            settings.soledadOpacity = 1
                            settings.malvinaOpacity = 1
                            settings.backgroundOpacity = 0.5
                            settings.showBackground = false
                        }
                    }
                }
            }

            // 3. Contorno: solo si hay ventanas, respetando forma y rendimiento.
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
                            iconFitMode: settings.cropFitMode
                            iconZoom: settings.cropZoom
                            iconPanX: settings.cropPanX
                            iconPanY: settings.cropPanY
                            activityCount: settings.simulateHasWindows ? 3 : 0
                            activityEffect: settings.effectStyle
                            activityColor: settings.accentColor
                            activityStroke: settings.strokeSize
                            activityMotionAllowed: settings.allowMotion
                        }
                    }
                    QQC2.CheckBox {
                        text: "Simular ventanas abiertas en esta vista previa"
                        checked: settings.simulateHasWindows
                        onToggled: settings.simulateHasWindows = checked
                    }
                    QQC2.Label {
                        text: "Sin ventanas abiertas, el borde debe desaparecer."
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
                            settings.effectStyle = "steady"
                            settings.accentColor = "#35d7ff"
                            settings.strokeSize = 1
                            settings.allowMotion = true
                        }
                    }
                }
            }

            // 4. Autocontracción: preferencias distintas; sin temporizador.
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
                }
            }

            // 5. Opciones actuales de isla y posición, sin añadir isla extra.
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
                    QQC2.Label {
                        text: "Malvina permanece visible por defecto. Podés recuperarla desde el menú de los seis puntos."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.CheckBox {
                        text: "Alinear isla 1 a la derecha"
                        checked: settings.alignedRight
                        onToggled: settings.alignedRight = checked
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
                        }
                    }
                    QQC2.Label {
                        text: "Mover ahora es una acción inmediata; no requiere Aplicar. La posición por aplicación sigue pendiente de desarrollo."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
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
