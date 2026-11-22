#!/usr/bin/env bash
# Prueba de una superficie LayerShellQt pasiva, limitada al proceso qml6.
# No instala paquetes, no modifica KWin/KConfig ni sustituye paneles.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ "${XDG_SESSION_TYPE:-}" != "wayland" ] || [ -z "${WAYLAND_DISPLAY:-}" ]; then
    printf 'Esta prueba solo se ejecuta en una sesión Wayland activa. No se modificó nada.\n' >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
else
    printf 'No se encontró el ejecutor QML de Qt 6. No se modificó nada.\n' >&2
    exit 1
fi

printf 'Prueba PASIVA LayerShellQt. Solicita borde superior derecho, 456x44.\n'
printf 'No reserva espacio ni toma clics/foco. Autocierre tras 60 s.\n'
printf 'La ventana de prueba puede cubrir visualmente parte del panel durante ese minuto.\n'
printf 'Cancelación inmediata disponible: Ctrl+C en Konsole.\n'
printf 'Si faltan módulos LayerShellQt, el visor fallará sin instalar nada.\n'
exec env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell \
    "$QML_RUNNER" "$HERE/preview_superposicion_layershell.qml"
