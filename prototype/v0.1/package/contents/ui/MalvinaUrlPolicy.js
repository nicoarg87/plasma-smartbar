// Politica de navegacion de Malvina. No ejecuta comandos ni accede a ventanas KDE.
// Solo devuelve una URL HTTPS validada o una razon de rechazo.
// La apertura externa corresponde exclusivamente al componente que llama.
// Compatible con JavaScript de Qt/QML, sin dependencias de navegador.
.pragma library

function validHttpsUrl(value) {
    const url = String(value === undefined || value === null ? "" : value).trim()
    // Rechazar caracteres de control, espacios, barras invertidas y sintaxis ambigua.
    if (!url || /[\x00-\x20\x7f\\]/.test(url)) return false
    const match = /^https:\/\/([^\/?#]+)(?:[\/?#]|$)/i.exec(url)
    if (!match) return false
    const authority = match[1]
    // Evitar credenciales ocultas, puertos arbitrarios y hosts sin dominio.
    if (authority.indexOf("@") !== -1 || authority.indexOf(":") !== -1) return false
    if (authority.length > 253 || !/^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$/i.test(authority))
        return false
    return true
}

function resolve(providerUrl, query, isAi) {
    const value = String(query === undefined || query === null ? "" : query).trim()
    if (!value) return { ok: false, reason: "Consulta vacia" }
    const template = String(providerUrl === undefined || providerUrl === null ? "" : providerUrl).trim()
    if (!validHttpsUrl(template))
        return { ok: false, reason: "Proveedor sin URL HTTPS publica valida" }
    if (isAi) {
        // Los proveedores IA no tienen un contrato URL universal para enviar prompts.
        return { ok: true, url: template }
    }
    if (template.indexOf("{query}") < 0)
        return { ok: false, reason: "Plantilla web sin {query}" }
    const url = template.split("{query}").join(encodeURIComponent(value))
    if (!validHttpsUrl(url))
        return { ok: false, reason: "URL final invalida" }
    return { ok: true, url: url }
}
