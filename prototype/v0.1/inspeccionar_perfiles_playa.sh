#!/usr/bin/env bash
# Inspección de SOLO LECTURA de temas guardados para preparar Playa 24hs.
# No modifica temas locales, ajustes Qt, recursos de fábrica ni panel KDE.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if command -v pgrep >/dev/null 2>&1 &&
    pgrep -f '[/]preview_redimensionable[.]qml' >/dev/null 2>&1; then
    echo "Cerrá el visor antes de inspeccionar las preferencias guardadas." >&2
    echo "No se modificó nada." >&2
    exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
    QML="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML="/usr/lib/qt6/bin/qml"
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML="$(command -v qmlscene6)"
else
    echo "Falta Qt 6 (qml6 o qmlscene6). No se modificó nada." >&2
    exit 1
fi
if ! command -v node >/dev/null 2>&1; then
    echo "Falta Node.js. No se modificó nada." >&2
    exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
if ! "$QML" "$HERE/scripts/leer_candidatos_playa.qml" >"$LOG" 2>&1; then
    echo "Falló la lectura QML. No se modificó nada." >&2
    grep -E 'QQmlApplicationEngine|failed|Error|module .*not installed' "$LOG" >&2 || true
    exit 3
fi
node "$HERE/scripts/inspeccionar_perfiles_playa.cjs" "$LOG"
