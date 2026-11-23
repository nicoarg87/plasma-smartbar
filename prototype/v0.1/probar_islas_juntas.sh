#!/usr/bin/env bash
# Sesión experimental de las dos islas en LayerShell sobre KDE Plasma/Wayland.
# No instala ni reemplaza paneles; NO modifica los fondos del escritorio.
# Un solo binario temporal atiende dos procesos independientes y aislados.
set -euo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" == "--help" ]]; then
    printf 'Uso: bash prototype/v0.1/probar_islas_juntas.sh\n'
    printf 'Soledad + Malvina sobre KDE, panel habitual intacto. Ctrl+C para cerrar.\n'
    exit 0
fi
if (( $# != 0 )); then
    printf 'Opción desconocida. Usá --help.\n' >&2
    exit 2
fi
if [[ "${XDG_SESSION_TYPE:-}" != "wayland" || -z "${WAYLAND_DISPLAY:-}" ]]; then
    printf 'Este ensayo requiere KDE/KWin bajo Wayland. Sin cambios.\n' >&2
    exit 2
fi
if ! command -v cmake >/dev/null 2>&1 || ! command -v c++ >/dev/null 2>&1; then
    printf 'Faltan cmake o un compilador C++; no se instalará nada.\n' >&2
    exit 3
fi

LOG_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/plasma-smartbar/ensayos"
mkdir -p -- "$LOG_ROOT"
chmod 700 -- "$LOG_ROOT"
if command -v flock >/dev/null 2>&1; then
    exec 9>"$LOG_ROOT/.islas-juntas.lock"
    if ! flock -n 9; then
        printf 'Ya existe una sesión conjunta activa; no iniciar duplicados.\n' >&2
        exit 6
    fi
fi

SESSION_DIR="$(mktemp -d "$LOG_ROOT/sesion-$(date +%Y%m%d-%H%M%S)-XXXXXXXX")"
printf '%s\n' "$SESSION_DIR" > "$LOG_ROOT/ultima_sesion.txt"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/smartbar-juntas.XXXXXXXX")"
SO_PID=""
MAL_PID=""
finish() {
    local status=$?
    trap - EXIT INT TERM
    # Solo finalizar los procesos que lanzó esta sesión.
    if [[ -n "$SO_PID" ]]; then kill "$SO_PID" 2>/dev/null || true; fi
    if [[ -n "$MAL_PID" ]]; then kill "$MAL_PID" 2>/dev/null || true; fi
    if [[ -n "$SO_PID" ]]; then wait "$SO_PID" 2>/dev/null || true; fi
    if [[ -n "$MAL_PID" ]]; then wait "$MAL_PID" 2>/dev/null || true; fi
    if [[ -d "$BUILD_DIR" ]]; then rm -rf -- "$BUILD_DIR"; fi
    printf '\nSesión terminada. Logs conservados en: %s\n' "$SESSION_DIR"
    exit "$status"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

printf 'Compilando puente Qt en directorio temporal...\n'
if ! cmake -S "$HERE/native_probes" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release >"$SESSION_DIR/compilacion.log" 2>&1; then
    tail -n 60 "$SESSION_DIR/compilacion.log" >&2
    exit 4
fi
if ! cmake --build "$BUILD_DIR" --parallel 2 >>"$SESSION_DIR/compilacion.log" 2>&1; then
    tail -n 60 "$SESSION_DIR/compilacion.log" >&2
    exit 5
fi

BIN="$BUILD_DIR/smartbar_input_mask_probe"
MESSAGE_PATTERN='[%{time yyyy-MM-dd hh:mm:ss.zzz}] %{type}: %{message}'
# Soledad: ventana fija y máscara de entrada ya ensayadas; posiciones por AppId.
env SMARTBAR_CONTINUOUS=1 QT_QPA_PLATFORM=wayland \
    QT_WAYLAND_SHELL_INTEGRATION=layer-shell QT_MESSAGE_PATTERN="$MESSAGE_PATTERN" \
    "$BIN" "$HERE/preview_soledad_input_mask.qml" \
    >"$SESSION_DIR/soledad.log" 2>&1 &
SO_PID=$!
# Malvina: capa Top independiente y teclado OnDemand. No imponer LayerShell
# globalmente a Configuración; su ventana conserva decoración KDE normal.
env -u QT_WAYLAND_SHELL_INTEGRATION SMARTBAR_CONTINUOUS=1 \
    QT_QPA_PLATFORM=wayland QT_MESSAGE_PATTERN="$MESSAGE_PATTERN" \
    "$BIN" "$HERE/preview_malvina_input_mask.qml" \
    >"$SESSION_DIR/malvina.log" 2>&1 &
MAL_PID=$!

printf '\nIslas experimentales iniciadas (Soledad PID %s; Malvina PID %s).\n' "$SO_PID" "$MAL_PID"
printf 'KDE y su panel inferior permanecen sin modificaciones.\n'
printf 'Sin autocierre: mantené esta Konsole abierta o minimizada. Ctrl+C detiene ambas.\n'
printf 'Malvina se autooculta; acercá el cursor a la esquina superior izquierda.\n'
printf 'Los perfiles de Soledad y las preferencias de Malvina siguen separados.\n'
printf 'NO es un plasmoide instalado; miniaturas y wallpaper real continúan pendientes.\n'
printf 'Logs privados: %s\n' "$SESSION_DIR"
printf 'En otra Konsole: tail -f "%s/soledad.log" "%s/malvina.log"\n' "$SESSION_DIR" 

# Si se cierra inesperadamente una isla, cerrar la otra para no dejar un
# experimento parcial superpuesto al escritorio.
if wait -n "$SO_PID" "$MAL_PID"; then
    printf 'Una de las islas terminó; se cierra la sesión conjunta.\n'
else
    printf 'Una isla terminó con error; revisar los logs de la sesión.\n' >&2
    exit 7
fi
