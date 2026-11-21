.pragma library
// Política pura de posiciones de Soledad. Sin interacción con KWin ni disco.
// Valores en píxeles lógicos de desplazamiento desde la referencia derecha.
function validAppId(value) {
    if (typeof value !== "string") return "";
    const id = value.trim();
    if (!id || id.length > 256 || /[\u0000-\u001f\u007f]/.test(id) ||
        id === "__proto__" || id === "constructor" || id === "prototype") return "";
    return id;
}
function clampOffset(offset, maxOffset) {
    const max = Number.isFinite(maxOffset) ? Math.max(0, maxOffset) : 0;
    const value = Number.isFinite(offset) ? offset : 0;
    return Math.min(max, Math.max(0, value));
}
function readProfiles(json) {
    let source;
    try { source = JSON.parse(typeof json === "string" ? json : "{}"); }
    catch (_) { return Object.create(null); }
    const result = Object.create(null);
    if (!source || typeof source !== "object" || Array.isArray(source)) return result;
    for (const key of Object.keys(source).slice(0, 250)) {
        const id = validAppId(key);
        if (!id || !Object.prototype.hasOwnProperty.call(source, key)) continue;
        const offset = source[key];
        if (typeof offset === "number" && Number.isFinite(offset) && offset >= 0)
            result[id] = offset;
    }
    return result;
}
function saveProfile(json, appId, offset, maxOffset) {
    const id = validAppId(appId);
    if (!id || !Number.isFinite(offset)) return null;
    const profiles = readProfiles(json);
    profiles[id] = clampOffset(offset, maxOffset);
    return JSON.stringify(profiles);
}
function removeProfile(json, appId) {
    const id = validAppId(appId);
    if (!id) return null;
    const profiles = readProfiles(json);
    delete profiles[id];
    return JSON.stringify(profiles);
}
function resolveOffset(json, appId, active, maximized, defaultOffset, maxOffset) {
    const baseline = clampOffset(defaultOffset, maxOffset);
    const id = validAppId(appId);
    if (!id || active !== true || maximized !== true) return baseline;
    const profiles = readProfiles(json);
    return Object.prototype.hasOwnProperty.call(profiles, id)
        ? clampOffset(profiles[id], maxOffset) : baseline;
}
