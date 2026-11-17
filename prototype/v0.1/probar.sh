#!/usr/bin/env bash
# Ensayo en ventana independiente: no instala ni reemplaza paneles.
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PKG="$HERE/package"

if ! command -v plasmoidviewer >/dev/null 2>&1; then
    echo "No encontré plasmoidviewer (Plasma SDK)." >&2
    echo "En CachyOS/Arch podés instalarlo con: sudo pacman -S --needed plasma-sdk" >&2
    echo "Este script NO instalará nada automáticamente." >&2
    exit 1
fi

echo "Abriendo Plasma SmartBar v0.1 en ventana de prueba…"
echo "No se reemplaza ni modifica el panel actual."
exec plasmoidviewer -a "$PKG" -l topedge -f horizontal -s 1000x80
