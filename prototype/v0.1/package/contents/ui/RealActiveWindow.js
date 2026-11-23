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


 // Política transitoria, SOLO para ensayo de superficie fija:
 // enfocar una ventana restaurada NO equivale a desmaximizar la anterior.
 // Con una ventana maximizada detrás, preservar la posición visible hasta
 // maximizar la nueva, desmaximizar explícitamente la activa o agotar las
 // ventanas maximizadas. No crea perfiles ni consulta APIs de KWin.
function shouldKeepNormalFocusPosition(rows, active, previousAppId, heldAppId) {
    if (!active || active.known !== true || !active.appId ||
        active.maximized === true || active.fullscreen === true ||
        !Array.isArray(rows)) return false;
    const maximizedBehind = rows.some(function(row) {
        return row && row.appId !== active.appId &&
            row.maximized === true && row.minimized !== true &&
            row.fullscreen !== true;
    });
    if (!maximizedBehind) return false;
    const switched = typeof previousAppId === "string" &&
        previousAppId.length > 0 && previousAppId !== active.appId;
    return switched || heldAppId === active.appId;
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
