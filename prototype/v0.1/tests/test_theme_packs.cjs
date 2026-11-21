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
assert.equal(JSON.stringify(JSON.parse(encoded)),encoded,"Persistencia no destructiva");

assert(qml.includes('import "ThemePack.js" as ThemePack'));
assert(bar.includes('import "ThemePack.js" as ThemePack'));
assert(qml.includes('property string selectedThemePackId: ThemePack.DEFAULT_ID'));
assert(qml.includes('property string themePackLibraryJson: "[]"'));
assert(bar.includes('property string selectedThemePackId: ThemePack.DEFAULT_ID'));
assert(bar.includes('property string themePackLibraryJson: "[]"'));
assert(qml.includes("function createPersonalPack()"));
assert(qml.includes("function selectThemePack(id)"));
assert(qml.includes("function activatePackMember(index)"));
assert(qml.includes("function resolvePackPreset(theme)"));
assert(qml.includes("function persistCustomPack(updated)"));
assert(qml.includes('text: "Crear pack personalizado"'));
assert(qml.includes('text: "Guardar pack"'));
assert(qml.includes("ThemePack.labels(settings.selectedThemePack)"));
assert(qml.includes('text: "Activar cambio automático de tema"'));
assert(qml.includes("scheduleMenuExpanded = true"));
assert(qml.includes("settings.setScheduleEnabled(false)"));
assert(qml.includes("return member.jsonData"));
assert(qml.includes("savedThemeLibrary.map("));
assert(qml.includes("settings.saveNamedTheme()"),"Seguir creando temas personales");
assert(bar.includes("ThemePack.active(customPack, themeScheduleSlotCount, now)"));
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
console.log("OK: pack Playa 24hs inicial, packs personales/horarios independientes y preferencias aisladas.");
