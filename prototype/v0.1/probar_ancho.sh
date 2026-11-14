#!/usr/bin/env bash
# Ensayo de ancho responsivo con Qt Quick, independiente de PlasmaShell.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qmlscene6)"
else
    echo "No se encontró qml6/qmlscene6 de Qt 6." >&2
    echo "En CachyOS/Arch suele venir con qt6-declarative." >&2
    echo "Verificá: pacman -Q qt6-declarative" >&2
    echo "El script no instalará ni modificará paquetes." >&2
    exit 1
fi

echo "Abriendo la vista de geometría Qt Quick de Plasma SmartBar…"
echo "Esta ventana usa SmartBarContent.qml, igual que el plasmoide."
echo "No se instala ni cambia ningún panel. Cerrala con la X."
exec "$QML_RUNNER" "$HERE/preview_redimensionable.qml"
