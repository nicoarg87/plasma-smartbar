import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

// Configuración visual independiente; estado, diálogos y persistencia siguen en el centro.
QQC2.ScrollView {
    id: page
    required property var settingsTarget
    required property var baseColorDialog
    required property var sampleColorDialog
    required property var gradientColorDialog
    readonly property var settings: settingsTarget
    property alias currentTargetIndex: appearanceTarget.currentIndex
    function resetScroll() {
        if (contentItem) contentItem.contentY = 0
    }
    function scrollToBreathing() {
        if (!contentItem || !gradientBreathingTitle.visible) return
        const scroll = contentItem
        const y = gradientBreathingTitle.mapToItem(scroll.contentItem, 0, 0).y
        scroll.contentY = Math.max(0, Math.min(scroll.contentHeight - scroll.height, y - 12))
    }
                // Área desplazable local de apariencia
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.width: 16
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, page.availableWidth - 32)
                    spacing: 14
                    QQC2.Label {
                        text: settings.colorScope === "soledad"
                            ? "SOLEDAD · Color, degradado y respiración"
                            : settings.colorScope === "malvina"
                            ? "MALVINA · Color, degradado y respiración"
                            : "GENERAL · Colores compartidos"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: settings.colorScope === "shared"
                            ? "Bandeja y agarre. Las islas se editan en sus propias secciones."
                            : "Estos colores modifican únicamente " +
                              (settings.colorScope === "soledad" ? "Soledad (isla 1)." : "Malvina (isla 2).") +
                              " La otra isla conserva su estética."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    // Selector técnico oculto; solo el menú lateral define la
                    // isla. El índice 2 queda reservado para ajustes históricos y no se ofrece.
                    QQC2.ComboBox {
                        id: appearanceTarget
                        visible: false
                        model: ["Soledad (isla 1)", "Malvina (isla 2)", "Reservado",
                                "Botones de bandeja", "Botón de seis puntos (agarre)"]
                    }
                    QQC2.ComboBox {
                        visible: settings.colorScope === "shared"
                        Layout.fillWidth: true
                        model: ["Cajón de sistema (bandeja)", "Agarre de seis puntos"]
                        currentIndex: appearanceTarget.currentIndex === 4 ? 1 : 0
                        onActivated: function(index) {
                            appearanceTarget.currentIndex = index + 3
                            settings.appearanceSection = 0
                        }
                    }
                    QQC2.Button {
                        visible: settings.colorScope === "shared"
                        Layout.fillWidth: true
                        text: "Copiar colores y degradado Soledad → Malvina (una vez)"
                        onClicked: {
                            settings.malvinaColor = settings.soledadColor
                            settings.malvinaOpacity = settings.soledadOpacity
                            settings.malvinaGradientEnabled = settings.soledadGradientEnabled
                            settings.malvinaGradientEnd = settings.soledadGradientEnd
                            settings.malvinaGradientThird = settings.soledadGradientThird
                            settings.malvinaGradientColorCount = settings.soledadGradientColorCount
                            settings.malvinaGradientDirection = settings.soledadGradientDirection
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Copia una vez los tonos del fondo. No enlaza las islas " +
                                          "ni copia el contorno o la respiración. Pulsá Aplicar para guardar."
                    }
                    // Color, degradado y respiración comparten una misma
                    // página para evitar navegar entre submenús redundantes.
                    // Las dos islas ofrecen su panel flotante en el MISMO
                    // apartado Color. El modo heredado sigue activo por defecto.
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.appearanceSection === 0
                        text: "Launcher de aplicaciones · panel de Soledad"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.appearanceSection === 0
                        text: "Personalizar transparencia del launcher"
                        checked: settings.launcherOpacityOverride
                        onToggled: {
                            if (checked && !settings.launcherOpacityOverride)
                                settings.launcherOpacity = settings.soledadOpacity
                            settings.launcherOpacityOverride = checked
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.appearanceSection === 0
                        text: settings.launcherOpacityOverride
                            ? "Opacidad propia del launcher (100 % = fondo opaco)"
                            : "Hereda la opacidad de Soledad: " +
                              Math.round(settings.soledadOpacity * 100) + "%"
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex === 0 &&
                                 settings.appearanceSection === 0
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.1; to: 1; stepSize: 0.05
                            enabled: settings.launcherOpacityOverride
                            value: settings.launcherOpacityOverride
                                ? settings.launcherOpacity : settings.soledadOpacity
                            onMoved: settings.launcherOpacity = value
                        }
                        QQC2.Label {
                            color: "white"
                            text: Math.round((settings.launcherOpacityOverride
                                ? settings.launcherOpacity : settings.soledadOpacity) * 100) + "%"
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 1 &&
                                 settings.appearanceSection === 0
                        text: "Panel de opciones Web / IA (Tab)"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex === 1 &&
                                 settings.appearanceSection === 0
                        text: "Personalizar transparencia del panel Web / IA"
                        checked: settings.malvinaOptionsOpacityOverride
                        onToggled: {
                            if (checked && !settings.malvinaOptionsOpacityOverride)
                                settings.malvinaOptionsOpacity = settings.malvinaOpacity
                            settings.malvinaOptionsOpacityOverride = checked
                        }
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex === 1 &&
                                 settings.appearanceSection === 0
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.1; to: 1; stepSize: 0.05
                            enabled: settings.malvinaOptionsOpacityOverride
                            value: settings.malvinaOptionsOpacityOverride
                                ? settings.malvinaOptionsOpacity : settings.malvinaOpacity
                            onMoved: settings.malvinaOptionsOpacity = value
                        }
                        QQC2.Label {
                            color: "white"
                            text: Math.round((settings.malvinaOptionsOpacityOverride
                                ? settings.malvinaOptionsOpacity : settings.malvinaOpacity) * 100) + "%"
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 1 &&
                                 settings.appearanceSection === 0
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: settings.malvinaOptionsOpacityOverride
                            ? "Opacidad propia. Conserva los colores, el degradado y la respiración de Malvina."
                            : "Hereda la opacidad de Malvina. Activá la opción anterior para regularla por separado."
                    }
                    ColumnLayout {
                        visible: settings.appearanceSection === 0
                        Layout.fillWidth: true
                        spacing: 9
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
                    // Filas independientes: aun con DPI alto, ningún botón tapa al scrollbar.
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
                                baseColorDialog.editingTarget = appearanceTarget.currentIndex
                                baseColorDialog.selectedColor = settings.activeColor
                                baseColorDialog.open()
                            }
                        }
                    }
                    QQC2.Button {
                        visible: appearanceTarget.currentIndex === 0
                        Layout.fillWidth: true
                        text: "Abrir paleta del GIF…"
                        onClicked: {
                            settings.showSoledadGradient()
                            paletteSampler.suggestFromImage("island")
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Detecta tonos del GIF, selecciona los dos principales en esta isla y activa su degradado. No cambia la luz SO ni otra isla."
                    }
                    RowLayout {
                        visible: settings.appearanceCanEdit
                        Layout.fillWidth: true
                        QQC2.TextField {
                            id: currentColorCopyField
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            readOnly: true
                            selectByMouse: true
                            text: settings.toHex(settings.activeColor)
                        }
                        QQC2.Button {
                            text: "Copiar HEX"
                            onClicked: {
                                currentColorCopyField.selectAll()
                                currentColorCopyField.copy()
                                currentColorCopyField.deselect()
                            }
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
                    }
                    ColumnLayout {
                        visible: settings.appearanceSection === 0 &&
                                 appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        spacing: 9
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
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: "El GIF propone colores; vos decidís cuáles usar. " +
                              "La luz del botón SO no interviene. " +
                              "Cada isla conserva su propia paleta."
                    }
                    QQC2.Button {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        text: "Analizar GIF y elegir colores"
                        onClicked: paletteSampler.suggestFromImage("island")
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#cdd9e8"
                        text: settings.paletteFeedback
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Tres tonos del GIF (editables)"
                        font.bold: true
                        color: "white"
                    }
                    // Disposición responsiva: los botones y HEX quedan dentro
                    // del ancho disponible incluso a la escala mínima de KDE.
                    GridLayout {
                        visible: appearanceTarget.currentIndex <= 1 &&
                                 settings.sampledColors.length > 0
                        Layout.fillWidth: true
                        columns: page.availableWidth >= 740 ? 3
                            : (page.availableWidth >= 470 ? 2 : 1)
                        columnSpacing: 8
                        rowSpacing: 8
                        Repeater {
                            model: settings.sampledColors.length
                            delegate: ColumnLayout {
                                required property int index
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 4
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    Rectangle {
                                        width: 32; height: 24; radius: 5
                                        color: settings.sampleHex(index)
                                    }
                                    QQC2.Label {
                                        text: "Tono " + (index + 1)
                                        color: "white"
                                        Layout.fillWidth: true
                                    }
                                }
                                QQC2.TextField {
                                    id: sampleHexField
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    selectByMouse: true
                                    text: settings.sampleHex(index)
                                    onEditingFinished: settings.editSampleHex(index, text)
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    QQC2.Button {
                                        Layout.fillWidth: true
                                        text: "Copiar"
                                        onClicked: {
                                            sampleHexField.selectAll()
                                            sampleHexField.copy()
                                            sampleHexField.deselect()
                                        }
                                    }
                                    QQC2.Button {
                                        Layout.fillWidth: true
                                        text: "Editar"
                                        onClicked: {
                                            sampleColorDialog.sampleIndex = index
                                            sampleColorDialog.selectedColor =
                                                settings.sampleHex(index)
                                            sampleColorDialog.open()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        spacing: 5
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: "Colores del degradado"
                            color: "white"
                            font.bold: true
                        }
                        QQC2.ComboBox {
                            id: gradientColorCountSelector
                            Layout.fillWidth: true
                            model: ["2 colores (predeterminado)", "3 colores"]
                            currentIndex: Math.max(0, settings.activeGradientColorCount - 2)
                            onActivated: function(i) { settings.setGradientColorCount(i + 2) }
                        }
                    }
                    Repeater {
                        model: settings.activeGradientColorCount
                        delegate: ColumnLayout {
                            required property int index
                            readonly property string slotName:
                                index === 0 ? "base" : index === 1 ? "end" : "third"
                            visible: appearanceTarget.currentIndex <= 1
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                QQC2.Label {
                                    text: "Color " + (index + 1)
                                    color: "white"
                                    Layout.preferredWidth: 55
                                }
                                QQC2.ComboBox {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    model: ["Manual"].concat(settings.sampledColors.map(
                                        function(x, i) { return "Tono " + (i + 1) }))
                                    currentIndex: settings.selectedSampleIndex(slotName)
                                    onActivated: function(i) {
                                        if (i > 0) settings.chooseSampledColor(i - 1, slotName)
                                    }
                                }
                                Rectangle {
                                    width: 26; height: 25; radius: 4
                                    color: settings.islandColor(slotName)
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                QQC2.TextField {
                                    id: activeHexField
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    selectByMouse: true
                                    placeholderText: "#000000"
                                    text: settings.toHex(settings.islandColor(slotName))
                                    onEditingFinished: settings.setIslandHex(slotName, text)
                                }
                                QQC2.Button {
                                    text: "Copiar"
                                    onClicked: {
                                        activeHexField.selectAll()
                                        activeHexField.copy()
                                        activeHexField.deselect()
                                    }
                                }
                                QQC2.Button {
                                    text: "Editar"
                                    onClicked: {
                                        gradientColorDialog.targetIsland =
                                            appearanceTarget.currentIndex
                                        gradientColorDialog.slotName = slotName
                                        gradientColorDialog.selectedColor =
                                            settings.islandColor(slotName)
                                        gradientColorDialog.open()
                                    }
                                }
                            }
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Vista previa del degradado (100 % de color)"
                        color: "white"
                        font.bold: true
                    }
                    Rectangle {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 8
                        color: settings.islandColor("base")
                        gradient: Gradient {
                            orientation: settings.activeGradientDirection === "leftRight" ||
                                         settings.activeGradientDirection === "rightLeft"
                                ? Gradient.Horizontal : Gradient.Vertical
                            GradientStop {
                                position: 0
                                color: settings.gradientPreviewStop(0)
                            }
                            GradientStop {
                                position: settings.activeGradientColorCount === 3 ? 0.5 : 1
                                color: settings.gradientPreviewStop(1)
                            }
                            GradientStop {
                                position: 1
                                color: settings.gradientPreviewStop(2)
                            }
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: "Al analizar: colores 1+2 y degradado activo por defecto. " +
                              "Podés elegir 1+3, 2+3, agregar el tercer color o escribir " +
                              "cualquier HEX. Aplicar guarda el resultado. " +
                              "La opacidad real de la isla puede reducir el contraste."
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
                    // La respiración es parte del degradado. Una casilla
                    // habilita el efecto y otra controla si comparte la fase
                    // de SO o usa su propia velocidad.
                    QQC2.Label {
                        id: gradientBreathingTitle
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        text: "RESPIRACIÓN DEL FONDO Y LOS MENÚS"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Activar respiración del degradado"
                        checked: appearanceTarget.currentIndex === 0
                            ? settings.soledadGradientBreathingEnabled
                            : settings.malvinaGradientBreathingEnabled
                        onToggled: {
                            if (appearanceTarget.currentIndex === 0)
                                settings.soledadGradientBreathingEnabled = checked
                            else settings.malvinaGradientBreathingEnabled = checked
                        }
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex <= 1
                        enabled: appearanceTarget.currentIndex === 0
                            ? settings.soledadGradientBreathingEnabled
                            : settings.malvinaGradientBreathingEnabled
                        text: "Sincronizar velocidad y ritmo con la línea SO"
                        checked: appearanceTarget.currentIndex === 0
                            ? settings.soledadGradientSyncBreathing
                            : settings.malvinaGradientSyncBreathing
                        onToggled: {
                            if (appearanceTarget.currentIndex === 0) {
                                settings.soledadGradientSyncBreathing = checked
                                if (!checked) settings.soledadGradientSyncIntensity = false
                            } else {
                                settings.malvinaGradientSyncBreathing = checked
                            }
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: (appearanceTarget.currentIndex === 0
                               ? settings.soledadGradientSyncBreathing
                               : settings.malvinaGradientSyncBreathing)
                            ? "El fondo comparte fase y velocidad con la línea SO. " +
                              "La intensidad solo se iguala en Soledad si activás la opción siguiente."
                            : "El degradado usa su propia velocidad: cambiar la velocidad de " +
                              "la línea luminosa SO no lo modifica."
                    }
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex === 0
                        Layout.fillWidth: true
                        text: "Igualar intensidad a la línea luminosa SO (también sincroniza ritmo)"
                        enabled: settings.soledadGradientBreathingEnabled
                        checked: settings.soledadGradientSyncIntensity
                        onToggled: {
                            settings.soledadGradientSyncIntensity = checked
                            if (checked) settings.soledadGradientSyncBreathing = true
                        }
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        enabled: (appearanceTarget.currentIndex === 0
                            ? settings.soledadGradientBreathingEnabled &&
                              !settings.soledadGradientSyncIntensity
                            : settings.malvinaGradientBreathingEnabled)
                        QQC2.Label { text: "Intensidad"; color: "white" }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: appearanceTarget.currentIndex === 0
                                ? (settings.soledadGradientSyncIntensity
                                    ? settings.pulseDepth : settings.soledadGradientBreathingIntensity)
                                : settings.malvinaGradientBreathingIntensity
                            onMoved: {
                                if (appearanceTarget.currentIndex === 0)
                                    settings.soledadGradientBreathingIntensity = value
                                else settings.malvinaGradientBreathingIntensity = value
                            }
                        }
                        QQC2.Label {
                            text: Math.round((appearanceTarget.currentIndex === 0
                                ? (settings.soledadGradientSyncIntensity
                                    ? settings.pulseDepth : settings.soledadGradientBreathingIntensity)
                                : settings.malvinaGradientBreathingIntensity) * 100) + "%"
                            color: "white"
                            Layout.preferredWidth: 42
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        text: "VELOCIDAD PROPIA DEL DEGRADADO"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: (appearanceTarget.currentIndex === 0
                            ? settings.soledadGradientSyncBreathing
                            : settings.malvinaGradientSyncBreathing)
                            ? "Ahora está sincronizada con la línea SO (" +
                              settings.pulseSpeed.toFixed(1) + " ciclos/s). " +
                              "Mové la velocidad de abajo para usar la velocidad propia."
                            : "Velocidad propia habilitada. Los botones − y + cambian el ritmo " +
                              "de esta isla sin modificar la línea SO."
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "−"
                            onClicked: settings.setIndependentGradientSpeed(
                                appearanceTarget.currentIndex,
                                (appearanceTarget.currentIndex === 0
                                    ? settings.soledadGradientBreathingSpeed
                                    : settings.malvinaGradientBreathingSpeed) - 0.1)
                        }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.1; to: 3; stepSize: 0.1
                            value: appearanceTarget.currentIndex === 0
                                ? settings.soledadGradientBreathingSpeed
                                : settings.malvinaGradientBreathingSpeed
                            onMoved: settings.setIndependentGradientSpeed(
                                appearanceTarget.currentIndex, value)
                        }
                        QQC2.Button {
                            text: "+"
                            onClicked: settings.setIndependentGradientSpeed(
                                appearanceTarget.currentIndex,
                                (appearanceTarget.currentIndex === 0
                                    ? settings.soledadGradientBreathingSpeed
                                    : settings.malvinaGradientBreathingSpeed) + 0.1)
                        }
                        QQC2.Label {
                            color: "white"
                            Layout.preferredWidth: 105
                            text: (appearanceTarget.currentIndex === 0
                                ? settings.soledadGradientBreathingSpeed
                                : settings.malvinaGradientBreathingSpeed).toFixed(1) + " ciclos/s"
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: "La intensidad y la velocidad se ven en la isla y sus paneles " +
                              "flotantes al activar el degradado. La opacidad configurada " +
                              "sigue siendo independiente. Pulsá Aplicar para guardar."
                    }
                    QQC2.Button {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        text: "Ir a Botón de inicio SO → Efectos luminosos → Brillo y respiración"
                        onClicked: settings.showSoledadGlowBreathing()
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Ajusta el brillo del contorno SO, " +
                            "la intensidad de su pulso y su duración en milisegundos. " +
                            "Los colores de esta isla no se modifican."
                    }


                    }
                    QQC2.Button {
                        text: "Restablecer colores de esta superficie"
                        Layout.fillWidth: true
                        onClicked: settings.resetColorsForTarget(appearanceTarget.currentIndex)
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Restablece sólo la isla o botón seleccionado. " +
                                          "No cambia el GIF, el contorno luminoso ni otras islas. " +
                                          "Después de restablecer podés analizar el GIF de nuevo."
                    }
                }
            }
