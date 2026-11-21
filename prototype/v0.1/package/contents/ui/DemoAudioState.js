.pragma library
// Estado de audio SIMULADO por aplicación. Funciones puras, sin PipeWire/KWin.
// Las preferencias reales y el sonido del sistema nunca se modifican.

function normalizeVolume(value) {
    return Math.max(0, Math.min(100, Math.round(Number(value) || 0)))
}

function volume(volumes, appName) {
    const stored = volumes[appName]
    return stored === undefined ? 70 : normalizeVolume(stored)
}

function isMuted(muted, volumes, appName) {
    return muted[appName] === true || volume(volumes, appName) === 0
}

function setVolume(muted, volumes, appName, value) {
    const next = normalizeVolume(value)
    const updatedVolumes = Object.assign({}, volumes)
    updatedVolumes[appName] = next
    const updatedMuted = Object.assign({}, muted)
    updatedMuted[appName] = next === 0
    return { volumes: updatedVolumes, muted: updatedMuted }
}

function toggleMute(muted, volumes, appName) {
    const wasMuted = isMuted(muted, volumes, appName)
    const updatedMuted = Object.assign({}, muted)
    updatedMuted[appName] = !wasMuted
    // El comportamiento previo recupera un 50 % ficticio desde cero.
    let updatedVolumes = volumes
    if (wasMuted && volume(volumes, appName) === 0) {
        updatedVolumes = Object.assign({}, volumes)
        updatedVolumes[appName] = 50
    }
    return { volumes: updatedVolumes, muted: updatedMuted }
}
