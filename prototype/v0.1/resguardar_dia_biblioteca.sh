#!/usr/bin/env bash
# Resguardar Día desde biblioteca Qt sin aplicarlo ni cambiar el reloj horario.
# No escribe ajustes, no toca KDE ni instala presets.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( $# != 0 )); then
    echo "Uso: bash prototype/v0.1/resguardar_dia_biblioteca.sh" >&2
    exit 2
fi
if command -v pgrep >/dev/null 2>&1 &&
    pgrep -f '[/]preview_redimensionable[.]qml' >/dev/null 2>&1; then
    echo "Cerrá el visor Qt antes de leer los temas guardados. Nada modificado." >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML="$(command -v qml6)"
elif [[ -x /usr/lib/qt6/bin/qml ]]; then
    QML=/usr/lib/qt6/bin/qml
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML="$(command -v qmlscene6)"
else
    echo "Falta QML de Qt 6. Nada modificado." >&2
    exit 1
fi
if ! command -v node >/dev/null 2>&1; then
    echo "Falta Node.js. Nada modificado." >&2
    exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
if ! "$QML" "$HERE/scripts/leer_apariencia_playa.qml" >"$LOG" 2>&1; then
    echo "Falló la lectura aislada Qt. Nada modificado." >&2
    grep -E 'QQmlApplicationEngine|failed|Error|module .*not installed' "$LOG" >&2 || true
    exit 3
fi
node "$HERE/scripts/resguardar_dia_biblioteca.cjs" "$LOG"
