.pragma library
// Análisis geométrico conservador de la franja superior del monitor.
// SOLO LECTURA. No accede al contenido de ventanas, pestañas, KWin o panel.
// La geometría del marco de una ventana NO prueba la región de clics ni tabs.
function rect(value) {
    if (!value || typeof value !== "object") return null;
    const x = Number(value.x);
    const y = Number(value.y);
    const width = Number(value.width);
    const height = Number(value.height);
    if (![x, y, width, height].every(Number.isFinite) ||
        width <= 0 || height <= 0) return null;
    return {x: x, y: y, width: width, height: height};
}
function inspect(windowGeometry, screenGeometry, stripHeight, maximized, fullscreen) {
    const win = rect(windowGeometry);
    const screen = rect(screenGeometry);
    // El diagnóstico es deliberadamente insuficiente para afirmar
    // convivencia con las pestañas o la entrada del puntero.
    const result = {
        status: "unknown", regionKnown: !!win && !!screen,
        intersectsTopStrip: false,
        windowRect: win, screenRect: screen, stripHeight: 0
    };
    if (!win || !screen || !Number.isFinite(stripHeight) || stripHeight <= 0)
        return result;
    const h = Math.min(stripHeight, screen.height);
    result.stripHeight = h;
    result.intersectsTopStrip =
        win.x < screen.x + screen.width &&
        win.x + win.width > screen.x &&
        win.y < screen.y + h &&
        win.y + win.height > screen.y;
    if (fullscreen === true) {
        result.status = "fullscreen";
    } else if (maximized === true) {
        result.status = result.intersectsTopStrip ? "potential" : "separate";
    } else {
        result.status = result.intersectsTopStrip ? "normal-top" : "normal";
    }
    return result;
}
function summary(appName, info) {
    const name = typeof appName === "string" && appName.trim()
        ? appName.trim() : "Aplicación";
    if (!info || info.status === "unknown")
        return name + ": geometría KDE no disponible; solape sin verificar.";
    if (info.status === "fullscreen")
        return name + ": fullscreen real; la barra debe ocultarse (pendiente verificar).";
    if (info.status === "potential")
        return name + ": marco maximizado intersecta la franja superior; posible solape, pestañas SIN verificar.";
    if (info.status === "separate")
        return name + ": marco maximizado fuera de la franja superior; pestañas/clics SIN verificar.";
    return name + ": ventana sin maximizar; el solape de pestañas sigue sin verificar.";
}
