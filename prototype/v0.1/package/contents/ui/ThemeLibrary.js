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
