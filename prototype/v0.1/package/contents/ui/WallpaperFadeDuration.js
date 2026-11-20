.pragma library

// Preferencia del fundido del wallpaper simulado. Independiente de los temas.
var limits = {seconds:3600, minutes:240, hours:24}
var factors = {seconds:1000, minutes:60000, hours:3600000}

function valid(amount, unit) {
    return Object.prototype.hasOwnProperty.call(limits, unit) &&
           typeof amount === "number" && isFinite(amount) &&
           Math.floor(amount) === amount &&
           amount >= 1 && amount <= limits[unit]
}

function normalizeUnit(unit) {
    return Object.prototype.hasOwnProperty.call(limits, unit) ? unit : "seconds"
}

function normalizeAmount(amount, unit) {
    const chosen = normalizeUnit(unit)
    const number = Number(amount)
    return valid(number, chosen) ? number : (chosen === "seconds" ? 3 : 1)
}

function durationMs(amount, unit) {
    const chosen = normalizeUnit(unit)
    return normalizeAmount(amount, chosen) * factors[chosen]
}
