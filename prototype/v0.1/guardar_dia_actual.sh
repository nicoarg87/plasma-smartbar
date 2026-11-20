#!/usr/bin/env bash
# Se ejecuta DESPUÉS de cerrar la maqueta con Día visible:
# al cerrar el visor se guarda appearanceV1 con los valores exactos.
# No instala nada ni modifica paneles ni el wallpaper real de KDE.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if command -v qml6 >/dev/null 2>&1; then
    RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    RUNNER="/usr/lib/qt6/bin/qml"
elif command -v qmlscene6 >/dev/null 2>&1; then
    RUNNER="$(command -v qmlscene6)"
else
    echo "Falta qml6 (Qt 6); no se efectuó captura." >&2
    exit 1
fi
if ! command -v node >/dev/null 2>&1; then
    echo "Falta Node.js para archivar la captura; no se modificó nada." >&2
    exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
export QML_XHR_ALLOW_FILE_READ=1

# La bandera se consume al siguiente arranque del visor. La captura se
# realiza en el MISMO componente QML que usa la apariencia guardada.
"$RUNNER" "$HERE/scripts/marcar_guardado_dia.qml" 2>&1 | tee "$LOG"
if ! grep -q "SMARTBAR_DAY_CAPTURE_REQUESTED" "$LOG"; then
    echo "No se pudo solicitar la captura; se detuvo sin modificar la biblioteca." >&2
    exit 1
fi
: > "$LOG"
echo "Leyendo la apariencia Día guardada en Qt Settings, sin abrir menús ni crear botones..."
"$RUNNER" "$HERE/preview_redimensionable.qml" 2>&1 | tee "$LOG"
node "$HERE/scripts/archivar_dia_local.cjs" "$LOG"
