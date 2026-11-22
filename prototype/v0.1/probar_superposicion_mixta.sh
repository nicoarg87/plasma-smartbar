#!/usr/bin/env bash
# Ensayo de zonas pasantes e interactivas; no instala ni cambia KDE.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ] || [ -z "${WAYLAND_DISPLAY:-}" ]; then
    printf 'ERROR: ensayo exclusivo de Wayland. No se cambió nada.\n' >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
else
    printf 'ERROR: no se encontró Qt 6 QML. No se modificó nada.\n' >&2
    exit 1
fi

printf 'Plasma SmartBar: ENSAYO MIXTO TEMPORAL LayerShellQt.\n'
printf 'Zona transparente para clics (348x42) y zona SO interactiva (52x42).\n'
printf 'Dos superficies separadas, ancladas arriba a la derecha, no un panel.\n'
printf 'Solo cuenta clics dentro de SO. No modifica Brave, Steam ni los temas.\n'
printf 'Sin zonas exclusivas; no mueve ni redimensiona ventanas reales.\n'
printf 'Puede cubrir temporalmente una pequeña parte de los controles del navegador.\n'
printf 'Autocierre del ensayo a los 60 s o Ctrl+C en esta Konsole.\n'
exec env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell \
    "$QML_RUNNER" "$HERE/preview_superposicion_mixta.qml"
