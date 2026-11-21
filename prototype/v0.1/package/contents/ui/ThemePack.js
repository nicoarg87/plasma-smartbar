.pragma library

// Pack inicial inmutable como IDENTIDAD de presentación.
// Los perfiles reales siguen en sus ranuras; aquí no se escriben temas.
// Su modo automático reutiliza themeScheduleEnabled y ThemeSchedule.js.
var DEFAULT_ID = "playa-24hs"
var NAME = "Playa 24hs"
var THEMES = ["sunset", "night", "day"]

function title(automatic) {
    return NAME + " · " + (automatic ? "Automático" : "Manual")
}

function isManualTheme(theme) {
    return THEMES.indexOf(theme) >= 0
}
