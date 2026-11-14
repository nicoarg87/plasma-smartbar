#!/usr/bin/env bash
# Diagnóstico read-only del modelo de tareas de KDE Plasma 6.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
else
    echo "No encontré qml6 ni /usr/lib/qt6/bin/qml." >&2
    echo "Comprobá qué binarios instaló qt6-declarative." >&2
    echo "Este script no instala paquetes." >&2
    exit 1
fi

echo "Plasma SmartBar: modelo de ventanas REALES, SOLO LECTURA."
echo "No se instalan widgets, no se reemplaza ningún panel."
echo "Si falta el módulo QML org.kde.taskmanager, conservá el error de Konsole."
exec "$QML_RUNNER" "$HERE/preview_ventanas_reales.qml"
