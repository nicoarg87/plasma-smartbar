"use strict";
// Contrato estático + función de categorías en el popup del ensayo KDE.
// La validación visual de tipografía y disposición final sigue en CachyOS.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const base=path.resolve(__dirname,"..");
const popup=fs.readFileSync(path.join(base,"package/contents/ui/SoLauncherPopup.qml"),"utf8");
const bar=fs.readFileSync(path.join(base,"package/contents/ui/SmartBarContent.qml"),"utf8");
const so=fs.readFileSync(path.join(base,"preview_soledad_input_mask.qml"),"utf8");
const mal=fs.readFileSync(path.join(base,"preview_malvina_input_mask.qml"),"utf8");

const categoryNames=["Internet","Oficina","Multimedia","Sistema","Utilidades",
    "Educación","Juegos","Gráficos","Desarrollo","Ciencia","Otras"];
for(const label of categoryNames)
    assert(popup.includes('"'+label+'"'),"Categoría perdida: "+label);

const fnMatch=popup.match(/function categoryOptions\(\) \{([\s\S]*?)\n    \}/);
assert(fnMatch,"Se perdió la función de categorías");
const categoryOptions=new Function("primaryCategories","moreCategories",
    "realLaunchEnabled","showMoreCategories",
    "return (function categoryOptions(){"+fnMatch[1]+"\n})();");
assert.deepEqual(
    categoryOptions(categoryNames.slice(0,5),categoryNames.slice(5),true,false),
    categoryNames,"La sesión KDE debe mostrar siempre las 11 categorías");
assert.deepEqual(
    categoryOptions(categoryNames.slice(0,5),categoryNames.slice(5),false,false),
    [...categoryNames.slice(0,5),"+"],
    "El visor antiguo conserva su expansión manual");
assert.deepEqual(
    categoryOptions(categoryNames.slice(0,5),categoryNames.slice(5),false,true),
    categoryNames,"El visor antiguo conserva la expansión completa");

for(const fragment of [
    "readonly property int sharedColumnWidth:",
    "Math.ceil(longestNameMetrics.advanceWidth + 62)",
    "TextMetrics {",
    "availableScreenWidth",
    "property int primaryWidth: realLaunchEnabled ? sharedColumnWidth : 285",
    "property int categoryWidth: realLaunchEnabled ? sharedColumnWidth : 280",
    "Layout.preferredWidth: launcher.categoryWidth - 13",
    "launcher.primaryWidth) - (launcher.realLaunchEnabled ? 13 : 18)",
    "Math.floor((Math.max(480, availableScreenWidth) - 42) / 2)",
    "spacing: launcher.realLaunchEnabled ? 2 : 5",
    "spacing: launcher.realLaunchEnabled ? 2 : 4",
    "height: launcher.realLaunchEnabled ? 30 : 32",
    "height: launcher.realLaunchEnabled ? 30 : 31",
    "QQC2.ToolTip.text: text"
]) assert(popup.includes(fragment),"Falta ajuste de tamaños: "+fragment);
assert(!popup.includes('text: "Activar Malvina (isla 2)"'),
       "Malvina se administra en Configuración, no desde botones redundantes");
assert(bar.includes("availableScreenWidth: root.width"),
       "El launcher debe caber en el escritorio real");
assert(popup.includes("model: launcher.appsForCategory()"),
       "No reemplazar el catálogo de apps reales");
assert(popup.includes("launcher.selectApplication(modelData)"),
       "Mantener apertura real y búsquedas");
assert(popup.includes("QQC2.ScrollBar.vertical"),
       "Conservar desplazamiento para nombres/filas que no entren");
assert(popup.includes('property int filesWidth: realLaunchEnabled ? 645 : 500'),
       "No cambiar el tamaño del navegador de archivos sin aprobación");
for(const viewer of [so,mal])
    assert(viewer.includes("launcherAvailableHeight:"),
           "El límite vertical debe depender de la pantalla real");
console.log("OK: 11 categorías, columnas 1:1, filas compactas, búsqueda y Archivos intactos");
