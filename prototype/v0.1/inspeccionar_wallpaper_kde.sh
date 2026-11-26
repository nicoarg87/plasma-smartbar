#!/usr/bin/env bash
# Diagnóstico de solo lectura: identificar los escritorios KDE cuyo wallpaper
# deberá acompañar a Playa 24hs. NO cambia wallpaper, tema ni panel KDE.
set -euo pipefail
if (( $# )); then
    echo "Uso: bash prototype/v0.1/inspeccionar_wallpaper_kde.sh" >&2
    exit 2
fi
if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
    echo "Este diagnóstico está previsto para KDE Plasma sobre Wayland." >&2
    exit 2
fi
DBUS=""
for candidate in qdbus6 qdbus-qt6 /usr/lib/qt6/bin/qdbus; do
    if command -v "$candidate" >/dev/null 2>&1; then
        DBUS="$(command -v "$candidate")"
        break
    fi
done
if [[ -z "$DBUS" ]]; then
    echo "No se encontró qdbus de Qt 6; no se modificó nada." >&2
    exit 3
fi
SCRIPT='
(function() {
  var list = desktops();
  var active = currentActivity();
  var result = [];
  for (var i = 0; i < list.length; ++i) {
    var desktop = list[i];
    var plugin = String(desktop.wallpaperPlugin || "");
    var activity = String(desktop.activityId || "");
    var screen = Number(desktop.screen);
    var imageSet = false;
    if (plugin === "org.kde.image") {
      desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
      imageSet = String(desktop.readConfig("Image", "")).length > 0;
    }
    result.push({
      id: Number(desktop.id),
      screen: screen,
      activityIsCurrent: activity === String(active),
      plugin: plugin,
      imageConfigured: imageSet
    });
  }
  print("SMARTBAR_WALLPAPER_KDE=" + JSON.stringify({
    desktops: result,
    count: result.length
  }));
})();'
printf 'Diagnóstico de fondos KDE (solo lectura; sin rutas privadas):\n'
if command -v timeout >/dev/null 2>&1; then
    timeout 10s "$DBUS" org.kde.plasmashell /PlasmaShell \
       org.kde.PlasmaShell.evaluateScript "$SCRIPT"
else
    "$DBUS" org.kde.plasmashell /PlasmaShell \
       org.kde.PlasmaShell.evaluateScript "$SCRIPT"
fi
printf 'No se modificó ningún wallpaper ni el panel KDE.\n'
