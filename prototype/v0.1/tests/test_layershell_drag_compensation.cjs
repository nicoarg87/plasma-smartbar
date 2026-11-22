"use strict";
// Regresión de la compensación de movimiento de la propia superficie:
// el panel real y el visor normal deben conservar su DragHandler anterior.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "..");
const helper = fs.readFileSync(path.join(base,
    "package/contents/ui/LayerShellDragCompensation.js"), "utf8");
const bar = fs.readFileSync(path.join(base,
    "package/contents/ui/SmartBarContent.qml"), "utf8");
const shellWindow = fs.readFileSync(path.join(base,
    "preview_soledad_layershell.qml"), "utf8");
const normalViewer = fs.readFileSync(path.join(base,
    "preview_redimensionable.qml"), "utf8");
const plasma = fs.readFileSync(path.join(base,
    "package/contents/ui/main.qml"), "utf8");

assert(helper.startsWith(".pragma library\n"));
const ctx = {};
vm.runInNewContext(helper.replace(/^\.pragma library\s*/, ""), ctx);
const next = ctx.nextOffset;
assert.equal(typeof next, "function");

// Escenario real: el puntero va 12 px a la IZQUIERDA antes de que KWin
// reubique físicamente la superficie. Se solicita 12 de offset.
assert.equal(next(0, 100, 88, 1200), 12);
// Tras mover LayerShellQt la ventana 12 px a la izquierda, el cursor,
// que no se ha movido, vuelve a la misma coordenada de escena.
assert.equal(next(12, 100, 100, 1200), 12);
// El cursor sigue 9 px más a izquierda, relativo a la ventana móvil.
assert.equal(next(12, 100, 91, 1200), 21);
// El shell terminó de seguir esos 9px: mantener offset, NO amplificar.
assert.equal(next(21, 100, 100, 1200), 21);
// Ahora desplazar el cursor 8px a la DERECHA, tras llegar al centro.
assert.equal(next(21, 100, 108, 1200), 13);
assert.equal(next(13, 100, 100, 1200), 13);
assert.equal(next(13, 100, 113, 1200), 0);
// Limitar los extremos; nunca crear desplazamientos negativos.
assert.equal(next(0, 100, 500, 1200), 0);
assert.equal(next(1200, 100, -900, 1200), 1200);
// Evitar NaN, Infinity y geometría no disponible.
assert.equal(next(44, 100, Number.NaN, 1200), 44);
assert.equal(next(44, Number.POSITIVE_INFINITY, 90, 1200), 44);
assert.equal(next(44, 100, 90, Number.NaN), 0);
assert.equal(next(-7, 100, 100, 1200), 0);

// Integración EXCLUSIVA del ensayo LayerShellQt. Prohibido cambiar
// involuntariamente el comportamiento del visor tradicional.
assert(bar.includes('import "LayerShellDragCompensation.js" as LayerShellDragCompensation'));
assert(bar.includes("property bool layerShellDragCompensation: false"));
assert(bar.includes("property real layerShellDragSceneStartX: 0"));
assert(bar.includes("gripDrag.centroid.scenePosition.x"));
assert(bar.includes("LayerShellDragCompensation.nextOffset("));
assert(bar.includes("root.offsetAtDragStart - activeTranslation.x"),
    "Conservar arrastre original si no está habilitado el modo aislado");
assert(shellWindow.includes("layerShellDragCompensation: true"));
assert(shellWindow.includes("right: 12 + Math.round(bar.islandOffset)"));
assert(shellWindow.includes("Math.abs(Math.round(islandOffset) -"),
    "No imprimir un log por cada pixel movido");
assert(!normalViewer.includes("layerShellDragCompensation: true"));
assert(!plasma.includes("layerShellDragCompensation: true"));
console.log("OK: compensación al mover la ventana Wayland, sin alterar arrastre normal de SO.");
