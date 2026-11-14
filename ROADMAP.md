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
- [ ] **Modo superior predeterminado**, con islas separadas, cuyo grosor configurado permanece **constante** durante cada interacción. Diseñar la base de estados y vistas para permitir cambiar de orientación más adelante sin reescribir la gestión de ventanas.
- [ ] Detectar max/restauración y mostrar/ocultar controles de ventana según corresponda; **anclarlos al extremo derecho de manera independiente de isla 1**, sin seguir el arrastre de SO.
- [ ] Lanzador izquierdo para apps instaladas, distinguible del selector SO.
- [ ] Selector SO de una sola fila, expansión a izquierda, agrupación por aplicación y activación de ventanas.
- [ ] Contracción automática de SO después de seleccionar por defecto y preferencia de permanecer abierto.
- [ ] Bandeja horizontal compacta, flechas correctas y exclusividad con SO.
- [ ] Respetar fullscreen real; probar foco, maximización y pestañas de navegadores.
- [ ] Pruebas en CachyOS con Dolphin, Konsole, Brave y Firefox.

## Validación del segundo modo oficial — borde inferior
- [ ] Investigar y desarrollar el **modo inferior** como opción configurada, conservando isla 2 a la izquierda, isla 1 a la derecha, expansión en una fila y grosor constante.
- [ ] Mostrar los **controles SmartBar para la ventana maximizada en el borde inferior**, **fijos en el extremo derecho y separados del arrastre de isla 1**, no en una barra separada arriba.
- [ ] Investigar conflictos con controles originales de las aplicaciones (KWin, Brave/Firefox/Chrome, Steam, Qt/GTK). **No asumir que KWin puede trasladar universalmente las decoraciones originales**.
- [ ] Subpaneles flotan hacia el interior: **hacia arriba** cuando la barra está abajo; fullscreen real oculta todo.
- [ ] Validar en CachyOS sin reemplazar el panel principal ni alterar las ventanas. Issue de investigación: [#2](https://github.com/nicoarg87/plasma-smartbar/issues/2).

## Fase 2 — Navegación y ergonomía
- [ ] Desagrupar ventanas opcionalmente.
- [ ] Miniaturas al pasar el puntero y selector de ventanas agrupadas.
- [ ] Navegación de desbordamiento con rueda/touchpad/flechas.
- [ ] Modos SO contraído, expandido y adaptativo.
- [ ] Escritorios virtuales, configuraciones de clic derecho y preferencias.
- [x] **Agarre horizontal compacto (seis puntos, 2 × 3) a la derecha de SO** redactado en la maqueta QML de la rama experimental v0.1; permite arrastrar la isla 1 **solo dentro de la vista previa**, aún sin ejecutar ni verificar en CachyOS.
- [ ] Conectar el agarre al estado **real** de maximización en KWin/Wayland, validar límites, compatibilidad, varios monitores, y estabilidad al expandir SO/bandeja.
- [ ] **Retorno automático a la derecha al desmaximizar**, activado y guardado por defecto con opción de desactivarlo. La maqueta simula la transición y declara KConfig; verificar persistencia real en Plasma.
- [x] **Ancho adaptable en vista Qt independiente:** en CachyOS, el mantenedor confirmó que las islas siguen los bordes al redimensionar la ventana. Captura anterior de 1920 px lógicos. **Esto no valida todavía el applet dentro de Plasma**.
- [ ] **Ancho en contenedor Plasma:** investigar la asignación de geometría de `plasmoidviewer`, que NO crecía con su ventana aun con `Layout.fillWidth`; probar en un contenedor aislado, sin reemplazar el panel existente. Mantener grosor fijo y fondo transparente entre islas.
- [ ] **Alineación directa de isla 1:** casilla «Alinear a la derecha» tildada por defecto, **destildada automáticamente al arrastrar** y con retorno inmediato al volver a tildarla. Programada en rama v0.1, **pendiente de validar en CachyOS**. Es independiente de la opción de regreso al desmaximizar y de los perfiles por aplicación.

## Fase 3 — Herramientas secundarias
- [ ] Panel de calendario/notas y otras herramientas opcionales, flotantes debajo de la barra.
- [ ] Mejoras de accesibilidad y multi-monitor.
- [ ] Multimedia mediante MPRIS **solo cuando el núcleo esté estable**.

## Perfiles por aplicación — requisito funcional confirmado (no implementado)
- [ ] Detectar aplicación de la ventana **activa y maximizada** con identificador estable en Plasma/KWin.
- [ ] **Clic derecho sobre isla 1 → «Recordar esta posición para [aplicación]»**: guardar y recuperar el desplazamiento horizontal al activar/maximizar ese programa. Mostrar opciones de modificar/eliminar perfil.
- [ ] Perfiles por app prevalecen al estar la ventana activa/maximizada; al desmaximizar rige retorno automático global a la derecha, activado por defecto. Sin perfil usar posición predeterminada.
- [ ] Validar Steam, Dolphin, Brave, persistencia, múltiples ventanas/monitores, límites de pantalla, sin mover controles fijos ni alterar grosor. [Issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4).
- [ ] Investigar **solo** alineación visual respecto a barras de título de apps. No adaptar altura automáticamente según aplicación sin nueva aprobación; grosor común configurable permanece constante.

## Arquitectura extensible; laterales solo experimentales
- [ ] Separar lógica de tareas, presentación, posicionamiento/anclaje y orientación. Evitar suposiciones de coordenadas superiores en la lógica compartida.
- [ ] **No prometer soporte oficial vertical izquierdo/derecho en las versiones iniciales**. Mantener posibilidad de pruebas y forks futuros sin sobrecargar el MVP.

## Fase 4 — Temas y animaciones personalizables
- [ ] Temas, transparencia, colores individuales, blur y transiciones opcionales.
- [ ] Extensibilidad para animaciones decorativas sin bloquear controles, alterar foco o geometría.
- [ ] Pruebas de rendimiento y estabilidad entre distribuciones Plasma.

## Aclaración de alcance
El diseño **por islas separadas** es el predeterminado; isla 3 (buscador visible) está oculta por defecto. La prueba v0.1 **incluye ya un agarre arrastrable de demostración**, sin conexión a las ventanas de KWin; el movimiento real y sus pruebas siguen pendientes. El código debe conservar acceso a SO, bandeja y controles de ventana y no alterar el alto de la barra.

## Criterio de aceptación continuo
Las modificaciones nunca deben modificar el grosor de la barra o de sus expansiones horizontales, reducir el espacio de la app para mostrar fichas, desplazar pestañas, violar fullscreen ni comprometer el control de ventanas. En orientación inferior los controles propios de SmartBar deben ubicarse abajo, junto a SO; la interacción con decoraciones originales necesita comprobación técnica.
