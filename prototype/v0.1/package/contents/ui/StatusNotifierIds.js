.pragma library

// Inventario puro de identificadores SNI de KDE, nunca ejecuta acciones D-Bus.
// Un ítem registrado puede ser «servicio/ruta» o solo «servicio»;
// en el segundo caso el protocolo usa /StatusNotifierItem.
function parseRegisteredId(raw) {
    if (typeof raw !== "string" || raw.length === 0 || raw.length > 512)
        return null
    const slash = raw.indexOf("/")
    const service = slash === -1 ? raw : raw.slice(0, slash)
    const objectPath = slash === -1 ? "/StatusNotifierItem" : raw.slice(slash)
    const wellKnown = /^(?:[A-Za-z_][A-Za-z0-9_-]*\.)+[A-Za-z_][A-Za-z0-9_-]*$/
    const unique = /^:[0-9]+(?:\.[0-9]+)+$/
    const validPath = /^\/(?:[A-Za-z0-9_]+(?:\/[A-Za-z0-9_]+)*)?$/
    if (service.length > 255 || !((wellKnown.test(service) || unique.test(service)) &&
          validPath.test(objectPath))) return null
    return {service: service, objectPath: objectPath, key: service + objectPath}
}

// Aísla y deduplica el estado recibido del observador; no mutar la lista.
// Se descartan identificadores inválidos, nunca se interpretan como comandos.
function normalizeRegisteredIds(values) {
    if (!Array.isArray(values)) return []
    const seen = {}
    const result = []
    for (let i = 0; i < values.length; ++i) {
        const item = parseRegisteredId(values[i])
        if (!item || Object.prototype.hasOwnProperty.call(seen, item.key)) continue
        seen[item.key] = true
        result.push(item)
    }
    return result
}
