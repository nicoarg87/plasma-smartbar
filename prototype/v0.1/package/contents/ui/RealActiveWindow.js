.pragma library
// Selección conservadora de UNA ventana real activa; solo lectura.
// No utiliza títulos de ventana para identificar aplicaciones.
function resolve(items) {
    if (!Array.isArray(items)) return { appId: "", appName: "", maximized: false, fullscreen: false, known: false };
    let active = null;
    for (const item of items) {
        if (!item || item.active !== true || item.minimized === true) continue;
        // No adivinar cuando KDE comunica dos ventanas activas o falta AppId.
        if (active !== null) return { appId: "", appName: "", maximized: false, fullscreen: false, known: false };
        active = item;
    }
    if (!active || typeof active.appId !== "string" || !active.appId.trim())
        return { appId: "", appName: "", maximized: false, fullscreen: false, known: false };
    return {
        appId: active.appId.trim(),
        appName: typeof active.appName === "string" ? active.appName : "",
        maximized: active.maximized === true,
        fullscreen: active.fullscreen === true,
        known: true
    };
}
