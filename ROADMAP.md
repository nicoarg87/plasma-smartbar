# Hoja de ruta de Plasma SmartBar

> **Estado real:** documentación disponible. **No hay aún código funcional ni versión instalable.**
> Las etapas se subordinan a la [Constitución técnica](docs/CONSTITUCION_TECNICA.md).

## Fase 0 — Fundamentos y organización
- [x] Abrir repositorio público para Linux con KDE Plasma.
- [x] Establecer licencia GPL-3.0, constitución, Manual Maestro y gobernanza.
- [x] Redactar reglas de contribución y visión inicial.
- [x] Activar regla de protección de rama main (bloqueo de borrado y force push; confirmado 14/11/2026).
- [ ] Revisar periódicamente colaboradores autorizados y evaluar exigencia de PRs cuando haya equipo.
- [ ] Investigar qué piezas de Plasma/KWin/Qt pueden reutilizarse y bajo qué licencias.

## Fase 1 — MVP funcional y estable (sin animaciones)
- [ ] Barra superior cuyo grosor configurado permanece **constante** durante cada interacción.
- [ ] Detectar max/restauración y mostrar/ocultar controles de ventana según corresponda.
- [ ] Lanzador izquierdo para apps instaladas, distinguible del selector SO.
- [ ] Selector SO de una sola fila, expansión a izquierda, agrupación por aplicación y activación de ventanas.
- [ ] Contracción automática de SO después de seleccionar por defecto y preferencia de permanecer abierto.
- [ ] Bandeja horizontal compacta, flechas correctas y exclusividad con SO.
- [ ] Respetar fullscreen real; probar foco, maximización y pestañas de navegadores.
- [ ] Pruebas en CachyOS con Dolphin, Konsole, Brave y Firefox.

## Fase 2 — Navegación y ergonomía
- [ ] Desagrupar ventanas opcionalmente.
- [ ] Miniaturas al pasar el puntero y selector de ventanas agrupadas.
- [ ] Navegación de desbordamiento con rueda/touchpad/flechas.
- [ ] Modos SO contraído, expandido y adaptativo.
- [ ] Escritorios virtuales, configuraciones de clic derecho y preferencias.
- [ ] **Agarre horizontal compacto (tres/cuatro puntos) a la derecha de SO** para mover la isla 1. No cambia de posición al expandir/contraer bandeja o SO; validar límites, posición guardada y relación con los controles de ventana maximizada.

## Fase 3 — Herramientas secundarias
- [ ] Panel de calendario/notas y otras herramientas opcionales, flotantes debajo de la barra.
- [ ] Mejoras de accesibilidad y multi-monitor.
- [ ] Multimedia mediante MPRIS **solo cuando el núcleo esté estable**.

## Fase 4 — Temas y animaciones personalizables
- [ ] Temas, transparencia, colores individuales, blur y transiciones opcionales.
- [ ] Extensibilidad para animaciones decorativas sin bloquear controles, alterar foco o geometría.
- [ ] Pruebas de rendimiento y estabilidad entre distribuciones Plasma.

## Aclaración de alcance
El diseño **por islas separadas** es el predeterminado; isla 3 (buscador visible) está oculta por defecto. La prueba v0.1 no incluye aún el agarre de desplazamiento, que se implementará por etapas. El código debe conservar acceso a SO, bandeja y controles de ventana y no alterar el alto de la barra.

## Criterio de aceptación continuo
Las modificaciones nunca deben modificar la altura de la barra o de sus expansiones horizontales, reducir el espacio de la app para mostrar fichas, desplazar pestañas, violar fullscreen ni comprometer el control de ventanas.
