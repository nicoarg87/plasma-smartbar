.pragma library

// Estado puro de la bandeja. NO accede a ventanas, launcher, KDE ni QML.
// La composición Soledad aplica aparte el ajuste horizontal de capacidad.
function toggle(currentExpanded, currentLastExpandedMode) {
    const opened = !Boolean(currentExpanded)
    return {
        expanded: opened,
        lastExpandedMode: opened ? "tray" : currentLastExpandedMode,
        ensureFits: opened
    }
}

// Autocontracción independiente del selector SO. Nunca temporizada.
function afterIconSelection(currentExpanded, autoCollapse) {
    return Boolean(currentExpanded) && !Boolean(autoCollapse)
}
