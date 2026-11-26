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
import "ThemeLibrary.js" as ThemeLibrary
import "ThemePack.js" as ThemePack
import "WallpaperFadeDuration.js" as WallpaperFadeDuration
import "assets/FactoryNightTheme.js" as FactoryNightTheme
import "assets/FactorySunsetTheme.js" as FactorySunsetTheme
import "assets/FactoryDayTheme.js" as FactoryDayTheme

Window {
    id: settings
    visible: false
    // Ventana de escritorio independiente: KDE/KWin ofrece título y controles
    // nativos para mover, minimizar, maximizar, restaurar y cerrar.
    // No bloquear ni mantener encima el visor de Soledad/Malvina tras Aplicar.
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint |
           Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint
    transientParent: null
    modality: Qt.NonModal
    title: "Plasma SmartBar · Configuración"
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
    readonly property var editableSettingsKeys: ["logoMode","themeDayJson","themeDayPreviousJson","themeNightJson","themeCustomJson","themeLibraryJson","filePath","shape","cropFitMode","cropZoom","cropPanX","cropPanY","cropRotation","enableGif","clockFontFamily","clockFontSize","clockTextColor","panelHeight","soledadHeight","malvinaHeight","soledadRadius","malvinaRadius","soledadMinWidth","malvinaWidth","malvinaGoogleUrl","malvinaDuckUrl","malvinaYahooUrl","malvinaChatGptUrl","malvinaGeminiUrl","malvinaClaudeUrl","malvinaBrowserId","malvinaWebFirst","malvinaWebOrder","malvinaAiOrder","malvinaExtraWeb","malvinaExtraAi","malvinaHiddenWeb","malvinaHiddenAi","malvinaCompactAi","malvinaGoogleName","malvinaDuckName","malvinaYahooName","malvinaChatGptName","malvinaGeminiName","malvinaClaudeName","malvinaWebGoogleEnabled","malvinaWebDuckEnabled","malvinaWebYahooEnabled","malvinaAllowChatGpt","malvinaAllowGemini","malvinaAllowClaude","soledadShape","malvinaShape","malvinaGearButtonShape","malvinaSearchButtonShape","outlineConfig","taskActiveGlowEnabled","taskActiveDoubleBorderEnabled","taskDisplayMode","taskCloseMode","taskFrameShape","taskFrameColor","taskFrameOpacity","taskFrameWidth","gripShape","trayButtonShape","soButtonFrameShape","soButtonWidth","soTextLabel","soTextColor","soTextBackground","soTextBackgroundOpacity","soTextFontFamily","soTextFontSize","soTextBold","soTextBackgroundImage","soledadColor","malvinaColor","soledadGradientEnabled","soledadGradientEnd","soledadGradientThird","soledadGradientColorCount","soledadGradientDirection","soledadGradientSyncBreathing","soledadGradientSyncIntensity","soledadGradientBreathingEnabled","soledadGradientBreathingIntensity","soledadGradientBreathingSpeed","malvinaGradientSyncBreathing","malvinaGradientBreathingEnabled","malvinaGradientBreathingIntensity","malvinaGradientBreathingSpeed","malvinaGradientEnabled","malvinaGradientEnd","malvinaGradientThird","malvinaGradientColorCount","malvinaGradientDirection","backgroundColor","soledadOpacity","malvinaOpacity","backgroundOpacity","showBackground","trayButtonColorOverride","trayButtonColor","trayButtonOpacity","gripButtonColorOverride","gripButtonColor","gripButtonOpacity","effectStyle","accentColor","strokeSize","allowMotion","orbitSpeed","trailPercent","trailStyle","glowColor","glowIntensity","glowSpread","pulseSpeed","pulseDepth","glowGradient","showOutlineWhenEmpty","showOutlineWhenOpen","autoCollapseSO","soLeftClickOpensLauncher","launcherCategoryLayout","launcherSwitchShape","launcherSwitchColorOverride","launcherSwitchColor","launcherMaxSlots","launcherOpacityOverride","launcherOpacity","launcherIconsWithNames","malvinaOptionsOpacityOverride","malvinaOptionsOpacity","autoCollapseTray","autoReturnRight","launcherIslandVisible","autoHideMalvina","alignedRight","positionMode","alignmentEdited"]
    readonly property var editableColorKeys: ["soTextColor","soTextBackground","clockTextColor","soledadColor","malvinaColor","soledadGradientEnd","soledadGradientThird","malvinaGradientEnd","malvinaGradientThird","backgroundColor","trayButtonColor","gripButtonColor","accentColor","glowColor","launcherSwitchColor","taskFrameColor"]
    property var lastAppliedSettings: ({})
    property var pendingThemeChanges: ({})
    property bool baselineLoaded: false
    // Solo el ensayo conjunto informa estado verificable de Aplicar.
    property bool runtimeApplyFailed: false
    property string runtimeApplyNote: ""
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
    // La selección predeterminada del pack no abre su configuración visual.
    // Solo una elección explícita del pack habilita el submenú; no es persistente.
    property bool packOptionsVisible: false
    property int wallpaperFadeAmount: 3
    property string wallpaperFadeUnit: "seconds"
    property string wallpaperFadeError: ""
    function setWallpaperFade(amount, unit) {
        if (!WallpaperFadeDuration.valid(amount,unit)) {
            wallpaperFadeError = "Duración inválida. Segundos: 1–3600, minutos: 1–240, horas: 1–24."
            return false
        }
        wallpaperFadeAmount = amount
        wallpaperFadeUnit = unit
        wallpaperFadeError = ""
        saveWallpaperFadeRequested(amount,unit)
        return true
    }
    property bool barThemeTransitionEnabled: true
    property bool themeScheduleEnabled: true
    // Las claves heredadas pertenecen a Playa 24hs; el editor muestra
    // por separado el modo/cantidad del pack activo sin reescribirlas.
    property bool playaScheduleEnabled: true
    property int playaScheduleSlotCount: 4
    // Playa 24hs es el pack inicial. Biblioteca y selección son independientes
    // de themeLibraryJson: jamás se reescriben temas personales antiguos.
    property string selectedThemePackId: ThemePack.DEFAULT_ID
    property string themePackLibraryJson: "[]"
    readonly property var savedThemePacks: ThemePack.parse(themePackLibraryJson)
    readonly property var selectedThemePack: ThemePack.find(savedThemePacks, selectedThemePackId)
    property bool creatingNewPack: false
    property string newPackName: ""
    property var pendingPackMemberIndexes: ([])
    readonly property var packCandidateItems: [
        {kind: "preset", theme: "day", name: "Día"},
        {kind: "preset", theme: "sunset", name: "Atardecer"},
        {kind: "preset", theme: "night", name: "Noche"}
    ].concat(savedThemeLibrary.map(function(item) {
        return {kind: "snapshot", name: item.name, jsonData: item.jsonData}
    }))
    property int themeScheduleSlotCount: 4
    property string themeScheduleSlots3Json:
        ThemeSchedule.serialize(ThemeSchedule.defaults(3), 3)
    property string themeScheduleSlots4Json:
        ThemeSchedule.serialize(ThemeSchedule.defaults(4), 4)
    property string scheduleError: ""
    readonly property var scheduleSlots: selectedThemePack
        ? ThemePack.schedule(selectedThemePack, themeScheduleSlotCount)
        : ThemeSchedule.read(
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
        if (index < 0 || index >= scheduleSlots.length) return ""
        return selectedThemePack ? scheduleSlots[index].member : scheduleSlots[index].theme
    }
    function selectThemePack(id) {
        const pack = ThemePack.find(savedThemePacks, id)
        if (id !== ThemePack.DEFAULT_ID && !pack)
            return false
        // Al elegir por primera vez un pack anterior a esta función,
        // capturar su modo y número de franjas sin tocar slots3/slots4.
        if (pack) {
            const upgraded = ThemePack.ensurePreferences(pack,
                playaScheduleEnabled, playaScheduleSlotCount)
            if (upgraded !== pack && !persistCustomPack(upgraded)) return false
        }
        selectedThemePackId = id
        packOptionsVisible = true
        scheduleMenuExpanded = false
        themeScheduleEnabled = selectedThemePack
            ? ThemePack.automatic(selectedThemePack, playaScheduleEnabled)
            : playaScheduleEnabled
        themeScheduleSlotCount = selectedThemePack
            ? ThemePack.slotCount(selectedThemePack, playaScheduleSlotCount)
            : playaScheduleSlotCount
        creatingNewPack = false
        saveThemePackSelectionRequested(id)
        return true
    }
    function persistCustomPack(updated) {
        const original = ThemePack.raw(themePackLibraryJson)
        if (!original || !updated) {
            scheduleError = "Biblioteca de packs inválida: no se sobrescribió."
            return false
        }
        const next = ThemePack.replace(original, updated)
        themePackLibraryJson = JSON.stringify(next)
        saveThemePackLibraryRequested(themePackLibraryJson)
        return true
    }
    function togglePackCandidate(index, checked) {
        const next = pendingPackMemberIndexes.slice()
        const at = next.indexOf(index)
        if (checked && at < 0) next.push(index)
        if (!checked && at >= 0) next.splice(at, 1)
        pendingPackMemberIndexes = next
    }
    function createPersonalPack() {
        const selected = pendingPackMemberIndexes.slice().sort(function(a,b){return a-b})
        const members = selected.filter(function(i) {
            return i >= 0 && i < packCandidateItems.length
        }).map(function(i) { return packCandidateItems[i] })
        const original = ThemePack.raw(themePackLibraryJson)
        if (!original) {
            themeStatus = "Biblioteca de packs inválida: no se sobrescribió."
            return false
        }
        const pack = ThemePack.create(original, newPackName, members,
                                      themeScheduleEnabled, themeScheduleSlotCount)
        if (!pack) {
            themeStatus = "Escribí un nombre distinto y elegí al menos un tema válido."
            return false
        }
        const next = original.concat([pack])
        themePackLibraryJson = JSON.stringify(next)
        saveThemePackLibraryRequested(themePackLibraryJson)
        selectedThemePackId = pack.id
        saveThemePackSelectionRequested(pack.id)
        packOptionsVisible = true
        scheduleMenuExpanded = false
        creatingNewPack = false
        newPackName = ""
        pendingPackMemberIndexes = []
        themeStatus = "Pack «" + pack.name + "» creado, con horarios independientes."
        return true
    }
    function resolvePackPreset(theme) {
        const named = namedThemeIndex(theme)
        if (theme === "day")
            return factoryDayAvailable ? "dayOfficial" :
                named >= 0 ? "library:" + named : ""
        if (theme === "sunset")
            return factorySunsetAvailable ? "sunset" :
                provisionalSunsetJson.length ? "sunsetProvisional" :
                named >= 0 ? "library:" + named :
                (themeDayJson.length ? "day" : "")
        if (theme === "night")
            return factoryNightAvailable ? "night" :
                named >= 0 ? "library:" + named :
                (themeNightJson.length ? "nightLegacy" : "")
        return ""
    }
    function activatePackMember(index) {
        if (!selectedThemePack || index < 0 ||
            index >= selectedThemePack.members.length) return false
        const member = selectedThemePack.members[index]
        const slot = member.kind === "preset"
            ? resolvePackPreset(member.theme) : "pack:" + index
        if (!slot || !activateTheme(slot)) return false
        setScheduleEnabled(false)
        if (member.kind === "preset") wallpaperThemeSelected(member.theme)
        return true
    }
    function persistThemeSchedule() {
        // Esta señal guarda solamente las claves históricas de Playa 24hs.
        saveThemeScheduleRequested(playaScheduleEnabled, playaScheduleSlotCount,
                                   themeScheduleSlots3Json, themeScheduleSlots4Json)
    }
    function setScheduleEnabled(enabled) {
        if (selectedThemePack) {
            if (!persistCustomPack(ThemePack.withPreferences(selectedThemePack,
                enabled, themeScheduleSlotCount))) return
        } else {
            playaScheduleEnabled = enabled
        }
        themeScheduleEnabled = enabled
        scheduleError = ""
        if (!selectedThemePack) persistThemeSchedule()
    }
    function setScheduleSlotCount(count) {
        if (count !== 3 && count !== 4) return
        if (selectedThemePack) {
            if (!persistCustomPack(ThemePack.withPreferences(selectedThemePack,
                themeScheduleEnabled, count))) return
        } else {
            playaScheduleSlotCount = count
        }
        themeScheduleSlotCount = count
        scheduleError = ""
        if (!selectedThemePack) persistThemeSchedule()
    }
    function updateScheduleBoundary(index, boundary, text) {
        if (selectedThemePack) {
            const next = ThemePack.withBoundary(selectedThemePack,
                themeScheduleSlotCount, index, boundary, text.trim())
            if (!next) {
                scheduleError = "Hora inválida (HH:MM) o límites fuera de orden."
                return false
            }
            persistCustomPack(next)
            scheduleError = ""
            return true
        }
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
        if (selectedThemePack) {
            const updatedPack = ThemePack.withMember(selectedThemePack,
                themeScheduleSlotCount, index, theme)
            if (updatedPack) {
                persistCustomPack(updatedPack)
                scheduleError = ""
            }
            return
        }
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
            return ThemeLibrary.parse(json)
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
    // Día/Atardecer/Noche de la biblioteca tienen una imagen y un perfil
    // propios. No confundir la ranura histórica themeDayJson (Atardecer)
    // ni sustituir los tres originales de fábrica inmutables.
    // API QML y enlaces del selector intactos; reglas puras en ThemeLibrary.js.
    function namedThemeIndex(theme) {
        return ThemeLibrary.namedThemeIndex(savedThemeLibrary, theme)
    }
    function dayThemeIndex() { return namedThemeIndex("day") }
    readonly property var otherNamedThemes: ThemeLibrary.otherNamedThemes(savedThemeLibrary)
    function otherNamedThemeOriginalIndex(index) {
        return ThemeLibrary.otherNamedThemeOriginalIndex(savedThemeLibrary, index)
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
    // Alternativa provisional LOCAL, aprobada por el mantenedor.
    // No reemplaza FactorySunsetTheme.js ni la ranura histórica.
    function readProvisionalSunset() {
        const url = Qt.resolvedUrl("assets/.smartbar-atardecer-provisional.json")
        try {
            const request = new XMLHttpRequest()
            request.open("GET", url, false)
            request.send()
            if (request.status !== 0 && request.status !== 200) return ""
            const raw = String(request.responseText || "")
            if (raw.length < 2 || raw.length > 200000) return ""
            const value = JSON.parse(raw)
            if (!value || value.version !== 1 || Array.isArray(value))
                return ""
            return raw
        } catch (e) { return "" }
    }
    readonly property string provisionalSunsetJson: readProvisionalSunset()

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
    signal saveThemePackSelectionRequested(string id)
    signal saveThemePackLibraryRequested(string json)
    signal saveWallpaperFadeRequested(int amount, string unit)
    signal saveBarThemeTransitionRequested(bool enabled)
    signal themeVisualTransitionRequested()
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
    function showThemes() { navigationGroup = "themes"; currentTab = 4; themeChooserExpanded = false; packOptionsVisible = false; scheduleMenuExpanded = false; factoryToolsExpanded = false; creatingNewPack = false }
    function showSoledadLogo() {
        navigationGroup = "soledad"
        currentTab = 1
        logoPage.resetScroll()
    }
    function scrollToSoledadEffects() {
        Qt.callLater(function() {
            logoPage.scrollToLight()
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
        geometryPage.resetScroll()
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
        appearancePage.currentTargetIndex = target === 2 ? 3 : target
        appearancePage.resetScroll()
    }
    function showSharedOutlines() { navigationGroup = "shared"; currentTab = 2; appearanceSubtabs.currentIndex = 2 }
    // Degradado y respiración viven dentro de Color y transparencia.
    function showSoledadGradient() { showSharedColors(0) }
    function showSoledadGradientBreathing() {
        showSharedColors(0)
        Qt.callLater(function() {
            appearancePage.scrollToBreathing()
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
            taskCloseMode: taskCloseMode,
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
        if (slot.indexOf("pack:") === 0) {
            const index = Number(slot.substring(5))
            const pack = selectedThemePack
            if (!pack || !Number.isInteger(index) ||
                index < 0 || index >= pack.members.length) return ""
            const member = pack.members[index]
            if (member.kind === "snapshot") return member.jsonData
            const resolved = resolvePackPreset(member.theme)
            return resolved ? slotJson(resolved) : ""
        }
        if (slot.indexOf("library:") === 0) {
            const index = Number(slot.substring(8))
            const items = savedThemeLibrary
            return isFinite(index) && index >= 0 && index < items.length &&
                   Math.floor(index) === index ? items[index].jsonData : ""
        }
        return slot === "sunsetProvisional" ? provisionalSunsetJson :
                slot === "dayOfficial" ? factoryDayJson :
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
    // Preferencia confirmada: 60 % SOLO en los 3 temas del pack Playa 24hs.
    // Otros packs y temas personales conservan sus opacidades guardadas.
    // Nunca modificar el perfil original ni los GIF, colores o geometrías.
    function isPlayaThemeSlot(slot) {
        if (selectedThemePackId !== ThemePack.DEFAULT_ID) return false
        return slot === resolvePackPreset("day") ||
               slot === resolvePackPreset("sunset") ||
               slot === resolvePackPreset("night")
    }
    function setUniformThemeOpacity() {
        soledadOpacity = 0.6
        malvinaOpacity = 0.6
        launcherOpacity = 0.6
        malvinaOptionsOpacity = 0.6
        trayButtonOpacity = 0.6
        gripButtonOpacity = 0.6
        backgroundOpacity = 0.6 // franja histórica, actualmente oculta
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
            // Activar el fundido únicamente al cargar un tema válido.
            // La demostración del wallpaper usa otra ruta, sin guardar temas.
            themeVisualTransitionRequested()
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
                "taskDisplayMode","taskCloseMode",
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
            // Solo los temas del pack Playa 24hs usan la preferencia
            // uniforme de 60 %. Nunca imponérsela a packs personalizados.
            if (isPlayaThemeSlot(slot)) setUniformThemeOpacity()
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
    property string malvinaBrowserId: "system"
    property var malvinaBrowserChoices: [{"id":"system","name":"Predeterminado del sistema (KDE)"}]
    signal saveMalvinaBrowserRequested(string browserId)
    property bool malvinaWebFirst: true
    property string malvinaWebOrder: "duck,yahoo,google"
    property string malvinaAiOrder: "chatgpt,claude,gemini"
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
    property real soledadOpacity: 0.9
    property real malvinaOpacity: 0.9
    property real backgroundOpacity: 0.9
    property bool showBackground: false
    property bool trayButtonColorOverride: false
    property color trayButtonColor: "#010111"
    property real trayButtonOpacity: 0.9
    property bool gripButtonColorOverride: false
    property color gripButtonColor: "#010111"
    property real gripButtonOpacity: 0.9
    readonly property color activeColor:
        appearancePage.currentTargetIndex === 0 ? soledadColor :
        appearancePage.currentTargetIndex === 1 ? malvinaColor :
        appearancePage.currentTargetIndex === 2 ? backgroundColor :
        appearancePage.currentTargetIndex === 3
            ? (trayButtonColorOverride ? trayButtonColor : soledadColor)
            : (gripButtonColorOverride ? gripButtonColor : soledadColor)
    readonly property real activeOpacity:
        appearancePage.currentTargetIndex === 0 ? soledadOpacity :
        appearancePage.currentTargetIndex === 1 ? malvinaOpacity :
        appearancePage.currentTargetIndex === 2 ? backgroundOpacity :
        appearancePage.currentTargetIndex === 3
            ? (trayButtonColorOverride ? trayButtonOpacity : soledadOpacity)
            : (gripButtonColorOverride ? gripButtonOpacity : soledadOpacity)
    readonly property bool appearanceCanEdit:
        appearancePage.currentTargetIndex < 3 ||
        (appearancePage.currentTargetIndex === 3 ? trayButtonColorOverride
                                              : gripButtonColorOverride)
    function setAppearanceOverride(enabled) {
        if (appearancePage.currentTargetIndex === 3) {
            if (enabled && !trayButtonColorOverride) {
                trayButtonColor = soledadColor
                trayButtonOpacity = soledadOpacity
            }
            trayButtonColorOverride = enabled
        } else if (appearancePage.currentTargetIndex === 4) {
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
        const malvina = appearancePage.currentTargetIndex === 1
        return slot === "base"
            ? (malvina ? malvinaColor : soledadColor)
            : slot === "third"
                ? (malvina ? malvinaGradientThird : soledadGradientThird)
                : (malvina ? malvinaGradientEnd : soledadGradientEnd)
    }
    readonly property int activeGradientColorCount: appearancePage.currentTargetIndex === 1
        ? malvinaGradientColorCount : soledadGradientColorCount
    function setGradientColorCount(count) {
        if (appearancePage.currentTargetIndex === 1)
            malvinaGradientColorCount = count === 3 ? 3 : 2
        else if (appearancePage.currentTargetIndex === 0)
            soledadGradientColorCount = count === 3 ? 3 : 2
    }
    readonly property string activeGradientDirection:
        appearancePage.currentTargetIndex === 1
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
        if (appearancePage.currentTargetIndex === 1) {
            if (slot === "base") malvinaColor = color
            else if (slot === "third") malvinaGradientThird = color
            else malvinaGradientEnd = color
        } else if (appearancePage.currentTargetIndex === 0) {
            if (slot === "base") soledadColor = color
            else if (slot === "third") soledadGradientThird = color
            else soledadGradientEnd = color
        } else return
        paletteFeedback = "Seleccionado " +
                          (slot === "base" ? "primer" : slot === "third" ? "tercer" : "segundo") +
                          " tono " + toHex(islandColor(slot)) +
                          " para " + (appearancePage.currentTargetIndex === 1 ? "Malvina" : "Soledad") +
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
            soledadOpacity = 0.9
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
            malvinaOpacity = 0.9
        } else if (target === 2) {
            backgroundColor = "#202333"
            backgroundOpacity = 0.9
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
    // Desde la carga, la muestra tiene todos los atributos tipados.
    // Se mantiene como instantánea de edición, no como guardado automático.
    property var appliedOutlinePreview: outlinePreviewSnapshot()
    function outlinePreviewSnapshot() {
        return {
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
    function refreshOutlinePreview() {
        appliedOutlinePreview = outlinePreviewSnapshot()
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

    property bool autoCollapseSO: false
    property bool soLeftClickOpensLauncher: false
    property int launcherCategoryLayout: 0
    property string launcherSwitchShape: "capsule"
    property bool launcherSwitchColorOverride: false
    property color launcherSwitchColor: "#010111"
    property int launcherMaxSlots: 20
    property bool launcherOpacityOverride: false
    property real launcherOpacity: 0.9
    property bool launcherIconsWithNames: true
    property bool malvinaOptionsOpacityOverride: false
    property real malvinaOptionsOpacity: 0.9
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
    property string taskDisplayMode: "both"
    // Modos seguros: ambos, solo popup o solo X en la ficha.
    property string taskCloseMode: "both"
    property string taskFrameShape: "rounded"
    property color taskFrameColor: "#ffffff"
    property real taskFrameOpacity: 0.12
    property real taskFrameWidth: 1
    signal saveTaskDisplayModeRequested(string mode)
    signal saveTaskCloseModeRequested(string mode)
    signal saveTaskFrameRequested(string shape, string color, real opacity, real width)
    property var outlineConfig: ({"soledad":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"malvina":{"style":"solid","width":1,"color":"#4e8499","opacity":1},"tray":{"style":"solid","width":1,"color":"#45647a","opacity":1},"grip":{"style":"solid","width":1,"color":"#45647a","opacity":1}})
    readonly property string outlineTargetKey: ["soledad","malvina","tray","grip"][sharedOutlinesPage.currentTargetIndex]
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
        if (appearancePage.currentTargetIndex === 0) soledadOpacity = value
        else if (appearancePage.currentTargetIndex === 1) malvinaOpacity = value
        else if (appearancePage.currentTargetIndex === 2) backgroundOpacity = value
        else if (appearancePage.currentTargetIndex === 3 && trayButtonColorOverride)
            trayButtonOpacity = value
        else if (appearancePage.currentTargetIndex === 4 && gripButtonColorOverride)
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
        // Una sola preferencia para Web e IA, guardada únicamente con Aplicar.
        saveMalvinaBrowserRequested(malvinaBrowserId)
        saveMalvinaConsentsRequested(malvinaAllowChatGpt,
                                    malvinaAllowGemini, malvinaAllowClaude)
        saveOutlineRequested(JSON.parse(JSON.stringify(outlineConfig)))
        saveTaskActiveIndicatorRequested(taskActiveGlowEnabled,
                                         taskActiveDoubleBorderEnabled)
        saveTaskDisplayModeRequested(taskDisplayMode)
        saveTaskCloseModeRequested(taskCloseMode)
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
        runtimeApplyFailed = false
        runtimeApplyNote = ""
        settingsApplied()
        if (runtimeApplyFailed) {
            // No avanzar el checkpoint ante fallo de disco: el usuario
            // puede volver a pulsar Aplicar sin perder su edición.
            appliedLabel.text = runtimeApplyNote
            console.warn("SmartBar Configuración: Aplicar sin guardar; " +
                         "punto de recuperación conservado")
            return
        }
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
        appliedLabel.text = (validProviderUrls && validProviderNames
            ? "Cambios compatibles aplicados y guardados."
            : "Apariencia compatible aplicada. Corregí las URL o nombres de proveedores.") +
            (runtimeApplyNote.length ? " " + runtimeApplyNote :
             " Podés seguir configurando.")
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
            if (settings.creatingNewTheme && themesPage.extractPaletteForNewTheme)
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
            requestTargetIsland = appearancePage.currentTargetIndex
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
                    // Evita el ciclo de Breeze: ancho implícito del separador -> barra -> rightPadding.
                    QQC2.ScrollBar.vertical.width: 16
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
                    SettingsPageTab { text: "Posición y figuras" }
                    SettingsPageTab { text: "Autocontracción" }
                    SettingsPageTab { text: "Proveedores Malvina" }
                }
                StackLayout {
                    currentIndex: islandSubtabs.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
            // 4. Posición y figuras: vista modular sin cambios funcionales.
            SoledadGeometryPage {
                id: geometryPage
                settingsTarget: settings
            }

            // 5. Autocontracción: mismas preferencias, vista extraída.
            SoledadBehaviorPage {
                settingsTarget: settings
                switchColorDialog: launcherSwitchColorDialog
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
                SoledadLogoPage {
                    id: logoPage
                    settingsTarget: settings
                    imageFileDialog: chooseImage
                    textFontPicker: soTextFontDialog
                    textColorPicker: soTextColorDialog
                    textBackgroundColorPicker: soTextBackgroundDialog
                    textBackgroundFileDialog: chooseTextBackground
                    clockFontPicker: clockFontDialog
                    clockColorPicker: clockColorDialog
                    lightOutlineColorPicker: outlineColorDialog
                    glowColorPicker: glowColorDialog
                    paletteSamplerTarget: paletteSampler
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
                    SettingsPageTab { text: "Color por isla" }
                    SettingsPageTab { text: "Fichas SO" }
                    SettingsPageTab { text: "Contornos compartidos" }
                }
                StackLayout {
                    currentIndex: appearanceSubtabs.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
            // 3. Apariencia: las islas mantienen sus preferencias independientes.
            SoledadAppearancePage {
                id: appearancePage
                settingsTarget: settings
                baseColorDialog: islandColorDialog
                sampleColorDialog: samplePaletteColorDialog
                gradientColorDialog: activeGradientColorDialog
            }

            // Las opciones del cajón SO ya tienen su propia vista QML.
            // El estado y la persistencia continúan en esta ventana.
            SoledadTaskStylesPage {
                settingsTarget: settings
                colorDialog: taskFrameColorDialog
            }

            // Contornos de superficies compartidos: vista modular, estado central.
            SoledadSharedOutlinesPage {
                id: sharedOutlinesPage
                settingsTarget: settings
                outlineColorDialog: islandOutlineColorDialog
            }
                }
            }

            // 6. Acerca de: contacto publicado con autorización del
            // mantenedor. Sin botones ni referencias a donaciones.
            // Ayuda/Acerca de independiente, sin botones ni contenido nuevo.
            SoledadAboutPage { }

            // Temas: selector único, contraído inicialmente. La lista se
            // despliega con scroll; no usar mosaico de tarjetas/cuadritos.
            SoledadThemesPage {
                id: themesPage
                settingsTarget: settings
                imagePicker: chooseImage
                paletteSamplerTarget: paletteSampler
            }
            }
        }

        // Pie compartido por TODOS los menús: el cierre conserva lo ya
        // aplicado, pero descarta las ediciones pendientes, igual que la X nativa.
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
                text: "Cerrar"
                onClicked: settings.close()
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Cerrar Configuración; conservar lo ya aplicado"
            }
            QQC2.Button {
                text: "Aplicar"
                highlighted: true
                onClicked: settings.applyChanges()
            }
        }
    }
}
