#!/usr/bin/env bash
# Ensayo Qt transitorio (SIN KConfig, PlasmaShell, instalación ni cambios de panel).
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-pasivo}"
case "$MODE" in
    pasivo|interactivo) ;;
    *)
        printf 'Uso: bash prototype/v0.1/probar_superposicion.sh [pasivo|interactivo]\n' >&2
        exit 2 ;;
esac

if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qmlscene6)"
else
    printf 'ERROR: no se encontró qml6 o qmlscene6. No se cambió nada.\n' >&2
    exit 1
fi

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ]; then
    printf 'AVISO: sesión no identificada como Wayland; el resultado no valida KWin/Wayland.\n' >&2
fi

printf 'Plasma SmartBar: ensayo TEMPORAL de superposición (%s).\n' "$MODE"
printf 'Superficie independiente de 456 x 44 píxeles lógicos, 60 s máximo.\n'
printf 'No se instala ninguna barra, no se modifican ventanas ni preferencias.\n'
printf 'Wayland/KWin puede ignorar la petición de posición superior y apilamiento.\n'
if [ "$MODE" = "pasivo" ]; then
    printf 'Modo pasivo: ventana sin entrada de teclado ni ratón; clics deben atravesarla.\n'
else
    printf 'Modo interactivo: la franja recibe clics; Escape la cierra.\n'
fi
printf 'Para abortar también podés usar Ctrl+C en esta Konsole.\n'
exec "$QML_RUNNER" "$HERE/preview_superposicion_${MODE}.qml"
