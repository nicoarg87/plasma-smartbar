#!/usr/bin/env bash
# Inspección local SOLO LECTURA. No cambia temas, horarios ni panel KDE.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (( $# != 0 ));then
  echo "Uso: bash prototype/v0.1/inspeccionar_recuperacion_atardecer.sh" >&2
  exit 2
fi
if command -v pgrep >/dev/null 2>&1 &&
   pgrep -f '[/]preview_redimensionable[.]qml' >/dev/null 2>&1; then
  echo "Cerrá el visor Qt para inspeccionar los valores ya guardados." >&2
  exit 2
fi
if command -v qml6 >/dev/null 2>&1; then
  QML="$(command -v qml6)"
elif [[ -x /usr/lib/qt6/bin/qml ]]; then
  QML=/usr/lib/qt6/bin/qml
elif command -v qmlscene6 >/dev/null 2>&1; then
  QML="$(command -v qmlscene6)"
else
  echo "No está disponible Qt 6. Nada modificado." >&2
  exit 1
fi
if ! command -v node >/dev/null 2>&1;then
  echo "Node.js no disponible. Nada modificado." >&2
  exit 1
fi
LOG="$(mktemp)"
trap 'rm -f -- "$LOG"' EXIT
if ! "$QML" "$HERE/scripts/leer_candidatos_atardecer.qml" >"$LOG" 2>&1;then
  echo "No se pudieron leer los perfiles guardados; nada modificado." >&2
  grep -E 'QQmlApplicationEngine|failed|Error|module .*not installed' "$LOG" >&2 || true
  exit 3
fi
node "$HERE/scripts/inspeccionar_recuperacion_atardecer.cjs" "$LOG"
