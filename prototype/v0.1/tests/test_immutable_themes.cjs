// Contrato de temas oficiales: tres presets inmutables, selector único y
// ningún botón para sobreescribir Día. Ejecutar con Node >= 18.
"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const base=path.resolve(__dirname,"..");
const ui=fs.readFileSync(path.join(base,"package/contents/ui/SoledadSettings.qml"),"utf8");
for(const slug of ["Day","Sunset","Night"]) {
    const filename=path.join(base,"package/contents/ui/assets/Factory"+slug+"Theme.js");
    assert(fs.existsSync(filename), "Falta plantilla oficial "+slug);
    assert(ui.includes('import "assets/Factory'+slug+'Theme.js"'), "Falta import "+slug);
    assert(ui.includes("factory"+slug+"Preset"), "Falta preset "+slug);
    assert(ui.includes("factory"+slug+"Available"), "Falta verificar recursos "+slug);
}
assert(ui.includes('index === 0 ? "Atardecer"'),"Atardecer primero");
assert(ui.includes('index === 1 ? "Noche"'),"Noche segundo");
assert(ui.includes('index === 2 ? "Día"'),"Día tercero");
assert(ui.includes("factoryDayAvailable"),"Día debe usar el preset oficial cuando exista");
assert(ui.includes('slot = "dayOfficial"'),"La selección de Día debe dar prioridad al original");
assert(ui.includes('slot === "dayOfficial"'),"El perfil oficial debe ser inmutable");
assert(ui.includes("themeDayJson"),"El Atardecer histórico debe preservarse");
assert(ui.includes("themeLibraryJson"),"Preservar biblioteca local");
assert(!ui.includes('text: "Guardar cambios actuales en Día"'),"No agregar botones de sellado");
assert(!ui.includes("saveCurrentDayTheme"),"No reintroducir la función rechazada");
assert(ui.includes("id: themeOptionsPopup"),"Mantener desplegable único");
assert(ui.includes("CloseOnPressOutsideParent"),"Segundo clic debe cerrar sin reabrir");
const qml=fs.readFileSync(path.join(base,"scripts/leer_temas_locales.qml"),"utf8");
const pack=fs.readFileSync(path.join(base,"scripts/sellar_tres_temas_fabrica.cjs"),"utf8");
assert(qml.includes('category: "plasma-smartbar-v01-preview-appearance"'));
assert(pack.includes("fs.constants.COPYFILE_EXCL"),"No sobrescribir recursos existentes");
assert(pack.includes("No se modificó ningún tema oficial"));
assert(pack.includes("themeNightJson")&&pack.includes("themeDayJson"));
for(const name of ["Día","Atardecer","Noche"])assert(pack.includes(name));
console.log("OK: tres temas oficiales inmutables preparados; sin botones extra ni sobrescritura de temas locales.");
