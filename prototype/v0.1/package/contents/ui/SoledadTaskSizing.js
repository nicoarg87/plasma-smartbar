.pragma library

// Ajuste puro del ancho extra de los nombres en las fichas SO.
// No modifica fuentes, cantidad de ventanas, perfiles ni preferencias.
// El componente QML continúa siendo responsable de guardar en Qt Settings.
function resizedExtraWidth(currentExtraWidth, requestedWidth, taskCount,
                           availableIslandWidth, naturalIslandWidth) {
    const count = Math.max(1, taskCount)
    const spare = Math.max(0, availableIslandWidth - naturalIslandWidth)
    const maximum = Math.max(0, Math.min(160,
        currentExtraWidth + Math.floor(spare / count)))
    return Math.max(0, Math.min(maximum, Math.round(requestedWidth)))
}
