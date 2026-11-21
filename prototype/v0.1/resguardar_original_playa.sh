#!/usr/bin/env bash
# Resguardo local de la apariencia ACTIVA y recursos originales, no publicación.
# Leer el visor YA CERRADO. No toca ni los temas de Qt ni el panel KDE.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ "$#" -gt 1 ]; then
    echo "Uso: bash prototype/v0.1/resguardar_original_playa.sh [auto|dia|atardecer|noche]" >&2
    exit 2
fi
TARGET="${1:-auto}"
case "$TARGET" in
    auto|dia|atardecer|noche) ;;
    *) echo "Modo inválido. No se guardó nada." >&2; exit 2 ;;
esac
if command -v pgrep >/dev/null 2>&1 &&
   pgrep -f '[/]preview_redimensionable[.]qml' >/dev/null 2>&1; then
    echo "Cerrá el visor con la apariencia elegida antes de generar el resguardo." >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML="/usr/lib/qt6/bin/qml"
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML="$(command -v qmlscene6)"
else
    echo "Qt 6 no disponible. Ningún tema modificado." >&2
    exit 1
fi
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js no disponible. Ningún tema modificado." >&2
    exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
if ! "$QML" "$HERE/scripts/leer_apariencia_playa.qml" >"$LOG" 2>&1; then
    echo "La lectura Qt falló: no se creó un resguardo." >&2
    grep -E 'QQmlApplicationEngine|failed|Error|module .*not installed' "$LOG" >&2 || true
    exit 3
fi
node "$HERE/scripts/archivar_original_playa.cjs" "$LOG" "$TARGET"
