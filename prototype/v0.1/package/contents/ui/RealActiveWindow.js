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


 // En un arranque sin perfil visual previo, una ÚNICA aplicación
 // maximizada (aunque esté detrás de Konsole/Steam restaurada) permite
 // recuperar su perfil como anclaje inicial. Ambigüedad => no adivinar.
 // No cambia foco, no guarda nada y nunca elige entre dos apps distintas.
function uniqueMaximizedProfile(rows, savedProfiles) {
    const unknown = {known: false, appId: "", offset: 0};
    if (!Array.isArray(rows) || !savedProfiles ||
        typeof savedProfiles !== "object") return unknown;
    const maximizedIds = Object.create(null);
    for (const row of rows) {
        if (!row || row.maximized !== true || row.minimized === true ||
            row.fullscreen === true) continue;
        const id = typeof row.appId === "string" ? row.appId.trim() : "";
        if (!id) return unknown;
        maximizedIds[id] = true;
    }
    const ids = Object.keys(maximizedIds);
    if (ids.length !== 1) return unknown;
    const id = ids[0];
    if (!Object.prototype.hasOwnProperty.call(savedProfiles, id)) return unknown;
    const offset = savedProfiles[id];
    if (typeof offset !== "number" || !Number.isFinite(offset) || offset < 0)
        return unknown;
    return {known: true, appId: id, offset: offset};
}


 // Excepción APROBADA: desmaximizar la MISMA aplicación activa no debe
 // mandar SO a la derecha si hay otra app maximizada detrás.
 // Una única app distinta con perfil habilita anclaje temporal; con varias
 // candidatas o sin perfil se conserva la posición visual, sin adivinar.
 // Si no queda otra maximizada, se mantiene el retorno general habitual.
function fallbackAfterActiveUnmaximize(rows, active, previousAppId,
                                       previousMaximized, savedProfiles) {
    const normal = {kind: "normal", appId: "", offset: 0};
    if (!active || active.known !== true || !active.appId ||
        active.fullscreen === true || active.maximized === true ||
        active.appId !== previousAppId || previousMaximized !== true ||
        !Array.isArray(rows)) return normal;

    // En la transición, elegir la maximizada visible más alta,
    // nunca una aplicación de fondo por ser la única con perfil.
    const remaining = rows.filter(function(row) {
        return row && row.appId !== active.appId;
    });
    return topmostMaximizedProfile(remaining, savedProfiles);
}


 // Prioridad: ventana MAXIMIZADA más alta en el apilamiento visual.
 // StackingOrder: número creciente hacia delante. -1 significa que
 // Wayland no lo informó; en empate/ausencia no inferir un ganador.
 // Una sola maximizada es inequívoca aun sin rol de apilamiento.
 // No se utiliza foco, orden alfabético ni último perfil visitado.
function topmostMaximizedProfile(rows, savedProfiles) {
    const none = {kind: "none", appId: "", offset: 0};
    const hold = {kind: "hold", appId: "", offset: 0};
    if (!Array.isArray(rows)) return hold;
    const candidates = rows.filter(function(row) {
        return row && row.maximized === true &&
            row.minimized !== true && row.fullscreen !== true;
    });
    if (candidates.length === 0) return none;
    let winner;
    if (candidates.length === 1) {
        winner = candidates[0];
    } else {
        // Los índices incompletos/duplicados son frecuentes mientras
        // KWin comunica un nuevo apilamiento de forma asíncrona.
        if (candidates.some(function(row) {
            return typeof row.stackingOrder !== "number" ||
                !Number.isInteger(row.stackingOrder) ||
                row.stackingOrder < 0;
        })) return hold;
        let highest = -1;
        let countHighest = 0;
        for (const row of candidates) {
            if (row.stackingOrder > highest) {
                highest = row.stackingOrder;
                winner = row;
                countHighest = 1;
            } else if (row.stackingOrder === highest) {
                countHighest++;
            }
        }
        if (countHighest !== 1) return hold;
    }
    const id = typeof winner.appId === "string"
        ? winner.appId.trim() : "";
    if (!id || !savedProfiles || typeof savedProfiles !== "object" ||
        !Object.prototype.hasOwnProperty.call(savedProfiles, id))
        return hold;
    const offset = savedProfiles[id];
    if (typeof offset !== "number" || !Number.isFinite(offset) ||
        offset < 0) return hold;
    return {kind: "profile", appId: id, offset: offset};
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
