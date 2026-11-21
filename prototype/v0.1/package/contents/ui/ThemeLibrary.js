.pragma library

// Lectura aislada de la biblioteca local de temas.
// No escribe preferencias, no crea temas ni modifica los objetos guardados.
// Mantener exactamente la tolerancia histórica de SoledadSettings:
// JSON vacío -> [], valores que no sean arrays -> [], y entradas inválidas
// se excluyen sin reinterpretar ni sobrescribir entradas válidas.
function parse(json) {
    const items = JSON.parse(json || "[]")
    if (!Array.isArray(items)) return []
    return items.filter(function(item) {
        return item && typeof item.name === "string" &&
               typeof item.jsonData === "string" && item.jsonData.length > 0
    })
}

// Índices de los temas personales según el orden guardado. Nunca se
// mezclan ni sobrescriben los perfiles oficiales inmutables de fábrica.
// Compatibilidad: respetar espacios y mayúsculas como el código QML previo.
function namedThemeIndex(items, theme) {
    const names = theme === "day" ? ["día", "dia"] :
                  theme === "sunset" ? ["atardecer"] :
                  theme === "night" ? ["noche", "anoche"] : []
    if (!names.length) return -1
    for (let i = 0; i < items.length; ++i) {
        if (names.indexOf(items[i].name.trim().toLocaleLowerCase()) >= 0)
            return i
    }
    return -1
}

// Día se muestra en la tercera entrada dedicada del selector. Los otros
// temas personales mantienen la posición original de la biblioteca.
function otherNamedThemes(items) {
    return items.filter(function(item) {
        const name = item.name.trim().toLocaleLowerCase()
        return name !== "día" && name !== "dia"
    })
}

function otherNamedThemeOriginalIndex(items, index) {
    let count = 0
    for (let i = 0; i < items.length; ++i) {
        const name = items[i].name.trim().toLocaleLowerCase()
        if (name === "día" || name === "dia") continue
        if (count++ === index) return i
    }
    return -1
}
