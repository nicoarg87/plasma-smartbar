.pragma library

// Política pura de convivencia entre el cajón SO y la bandeja.
// La vista conserva geometría, botones, estado y advertencias.
// Contrato vigente: ambos quedan abiertos si caben, y la última
// expansión solicitada tiene prioridad solo cuando falta espacio.
function fit(state) {
    const result = {
        soExpanded: state.soExpanded,
        trayExpanded: state.trayExpanded,
        centeredOverflow: false
    }
    if (state.centeredPresentation) {
        if (!state.soExpanded && !state.trayExpanded) return result

        const leftLimit = state.leftReserved
        const rightLimit = state.width - state.rightReserved
        if (state.naturalIslandWidth > state.physicalIslandLimit + 0.5 ||
            state.systemIslandX < leftLimit - 0.5 ||
            state.systemIslandX + state.systemIslandWidth > rightLimit + 0.5) {
            if (state.soExpanded && state.trayExpanded) {
                if (state.lastExpandedMode === "so") result.trayExpanded = false
                else result.soExpanded = false
            } else if (state.soExpanded) result.soExpanded = false
            else if (state.trayExpanded) result.trayExpanded = false
            result.centeredOverflow = true
        }
        return result
    }

    if (!state.soExpanded || !state.trayExpanded) return result
    if (state.naturalIslandWidth > state.availableIslandWidth + 0.5) {
        if (state.lastExpandedMode === "tray") result.soExpanded = false
        else result.trayExpanded = false
    }
    return result
}
