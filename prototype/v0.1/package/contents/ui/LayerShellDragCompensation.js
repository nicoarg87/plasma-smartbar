.pragma library
// Cálculo PURO para el ensayo de una isla en una ventana LayerShellQt móvil.
// En un window de ancho acotado, la posición del puntero QML es RELATIVA
// a esa ventana. Cuando la ventana sigue al cursor, la posición relativa
// cambia aunque el usuario no haya movido físicamente el puntero.
// Ajustamos el offset por el desplazamiento RELATIVO respecto del punto
// de inicio, no por activeTranslation acumulada en coordenadas móviles.
// Nunca se usa en el panel real: activación explícita por el visor aislado.
function clamp(value, maxOffset) {
    if (typeof maxOffset !== "number" || !Number.isFinite(maxOffset)) return 0;
    const max = Math.max(0, maxOffset);
    if (typeof value !== "number" || !Number.isFinite(value)) return 0;
    return Math.min(max, Math.max(0, value));
}
function nextOffset(currentOffset, pressSceneX, sceneX, maxOffset) {
    const current = clamp(currentOffset, maxOffset);
    if (typeof pressSceneX !== "number" || !Number.isFinite(pressSceneX) ||
        typeof sceneX !== "number" || !Number.isFinite(sceneX))
        return current;
    // Para pantalla con ancla derecha: al ir a la izquierda aumenta
    // islandOffset. Al mover la superficie, el dx relativo al Window
    // se corrige por sí mismo en la siguiente muestra de puntero.
    return clamp(current - (sceneX - pressSceneX), maxOffset);
}
