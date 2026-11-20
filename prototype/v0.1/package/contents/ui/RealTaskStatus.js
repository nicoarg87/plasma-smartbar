.pragma library
// Diagnóstico de roles de ventanas REALES KDE: exclusivamente lectura.
// Separar foco y estado de ventana evita perder "Maximizada" cuando
// la aplicación también es la activa.
function label(isActive, isMinimized, isMaximized, isFullScreen) {
    const focus = isActive === true ? "Activa" : "Inactiva"
    const state = isFullScreen === true ? "Pantalla completa"
        : (isMinimized === true ? "Minimizada"
            : (isMaximized === true ? "Maximizada" : "Normal"))
    return focus + " · " + state
}
