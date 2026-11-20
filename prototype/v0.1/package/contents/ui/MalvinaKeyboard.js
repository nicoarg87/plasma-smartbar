.pragma library

// La primera pulsación de Enter sobre una opción destacada solo la elige.
// El envío de la consulta se permite con otra pulsación de Enter,
// una vez que el foco visual vuelve al campo (navigationSection === 0).
function enterAction(navigationSection) {
    return navigationSection === 1 || navigationSection === 2
        ? "confirm" : "search"
}
