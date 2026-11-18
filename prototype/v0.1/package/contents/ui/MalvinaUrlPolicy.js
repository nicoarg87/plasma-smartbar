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

// Precarga experimental: q= puede incluso causar envío automático según el
// proveedor y su versión. Solo se genera con consentimiento por proveedor.
// NUNCA incluir consultas en destinos editados, aunque usen HTTPS.
function resolveAiPrefill(providerIndex, providerUrl, query, authorized) {
    const base = resolve(providerUrl, query, true)
    if (!base.ok || !authorized) return base
    const normalized = String(providerUrl).trim().toLowerCase().replace(/\/$/, "")
    const official = [
        { bases: ["https://chatgpt.com", "https://www.chatgpt.com"], target: "https://chatgpt.com/" },
        { bases: ["https://gemini.google.com/app"], target: "https://gemini.google.com/app" },
        { bases: ["https://claude.ai/new"], target: "https://claude.ai/new" }
    ]
    if (providerIndex < 0 || providerIndex >= official.length)
        return base
    const item = official[providerIndex]
    if (item.bases.indexOf(normalized) < 0)
        return { ok: true, url: base.url, warning: "URL personalizada: no se comparte texto" }
    const encoded = encodeURIComponent(String(query).trim())
    // No anexar parámetros a direcciones que contengan redirecciones.
    return {
        ok: true, url: item.target + "?q=" + encoded,
        experimental: true
    }
}
