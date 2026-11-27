#!/usr/bin/env bash
# Sesión experimental de las dos islas en LayerShell sobre KDE Plasma/Wayland.
# No instala ni reemplaza paneles; solo el botón de tema, por clic
# explícito, puede cambiar el fondo del escritorio activo con respaldo.
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
CATALOG_CREATED=0
CATALOG_FILE="$HERE/package/contents/ui/.smartbar-app-catalog-preview.json"
finish() {
    local status=$?
    trap - EXIT INT TERM
    # Solo finalizar los procesos que lanzó esta sesión.
    if [[ -n "$SO_PID" ]]; then kill "$SO_PID" 2>/dev/null || true; fi
    if [[ -n "$MAL_PID" ]]; then kill "$MAL_PID" 2>/dev/null || true; fi
    if [[ -n "$SO_PID" ]]; then wait "$SO_PID" 2>/dev/null || true; fi
    if [[ -n "$MAL_PID" ]]; then wait "$MAL_PID" 2>/dev/null || true; fi
    if [[ -d "$BUILD_DIR" ]]; then rm -rf -- "$BUILD_DIR"; fi
    if (( CATALOG_CREATED == 1 )); then rm -f -- "$CATALOG_FILE"; fi
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

# Generar solo el catálogo efímero ausente; no sobreescribir datos existentes.
if [[ ! -e "$CATALOG_FILE" ]]; then
    if command -v python3 >/dev/null 2>&1 &&
       python3 "$HERE/catalogo_aplicaciones.py" "$CATALOG_FILE" \
           >"$SESSION_DIR/catalogo.log" 2>&1; then
        CATALOG_CREATED=1
    else
        printf 'AVISO: catálogo local no disponible; launcher de muestra.\n' >&2
    fi
else
    printf 'Catálogo ya existente: se preserva sin reescrituras.\n'
fi

# Usar la apariencia real guardada en el visor original, sin tocar
# sus Qt Settings, temas inmutables, preferencias de KDE ni wallpapers.
# La copia compartida local se crea UNA sola vez y después solo cambia
# mediante Aplicar en las islas; nunca se reinstalan defaults al arrancar.
APPEARANCE_FILE="$LOG_ROOT/appearance-runtime.json"
if [[ ! -e "$APPEARANCE_FILE" ]]; then
    QML_READER=""
    if command -v qml6 >/dev/null 2>&1; then
        QML_READER="$(command -v qml6)"
    elif [[ -x /usr/lib/qt6/bin/qml ]]; then
        QML_READER=/usr/lib/qt6/bin/qml
    fi
    if [[ -n "$QML_READER" ]] && command -v node >/dev/null 2>&1; then
        if env QT_QPA_PLATFORM=offscreen "$QML_READER" \
           "$HERE/scripts/leer_apariencia_playa.qml" \
           >"$SESSION_DIR/apariencia-origen-privado.log" 2>&1; then
            if ! node "$HERE/scripts/importar_apariencia_conjunta.cjs" \
                "$SESSION_DIR/apariencia-origen-privado.log" "$APPEARANCE_FILE"; then
                printf 'AVISO: no se pudo importar la apariencia previa.\n' >&2
            fi
        else
            printf 'AVISO: lector Qt no disponible; no se modificó la apariencia.\n' >&2
        fi
        # El registro bruto contiene la apariencia del usuario; eliminar
        # los datos fuente una vez terminada la importación.
        rm -f -- "$SESSION_DIR/apariencia-origen-privado.log"
    else
        printf 'AVISO: falta qml6/node para importar la apariencia existente.\n' >&2
    fi
fi

BIN="$BUILD_DIR/smartbar_input_mask_probe"
MESSAGE_PATTERN='[%{time yyyy-MM-dd hh:mm:ss.zzz}] %{type}: %{message}'
# Soledad: ventana fija y máscara de entrada ya ensayadas; posiciones por AppId.
# LayerShell se declara en el QML raíz; no forzarlo sobre las ventanas Popup.
env -u QT_WAYLAND_SHELL_INTEGRATION SMARTBAR_CONTINUOUS=1 \
    SMARTBAR_SHARED_APPEARANCE_PATH="$APPEARANCE_FILE" \
    SMARTBAR_WALLPAPER_HELPER_PATH="$HERE/scripts/wallpaper_playa_kde.cjs" \
    QT_QPA_PLATFORM=wayland QML_XHR_ALLOW_FILE_READ=1 \
    QT_MESSAGE_PATTERN="$MESSAGE_PATTERN" \
    "$BIN" "$HERE/preview_soledad_input_mask.qml" \
    >"$SESSION_DIR/soledad.log" 2>&1 &
SO_PID=$!
# Malvina: capa Top independiente y teclado OnDemand. No imponer LayerShell
# globalmente a Configuración; su ventana conserva decoración KDE normal.
env -u QT_WAYLAND_SHELL_INTEGRATION SMARTBAR_CONTINUOUS=1 \
    SMARTBAR_SHARED_APPEARANCE_PATH="$APPEARANCE_FILE" \
    QT_QPA_PLATFORM=wayland QML_XHR_ALLOW_FILE_READ=1 \
    QT_MESSAGE_PATTERN="$MESSAGE_PATTERN" \
    "$BIN" "$HERE/preview_malvina_input_mask.qml" \
    >"$SESSION_DIR/malvina.log" 2>&1 &
MAL_PID=$!

printf '\nIslas experimentales iniciadas (Soledad PID %s; Malvina PID %s).\n' "$SO_PID" "$MAL_PID"
printf 'KDE y su panel inferior permanecen sin modificaciones.\n'
printf 'Sin autocierre: mantené esta Konsole abierta o minimizada. Ctrl+C detiene ambas.\n'
printf 'Malvina se autooculta; acercá el cursor a la esquina superior izquierda.\n'
printf 'Los perfiles de Soledad y las preferencias de Malvina siguen separados.\n'
printf 'La apariencia visual se comparte localmente, sin tocar los temas originales.\n'
printf 'NO es un plasmoide instalado; miniaturas y wallpaper real continúan pendientes.\n'
printf 'Logs privados: %s\n' "$SESSION_DIR"
printf 'En otra Konsole: tail -f "%s/soledad.log" "%s/malvina.log"\n' "$SESSION_DIR" "$SESSION_DIR"

# Si se cierra inesperadamente una isla, cerrar la otra para no dejar un
# experimento parcial superpuesto al escritorio.
if wait -n "$SO_PID" "$MAL_PID"; then
    printf 'Una de las islas terminó; se cierra la sesión conjunta.\n'
else
    printf 'Una isla terminó con error. Últimas líneas de ambos logs:\n' >&2
    # Mostrar únicamente el tramo final en caso de fallo, sin tocar
    # los registros completos que permanecen guardados por sesión.
    for island in soledad malvina; do
        printf '\n=== %s ===\n' "$island" >&2
        if [[ -f "$SESSION_DIR/$island.log" ]]; then
            tail -n 18 -- "$SESSION_DIR/$island.log" >&2
        fi
    done
    printf '\nLogs originales conservados en: %s\n' "$SESSION_DIR" >&2
    exit 7
fi
