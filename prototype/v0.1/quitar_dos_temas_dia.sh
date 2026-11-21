#!/usr/bin/env bash
# Retira únicamente los dos registros Día señalados por el mantenedor.
# Nunca cambia Día/Atardecer/Noche principales, panel KDE, GIF ni apariencia.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if command -v qml6 >/dev/null 2>&1; then
    QML="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML="/usr/lib/qt6/bin/qml"
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML="$(command -v qmlscene6)"
else
    echo "Falta el ejecutor QML de Qt 6. No se modificó ningún tema." >&2
    exit 1
fi
if ! command -v node >/dev/null 2>&1; then
    echo "Falta Node.js. No se modificó ningún tema." >&2
    exit 1
fi
# Con el visor abierto, al cerrar podría reescribir una biblioteca vieja.
if command -v pgrep >/dev/null 2>&1 &&
    pgrep -f '[/]preview_redimensionable[.]qml' >/dev/null 2>&1; then
    echo "Cerrá el visor de Plasma SmartBar antes de ejecutar la limpieza." >&2
    echo "No se modificó ningún tema." >&2
    exit 2
fi

BEFORE="$(mktemp)"
AFTER="$(mktemp)"
WRITE_LOG="$(mktemp)"
BACKUP_LOG="$(mktemp)"
cleanup() { rm -f -- "$BEFORE" "$AFTER" "$WRITE_LOG" "$BACKUP_LOG"; }
trap cleanup EXIT

if ! "$QML" "$HERE/scripts/leer_biblioteca_para_quitar_dia.qml" >"$BEFORE" 2>&1; then
    echo "Error al leer la biblioteca local: no se modificó nada." >&2
    exit 3
fi
if ! node "$HERE/scripts/respaldar_biblioteca_antes_de_quitar_dia.cjs" "$BEFORE" >"$BACKUP_LOG" 2>&1; then
    cat "$BACKUP_LOG" >&2
    echo "No se eliminó ningún tema." >&2
    exit 4
fi
cat "$BACKUP_LOG"
BACKUP_FILE="$(sed -n 's/^Respaldo íntegro creado en: //p' "$BACKUP_LOG")"
if [ -z "$BACKUP_FILE" ] || [ ! -s "$BACKUP_FILE" ]; then
    echo "No se verificó la copia local; limpieza cancelada." >&2
    exit 5
fi

# Verificar lectura estable antes de modificar el almacenamiento.
STABLE="$(mktemp)"
trap 'rm -f -- "$STABLE"; cleanup' EXIT
if ! "$QML" "$HERE/scripts/leer_biblioteca_para_quitar_dia.qml" >"$STABLE" 2>&1; then
    echo "La segunda lectura falló: no se modificó nada." >&2
    exit 6
fi
if ! node "$HERE/scripts/comparar_biblioteca_dia_antes.cjs" "$BACKUP_FILE" "$STABLE"; then
    echo "La biblioteca cambió durante el respaldo; limpieza cancelada." >&2
    exit 7
fi
if ! "$QML" "$HERE/scripts/quitar_dos_entradas_dia.qml" >"$WRITE_LOG" 2>&1; then
    cat "$WRITE_LOG" >&2
    echo "Qt no confirmó la escritura. Respaldo: $BACKUP_FILE" >&2
    exit 8
fi
if ! grep -q 'SMARTBAR_DAY_CLEANUP_DONE=2' "$WRITE_LOG" ||
    grep -q 'SMARTBAR_DAY_CLEANUP_ERROR=' "$WRITE_LOG"; then
    cat "$WRITE_LOG" >&2
    echo "No se confirmó la limpieza; copia conservada en $BACKUP_FILE" >&2
    exit 9
fi
if ! "$QML" "$HERE/scripts/leer_biblioteca_para_quitar_dia.qml" >"$AFTER" 2>&1; then
    echo "No se pudo releer la biblioteca final. Respaldo: $BACKUP_FILE" >&2
    exit 10
fi
if ! node "$HERE/scripts/verificar_limpieza_dos_dia.cjs" "$BACKUP_FILE" "$AFTER"; then
    echo "AVISO: verificación fallida. Respaldo íntegro en $BACKUP_FILE" >&2
    exit 11
fi
echo "Listo: Día, Atardecer y Noche principales permanecen sin cambios."
echo "Respaldo recuperable: $BACKUP_FILE"
