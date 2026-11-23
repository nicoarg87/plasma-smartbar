#!/usr/bin/env bash
# Compila localmente un pequeño puente QWindow::setMask; no instala nada.
# La compilación y el ejecutable se borran al terminar este ensayo.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${XDG_SESSION_TYPE:-}" != wayland || -z "${WAYLAND_DISPLAY:-}" ]]; then
    printf 'ERROR: ensayo exclusivo de KWin/Wayland. Sin cambios.\n' >&2
    exit 2
fi

if ! command -v cmake >/dev/null 2>&1 ||
   ! command -v c++ >/dev/null 2>&1; then
    printf 'FALTAN herramientas de desarrollo (cmake y/o compilador C++).\n' >&2
    printf 'No se instalo nada ni se modifico tu panel.\n' >&2
    exit 3
fi

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/smartbar-mask-probe.XXXXXXXX")"
cleanup() { rm -rf -- "$BUILD_DIR"; }
trap cleanup EXIT

printf 'Plasma SmartBar: prueba DIFERENCIAL de arrastre sin mover la superficie.\n'
printf 'Soledad REAL + agarre existente + GIF original.\n'
printf 'El Window queda FIJO; solo la region Qt de entrada sigue la isla.\n'
printf 'Nuevo ensayo: ventanas KDE reales en SOLO LECTURA; SIN margen derecho fijo.\n'
printf 'Posición por aplicación: arrastrar agarre; clic derecho y elegir RECORDAR.\n'
printf 'Memoria propia de posiciones, AISLADA del visor Qt y panel.\n'
printf 'Solo guarda esa posición si elegís RECORDAR, nunca por arrastre ni tema.\n'
printf 'Al desmaximizar/minimizar: retorna a derecha por defecto.\n'
printf 'No instala paquetes, no cambia el panel ni modifica temas.\n'
printf 'Requiere cabeceras de Qt6 (Gui, Qml, Quick), cmake y compilador C++.\n'
printf 'Compilando en directorio TEMPORAL, que se eliminara al finalizar...\n'

if ! cmake -S "$HERE/native_probes" -B "$BUILD_DIR" \
            -DCMAKE_BUILD_TYPE=Release; then
    printf '\nNo se pudo configurar el ensayo: faltan dependencias Qt6 de desarrollo.\n' >&2
    printf 'No instalar paquetes sin permiso; conservá el error de CMake.\n' >&2
    exit 4
fi

if ! cmake --build "$BUILD_DIR" --parallel 2; then
    printf '\nNo se pudo compilar el ensayo. Conservá la salida de CMake.\n' >&2
    exit 5
fi

printf '\nPrueba lista. Arrastrá la isla desde los SEIS puntos.\n'
printf 'Probá cerca del borde izquierdo y al volver hacia la derecha.\n'
printf 'Los clics FUERA de la isla deben seguir llegando a Brave.\n'
printf 'Autocierre 90 segundos o Ctrl+C desde Konsole.\n'
env QT_QPA_PLATFORM=wayland QT_WAYLAND_SHELL_INTEGRATION=layer-shell \
    "$BUILD_DIR/smartbar_input_mask_probe" "$HERE/preview_soledad_input_mask.qml"
