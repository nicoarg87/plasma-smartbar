#!/usr/bin/env bash
# Comparación privada SOLO LECTURA: Qt histórico frente a ensayo conjunto.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( $# != 0 ));then
  echo "Uso: bash prototype/v0.1/comparar_atardecer_islas.sh" >&2
  exit 2
fi
if command -v qml6 >/dev/null 2>&1;then
  QML="$(command -v qml6)"
elif [[ -x /usr/lib/qt6/bin/qml ]];then
  QML=/usr/lib/qt6/bin/qml
elif command -v qmlscene6 >/dev/null 2>&1;then
  QML="$(command -v qmlscene6)"
else
  echo "No se encontró QML Qt6." >&2
  exit 1
fi
if ! command -v node >/dev/null 2>&1;then
  echo "No se encontró Node.js." >&2
  exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
if ! "$QML" "$HERE/scripts/leer_candidatos_atardecer.qml" >"$LOG" 2>&1;then
  echo "No se pudo leer el perfil histórico Qt. Nada modificado." >&2
  exit 3
fi
node "$HERE/scripts/comparar_atardecer_islas.cjs" "$LOG"
