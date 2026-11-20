// Centro unificado de configuracion de Soledad (prototipo Qt 6).
// Las pestañas comparten una ventana. Aplicar guarda y NO cierra.
// Cada pestaña tiene desplazamiento vertical para pantallas reducidas.
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import "PaletteExtractor.js" as PaletteExtractor
import "ThemeSchedule.js" as ThemeSchedule
import "assets/FactoryNightTheme.js" as FactoryNightTheme
import "assets/FactorySunsetTheme.js" as FactorySunsetTheme
import "assets/FactoryDayTheme.js" as FactoryDayTheme

Window {
    id: settings
    visible: false
    flags: Qt.Dialog
    title: "Configuraciones"
    color: "#242236"

    // Más ancho para que los botones HEX y el scroll nunca se superpongan.
    // Si la pantalla es pequeña, las pestañas permiten desplazamiento.
    width: Screen.desktopAvailableWidth > 0
        ? Math.min(1180, Math.max(560, Screen.desktopAvailableWidth - 48)) : 1100
    height: Screen.desktopAvailableHeight > 0
        ? Math.min(850, Math.max(510, Screen.desktopAvailableHeight - 64)) : 850
    minimumWidth: Screen.desktopAvailableWidth > 0
        ? Math.min(850, Math.max(560, Screen.desktopAvailableWidth - 48)) : 850
    minimumHeight: 510

    // Copia de las preferencias de la sesión: «Cancelar» y la X revierten
    // solo cambios sin aplicar. «Aplicar» actualiza el punto de recuperación.
    readonly property var editableSettingsKeys: ["logoMode","themeDayJson","themeDayPreviousJson","themeNightJson","themeCustomJson","themeLibraryJson","filePath","shape","cropFitMode","cropZoom","cropPanX","cropPanY","cropRotation","enableGif","clockFontFamily","clockFontSize","clockTextColor","panelHeight","soledadHeight","malvinaHeight","soledadRadius","malvinaRadius","soledadMinWidth","malvinaWidth","malvinaGoogleUrl","malvinaDuckUrl","malvinaYahooUrl","malvinaChatGptUrl","malvinaGeminiUrl","malvinaClaudeUrl","malvinaWebFirst","malvinaWebOrder","malvinaAiOrder","malvinaExtraWeb","malvinaExtraAi","malvinaHiddenWeb","malvinaHiddenAi","malvinaCompactAi","malvinaGoogleName","malvinaDuckName","malvinaYahooName","malvinaChatGptName","malvinaGeminiName","malvinaClaudeName","malvinaWebGoogleEnabled","malvinaWebDuckEnabled","malvinaWebYahooEnabled","malvinaAllowChatGpt","malvinaAllowGemini","malvinaAllowClaude","soledadShape","malvinaShape","malvinaGearButtonShape","malvinaSearchButtonShape","outlineConfig","taskActiveGlowEnabled","taskActiveDoubleBorderEnabled","taskDisplayMode","taskFrameShape","taskFrameColor","taskFrameOpacity","taskFrameWidth","gripShape","trayButtonShape","soButtonFrameShape","soButtonWidth","soTextLabel","soTextColor","soTextBackground","soTextBackgroundOpacity","soTextFontFamily","soTextFontSize","soTextBold","soTextBackgroundImage","soledadColor","malvinaColor","soledadGradientEnabled","soledadGradientEnd","soledadGradientThird","soledadGradientColorCount","soledadGradientDirection","soledadGradientSyncBreathing","soledadGradientSyncIntensity","soledadGradientBreathingEnabled","soledadGradientBreathingIntensity","soledadGradientBreathingSpeed","malvinaGradientSyncBreathing","malvinaGradientBreathingEnabled","malvinaGradientBreathingIntensity","malvinaGradientBreathingSpeed","malvinaGradientEnabled","malvinaGradientEnd","malvinaGradientThird","malvinaGradientColorCount","malvinaGradientDirection","backgroundColor","soledadOpacity","malvinaOpacity","backgroundOpacity","showBackground","trayButtonColorOverride","trayButtonColor","trayButtonOpacity","gripButtonColorOverride","gripButtonColor","gripButtonOpacity","effectStyle","accentColor","strokeSize","allowMotion","orbitSpeed","trailPercent","trailStyle","glowColor","glowIntensity","glowSpread","pulseSpeed","pulseDepth","glowGradient","showOutlineWhenEmpty","showOutlineWhenOpen","autoCollapseSO","soLeftClickOpensLauncher","launcherCategoryLayout","launcherSwitchShape","launcherSwitchColorOverride","launcherSwitchColor","launcherMaxSlots","launcherOpacityOverride","launcherOpacity","launcherIconsWithNames","malvinaOptionsOpacityOverride","malvinaOptionsOpacity","autoCollapseTray","autoReturnRight","launcherIslandVisible","autoHideMalvina","alignedRight","positionMode","alignmentEdited"]
    readonly property var editableColorKeys: ["soTextColor","soTextBackground","clockTextColor","soledadColor","malvinaColor","soledadGradientEnd","soledadGradientThird","malvinaGradientEnd","malvinaGradientThird","backgroundColor","trayButtonColor","gripButtonColor","accentColor","glowColor","launcherSwitchColor","taskFrameColor"]
    property var lastAppliedSettings: ({})
    property var pendingThemeChanges: ({})
    property bool baselineLoaded: false
    property string pendingAlignAction: ""
    function preferenceCopy(key, value) {
        if (value === undefined || value === null) return value
        if (editableColorKeys.indexOf(key) !== -1) return String(value)
        if (typeof value === "object") return JSON.parse(JSON.stringify(value))
        return value
    }
    function captureSettingsBaseline() {
        const snapshot = {}
        for (let i = 0; i < editableSettingsKeys.length; ++i) {
            const key = editableSettingsKeys[i]
            snapshot[key] = preferenceCopy(key, settings[key])
        }
        lastAppliedSettings = snapshot
        baselineLoaded = true
        pendingThemeChanges = ({})
        pendingAlignAction = ""
    }
    function stageThemeSlot(slot, data) {
        const next = JSON.parse(JSON.stringify(pendingThemeChanges))
        next[slot] = data
        pendingThemeChanges = next
    }
    function discardPendingEdits() {
        if (!baselineLoaded) return
        for (let i = 0; i < editableSettingsKeys.length; ++i) {
            const key = editableSettingsKeys[i]
            if (lastAppliedSettings[key] !== undefined)
                settings[key] = preferenceCopy(key, lastAppliedSettings[key])
        }
        pendingThemeChanges = ({})
        pendingAlignAction = ""
        alignmentEdited = false
        baselineLoaded = false
        refreshOutlinePreview()
        appliedLabel.text = ""
    }
    onClosing: function(event) { themeChooserExpanded = false; scheduleMenuExpanded = false; factoryToolsExpanded = false; discardPendingEdits() }

    // Secciones de geometría reducidas para que entren en la ventana de configuración.
    property int geometrySection: 0
    property int outlineSection: 2
    property int appearanceSection: 0
    // El menú lateral decide el destino. Dentro de Soledad o Malvina no
    // existe selector para saltar a controles de la otra isla.
    property string geometryScope: "shared"
    property string behaviorScope: "shared"
    property string colorScope: "soledad"
    property string navigationGroup: "themes"
    // Claves históricas de Atardecer: NO son el tema de fábrica. Se conservan
    // sin migraciones ni reemplazos y quedan apartadas de los futuros temas Día.
    property string themeDayJson: ""
    // Respaldo recuperable del Atardecer previo; conservar la clave histórica.
    property string themeDayPreviousJson: ""
    property string themeNightJson: ""
    property string themeCustomJson: ""
    // Colección local extensible. No sustituye las ranuras históricas ni
    // los temas originales de fábrica, que permanecen protegidos.
    property string themeLibraryJson: "[]"
    property bool personalDefaultAvailable: false
    property bool favoriteAppearanceAvailable: false
    signal restorePersonalDefaultRequested()
    signal restoreFavoriteAppearanceRequested()
    function restoreExistingLocalTheme(kind) {
        // El visor conserva el preset personal y la estética favorita en
        // su Qt Settings histórica; pedirle restaurarla sin regrabarla.
        settings.close()
        if (kind === "personal") restorePersonalDefaultRequested()
        else if (kind === "favorite") restoreFavoriteAppearanceRequested()
    }
    // La selección visual no modifica ninguna instantánea guardada.
    property string previewFactorySlot: ""
    property bool creatingNewTheme: false
    function previewGradientColor(index) {
        let data = null
        try {
            const json = previewFactorySlot === "sunset" ? factorySunsetJson :
                         previewFactorySlot === "night" ? factoryNightJson :
                         previewFactorySlot === "day" ? themeDayJson :
                         previewFactorySlot === "dayOfficial" ? factoryDayJson :
                         previewFactorySlot === "nightLegacy" ? themeNightJson :
                         previewFactorySlot.indexOf("library:") === 0 ? slotJson(previewFactorySlot) : ""
            if (json.length) data = JSON.parse(json)
        } catch (error) { data = null }
        const base = data || {
            soledadColor: toHex(soledadColor),
            soledadGradientEnd: toHex(soledadGradientEnd),
            soledadGradientThird: toHex(soledadGradientThird)
        }
        return index === 0 ? (base.soledadColor || "#46516a") :
               index === 1 ? (base.soledadGradientEnd || base.soledadColor || "#46516a") :
               (base.soledadGradientThird || base.soledadGradientEnd || "#46516a")
    }
    // Programación diaria: opción personal, independiente de los temas inmutables.
    property bool scheduleMenuExpanded: false
    property bool themeScheduleEnabled: true
    property int themeScheduleSlotCount: 4
    property string themeScheduleSlots3Json:
        ThemeSchedule.serialize(ThemeSchedule.defaults(3), 3)
    property string themeScheduleSlots4Json:
        ThemeSchedule.serialize(ThemeSchedule.defaults(4), 4)
    property string scheduleError: ""
    readonly property var scheduleSlots: ThemeSchedule.read(
        themeScheduleSlotCount === 3 ? themeScheduleSlots3Json : themeScheduleSlots4Json,
        themeScheduleSlotCount)
    function scheduleStart(index) {
        return index >= 0 && index < scheduleSlots.length ? scheduleSlots[index].start : ""
    }
    function scheduleEnd(index) {
        return index >= 0 && index < scheduleSlots.length
            ? scheduleSlots[(index + 1) % scheduleSlots.length].start : ""
    }
    function scheduleTheme(index) {
        return index >= 0 && index < scheduleSlots.length ? scheduleSlots[index].theme : ""
    }
    function persistThemeSchedule() {
        saveThemeScheduleRequested(themeScheduleEnabled, themeScheduleSlotCount,
                                   themeScheduleSlots3Json, themeScheduleSlots4Json)
    }
    function setScheduleEnabled(enabled) {
        themeScheduleEnabled = enabled
        scheduleError = ""
        persistThemeSchedule()
    }
    function setScheduleSlotCount(count) {
        if (count !== 3 && count !== 4) return
        themeScheduleSlotCount = count
        scheduleError = ""
        persistThemeSchedule()
    }
    function updateScheduleBoundary(index, boundary, text) {
        const updated = ThemeSchedule.withBoundary(scheduleSlots, index, boundary, text.trim())
        if (!updated) {
            scheduleError = "Hora inválida (HH:MM) o límites fuera de orden. No se guardó ese cambio."
            return false
        }
        const json = ThemeSchedule.serialize(updated, themeScheduleSlotCount)
        if (themeScheduleSlotCount === 3) themeScheduleSlots3Json = json
        else themeScheduleSlots4Json = json
        scheduleError = ""
        persistThemeSchedule()
        return true
    }
    function updateScheduleTheme(index, theme) {
        const updated = ThemeSchedule.withTheme(scheduleSlots, index, theme)
        if (!updated) return
        const json = ThemeSchedule.serialize(updated, themeScheduleSlotCount)
        if (themeScheduleSlotCount === 3) themeScheduleSlots3Json = json
        else themeScheduleSlots4Json = json
        scheduleError = ""
        persistThemeSchedule()
    }

    property bool thematicWallpaperEnabled: true
    property bool themeChooserExpanded: false
    property bool factoryToolsExpanded: false
    property string newThemeName: ""
    readonly property var savedThemeLibrary: parseThemeLibrary(themeLibraryJson)
    function parseThemeLibrary(json) {
        try {
            const items = JSON.parse(json || "[]")
            if (!Array.isArray(items)) return []
            return items.filter(function(item) {
                return item && typeof item.name === "string" &&
                       typeof item.jsonData === "string" && item.jsonData.length > 0
            })
        } catch (error) {
            console.warn("SmartBar: biblioteca de temas inválida, no se borró", error)
            return []
        }
    }
    function saveNamedTheme() {
        const items = savedThemeLibrary.slice()
        if (items.length >= 200) {
            themeStatus = "Límite de 200 temas alcanzado. Conservá los que ya guardaste."
            return
        }
        const name = String(newThemeName).trim().slice(0, 60) ||
                     ("Mi tema " + (items.length + 1))
        items.push({name: name, jsonData: themeSnapshot()})
        themeLibraryJson = JSON.stringify(items)
        stageThemeSlot("library", themeLibraryJson)
        // Guardar tema confirma el estado visual y evita que se pierda al salir.
        applyChanges()
        newThemeName = ""
        themeStatus = "Tema «" + name + "» guardado en la biblioteca local. " +
                      "Los anteriores se conservan."
    }
    function restoreNamedTheme(index) {
        activateTheme("library:" + index)
    }
    // Día ocupa una sola opción en el selector; nunca se mezcla con la
    // antigua clave histórica themeDayJson (Atardecer).
    function dayThemeIndex() {
        const items = savedThemeLibrary
        for (let i = 0; i < items.length; ++i) {
            if (items[i].name.trim().toLocaleLowerCase() === "día" ||
                items[i].name.trim().toLocaleLowerCase() === "dia") return i
        }
        return -1
    }
    readonly property var otherNamedThemes: savedThemeLibrary.filter(function(item) {
        const name = item.name.trim().toLocaleLowerCase()
        return name !== "día" && name !== "dia"
    })
    function otherNamedThemeOriginalIndex(index) {
        let count = 0
        const items = savedThemeLibrary
        for (let i = 0; i < items.length; ++i) {
            const name = items[i].name.trim().toLocaleLowerCase()
            if (name === "día" || name === "dia") continue
            if (count++ === index) return i
        }
        return -1
    }
    // Perfil Noche original de fábrica: SOLO manifiesto distribuido con el
    // programa; el tema histórico guardado localmente no lo modifica.
    readonly property var factoryNightPreset: FactoryNightTheme.preset
    readonly property url factoryNightImage:
        factoryNightPreset && factoryNightPreset.assetFile
            ? Qt.resolvedUrl("assets/" + factoryNightPreset.assetFile) : ""
    readonly property bool factoryNightAvailable:
        factoryNightPreset !== null && factoryNightPreset !== undefined &&
        factoryNightPreset.version === 1 &&
        (factoryNightPreset.logoMode === "text" ||
         (factoryNightPreset.assetFile && factoryNightProbe.status === Image.Ready)) &&
        (!factoryNightPreset.assetTextFile ||
         factoryNightTextProbe.status === Image.Ready)
    Image {
        id: factoryNightProbe
        visible: false
        asynchronous: false
        cache: true
        source: settings.factoryNightImage
    }
    Image {
        id: factoryNightTextProbe
        visible: false
        asynchronous: false
        cache: true
        source: factoryNightPreset && factoryNightPreset.assetTextFile
            ? Qt.resolvedUrl("assets/" + factoryNightPreset.assetTextFile) : ""
    }
    readonly property string factoryNightJson:
        factoryNightAvailable ? JSON.stringify(factoryNightPreset) : ""
    // Atardecer original de sistema: manifest propio, distinto de themeDayJson
    // y de Noche. Nunca utilizar una imagen o colores de un tema diferente.
    readonly property var factorySunsetPreset: FactorySunsetTheme.preset
    readonly property url factorySunsetImage:
        factorySunsetPreset && factorySunsetPreset.assetFile
            ? Qt.resolvedUrl("assets/" + factorySunsetPreset.assetFile) : ""
    readonly property bool factorySunsetAvailable:
        factorySunsetPreset !== null && factorySunsetPreset !== undefined &&
        factorySunsetPreset.version === 1 &&
        (factorySunsetPreset.logoMode === "text" ||
         (factorySunsetPreset.assetFile && factorySunsetProbe.status === Image.Ready)) &&
        (!factorySunsetPreset.assetTextFile ||
         factorySunsetTextProbe.status === Image.Ready)
    Image {
        id: factorySunsetProbe
        visible: false
        asynchronous: false
        cache: true
        source: settings.factorySunsetImage
    }
    Image {
        id: factorySunsetTextProbe
        visible: false
        asynchronous: false
        cache: true
        source: factorySunsetPreset && factorySunsetPreset.assetTextFile
            ? Qt.resolvedUrl("assets/" + factorySunsetPreset.assetTextFile) : ""
    }
    readonly property string factorySunsetJson:
        factorySunsetAvailable ? JSON.stringify(factorySunsetPreset) : ""
    // Tema oficial Día, solo lectura; no confundir con themeDayJson (Atardecer).
    readonly property var factoryDayPreset: FactoryDayTheme.preset
    readonly property url factoryDayImage:
        factoryDayPreset && factoryDayPreset.assetFile
            ? Qt.resolvedUrl("assets/" + factoryDayPreset.assetFile) : ""
    Image { id: factoryDayProbe; visible: false; asynchronous: false; cache: true
            source: settings.factoryDayImage }
    Image { id: factoryDayTextProbe; visible: false; asynchronous: false; cache: true
            source: factoryDayPreset && factoryDayPreset.assetTextFile
                ? Qt.resolvedUrl("assets/" + factoryDayPreset.assetTextFile) : "" }
    readonly property bool factoryDayAvailable:
        factoryDayPreset !== null && factoryDayPreset !== undefined &&
        factoryDayPreset.version === 1 &&
        (factoryDayPreset.logoMode === "text" ||
         (factoryDayPreset.assetFile && factoryDayProbe.status === Image.Ready)) &&
        (!factoryDayPreset.assetTextFile || factoryDayTextProbe.status === Image.Ready)
    readonly property string factoryDayJson:
        factoryDayAvailable ? JSON.stringify(factoryDayPreset) : ""
    property string factoryExportTarget: "night"
    function showFactoryCapture(target) {
        factoryExportTarget = target === "sunset" ? "sunset" : "night"
        factoryNightExportDialog.open()
    }
    property string themeStatus: "Atardecer y Noche de fábrica conservan sus originales; los cambios van por separado."
    signal saveThemeSlotRequested(string slot, string jsonData)
    signal wallpaperThemeSelected(string themeName)
    signal saveThemeScheduleRequested(bool enabled, int count, string slots3Json, string slots4Json)
    // Ajuste personal, no forma parte de los temas oficiales inmutables.
    signal thematicWallpaperVisibilityRequested(bool enabled)
    QQC2.Dialog {
        id: factoryNightExportDialog
        title: "Copiar apariencia exacta para " + (settings.factoryExportTarget === "sunset" ? "Atardecer" : "Noche") + " de fábrica"
        modal: true
        width: Math.min(740, settings.width - 80)
        height: Math.min(560, settings.height - 90)
        standardButtons: QQC2.Dialog.Close
        contentItem: ColumnLayout {
            spacing: 8
            QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Copiá este JSON y aportá el GIF o imagen original del logo. " +
                      "La captura incluye los valores visuales exactos actuales y no escribe en la fábrica."
            }
            QQC2.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                QQC2.TextArea {
                    id: factoryNightExportText
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.WrapAnywhere
                    text: settings.factoryNightCandidateJson()
                }
            }
            QQC2.Button {
                text: "Copiar JSON actual"
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    factoryNightExportText.selectAll()
                    factoryNightExportText.copy()
                    factoryNightExportText.deselect()
                }
            }
        }
    }
    // Los antiguos diálogos para sobrescribir Atardecer se retiraron.
    // Las ranuras históricas siguen persistidas, pero no son el original.

    // Botones del menú lateral: no cortar nombres cuando la ventana es angosta
    // o cuando el usuario aumenta la escala de fuentes de KDE.
    component SettingsPageTab: QQC2.TabButton {
        id: pageTab
        implicitHeight: 48
        contentItem: Text {
            text: pageTab.text
            font: pageTab.font
            color: pageTab.enabled ? "#ffffff" : "#999999"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideNone
        }
    }

    component SettingsMenuButton: QQC2.Button {
        id: navigationButton
        // Dos niveles visuales sin alterar los destinos ni el funcionamiento.
        property bool sectionHeader: false
        Layout.fillWidth: true
        Layout.leftMargin: sectionHeader ? 0 : 16
        Layout.minimumHeight: sectionHeader ? 50 : 38
        Layout.preferredHeight: Math.max(sectionHeader ? 50 : 38,
            menuText.contentHeight + navigationButton.topPadding + navigationButton.bottomPadding)
        topPadding: sectionHeader ? 11 : 8
        bottomPadding: sectionHeader ? 11 : 8
        leftPadding: sectionHeader ? 12 : 11
        rightPadding: 8
        background: Rectangle {
            radius: navigationButton.sectionHeader ? 9 : 6
            color: navigationButton.highlighted
                ? (navigationButton.sectionHeader ? "#425c7b" : "#374962")
                : (navigationButton.sectionHeader ? "#343c53" : "#292f41")
            border.width: navigationButton.sectionHeader ? 1 : 0
            border.color: navigationButton.sectionHeader ? "#62738f" : "transparent"
        }
        contentItem: Text {
            id: menuText
            text: navigationButton.text
            font.family: navigationButton.font.family
            font.pixelSize: navigationButton.sectionHeader ? 15 : 12
            font.bold: navigationButton.sectionHeader
            color: navigationButton.enabled ? "#ffffff" : "#999999"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideNone
        }
    }

    // Accesos únicos y acotados. Ninguna pestaña de isla permite editar
    // otra isla; los controles compartidos se encuentran en General.
    function showThemes() { navigationGroup = "themes"; currentTab = 4; themeChooserExpanded = false; scheduleMenuExpanded = false; factoryToolsExpanded = false }
    function showSoledadLogo() {
        navigationGroup = "soledad"
        currentTab = 1
        if (logoScroll.contentItem) logoScroll.contentItem.contentY = 0
    }
    function scrollToSoledadEffects() {
        Qt.callLater(function() {
            if (!logoScroll.contentItem || !soLightSectionTitle.visible) return
            const scroll = logoScroll.contentItem
            const y = soLightSectionTitle.mapToItem(scroll.contentItem, 0, 0).y
            scroll.contentY = Math.max(0, Math.min(scroll.contentHeight - scroll.height, y - 12))
        })
    }
    function showSoledadEffects() {
        navigationGroup = "soledad"
        currentTab = 1
        outlineSection = 2
        scrollToSoledadEffects()
    }
    function showSoledadGlowBreathing() { showSoledadEffects() }
    function showSoledadWindows() { navigationGroup = "soledad"; currentTab = 2; appearanceSubtabs.currentIndex = 1 }
    function showSoledadLauncher() {
        navigationGroup = "soledad"; behaviorScope = "soledad"
        currentTab = 0; islandSubtabs.currentIndex = 1
    }
    function showMalvinaProviders() { navigationGroup = "malvina"; currentTab = 0; islandSubtabs.currentIndex = 2 }
    function showGeometry(scope, section) {
        geometryScope = scope
        navigationGroup = scope === "shared" ? "shared" : scope
        geometrySection = section
        currentTab = 0
        islandSubtabs.currentIndex = 0
        if (positionScroll.contentItem) positionScroll.contentItem.contentY = 0
    }
    function showSoledadShape() { showGeometry("soledad", 1) }
    function showMalvinaShape() { showGeometry("malvina", 1) }
    function showSharedLayout() { showGeometry("shared", 0) }
    function showSharedButtons() { showGeometry("shared", 1) }
    function showSharedSizes() { showGeometry("shared", 2) }
    function showSharedBehavior() {
        navigationGroup = "shared"; behaviorScope = "shared"
        currentTab = 0; islandSubtabs.currentIndex = 1
    }
    function showSharedColors(target) {
        colorScope = target === 0 ? "soledad" : target === 1 ? "malvina" : "shared"
        navigationGroup = colorScope
        currentTab = 2
        appearanceSubtabs.currentIndex = 0
        appearanceSection = 0
        // El índice 2 era la barra continua: mantenerlo solo en datos históricos.
        appearanceTarget.currentIndex = target === 2 ? 3 : target
        if (appearanceScroll.contentItem) appearanceScroll.contentItem.contentY = 0
    }
    function showSharedOutlines() { navigationGroup = "shared"; currentTab = 2; appearanceSubtabs.currentIndex = 2 }
    // Degradado y respiración viven dentro de Color y transparencia.
    function showSoledadGradient() { showSharedColors(0) }
    function showSoledadGradientBreathing() {
        showSharedColors(0)
        Qt.callLater(function() {
            if (appearanceScroll.contentItem && gradientBreathingTitle.visible) {
                const scroll = appearanceScroll.contentItem
                const y = gradientBreathingTitle.mapToItem(scroll.contentItem, 0, 0).y
                scroll.contentY = Math.max(0, Math.min(scroll.contentHeight - scroll.height, y - 12))
            }
        })
    }
    function showMalvinaGradient() { showSharedColors(1) }
    // Siempre se puede ajustar la velocidad propia: al moverla se desactiva
    // solamente el enlace con SO, sin borrar las preferencias personales.
    function setIndependentGradientSpeed(target, speed) {
        if (!isFinite(speed)) return
        const next = Math.round(Math.max(0.1, Math.min(3, speed)) * 10) / 10
        if (target === 0) {
            soledadGradientSyncBreathing = false
            soledadGradientSyncIntensity = false
            soledadGradientBreathingEnabled = true
            soledadGradientBreathingSpeed = next
        } else if (target === 1) {
            malvinaGradientSyncBreathing = false
            malvinaGradientBreathingEnabled = true
            malvinaGradientBreathingSpeed = next
        }
    }
    function setSoLineBreathingSpeed(speed) {
        if (!isFinite(speed)) return
        pulseSpeed = Math.round(Math.max(0.1, Math.min(3, speed)) * 10) / 10
        effectStyle = "breathe"
        allowMotion = true
        refreshOutlinePreview()
    }
    function setSoLineBreathingDepth(depth) {
        if (!isFinite(depth)) return
        pulseDepth = Math.round(Math.max(0, Math.min(1, depth)) * 20) / 20
        effectStyle = "breathe"
        allowMotion = true
        refreshOutlinePreview()
    }
    property int currentTab: 0
    // V1 de tema visual: foto/logo + colores de las dos islas, líneas y
    // contornos, sin alterar posición, controles de ventanas ni permisos IA.
    // Sólo snapshots explícitos; no se publican GIFs personales en GitHub.
    // Atardecer/Noche conservan exactamente el efecto de respiración
    // capturado en su instantánea: no forzar sincronización ni pulsación
    // cuando el usuario guardó valores propios.
    function factoryNightCandidateJson() {
        const values = JSON.parse(themeSnapshot())
        // Solo se utiliza para encontrar el binario durante el empaquetado:
        // nunca se debe distribuir la ruta local del mantenedor.
        values.originalImageUrl = logoMode === "text" ? "" : selectedImage.toString()
        return JSON.stringify(values)
    }
    function themeSnapshot() {
        return JSON.stringify({
            version: 1,
            effectStyle: effectStyle, allowMotion: allowMotion,
            strokeSize: strokeSize, orbitSpeed: orbitSpeed,
            trailPercent: trailPercent, trailStyle: trailStyle,
            showOutlineWhenEmpty: showOutlineWhenEmpty,
            showOutlineWhenOpen: showOutlineWhenOpen,
            pulseSpeed: pulseSpeed, pulseDepth: pulseDepth,
            logoMode: logoMode, filePath: filePath, shape: shape,
            cropFitMode: cropFitMode, cropZoom: cropZoom,
            cropPanX: cropPanX, cropPanY: cropPanY,
            cropRotation: cropRotation, enableGif: enableGif,
            soledadColor: toHex(soledadColor), soledadOpacity: soledadOpacity,
            soledadGradientEnabled: soledadGradientEnabled,
            soledadGradientEnd: toHex(soledadGradientEnd),
            soledadGradientThird: toHex(soledadGradientThird),
            soledadGradientColorCount: soledadGradientColorCount,
            soledadGradientDirection: soledadGradientDirection,
            soledadGradientSyncBreathing: soledadGradientSyncBreathing,
            soledadGradientSyncIntensity: soledadGradientSyncIntensity,
            soledadGradientBreathingEnabled: soledadGradientBreathingEnabled,
            soledadGradientBreathingSpeed: soledadGradientBreathingSpeed,
            soledadGradientBreathingIntensity: soledadGradientBreathingIntensity,
            malvinaColor: toHex(malvinaColor), malvinaOpacity: malvinaOpacity,
            malvinaGradientEnabled: malvinaGradientEnabled,
            malvinaGradientEnd: toHex(malvinaGradientEnd),
            malvinaGradientThird: toHex(malvinaGradientThird),
            malvinaGradientColorCount: malvinaGradientColorCount,
            malvinaGradientDirection: malvinaGradientDirection,
            malvinaGradientSyncBreathing: malvinaGradientSyncBreathing,
            malvinaGradientBreathingEnabled: malvinaGradientBreathingEnabled,
            malvinaGradientBreathingSpeed: malvinaGradientBreathingSpeed,
            malvinaGradientBreathingIntensity: malvinaGradientBreathingIntensity,
            accentColor: toHex(accentColor), glowColor: toHex(glowColor),
            glowGradient: glowGradient, glowIntensity: glowIntensity,
            glowSpread: glowSpread,
            // Estética antes omitida: fondo, botones, texto y fichas. Los
            // valores locales se serializan, nunca se sustituyen por paletas.
            showBackground: showBackground,
            backgroundColor: toHex(backgroundColor),
            backgroundOpacity: backgroundOpacity,
            trayButtonColorOverride: trayButtonColorOverride,
            trayButtonColor: toHex(trayButtonColor), trayButtonOpacity: trayButtonOpacity,
            gripButtonColorOverride: gripButtonColorOverride,
            gripButtonColor: toHex(gripButtonColor), gripButtonOpacity: gripButtonOpacity,
            soledadShape: soledadShape, malvinaShape: malvinaShape,
            malvinaGearButtonShape: malvinaGearButtonShape,
            malvinaSearchButtonShape: malvinaSearchButtonShape,
            soButtonFrameShape: soButtonFrameShape,
            soButtonWidth: soButtonWidth,
            panelHeight: panelHeight,
            soledadHeight: soledadHeight, malvinaHeight: malvinaHeight,
            soledadRadius: soledadRadius, malvinaRadius: malvinaRadius,
            soledadMinWidth: soledadMinWidth, malvinaWidth: malvinaWidth,
            gripShape: gripShape, trayButtonShape: trayButtonShape,
            soTextLabel: soTextLabel, soTextColor: toHex(soTextColor),
            soTextBackground: toHex(soTextBackground),
            soTextBackgroundOpacity: soTextBackgroundOpacity,
            soTextFontFamily: soTextFontFamily, soTextFontSize: soTextFontSize,
            soTextBold: soTextBold, soTextBackgroundImage: soTextBackgroundImage,
            clockFontFamily: clockFontFamily, clockFontSize: clockFontSize,
            clockTextColor: toHex(clockTextColor),
            taskDisplayMode: taskDisplayMode,
            taskFrameShape: taskFrameShape, taskFrameColor: toHex(taskFrameColor),
            taskFrameOpacity: taskFrameOpacity, taskFrameWidth: taskFrameWidth,
            taskActiveGlowEnabled: taskActiveGlowEnabled,
            taskActiveDoubleBorderEnabled: taskActiveDoubleBorderEnabled,
            launcherSwitchShape: launcherSwitchShape,
            launcherSwitchColorOverride: launcherSwitchColorOverride,
            launcherSwitchColor: toHex(launcherSwitchColor),
            launcherIconsWithNames: launcherIconsWithNames,
            outlineConfig: JSON.parse(JSON.stringify(outlineConfig)),
            launcherOpacityOverride: launcherOpacityOverride,
            launcherOpacity: launcherOpacity,
            malvinaOptionsOpacityOverride: malvinaOptionsOpacityOverride,
            malvinaOptionsOpacity: malvinaOptionsOpacity
        })
    }
    function slotJson(slot) {
        if (slot.indexOf("library:") === 0) {
            const index = Number(slot.substring(8))
            const items = savedThemeLibrary
            return isFinite(index) && index >= 0 && index < items.length &&
                   Math.floor(index) === index ? items[index].jsonData : ""
        }
        return slot === "dayOfficial" ? factoryDayJson :
               slot === "sunset" ? factorySunsetJson :
               slot === "night" ? factoryNightJson :
               slot === "nightLegacy" ? themeNightJson :
               slot === "dayPrevious" ? themeDayPreviousJson :
               slot === "day" ? themeDayJson : themeCustomJson
    }
    function storeTheme(slot) {
        // Los originales de fábrica Noche y Atardecer no se pueden escribir.
        if (slot === "dayOfficial") {
            themeStatus = "Día oficial es inmutable; usá una copia personalizada."
            return
        }
        if (slot === "night") {
            themeStatus = "Noche de fábrica está protegida; usá Personalizado."
            return
        }
        if (slot === "sunset") {
            themeStatus = "Atardecer de fábrica está protegido; usá Personalizado."
            return
        }
        if (slot === "day") {
            themeStatus = "La antigua ranura Atardecer se conserva, pero ya no se modifica; usá Personalizado."
            return
        }
        const data = themeSnapshot()
        themeCustomJson = data
        stageThemeSlot(slot, data)
        themeStatus = "Tema Personalizado" +
                      " preparado. Pulsá Aplicar para guardarlo sin reemplazar otros temas."
    }
    // Las instantáneas antiguas de Atardecer no se descartan ni se reescriben.
    // El original se distribuye exclusivamente en FactorySunsetTheme.js.
    function themeImageSource(jsonData) {
        try {
            if (!jsonData) return ""
            const info = JSON.parse(jsonData)
            if (info.logoMode === "custom" && info.filePath) return info.filePath
            if (info.logoMode === "default") return defaultImage.toString()
            // Texto sin imagen no debe tomar un GIF de otra ranura.
            return ""
        } catch(e) { return "" }
    }
    function activateTheme(slot) {
        const jsonData = slotJson(slot)
        if (!jsonData) {
            themeStatus = slot === "night"
                ? "Falta incorporar el perfil Noche exacto y su imagen original; no se aplicará otro tema."
                : slot === "sunset"
                  ? "Falta incorporar el Atardecer exacto y su imagen original; no se aplicará otro tema."
                  : "Este tema todavía no está guardado. Personalizá la isla y pulsá Guardar."
            return false
        }
        try {
            const info = JSON.parse(jsonData)
            if (info.version !== 1) throw new Error("Versión de tema desconocida")
            const fields = [
                "effectStyle","allowMotion","strokeSize","orbitSpeed",
                "trailPercent","trailStyle","showOutlineWhenEmpty",
                "showOutlineWhenOpen","pulseSpeed","pulseDepth",
                "logoMode","filePath","shape","cropFitMode","cropZoom",
                "cropPanX","cropPanY","cropRotation","enableGif",
                "soledadColor","soledadOpacity","soledadGradientEnabled",
                "soledadGradientEnd","soledadGradientThird",
                "soledadGradientColorCount","soledadGradientDirection",
                "soledadGradientSyncBreathing","soledadGradientSyncIntensity",
                "soledadGradientBreathingEnabled",
                "soledadGradientBreathingSpeed","soledadGradientBreathingIntensity",
                "malvinaColor","malvinaOpacity","malvinaGradientEnabled",
                "malvinaGradientEnd","malvinaGradientThird",
                "malvinaGradientColorCount","malvinaGradientDirection",
                "malvinaGradientSyncBreathing","malvinaGradientBreathingEnabled",
                "malvinaGradientBreathingSpeed","malvinaGradientBreathingIntensity",
                "accentColor","glowColor","glowGradient","glowIntensity","glowSpread",
                "showBackground","backgroundColor","backgroundOpacity",
                "trayButtonColorOverride","trayButtonColor","trayButtonOpacity",
                "gripButtonColorOverride","gripButtonColor","gripButtonOpacity",
                "soledadShape","malvinaShape","malvinaGearButtonShape",
                "malvinaSearchButtonShape","soButtonFrameShape",
                "soButtonWidth","panelHeight","soledadHeight","malvinaHeight",
                "soledadRadius","malvinaRadius","soledadMinWidth","malvinaWidth",
                "gripShape","trayButtonShape",
                "soTextLabel","soTextColor","soTextBackground",
                "soTextBackgroundOpacity","soTextFontFamily","soTextFontSize",
                "soTextBold","soTextBackgroundImage",
                "clockFontFamily","clockFontSize","clockTextColor",
                "taskDisplayMode",
                "taskFrameShape","taskFrameColor","taskFrameOpacity","taskFrameWidth",
                "taskActiveGlowEnabled","taskActiveDoubleBorderEnabled",
                "launcherSwitchShape","launcherSwitchColorOverride",
                "launcherSwitchColor","launcherIconsWithNames",
                "launcherOpacityOverride","launcherOpacity",
                "malvinaOptionsOpacityOverride","malvinaOptionsOpacity"
            ]
            for (let i = 0; i < fields.length; ++i) {
                const key = fields[i]
                if (info[key] !== undefined && info[key] !== null)
                    settings[key] = info[key]
            }
            if (info.outlineConfig && typeof info.outlineConfig === "object")
                outlineConfig = JSON.parse(JSON.stringify(info.outlineConfig))
            // Aplicar recupera el estado capturado, incluidos sync, velocidad
            // e intensidad, sin reactivar interruptores apagados.
            // Respetar exactamente colores y orientaciones guardados,
            // sin copiar el degradado de una isla hacia la otra.
            // Noche utiliza recursos inmutables del paquete (no rutas locales
            // del equipo del autor ni la foto activa de otro tema).
            if (slot === "night" || slot === "sunset" || slot === "dayOfficial") {
                if (info.assetFile) {
                    logoMode = "custom"
                    filePath = slot === "sunset"
                        ? factorySunsetImage.toString()
                        : slot === "dayOfficial" ? factoryDayImage.toString()
                        : factoryNightImage.toString()
                }
                if (info.assetTextFile)
                    soTextBackgroundImage =
                        Qt.resolvedUrl("assets/" + info.assetTextFile).toString()
            }
            // Reusar la ruta de guardado vigente, inclusive los favoritos que
            // son independientes de estos tres espacios de tema.
            applyChanges()
            themeStatus = "Tema " +
                (slot === "dayOfficial" ? "Día oficial" :
                 slot === "sunset" ? "Atardecer de fábrica" :
                 slot === "day" ? "Atardecer anterior" :
                 slot === "night" ? "Noche de fábrica" :
                 slot.indexOf("library:") === 0 ? "personal guardado" : "Personalizado") +
                " restaurado. Podés personalizar la barra sin modificar el original."
            return true
        } catch(e) {
            themeStatus = "No se pudo aplicar el tema guardado: " + e
            console.warn("SmartBar: tema local inválido", e)
            return false
        }
    }
    property alias currentIslandSubtab: islandSubtabs.currentIndex
    property string malvinaGoogleUrl: "https://www.google.com/search?q={query}"
    property string malvinaDuckUrl: "https://duckduckgo.com/?q={query}"
    property string malvinaYahooUrl: "https://search.yahoo.com/search?p={query}"
    property string malvinaChatGptUrl: "https://chatgpt.com/"
    property string malvinaGeminiUrl: "https://gemini.google.com/app"
    property string malvinaClaudeUrl: "https://claude.ai/new"
    property bool malvinaWebFirst: true
    property string malvinaWebOrder: "google,duck,yahoo"
    property string malvinaAiOrder: "chatgpt,gemini,claude"
    property string malvinaExtraWeb: "[]"
    property string malvinaExtraAi: "[]"
    property string malvinaHiddenWeb: ""
    property string malvinaHiddenAi: ""
    property bool malvinaCompactAi: false
    signal saveMalvinaExtrasRequested(string webJson, string aiJson,
                                      string hiddenWeb, string hiddenAi, bool compactAi)
    signal saveMalvinaOrderRequested(bool firstWeb, string webOrder, string aiOrder)
    property string malvinaGoogleName: "Google"
    property string malvinaDuckName: "DuckDuckGo"
    property string malvinaYahooName: "Yahoo"
    property string malvinaChatGptName: "ChatGPT"
    property string malvinaGeminiName: "Gemini"
    property string malvinaClaudeName: "Claude"
    signal saveMalvinaNamesRequested(string google, string duck, string yahoo,
                                     string chatGpt, string gemini, string claude)
    // Solo consentimiento guardado. No activa envío al chat hasta existir una integración verificada.
    property bool malvinaWebGoogleEnabled: true
    property bool malvinaWebDuckEnabled: true
    property bool malvinaWebYahooEnabled: true
    signal saveMalvinaWebEnabledRequested(bool google, bool duck, bool yahoo)
    property bool malvinaAllowChatGpt: false
    property bool malvinaAllowGemini: false
    property bool malvinaAllowClaude: false
    signal saveMalvinaConsentsRequested(bool chatGpt, bool gemini, bool claude)
    signal saveMalvinaProvidersRequested(string google, string duck, string yahoo,
                                         string chatGpt, string gemini, string claude)
    function malvinaNameValid(name) {
        return typeof name === "string" && name.trim().length > 0 &&
               name.trim().length <= 48 && !/[\\x00-\\x1f\\x7f]/.test(name)
    }
    function malvinaWebTemplateValid(url) {
        return /^https:\/\//i.test(url.trim()) && url.indexOf("{query}") >= 0
    }
    function malvinaSiteValid(url) {
        return /^https:\/\//i.test(url.trim())
    }

    property url defaultImage: ""

    // Valores de trabajo. Se copian desde SmartBarContent al abrir.
    property string logoMode: "default"
    property string soTextLabel: "SO"
    property color soTextColor: "#ffffff"
    property color soTextBackground: "#192536"
    property real soTextBackgroundOpacity: 0.9
    property string soTextFontFamily: "Sans Serif"
    property int soTextFontSize: 13
    property bool soTextBold: true
    property string soTextBackgroundImage: ""
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
    property color soledadGradientThird: "#ee9852"
    property int soledadGradientColorCount: 2 // 2 por defecto, 3 opcional
    property string soledadGradientDirection: "topBottom"
    // Ajustes de respiración propios de cada isla. La sincronización toma
    // velocidad y fase de SO; fuera de ella cada isla usa su velocidad local.
    property bool soledadGradientBreathingEnabled: true
    property bool soledadGradientSyncBreathing: false
    // La intensidad de fondo solo sigue al contorno por elección expresa.
    property bool soledadGradientSyncIntensity: false
    property real soledadGradientBreathingIntensity: 0.6
    property real soledadGradientBreathingSpeed: 0.6
    property bool malvinaGradientBreathingEnabled: true
    property bool malvinaGradientSyncBreathing: false
    property real malvinaGradientBreathingIntensity: 0.6
    property real malvinaGradientBreathingSpeed: 0.6
    property bool malvinaGradientEnabled: false
    property color malvinaGradientEnd: "#445577"
    property color malvinaGradientThird: "#445577"
    property int malvinaGradientColorCount: 2
    property string malvinaGradientDirection: "topBottom"
    property color backgroundColor: "#202333"
    property real soledadOpacity: 0.7
    property real malvinaOpacity: 0.7
    property real backgroundOpacity: 0.7
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

    property string effectStyle: "breathe"
    property color accentColor: "#35d7ff"
    property real strokeSize: 0.75
    property bool allowMotion: true
    // Valores de contorno provisoriamente elegidos para esta prueba.
    property real orbitSpeed: 1.5 // vueltas por segundo
    property color glowColor: "#ffab52"
    property real glowIntensity: 0.7
    property real glowSpread: 5
    property real pulseSpeed: 0.3
    property real pulseDepth: 0.7
    property bool glowGradient: true
    property int trailPercent: 75 // porcentaje del perímetro
    property string trailStyle: "dashed" // solid, dotted, dashed
    property bool showOutlineWhenEmpty: true
    property bool showOutlineWhenOpen: false
    property bool simulateHasWindows: false
    // Nueva lógica cromática: una sola fuente real de color por isla.
    // El GIF solo ofrece candidatos y nunca modifica el brillo/contorno SO.
    // Cada tono es un HEX independiente y editable, aun sin imagen.
    property var sampledColors: []   // hasta tres HEX reales de la imagen
    property string sampledSource: ""
    property string paletteFeedback: "Analizá el GIF para obtener hasta tres tonos. Elegí cuáles usar o escribí tus propios colores."
    function resetSampledColors() {
        sampledColors = []
        sampledSource = ""
    }
    onSelectedImageChanged: resetSampledColors()
    onSoTextBackgroundImageChanged: resetSampledColors()
    function normalizeColorHex(raw) {
        const value = String(raw).trim()
        const normalized = value.charAt(0) === "#" ? value : "#" + value
        return /^#[0-9a-fA-F]{6}$/.test(normalized)
            ? normalized.toLowerCase() : ""
    }
    function sampleHex(index) {
        return index >= 0 && index < sampledColors.length
            ? String(sampledColors[index]) : ""
    }
    function editSampleHex(index, raw) {
        const hex = normalizeColorHex(raw)
        if (!hex || index < 0 || index >= sampledColors.length) {
            paletteFeedback = "Código no válido: escribí seis caracteres hexadecimales (ejemplo #004b87)."
            return false
        }
        const previous = sampleHex(index).toLowerCase()
        // Si el usuario ya estaba usando este tono, editarlo actualiza el
        // color activo de ESTA isla. No se cambian los colores de la otra.
        const slots = ["base", "end", "third"]
        const assigned = []
        for (let i = 0; i < slots.length; ++i)
            if (toHex(islandColor(slots[i])).toLowerCase() === previous)
                assigned.push(slots[i])
        const next = sampledColors.slice()
        next[index] = hex
        sampledColors = next
        for (let i = 0; i < assigned.length; ++i)
            setIslandColor(assigned[i], hex)
        paletteFeedback = "Tono " + (index + 1) + " editado a " + hex +
            (assigned.length
                ? ". Actualizado también en el degradado activo de esta isla."
                : ". Elegí qué color del degradado debe utilizarlo.") +
            " Pulsá Aplicar para guardarlo."
        return true
    }
    function islandColor(slot) {
        const malvina = appearanceTarget.currentIndex === 1
        return slot === "base"
            ? (malvina ? malvinaColor : soledadColor)
            : slot === "third"
                ? (malvina ? malvinaGradientThird : soledadGradientThird)
                : (malvina ? malvinaGradientEnd : soledadGradientEnd)
    }
    readonly property int activeGradientColorCount: appearanceTarget.currentIndex === 1
        ? malvinaGradientColorCount : soledadGradientColorCount
    function setGradientColorCount(count) {
        if (appearanceTarget.currentIndex === 1)
            malvinaGradientColorCount = count === 3 ? 3 : 2
        else if (appearanceTarget.currentIndex === 0)
            soledadGradientColorCount = count === 3 ? 3 : 2
    }
    readonly property string activeGradientDirection:
        appearanceTarget.currentIndex === 1
        ? malvinaGradientDirection : soledadGradientDirection
    function gradientPreviewStop(index) {
        const reversed = activeGradientDirection === "rightLeft" ||
                         activeGradientDirection === "bottomTop"
        const three = activeGradientColorCount === 3
        if (index === 0)
            return islandColor(reversed ? (three ? "third" : "end") : "base")
        if (index === 1)
            return islandColor(three ? "end" : (reversed ? "base" : "end"))
        return islandColor(reversed ? "base" : (three ? "third" : "end"))
    }
    function selectedSampleIndex(slot) {
        const targetHex = toHex(islandColor(slot)).toLowerCase()
        for (let i = 0; i < sampledColors.length; ++i) {
            if (sampleHex(i).toLowerCase() === targetHex)
                return i + 1
        }
        return 0 // 0 significa color manual fuera de la paleta sugerida
    }
    function setIslandColor(slot, color) {
        // Nunca tocar el contorno ni el color de la otra isla.
        if (appearanceTarget.currentIndex === 1) {
            if (slot === "base") malvinaColor = color
            else if (slot === "third") malvinaGradientThird = color
            else malvinaGradientEnd = color
        } else if (appearanceTarget.currentIndex === 0) {
            if (slot === "base") soledadColor = color
            else if (slot === "third") soledadGradientThird = color
            else soledadGradientEnd = color
        } else return
        paletteFeedback = "Seleccionado " +
                          (slot === "base" ? "primer" : slot === "third" ? "tercer" : "segundo") +
                          " tono " + toHex(islandColor(slot)) +
                          " para " + (appearanceTarget.currentIndex === 1 ? "Malvina" : "Soledad") +
                          ". Aplicar guarda estos valores; no cambia la otra isla."
    }
    function setIslandHex(slot, raw) {
        const hex = normalizeColorHex(raw)
        if (!hex) {
            paletteFeedback = "HEX no válido; usá seis dígitos como #000000."
            return false
        }
        setIslandColor(slot, hex)
        return true
    }
    function chooseSampledColor(index, slot) {
        if (index < 0 || index >= sampledColors.length) return
        setIslandColor(slot, sampledColors[index])
    }
    function chooseCoordinatedPalette(name, contour, outer, islandBase, islandEnd) {
        // Retrocompatibilidad para presets de CONTORNO: solo luz, sin
        // propuestas ocultas de fondo ni aplicación automática de degradado.
        accentColor = contour
        glowColor = outer
        glowGradient = true
        paletteFeedback = "Contorno «" + name +
                          "» actualizado independientemente del fondo. Pulsá Aplicar."
    }
    function resetColorsForTarget(target) {
        // Restablecimiento local, sin tocar el GIF ni los demás destinos.
        // Evitar rescatar un naranja obsoleto al volver a activar degradado.
        if (target === 0) {
            soledadColor = "#010111"
            soledadGradientEnd = "#010111"
            soledadGradientThird = "#010111"
            soledadGradientColorCount = 2
            soledadGradientEnabled = false
            soledadGradientDirection = "topBottom"
            soledadGradientBreathingEnabled = true
            soledadGradientSyncBreathing = false
            soledadGradientSyncIntensity = false
            soledadGradientBreathingIntensity = 0.6
            soledadGradientBreathingSpeed = 0.6
            soledadOpacity = 0.5
            resetSampledColors()
            paletteFeedback = "Soledad volvió a tonos neutros. Para la playa nocturna, " +
                              "elegí Sugerir desde GIF y aplicá sus dos colores."
        } else if (target === 1) {
            malvinaColor = "#101e31"
            malvinaGradientEnd = "#101e31"
            malvinaGradientThird = "#101e31"
            malvinaGradientColorCount = 2
            malvinaGradientEnabled = false
            malvinaGradientDirection = "topBottom"
            malvinaGradientBreathingEnabled = true
            malvinaGradientSyncBreathing = false
            malvinaGradientBreathingIntensity = 0.6
            malvinaGradientBreathingSpeed = 0.6
            malvinaOpacity = 1
        } else if (target === 2) {
            backgroundColor = "#202333"
            backgroundOpacity = 0.5
            showBackground = false
        } else if (target === 3) {
            trayButtonColorOverride = false
            trayButtonColor = soledadColor
            trayButtonOpacity = soledadOpacity
        } else if (target === 4) {
            gripButtonColorOverride = false
            gripButtonColor = soledadColor
            gripButtonOpacity = soledadOpacity
        }
    }
    // Muestra de edición de SO; la barra real solo cambia al pulsar Aplicar.
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
    // Mantener la muestra sincronizada con el control actual sin guardar en disco.
    onPulseSpeedChanged: if (visible) refreshOutlinePreview()
    onPulseDepthChanged: if (visible) refreshOutlinePreview()
    onEffectStyleChanged: if (visible) refreshOutlinePreview()
    onAllowMotionChanged: if (visible) refreshOutlinePreview()
    onSimulateHasWindowsChanged: if (visible) refreshOutlinePreview()
    onShowOutlineWhenEmptyChanged: if (visible) refreshOutlinePreview()
    onShowOutlineWhenOpenChanged: if (visible) refreshOutlinePreview()
    onGlowIntensityChanged: if (visible) refreshOutlinePreview()
    onGlowSpreadChanged: if (visible) refreshOutlinePreview()
    onAccentColorChanged: if (visible) refreshOutlinePreview()
    onGlowColorChanged: if (visible) refreshOutlinePreview()
    onGlowGradientChanged: if (visible) refreshOutlinePreview()
    onStrokeSizeChanged: if (visible) refreshOutlinePreview()
    readonly property bool outlineIsOrbit: effectStyle === "orbit" || effectStyle === "orbitGlow"
    readonly property bool outlineUsesGlow: effectStyle === "glow" || effectStyle === "breathe" || effectStyle === "orbitGlow"
    readonly property bool outlineCanMove: outlineIsOrbit || effectStyle === "breathe"

    property bool autoCollapseSO: true
    property bool soLeftClickOpensLauncher: false
    property int launcherCategoryLayout: 0
    property string launcherSwitchShape: "capsule"
    property bool launcherSwitchColorOverride: false
    property color launcherSwitchColor: "#010111"
    property int launcherMaxSlots: 20
    property bool launcherOpacityOverride: false
    property real launcherOpacity: 0.7
    property bool launcherIconsWithNames: true
    property bool malvinaOptionsOpacityOverride: false
    property real malvinaOptionsOpacity: 0.7
    property bool autoCollapseTray: false
    property bool autoReturnRight: true
    property bool launcherIslandVisible: true
    property bool autoHideMalvina: true
    property bool alignedRight: true
    property string positionMode: "right"
    property real panelHeight: 48
    property real soledadHeight: 44
    property real malvinaHeight: 44
    property real soledadRadius: 22
    property real malvinaRadius: 22
    property real soledadMinWidth: 0
    property real malvinaWidth: 52
    property string soledadShape: "leftRoundRightSquare"
    property string malvinaShape: "rounded"
    property string malvinaGearButtonShape: "square"
    property string malvinaSearchButtonShape: "square"
    signal saveMalvinaButtonShapesRequested(string gearShape, string searchShape)
    signal settingsApplied()
    property string gripShape: "rounded"
    property string trayButtonShape: "rounded"
    // No reinterpretar un arrastre posterior como una orden de alineación.
    property bool alignmentEdited: false
    property bool taskActiveGlowEnabled: true
    property bool taskActiveDoubleBorderEnabled: false
    signal saveTaskActiveIndicatorRequested(bool glowEnabled, bool doubleBorderEnabled)
    property string taskDisplayMode: "icon"
    property string taskFrameShape: "rounded"
    property color taskFrameColor: "#ffffff"
    property real taskFrameOpacity: 0.12
    property real taskFrameWidth: 1
    signal saveTaskDisplayModeRequested(string mode)
    signal saveTaskFrameRequested(string shape, string color, real opacity, real width)
    property var outlineConfig: ({"soledad":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"malvina":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"tray":{"style":"solid","width":1,"color":"#45647a","opacity":1},"grip":{"style":"solid","width":1,"color":"#45647a","opacity":1}})
    readonly property string outlineTargetKey: ["soledad","malvina","tray","grip"][outlineTarget.currentIndex]
    readonly property var selectedOutline: outlineConfig[outlineTargetKey]
    function setOutlineField(field, value) {
        const next = JSON.parse(JSON.stringify(outlineConfig))
        next[outlineTargetKey][field] = value
        outlineConfig = next
    }
    signal saveOutlineRequested(var updated)
    signal saveGradientBreathingRequested(bool synchronizedWithSO, real intensity,
                                         bool breathingEnabled, real speed, bool syncIntensity)
    signal saveMalvinaGradientBreathingRequested(bool synchronizedWithSO, real intensity,
                                                bool breathingEnabled, real speed)
    signal saveIslandGradientRequested(bool soEnabled, string soEnd, string soDirection,
                                       bool malEnabled, string malEnd, string malDirection,
                                       int soCount, string soThird, int malCount, string malThird)

    signal saveClockAppearanceRequested(string family, int size,
                                        string textColor)
    signal saveSoTextRequested(string label, string color, string background,
                                real opacity, string fontFamily, int fontSize, bool bold,
                                string backgroundImage)
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
    signal saveSoClickMappingRequested(bool leftOpensLauncher)
    signal saveLauncherStyleRequested(int layoutMode, string switchShape,
                                     bool customColor, string switchColor,
                                     int maxVisibleSlots)
    signal saveLauncherOpacityRequested(bool customOpacity, real opacityValue)
    signal saveLauncherIconDisplayRequested(bool iconsWithNames)
    signal saveMalvinaOptionsOpacityRequested(bool customOpacity, real opacityValue)
    signal saveBehaviorRequested(bool collapseSO, bool collapseTray,
                                 bool returnRight, bool showMalvina,
                                 bool alignRight, bool alignmentEdited)
    signal alignNowRequested()
    signal alignCenterNowRequested()
    signal savePositionModeRequested(string mode)

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
        // Validación aislada: un error en una URL o nombre de proveedor
        // NO debe descartar cambios de forma, color o geometría.
        const validProviderUrls = malvinaWebTemplateValid(malvinaGoogleUrl) &&
            malvinaWebTemplateValid(malvinaDuckUrl) &&
            malvinaWebTemplateValid(malvinaYahooUrl) &&
            malvinaSiteValid(malvinaChatGptUrl) &&
            malvinaSiteValid(malvinaGeminiUrl) &&
            malvinaSiteValid(malvinaClaudeUrl)
        const names = [malvinaGoogleName, malvinaDuckName, malvinaYahooName,
                       malvinaChatGptName, malvinaGeminiName, malvinaClaudeName]
        const validProviderNames = names.every(malvinaNameValid)
        if (validProviderUrls && validProviderNames) {
            saveMalvinaNamesRequested(malvinaGoogleName.trim(), malvinaDuckName.trim(),
                                      malvinaYahooName.trim(), malvinaChatGptName.trim(),
                                      malvinaGeminiName.trim(), malvinaClaudeName.trim())
            saveMalvinaProvidersRequested(malvinaGoogleUrl, malvinaDuckUrl,
                                          malvinaYahooUrl, malvinaChatGptUrl,
                                          malvinaGeminiUrl, malvinaClaudeUrl)
        }
        saveMalvinaWebEnabledRequested(malvinaWebGoogleEnabled,
                                       malvinaWebDuckEnabled, malvinaWebYahooEnabled)
        saveMalvinaExtrasRequested(malvinaExtraWeb, malvinaExtraAi,
                                            malvinaHiddenWeb, malvinaHiddenAi, malvinaCompactAi)
        saveMalvinaButtonShapesRequested(malvinaGearButtonShape, malvinaSearchButtonShape)
        saveMalvinaOrderRequested(malvinaWebFirst, malvinaWebOrder, malvinaAiOrder)
        saveMalvinaConsentsRequested(malvinaAllowChatGpt,
                                    malvinaAllowGemini, malvinaAllowClaude)
        saveOutlineRequested(JSON.parse(JSON.stringify(outlineConfig)))
        saveTaskActiveIndicatorRequested(taskActiveGlowEnabled,
                                         taskActiveDoubleBorderEnabled)
        saveTaskDisplayModeRequested(taskDisplayMode)
        saveTaskFrameRequested(taskFrameShape, toHex(taskFrameColor),
                               taskFrameOpacity, taskFrameWidth)
        refreshOutlinePreview()
        saveGradientBreathingRequested(soledadGradientSyncBreathing,
                                      soledadGradientBreathingIntensity,
                                      soledadGradientBreathingEnabled,
                                      soledadGradientBreathingSpeed,
                                      soledadGradientSyncIntensity)
        saveMalvinaGradientBreathingRequested(malvinaGradientSyncBreathing,
                                              malvinaGradientBreathingIntensity,
                                              malvinaGradientBreathingEnabled,
                                              malvinaGradientBreathingSpeed)
        saveIslandGradientRequested(soledadGradientEnabled, toHex(soledadGradientEnd),
                                   soledadGradientDirection, malvinaGradientEnabled,
                                   toHex(malvinaGradientEnd), malvinaGradientDirection,
                                   soledadGradientColorCount, toHex(soledadGradientThird),
                                   malvinaGradientColorCount, toHex(malvinaGradientThird))
        saveClockAppearanceRequested(clockFontFamily, clockFontSize,
                                     toHex(clockTextColor))
        saveSoTextRequested(soTextLabel, toHex(soTextColor), toHex(soTextBackground),
                            soTextBackgroundOpacity, soTextFontFamily, soTextFontSize,
                            soTextBold, soTextBackgroundImage)
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
        saveSoClickMappingRequested(soLeftClickOpensLauncher)
        saveLauncherStyleRequested(launcherCategoryLayout, launcherSwitchShape,
                                   launcherSwitchColorOverride, toHex(launcherSwitchColor),
                                   launcherMaxSlots)
        saveLauncherOpacityRequested(launcherOpacityOverride, launcherOpacity)
        saveLauncherIconDisplayRequested(launcherIconsWithNames)
        saveMalvinaOptionsOpacityRequested(malvinaOptionsOpacityOverride,
                                           malvinaOptionsOpacity)
        savePositionModeRequested(positionMode)
        saveBehaviorRequested(autoCollapseSO, autoCollapseTray,
                              autoReturnRight, launcherIslandVisible,
                              alignedRight, alignmentEdited)
        paletteFeedback = "Aplicar guardó los valores seleccionados: Soledad " +
            toHex(soledadColor) + " → " + toHex(soledadGradientEnd) +
            " (" + (soledadGradientEnabled ? "degradado activo" : "sin degradado") +
            "), Malvina " + toHex(malvinaColor) + " → " +
            toHex(malvinaGradientEnd) +
            " (" + (malvinaGradientEnabled ? "degradado activo" : "sin degradado") +
            "). La luz SO no interviene en estos colores."
        console.log("SmartBar: paletas activas aplicadas",
                    "Soledad", toHex(soledadColor), toHex(soledadGradientEnd),
                    "Malvina", toHex(malvinaColor), toHex(malvinaGradientEnd))
        alignmentEdited = false
        // Confirmar los cambios de temas al pulsar Aplicar. Cancelar y la X
        // jamás sobreescriben ranuras ni la estética favorita.
        const themeSlots = ["dayPrevious", "day", "night", "custom", "library"]
        for (let i = 0; i < themeSlots.length; ++i) {
            const slot = themeSlots[i]
            if (pendingThemeChanges[slot] !== undefined)
                saveThemeSlotRequested(slot, pendingThemeChanges[slot])
        }
        if (pendingAlignAction === "center") alignCenterNowRequested()
        else if (pendingAlignAction === "right") alignNowRequested()
        settingsApplied()
        const before = lastAppliedSettings
        captureSettingsBaseline()
        // Si URL o nombres no eran válidos, los valores previos siguen
        // siendo el punto de restauración de esas claves, sin borrar el formulario.
        const invalid = []
        if (!validProviderUrls)
            invalid.push("malvinaGoogleUrl","malvinaDuckUrl","malvinaYahooUrl",
                         "malvinaChatGptUrl","malvinaGeminiUrl","malvinaClaudeUrl")
        if (!validProviderNames)
            invalid.push("malvinaGoogleName","malvinaDuckName","malvinaYahooName",
                         "malvinaChatGptName","malvinaGeminiName","malvinaClaudeName")
        if (invalid.length > 0 && before) {
            const committed = JSON.parse(JSON.stringify(lastAppliedSettings))
            for (let i = 0; i < invalid.length; ++i) {
                const key = invalid[i]
                if (before[key] !== undefined) committed[key] = before[key]
            }
            lastAppliedSettings = committed
        }
        appliedLabel.text = validProviderUrls && validProviderNames
            ? "Cambios aplicados y guardados. Podés seguir configurando."
            : "Apariencia y opciones aplicadas y guardadas. Corregí las URL o nombres de proveedores para guardarlos."
        // Aplicar deja la ventana abierta; Cancelar/X descarta lo no aplicado.
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
            settings.previewFactorySlot = ""
            if (settings.creatingNewTheme && useGifPaletteForTheme.checked)
                Qt.callLater(function() { paletteSampler.suggestFromImage("theme") })
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
        id: launcherSwitchColorDialog
        title: "Color propio del interruptor Aplicaciones / Archivos"
        onAccepted: settings.launcherSwitchColor = selectedColor
    }
    ColorDialog {
        id: activeGradientColorDialog
        title: "Editar color del degradado"
        property int targetIsland: 0
        property string slotName: "base"
        onAccepted: {
            if (targetIsland === 0) {
                if (slotName === "base") settings.soledadColor = selectedColor
                else if (slotName === "third") settings.soledadGradientThird = selectedColor
                else settings.soledadGradientEnd = selectedColor
            } else {
                if (slotName === "base") settings.malvinaColor = selectedColor
                else if (slotName === "third") settings.malvinaGradientThird = selectedColor
                else settings.malvinaGradientEnd = selectedColor
            }
        }
    }
    ColorDialog {
        id: samplePaletteColorDialog
        title: "Editar tonalidad de la paleta"
        property int sampleIndex: -1
        onAccepted: settings.editSampleHex(sampleIndex, settings.toHex(selectedColor))
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
        id: soTextFontDialog
        title: "Elegir fuente instalada para texto SO"
        // Selector nativo de fuentes: familias disponibles, vista previa
        // y lista desplazable, sin necesidad de escribir nombres exactos.
        onAccepted: settings.soTextFontFamily = selectedFont.family
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
        id: taskFrameColorDialog
        title: "Color de líneas de las fichas de aplicaciones"
        onAccepted: settings.taskFrameColor = selectedColor
    }
    ColorDialog {
        id: islandOutlineColorDialog
        title: "Color del contorno seleccionado"
        onAccepted: settings.setOutlineField("color", settings.toHex(selectedColor))
    }
    FileDialog {
        id: chooseTextBackground
        title: "Elegir imagen o GIF de fondo del texto SO"
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.webp *.gif)", "Todos los archivos (*)"]
        onAccepted: settings.soTextBackgroundImage = selectedFile.toString()
    }
    // Muestreo de GIF bajo demanda: nunca modifica el fondo por sí mismo.
    Timer {
        id: paletteImageLoadTimeout
        interval: 3500
        repeat: false
        onTriggered: {
            if (!paletteSampler.pending) return
            if (paletteSampler.isImageLoaded(paletteSampler.requestedUrl)) {
                paletteSampler.requestPaint()
            } else {
                paletteSampler.pending = false
                settings.paletteFeedback = "No se pudo leer la imagen. Revisá la ruta GIF/PNG."
            }
        }
    }
    Canvas {
        id: paletteSampler
        width: 64
        height: 64
        opacity: 0
        property string requestedUrl: ""
        property bool pending: false
        property string requestMode: "island"
        property int requestTargetIsland: 0
        onImageLoaded: {
            if (pending && isImageLoaded(requestedUrl)) requestPaint()
        }
        function suggestFromImage(mode) {
            requestMode = mode === "contour" ? "contour" : (mode === "theme" ? "theme" : "island")
            requestTargetIsland = appearanceTarget.currentIndex
            requestedUrl = settings.logoMode === "text"
                ? (settings.soTextBackgroundImage.length
                    ? settings.soTextBackgroundImage
                    : settings.defaultImage.toString())
                : settings.selectedImage.toString()
            if (!requestedUrl.length) {
                settings.paletteFeedback = "No se eligió ninguna imagen."
                return
            }
            settings.paletteFeedback = "Leyendo un fotograma del GIF para ofrecer tres tonos…"
            pending = true
            paletteImageLoadTimeout.restart()
            // Releer el archivo incluso si un GIF fue reemplazado en la
            // misma ruta. Sin cachear un resultado de análisis anterior.
            if (isImageLoaded(requestedUrl)) unloadImage(requestedUrl)
            loadImage(requestedUrl)
        }
        onPaint: {
            if (!pending || !isImageLoaded(requestedUrl)) return
            pending = false
            paletteImageLoadTimeout.stop()
            const activeUrl = settings.logoMode === "text"
                ? (settings.soTextBackgroundImage.length
                    ? settings.soTextBackgroundImage
                    : settings.defaultImage.toString())
                : settings.selectedImage.toString()
            if (activeUrl !== requestedUrl) {
                settings.resetSampledColors()
                settings.paletteFeedback = "La imagen cambió durante el análisis. Volvé a analizar."
                return
            }
            try {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.drawImage(requestedUrl, 0, 0, width, height)
                const raw = ctx.getImageData(0, 0, width, height).data
                // Un solo análisis cuando el usuario lo pide; sin muestreo
                // por cada fotograma GIF ni trabajo continuo de CPU/GPU.
                const colors = PaletteExtractor.extractDominantColors(raw, 3)
                if (colors.length === 0) {
                    settings.resetSampledColors()
                    settings.paletteFeedback = "No se detectaron suficientes tonos cromáticos " +
                        "en este fotograma; podés elegir cualquier HEX manualmente."
                    return
                }
                if (requestMode === "contour") {
                    // El botón explícito del editor de CONTORNO solo altera
                    // acento y brillo, nunca fondos o degradados de islas.
                    settings.chooseCoordinatedPalette(
                        "GIF (contorno)", Qt.lighter(colors[0].hex, 1.35),
                        Qt.lighter(colors[Math.min(1, colors.length - 1)].hex, 1.2),
                        "", "")
                } else {
                    settings.sampledColors = colors.map(function(x) { return x.hex })
                    settings.sampledSource = requestedUrl
                    const first = colors[0].hex
                    const second = colors.length > 1 ? colors[1].hex : first
                    const third = colors.length > 2 ? colors[2].hex : second
                    // Selección inicial automática: dos colores y degradado
                    // activado SOLO en la isla desde la que se inició el análisis.
                    // No modificar el brillo SO ni la otra isla. No guardar
                    // los presets hasta que el usuario lo solicite.
                    if (requestTargetIsland === 1) {
                        settings.malvinaColor = first
                        settings.malvinaGradientEnd = second
                        settings.malvinaGradientThird = third
                        settings.malvinaGradientColorCount = 2
                        settings.malvinaGradientEnabled = true
                    } else {
                        settings.soledadColor = first
                        settings.soledadGradientEnd = second
                        settings.soledadGradientThird = third
                        settings.soledadGradientColorCount = 2
                        settings.soledadGradientEnabled = true
                    }
                    if (requestMode === "theme") {
                        settings.malvinaColor = first
                        settings.malvinaGradientEnd = second
                        settings.malvinaGradientThird = third
                        settings.malvinaGradientEnabled = true
                        settings.malvinaGradientColorCount = 2
                        settings.accentColor = first
                        settings.glowColor = second
                    }
                    settings.paletteFeedback = "Paleta del GIF aplicada al editor: " +
                        first + " → " + second + ". Degradado de 2 colores activo. " +
                        (colors.length > 2
                            ? "El tono 3 está disponible si elegís 3 colores. "
                            : "") +
                        "Podés cambiar cada tono y pulsar Aplicar para guardarlo."
                }
            } catch (e) {
                settings.paletteFeedback = "No se pudo analizar el GIF: " + e
                console.warn("SmartBar: error de análisis de paleta", e)
            }
        }
    }
    ColorDialog {
        id: soTextColorDialog
        title: "Color del texto SO"
        onAccepted: settings.soTextColor = selectedColor
    }
    ColorDialog {
        id: soTextBackgroundDialog
        title: "Fondo del texto SO"
        onAccepted: settings.soTextBackground = selectedColor
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
            text: "Plasma SmartBar · Configuración"
            font.bold: true
            font.pixelSize: 17
            color: "white"
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: "Elegí el área del menú lateral. Cada isla tiene sus propios ajustes; " +
                  "los comunes están en General. Temas guarda estilos sin cambiar el panel KDE."
            color: "#d8d9e5"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            Rectangle {
                Layout.preferredWidth: Math.min(250, Math.max(200, settings.width * 0.28))
                Layout.fillHeight: true
                radius: 10
                color: "#292c3f"
                border.width: 1
                border.color: "#41475e"
                QQC2.ScrollView {
                    id: navigationScroll
                    anchors.fill: parent
                    anchors.margins: 7
                    clip: true
                    contentWidth: Math.max(0, availableWidth - 32)
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: Math.max(0, navigationScroll.availableWidth - 32)
                        spacing: 5
                    SettingsMenuButton {
                        sectionHeader: true
                        text: (settings.navigationGroup === "themes" ? "▾ " : "▸ ") + "TEMAS"
                        highlighted: settings.navigationGroup === "themes"
                        onClicked: settings.navigationGroup =
                            settings.navigationGroup === "themes" ? "" : "themes"
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "themes"
                        text: "Temas"
                        highlighted: settings.currentTab === 4
                        onClicked: settings.showThemes()
                    }
                    SettingsMenuButton {
                        sectionHeader: true
                        text: (settings.navigationGroup === "soledad" ? "▾ " : "▸ ") + "SOLEDAD · Isla 1"
                        highlighted: settings.navigationGroup === "soledad"
                        onClicked: settings.navigationGroup =
                            settings.navigationGroup === "soledad" ? "" : "soledad"
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Isla y launcher"
                        highlighted: settings.currentTab === 0 &&
                                     islandSubtabs.currentIndex === 1 &&
                                     settings.behaviorScope === "soledad"
                        onClicked: settings.showSoledadLauncher()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Botón de inicio SO"
                        highlighted: settings.currentTab === 1
                        onClicked: settings.showSoledadLogo()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Color y transparencia"
                        highlighted: settings.currentTab === 2 &&
                                     appearanceSubtabs.currentIndex === 0 &&
                                     settings.colorScope === "soledad"
                        onClicked: settings.showSharedColors(0)
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Figura y tamaño"
                        highlighted: settings.currentTab === 0 && islandSubtabs.currentIndex === 0 &&
                                     settings.geometryScope === "soledad"
                        onClicked: settings.showSoledadShape()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Cajón y ventanas"
                        highlighted: settings.currentTab === 2 && appearanceSubtabs.currentIndex === 1
                        onClicked: settings.showSoledadWindows()
                    }
                    SettingsMenuButton {
                        sectionHeader: true
                        text: (settings.navigationGroup === "malvina" ? "▾ " : "▸ ") + "MALVINA · Isla 2"
                        highlighted: settings.navigationGroup === "malvina"
                        onClicked: settings.navigationGroup =
                            settings.navigationGroup === "malvina" ? "" : "malvina"
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "malvina"
                        text: "Buscador Web e IA"
                        highlighted: settings.currentTab === 0 && islandSubtabs.currentIndex === 2
                        onClicked: settings.showMalvinaProviders()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "malvina"
                        text: "Figura y tamaño"
                        highlighted: settings.currentTab === 0 && islandSubtabs.currentIndex === 0 &&
                                     settings.geometryScope === "malvina"
                        onClicked: settings.showMalvinaShape()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "malvina"
                        text: "Color y transparencia"
                        highlighted: settings.currentTab === 2 &&
                                     appearanceSubtabs.currentIndex === 0 &&
                                     settings.colorScope === "malvina"
                        onClicked: settings.showSharedColors(1)
                    }
                    SettingsMenuButton {
                        sectionHeader: true
                        text: (settings.navigationGroup === "shared" ? "▾ " : "▸ ") + "GENERAL Y COMPARTIDAS"
                        highlighted: settings.navigationGroup === "shared"
                        onClicked: settings.navigationGroup =
                            settings.navigationGroup === "shared" ? "" : "shared"
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "shared"
                        text: "Posición y barra"
                        highlighted: settings.currentTab === 0 && islandSubtabs.currentIndex === 0 &&
                                     settings.geometryScope === "shared" && settings.geometrySection === 0
                        onClicked: settings.showSharedLayout()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "shared"
                        text: "Cajón de sistema y opciones comunes"
                        highlighted: settings.currentTab === 0 && islandSubtabs.currentIndex === 1 &&
                                     settings.behaviorScope === "shared"
                        onClicked: settings.showSharedBehavior()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "shared"
                        text: "Botones compartidos"
                        highlighted: settings.currentTab === 0 && islandSubtabs.currentIndex === 0 &&
                                     settings.geometryScope === "shared" && settings.geometrySection === 1
                        onClicked: settings.showSharedButtons()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "shared"
                        text: "Fondo y colores comunes"
                        highlighted: settings.currentTab === 2 && appearanceSubtabs.currentIndex === 0 &&
                                     settings.colorScope === "shared"
                        onClicked: settings.showSharedColors(2)
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "shared"
                        text: "Contornos y trazados"
                        highlighted: settings.currentTab === 2 && appearanceSubtabs.currentIndex === 2
                        onClicked: settings.showSharedOutlines()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "shared"
                        text: "Ayuda"
                        highlighted: settings.currentTab === 3
                        onClicked: {
                            settings.navigationGroup = "shared"
                            settings.currentTab = 3
                        }
                    }
                    Item { Layout.preferredHeight: 8 }
                    }
                }
            }
            StackLayout {
                id: pages
                currentIndex: settings.currentTab
                Layout.fillWidth: true
                Layout.fillHeight: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                QQC2.TabBar {
                    id: islandSubtabs
                    visible: false
                    Layout.fillWidth: true
                    SettingsPageTab { text: "Posición y figuras"; width: islandSubtabs.width / 3 }
                    SettingsPageTab { text: "Autocontracción"; width: islandSubtabs.width / 3 }
                    SettingsPageTab { text: "Proveedores Malvina"; width: islandSubtabs.width / 3 }
                }
                StackLayout {
                    currentIndex: islandSubtabs.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
            // 4. Islas y posición de isla y posición, sin añadir isla extra.
            QQC2.ScrollView {
                id: positionScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, positionScroll.availableWidth - 32)
                    spacing: 16
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: "Ubicación"
                            visible: settings.geometryScope === "shared"
                            highlighted: settings.geometrySection === 0
                            onClicked: { settings.geometrySection = 0; positionScroll.contentItem.contentY = 0 }
                        }
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: settings.geometryScope === "shared" ? "Botones comunes" : "Figuras"
                            highlighted: settings.geometrySection === 1
                            onClicked: { settings.geometrySection = 1; positionScroll.contentItem.contentY = 0 }
                        }
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: "Tamaños"
                            visible: settings.geometryScope !== "shared"
                            highlighted: settings.geometrySection === 2
                            onClicked: { settings.geometrySection = 2; positionScroll.contentItem.contentY = 0 }
                        }
                    }
                    ColumnLayout {
                        visible: settings.geometrySection === 0
                        Layout.fillWidth: true
                        spacing: 10
                    QQC2.Label {
                        text: "Ubicación, visibilidad y altura general de la barra"
                        color: "#ddd6e8"; Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Posición general de las islas"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        text: "Activar Malvina (isla 2)"
                        checked: settings.launcherIslandVisible
                        onToggled: settings.launcherIslandVisible = checked
                    }
                    QQC2.Label {
                        text: "Activada significa disponible, no siempre visible. Al desactivarla, Malvina deja de responder y no aparece por proximidad."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.launcherIslandVisible
                        text: "Visibilidad de Malvina"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        visible: settings.launcherIslandVisible
                        Layout.fillWidth: true
                        model: ["Automática: se oculta sola (predeterminado)",
                                "Siempre visible (opcional)"]
                        currentIndex: settings.autoHideMalvina ? 0 : 1
                        onActivated: function(index) {
                            settings.autoHideMalvina = index === 0
                        }
                    }
                    QQC2.Label {
                        visible: settings.launcherIslandVisible
                        text: settings.autoHideMalvina
                            ? "Modo automático: Malvina sigue activa aunque esté escondida. Aparece al sostener el cursor 0,6 s en su ubicación y se oculta al salir. El menú de los seis puntos la muestra 1 s al activarla."
                            : "Modo siempre visible: Malvina permanece a la vista mientras esté activa, salvo protección de ventanas maximizadas o pantalla completa."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Altura general compartida"
                        font.bold: true
                        color: "white"
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
                    QQC2.Label {
                        text: "Alineación predeterminada de Soledad"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["A la derecha (SO abre a la izquierda)",
                                "En el centro (SO abre a la derecha)"]
                        currentIndex: settings.positionMode === "center" ? 1 : 0
                        onActivated: function(index) {
                            settings.positionMode = index === 1 ? "center" : "right"
                            settings.alignmentEdited = false
                        }
                    }
                    QQC2.Label {
                        visible: settings.positionMode === "center"
                        text: "La isla se centra mientras está contraída y las fichas crecen hacia la derecha. La altura no cambia; al expandir se controla el espacio disponible."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.positionMode === "center"
                        text: "Centrar isla 1 al aplicar"
                        onClicked: {
                            settings.positionMode = "center"
                            settings.pendingAlignAction = "center"
                            settings.alignmentEdited = true
                        }
                    }
                    QQC2.CheckBox {
                        visible: settings.positionMode === "right"
                        text: "Alinear isla 1 a la derecha"
                        checked: settings.alignedRight
                        onToggled: settings.alignedRight = checked
                        onClicked: settings.alignmentEdited = true
                    }
                    QQC2.CheckBox {
                        visible: settings.positionMode === "right" && settings.alignedRight
                        text: "Volver a la derecha al desmaximizar"
                        checked: settings.autoReturnRight
                        onToggled: settings.autoReturnRight = checked
                    }
                    QQC2.Label {
                        visible: settings.positionMode === "right" && settings.alignedRight
                        text: "El regreso al desmaximizar está activado por defecto. No impide mover Soledad manualmente."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.positionMode === "right"
                        text: "Mover isla 1 a la derecha al aplicar"
                        onClicked: {
                            settings.positionMode = "right"
                            settings.alignedRight = true
                            settings.pendingAlignAction = "right"
                            settings.alignmentEdited = true
                        }
                    }
                    QQC2.Label {
                        text: "La nueva posición se confirma con Aplicar; Cancelar la descarta. La posición por aplicación sigue pendiente de desarrollo."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Restablecer posición y altura general"
                        onClicked: {
                            settings.autoReturnRight = true
                            settings.alignedRight = true
                            settings.positionMode = "right"
                            settings.alignmentEdited = true
                            settings.panelHeight = 48
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "No modifica las figuras ni los tamaños particulares de las islas."
                    }
                    }
                    ColumnLayout {
                        visible: settings.geometrySection === 1
                        Layout.fillWidth: true
                        spacing: 10
                    QQC2.Label {
                        text: "Terminaciones visuales"
                        color: "white"; font.bold: true
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "soledad"
                        text: "Soledad: el modelo inicial conserva la izquierda redondeada y termina recto a la derecha."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "soledad"
                        text: "SOLEDAD · Figura exterior"
                        color: "#cde6f5"; font.bold: true
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "soledad"
                        text: "Forma de Soledad"; color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        visible: settings.geometryScope === "soledad"
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
                        visible: settings.geometryScope === "malvina"
                        text: "MALVINA · Figura exterior y controles"
                        color: "#cde6f5"; font.bold: true
                    }
                    QQC2.Label {
                        text: "Forma de Malvina";
                        color: "white"
                        visible: settings.geometryScope === "malvina"
                    }
                    QQC2.ComboBox {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        model: ["Redondeada (inicial)", "Cuadrada",
                                "Izquierda redondeada / derecha recta",
                                "Izquierda recta / derecha redondeada",
                                "Punta triangular izquierda / derecha recta",
                                "Cápsula (extremos totalmente redondos)"]
                        id: malvinaFigureSelector
                        currentIndex: Math.max(0, ["rounded","square","leftRoundRightSquare",
                                       "leftSquareRightRound","leftTip","capsule"].indexOf(settings.malvinaShape))
                        onActivated: function(i) {
                            settings.malvinaShape = ["rounded","square",
                                "leftRoundRightSquare","leftSquareRightRound","leftTip","capsule"][i]
                        }
                    }
                    QQC2.Label {
                        text: "Botón engranaje de Malvina"
                        color: "white"
                        visible: settings.geometryScope === "malvina"
                    }
                    QQC2.ComboBox {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        model: ["Cuadrado (inicial)", "Cuadrado con esquinas redondeadas", "Circular", "Cápsula"]
                        currentIndex: Math.max(0,["square","rounded","circle","capsule"].indexOf(settings.malvinaGearButtonShape))
                        onActivated: function(i) {
                            settings.malvinaGearButtonShape = ["square","rounded","circle","capsule"][i]
                        }
                    }
                    QQC2.Label {
                        text: "Botón lupa de Malvina"
                        color: "white"
                        visible: settings.geometryScope === "malvina"
                    }
                    QQC2.ComboBox {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        model: ["Cuadrado (inicial)", "Cuadrado con esquinas redondeadas", "Circular", "Cápsula"]
                        currentIndex: Math.max(0,["square","rounded","circle","capsule"].indexOf(settings.malvinaSearchButtonShape))
                        onActivated: function(i) {
                            settings.malvinaSearchButtonShape = ["square","rounded","circle","capsule"][i]
                        }
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "shared"
                        text: "COMPARTIDAS · Controles del panel"
                        color: "#cde6f5"; font.bold: true
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "shared"
                        text: "Agarre de seis puntos"; color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        visible: settings.geometryScope === "shared"
                        model: ["Cuadrado", "Cuadrado con bordes redondeados (inicial)"]
                        currentIndex: settings.gripShape === "rounded" ? 1 : 0
                        onActivated: function(i) {
                            settings.gripShape = i === 1 ? "rounded" : "square"
                        }
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "shared"
                        text: "Botón de bandeja simulada"; color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        visible: settings.geometryScope === "shared"
                        model: ["Redondeado (inicial)", "Cuadrado"]
                        currentIndex: settings.trayButtonShape === "square" ? 1 : 0
                        onActivated: function(i) {
                            settings.trayButtonShape = i === 1 ? "square" : "rounded"
                        }
                    }
                    }
                    ColumnLayout {
                        visible: settings.geometrySection === 2
                        Layout.fillWidth: true
                        spacing: 10
                    QQC2.Label { text: settings.geometryScope === "soledad" ? "Tamaño de Soledad" : "Tamaño de Malvina"; color: "white"; font.bold: true }
                    QQC2.Label {
                        text: "La altura elegida es constante durante el uso. Al aumentar una isla, Aplicar también aumenta la altura general si hace falta (máximo 120 px, con 4 px de margen)."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        visible: settings.geometryScope === "soledad"
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
                        visible: settings.geometryScope === "malvina"
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
                        visible: settings.geometryScope === "soledad" && settings.soledadShape !== "square" && settings.soledadShape !== "leftTip"
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
                        visible: settings.geometryScope === "malvina" && settings.malvinaShape !== "square" && settings.malvinaShape !== "leftTip" && settings.malvinaShape !== "capsule"
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
                        visible: settings.geometryScope === "soledad"
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
                        visible: settings.geometryScope === "malvina"
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
                        text: settings.geometryScope === "soledad"
                            ? "Restablecer figura y tamaño SOLEDAD"
                            : "Restablecer figura y tamaño MALVINA"
                        onClicked: {
                            if (settings.geometryScope === "soledad") {
                                settings.soledadHeight = 44
                                settings.soledadRadius = 22
                                settings.soledadMinWidth = 0
                                settings.soledadShape = "leftRoundRightSquare"
                            } else if (settings.geometryScope === "malvina") {
                                settings.malvinaHeight = 44
                                settings.malvinaRadius = 22
                                settings.malvinaWidth = 52
                                settings.malvinaShape = "rounded"
                            }
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Solo modifica la isla que estás configurando."
                    }
                    }
                }
            }

            // 5. Autocontracción: preferencias distintas; sin temporizador.
            QQC2.ScrollView {
                id: collapseScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, collapseScroll.availableWidth - 32)
                    spacing: 16
                    ColumnLayout {
                        visible: settings.behaviorScope === "soledad"
                        Layout.fillWidth: true
                        spacing: 12
                    QQC2.Label {
                        text: "Isla y launcher · Soledad"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Posición de la isla en la barra…"
                        onClicked: settings.showSharedLayout()
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Figura y tamaño de la isla Soledad…"
                        onClicked: settings.showSoledadShape()
                    }
                    QQC2.Label {
                        text: "Acciones del botón SO"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: [
                            "Izquierdo: Launcher de aplicaciones · Derecho: Cajón de aplicaciones",
                            "Izquierdo: Cajón de aplicaciones · Derecho: Launcher de aplicaciones (inicial)"
                        ]
                        currentIndex: settings.soLeftClickOpensLauncher ? 0 : 1
                        onActivated: function(i) { settings.soLeftClickOpensLauncher = i === 0 }
                    }
                    QQC2.Label {
                        text: "Podés invertir los clics cuando quieras. El mensaje al pasar el cursor sobre SO muestra las acciones elegidas. Mantener pulsado el botón sigue abriendo el lanzador."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Launcher de aplicaciones · Soledad"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: "El fondo, degradado, contorno, transparencia y respiración del launcher siguen automáticamente los de Soledad."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Íconos de sectores y aplicaciones"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Ícono y nombre (predeterminado)", "Solo nombre"]
                        currentIndex: settings.launcherIconsWithNames ? 0 : 1
                        onActivated: function(i) { settings.launcherIconsWithNames = i === 0 }
                    }
                    QQC2.Label {
                        text: "Ubicación del panel de aplicaciones"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: [
                            "A · Original: opciones a la derecha, cerca del cursor (inicial)",
                            "B · Opciones a la izquierda, cuadro principal fijo"
                        ]
                        currentIndex: settings.launcherCategoryLayout
                        onActivated: function(i) { settings.launcherCategoryLayout = i }
                    }
                    QQC2.Label {
                        text: "Forma del interruptor Aplicaciones / Archivos"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Cápsula", "Cuadrado redondeado", "Cuadrado"]
                        currentIndex: ["capsule", "rounded", "square"].indexOf(settings.launcherSwitchShape)
                        onActivated: function(i) {
                            settings.launcherSwitchShape = ["capsule", "rounded", "square"][i]
                        }
                    }
                    QQC2.CheckBox {
                        text: "Elegir un color propio para el interruptor"
                        checked: settings.launcherSwitchColorOverride
                        onToggled: settings.launcherSwitchColorOverride = checked
                    }
                    QQC2.Button {
                        text: "Elegir color del interruptor…"
                        visible: settings.launcherSwitchColorOverride
                        onClicked: launcherSwitchColorDialog.open()
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        QQC2.Label {
                            text: "Máximo de filas antes de desplazarse"
                            color: "white"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        QQC2.SpinBox {
                            from: 5
                            to: 20
                            editable: true
                            value: settings.launcherMaxSlots
                            onValueChanged: settings.launcherMaxSlots = value
                        }
                    }
                    QQC2.Label {
                        text: "El launcher también se limita al espacio inferior disponible. En Archivos busca por nombre dentro de la carpeta actual; la búsqueda global sigue pendiente."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "soledad"
                        text: "Autocontracción del cajón de aplicaciones"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        visible: settings.behaviorScope === "soledad"
                        text: "SO: contraer después de elegir una ventana"
                        checked: settings.autoCollapseSO
                        onToggled: settings.autoCollapseSO = checked
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "soledad"
                        text: "Activado por defecto. Podés dejar SO abierto desmarcando esta opción."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "shared"
                        text: "Cajón de sistema (bandeja)"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        visible: settings.behaviorScope === "shared"
                        text: "Bandeja: contraer después de utilizar un icono"
                        checked: settings.autoCollapseTray
                        onToggled: settings.autoCollapseTray = checked
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "shared"
                        text: "Desactivado por defecto. La apertura del lanzador no contrae ninguna sección."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "shared"
                        text: "Sin temporizador de inactividad: el cierre solo se dispara por la acción aprobada o por falta de espacio."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.behaviorScope === "soledad"
                        text: "Restablecer autocontracción SO"
                        onClicked: settings.autoCollapseSO = true
                    }
                    QQC2.Button {
                        visible: settings.behaviorScope === "shared"
                        text: "Restablecer autocontracción de bandeja"
                        onClicked: settings.autoCollapseTray = false
                    }
                }
            }
            MalvinaProvidersPage {
                settingsTarget: settings
            }

                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                // Única página continua: imagen o texto, encuadre, reloj y luz SO.
                QQC2.ScrollView {
                    id: logoScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: Math.max(0, availableWidth - 32)
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                    ColumnLayout {
                        width: Math.max(0, logoScroll.availableWidth - 32)
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
                                soTextFontDialog.selectedFont = Qt.font({
                                    family: settings.soTextFontFamily,
                                    pixelSize: settings.soTextFontSize,
                                    bold: settings.soTextBold
                                })
                                soTextFontDialog.open()
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
                            onClicked: { soTextColorDialog.selectedColor = settings.soTextColor; soTextColorDialog.open() }
                        }
                        Rectangle { width: 30; height: 22; radius: 4; color: settings.soTextColor }
                        QQC2.Button {
                            text: "Fondo…"
                            onClicked: { soTextBackgroundDialog.selectedColor = settings.soTextBackground; soTextBackgroundDialog.open() }
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
                            onClicked: chooseTextBackground.open()
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
                        onClicked: paletteSampler.suggestFromImage("contour")
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
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6
                QQC2.TabBar {
                    id: appearanceSubtabs
                    visible: false
                    Layout.fillWidth: true
                    SettingsPageTab { text: "Color por isla"; width: appearanceSubtabs.width / 3 }
                    SettingsPageTab { text: "Fichas SO"; width: appearanceSubtabs.width / 3 }
                    SettingsPageTab { text: "Contornos compartidos"; width: appearanceSubtabs.width / 3 }
                }
                StackLayout {
                    currentIndex: appearanceSubtabs.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
            // 3. Apariencia: las islas mantienen sus preferencias independientes.
            QQC2.ScrollView {
                id: appearanceScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, appearanceScroll.availableWidth - 32)
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
                                islandColorDialog.editingTarget = appearanceTarget.currentIndex
                                islandColorDialog.selectedColor = settings.activeColor
                                islandColorDialog.open()
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
                        columns: appearanceScroll.availableWidth >= 740 ? 3
                            : (appearanceScroll.availableWidth >= 470 ? 2 : 1)
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
                                            samplePaletteColorDialog.sampleIndex = index
                                            samplePaletteColorDialog.selectedColor =
                                                settings.sampleHex(index)
                                            samplePaletteColorDialog.open()
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
                                        activeGradientColorDialog.targetIsland =
                                            appearanceTarget.currentIndex
                                        activeGradientColorDialog.slotName = slotName
                                        activeGradientColorDialog.selectedColor =
                                            settings.islandColor(slotName)
                                        activeGradientColorDialog.open()
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

            QQC2.ScrollView {
                id: taskStylesScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, taskStylesScroll.availableWidth - 32)
                    spacing: 14
                    QQC2.Label {
                        text: "Presentación de aplicaciones y líneas"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: "Indicador de aplicación activa"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        text: "Iluminar la aplicación activa con el efecto de SO"
                        checked: settings.taskActiveGlowEnabled
                        onToggled: settings.taskActiveGlowEnabled = checked
                    }
                    QQC2.CheckBox {
                        text: "Marcar la aplicación activa con doble línea"
                        checked: settings.taskActiveDoubleBorderEnabled
                        onToggled: settings.taskActiveDoubleBorderEnabled = checked
                    }
                    QQC2.Label {
                        text: "La luz usa el efecto del botón SO. La doble línea usa el color, grosor y transparencia del contorno de Soledad. Podés activar ambos, uno solo o ninguno."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    QQC2.Label {
                        text: "Cómo mostrar cada aplicación"
                        color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Solo nombre", "Icono y nombre", "Solo icono"]
                        currentIndex: Math.max(0, ["text", "both", "icon"]
                            .indexOf(settings.taskDisplayMode))
                        onActivated: function(i) {
                            settings.taskDisplayMode = ["text", "both", "icon"][i]
                        }
                    }
                    QQC2.Label {
                        text: "En Solo icono, al pasar el cursor aparece el nombre de la aplicación."
                        visible: settings.taskDisplayMode === "icon"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                    }
                    QQC2.Label {
                        text: "Fichas de aplicaciones abiertas en SO"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: "El interior de las fichas conserva el degradado de Soledad. Configurá únicamente su marco."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label { text: "Forma de las fichas"; color: "white" }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Rectángulo con esquinas redondeadas",
                                "Rectángulo cuadrado", "Sin recuadro"]
                        currentIndex: Math.max(0, ["rounded", "square", "none"]
                            .indexOf(settings.taskFrameShape))
                        onActivated: function(i) {
                            settings.taskFrameShape = ["rounded", "square", "none"][i]
                        }
                    }
                    QQC2.Label {
                        text: "Color de las líneas"
                        color: "white"
                        visible: settings.taskFrameShape !== "none"
                    }
                    RowLayout {
                        visible: settings.taskFrameShape !== "none"
                        Layout.fillWidth: true
                        QQC2.Button {
                            text: "Elegir color de línea…"
                            onClicked: {
                                taskFrameColorDialog.selectedColor = settings.taskFrameColor
                                taskFrameColorDialog.open()
                            }
                        }
                        Rectangle {
                            width: 34; height: 24; radius: 4
                            color: settings.taskFrameColor
                        }
                    }
                    QQC2.Label {
                        text: "Intensidad de las líneas"
                        color: "white"
                        visible: settings.taskFrameShape !== "none"
                    }
                    RowLayout {
                        visible: settings.taskFrameShape !== "none"
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.taskFrameOpacity
                            onMoved: settings.taskFrameOpacity = value
                        }
                        QQC2.Label {
                            text: Math.round(settings.taskFrameOpacity * 100) + "%"
                            color: "white"
                        }
                    }
                    QQC2.Label {
                        text: "Grosor de línea"
                        color: "white"
                        visible: settings.taskFrameShape !== "none"
                    }
                    RowLayout {
                        visible: settings.taskFrameShape !== "none"
                        Layout.fillWidth: true
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0.5; to: 3; stepSize: 0.5
                            value: settings.taskFrameWidth
                            onMoved: settings.taskFrameWidth = value
                        }
                        QQC2.Label {
                            text: settings.taskFrameWidth.toFixed(1) + " px"
                            color: "white"
                        }
                    }

                }
            }

            // Contornos de superficies compartidos: un único editor, cuatro valores independientes.
            QQC2.ScrollView {
                id: sharedOutlineScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, sharedOutlineScroll.availableWidth - 32)
                    spacing: 14
                    QQC2.Label {
                        text: "Editá el contorno de cada superficie por separado.\n" +
                              "Soledad, Malvina, bandeja y agarre conservan sus propios valores.\n" +
                              "Pulsá Aplicar para guardar sin cerrar."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
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
                }
            }
                }
            }

            // 6. Acerca de: contacto publicado con autorización del
            // mantenedor. Sin botones ni referencias a donaciones.
            QQC2.ScrollView {
                id: aboutScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, aboutScroll.availableWidth - 32)
                    spacing: 16
                    QQC2.Label {
                        text: "Ayuda rápida"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                    }
                    QQC2.Label {
                        text: "Soledad: botón SO, logo, efectos y fichas de ventanas.\n" +
                              "Malvina: proveedores Web/IA, figura, controles y colores propios.\n" +
                              "Compartidas: geometría, posición, comportamiento y fondos.\n" +
                              "Colores: seleccioná la isla o superficie que querés editar.\n" +
                              "Aplicar guarda los cambios sin cerrar la ventana."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Abrir manual del proyecto"
                        icon.name: "help-contents"
                        onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar/blob/prototype/v0.1-islas-so/docs/MANUAL_MAESTRO.md")
                    }
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

            // Temas: selector único, contraído inicialmente. La lista se
            // despliega con scroll; no usar mosaico de tarjetas/cuadritos.
            QQC2.ScrollView {
                id: themesScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, themesScroll.availableWidth - 32)
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
                        text: "Elegí Día, Atardecer o Noche. Los temas nuevos se suman al mismo desplegable."
                    }
                    // Dos controles juntos: el segundo solo despliega la
                    // configuración horaria; no cambia el estado automático.
                    RowLayout {
                        Layout.fillWidth: true
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
                        visible: settings.scheduleMenuExpanded
                        spacing: 10
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
                                model: settings.themeScheduleSlotCount
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
                                        model: ["Día", "Atardecer", "Noche"]
                                        currentIndex: settings.scheduleTheme(index) === "day" ? 0
                                            : settings.scheduleTheme(index) === "sunset" ? 1 : 2
                                        onActivated: function(i) {
                                            settings.updateScheduleTheme(index, ["day", "sunset", "night"][i])
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
                    // Un único desplegable. Sin tarjetas, subtítulos ni botones "Usar".
                    // Primero las instantáneas locales que el usuario ya guardó.
                    // Selector básico con Popup propio: evita el ComboBox con lista vacía.
                    QQC2.Button {
                        id: themeSelectorButton
                        Layout.fillWidth: true
                        text: "Elegir tema  " + (themeOptionsPopup.opened ? "▴" : "▾")
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
                        height: Math.min(240, 50 * (3 + settings.otherNamedThemes.length) + 8)
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
                                Repeater {
                                    model: 3 + settings.otherNamedThemes.length
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
                                                slot = settings.themeDayJson.length ? "day" :
                                                    (settings.factorySunsetAvailable ? "sunset" : "")
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
                                                settings.previewFactorySlot = ""
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
                            onClicked: chooseImage.open()
                        }
                        QQC2.CheckBox {
                            id: useGifPaletteForTheme
                            text: "Usar colores del GIF para todo el tema"
                            checked: false
                            onToggled: {
                                if (checked && settings.logoMode === "custom")
                                    paletteSampler.suggestFromImage("theme")
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
                    QQC2.Label {
                        Layout.fillWidth: true
                        text: settings.themeStatus
                        color: "#b9e5ff"
                        wrapMode: Text.WordWrap
                    }
                }
            }
            }
        }

        // Pie fijo: Cancelar izquierda y Aplicar derecha, sin botón Cerrar.
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
                text: "Cancelar"
                onClicked: settings.close()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Descartar los cambios pendientes desde el último Aplicar"
            }
            QQC2.Button {
                text: "Aplicar"
                highlighted: true
                onClicked: settings.applyChanges()
            }
        }
    }
}
