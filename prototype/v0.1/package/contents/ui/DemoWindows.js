.pragma library

// Modelo de ventanas SOLO ficticias del visor de pruebas.
// No importa TaskManager, no utiliza procesos ni controla ventanas KDE.
// Cada nombre del catálogo representa una ficha de ejemplo independiente.
function open(current, catalog, name) {
    const items = Array.isArray(current) ? current : []
    if (!Array.isArray(catalog) || catalog.indexOf(name) < 0 ||
        items.indexOf(name) >= 0) return items.slice()
    return items.concat([name])
}

function close(current, name) {
    const items = Array.isArray(current) ? current : []
    const index = items.indexOf(name)
    if (index < 0) return items.slice()
    return items.slice(0, index).concat(items.slice(index + 1))
}

function firstClosed(current, catalog) {
    if (!Array.isArray(catalog)) return ""
    const items = Array.isArray(current) ? current : []
    for (let i = 0; i < catalog.length; ++i) {
        if (items.indexOf(catalog[i]) < 0) return catalog[i]
    }
    return ""
}
