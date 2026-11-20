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
trap cleanup_catalog EXIT

export QML_XHR_ALLOW_FILE_READ=1

# Solo simulación: la foto se dibuja en preview_redimensionable.qml.
# No se ejecutan monitores externos ni comandos que cambien el wallpaper KDE.
WALLPAPER_ASSETS="$HERE/package/contents/ui/assets/wallpapers"
if [ ! -f "$WALLPAPER_ASSETS/day.png" ] ||
   [ ! -f "$WALLPAPER_ASSETS/sunset.png" ] ||
   [ ! -f "$WALLPAPER_ASSETS/night.png" ]; then
    echo "AVISO: faltan wallpapers del escritorio simulado. Extraé el ZIP de wallpapers en la raíz del repositorio."
    echo "El visor abrirá con el fondo liso si no están instaladas las imágenes."
fi

echo "Abriendo la vista de geometría Qt Quick de Plasma SmartBar Islands…"
echo "Esta ventana usa SmartBarContent.qml, igual que el plasmoide."
echo "No se instala ni cambia ningún panel. Cerrala con la X."
"$QML_RUNNER" "$HERE/preview_redimensionable.qml"
