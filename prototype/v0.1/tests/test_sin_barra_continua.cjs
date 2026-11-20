"use strict";
// Regresión visual: NO dibujar franja continua ni dejar zonas de clic.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const view = fs.readFileSync(path.join(root,"package/contents/ui/SmartBarContent.qml"),"utf8");
const settings = fs.readFileSync(path.join(root,"package/contents/ui/SoledadSettings.qml"),"utf8");
const preview = fs.readFileSync(path.join(root,"preview_redimensionable.qml"),"utf8");
// La propiedad histórica se mantiene para recuperar perfiles, PERO no existe
// un Rectangle que la pinte a lo ancho del panel.
assert(!view.includes("visible: root.showBackground"),"Se volvió a dibujar la barra continua");
assert(!view.includes("anchors.fill: parent\n            visible: root.showBackground"));
assert(view.includes("id: systemIsland"),"No borrar la isla SO");
assert(view.includes("id: malvinaHotspot"),"No borrar el acceso a Malvina");
assert(!settings.includes('text: "Mostrar fondo continuo opcional"'),"Reapareció el control rechazado");
assert(!settings.includes('model: ["Fondo opcional"'),"Reapareció el fondo en el selector");
assert(settings.includes("appearanceTarget.currentIndex = target === 2 ? 3 : target"),
    "El menú compartido puede volver al índice de fondo discontinuado");
assert(settings.includes('model: ["Cajón de sistema (bandeja)", "Agarre de seis puntos"]'));
assert(settings.includes("property bool showBackground: false"),
    "No eliminar el almacenamiento histórico de usuarios");
assert(preview.includes("id: simulatedDesktopWallpaper"),"No retirar el wallpaper simulado");
assert(preview.includes("fillMode: Image.Stretch"),"No cambiar el modo Estirar");
// Sin MouseArea sobre la superficie general; conservar clic derecho de las islas.
const segment=view.slice(view.indexOf('Item {\n        anchors.fill: parent'),view.indexOf('id: malvinaHotspot'));
assert(segment.includes("Sin barra continua"));
assert(!segment.includes("MouseArea {"),"Una capa invisible cubre los clics");
console.log("OK: franja continua eliminada, selector depurado, islas y wallpaper intactos.");
