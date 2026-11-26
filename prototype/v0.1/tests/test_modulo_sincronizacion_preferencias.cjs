#!/usr/bin/env node
"use strict";
// Ejecuta la copia de preferencias con objetos ficticios; no usa QML ni KConfig.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "../package/contents/ui");
const main = fs.readFileSync(path.join(base, "SmartBarContent.qml"), "utf8");
const source = fs.readFileSync(path.join(base, "SoledadSettingsSync.js"), "utf8");
const keys = [...source.matchAll(/settings\.([A-Za-z]\w*)\s*=/g)].map(match => match[1]);
assert.equal(keys.length, 157, "No descartar ni duplicar preferencias");
assert.equal(new Set(keys).size, keys.length);
assert.match(main, /import "SoledadSettingsSync\.js" as SoledadSettingsSync/);
assert.match(main, /function syncSettingsFromRoot\(\)\s*\{\s*SoledadSettingsSync\.sync\(root, soledadSettings\)/);
const context = {JSON};
vm.createContext(context);
vm.runInContext(source.replace(/^\.pragma library\s*/m, ""), context);
const accessed = new Set();
const host = new Proxy({}, {get(target, key) {
  accessed.add(key);
  if (key === "outlineConfig") return {soledad: {width: 2}};
  return "mock:" + String(key);
}});
const actual = {};
context.sync(host, actual);
for (const key of keys) assert.ok(Object.prototype.hasOwnProperty.call(actual, key), "Sin copiar: " + key);
assert.equal(actual.logoMode, "mock:soLogoMode");
assert.equal(actual.filePath, "mock:soLogoPath");
assert.equal(actual.alignedRight, "mock:alignRightSelected");
assert.equal(actual.alignmentEdited, false);
assert.equal(actual.outlineConfig.soledad.width, 2);
assert.ok(accessed.size > 125);
assert.doesNotMatch(source, /\broot\.\w+|\bsoledadSettings\.\w+|QtCore\.Settings/);
console.log("OK: 157 asignaciones de preferencias ejecutadas con dobles, sin persistencia.");
