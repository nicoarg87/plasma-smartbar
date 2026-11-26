#!/usr/bin/env bash
# Preparación privada y reversible de los tres perfiles de Playa 24hs.
# No inicia ni detiene islas ni cambia los ajustes del panel KDE.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( $# != 0 )); then
 echo "Uso: bash prototype/v0.1/preparar_pack_islas_juntas.sh" >&2
 exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
 QML="$(command -v qml6)"
elif [[ -x /usr/lib/qt6/bin/qml ]]; then
 QML="/usr/lib/qt6/bin/qml"
elif command -v qmlscene6 >/dev/null 2>&1; then
 QML="$(command -v qmlscene6)"
else
 echo "Falta Qt 6; no se modificó nada." >&2
 exit 1
fi
if ! command -v node >/dev/null 2>&1; then
 echo "Falta Node.js; no se modificó nada." >&2
 exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
if ! "$QML" "$HERE/scripts/leer_apariencia_playa.qml" >"$LOG" 2>&1; then
 echo "No se pudieron leer las preferencias Qt; no se habilitó el pack." >&2
 exit 3
fi
node "$HERE/scripts/preparar_pack_islas_juntas.cjs" "$LOG"
