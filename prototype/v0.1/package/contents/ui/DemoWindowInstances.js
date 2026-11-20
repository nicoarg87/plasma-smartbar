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
