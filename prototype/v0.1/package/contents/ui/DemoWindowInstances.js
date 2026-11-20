.pragma library
// Únicamente datos ficticios del visor. NO son miniaturas/sesiones reales,
// no hay capturas de pantalla ni acciones sobre KDE/KWin.

function seed(appName) {
    if (appName === "Dolphin") return [
        { id: "dolphin-1", title: "Dolphin · Ventana 1", minimized: true },
        { id: "dolphin-2", title: "Dolphin · Ventana 2", minimized: true }
    ]
    return [{ id: String(appName).toLowerCase() + "-1",
              title: String(appName) + " · Ventana 1", minimized: false }]
}
function initial() {
    return { Dolphin: seed("Dolphin"), Konsole: seed("Konsole"),
             Brave: seed("Brave") }
}
function forApp(state, appName) {
    const data = state && state[appName]
    return Array.isArray(data) ? data.slice() : []
}
function reopen(state, appName) {
    const next = Object.assign({}, state || {})
    next[appName] = seed(appName)
    return next
}
function withoutApp(state, appName) {
    const next = Object.assign({}, state || {})
    delete next[appName]
    return next
}
function close(state, appName, windowId) {
    const before = forApp(state, appName)
    const after = before.filter(item => item.id !== windowId)
    if (after.length === before.length) return state
    if (!after.length) return withoutApp(state, appName)
    const next = Object.assign({}, state || {})
    next[appName] = after
    return next
}

// Guardar SOLO datos ficticios para deshacer el último cierre. Para una
// ventana individual se conserva también su posición en la fila del grupo.
// No contiene identificadores ni datos reales de KWin/TasksModel.
function snapshot(state, appName, windowId) {
    const items = forApp(state, appName)
    const saved = []
    for (let index = 0; index < items.length; ++index) {
        if (windowId === undefined || items[index].id === windowId)
            saved.push({index: index, item: items[index]})
    }
    return saved.length ? {appName: appName, items: saved} : null
}

// Reconstruir una o más tarjetas FICTICIAS sin duplicar las que siguen
// abiertas y respetando, si es posible, el orden de aparición anterior.
function restore(state, record) {
    if (!record || !record.appName || !Array.isArray(record.items) ||
        record.items.length === 0) return state
    const next = Object.assign({}, state || {})
    const items = forApp(next, record.appName)
    for (const saved of record.items) {
        if (!saved || !saved.item ||
            items.some(item => item.id === saved.item.id)) continue
        const index = Math.max(0, Math.min(items.length, saved.index))
        items.splice(index, 0, saved.item)
    }
    if (items.length) next[record.appName] = items
    return next
}
