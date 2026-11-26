.pragma library

// Catálogo de muestra de la bandeja para el visor v0.1.
// Los indicadores KDE reales requieren un proveedor SNI separado;
// no se mezclan aquí con entradas simuladas.
function demoEntries() {
    return ["Wi-Fi", "Audio", "Bluetooth"]
}

// Retornar una lista nueva: nunca mutar el origen ni el estado de KDE.
// La bandeja contraída no necesita instanciar delegates QML.
function visibleEntries(entries, expanded) {
    if (!expanded || !Array.isArray(entries)) return []
    return entries.slice()
}
