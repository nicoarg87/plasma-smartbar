.pragma library
// Solo claves visuales del visor histórico. Ninguna posición de KWin,
// permisos de IA, preferencias de wallpaper, temas originales o panel KDE.
// Se reutilizan los nombres demoX del appearanceV1 ya guardado.
var visualKeys = [
    "soledadShape","malvinaShape","malvinaGearButtonShape",
    "malvinaSearchButtonShape","soledadRadius","malvinaRadius",
    "soledadMinWidth","malvinaWidth","gripShape","trayButtonShape",
    "soButtonFrameShape","soButtonWidth",
    "soledadColor","malvinaColor","soledadOpacity","malvinaOpacity",
    "soledadGradientEnabled","soledadGradientEnd","soledadGradientThird",
    "soledadGradientColorCount","soledadGradientDirection",
    "soledadGradientSyncBreathing","soledadGradientSyncIntensity",
    "soledadGradientBreathingEnabled","soledadGradientBreathingIntensity",
    "soledadGradientBreathingSpeed",
    "malvinaGradientEnabled","malvinaGradientEnd","malvinaGradientThird",
    "malvinaGradientColorCount","malvinaGradientDirection",
    "malvinaGradientSyncBreathing","malvinaGradientBreathingEnabled",
    "malvinaGradientBreathingIntensity","malvinaGradientBreathingSpeed",
    "outlineConfig","taskDisplayMode","taskFrameShape","taskFrameColor",
    "taskFrameOpacity","taskFrameWidth","taskActiveGlowEnabled",
    "taskActiveDoubleBorderEnabled",
    "trayButtonColorOverride","trayButtonColor","trayButtonOpacity",
    "gripButtonColorOverride","gripButtonColor","gripButtonOpacity",
    "launcherCategoryLayout","launcherSwitchShape",
    "launcherSwitchColorOverride","launcherSwitchColor","launcherMaxSlots",
    "launcherOpacityOverride","launcherOpacity","launcherIconsWithNames",
    "malvinaOptionsOpacityOverride","malvinaOptionsOpacity",
    "soTextLabel","soTextColor","soTextBackground",
    "soTextBackgroundOpacity","soTextFontFamily","soTextFontSize",
    "soTextBold","soTextBackgroundImage","soClockFontFamily",
    "soClockFontSize","soClockTextColor",
    "soActivityStyle","soActivityColor","soActivityStroke",
    "soActivityMotion","soActivityOrbitSpeed","soActivityTrailPercent",
    "soActivityTrailStyle","soActivityGlowColor",
    "soActivityGlowIntensity","soActivityGlowSpread",
    "soActivityPulseSpeed","soActivityPulseDepth",
    "soActivityGlowGradient","soActivityShowWhenEmpty",
    "soActivityShowWhenOpen",
    "soLogoMode","soLogoPath","soLogoShape","soLogoFitMode",
    "soLogoZoom","soLogoPanX","soLogoPanY",
    "soLogoAnimate","soLogoRotation"
]
// Mapeo inverso entre nombre del elemento visual y la propiedad del editor.
var editorNames = {
    soClockFontFamily:"clockFontFamily",soClockFontSize:"clockFontSize",
    soClockTextColor:"clockTextColor",
    soLogoMode:"logoMode",soLogoPath:"filePath",soLogoShape:"shape",
    soLogoFitMode:"cropFitMode",soLogoZoom:"cropZoom",
    soLogoPanX:"cropPanX",soLogoPanY:"cropPanY",
    soLogoRotation:"cropRotation",soLogoAnimate:"enableGif",
    soActivityStyle:"effectStyle",soActivityColor:"accentColor",
    soActivityStroke:"strokeSize",soActivityMotion:"allowMotion",
    soActivityOrbitSpeed:"orbitSpeed",soActivityTrailPercent:"trailPercent",
    soActivityTrailStyle:"trailStyle",soActivityGlowColor:"glowColor",
    soActivityGlowIntensity:"glowIntensity",soActivityGlowSpread:"glowSpread",
    soActivityPulseSpeed:"pulseSpeed",soActivityPulseDepth:"pulseDepth",
    soActivityGlowGradient:"glowGradient",
    soActivityShowWhenEmpty:"showOutlineWhenEmpty",
    soActivityShowWhenOpen:"showOutlineWhenOpen"
}
function savedKey(name) {
    return "demo" + name.charAt(0).toUpperCase() + name.slice(1)
}
function hasOwn(obj,key) {
    return Object.prototype.hasOwnProperty.call(obj,key)
}
function parse(raw) {
    if (typeof raw !== "string" || raw.length === 0 || raw.length > 200000)
        return null
    try {
        const value = JSON.parse(raw)
        return value && typeof value === "object" && !Array.isArray(value) ? value : null
    } catch (e) {
        return null
    }
}
function applyToBar(bar,values) {
    if (!bar || !values) return 0
    let changed = 0
    for (const name of visualKeys) {
        const key = savedKey(name)
        if (!hasOwn(values,key) || values[key] === undefined || values[key] === null) continue
        // Aplicar únicamente propiedades declaradas del componente, nunca
        // crear campos dinámicos ni modificar la altura fija de LayerShell.
        if (bar[name] === undefined) continue
        try { bar[name] = values[key]; changed++ } catch (e) {}
    }
    return changed
}
function captureChanges(editor) {
    if (!editor || !editor.baselineLoaded) return ({})
    const patch = ({})
    const old = editor.lastAppliedSettings || ({})
    for (const name of visualKeys) {
        const source = editorNames[name] || name
        if (editor[source] === undefined || !hasOwn(old,source)) continue
        const value = editor.preferenceCopy(source,editor[source])
        if (JSON.stringify(value) !== JSON.stringify(old[source]))
            patch[savedKey(name)] = value
    }
    return patch
}
