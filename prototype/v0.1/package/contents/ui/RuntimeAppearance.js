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
    "soLogoAnimate","soLogoRotation",
    // Opciones de interfaz que el editor ya admite, pero el ensayo
    // conjunto anterior omitía: no controlan procesos ni ventanas ajenas.
    "taskCloseMode","backgroundColor","backgroundOpacity","showBackground",
    "autoCollapseSO","autoCollapseTray","autoReturnRight",
    "soLeftClickOpensLauncher"
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
        try {
            bar[name] = values[key]
            changed++
        } catch (e) {
            console.warn("SmartBar apariencia: propiedad no aplicada", name,
                         String(e))
        }
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

function unmappedChanges(editor) {
    if (!editor || !editor.baselineLoaded) return []
    const used = new Set(visualKeys.map(function(name) {
        return editorNames[name] || name
    }))
    const baseline = editor.lastAppliedSettings || ({})
    const missing = []
    for (const source of editor.editableSettingsKeys) {
        if (used.has(source) || !hasOwn(baseline,source) ||
            editor[source] === undefined) continue
        const next = editor.preferenceCopy(source,editor[source])
        if (JSON.stringify(next) !== JSON.stringify(baseline[source]))
            missing.push(source)
    }
    return missing
}


 // Identidad visual del tema: los controles funcionales de las ventanas,
 // la autocontracción y las posiciones guardadas NO son parte de un tema.
var themeBehaviorKeys = [
    "autoCollapseSO", "autoCollapseTray", "autoReturnRight",
    "soLeftClickOpensLauncher", "taskCloseMode"
]
// Regla aprobada exclusivamente para los temas del pack «Playa 24hs»:
// mantener las opacidades a 60 % sin reescribir los presets originales.
// Los packs personalizados conservan los valores de sus propios temas.
var persistentThemeOpacityKeys = [
    "soledadOpacity", "malvinaOpacity", "launcherOpacity",
    "malvinaOptionsOpacity", "trayButtonOpacity", "gripButtonOpacity",
    "backgroundOpacity"
]
function withThemeOpacity(patch, packId) {
    if (!patch || typeof patch !== "object" || Array.isArray(patch)) return null
    const updated = Object.assign({}, patch)
    if (packId === "playa-24hs") {
        for (const name of persistentThemeOpacityKeys)
            updated[savedKey(name)] = 0.6
    }
    return updated
}
function themeToPatch(snapshot) {
    if (!snapshot || snapshot.version !== 1 || Array.isArray(snapshot))
        return null
    const patch = ({})
    for (const name of visualKeys) {
        if (themeBehaviorKeys.indexOf(name) >= 0) continue
        const source = editorNames[name] || name
        if (!hasOwn(snapshot, source) || snapshot[source] === null ||
            snapshot[source] === undefined) continue
        patch[savedKey(name)] = snapshot[source]
    }
    return Object.keys(patch).length >= 55 ? patch : null
}


function closestThemeIndex(current, themes, sequence) {
    if (!current || !themes || !Array.isArray(sequence)) return -1
    let best = -1, bestScore = 0, second = 0
    for (let i=0; i<sequence.length; ++i) {
        const patch=themes[sequence[i]]
        if (!patch || typeof patch !== "object") continue
        let comparable=0, equal=0
        for (const key of Object.keys(patch)) {
            // Las rutas de GIF cambian al resguardar recursos sin cambiar el
            // dibujo; nunca usar rutas personales para identificar un tema.
            if (key==="demoSoLogoPath"||key==="demoSoTextBackgroundImage") continue
            if (!hasOwn(current,key)) continue
            ++comparable
            if (JSON.stringify(current[key])===JSON.stringify(patch[key])) ++equal
        }
        const score=comparable>=50 ? equal/comparable : 0
        if (score>bestScore){second=bestScore;bestScore=score;best=i}
        else if(score>second) second=score
    }
    // Solo identificar si el parecido es alto y no hay otro tema ambiguo.
    return bestScore>=0.80 && bestScore-second>=0.08 ? best : -1
}
