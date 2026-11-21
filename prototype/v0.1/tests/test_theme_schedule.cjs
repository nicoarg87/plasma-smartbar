"use strict";
// Horarios locales editables sin transición animada ni modificación del escritorio KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const root = path.resolve(__dirname,"..");
const read = p => fs.readFileSync(path.join(root,p),"utf8");
const source = read("package/contents/ui/ThemeSchedule.js").replace(/^\.pragma library\s*/, "");
const context = vm.createContext({});
vm.runInContext(source,context);
const four = JSON.parse(JSON.stringify(context.defaults(4)));
const three = JSON.parse(JSON.stringify(context.defaults(3)));
assert.deepEqual(four, [
    {start:"06:00",theme:"sunset"},
    {start:"08:00",theme:"day"},
    {start:"18:00",theme:"sunset"},
    {start:"21:00",theme:"night"}
]);
assert.deepEqual(three, [
    {start:"08:00",theme:"day"},
    {start:"18:00",theme:"sunset"},
    {start:"21:00",theme:"night"}
]);
const examples = [
    [0,0,"night"], [5,59,"night"], [6,0,"sunset"],
    [7,59,"sunset"], [8,0,"day"], [17,59,"day"],
    [18,0,"sunset"], [20,59,"sunset"], [21,0,"night"],
    [23,59,"night"]
];
for (const [h,m,theme] of examples)
    assert.equal(context.current(four,h,m).theme,theme,`${h}:${m}`);
assert.equal(context.current(three,7,59).theme,"night");
assert.equal(context.current(three,8,0).theme,"day");
assert.equal(context.withBoundary(four,0,"end","07:30")[1].start,"07:30");
assert.equal(context.withBoundary(four,3,"end","05:45")[0].start,"05:45");
assert.equal(context.withBoundary(four,1,"end","05:59"),null);
assert.equal(context.withBoundary(four,0,"end","06:00"),null);
assert.equal(context.withBoundary(four,0,"start","24:00"),null);
assert.equal(context.withBoundary(four,0,"start","8:00"),null);
assert.equal(context.withBoundary(four,0,"start","08:00"),null);
assert.equal(context.withTheme(four,1,"night")[1].theme,"night");
assert.equal(context.withTheme(four,1,"invalid"),null);
assert.deepEqual(JSON.parse(JSON.stringify(context.read(context.serialize(four,4),4))),four);
assert.deepEqual(JSON.parse(JSON.stringify(context.read("garbage",4))),four);
assert.deepEqual(JSON.parse(JSON.stringify(context.read("garbage",3))),three);

const settings = read("package/contents/ui/SoledadSettings.qml");
const bar = read("package/contents/ui/SmartBarContent.qml");
const preview = read("preview_redimensionable.qml");
const main = read("package/contents/ui/main.qml");
const config = read("package/contents/config/main.xml");
assert(settings.includes('id: themeScheduleMenu'));
assert(settings.includes('visible: settings.scheduleMenuExpanded'));
assert(settings.includes('id: scheduleMenuButton'));
assert(settings.includes('text: "Con horarios "'));
assert(settings.includes('onClicked: settings.scheduleMenuExpanded = !settings.scheduleMenuExpanded'));
assert(settings.includes('checked: settings.thematicWallpaperEnabled'));
assert(settings.includes('onToggled: settings.setScheduleEnabled(checked)'));
assert(settings.includes('scheduleMenuExpanded = false; factoryToolsExpanded = false'));
assert(settings.indexOf('id: scheduleMenuButton') < settings.indexOf('id: themeScheduleMenu'));
assert(settings.indexOf('id: themeScheduleMenu') < settings.indexOf('text: "Activar cambio automático de tema"'));
assert(settings.includes('text: "Activar cambio automático de tema"'));
assert(settings.includes('model: ["3 franjas", "4 franjas"]'));
assert(settings.includes('settings.updateScheduleBoundary(index, "start", text)'));
assert(settings.includes('settings.updateScheduleBoundary(index, "end", text)'));
assert(settings.includes("settings.updateScheduleTheme(index,"),
       "La edición de franja usa la misma función pública");
assert(settings.includes("settings.selectedThemePack ? i :"),
       "El pack personal usa su propio índice de tema");
assert(settings.includes('["day", "sunset", "night"][i])'),
       "Playa 24hs conserva los tres identificadores históricos");
assert(settings.includes("saveThemeScheduleRequested(bool enabled"));
assert(bar.includes("themeScheduleRuntimeEnabled: false"));
assert(bar.includes("function checkThemeSchedule()"));
assert(bar.includes("interval: 15000"));
assert(bar.includes("syncSettingsFromRoot()"));
assert(bar.includes("soledadSettings.activateTheme(slot)"));
assert(bar.includes('requestWallpaperThemeChange(customPack ? member.theme : selected.theme)'),
       "El pack Playa y sus referencias de fábrica conservan el wallpaper horario");
assert(bar.includes('if (!customPack || member.kind === "preset")'),
       "Un snapshot personal nunca debe inventar un wallpaper no configurado");
assert(preview.includes("themeScheduleRuntimeEnabled: previewWindow.appearanceRestored && !previewWindow.captureDayOnce"));
assert(preview.includes('localPreviewSettings.setValue("themeScheduleSlots4Json", slots4Json)'));
assert(preview.includes('localPreviewSettings.setValue("themeScheduleSlots3Json", slots3Json)'));
assert(main.includes("themeScheduleRuntimeEnabled: false"));
assert(config.includes('<entry name="themeScheduleEnabled" type="Bool"><default>true</default></entry>'));
assert(config.includes('<entry name="themeScheduleSlotCount" type="Int"><default>4</default></entry>'));
assert(!settings.includes('text: "Guardar cambios actuales en Día"'));
assert(!preview.includes("plasma-apply-wallpaperimage"));
console.log("OK: ciclo diario de 3/4 franjas, medianoche, validación y persistencia sin modificar KDE.");
