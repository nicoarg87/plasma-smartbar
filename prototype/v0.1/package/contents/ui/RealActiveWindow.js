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

/*
 * Restauración visual TRANSITORIA al cerrar fullscreen: KWin puede dejar
 * IsActive vacío hasta el próximo clic. Nunca inferir a partir del título
 * ni usar un programa abierto en segundo plano si hay OTRA ventana activa.
 * Se exige el AppId previamente identificado antes del fullscreen.
 */
function fullscreenExitCandidate(items, previousAppId) {
    if (!Array.isArray(items) || typeof previousAppId !== "string" ||
        previousAppId.trim().length === 0) return null;
    const appId = previousAppId.trim();
    // Si KWin sí identifica una ventana activa, corresponde al flujo normal.
    if (items.some(function(row) {
        return row && row.active === true && row.minimized !== true;
    })) return null;
    // Nunca mostrar Soledad por encima de ningún fullscreen todavía presente.
    if (items.some(function(row) {
        return row && row.fullscreen === true && row.minimized !== true;
    })) return null;
    const match = items.filter(function(row) {
        return row && row.appId === appId && row.maximized === true &&
            row.minimized !== true && row.fullscreen !== true;
    });
    if (match.length === 0) return null;
    return {appId: appId, appName: match[0].appName || ""};
}

function rememberExternal(previous, observed, viewerAppId) {
    const old = previous && previous.known === true ? previous
        : { appId: "", appName: "", maximized: false, fullscreen: false, known: false };
    // El propio visor toma foco al usar el agarre o abrir el menú.
    // No reemplazar por qml6 la última aplicación externa observada.
    if (!observed || observed.known !== true ||
        observed.appId === viewerAppId) return old;
    return {
        appId: observed.appId,
        appName: observed.appName,
        maximized: observed.maximized === true,
        fullscreen: observed.fullscreen === true,
        known: true
    };
}

function profileTarget(selectedAppId, selectedAppName, external) {
    const chosen = typeof selectedAppName === "string" &&
        selectedAppName.trim().length > 0;
    const id = chosen
        ? (typeof selectedAppId === "string" ? selectedAppId.trim() : "")
        : (external && external.known === true &&
           typeof external.appId === "string" ? external.appId.trim() : "");
    const name = chosen ? selectedAppName.trim()
        : (external && external.known === true &&
           typeof external.appName === "string" ? external.appName : "");
    // Seleccionar Steam no activa Steam. Solo permite guardar si KDE
    // confirmó que ESA MISMA ventana estaba activa y maximizada.
    return {
        appId: id,
        appName: name,
        explicitlySelected: chosen,
        eligible: !!id && !!external && external.known === true &&
            external.appId === id && external.maximized === true &&
            external.fullscreen !== true
    };
}
