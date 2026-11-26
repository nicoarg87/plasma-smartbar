.pragma library

// Copia para cancelar cambios sin alterar el valor persistido por el visor.
// Colores QML se convierten a texto como hacia SoledadSettings.qml.
function preferenceCopy(key, value, colorKeys) {
    if (value === undefined || value === null) return value
    if (colorKeys.indexOf(key) !== -1) return String(value)
    if (typeof value === "object") return JSON.parse(JSON.stringify(value))
    return value
}
