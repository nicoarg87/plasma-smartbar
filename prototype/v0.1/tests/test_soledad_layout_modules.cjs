#!/usr/bin/env node
"use strict";
// Regresión del refactor: comparar políticas separadas con las reglas
// originales de v0.1. No abre Qt, ni interviene sobre el escritorio KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "../package/contents/ui");
const read = file => fs.readFileSync(path.join(base, file), "utf8");
function load(name) {
    const source = read(name);
    assert.match(source, /^\.pragma library\s/);
    const context = {};
    vm.runInNewContext(source.replace(/^\.pragma library\s*/, ""), context);
    return context;
}
function plain(value) { return JSON.parse(JSON.stringify(value)); }
const expansion = load("SoledadExpansionPolicy.js");
const placement = load("SoledadLauncherPlacement.js");
const sizing = load("SoledadTaskSizing.js");

function priorFit(s) {
    let so = s.soExpanded, tray = s.trayExpanded, warn = false;
    if (s.centeredPresentation) {
        if (!so && !tray) return {soExpanded: so, trayExpanded: tray, centeredOverflow: warn};
        const left = s.leftReserved, right = s.width - s.rightReserved;
        if (s.naturalIslandWidth > s.physicalIslandLimit + 0.5 ||
            s.systemIslandX < left - 0.5 ||
            s.systemIslandX + s.systemIslandWidth > right + 0.5) {
            if (so && tray) {
                if (s.lastExpandedMode === "so") tray = false;
                else so = false;
            } else if (so) so = false;
            else if (tray) tray = false;
            warn = true;
        }
    } else if (so && tray && s.naturalIslandWidth > s.availableIslandWidth + 0.5) {
        if (s.lastExpandedMode === "tray") so = false;
        else tray = false;
    }
    return {soExpanded: so, trayExpanded: tray, centeredOverflow: warn};
}
let expansionCases = 0;
for (const centered of [false, true])
for (const so of [false, true])
for (const tray of [false, true])
for (const last of ["so", "tray"])
for (const natural of [200, 500, 500.5, 501, 700])
for (const x of [25, 80, 800]) {
    const state = {
        centeredPresentation: centered,
        soExpanded: so,
        trayExpanded: tray,
        lastExpandedMode: last,
        naturalIslandWidth: natural,
        physicalIslandLimit: 700,
        systemIslandX: x,
        systemIslandWidth: natural,
        leftReserved: 25,
        rightReserved: 50,
        width: 900,
        availableIslandWidth: 500
    };
    const frozen = JSON.stringify(state);
    assert.deepEqual(plain(expansion.fit(state)), priorFit(state));
    assert.equal(JSON.stringify(state), frozen, "la política no puede mutar la vista");
    expansionCases++;
}
function priorPlacement(g) {
    const popupWidth = g.popupWidth;
    const screenWidth = g.requirePositiveScreenWidth ? Math.max(1, g.screenWidth) : g.screenWidth;
    const maxLeft = Math.max(0, screenWidth - popupWidth);
    if (g.fromSo)
        return Math.max(0, Math.min(maxLeft,
            g.systemIslandX + g.systemIslandWidth - popupWidth));
    const center = g.launcherCenter;
    if (g.categoryLayout === 1 &&
        (g.showCategoryPanel || (g.filesMode && g.expandedCanvas))) {
        const baseX = Math.max(0, Math.min(Math.max(0, screenWidth - g.primaryWidth),
            center - g.primaryWidth / 2));
        return Math.max(0, Math.min(maxLeft, baseX - (popupWidth - g.primaryWidth)));
    }
    return Math.max(0, Math.min(maxLeft, center - popupWidth / 2));
}
let placementCases = 0;
for(const minWidth of [false, true])
for(const sw of [0, 1, 640, 1920])
for(const pw of [1, 285, 620])
for(const fromSo of [false, true])
for(const layout of [0, 1])
for(const category of [false, true])
for(const files of [false, true]) {
    const opts = {
        requirePositiveScreenWidth: minWidth,
        popupWidth: pw, screenWidth: sw, fromSo,
        systemIslandX: 30, systemIslandWidth: 80,
        launcherCenter: 450, categoryLayout: layout,
        showCategoryPanel: category, filesMode: files,
        expandedCanvas: true, primaryWidth: 285
    };
    assert.equal(placement.screenLeft(opts), priorPlacement(opts),
                 "coordenada debe conservarse incluso en pantallas estrechas");
    placementCases++;
}
function priorSizing(current, requested, count, available, natural) {
    const n = Math.max(1, count);
    const spare = Math.max(0, available - natural);
    const maximum = Math.max(0, Math.min(160,
        current + Math.floor(spare / n)));
    return Math.max(0, Math.min(maximum, Math.round(requested)));
}
let sizingCases = 0;
for(const current of [0, 40, 160])
for(const requested of [-4, 5.5, 100, 300])
for(const count of [0, 1, 2, 10])
for(const available of [120, 700]) {
    assert.equal(sizing.resizedExtraWidth(current, requested, count, available, 250),
                 priorSizing(current, requested, count, available, 250));
    sizingCases++;
}
const bar = read("SmartBarContent.qml");
for(const name of ["SoledadExpansionPolicy", "SoledadLauncherPlacement", "SoledadTaskSizing"])
    assert(bar.includes('import "' + name + '.js" as ' + name), "importación " + name);
assert(bar.includes("const next = SoledadExpansionPolicy.fit({"));
assert(bar.includes("if (next.soExpanded !== soExpanded) soExpanded = next.soExpanded"));
assert(bar.includes("if (next.trayExpanded !== trayExpanded) trayExpanded = next.trayExpanded"));
assert(bar.includes("if (next.centeredOverflow)"));
assert.equal((bar.match(/SoledadLauncherPlacement\.screenLeft\(\{/g) || []).length, 2,
             "un solo algoritmo para la posición del launcher real y de visor");
assert(bar.includes("return left - anchor.mapToItem(root, 0, 0).x"),
       "anclaje de Popup.Window permanece local a QML");
assert(bar.includes("taskNameExtraWidth = SoledadTaskSizing.resizedExtraWidth("));
assert(bar.includes('taskWidthSettings.setValue("extraWidth", taskNameExtraWidth)'),
       "se conserva la persistencia existente");
console.log("OK: políticas SO separadas; " + expansionCases + " casos de expansión, " +
            placementCases + " de geometría, " + sizingCases + " de fichas; sin cambios KDE.");
