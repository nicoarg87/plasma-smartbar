.pragma library

// Horarios civiles locales (HH:MM), sin animaciones ni reloj externo.
// Las franjas son contiguas: el fin de una es el inicio de la siguiente.
var THEMES = ["day", "sunset", "night"]

function defaults(count) {
    if (count === 3) return [
        {start:"08:00", theme:"day"},
        {start:"18:00", theme:"sunset"},
        {start:"21:00", theme:"night"}
    ]
    return [
        {start:"06:00", theme:"sunset"},
        {start:"08:00", theme:"day"},
        {start:"18:00", theme:"sunset"},
        {start:"21:00", theme:"night"}
    ]
}

function minutes(value) {
    if (typeof value !== "string" || !/^(?:[01][0-9]|2[0-3]):[0-5][0-9]$/.test(value))
        return -1
    return Number(value.slice(0,2)) * 60 + Number(value.slice(3,5))
}

function valid(slots, count) {
    if ((count !== 3 && count !== 4) || !Array.isArray(slots) || slots.length !== count)
        return false
    let previous = -1
    for (let i=0;i<slots.length;i++) {
        const item=slots[i]
        if (!item || THEMES.indexOf(item.theme) < 0) return false
        const time=minutes(item.start)
        if (time <= previous) return false
        previous = time
    }
    return true
}

function read(json, count) {
    try {
        const slots = JSON.parse(json)
        if (valid(slots, count))
            return slots.map(function(row){ return {start:row.start,theme:row.theme} })
    } catch (_) { }
    return defaults(count)
}

function serialize(slots, count) {
    return valid(slots, count) ? JSON.stringify(slots) : ""
}

function withBoundary(slots, index, boundary, value) {
    if (!Array.isArray(slots) || (slots.length !== 3 && slots.length !== 4))
        return null
    if (minutes(value) < 0 || !Number.isInteger(index) || index<0 || index>=slots.length)
        return null
    const target = boundary === "start" ? index :
                   boundary === "end" ? (index+1)%slots.length : -1
    if (target < 0) return null
    const updated = slots.map(function(row){ return {start:row.start, theme:row.theme} })
    updated[target].start = value
    return valid(updated, updated.length) ? updated : null
}

function withTheme(slots, index, theme) {
    if (!Array.isArray(slots) || !Number.isInteger(index) || index < 0 ||
        index >= slots.length || THEMES.indexOf(theme) < 0) return null
    const next=slots.map(function(row){ return {start:row.start,theme:row.theme} })
    next[index].theme=theme
    return valid(next, next.length) ? next : null
}

function current(slots, hour, minute) {
    if (!Array.isArray(slots) || !valid(slots, slots.length) ||
        !Number.isInteger(hour) || !Number.isInteger(minute) ||
        hour<0 || hour>23 || minute<0 || minute>59) return null
    const now=hour*60+minute
    let index=slots.length-1
    for (let i=0;i<slots.length;i++) {
        if (minutes(slots[i].start)<=now) index=i
        else break
    }
    return {index:index, start:slots[index].start,
            end:slots[(index+1)%slots.length].start,
            theme:slots[index].theme}
}

function activeNow(json, count, clock) {
    const now=clock || new Date()
    return current(read(json,count),now.getHours(),now.getMinutes())
}
