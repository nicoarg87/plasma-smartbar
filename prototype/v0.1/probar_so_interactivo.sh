#!/usr/bin/env bash
# Diagnóstico aislado de eventos de ratón para una SOLA capa LayerShellQt.
# Sin panel, KConfig, instalaciones ni modificaciones a otras ventanas.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ "${XDG_SESSION_TYPE:-}" != "wayland" ] || [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "ERROR: requiere sesión KDE Wayland; no se modificó nada." >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER="/usr/lib/qt6/bin/qml"
else
    echo "ERROR: no se encontró qml6. No se modificó nada." >&2
    exit 1
fi
echo "Plasma SmartBar: diagnóstico de UN ÚNICO SO interactivo (64×48)."
echo "No se crea zona pasante en este ensayo: se aísla el fallo del ratón."
echo "GIF tropical de fábrica, contador e informes HOVER/PULSACION en Konsole."
echo "Si no hay HOVER ni PULSACION, la capa no está recibiendo entrada."
echo "Sin instalación ni cambios del panel. Autocierre 60s / Ctrl+C."
exec env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell \
    "$QML_RUNNER" "$HERE/preview_superposicion_interactiva_layershell.qml"
