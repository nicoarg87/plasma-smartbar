#!/usr/bin/env node
"use strict";
// Regresión de política documental/licencias. Solo lectura: sin KDE, Qt ni red.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname,"../../..");
const load = file => fs.readFileSync(path.join(root,file),"utf8");

const license = load("LICENSE");
assert(license.startsWith("MIT License"),"El archivo LICENSE oficial debe ser MIT");
const metadata = JSON.parse(load("prototype/v0.1/package/metadata.json"));
assert.equal(metadata.KPlugin.License,"MIT",
             "Los metadatos de Plasma no pueden declarar una licencia distinta");

const manifest = JSON.parse(load(
    "prototype/v0.1/package/contents/ui/assets/wallpapers/manifest.json"));
assert.equal(manifest.assets.length,3);
assert.deepEqual(manifest.assets.map(asset=>asset.theme),["day","sunset","night"]);
for (const asset of manifest.assets) {
    assert.equal(asset.license,"CC0-1.0",
                 "Todo wallpaper original debe declarar la licencia CC0 1.0");
    assert.match(asset.sha256,/^[a-f0-9]{64}$/i,"Preservar hashes exactos");
    assert(asset.width>0 && asset.height>0 && asset.bytes>0);
}
const policy = load("docs/LICENCIAS_RECURSOS_GRAFICOS.md");
assert(policy.includes("Creative Commons CC0 1.0 Universal"));
assert(policy.includes("los tres wallpapers PNG"));
assert(policy.includes("MIT"));
assert(policy.includes("Golden Dog") && policy.includes("excluido"),
       "No dar por autorizadas marcas o recursos de terceros por accidente");

for (const file of [
    ".github/pull_request_template.md",
    "README.md",
    "ROADMAP.md",
    "docs/CONSTITUCION_TECNICA.md",
    "docs/MANUAL_MAESTRO.md",
    "docs/PLANTILLA_INSTRUCCIONES_CHATGPT.md"
]) {
    const text = load(file);
    assert(!/\bGPL(?:-[0-9.]+)?\b/i.test(text),
        "Referencia obsoleta de licencia en documentación operativa: "+file);
}
console.log("OK: LICENSE y KPlugin MIT, wallpapers Día/Atardecer/Noche CC0 1.0 y documentación coherente.");
