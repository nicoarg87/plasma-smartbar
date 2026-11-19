// Centro unificado de configuracion de Soledad (prototipo Qt 6).
// Las pestañas comparten una ventana. Aplicar guarda y NO cierra.
// Cada pestaña tiene desplazamiento vertical para pantallas reducidas.
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import "PaletteExtractor.js" as PaletteExtractor

Window {
    id: settings
    visible: false
    flags: Qt.Dialog
    title: "Configuraciones"
    color: "#242236"

    // Tamaño de referencia: el editor de logo es la pestaña más alta.
    // Si la pantalla es pequeña, las pestañas permiten desplazamiento.
    width: Screen.desktopAvailableWidth > 0
        ? Math.min(940, Math.max(560, Screen.desktopAvailableWidth - 64)) : 940
    height: Screen.desktopAvailableHeight > 0
        ? Math.min(850, Math.max(510, Screen.desktopAvailableHeight - 64)) : 850
    minimumWidth: 560
    minimumHeight: 510

    // Secciones de geometría reducidas para que entren en la ventana de configuración.
    property int geometrySection: 0
    property int logoSection: 0
    property int outlineSection: 0
    property int appearanceSection: 0
    // El menú lateral decide el destino. Dentro de Soledad o Malvina no
    // existe selector para saltar a controles de la otra isla.
    property string geometryScope: "shared"
    property string behaviorScope: "shared"
    property string colorScope: "soledad"
    property string navigationGroup: "themes"
    property string themeDayJson: ""
    // Respaldo recuperable del Atardecer previo; conservar la clave histórica.
    property string themeDayPreviousJson: ""
    property string themeNightJson: ""
    property string themeCustomJson: ""
    // Recurso oficial opcional: se carga solo cuando el GIF exacto está instalado.
    // La falta del binario NO invalida los temas locales existentes.
    readonly property url officialNightImage: Qt.resolvedUrl("assets/so-night.gif")
    readonly property bool officialNightAvailable: officialNightProbe.status === Image.Ready
    Image {
        id: officialNightProbe
        visible: false
        asynchronous: false
        cache: true
        source: settings.visible ? settings.officialNightImage : ""
    }
    property string themeStatus: "Elegí un tema guardado o creá uno a partir del logo SO."
    signal saveThemeSlotRequested(string slot, string jsonData)
    QQC2.Dialog {
        id: updateSunsetConfirmation
        title: "Confirmar actualización de Atardecer"
        modal: true
        standardButtons: QQC2.Dialog.Yes | QQC2.Dialog.Cancel
        QQC2.Label {
            text: "Guardar la estética actual como Atardecer. La versión anterior quedará recuperable."
            wrapMode: Text.WordWrap
            width: 290
        }
        onAccepted: settings.updateSunsetFromCurrent()
    }
    QQC2.Dialog {
        id: restoreSunsetConfirmation
        title: "Recuperar Atardecer anterior"
        modal: true
        standardButtons: QQC2.Dialog.Yes | QQC2.Dialog.Cancel
        QQC2.Label {
            text: "Intercambiar la versión anterior y la actual. No se tocará la estética favorita."
            wrapMode: Text.WordWrap
            width: 290
        }
        onAccepted: settings.restorePreviousSunset()
    }

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
    function showThemes() { navigationGroup = "themes"; currentTab = 4 }
    function showSoledadLogo() { navigationGroup = "soledad"; currentTab = 1; logoSubtabs.currentIndex = 0; logoSection = 0 }
    function showSoledadEffects() { navigationGroup = "soledad"; currentTab = 1; logoSubtabs.currentIndex = 1; outlineSection = 0 }
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
        appearanceTarget.currentIndex = target
        if (appearanceScroll.contentItem) appearanceScroll.contentItem.contentY = 0
    }
    function showSharedOutlines() { navigationGroup = "shared"; currentTab = 2; appearanceSubtabs.currentIndex = 2 }
    function showSoledadGradient() { showSharedColors(0); appearanceSection = 1 }
    function showMalvinaGradient() { showSharedColors(1); appearanceSection = 1 }
    property int currentTab: 0
    // V1 de tema visual: foto/logo + colores de las dos islas, líneas y
    // contornos, sin alterar posición, controles de ventanas ni permisos IA.
    // Sólo snapshots explícitos; no se publican GIFs personales en GitHub.
    // Presets Playa Dia/Noche: conservar tonos y fuerza guardados, pero
    // asegurar que ambos degradados respiren sin depender del estado de ventanas.
    function ensureBeachBreathing() {
        // El efecto puede seguir habilitado con el degradado apagado.
        // NUNCA volver a activarlo por seleccionar un tema: ahora cada
        // usuario decide si usar un color uniforme o dos tonos.
        soledadGradientSyncBreathing = true
        malvinaGradientSyncBreathing = true
        effectStyle = "breathe"
        allowMotion = true
        showOutlineWhenEmpty = true
        showOutlineWhenOpen = true
        if (pulseDepth <= 0) pulseDepth = 0.7
        if (pulseSpeed <= 0) pulseSpeed = 0.6
    }
    function themeSnapshot() {
        return JSON.stringify({
            version: 1,
            effectStyle: effectStyle, allowMotion: allowMotion,
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
            soledadGradientBreathingIntensity: soledadGradientBreathingIntensity,
            malvinaColor: toHex(malvinaColor), malvinaOpacity: malvinaOpacity,
            malvinaGradientEnabled: malvinaGradientEnabled,
            malvinaGradientEnd: toHex(malvinaGradientEnd),
            malvinaGradientThird: toHex(malvinaGradientThird),
            malvinaGradientColorCount: malvinaGradientColorCount,
            malvinaGradientDirection: malvinaGradientDirection,
            malvinaGradientSyncBreathing: malvinaGradientSyncBreathing,
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
            gripShape: gripShape, trayButtonShape: trayButtonShape,
            soTextLabel: soTextLabel, soTextColor: toHex(soTextColor),
            soTextBackground: toHex(soTextBackground),
            soTextBackgroundOpacity: soTextBackgroundOpacity,
            soTextFontFamily: soTextFontFamily, soTextFontSize: soTextFontSize,
            soTextBold: soTextBold, soTextBackgroundImage: soTextBackgroundImage,
            clockFontFamily: clockFontFamily, clockFontSize: clockFontSize,
            clockTextColor: toHex(clockTextColor),
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
        return slot === "day" ? themeDayJson :
               slot === "night" ? themeNightJson : themeCustomJson
    }
    function storeTheme(slot) {
        // Día y Noche se fijan una sola vez: evitar sobrescrituras
        // accidentales desde el editor de temas.
        if ((slot === "day" || slot === "night") && slotJson(slot).length > 0) {
            themeStatus = "Este tema está protegido. Aplicalo para recuperar sus colores originales."
            return
        }
        if (slot === "day" || slot === "night")
            ensureBeachBreathing()
        const data = themeSnapshot()
        if (slot === "day") themeDayJson = data
        else if (slot === "night") themeNightJson = data
        else themeCustomJson = data
        saveThemeSlotRequested(slot, data)
        themeStatus = "Tema " + (slot === "day" ? "Atardecer" : slot === "night" ? "Noche" : "Personalizado") +
                      " guardado con el logo y los colores actuales. No reemplaza otros temas."
    }
    // Acción excepcional, solicitada por el mantenedor, con confirmación:
    // no reescribir Atardecer durante Aplicar, favoritos o autoguardado.
    function updateSunsetFromCurrent() {
        if (themeDayJson.length > 0) {
            themeDayPreviousJson = themeDayJson
            saveThemeSlotRequested("dayPrevious", themeDayPreviousJson)
        }
        ensureBeachBreathing()
        const data = themeSnapshot()
        themeDayJson = data
        saveThemeSlotRequested("day", data)
        themeStatus = "Atardecer actualizado. La versión anterior quedó recuperable."
    }
    function restorePreviousSunset() {
        if (!themeDayPreviousJson.length) return
        const previous = themeDayPreviousJson
        const current = themeDayJson
        themeDayPreviousJson = current
        themeDayJson = previous
        saveThemeSlotRequested("dayPrevious", current)
        saveThemeSlotRequested("day", previous)
        themeStatus = "Atardecer anterior recuperado. Aplicalo para verlo."
    }
    function themeImageSource(jsonData) {
        try {
            if (!jsonData) return ""
            const info = JSON.parse(jsonData)
            return info.logoMode === "custom" && info.filePath
                ? info.filePath : defaultImage.toString()
        } catch(e) { return "" }
    }
    function activateTheme(slot) {
        const jsonData = slotJson(slot)
        if (!jsonData) {
            themeStatus = "Este tema todavía no está guardado. Personalizá la isla y pulsá Guardar."
            return
        }
        try {
            const info = JSON.parse(jsonData)
            if (info.version !== 1) throw new Error("Versión de tema desconocida")
            const fields = [
                "effectStyle","allowMotion","showOutlineWhenEmpty",
                "showOutlineWhenOpen","pulseSpeed","pulseDepth",
                "logoMode","filePath","shape","cropFitMode","cropZoom",
                "cropPanX","cropPanY","cropRotation","enableGif",
                "soledadColor","soledadOpacity","soledadGradientEnabled",
                "soledadGradientEnd","soledadGradientThird",
                "soledadGradientColorCount","soledadGradientDirection",
                "soledadGradientSyncBreathing","soledadGradientBreathingIntensity",
                "malvinaColor","malvinaOpacity","malvinaGradientEnabled",
                "malvinaGradientEnd","malvinaGradientThird",
                "malvinaGradientColorCount","malvinaGradientDirection",
                "malvinaGradientSyncBreathing","malvinaGradientBreathingIntensity",
                "accentColor","glowColor","glowGradient","glowIntensity","glowSpread",
                "showBackground","backgroundColor","backgroundOpacity",
                "trayButtonColorOverride","trayButtonColor","trayButtonOpacity",
                "gripButtonColorOverride","gripButtonColor","gripButtonOpacity",
                "soledadShape","malvinaShape","malvinaGearButtonShape",
                "malvinaSearchButtonShape","soButtonFrameShape",
                "gripShape","trayButtonShape",
                "soTextLabel","soTextColor","soTextBackground",
                "soTextBackgroundOpacity","soTextFontFamily","soTextFontSize",
                "soTextBold","soTextBackgroundImage",
                "clockFontFamily","clockFontSize","clockTextColor",
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
            // Los presets de playa mantienen la respiracion aunque el JSON
            // previo se hubiera grabado con interruptores apagados.
            // No se aplica esta regla a los temas personalizados.
            if (slot === "day" || slot === "night")
                ensureBeachBreathing()
            // Respetar exactamente colores y orientaciones guardados,
            // sin copiar el degradado de una isla hacia la otra.
            // Si el GIF nocturno verificado está instalado, usarlo como
            // imagen oficial de Noche. El JSON mantiene sus colores propios
            // y no se reescribe la ruta de la foto de ningún otro tema.
            if (slot === "night" && officialNightAvailable) {
                logoMode = "custom"
                filePath = officialNightImage.toString()
                enableGif = true
            }
            // Reusar la ruta de guardado vigente, inclusive los favoritos que
            // son independientes de estos tres espacios de tema.
            applyChanges()
            themeStatus = "Tema " + (slot === "day" ? "Atardecer" : slot === "night" ? "Noche" : "Personalizado") +
                          " aplicado. Los controles siguen siendo editables por isla." +
                          (slot === "night" && !officialNightAvailable
                              ? " El recurso nocturno oficial no está instalado: se conservó la imagen local del tema."
                              : "")
        } catch(e) {
            themeStatus = "No se pudo aplicar el tema guardado: " + e
            console.warn("SmartBar: tema local inválido", e)
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
    property bool soledadGradientSyncBreathing: false
    property real soledadGradientBreathingIntensity: 0.6
    property bool malvinaGradientSyncBreathing: false
    property real malvinaGradientBreathingIntensity: 0.6
    property bool malvinaGradientEnabled: false
    property color malvinaGradientEnd: "#445577"
    property color malvinaGradientThird: "#445577"
    property int malvinaGradientColorCount: 2
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
        const next = sampledColors.slice()
        next[index] = hex
        sampledColors = next
        paletteFeedback = "Tono " + (index + 1) + " ajustado a " + hex +
                          ". Elegí el destino antes de pulsar Aplicar."
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
            soledadGradientSyncBreathing = false
            soledadGradientBreathingIntensity = 0.6
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
            malvinaGradientSyncBreathing = false
            malvinaGradientBreathingIntensity = 0.6
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
    property bool soLeftClickOpensLauncher: false
    property int launcherCategoryLayout: 0
    property string launcherSwitchShape: "capsule"
    property bool launcherSwitchColorOverride: false
    property color launcherSwitchColor: "#010111"
    property int launcherMaxSlots: 20
    property bool launcherOpacityOverride: false
    property real launcherOpacity: 1
    property bool launcherIconsWithNames: true
    property bool malvinaOptionsOpacityOverride: false
    property real malvinaOptionsOpacity: 1
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
    signal saveGradientBreathingRequested(bool enabled, real intensity)
    signal saveMalvinaGradientBreathingRequested(bool enabled, real intensity)
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
                                     soledadGradientBreathingIntensity)
        saveMalvinaGradientBreathingRequested(malvinaGradientSyncBreathing,
                                             malvinaGradientBreathingIntensity)
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
        settingsApplied()
        appliedLabel.text = validProviderUrls && validProviderNames
            ? "Cambios aplicados y guardados. Podés seguir configurando."
            : "Apariencia y opciones aplicadas y guardadas. Corregí las URL o nombres de proveedores para guardarlos."
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
        id: launcherSwitchColorDialog
        title: "Color propio del interruptor Aplicaciones / Archivos"
        onAccepted: settings.launcherSwitchColor = selectedColor
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
        onImageLoaded: {
            if (pending && isImageLoaded(requestedUrl)) requestPaint()
        }
        function suggestFromImage(mode) {
            requestMode = mode === "contour" ? "contour" : "island"
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
                    settings.paletteFeedback = "Se encontraron " + colors.length +
                        " tonos representativos de un fotograma. " +
                        "Elegí primer y segundo tono para cada isla; " +
                        "el análisis no cambia nada automáticamente."
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
                    anchors.fill: parent
                    anchors.margins: 7
                    clip: true
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: Math.max(0, parent.width - 16)
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
                        text: "Temas · Atardecer, Noche y personalizado"
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
                        text: "Logo SO"
                        highlighted: settings.currentTab === 1 && logoSubtabs.currentIndex === 0
                        onClicked: settings.showSoledadLogo()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Efectos luminosos"
                        highlighted: settings.currentTab === 1 && logoSubtabs.currentIndex === 1
                        onClicked: settings.showSoledadEffects()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Cajón y ventanas"
                        highlighted: settings.currentTab === 2 && appearanceSubtabs.currentIndex === 1
                        onClicked: settings.showSoledadWindows()
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "Launcher y botón SO"
                        highlighted: settings.currentTab === 0 &&
                                     islandSubtabs.currentIndex === 1 &&
                                     settings.behaviorScope === "soledad"
                        onClicked: settings.showSoledadLauncher()
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
                        text: "Color y transparencia"
                        highlighted: settings.currentTab === 2 &&
                                     appearanceSubtabs.currentIndex === 0 &&
                                     settings.colorScope === "soledad" && settings.appearanceSection !== 1
                        onClicked: settings.showSharedColors(0)
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "soledad"
                        text: "DEGRADADO SOLEDAD"
                        highlighted: settings.currentTab === 2 &&
                                     appearanceSubtabs.currentIndex === 0 &&
                                     settings.colorScope === "soledad" && settings.appearanceSection === 1
                        onClicked: settings.showSoledadGradient()
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
                                     settings.colorScope === "malvina" && settings.appearanceSection !== 1
                        onClicked: settings.showSharedColors(1)
                    }
                    SettingsMenuButton {
                        visible: settings.navigationGroup === "malvina"
                        text: "DEGRADADO MALVINA"
                        highlighted: settings.currentTab === 2 &&
                                     appearanceSubtabs.currentIndex === 0 &&
                                     settings.colorScope === "malvina" && settings.appearanceSection === 1
                        onClicked: settings.showMalvinaGradient()
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
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, positionScroll.availableWidth - 8)
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
                        text: "Centrar isla 1 AHORA"
                        onClicked: settings.alignCenterNowRequested()
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
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, collapseScroll.availableWidth - 8)
                    spacing: 16
                    ColumnLayout {
                        visible: settings.behaviorScope === "soledad"
                        Layout.fillWidth: true
                        spacing: 12
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
                QQC2.TabBar {
                    id: logoSubtabs
                    visible: false
                    Layout.fillWidth: true
                    SettingsPageTab { text: "Imagen y texto"; width: logoSubtabs.width / 2 }
                    SettingsPageTab { text: "Contorno e iluminación"; width: logoSubtabs.width / 2 }
                }
                StackLayout {
                    currentIndex: logoSubtabs.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
            // 1. Logo: se conserva encuadre visual y recorte no destructivo.
            QQC2.ScrollView {
                id: logoScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, logoScroll.availableWidth - 8)
                    spacing: 10
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: ["Imagen", "Texto", "Encuadre", "Reloj"]
                            delegate: QQC2.Button {
                                required property int index
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                highlighted: settings.logoSection === index
                                onClicked: { settings.logoSection = index; logoScroll.contentItem.contentY = 0 }
                            }
                        }
                    }
                    ColumnLayout {
                        visible: settings.logoSection === 0
                        Layout.fillWidth: true
                        spacing: 9
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
                        visible: settings.logoSection === 1
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
                    ColumnLayout {
                        visible: settings.logoSection === 2
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
                    }
                    ColumnLayout {
                        visible: settings.logoSection === 3
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
                    text: "Muestra de los últimos ajustes aplicados. Pulsá Aplicar para ver los cambios."
                    color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                }
                QQC2.ScrollView {
                    id: outlineScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: Math.max(0, availableWidth - 8)
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                    ColumnLayout {
                        width: Math.max(0, outlineScroll.availableWidth - 8)
                        spacing: 13
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: ["Estados y color", "Luz móvil", "Brillo y respiración"]
                            delegate: QQC2.Button {
                                required property int index
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                highlighted: settings.outlineSection === index
                                onClicked: { settings.outlineSection = index; outlineScroll.contentItem.contentY = 0 }
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
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, appearanceScroll.availableWidth - 8)
                    spacing: 14
                    QQC2.Label {
                        text: settings.colorScope === "soledad"
                            ? "SOLEDAD · Color, degradado y respiración"
                            : settings.colorScope === "malvina"
                            ? "MALVINA · Color, degradado y respiración"
                            : "GENERAL · Fondo y colores compartidos"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: settings.colorScope === "shared"
                            ? "Solo fondo opcional, bandeja y agarre. Las islas se editan en sus propias secciones."
                            : "Estos colores modifican únicamente " +
                              (settings.colorScope === "soledad" ? "Soledad (isla 1)." : "Malvina (isla 2).") +
                              " La otra isla conserva su estética."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    // Selector técnico oculto; solo el menú lateral define la
                    // isla. En General se ofrece únicamente su lista de fondos.
                    QQC2.ComboBox {
                        id: appearanceTarget
                        visible: false
                        model: ["Soledad (isla 1)", "Malvina (isla 2)", "Fondo opcional",
                                "Botones de bandeja", "Botón de seis puntos (agarre)"]
                    }
                    QQC2.ComboBox {
                        visible: settings.colorScope === "shared"
                        Layout.fillWidth: true
                        model: ["Fondo opcional", "Cajón de sistema (bandeja)", "Agarre de seis puntos"]
                        currentIndex: Math.max(0, appearanceTarget.currentIndex - 2)
                        onActivated: function(index) {
                            appearanceTarget.currentIndex = index + 2
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
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: ["Color y opacidad", "DEGRADADO", "Respiración y fondo"]
                            delegate: QQC2.Button {
                                required property int index
                                required property string modelData
                                Layout.fillWidth: true
                                visible: settings.colorScope !== "shared" ||
                                         index === 0 || (index === 2 && appearanceTarget.currentIndex === 2)
                                text: modelData
                                highlighted: settings.appearanceSection === index
                                onClicked: { settings.appearanceSection = index; appearanceScroll.contentItem.contentY = 0 }
                            }
                        }
                    }
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
                        QQC2.Button {
                            visible: appearanceTarget.currentIndex === 0
                            text: "Abrir paleta del GIF…"
                            onClicked: {
                                settings.showSoledadGradient()
                                paletteSampler.suggestFromImage("island")
                            }
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: "Calcula los tonos del fotograma sin copiar el celeste del contorno ni aplicarlos automáticamente"
                        }
                        QQC2.TextField {
                            id: currentColorCopyField
                            Layout.preferredWidth: 105
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
                        visible: settings.appearanceSection === 1
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
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        color: "white"
                        font.bold: true
                        text: "COLORES ACTIVOS DE " +
                              (appearanceTarget.currentIndex === 1 ? "MALVINA" : "SOLEDAD")
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: "Estos son los colores que usa Aplicar. Si la isla tiene " +
                              "transparencia, el fondo del escritorio también influye."
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        spacing: 6
                        QQC2.Label { text: "Color 1"; color: "white" }
                        Rectangle {
                            width: 28; height: 25; radius: 4
                            color: settings.islandColor("base")
                        }
                        QQC2.TextField {
                            id: currentBaseHex
                            Layout.fillWidth: true
                            selectByMouse: true
                            placeholderText: "#000000"
                            text: settings.toHex(settings.islandColor("base"))
                            onEditingFinished: settings.setIslandHex("base", text)
                        }
                        QQC2.Button {
                            text: "Copiar"
                            onClicked: {
                                currentBaseHex.selectAll()
                                currentBaseHex.copy()
                                currentBaseHex.deselect()
                            }
                        }
                        QQC2.Button {
                            text: "Elegir…"
                            onClicked: {
                                islandColorDialog.editingTarget = appearanceTarget.currentIndex
                                islandColorDialog.selectedColor = settings.islandColor("base")
                                islandColorDialog.open()
                            }
                        }
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        spacing: 6
                        QQC2.Label { text: "Color 2"; color: "white" }
                        Rectangle {
                            width: 28; height: 25; radius: 4
                            color: settings.islandColor("end")
                        }
                        QQC2.TextField {
                            id: currentEndHex
                            Layout.fillWidth: true
                            selectByMouse: true
                            placeholderText: "#000000"
                            text: settings.toHex(settings.islandColor("end"))
                            onEditingFinished: settings.setIslandHex("end", text)
                        }
                        QQC2.Button {
                            text: "Copiar"
                            onClicked: {
                                currentEndHex.selectAll()
                                currentEndHex.copy()
                                currentEndHex.deselect()
                            }
                        }
                        QQC2.Button {
                            text: "Elegir…"
                            onClicked: {
                                islandGradientEndDialog.target = appearanceTarget.currentIndex
                                islandGradientEndDialog.selectedColor = settings.islandColor("end")
                                islandGradientEndDialog.open()
                            }
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        text: "PALETA DEL GIF"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.Button {
                        visible: appearanceTarget.currentIndex <= 1
                        text: "Analizar GIF y mostrar tres colores"
                        Layout.fillWidth: true
                        onClicked: paletteSampler.suggestFromImage("island")
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#d1d8e5"
                        text: settings.paletteFeedback
                    }
                    Repeater {
                        model: settings.sampledColors.length
                        delegate: ColumnLayout {
                            required property int index
                            Layout.fillWidth: true
                            spacing: 4
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    width: 34; height: 27; radius: 5
                                    color: settings.sampleHex(index)
                                }
                                QQC2.Label {
                                    text: "Tono " + (index + 1)
                                    color: "white"
                                }
                                QQC2.TextField {
                                    id: sampleHexField
                                    Layout.fillWidth: true
                                    selectByMouse: true
                                    text: settings.sampleHex(index)
                                    placeholderText: "#000000"
                                    onEditingFinished: settings.editSampleHex(index, text)
                                }
                                QQC2.Button {
                                    text: "Copiar"
                                    onClicked: {
                                        sampleHexField.selectAll()
                                        sampleHexField.copy()
                                        sampleHexField.deselect()
                                    }
                                }
                                QQC2.Button {
                                    text: "Editar…"
                                    onClicked: {
                                        samplePaletteColorDialog.sampleIndex = index
                                        samplePaletteColorDialog.selectedColor =
                                            settings.sampleHex(index)
                                        samplePaletteColorDialog.open()
                                    }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                QQC2.Button {
                                    Layout.fillWidth: true
                                    text: "Usar como color 1"
                                    onClicked: settings.chooseSampledColor(index, "base")
                                }
                                QQC2.Button {
                                    Layout.fillWidth: true
                                    text: "Usar como color 2"
                                    onClicked: settings.chooseSampledColor(index, "end")
                                }
                            }
                        }
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex <= 1
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#bbd8f2"
                        text: "Podés escribir o pegar cualquier código #RRGGBB, incluso negro. " +
                              "Los tonos del GIF son sugerencias editables, no restricciones."
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

                    }
                    ColumnLayout {
                        visible: settings.appearanceSection === 2
                        Layout.fillWidth: true
                        spacing: 9
                    QQC2.CheckBox {
                        visible: appearanceTarget.currentIndex === 1 && settings.malvinaGradientEnabled
                        text: "Sincronizar respiración del degradado de Malvina con SO"
                        checked: settings.malvinaGradientSyncBreathing
                        onToggled: settings.malvinaGradientSyncBreathing = checked
                    }
                    QQC2.Label {
                        visible: appearanceTarget.currentIndex === 1 &&
                                 settings.malvinaGradientEnabled &&
                                 settings.malvinaGradientSyncBreathing
                        text: "Usa la fase y velocidad de Respiración luminosa de SO, pero conserva intensidad propia. Requiere SO en modo respiración y se guarda con Aplicar."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    RowLayout {
                        visible: appearanceTarget.currentIndex === 1 &&
                                 settings.malvinaGradientEnabled &&
                                 settings.malvinaGradientSyncBreathing
                        Layout.fillWidth: true
                        QQC2.Label { text: "Intensidad"; color: "white" }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 1; stepSize: 0.05
                            value: settings.malvinaGradientBreathingIntensity
                            onMoved: settings.malvinaGradientBreathingIntensity = value
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaGradientBreathingIntensity * 100) + "%"
                            color: "white"
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
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, taskStylesScroll.availableWidth - 8)
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
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, sharedOutlineScroll.availableWidth - 8)
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
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, aboutScroll.availableWidth - 8)
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

            // Página PRINCIPAL Temas (índice 4), independiente de las
            // subpestañas antiguas de islas. Nunca aplica otro GIF sola.
            QQC2.ScrollView {
                id: themesScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 8)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
                ColumnLayout {
                    width: Math.max(0, themesScroll.availableWidth - 10)
                    spacing: 12
                    QQC2.Label {
                        text: "Temas visuales"
                        font.pixelSize: 19
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: "Elegí Atardecer, Noche o Personalizado. " +
                              "Cada tema conserva la imagen SO, los colores, los degradados " +
                              "y los contornos; Malvina conserva ajustes independientes " +
                              "después de aplicar un tema."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 114
                        radius: 12
                        color: "#262e44"
                        border.color: "#506985"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12
                            Image {
                                Layout.preferredWidth: 135
                                Layout.preferredHeight: 90
                                source: settings.selectedImage
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: false
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                QQC2.Label {
                                    text: "Logo SO actual"
                                    color: "white"
                                    font.bold: true
                                }
                                QQC2.Label {
                                    text: settings.logoMode === "custom"
                                        ? "Imagen personalizada" : "Imagen predeterminada"
                                    color: "#d0ddeb"
                                }
                                QQC2.Button {
                                    text: "Personalizar logo SO"
                                    onClicked: settings.showSoledadLogo()
                                }
                            }
                        }
                    }
                    QQC2.Label {
                        text: "Mis temas guardados"
                        color: "white"; font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 9
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 270
                            radius: 9
                            color: "#2b2d42"
                            border.color: "#4d607b"
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 5
                                QQC2.Label { text: "Atardecer"; color: "white"; font.bold: true }
                                Image {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 64
                                    fillMode: Image.PreserveAspectFit
                                    source: settings.themeDayJson.length
                                        ? settings.themeImageSource(settings.themeDayJson)
                                        : settings.defaultImage
                                    cache: false
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    QQC2.Button {
                                        Layout.fillWidth: true
                                        visible: settings.themeDayJson.length === 0
                                        text: "Fijar Atardecer"
                                        onClicked: settings.storeTheme("day")
                                    }
                                    QQC2.Button {
                                        Layout.fillWidth: true
                                        enabled: settings.themeDayJson.length > 0
                                        text: "Aplicar Atardecer"
                                        onClicked: settings.activateTheme("day")
                                    }
                                }
                                QQC2.Button {
                                    Layout.fillWidth: true
                                    enabled: settings.themeDayJson.length > 0
                                    text: "Actualizar Atardecer con estética actual…"
                                    onClicked: updateSunsetConfirmation.open()
                                }
                                QQC2.Button {
                                    Layout.fillWidth: true
                                    enabled: settings.themeDayPreviousJson.length > 0
                                    text: "Recuperar Atardecer anterior…"
                                    onClicked: restoreSunsetConfirmation.open()
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 182
                            radius: 9
                            color: "#202a3e"
                            border.color: "#4d607b"
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 5
                                QQC2.Label { text: "Noche"; color: "white"; font.bold: true }
                                Image {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 64
                                    fillMode: Image.PreserveAspectFit
                                    source: settings.officialNightAvailable
                                        ? settings.officialNightImage
                                        : settings.themeImageSource(settings.themeNightJson)
                                    visible: settings.officialNightAvailable ||
                                             settings.themeNightJson.length > 0
                                    cache: false
                                }
                                QQC2.Label {
                                    visible: !settings.themeNightJson.length
                                    text: settings.officialNightAvailable
                                        ? "Imagen oficial disponible · falta guardar colores de Noche"
                                        : "Todavía sin guardar"
                                    color: "#bbc6db"
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    QQC2.Button {
                                        Layout.fillWidth: true
                                        visible: settings.themeNightJson.length === 0
                                        text: "Fijar tema Noche"
                                        onClicked: settings.storeTheme("night")
                                    }
                                    QQC2.Button {
                                        Layout.fillWidth: true
                                        enabled: settings.themeNightJson.length > 0
                                        text: "Aplicar Noche"
                                        onClicked: settings.activateTheme("night")
                                    }
                                }
                            }
                        }
                    }
                    QQC2.Label {
                        text: "Crear un tema desde los colores del GIF"
                        color: "white"; font.bold: true
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: "Analizá el GIF, elegí hasta tres tonos y asigná dos a cada isla. " +
                              "Podés editar cualquier HEX y decidir después si usar degradado. " +
                              "El contorno del botón SO no se modifica."
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Abrir paleta del GIF y elegir colores…"
                        onClicked: {
                            settings.showSoledadGradient()
                            paletteSampler.suggestFromImage("island")
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: "Guardar como Personalizado"
                            onClicked: settings.storeTheme("custom")
                        }
                        QQC2.Button {
                            Layout.fillWidth: true
                            enabled: settings.themeCustomJson.length > 0
                            text: "Aplicar Personalizado"
                            onClicked: settings.activateTheme("custom")
                        }
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#b9e5ff"
                        text: settings.themeStatus
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: "#ddd6e8"
                        text: "Atardecer y Noche no se sobrescriben al guardar una estética favorita. " +
                              "Para actualizar Atardecer, usá su botón de actualización y confirmá. " +
                              "Los GIF personalizados permanecen en tu equipo."
                    }
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
