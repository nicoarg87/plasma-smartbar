#!/usr/bin/env bash
# Ensayo aislado de Malvina: LayerShell Top + máscara de entrada exacta.
# No instala panel, no modifica preferencias y no controla ventanas externas.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${XDG_SESSION_TYPE:-}" != wayland || -z "${WAYLAND_DISPLAY:-}" ]]; then
    printf 'ERROR: ensayo exclusivo de KWin/Wayland. Sin cambios.\n' >&2
    exit 2
fi
if ! command -v cmake >/dev/null 2>&1 || ! command -v c++ >/dev/null 2>&1; then
    printf 'FALTAN herramientas de desarrollo (cmake y/o compilador C++).\n' >&2
    printf 'No se instalo nada ni se modifico tu panel.\n' >&2
    exit 3
fi

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/smartbar-malvina-mask.XXXXXXXX")"
cleanup() { rm -rf -- "$BUILD_DIR"; }
trap cleanup EXIT

printf 'Plasma SmartBar: MALVINA delante de ventanas, excepto fullscreen real.\n'
printf 'Superficie superior limitada al ancho real de Malvina.\n'
printf 'Esta instancia muestra Malvina siempre, SOLO para comprobarla.\n'
printf 'No cambia el autoocultamiento ni las preferencias del visor.\n'
printf 'NO instala widgets, NO reemplaza panel y NO mueve aplicaciones.\n'
printf 'Primero comprobar con Brave/Steam abiertos, luego fullscreen real.\n'
printf 'Ensayo extendido: 180 segundos o Ctrl+C, sin guardar el orden.\n'

if ! cmake -S "$HERE/native_probes" -B "$BUILD_DIR" \
           -DCMAKE_BUILD_TYPE=Release; then
    printf 'Error de CMake: conservar la salida, sin instalar paquetes.\n' >&2
    exit 4
fi
if ! cmake --build "$BUILD_DIR" --parallel 2; then
    printf 'Error de compilacion: conservar salida de Konsole.\n' >&2
    exit 5
fi

env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell \
    "$BUILD_DIR/smartbar_input_mask_probe" "$HERE/preview_malvina_input_mask.qml"
