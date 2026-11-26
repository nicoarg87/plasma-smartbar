import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

// Vista del botón SO y efectos; el estado y el guardado siguen en SoledadSettings.
QQC2.ScrollView {
    id: page
    required property var settingsTarget
    required property var imageFileDialog
    required property var textFontPicker
    required property var textColorPicker
    required property var textBackgroundColorPicker
    required property var textBackgroundFileDialog
    required property var clockFontPicker
    required property var clockColorPicker
    required property var lightOutlineColorPicker
    required property var glowColorPicker
    required property var paletteSamplerTarget
    readonly property var settings: settingsTarget
    function resetScroll() {
        if (contentItem) contentItem.contentY = 0
    }
    function scrollToLight() {
        if (!contentItem || !soLightSectionTitle.visible) return
        const scroll = contentItem
        const y = soLightSectionTitle.mapToItem(scroll.contentItem, 0, 0).y
        scroll.contentY = Math.max(0, Math.min(scroll.contentHeight - scroll.height, y - 12))
    }
                    // Contenido desplazable del logo SO
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: Math.max(0, availableWidth - 32)
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    QQC2.ScrollBar.vertical.width: 16
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                    ColumnLayout {
                        width: Math.max(0, page.availableWidth - 32)
                        spacing: 14
                        QQC2.Label {
                            text: "Logo, ancho y texto"
                            color: "white"
                            font.bold: true
                        }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 9
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        QQC2.Label {
                            text: "Anchura del botón SO · logo e imagen"
                            color: "white"; font.bold: true
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#ddd6e8"
                            text: "Ajusta el ancho de SO sin modificar el tamaño general de la barra. " +
                                  "Los formatos cuadrados mantienen su anchura determinada por la altura."
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            enabled: settings.soButtonFrameShape !== "square"
                            QQC2.Slider {
                                Layout.fillWidth: true
                                from: 44; to: 180; stepSize: 2
                                value: settings.soButtonWidth
                                onMoved: settings.soButtonWidth = value
                            }
                            QQC2.Label {
                                color: "white"
                                text: Math.round(settings.soButtonWidth) + " px"
                                Layout.preferredWidth: 58
                            }
                        }
                    }
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
                        Rectangle {
                            anchors.centerIn: parent
                            visible: settings.logoMode === "text"
                            width: settings.soButtonFrameShape === "square" ? 96 : 190
                            height: 64
                            radius: settings.soButtonFrameShape === "square" ||
                                    settings.soButtonFrameShape === "rectangle" ? 0 : height/2
                            clip: true
                            color: Qt.rgba(settings.soTextBackground.r,
                                           settings.soTextBackground.g,
                                           settings.soTextBackground.b,
                                           settings.soTextBackgroundOpacity)
                            LogoArtwork {
                                anchors.fill: parent
                                visible: settings.soTextBackgroundImage.length > 0
                                imageUrl: settings.soTextBackgroundImage
                                animateGif: settings.soTextBackgroundImage.toLowerCase().endsWith(".gif")
                                animationAllowed: true
                                cropShape: settings.soButtonFrameShape === "square"
                                    ? settings.shape : settings.soButtonFrameShape
                                fitMode: "crop"
                            }
                            Text {
                                anchors.fill: parent
                                anchors.margins: 6
                                text: settings.soTextLabel
                                color: settings.soTextColor
                                font.family: settings.soTextFontFamily
                                font.pixelSize: settings.soTextFontSize * 1.5
                                font.bold: settings.soTextBold
                                fontSizeMode: Text.Fit
                                minimumPixelSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        QQC2.Label {
                            anchors.centerIn: parent
                            text: "SO"
                            visible: settings.logoMode !== "text" &&
                                     settings.selectedImage.toString().length === 0
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
                            onClicked: imageFileDialog.open()
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
                    }
                    ColumnLayout {
                        visible: settings.logoMode === "text"
                        Layout.fillWidth: true
                        spacing: 9
                    QQC2.Label {
                        text: "Texto personalizado del botón SO"
                        color: "white"
                        visible: settings.logoMode === "text"
                        font.bold: true
                    }
                    QQC2.TextField {
                        Layout.fillWidth: true
                        visible: settings.logoMode === "text"
                        text: settings.soTextLabel
                        maximumLength: 24
                        placeholderText: "SO, Mint, CachyOS..."
                        onTextEdited: settings.soTextLabel = text
                    }
                    RowLayout {
                        visible: settings.logoMode === "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Fuente"; color: "white"; Layout.fillWidth: true }
                        QQC2.Button {
                            text: settings.soTextFontFamily + "  ▾"
                            Layout.preferredWidth: 230
                            onClicked: {
                                textFontPicker.selectedFont = Qt.font({
                                    family: settings.soTextFontFamily,
                                    pixelSize: settings.soTextFontSize,
                                    bold: settings.soTextBold
                                })
                                textFontPicker.open()
                            }
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Abrir selector de fuentes instaladas con lista desplazable"
                        }
                    }
                    RowLayout {
                        visible: settings.logoMode === "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Tamaño"; color: "white" }
                        QQC2.SpinBox {
                            from: 8; to: 36
                            value: settings.soTextFontSize
                            onValueModified: settings.soTextFontSize = value
                        }
                        QQC2.CheckBox {
                            text: "Negrita"
                            checked: settings.soTextBold
                            onToggled: settings.soTextBold = checked
                        }
                    }
                    RowLayout {
                        visible: settings.logoMode === "text"
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Color de letras…"
                            onClicked: { textColorPicker.selectedColor = settings.soTextColor; textColorPicker.open() }
                        }
                        Rectangle { width: 30; height: 22; radius: 4; color: settings.soTextColor }
                        QQC2.Button {
                            text: "Fondo…"
                            onClicked: { textBackgroundColorPicker.selectedColor = settings.soTextBackground; textBackgroundColorPicker.open() }
                        }
                        Rectangle { width: 30; height: 22; radius: 4; color: settings.soTextBackground }
                    }
                    RowLayout {
                        visible: settings.logoMode === "text"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Opacidad del fondo"; color: "white" }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.soTextBackgroundOpacity
                            onMoved: settings.soTextBackgroundOpacity = value
                        }
                        QQC2.Label { text: Math.round(settings.soTextBackgroundOpacity*100) + "%"; color: "white" }
                    }
                    RowLayout {
                        visible: settings.logoMode === "text"
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Elegir imagen/GIF de fondo…"
                            onClicked: textBackgroundFileDialog.open()
                        }
                        QQC2.Button {
                            text: "Sin imagen de fondo"
                            visible: settings.soTextBackgroundImage.length > 0
                            onClicked: settings.soTextBackgroundImage = ""
                        }
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
                    ColumnLayout {
                        visible: settings.logoMode !== "text"
                        Layout.fillWidth: true
                        spacing: 9
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
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 9
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
                                clockFontPicker.selectedFont = Qt.font({
                                    family: settings.clockFontFamily,
                                    pixelSize: settings.clockFontSize
                                })
                                clockFontPicker.open()
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
                                clockColorPicker.selectedColor = settings.clockTextColor
                                clockColorPicker.open()
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
                    }

                        // Debajo de TODOS los controles del logo aparecen los efectos.
            // Efectos luminosos en la misma página, debajo de logo/texto/reloj.
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                QQC2.Label { id: soLightSectionTitle; text: "Efectos luminosos del botón SO"; color: "white"; font.bold: true }
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
                            text: settings.logoMode === "text" ? settings.soTextLabel : "SO"
                            customTextMode: settings.logoMode === "text"
                            customTextColor: settings.soTextColor
                            customTextBackground: settings.soTextBackground
                            customTextBackgroundOpacity: settings.soTextBackgroundOpacity
                            customTextFontFamily: settings.soTextFontFamily
                            customTextFontSize: settings.soTextFontSize
                            customTextBold: settings.soTextBold
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
                    text: "Vista previa: la velocidad y el pulso cambian aquí al instante. Pulsá Aplicar para guardar en la barra."
                    color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: ["Brillo y respiración", "Cuándo mostrar", "Luz móvil"]
                            delegate: QQC2.Button {
                                required property int index
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                highlighted: settings.outlineSection === [2,0,1][index]
                                onClicked: { settings.outlineSection = [2,0,1][index]; settings.scrollToSoledadEffects() }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: settings.outlineSection === 0
                        Layout.fillWidth: true
                        spacing: 9
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
                    }
                    ColumnLayout {
                        visible: settings.outlineSection === 1
                        Layout.fillWidth: true
                        spacing: 9
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
                    }
                    ColumnLayout {
                        visible: settings.outlineSection === 2
                        Layout.fillWidth: true
                        spacing: 9
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
                            text: "Color de la línea SO…"
                            onClicked: {
                                lightOutlineColorPicker.selectedColor = settings.accentColor
                                lightOutlineColorPicker.open()
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
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: "Brillo y respiración del botón SO"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: "La línea luminosa del botón SO tiene velocidad e intensidad propias. " +
                              "Los degradados de Soledad y Malvina mantienen su ritmo salvo que " +
                              "elijas sincronizarlos expresamente."
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        text: "VELOCIDAD DE LA RESPIRACIÓN · LÍNEA SO"
                        color: "white"
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "−"
                            onClicked: settings.setSoLineBreathingSpeed(settings.pulseSpeed - 0.1)
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Respiración de la línea SO más lenta"
                        }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.1; to: 3; stepSize: 0.1
                            value: settings.pulseSpeed
                            onMoved: settings.setSoLineBreathingSpeed(value)
                        }
                        QQC2.Button {
                            text: "+"
                            onClicked: settings.setSoLineBreathingSpeed(settings.pulseSpeed + 0.1)
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Respiración de la línea SO más rápida"
                        }
                        QQC2.Label {
                            color: "white"
                            Layout.preferredWidth: 104
                            text: settings.pulseSpeed.toFixed(1) + " ciclos/s"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        QQC2.Label {
                            text: "Duración de cada ciclo"
                            color: "white"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        QQC2.SpinBox {
                            from: 333; to: 10000; stepSize: 100
                            editable: true
                            value: Math.round(1000 / Math.max(0.1, settings.pulseSpeed))
                            onValueModified: settings.setSoLineBreathingSpeed(1000 / value)
                        }
                        QQC2.Label { text: "ms"; color: "white" }
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: "La línea SO usa su propia velocidad. Menos ciclos/s significa " +
                              "más lento. Ajustar un control activa la respiración de la línea; " +
                              "no modifica la velocidad del degradado salvo sincronización elegida."
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        text: "INTENSIDAD DEL PULSO · LÍNEA SO"
                        color: "white"
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "−"
                            onClicked: settings.setSoLineBreathingDepth(settings.pulseDepth - 0.05)
                        }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.pulseDepth
                            onMoved: settings.setSoLineBreathingDepth(value)
                        }
                        QQC2.Button {
                            text: "+"
                            onClicked: settings.setSoLineBreathingDepth(settings.pulseDepth + 0.05)
                        }
                        QQC2.Label {
                            color: "white"
                            Layout.preferredWidth: 62
                            text: Math.round(settings.pulseDepth * 100) + "%"
                        }
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: "La intensidad del pulso es cuánto varía el brillo de la línea. " +
                              "No es la opacidad de la isla ni el color del degradado."
                    }
                    QQC2.CheckBox {
                        Layout.fillWidth: true
                        text: "Sincronizar degradado Soledad con la línea SO (ritmo e intensidad)"
                        checked: settings.soledadGradientSyncBreathing &&
                                 settings.soledadGradientSyncIntensity
                        onToggled: {
                            settings.soledadGradientSyncBreathing = checked
                            settings.soledadGradientSyncIntensity = checked
                        }
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        visible: settings.soledadGradientSyncBreathing ||
                                 settings.soledadGradientSyncIntensity
                        text: "Desvincular degradado: usar velocidad e intensidad propias"
                        onClicked: {
                            settings.soledadGradientSyncBreathing = false
                            settings.soledadGradientSyncIntensity = false
                        }
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: settings.soledadGradientSyncBreathing
                            ? (settings.soledadGradientSyncIntensity
                               ? "Soledad sigue el ritmo y la intensidad del contorno SO."
                               : "Soledad comparte solo el ritmo; su intensidad es independiente.")
                            : "El degradado tiene velocidad propia. Mover la velocidad de la línea SO no lo cambia."
                    }
                    QQC2.CheckBox {
                        Layout.fillWidth: true
                        text: "Mostrar la línea SO cuando hay ventanas abiertas"
                        checked: settings.showOutlineWhenOpen
                        onToggled: settings.showOutlineWhenOpen = checked
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#d1c8dd"
                        text: !settings.showOutlineWhenOpen
                            ? "Con ventanas abiertas, la línea se oculta según la configuración actual. " +
                              "Activá la casilla anterior si querés verla mientras probás."
                            : "La línea puede mostrarse también con ventanas abiertas."
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        visible: settings.effectStyle !== "breathe" || !settings.allowMotion
                        text: "Activar efecto Respiración luminosa en SO"
                        onClicked: {
                            settings.effectStyle = "breathe"
                            settings.allowMotion = true
                        }
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        visible: settings.effectStyle !== "breathe" || !settings.allowMotion
                        wrapMode: Text.WordWrap
                        color: "#f0cf95"
                        text: "La respiración luminosa de SO no está activa. " +
                              "Usá el botón anterior para habilitarla; " +
                              "las islas pueden respirar aunque el contorno esté apagado."
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
                            text: "Color exterior del brillo…"
                            onClicked: {
                                glowColorPicker.selectedColor = settings.glowColor
                                glowColorPicker.open()
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
                        text: "El color de la línea SO y el color exterior están en este mismo apartado; el degradado combina ambos."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.outlineUsesGlow
                        text: "Paleta de colores del contorno"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        visible: settings.outlineUsesGlow
                        Layout.fillWidth: true
                        model: ["Elegir una paleta…", "Atardecer dorado y naranja",
                                "Océano azul y celeste", "Bosque verde",
                                "Lavanda y violeta", "Neutro blanco y gris"]
                        onActivated: function(i) {
                            const palettes = [
                                null,
                                ["Atardecer", "#ffd27a", "#ff963c", "#e9c58b", "#ad623f"],
                                ["Océano", "#75d7ff", "#2563cf", "#a0d5e4", "#275d91"],
                                ["Bosque", "#a3e78d", "#2e9564", "#b1d0a0", "#38734d"],
                                ["Lavanda", "#d5b4ff", "#734cae", "#dfc8ec", "#694c91"],
                                ["Neutro", "#f8f8f6", "#848e9d", "#e7e2db", "#58616b"]
                            ]
                            if (i > 0) {
                                const p = palettes[i]
                                settings.chooseCoordinatedPalette(p[0],p[1],p[2],p[3],p[4])
                            }
                        }
                    }
                    QQC2.Button {
                        visible: settings.outlineUsesGlow && settings.logoMode !== "text"
                        text: "Analizar GIF actual para el contorno (sin tocar fondo)"
                        onClicked: paletteSamplerTarget.suggestFromImage("contour")
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Sólo prepara los colores luminosos del contorno; el degradado del fondo sigue independiente."
                    }
                    QQC2.Label {
                        visible: settings.outlineUsesGlow
                        text: settings.paletteFeedback
                        color: "#ddd6e8"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
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
                    // El usuario no necesita volver atrás para configurar el
                    // degradado del fondo: esa velocidad vive en Color y transparencia.
                    QQC2.Button {
                        Layout.fillWidth: true
                        visible: settings.outlineSection === 2
                        text: "Ir a Color y transparencia → Degradado y respiración de Soledad"
                        onClicked: settings.showSoledadGradientBreathing()
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Abrir los colores, el degradado y su velocidad en Soledad. La iluminación del botón SO es independiente."
                    }
                    }
                    QQC2.Button {
                        text: "Restablecer contorno"
                        onClicked: {
                            settings.effectStyle = "breathe"
                            settings.accentColor = "#35d7ff"
                            settings.strokeSize = 0.75
                            settings.allowMotion = true
                            settings.orbitSpeed = 1.5
                            settings.trailPercent = 75
                            settings.trailStyle = "dashed"
                            settings.glowColor = "#ffab52"
                            settings.glowIntensity = 0.7
                            settings.glowSpread = 5
                            settings.pulseSpeed = 0.3
                            settings.pulseDepth = 0.7
                            settings.glowGradient = true
                            settings.showOutlineWhenEmpty = true
                            settings.showOutlineWhenOpen = false
                        }
                    }

            }
                    }
                }
