import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import "ThemePack.js" as ThemePack
import "WallpaperFadeDuration.js" as WallpaperFadeDuration

// Temas y packs: vista modular. Persistencia y operaciones continúan en SoledadSettings.
QQC2.ScrollView {
    id: page
    required property var settingsTarget
    required property var imagePicker
    required property var paletteSamplerTarget
    readonly property var settings: settingsTarget
    property alias extractPaletteForNewTheme: useGifPaletteForTheme.checked
                // Área desplazable del selector de temas
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.width: 16
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, page.availableWidth - 32)
                    spacing: 12
                    QQC2.Label {
                        text: "Temas"
                        font.pixelSize: 19
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: "Pack predeterminado Playa 24hs: usá el cambio automático por horarios o elegí Día, Atardecer o Noche de forma manual. Tus temas personales siguen disponibles."
                    }
                    // Los packs usan este mismo editor horario y el selector
                    // existente; no duplicar botones de activación ni menú.
                    // Un pack personalizado copia los perfiles elegidos y no
                    // reemplaza ninguna biblioteca ni preset de fábrica.
                    // Un único desplegable. Sin tarjetas, subtítulos ni botones "Usar".
                    // Primero las instantáneas locales que el usuario ya guardó.
                    // Selector básico con Popup propio: evita el ComboBox con lista vacía.
                    QQC2.Button {
                        id: themeSelectorButton
                        Layout.fillWidth: true
                        text: (settings.selectedThemePack
                            ? settings.selectedThemePack.name +
                              (settings.themeScheduleEnabled ? " · Automático" : " · Manual")
                            : ThemePack.title(settings.themeScheduleEnabled)) +
                              (themeOptionsPopup.opened ? "  ▴" : "  ▾")
                        onClicked: {
                            if (themeOptionsPopup.opened) themeOptionsPopup.close()
                            else themeOptionsPopup.open()
                        }
                    }
                    QQC2.Popup {
                        id: themeOptionsPopup
                        parent: themeSelectorButton
                        x: 0
                        y: themeSelectorButton.height
                        width: themeSelectorButton.width
                        height: Math.min(240, 50 * (5 + settings.savedThemePacks.length +
                            (settings.selectedThemePack ? settings.selectedThemePack.members.length
                                : 3 + settings.otherNamedThemes.length)) + 8)
                        padding: 4
                        modal: false
                        focus: true
                        // Clic repetido en botón padre NO debe cerrar popup antes de onClicked.
                        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent
                        background: Rectangle {
                            color: "#252b38"
                            border.color: "#63778e"
                            radius: 5
                        }
                        contentItem: Flickable {
                            clip: true
                            contentWidth: width
                            contentHeight: themeOptionsColumn.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds
                            QQC2.ScrollBar.vertical: QQC2.ScrollBar {
                                policy: QQC2.ScrollBar.AsNeeded
                            }
                            Column {
                                id: themeOptionsColumn
                                width: parent.width
                                spacing: 2
                                QQC2.ItemDelegate {
                                    width: themeOptionsColumn.width
                                    height: 48
                                    text: "Pack · Playa 24hs" +
                                        (settings.selectedThemePackId === ThemePack.DEFAULT_ID
                                            ? " ✓" : "")
                                    onClicked: {
                                        themeOptionsPopup.close()
                                        settings.selectThemePack(ThemePack.DEFAULT_ID)
                                    }
                                }
                                Repeater {
                                    model: settings.savedThemePacks
                                    delegate: QQC2.ItemDelegate {
                                        required property var modelData
                                        width: themeOptionsColumn.width
                                        height: 48
                                        text: "Pack · " + modelData.name +
                                            (settings.selectedThemePackId === modelData.id ? " ✓" : "")
                                        onClicked: {
                                            themeOptionsPopup.close()
                                            settings.selectThemePack(modelData.id)
                                        }
                                    }
                                }
                                // Elegir modo automático para el pack activo.
                                QQC2.ItemDelegate {
                                    id: playa24AutoChoice
                                    width: themeOptionsColumn.width
                                    height: 48
                                    text: (settings.selectedThemePack
                                        ? settings.selectedThemePack.name : ThemePack.NAME) +
                                        " · automático por horarios"
                                    font.bold: settings.themeScheduleEnabled
                                    onClicked: {
                                        themeOptionsPopup.close()
                                        settings.setScheduleEnabled(true)
                                        settings.packOptionsVisible = true
                                        settings.scheduleMenuExpanded = true
                                        settings.themeStatus = "Pack: cambio automático por horarios activado."
                                    }
                                }
                                Repeater {
                                    model: settings.selectedThemePack ? 0 :
                                        3 + settings.otherNamedThemes.length
                                    delegate: QQC2.ItemDelegate {
                                        required property int index
                                        width: themeOptionsColumn.width
                                        height: 48
                                        contentItem: RowLayout {
                                            spacing: 10
                                            AnimatedImage {
                                                Layout.preferredWidth: 58
                                                Layout.preferredHeight: 38
                                                fillMode: Image.PreserveAspectFit
                                                playing: visible
                                                source: index === 0
                                                    ? (settings.themeDayJson.length
                                                        ? settings.themeImageSource(settings.themeDayJson)
                                                        : settings.factorySunsetImage)
                                                    : index === 1
                                                      ? (settings.themeNightJson.length
                                                          ? settings.themeImageSource(settings.themeNightJson)
                                                          : settings.factoryNightImage)
                                                      : index === 2
                                                        ? (settings.factoryDayAvailable ? settings.factoryDayImage
                                                            : settings.dayThemeIndex() >= 0
                                                              ? settings.themeImageSource(settings.savedThemeLibrary[settings.dayThemeIndex()].jsonData)
                                                              : "")
                                                        : settings.themeImageSource(settings.savedThemeLibrary[settings.otherNamedThemeOriginalIndex(index - 3)].jsonData)
                                            }
                                            QQC2.Label {
                                                Layout.fillWidth: true
                                                color: "white"
                                                text: index === 0 ? "Atardecer" :
                                                      index === 1 ? "Noche" :
                                                      index === 2 ? "Día" :
                                                      settings.savedThemeLibrary[settings.otherNamedThemeOriginalIndex(index - 3)].name
                                            }
                                        }
                                        onClicked: {
                                            const selectedIndex = index
                                            themeOptionsPopup.close()
                                            let slot = ""
                                            if (selectedIndex === 0) {
                                                slot = settings.resolvePackPreset("sunset")
                                            } else if (selectedIndex === 1) {
                                                slot = settings.themeNightJson.length ? "nightLegacy" :
                                                    (settings.factoryNightAvailable ? "night" : "")
                                            } else if (selectedIndex === 2) {
                                                if (settings.factoryDayAvailable) slot = "dayOfficial"
                                                else {
                                                    const savedDayIndex = settings.dayThemeIndex()
                                                    if (savedDayIndex >= 0) slot = "library:" + savedDayIndex
                                                }
                                            } else {
                                                const originalIndex = settings.otherNamedThemeOriginalIndex(selectedIndex - 3)
                                                if (originalIndex >= 0) slot = "library:" + originalIndex
                                            }
                                            if (slot.length && settings.activateTheme(slot)) {
                                                settings.packOptionsVisible = false
                                                settings.scheduleMenuExpanded = false
                                                settings.previewFactorySlot = ""
                                                // La elección individual del pack es MANUAL:
                                                // suspender el reloj solo si el tema se aplicó.
                                                if (selectedIndex < 3)
                                                    settings.setScheduleEnabled(false)
                                                if (selectedIndex === 0) settings.wallpaperThemeSelected("sunset")
                                                else if (selectedIndex === 1) settings.wallpaperThemeSelected("night")
                                                else if (selectedIndex === 2) settings.wallpaperThemeSelected("day")
                                            } else {
                                                settings.themeStatus = selectedIndex === 0
                                                    ? "No se encuentra el Atardecer guardado."
                                                    : selectedIndex === 1
                                                      ? "No se encuentra la Noche guardada."
                                                       : "El tema Día todavía no tiene una configuración disponible."
                                            }
                                        }
                                    }
                                }
                                // Opciones MANUALES del pack personal seleccionado.
                                Repeater {
                                    model: settings.selectedThemePack
                                        ? settings.selectedThemePack.members : []
                                    delegate: QQC2.ItemDelegate {
                                        required property var modelData
                                        required property int index
                                        width: themeOptionsColumn.width
                                        height: 48
                                        text: modelData.name
                                        onClicked: {
                                            themeOptionsPopup.close()
                                            settings.activatePackMember(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Fin del selector de temas y packs.
                    // Submenú del pack, oculto hasta que el usuario elige
                    // explícitamente un pack en el selector superior.
                    RowLayout {
                        Layout.fillWidth: true
                        visible: settings.packOptionsVisible
                        spacing: 8
                        QQC2.CheckBox {
                            Layout.fillWidth: true
                            text: "Activar wallpaper temático"
                            checked: settings.thematicWallpaperEnabled
                            onClicked: {
                                settings.thematicWallpaperEnabled = checked
                                settings.thematicWallpaperVisibilityRequested(checked)
                            }
                        }
                        QQC2.ToolButton {
                            id: scheduleMenuButton
                            text: "Con horarios " + (settings.scheduleMenuExpanded ? "▴" : "▾")
                            onClicked: settings.scheduleMenuExpanded = !settings.scheduleMenuExpanded
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Mostrar u ocultar la programación horaria"
                        }
                    }
                    // Ajustes agrupados en un desplegable; la programación
                    // sigue funcionando aun cuando este menú esté contraído.
                    ColumnLayout {
                        id: themeScheduleMenu
                        Layout.fillWidth: true
                        visible: settings.scheduleMenuExpanded && settings.packOptionsVisible
                        spacing: 10
                        // Duración independiente de las franjas horarias.
                        // El fundido también se usa al elegir un tema a mano.
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            QQC2.Label {
                                text: "Fundido del wallpaper"
                                color: "#cdd8e8"
                                Layout.fillWidth: true
                            }
                            QQC2.TextField {
                                id: wallpaperFadeAmountField
                                Layout.preferredWidth: 76
                                maximumLength: 4
                                horizontalAlignment: Text.AlignHCenter
                                validator: IntValidator { bottom: 1; top: 3600 }
                                text: String(settings.wallpaperFadeAmount)
                                onEditingFinished: {
                                    const amount = Number(text)
                                    if (!settings.setWallpaperFade(amount,settings.wallpaperFadeUnit))
                                        text = String(settings.wallpaperFadeAmount)
                                }
                            }
                            QQC2.ComboBox {
                                id: wallpaperFadeUnitSelector
                                Layout.preferredWidth: 128
                                model: ["Segundos", "Minutos", "Horas"]
                                currentIndex: settings.wallpaperFadeUnit === "minutes" ? 1
                                    : settings.wallpaperFadeUnit === "hours" ? 2 : 0
                                onActivated: function(index) {
                                    const unit = ["seconds", "minutes", "hours"][index]
                                    const amount = Number(wallpaperFadeAmountField.text)
                                    if (!settings.setWallpaperFade(amount, unit)) {
                                        // Ante un número fuera del rango de la nueva unidad,
                                        // ajustar al límite permitido sin borrar preferencias previas.
                                        const limit = WallpaperFadeDuration.limits[unit]
                                        settings.setWallpaperFade(Math.max(1, Math.min(limit, settings.wallpaperFadeAmount)),unit)
                                    }
                                    wallpaperFadeAmountField.text = String(settings.wallpaperFadeAmount)
                                }
                            }
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#b7c7d9"
                            text: "Duración por transición (3 segundos inicialmente), tanto en horario automático como al elegir un tema o probar el fondo."
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            visible: settings.wallpaperFadeError.length > 0
                            color: "#ffbba5"
                            text: settings.wallpaperFadeError
                        }
                        QQC2.CheckBox {
                            Layout.fillWidth: true
                            text: "Transición suave de las islas"
                            checked: settings.barThemeTransitionEnabled
                            onToggled: {
                                settings.barThemeTransitionEnabled = checked
                                settings.saveBarThemeTransitionRequested(checked)
                            }
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#b7c7d9"
                            text: "Usa el mismo tiempo del fundido del wallpaper para los colores y contornos de Soledad y Malvina. Se puede desactivar sin modificar los temas."
                        }
                        // Cuatro franjas diarias de fábrica; tres como alternativa.
                        // No hay botones para aplicar/guardar horarios: cada valor válido persiste.
                        QQC2.Label {
                            Layout.fillWidth: true
                            text: "Cambio automático por horario"
                            color: "white"
                            font.bold: true
                        }
                        QQC2.CheckBox {
                            Layout.fillWidth: true
                            text: "Activar cambio automático de tema"
                            checked: settings.themeScheduleEnabled
                            onToggled: settings.setScheduleEnabled(checked)
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            QQC2.Label {
                                text: "Franjas horarias"
                                color: "#cdd8e8"
                                Layout.fillWidth: true
                            }
                            QQC2.ComboBox {
                                id: scheduleCountSelector
                                Layout.preferredWidth: 150
                                model: ["3 franjas", "4 franjas"]
                                currentIndex: settings.themeScheduleSlotCount === 3 ? 0 : 1
                                onActivated: function(index) {
                                    settings.setScheduleSlotCount(index === 0 ? 3 : 4)
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Repeater {
                                // Al cambiar de pack recrear las filas con los datos
                                // guardados, no reutilizar ComboBox del pack anterior.
                                model: settings.scheduleSlots
                                delegate: RowLayout {
                                    required property int index
                                    Layout.fillWidth: true
                                    spacing: 7
                                    QQC2.Label {
                                        text: String(index + 1) + "."
                                        color: "#bac9db"
                                        Layout.preferredWidth: 21
                                    }
                                    QQC2.TextField {
                                        Layout.preferredWidth: 78
                                        maximumLength: 5
                                        horizontalAlignment: Text.AlignHCenter
                                        text: settings.scheduleStart(index)
                                        onEditingFinished: {
                                            if (!settings.updateScheduleBoundary(index, "start", text))
                                                text = Qt.binding(function() { return settings.scheduleStart(index) })
                                        }
                                    }
                                    QQC2.Label {
                                        text: "a"
                                        color: "#cad7e8"
                                    }
                                    QQC2.TextField {
                                        Layout.preferredWidth: 78
                                        maximumLength: 5
                                        horizontalAlignment: Text.AlignHCenter
                                        text: settings.scheduleEnd(index)
                                        onEditingFinished: {
                                            if (!settings.updateScheduleBoundary(index, "end", text))
                                                text = Qt.binding(function() { return settings.scheduleEnd(index) })
                                        }
                                    }
                                    QQC2.ComboBox {
                                        Layout.fillWidth: true
                                        readonly property var themeChoices: settings.selectedThemePack
                                            ? ThemePack.labels(settings.selectedThemePack)
                                            : ["Día", "Atardecer", "Noche"]
                                        readonly property int savedThemeIndex: settings.selectedThemePack
                                            ? settings.scheduleTheme(index)
                                            : settings.scheduleTheme(index) === "day" ? 0
                                              : settings.scheduleTheme(index) === "sunset" ? 1
                                                : settings.scheduleTheme(index) === "night" ? 2 : -1
                                        model: themeChoices
                                        currentIndex: savedThemeIndex
                                        // El modelo de QQC2.ComboBox puede reiniciar su índice
                                        // a cero al cambiar entre packs. Mostrar SIEMPRE el
                                        // valor persistido; no sustituirlo por "Día".
                                        displayText: savedThemeIndex >= 0 &&
                                            savedThemeIndex < themeChoices.length
                                            ? themeChoices[savedThemeIndex] : "Tema no disponible"
                                        onActivated: function(i) {
                                            settings.updateScheduleTheme(index,
                                                settings.selectedThemePack ? i :
                                                ["day", "sunset", "night"][i])
                                        }
                                    }
                                }
                            }
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#b7c7d9"
                            text: "Horario local del equipo, todos los días. El fin de cada franja es el inicio de la siguiente; la última cruza medianoche si corresponde. Los horarios de 3 y 4 franjas se conservan por separado."
                        }
                        QQC2.Label {
                            visible: settings.scheduleError.length > 0
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#ffbba5"
                            text: settings.scheduleError
                        }
                    }
                    // Vista previa principal del tema seleccionado, independiente de la lista.
                    QQC2.Label {
                        text: "Vista previa del tema"
                        color: "white"
                        font.bold: true
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 172
                        radius: 10
                        color: "#222938"
                        border.color: "#54637a"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 18
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 6
                                QQC2.Label {
                                    text: settings.previewFactorySlot === "dayOfficial" ? "Día" :
                                          (settings.previewFactorySlot === "sunset" || settings.previewFactorySlot === "day") ? "Atardecer" :
                                          (settings.previewFactorySlot === "night" || settings.previewFactorySlot === "nightLegacy") ? "Noche" : "Tema actual"
                                    color: "white"
                                    font.bold: true
                                }
                                QQC2.Label {
                                    text: "Motivo / GIF del botón SO"
                                    color: "#b9cce2"
                                }
                                AnimatedImage {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    source: settings.previewFactorySlot === "sunset"
                                        ? settings.factorySunsetImage
                                        : settings.previewFactorySlot === "night"
                                          ? settings.factoryNightImage :
                                          settings.previewFactorySlot === "day" ? settings.themeImageSource(settings.themeDayJson) :
                                          settings.previewFactorySlot === "dayOfficial" ? settings.factoryDayImage :
                                          settings.previewFactorySlot === "nightLegacy" ? settings.themeImageSource(settings.themeNightJson) :
                                          settings.previewFactorySlot.indexOf("library:") === 0 ? settings.themeImageSource(settings.slotJson(settings.previewFactorySlot)) : settings.selectedImage
                                    fillMode: Image.PreserveAspectFit
                                    playing: visible
                                }
                            }
                            ColumnLayout {
                                Layout.preferredWidth: 96
                                Layout.fillHeight: true
                                QQC2.Label {
                                    text: "Botón SO"
                                    color: "#b9cce2"
                                }
                                AnimatedImage {
                                    Layout.preferredWidth: 72
                                    Layout.preferredHeight: 48
                                    source: settings.previewFactorySlot === "sunset"
                                        ? settings.factorySunsetImage
                                        : settings.previewFactorySlot === "night"
                                          ? settings.factoryNightImage :
                                          settings.previewFactorySlot === "day" ? settings.themeImageSource(settings.themeDayJson) :
                                          settings.previewFactorySlot === "dayOfficial" ? settings.factoryDayImage :
                                          settings.previewFactorySlot === "nightLegacy" ? settings.themeImageSource(settings.themeNightJson) :
                                          settings.previewFactorySlot.indexOf("library:") === 0 ? settings.themeImageSource(settings.slotJson(settings.previewFactorySlot)) : settings.selectedImage
                                    fillMode: Image.PreserveAspectFit
                                    playing: visible
                                }
                                QQC2.Label {
                                    text: "Degradado"
                                    color: "#b9cce2"
                                }
                                Rectangle {
                                    Layout.preferredWidth: 46
                                    Layout.fillHeight: true
                                    radius: 6
                                    gradient: Gradient {
                                        GradientStop {
                                            position: 0
                                            color: settings.previewGradientColor(0)
                                        }
                                        GradientStop {
                                            position: 0.5
                                            color: settings.previewGradientColor(1)
                                        }
                                        GradientStop {
                                            position: 1
                                            color: settings.previewGradientColor(2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Crear tema nuevo"
                        onClicked: {
                            settings.previewFactorySlot = ""
                            settings.creatingNewTheme = !settings.creatingNewTheme
                            settings.themeChooserExpanded = false
                        }
                    }
                    ColumnLayout {
                        visible: settings.creatingNewTheme
                        Layout.fillWidth: true
                        spacing: 8
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: "Añadir una foto o GIF…"
                            onClicked: imagePicker.open()
                        }
                        QQC2.CheckBox {
                            id: useGifPaletteForTheme
                            text: "Usar colores del GIF para todo el tema"
                            checked: false
                            onToggled: {
                                if (checked && settings.logoMode === "custom")
                                    paletteSamplerTarget.suggestFromImage("theme")
                            }
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#b9cce2"
                            text: settings.paletteFeedback
                        }
                        QQC2.Button {
                            text: "Aplicar sin guardar tema"
                            onClicked: settings.applyChanges()
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            QQC2.TextField {
                                Layout.fillWidth: true
                                placeholderText: "Nombre del tema nuevo"
                                text: settings.newThemeName
                                onTextEdited: settings.newThemeName = text
                            }
                            QQC2.Button {
                                text: "Guardar tema"
                                onClicked: settings.saveNamedTheme()
                            }
                        }
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Crear pack personalizado"
                        onClicked: {
                            settings.creatingNewPack = !settings.creatingNewPack
                            settings.creatingNewTheme = false
                        }
                    }
                    ColumnLayout {
                        visible: settings.creatingNewPack
                        Layout.fillWidth: true
                        spacing: 8
                        QQC2.TextField {
                            Layout.fillWidth: true
                            placeholderText: "Nombre del pack"
                            text: settings.newPackName
                            onTextEdited: settings.newPackName = text
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            color: "#b7c7d9"
                            wrapMode: Text.WordWrap
                            text: "Elegí los temas que integrarán el pack. Podrás configurar sus franjas horarias o seleccionarlos individualmente."
                        }
                        Repeater {
                            // Instanciar controles de hasta 200 temas solo al crear pack.
                            model: settings.creatingNewPack ? settings.packCandidateItems : []
                            delegate: QQC2.CheckBox {
                                required property int index
                                required property var modelData
                                Layout.fillWidth: true
                                text: modelData.name
                                checked: settings.pendingPackMemberIndexes.indexOf(index) >= 0
                                onToggled: settings.togglePackCandidate(index, checked)
                            }
                        }
                        QQC2.Button {
                            text: "Guardar pack"
                            onClicked: settings.createPersonalPack()
                        }
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        text: settings.themeStatus
                        color: "#b9e5ff"
                        wrapMode: Text.WordWrap
                    }
                }
            }
