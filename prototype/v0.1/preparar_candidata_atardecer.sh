#!/usr/bin/env bash
# Candidata privada, NUNCA aplica ni reemplaza temas. Solo lee Qt y JSON de islas.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( $# != 0 )); then
 echo "Uso: bash prototype/v0.1/preparar_candidata_atardecer.sh" >&2
 exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
 QML="$(command -v qml6)"
elif [[ -x /usr/lib/qt6/bin/qml ]]; then
 QML=/usr/lib/qt6/bin/qml
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
if ! "$QML" "$HERE/scripts/leer_candidatos_atardecer.qml" >"$LOG" 2>&1; then
 echo "Falló la lectura Qt; no se generó candidata." >&2
 exit 3
fi
node "$HERE/scripts/preparar_candidata_atardecer.cjs" "$LOG"
