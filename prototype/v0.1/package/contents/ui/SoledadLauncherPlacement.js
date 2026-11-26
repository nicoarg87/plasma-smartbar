.pragma library

// Coordenada horizontal del launcher de aplicaciones instaladas.
// Política compartida por la ventana propia LayerShell y el Popup Qt
// del visor; el padre QML conserva el origen y las coordenadas locales.
// Reproduce el anclaje a SO y el despliegue de categorías a la izquierda.
function screenLeft(geometry) {
    const popupWidth = geometry.popupWidth
    const screenWidth = geometry.requirePositiveScreenWidth
        ? Math.max(1, geometry.screenWidth) : geometry.screenWidth
    const maxLeft = Math.max(0, screenWidth - popupWidth)

    if (geometry.fromSo)
        return Math.max(0, Math.min(maxLeft,
            geometry.systemIslandX + geometry.systemIslandWidth - popupWidth))

    const center = geometry.launcherCenter
    if (geometry.categoryLayout === 1 &&
        (geometry.showCategoryPanel ||
         (geometry.filesMode && geometry.expandedCanvas))) {
        const baseX = Math.max(0, Math.min(
            Math.max(0, screenWidth - geometry.primaryWidth),
            center - geometry.primaryWidth / 2))
        return Math.max(0, Math.min(maxLeft,
            baseX - (popupWidth - geometry.primaryWidth)))
    }
    return Math.max(0, Math.min(maxLeft, center - popupWidth / 2))
}
