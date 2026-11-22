#!/usr/bin/env bash
# Prueba temporal con la isla REAL de SmartBarContent.qml en LayerShellQt.
# No instala widgets, no edita el panel ni la configuración personal.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ "${XDG_SESSION_TYPE:-}" != "wayland" ] || [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "ERROR: esta prueba solo funciona en una sesión Wayland." >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
else
    echo "ERROR: no se encontró qml6. No se instaló nada." >&2
    exit 1
fi
echo "Plasma SmartBar — ensayo TEMPORAL de Soledad AUTÉNTICA."
echo "Carga SmartBarContent.qml: GIF original y agarre de seis puntos."
echo "Ventana limitada al ancho REAL de la isla, sin banda transparente externa."
echo "Para desplazarla, arrastrá el agarre de seis puntos, NO las pestañas."
echo "El desplazamiento es temporal; no altera perfiles Steam/Brave ni temas."
echo "El GIF puede usar la configuración predeterminada en este ensayo aislado."
echo "Sin instalación ni reemplazo del panel KDE. Cierre en 90s o Ctrl+C."
exec env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell \
    "$QML_RUNNER" "$HERE/preview_soledad_layershell.qml"
