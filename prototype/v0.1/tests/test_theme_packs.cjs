"use strict";
// Packs Playa 24hs + personalizados sin sobrescribir temas ni panel KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const base = path.resolve(__dirname, "..");
const uiPath = path.join(base, "package/contents/ui");
const qml = fs.readFileSync(path.join(uiPath, "SoledadSettings.qml"), "utf8");
const bar = fs.readFileSync(path.join(uiPath, "SmartBarContent.qml"), "utf8");
const preview = fs.readFileSync(path.join(base, "preview_redimensionable.qml"), "utf8");
const main = fs.readFileSync(path.join(uiPath, "main.qml"), "utf8");
const config = fs.readFileSync(path.join(base, "package/contents/config/main.xml"), "utf8");
const js = fs.readFileSync(path.join(uiPath, "ThemePack.js"), "utf8");
assert(js.startsWith(".pragma library\n"));
const pack = {};
vm.runInNewContext(js.replace(/^\s*\.pragma library\s*/, ""), pack);
assert.equal(pack.DEFAULT_ID, "playa-24hs");
assert.equal(pack.NAME, "Playa 24hs");
assert.equal(pack.title(true), "Playa 24hs · Automático");
assert.equal(pack.title(false), "Playa 24hs · Manual");
assert.equal(pack.find([], pack.DEFAULT_ID), null);
assert.equal(pack.parse("[]").length, 0);
assert.equal(pack.parse("{broken").length, 0);
assert.equal(pack.parse("{}").length, 0);
assert.equal(pack.parse('null').length, 0);
assert.equal(pack.raw("[]").length, 0);
assert.equal(pack.raw("{broken"), null, "Nunca sobreescribir biblioteca inválida");
assert.equal(pack.raw("{}"), null);

const members = [
    {kind:"preset",theme:"day",name:"Día"},
    {kind:"snapshot",name:"Mi tema azul",jsonData:'{"version":1,"soledadColor":"#123456"}'},
    {kind:"preset",theme:"night",name:"Noche"}
];
const original = JSON.stringify(members);
const created = pack.create([], "Mis momentos", members);
assert(created, "Crear pack con temas de origen y personales");
assert.equal(created.id, "pack-1");
assert.equal(created.name, "Mis momentos");
assert.deepEqual(JSON.parse(JSON.stringify(created.members)),members);
assert.equal(JSON.stringify(members),original, "Nunca modificar la biblioteca origen");
assert.notEqual(created.members[0], members[0], "Guardar copia independiente");
assert.equal(created.slots3.length, 3);
assert.equal(created.slots4.length, 4);
assert.equal(created.automaticEnabled, true);
assert.equal(created.slotCount, 4);
const inheritedCustom = pack.create([], "Con tres franjas", members, false, 3);
assert.equal(inheritedCustom.automaticEnabled, false);
assert.equal(inheritedCustom.slotCount, 3);
const customized = pack.withPreferences(created, false, 3);
assert.equal(pack.automatic(customized, true), false, "Modo del pack personal aislado");
assert.equal(pack.slotCount(customized, 4), 3, "Cantidad de franjas aislada");
assert.equal(pack.automatic(created, true), true, "No modificar el pack original");
assert.equal(pack.slotCount(created, 4), 4, "No modificar franjas originales");
assert.equal(pack.withPreferences(created, true, 5), null, "Rechazar cantidad inválida");
const legacyPack = JSON.parse(JSON.stringify(created));
delete legacyPack.automaticEnabled;
delete legacyPack.slotCount;
assert.equal(pack.automatic(legacyPack, false), false, "Pack previo hereda estado activo");
assert.equal(pack.slotCount(legacyPack, 3), 3, "Pack previo hereda franjas activas");
const migratedPack = pack.ensurePreferences(legacyPack, false, 3);
assert.equal(migratedPack.automaticEnabled, false, "Migración no destructiva del modo");
assert.equal(migratedPack.slotCount, 3, "Migración no destructiva de franjas");
assert.deepEqual(JSON.parse(JSON.stringify(migratedPack.slots4)),
    JSON.parse(JSON.stringify(legacyPack.slots4)), "No alterar franjas existentes");
assert.deepEqual(JSON.parse(JSON.stringify(migratedPack.members)),
    JSON.parse(JSON.stringify(legacyPack.members)), "No alterar temas del pack");
assert.equal(pack.ensurePreferences(created, false, 3), created,
    "No reescribir configuración de pack que ya está completo");
assert.equal(pack.create([], "Playa 24hs", members), null, "No reemplazar pack del sistema");
assert.equal(pack.create([], "", members), null);
assert.equal(pack.create([], "Vacío", []), null);
assert.equal(pack.create([created], "mis MOMENTOS", members), null);
const second = pack.create([created], "Otro pack", members);
assert.equal(second.id, "pack-2", "IDs persistentes e independientes");
const encoded = JSON.stringify([created,second]);
const parsed = pack.parse(encoded);
assert.equal(parsed.length, 2);
assert.equal(pack.find(parsed,"pack-2").name, "Otro pack");
assert.deepEqual(Array.from(pack.labels(created)), ["Día","Mi tema azul","Noche"]);
assert.equal(pack.find(parsed,"pack-404"), null);
const unknown = {id:"pack-99",name:"Formato futuro",members:[{newSchema:true}]};
const storedWithUnknown = [created, unknown, null];
const rawPackList = pack.raw(JSON.stringify(storedWithUnknown));
const updated = pack.replace(rawPackList, second);
assert.deepEqual(JSON.parse(JSON.stringify(updated)),
    JSON.parse(JSON.stringify(storedWithUnknown)),
    "No borrar packs desconocidos ni objetos históricos al persistir");
assert.equal(updated[1], rawPackList[1], "No reescribir el pack de versión desconocida");
assert.deepEqual(JSON.parse(JSON.stringify(pack.schedule(created, 3))), [
    {start:"08:00",member:0},
    {start:"18:00",member:1},
    {start:"21:00",member:2}
]);
assert.deepEqual(JSON.parse(JSON.stringify(pack.schedule(created,4))), [
    {start:"06:00",member:1},
    {start:"08:00",member:0},
    {start:"18:00",member:1},
    {start:"21:00",member:2}
]);
const fakeClock=(hour,minute)=>({getHours:()=>hour,getMinutes:()=>minute});
assert.equal(pack.active(created,4,fakeClock(3,0)).memberIndex,2);
assert.equal(pack.active(created,4,fakeClock(7,30)).memberIndex,1);
assert.equal(pack.active(created,4,fakeClock(12,0)).memberIndex,0);
assert.equal(pack.active(created,4,fakeClock(18,0)).memberIndex,1);
assert.equal(pack.active(created,4,fakeClock(22,0)).memberIndex,2);
const edited = pack.withMember(created,4,2,0);
assert(edited);
assert.equal(edited.slots4[2].member,0);
assert.equal(created.slots4[2].member,1,"No mutar otro pack o estado anterior");
const changed = pack.withBoundary(edited,4,1,"start","09:15");
assert.equal(changed.slots4[1].start,"09:15");
assert.equal(created.slots4[1].start,"08:00");
assert.equal(pack.withBoundary(created,4,1,"start","05:59"),null);
assert.equal(pack.withMember(created,4,0,99),null);
const replaced=pack.replace([created,second],edited);
assert.equal(replaced[0].slots4[2].member,0);
assert.equal(replaced[1],second,"El resto de packs no cambia");
const isolatedOptions = pack.replace([created,second], customized);
assert.equal(isolatedOptions[0].automaticEnabled, false);
assert.equal(isolatedOptions[0].slotCount, 3);
assert.equal(isolatedOptions[1], second, "Cambiar modo/3-4 no modifica otro pack");
assert.equal(pack.automatic(created, true), true);
assert.equal(pack.slotCount(created, 4), 4);
assert.equal(JSON.stringify(JSON.parse(encoded)),encoded,"Persistencia no destructiva");

assert(qml.includes('import "ThemePack.js" as ThemePack'));
assert(bar.includes('import "ThemePack.js" as ThemePack'));
assert(qml.includes('property string selectedThemePackId: ThemePack.DEFAULT_ID'));
assert(qml.includes('property string themePackLibraryJson: "[]"'));
assert(qml.includes("property bool packOptionsVisible: false"),
    "Playa 24hs puede quedar seleccionado por defecto sin abrir su configuración");
assert(qml.includes("packOptionsVisible = false; scheduleMenuExpanded = false; factoryToolsExpanded = false"),
    "Reingresar en Temas no reabre ajustes horarios");
assert(qml.includes("selectedThemePackId = id\n        packOptionsVisible = true\n        scheduleMenuExpanded = false"),
    "Elegir pack muestra solo el submenú, nunca las franjas desplegadas");
assert(qml.includes("visible: settings.packOptionsVisible"),
    "Ocultar todos los controles horarios antes de elegir pack");
assert(qml.includes("visible: settings.scheduleMenuExpanded && settings.packOptionsVisible"),
    "Ni siquiera un estado previo del horario puede abrir el bloque sin elegir pack");
assert(qml.indexOf("id: themeSelectorButton") < qml.indexOf("id: scheduleMenuButton") &&
       qml.indexOf("id: scheduleMenuButton") < qml.indexOf("id: themeScheduleMenu"),
    "Primero debe aparecer el pack, luego su submenú y recién después las franjas");
assert(bar.includes('property string selectedThemePackId: ThemePack.DEFAULT_ID'));
assert(bar.includes('property string themePackLibraryJson: "[]"'));
assert(qml.includes("function createPersonalPack()"));
assert(qml.includes("function selectThemePack(id)"));
assert(qml.includes("function activatePackMember(index)"));
assert(qml.includes("function resolvePackPreset(theme)"));
assert(qml.includes("function persistCustomPack(updated)"));
assert(qml.includes("ThemePack.ensurePreferences(pack,"),
       "Primer ingreso a pack anterior captura sus opciones sin borrar franjas");
assert(qml.includes("ThemePack.withPreferences(selectedThemePack,"),
       "Editar modo o 3/4 franjas guarda en el pack seleccionado");
assert(qml.includes("playaScheduleEnabled = enabled"),
       "Solo el pack Playa escribe el modo histórico");
assert(qml.includes("playaScheduleSlotCount = count"),
       "Solo el pack Playa escribe la cantidad histórica");
assert(qml.includes("saveThemeScheduleRequested(playaScheduleEnabled, playaScheduleSlotCount,"),
       "La persistencia histórica no recibe controles del pack personalizado");
assert(bar.includes("readonly property bool activeThemeScheduleEnabled:"),
       "El reloj resuelve el modo del pack activo");
assert(bar.includes("readonly property int activeThemeScheduleSlotCount:"),
       "El reloj resuelve 3/4 franjas del pack activo");
assert(bar.includes("soledadSettings.playaScheduleEnabled = root.themeScheduleEnabled"),
       "El editor conserva el modo antiguo de Playa");
assert(bar.includes("soledadSettings.themeScheduleEnabled = root.activeThemeScheduleEnabled"),
       "El editor abre con modo propio del pack activo");
assert(bar.includes("soledadSettings.themeScheduleSlotCount = root.activeThemeScheduleSlotCount"),
       "El editor abre con cantidad de franjas del pack activo");
assert(qml.includes('text: "Crear pack personalizado"'));
assert(qml.includes('text: "Guardar pack"'));
assert(qml.includes("ThemePack.labels(settings.selectedThemePack)"));
assert(qml.includes('text: "Activar cambio automático de tema"'));
assert(qml.includes("scheduleMenuExpanded = true"));
assert(qml.includes("settings.setScheduleEnabled(false)"));
assert(qml.includes("return member.jsonData"));
assert(qml.includes("savedThemeLibrary.map("));
assert(qml.includes("settings.saveNamedTheme()"),"Seguir creando temas personales");
assert(bar.includes("ThemePack.active(customPack, activeThemeScheduleSlotCount, now)"));
assert(bar.includes('slot = customPack ?') || bar.includes("const slot = customPack ?"));
assert(bar.includes('root.requestSelectedThemePackChange(id)'));
assert(bar.includes('root.requestThemePackLibraryChange(json)'));
assert(preview.includes('localPreviewSettings.setValue("themePackLibraryJson", json)'));
assert(preview.includes('localPreviewSettings.setValue("selectedThemePackId", id)'));
assert(main.includes('Plasmoid.configuration.themePackLibraryJson'));
assert(main.includes('Plasmoid.configuration.selectedThemePackId'));
assert(config.includes('<entry name="themePackLibraryJson" type="String"><default>[]</default></entry>'));
assert(config.includes('<entry name="selectedThemePackId" type="String"><default>playa-24hs</default></entry>'));
assert(preview.includes("themeScheduleRuntimeEnabled: previewWindow.appearanceRestored && !previewWindow.captureDayOnce"));
assert(main.includes("themeScheduleRuntimeEnabled: false"),"No activar reloj en panel KDE real");
assert(!qml.includes('text: "Guardar cambios actuales en Día"'));
console.log("OK: Playa y packs personales conservan franjas, modo automático y 3/4 independientemente.");
