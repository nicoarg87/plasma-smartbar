"use strict";
// Protección de los presets, respaldo de Día y 90% en islas y paneles.
const fs=require("node:fs");
const path=require("node:path");
const assert=require("node:assert/strict");
const root=path.resolve(__dirname,"..");
const read=p=>fs.readFileSync(path.join(root,p),"utf8");
const ui=read("package/contents/ui/SoledadSettings.qml");
const bar=read("package/contents/ui/SmartBarContent.qml");
const preview=read("preview_redimensionable.qml");
const config=read("package/contents/config/main.xml");
const archive=read("scripts/archivar_dia_local.cjs");
const sh=read("guardar_dia_actual.sh");
const fields=["soledadOpacity","malvinaOpacity","launcherOpacity",
              "malvinaOptionsOpacity","trayButtonOpacity",
              "gripButtonOpacity","backgroundOpacity"];
const srcFields=["demoSoledadOpacity","demoMalvinaOpacity","demoLauncherOpacity",
                 "demoMalvinaOptionsOpacity","demoTrayButtonOpacity",
                 "demoGripButtonOpacity","demoBackgroundOpacity"];
for(const field of fields){
    assert(ui.includes(field+" = 0.9"),"El editor no aplica 90% a "+field);
    assert(ui.includes("property real "+field+": 0.9"),"Editor no inicia 90% "+field);
    assert(bar.includes("property real "+field+": 0.9"),"Componente no inicia 90% "+field);
    assert(config.includes('name="'+field+'" type="Double"><default>0.9</default>'),
           "KConfig no inicia 90% "+field);
}
for(const field of srcFields)
    assert(preview.includes("property real "+field+": 0.9"),
           "Visor no inicia 90% "+field);
assert(ui.includes("function setUniformThemeOpacity()"));
assert(ui.includes("setUniformThemeOpacity()\n            // Aplicar"),"Aplicar tema debe ajustar 90%");
assert(bar.includes("function snapshotFromLiveAppearance()"));
assert(preview.includes("function captureDayFromSavedAppearance()"));
assert(preview.includes('simulatedWallpaperTheme !== "day"'),"No guardar una Noche como Día");
assert(preview.includes('dayCapturedAppearanceBefore90V1'),"Falta respaldo anterior");
assert(preview.includes('dayCapturedLibraryBeforeV1'),"Falta respaldo biblioteca");
assert(preview.includes('items.push({name: "Día · respaldo "'));
assert(preview.includes('localPreviewSettings.setValue("themeLibraryJson"'));
assert(preview.includes('if (captureDayOnce)'));
assert(preview.includes('themeScheduleRuntimeEnabled: previewWindow.appearanceRestored && !previewWindow.captureDayOnce'));
assert(archive.includes("fs.mkdtempSync"),"La copia no debe sobrescribir otra");
assert(archive.includes("fs.copyFileSync"),"Copia el GIF si existe");
assert(sh.includes("scripts/marcar_guardado_dia.qml"));
assert(!ui.includes('text: "Guardar cambios actuales en Día"'));
assert(!ui.includes("function saveCurrentDayTheme("));
assert(!archive.includes("https://api.github.com"));
console.log("OK: valores 90%, carga de cualquier tema, captura Día y respaldo local sin botones.");
