"use strict";
// Contrato de fondos del escritorio SIMULADO: sin tocar el wallpaper real KDE.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const ui = read("package/contents/ui/SoledadSettings.qml");
const bar = read("package/contents/ui/SmartBarContent.qml");
const viewer = read("preview_redimensionable.qml");
const wrapper = read("package/contents/ui/main.qml");
const config = read("package/contents/config/main.xml");
const launcher = read("probar_ancho.sh");
const manifest = JSON.parse(read("package/contents/ui/assets/wallpapers/manifest.json"));

assert(ui.includes('text: "Activar wallpaper temático"'));
assert(ui.includes("thematicWallpaperVisibilityRequested(checked)"));
assert(ui.includes("signal wallpaperThemeSelected(string themeName)"));
assert(ui.includes('settings.wallpaperThemeSelected("day")'));
assert(ui.includes('settings.wallpaperThemeSelected("sunset")'));
assert(ui.includes('settings.wallpaperThemeSelected("night")'));
assert(ui.includes("slot.length && settings.activateTheme(slot)"),
       "No cambiar wallpaper si la carga del tema falla");
assert(bar.includes("onThematicWallpaperVisibilityRequested: function(enabled)"));
assert(bar.includes("requestThematicWallpaperVisibilityChange(bool enabled)"));
assert(viewer.includes('id: simulatedDesktopWallpaper'));
assert(viewer.includes("fillMode: Image.Stretch"));
assert(viewer.includes("previewWindow.simulatedWallpaperEnabled && status === Image.Ready"));
assert(viewer.includes('localPreviewSettings.value("simulatedWallpaperEnabled", true)'));
assert(viewer.includes('localPreviewSettings.setValue("simulatedWallpaperEnabled", enabled)'));
assert(viewer.includes('localPreviewSettings.setValue("simulatedWallpaperTheme", theme)'));
assert(viewer.includes('previewWindow.changeSimulatedWallpaper(themeName, true)'));
assert(viewer.includes('changeSimulatedWallpaper(next, false)'));
assert(viewer.includes('bar.previewBarThemeColors(wallpaperIncomingTheme)'));
assert(viewer.includes('wallpaperDemoPendingTheme = next'));
assert(viewer.includes('id: wallpaperDemoButton'));
assert(viewer.includes('duration: previewWindow.wallpaperFadeDurationMs'));
assert(viewer.includes('WallpaperFadeDuration.durationMs(demoWallpaperFadeAmount,demoWallpaperFadeUnit)'));
assert(viewer.includes('localPreviewSettings.value("wallpaperFadeAmount",3)'));
assert(viewer.includes('localPreviewSettings.value("wallpaperFadeUnit","seconds")'));
assert(viewer.includes('onRequestWallpaperFadeChange: function(amount, unit)'));
assert(!viewer.includes('wallpaperDemoRemaining'),"No hay transición automática tras el clic");
assert(viewer.includes('id: incomingWallpaper'));
assert(viewer.includes('wallpaperActiveLayer = wallpaperIncomingLayer'));
assert(wrapper.includes("Plasmoid.configuration.thematicWallpaperEnabled = enabled"));
assert(config.includes('<entry name="thematicWallpaperEnabled" type="Bool"><default>true</default></entry>'));
assert(!launcher.includes("vigilar_wallpaper.py"));
assert(!fs.existsSync(path.join(root, "scripts/vigilar_wallpaper.py")));
assert(!viewer.includes("plasma-apply-wallpaperimage"));
assert(!viewer.includes("wallpaperSignal.setValue("));
assert(!wrapper.includes("wallpaperSignal.setValue("));
assert.equal(manifest.assets.length, 3);
assert.deepEqual(manifest.assets.map(x => x.theme), ["day", "sunset", "night"]);
for (const item of manifest.assets) {
    assert.equal(item.fillMode, "stretch");
    assert.match(item.sha256, /^[a-f0-9]{64}$/);
}
console.log("OK: wallpaper temático opcional persistente, 3 fondos estirados solo dentro del visor.");
