.pragma library

// Packs de temas: solo estructura y selección; sin escrituras ni efectos Qt.
// Playa 24hs utiliza los tres perfiles existentes (no almacena copias).
// Los packs creados por el usuario conservan sus instantáneas por separado.
var DEFAULT_ID = "playa-24hs"
var NAME = "Playa 24hs"
var THEMES = ["sunset", "night", "day"]

function title(automatic) {
    return NAME + " · " + (automatic ? "Automático" : "Manual")
}

function isManualTheme(theme) {
    return THEMES.indexOf(theme) >= 0
}

// Lectura sin filtrar para reescribir solo el pack editado, preservando
// versiones futuras/desconocidas en almacenamiento. JSON inválido: bloquear.
function raw(json) {
    try {
        const values = JSON.parse(json || "[]")
        return Array.isArray(values) ? values : null
    } catch (error) { return null }
}

function parse(json) {
    try {
        const values = JSON.parse(json || "[]")
        if (!Array.isArray(values)) return []
        return values.filter(function(pack) {
            return pack && typeof pack.id === "string" &&
                /^pack-[1-9][0-9]*$/.test(pack.id) &&
                typeof pack.name === "string" && pack.name.trim().length > 0 &&
                Array.isArray(pack.members) && pack.members.length > 0 &&
                pack.members.every(function(member) {
                    return member && typeof member.name === "string" &&
                        ((member.kind === "preset" &&
                            ["day", "sunset", "night"].indexOf(member.theme) >= 0) ||
                         (member.kind === "snapshot" &&
                            typeof member.jsonData === "string" &&
                            member.jsonData.length > 0))
                })
        })
    } catch (error) { return [] }
}

function find(packs, id) {
    for (let i = 0; i < packs.length; ++i) {
        if (packs[i].id === id) return packs[i]
    }
    return null
}

function labels(pack) {
    return pack && Array.isArray(pack.members) ?
        pack.members.map(function(member) { return member.name }) : []
}

function nextId(packs) {
    let maxId = 0
    for (let i = 0; i < packs.length; ++i) {
        const id = packs[i] && typeof packs[i].id === "string"
            ? packs[i].id : ""
        const match = /^pack-([1-9][0-9]*)$/.exec(id)
        if (match) maxId = Math.max(maxId, Number(match[1]))
    }
    return "pack-" + (maxId + 1)
}

function defaultSlots(count, memberCount) {
    const positions = count === 3 ? ["08:00", "18:00", "21:00"] :
        ["06:00", "08:00", "18:00", "21:00"]
    const indexes = count === 3 ? [0, 1, 2] : [1, 0, 1, 2]
    return positions.map(function(start, i) {
        return {start: start, member: Math.min(memberCount - 1, indexes[i])}
    })
}

function minutes(value) {
    if (typeof value !== "string" ||
        !/^(?:[01][0-9]|2[0-3]):[0-5][0-9]$/.test(value)) return -1
    return Number(value.slice(0, 2)) * 60 + Number(value.slice(3, 5))
}

function validSlots(slots, count, memberCount) {
    if (!Array.isArray(slots) || slots.length !== count ||
        (count !== 3 && count !== 4) || memberCount < 1) return false
    let previous = -1
    for (let i = 0; i < slots.length; ++i) {
        const row = slots[i]
        if (!row || !Number.isInteger(row.member) ||
            row.member < 0 || row.member >= memberCount) return false
        const time = minutes(row.start)
        if (time <= previous) return false
        previous = time
    }
    return true
}

function schedule(pack, count) {
    if (!pack || !pack.members) return []
    const slots = count === 3 ? pack.slots3 : pack.slots4
    return validSlots(slots, count, pack.members.length) ?
        slots.map(function(row) { return {start: row.start, member: row.member} }) :
        defaultSlots(count, pack.members.length)
}

// Estado de modo y cantidad de franjas propio de cada pack personal.
// Valores heredados: usar los ajustes históricos de Playa una sola vez.
function automatic(pack, legacyEnabled) {
    return pack && typeof pack.automaticEnabled === "boolean"
        ? pack.automaticEnabled : legacyEnabled === true
}

function slotCount(pack, legacyCount) {
    return pack && (pack.slotCount === 3 || pack.slotCount === 4)
        ? pack.slotCount : legacyCount === 3 ? 3 : 4
}

function withPreferences(pack, enabled, count) {
    if (!pack || typeof enabled !== "boolean" || (count !== 3 && count !== 4))
        return null
    return Object.assign({}, pack, {
        automaticEnabled: enabled,
        slotCount: count
    })
}

function ensurePreferences(pack, legacyEnabled, legacyCount) {
    if (!pack) return null
    if (typeof pack.automaticEnabled === "boolean" &&
        (pack.slotCount === 3 || pack.slotCount === 4)) return pack
    return withPreferences(pack,
        automatic(pack, legacyEnabled), slotCount(pack, legacyCount))
}

function update(pack, count, slots) {
    if (!pack || !validSlots(slots, count, pack.members.length)) return null
    const result = Object.assign({}, pack)
    result[count === 3 ? "slots3" : "slots4"] = slots.map(function(row) {
        return {start: row.start, member: row.member}
    })
    return result
}

function withBoundary(pack, count, index, boundary, time) {
    const slots = schedule(pack, count)
    const target = boundary === "start" ? index :
        boundary === "end" ? (index + 1) % count : -1
    if (target < 0 || target >= count || minutes(time) < 0) return null
    slots[target].start = time
    return update(pack, count, slots)
}

function withMember(pack, count, index, memberIndex) {
    const slots = schedule(pack, count)
    if (index < 0 || index >= count ||
        !Number.isInteger(memberIndex) || memberIndex < 0 ||
        memberIndex >= pack.members.length) return null
    slots[index].member = memberIndex
    return update(pack, count, slots)
}

function active(pack, count, clock) {
    if (!pack || !pack.members || !pack.members.length) return null
    const slots = schedule(pack, count)
    if (!slots.length) return null
    const date = clock || new Date()
    const now = date.getHours() * 60 + date.getMinutes()
    let index = slots.length - 1
    for (let i = 0; i < slots.length; ++i) {
        if (minutes(slots[i].start) <= now) index = i
        else break
    }
    return {index: index, start: slots[index].start,
            memberIndex: slots[index].member,
            member: pack.members[slots[index].member]}
}

function create(packs, name, members, enabled, count) {
    const normalizedName = String(name || "").trim().slice(0, 60)
    if (!normalizedName || normalizedName.toLocaleLowerCase() === NAME.toLocaleLowerCase() ||
        !Array.isArray(members) || members.length < 1 ||
        members.length > 20 || packs.length >= 30) return null
    const validMembers = members.every(function(member) {
        return member && typeof member.name === "string" &&
            ((member.kind === "preset" && isManualTheme(member.theme)) ||
             (member.kind === "snapshot" && typeof member.jsonData === "string" &&
              member.jsonData.length > 0))
    })
    if (!validMembers || packs.some(function(item) {
        return item && typeof item.name === "string" &&
            item.name.trim().toLocaleLowerCase() === normalizedName.toLocaleLowerCase()
    })) return null
    const pack = {id: nextId(packs), name: normalizedName,
                  members: members.map(function(member) { return Object.assign({}, member) })}
    pack.slots3 = defaultSlots(3, pack.members.length)
    pack.slots4 = defaultSlots(4, pack.members.length)
    pack.automaticEnabled = typeof enabled === "boolean" ? enabled : true
    pack.slotCount = count === 3 ? 3 : 4
    return pack
}

function replace(packs, pack) {
    return packs.map(function(item) {
        return item && item.id === pack.id ? pack : item
    })
}
