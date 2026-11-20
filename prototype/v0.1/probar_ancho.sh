#!/usr/bin/env bash
# Ensayo de ancho responsivo con Qt Quick, independiente de PlasmaShell.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if command -v qml6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qml6)"
elif [ -x /usr/lib/qt6/bin/qml ]; then
    QML_RUNNER=/usr/lib/qt6/bin/qml
elif command -v qmlscene6 >/dev/null 2>&1; then
    QML_RUNNER="$(command -v qmlscene6)"
else
    echo "No se encontró qml6/qmlscene6 de Qt 6." >&2
    echo "En CachyOS/Arch suele venir con qt6-declarative." >&2
    echo "Verificá: pacman -Q qt6-declarative" >&2
    echo "El script no instalará ni modificará paquetes." >&2
    exit 1
fi

GIF_SO="$HERE/package/contents/ui/assets/so-tropical.gif"
if [ ! -s "$GIF_SO" ]; then
    echo "AVISO: falta el GIF tropical predeterminado de SO:" >&2
    echo "  $GIF_SO" >&2
    echo "El botón mostrará el texto SO en lugar del GIF." >&2
    echo "Descargá Plasma-SmartBar-Islands-GIF-SO-definitivo.zip y" >&2
    echo "extraelo desde la raíz del repositorio, por ejemplo:" >&2
    echo "  unzip -o ~/Descargas/Plasma-SmartBar-Islands-GIF-SO-definitivo.zip -d ." >&2
else
    echo "GIF predeterminado de SO localizado: $GIF_SO"
fi

# Catálogo efímero local para el launcher de SO: únicamente nombres/categorías
# de archivos .desktop, sin ejecutar programas ni indexar archivos personales.
# No se guarda en GitHub, KConfig ni en configuraciones del usuario.
LOCAL_CATALOG="$HERE/package/contents/ui/.smartbar-app-catalog-preview.json"
CATALOG_CREATED=0
if [ ! -e "$LOCAL_CATALOG" ] && command -v python3 >/dev/null 2>&1; then
    if python3 "$HERE/catalogo_aplicaciones.py" "$LOCAL_CATALOG"; then
        CATALOG_CREATED=1
    else
        echo "AVISO: no se pudo generar el catálogo de aplicaciones. Se usan muestras." >&2
    fi
fi
cleanup_catalog() {
    if [ "$CATALOG_CREATED" -eq 1 ]; then
        rm -f -- "$LOCAL_CATALOG"
    fi
}
WALLPAPER_WATCH_PID=""
cleanup_preview() {
    if [ -n "$WALLPAPER_WATCH_PID" ]; then
        kill "$WALLPAPER_WATCH_PID" 2>/dev/null || true
        wait "$WALLPAPER_WATCH_PID" 2>/dev/null || true
    fi
    cleanup_catalog
}
trap cleanup_preview EXIT

export QML_XHR_ALLOW_FILE_READ=1

# El monitor solo cambia el fondo después de seleccionar Día/Atardecer/Noche.
# Los tres PNG originales se entregan por ZIP; si faltan, no afecta al visor.
WALLPAPER_ASSETS="$HERE/package/contents/ui/assets/wallpapers"
if command -v python3 >/dev/null 2>&1 &&
   [ -f "$WALLPAPER_ASSETS/manifest.json" ] &&
   python3 "$HERE/scripts/vigilar_wallpaper.py" --check >/dev/null 2>&1; then
    python3 -u "$HERE/scripts/vigilar_wallpaper.py" &
    WALLPAPER_WATCH_PID=$!
    echo "Fondos por tema habilitados: Día, Atardecer y Noche, modo Estirar."
else
    echo "AVISO: los wallpapers aún no están completos. Extraé el ZIP de wallpapers en la raíz del repositorio."
    echo "La maqueta sigue funcionando sin modificar el fondo del escritorio."
fi

echo "Abriendo la vista de geometría Qt Quick de Plasma SmartBar Islands…"
echo "Esta ventana usa SmartBarContent.qml, igual que el plasmoide."
echo "No se instala ni cambia ningún panel. Cerrala con la X."
"$QML_RUNNER" "$HERE/preview_redimensionable.qml"
