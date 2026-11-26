.pragma library

// Cálculos puros de respiración de degradados. Sin estados ni efectos QML.
function breathingFactor(intensity, phase) {
    const wave = 0.5 - 0.5 * Math.cos(2 * Math.PI * phase)
    // Intensidad por isla; solo si el usuario lo pide sigue al pulso SO.
    // Intensidad 0 = sin modulación; 100 % = hasta 65 % de amplitud.
    const amplitude = Math.max(0, Math.min(1, intensity)) * 0.65
    return 1 - amplitude * (1 - wave)
}

function nextPhase(phase, speed, dt) {
    return (phase + Math.max(0.1, Math.min(3, speed)) * dt) % 1
}
