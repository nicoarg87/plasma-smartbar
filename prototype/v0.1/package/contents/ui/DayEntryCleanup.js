.pragma library

// Limpieza puntual autorizada: EXACTAMENTE los dos registros vistos en la
// captura del 20/11/2026. No tocar "Día", otros temas ni futuros respaldos.
// No usa ThemeLibrary.parse: debe conservar incluso entradas históricas raras.
const unwantedNames = [
    "Día · versión anterior",
    "Día · respaldo 2026-11-20T02-00"
]

function plan(items) {
    if (!Array.isArray(items))
        return {ok: false, reason: "La biblioteca no es un arreglo; no se modifica."}
    const counts = [0, 0]
    for (let i = 0; i < items.length; ++i) {
        const entry = items[i]
        if (!entry || typeof entry.name !== "string") continue
        for (let j = 0; j < unwantedNames.length; ++j) {
            if (entry.name === unwantedNames[j]) ++counts[j]
        }
    }
    if (counts[0] !== 1 || counts[1] !== 1)
        return {ok: false, reason: "Se esperaban exactamente las dos entradas de la captura (una de cada nombre). Halladas: " +
                               counts[0] + " y " + counts[1] + ". No se modifica nada."}

    const remaining = items.filter(function(entry) {
        return !(entry && typeof entry.name === "string" &&
            (entry.name === unwantedNames[0] || entry.name === unwantedNames[1]))
    })
    return {ok: true, items: remaining, removed: unwantedNames.slice()}
}
