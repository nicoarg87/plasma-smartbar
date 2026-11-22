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


// En el extremo, seguir empujando no puede almacenar distancia extra.
// Si esa distancia queda en la referencia, al invertir el sentido el
// agarre parece bloqueado hasta deshacerla y después puede dar un salto.
// Reanclar la coordenada LOCAL únicamente cuando se satura el recorrido.
// Esta función se activa SOLO desde el ensayo LayerShell, no en el visor.
function nextWithEdgeRebase(currentOffset, anchorSceneX, currentSceneX, maxOffset) {
    const offset = nextOffset(currentOffset, anchorSceneX, currentSceneX, maxOffset);
    const max = (typeof maxOffset === "number" && Number.isFinite(maxOffset))
        ? Math.max(0, maxOffset) : 0;
    const valid = Number.isFinite(anchorSceneX) && Number.isFinite(currentSceneX);
    if (!valid || max === 0) {
        return {offset: offset, anchorSceneX: anchorSceneX};
    }
    const relativeDelta = currentSceneX - anchorSceneX;
    const hitLeftEdge = offset >= max && relativeDelta < 0;
    const hitRightEdge = offset <= 0 && relativeDelta > 0;
    return {
        offset: offset,
        anchorSceneX: (hitLeftEdge || hitRightEdge)
            ? currentSceneX : anchorSceneX
    };
}
