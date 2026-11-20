"use strict";
// Contrato de conexión tema→wallpaper y modo estirar; sin ejecutar nada en KDE.
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const root=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(root,p),"utf8");
const ui=read("package/contents/ui/SoledadSettings.qml");
const bar=read("package/contents/ui/SmartBarContent.qml");
const viewer=read("preview_redimensionable.qml");
const launcher=read("probar_ancho.sh");
const worker=read("scripts/vigilar_wallpaper.py");
const manifest=JSON.parse(read("package/contents/ui/assets/wallpapers/manifest.json"));
assert(ui.includes("signal wallpaperThemeSelected(string themeName)"));
assert(ui.includes('settings.wallpaperThemeSelected("day")'));
assert(ui.includes('settings.wallpaperThemeSelected("sunset")'));
assert(ui.includes('settings.wallpaperThemeSelected("night")'));
assert(ui.includes("slot.length && settings.activateTheme(slot)"),
    "Nunca cambiar wallpaper si el tema no se pudo aplicar");
assert(bar.includes("signal requestWallpaperThemeChange(string themeName)"));
assert(bar.includes("onWallpaperThemeSelected: function(themeName)"));
assert(viewer.includes('category: "ThemeWallpaper"'));
assert(viewer.includes("onRequestWallpaperThemeChange: function(themeName)"));
assert(viewer.includes('wallpaperSignal.setValue("revision"'));
assert(launcher.includes('scripts/vigilar_wallpaper.py'));
assert(worker.includes('"--fill-mode", "stretch"'));
assert(worker.includes("backup_kde_settings()"));
assert.equal(manifest.assets.length,3);
assert.deepEqual(manifest.assets.map(x=>x.theme),["day","sunset","night"]);
for(const record of manifest.assets){
    assert.equal(record.fillMode,"stretch");
    assert.match(record.sha256,/^[a-f0-9]{64}$/);
    assert(record.bytes>1000000);
}
console.log("OK: 3 wallpapers vinculados sin controles extra; estirar, hashes y backup.");
