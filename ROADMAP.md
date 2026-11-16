# Hoja de ruta de Plasma SmartBar Islands

> **Estado real:** documentación disponible. **No hay aún código funcional ni versión instalable.**
> Las etapas se subordinan a la [Constitución técnica](docs/CONSTITUCION_TECNICA.md).

## Fase 0 — Fundamentos y organización
- [x] Abrir repositorio público para Linux con KDE Plasma.
- [x] Establecer constitución, Manual Maestro y gobernanza; licencia inicial GPL-3.0, **relicenciamiento del código propio a MIT aprobado el 16/11/2026**.
- [x] Redactar reglas de contribución y visión inicial.
- [x] Activar regla de protección de rama main (bloqueo de borrado y force push; confirmado 14/11/2026).
- [ ] Revisar periódicamente colaboradores autorizados y evaluar exigencia de PRs cuando haya equipo.
- [ ] Investigar qué piezas de Plasma/KWin/Qt pueden reutilizarse y bajo qué licencias.

- [x] Documentar separación entre licencia MIT del código y licencia de recursos gráficos (CC0 1.0 previsto para imagen tropical de OpenAI, aún falta recuperar su archivo exacto). No incluir logo Golden Dog de procedencia no verificada.
- [ ] Integrar imagen tropical original cuando esté disponible y registrar integridad/autoría; no usar sustitutos visuales como si fueran el original.
- [ ] Retest en CachyOS de forma única del botón SO (figuras normales y anchas) y ajuste `Estirar` + zoom y desplazamiento sin reescribir la imagen.

## Fase 1 — MVP funcional y estable (sin animaciones)
- [ ] **Modo superior predeterminado**, con islas separadas, cuyo grosor configurado permanece **constante** durante cada interacción. Diseñar la base de estados y vistas para permitir cambiar de orientación más adelante sin reescribir la gestión de ventanas.
- [ ] Detectar max/restauración y mostrar/ocultar controles de ventana según corresponda; **anclarlos al extremo derecho de manera independiente de isla 1**, sin seguir el arrastre de SO.
- [ ] Lanzador izquierdo para apps instaladas, distinguible del selector SO.
- [ ] **SO doble gesto:** clic breve ventanas abiertas; pulsación sostenida de ~400 ms abre lanzador flotante de **apps instaladas**, sin clic corto al soltar. La v0.1 solo simula este menú. Pendiente de prueba en CachyOS y de usar catálogo real de apps.
- [ ] **Nombres de islas confirmados:** Soledad = isla 1 principal, Malvina = isla 2; evaluar con autorización explícita antes de renombrar el proyecto entero o repositorio. El botón SO mantiene su etiqueta actual.
- [ ] **Isla 2 opcional:** permanece visible por defecto; clic derecho para ocultar y menú contextual de SO para mostrar de nuevo, con preferencia KConfig `showLauncherIsland=true`. Código de maqueta publicado, pendientes persistencia y prueba.
- [ ] **Ocultación automática de isla 2 — PROPUESTA:** definir disparador, forma de recuperación y accesibilidad antes de aprobar/implementar. No activada por defecto.
- [ ] Selector SO de una sola fila, expansión a izquierda, agrupación por aplicación y activación de ventanas.
- [ ] Contracción automática de SO después de seleccionar por defecto y preferencia de permanecer abierto.
- [ ] **Separador visual entre bandeja y SO:** línea vertical fina solo cuando ambas expansiones estén abiertas; sumarla a la medición horizontal y ocultarla al contraer un grupo. Implementada en maqueta QML, **pendiente de prueba**.
- [ ] **Clic breve SO cierra solo el popup flotante si está abierto:** preservar fichas SO y bandeja desplegadas; sin popup visible, SO conserva el cierre/apertura normal de ventanas. Arreglo en PR #3, **pendiente de retest en CachyOS**.
- [ ] **Lanzador SO flotante sin cerrar expansiones:** con SO y bandeja visibles, mantener SO ~400 ms abre menú bajo Soledad **sin contraer ninguna expansión**. El mismo principio rige al abrir desde Malvina. Código corregido en PR #3, **pendiente de prueba en CachyOS**; mantener reglas separadas de capacidad y autocontracción por selección.
- [ ] **Lanzador propio de Malvina:** clic en Malvina abre menú flotante **debajo de Malvina**, no de Soledad; SO sostenido mantiene su menú debajo de su posición actual. Implementado reutilizando popup con origen explícito, **pendiente de prueba**.
- [ ] **Soledad y bandeja simultáneas según espacio:** SO y bandeja conservan sus fichas visibles juntos cuando caben, en una fila. Si no entran, al abrir uno se contrae el otro; si se estrecha la ventana o se mueve Soledad, conservar la última expansión solicitada. **Maqueta QML implementada, todavía no probada en CachyOS**.
- [ ] **Autocontracción independiente por configuración:** SO al elegir ventana (predeterminado activado); bandeja al usar icono (predeterminado desactivado). Clic en seis puntos → Configuración de autocontracción. La v0.1 simula selección, y KConfig está declarado; **pendiente de prueba y de integrar comportamiento real seguro**.
- [ ] **Cerrar menú de agarre también con clic izquierdo breve:** con opciones abiertas, izquierdo breve sobre los seis puntos las cierra; con menú cerrado izquierdo no abre nada y sigue permitiendo arrastrar. Apertura por derecho **probada en CachyOS**; cierre izquierdo programado en QML, **pendiente de prueba**.
- [ ] **Gesto del agarre separado de configuración:** clic izquierdo / arrastre mueve Soledad **sin abrir menús**; clic derecho abre/cierra opciones con pulsaciones sucesivas; teclado Menú o Mayús+F10 conserva acceso. Implementado en PR #3, **pendiente de prueba en CachyOS**; sustituye apertura de opciones por clic izquierdo.
- [ ] **Recuperación de Malvina desde opciones del agarre:** clic derecho en los **seis puntos de Soledad** → primera acción «Mostrar Malvina (isla 2)» cuando esté oculta; pasa a «Ocultar Malvina» cuando esté visible. Programado en maqueta v0.1, **pendiente de prueba en CachyOS**. No agregar botón permanente.
- [ ] **Recuperar Malvina fácilmente:** si se oculta la isla 2, mantener SO y pulsar una vez «Mostrar Malvina (isla 2)». Acceso agregado en maqueta QML, **pendiente de prueba**; se conserva el menú contextual de SO.
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


## Personalización visual de SO e islas — mejoras confirmadas (14/11/2026)

- [ ] **Logo de SO personalizado:** huella PNG predeterminada o imagen fija/GIF elegida por usuario; modo texto SO, posibilidad de branding de distribuciones. Editor para escala, encuadre no destructivo y recorte **cuadrado/círculo/rombo/corazón/estrella**; aplicar el mismo recorte a GIF. **Implementado en código de PR #3, pendiente de prueba en CachyOS y persistencia en Plasma**. [Issue #5](https://github.com/nicoarg87/plasma-smartbar/issues/5).
- [ ] **Color y opacidad de cada isla:** Soledad y Malvina independientes; **fondo general opcional** con color/transparencia y desactivado por defecto. El fondo no cambia altura ni controles; la antigua isla 3 buscadora sigue reservada, numeración del fondo pendiente de decisión explícita.
- [ ] **Contorno SO por ventanas abiertas:** **cero ventanas → sin trazo y sin temporizador**; una o más → efecto opcional off/fijo/luz recorriendo perímetro de la máscara, color ajustable, grosor 0,5–2 px, movimiento opcional. Brillo fijo predeterminado. Demo con alternancia 0/3 ventanas; **conexión al modelo KDE de ventanas reales pendiente de prueba**. Consumo/performance y accesibilidad pendientes.
- [ ] **No introducir animaciones generales de barra:** GIF elegido y contorno SO animado optativo son excepciones explícitas limitadas; nada de MPRIS, animaciones de fichas ni de minimización en MVP.


## Geometría editable, rotación y Acerca de (15/11/2026)

- [ ] Botón SO ancho configurable con formato cuadrado, rectángulo recto, redondeado, cápsula y óvalo; mantener una sola máscara/contorno y la fila horizontal.
- [ ] Altura global elegida por usuario (48 por defecto, constante mientras se expanden las islas), altos/anchos/radios de Soledad y Malvina independientes dentro del espacio. Verificar limitaciones del contenedor Plasma al solicitar altura de panel real.
- [ ] Rotar foto/GIF con control de −180° a +180° sin modificar fuente, manteniendo recorte y contorno coherentes.
- [ ] Pestañas reordenadas Logo → Contorno → Apariencia → Islas y posición → Autocontracción → Acerca de. Las cinco configurables tienen Restablecer; Aplicar guarda sin cerrar.
- [ ] **Acerca de (prueba pendiente):** autor público nicoarg87, correo para consultas **nicoarg87@gmail.com** (autorizado), licencia GNU GPL v3 con enlace al LICENSE oficial y aviso **SIN NINGUNA GARANTÍA**. Código en PR #3; verificar apertura de cliente de correo y legibilidad en CachyOS. **PayPal y Cafecito se posponen**; sin links ni botones de donaciones.
- [ ] Validar todos los cambios en CachyOS/Wayland usando exclusivamente ventana de prueba Qt; PR #3 y issues #1/#5 abiertos. Iconos personalizados del agarre y bandeja e isla extra siguen diferidos.

## Terminaciones por isla y orden de Acerca de — validar en CachyOS (15/11/2026)

- [ ] **Geometría predeterminada nueva:** Soledad redondeada izquierda / recta derecha y agarre cuadrado. Alternar Soledad entre redondeada, cuadrada, ambas mixtas y punta triangular izquierda (experimental); Malvina entre redondeada, cuadrada y ambas mixtas; agarre y flecha de bandeja cuadrado/redondeado. `Restablecer` vuelve a defaults. Verificar gesto de arrastre y barra fija.
- [ ] **Acerca de:** correo autorizado `nicoarg87@gmail.com`, repositorio GitHub inmediatamente debajo del contacto, licencia GNU GPL v3 y aviso SIN NINGUNA GARANTÍA por debajo. Verificar botones con teclado, sin donaciones.
- [ ] **Compatibilidad:** probar esquinas individuales de QtQuick Rectangle (Qt 6.7+, `tech preview` en Qt 6.8), Canvas triangular y ancho de isla con SO y bandeja abiertos. PR #3 experimental, issues #1/#5 abiertos; no modificar panel KDE en uso.

## Centro de configuración de Soledad en pestañas — decisión confirmada (14/11/2026)

- [ ] **Una ventana con seis pestañas (orden actual):** Logo SO, Contorno, Apariencia, Islas y posición, Autocontracción y Acerca de. Entrada única «Configuración de Soledad…» en el menú de los seis puntos. Código publicado en [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) con nuevo componente SoledadSettings.qml; **sin retest en CachyOS**. Verificar que no se instancien tres ventanas de personalización separadas.
- [ ] **Aplicar no cierra:** persistir preferencias de todas las pestañas al pulsar «Aplicar» y mantener la ventana abierta. «Cerrar» es un botón independiente, siempre visible. En la ventana Qt independiente los valores solo viven durante la sesión; validar KConfig real después.
- [ ] **Tamaño usable:** dimensión inicial que permita el contenido de logo (la pestaña más alta) y límites de pantalla; pestañas y controles con desplazamiento para evitar opciones ocultas en resoluciones menores. No modificar grosor de la barra al configurar.
- [ ] **Preferencias intactas:** autocontracción SO/bandeja separada, colores por isla, contorno condicional, visibilidad Malvina, alineación y retorno a la derecha. «Mover a la derecha AHORA» mantiene su acción inmediata. Comprobar que Aplicar no alinee Soledad si la casilla no se cambió.
- [ ] **Idea diferida:** posible botón «Añadir isla extra» (mencionado por el mantenedor, NO desarrollar ahora). No sustituir ni renumerar isla 3 buscadora existente, ni definir el comportamiento de otra isla sin decisión posterior.

**Siguiente prueba reversible:** rama `prototype/v0.1-islas-so`; `git pull` y `bash prototype/v0.1/probar_ancho.sh` con la ventana aislada; verificar las seis pestañas, aplicar sin cerrar, tamaño en pantalla pequeña, cerrar, colores/logo/GIF y opciones de comportamiento. Seguir documentando en issues #1 y #5, sin tocar el panel de KDE instalado.

## Nueva prueba: Malvina autooculta y logo tropical (16/11/2026)

- [x] Autoocultamiento de Malvina por defecto en rama v0.1, aparición tras hover 600 ms y ocultamiento tras salida 250 ms; opción para desactivar en Configuración.
- [x] Imagen tropical original adjuntada en ZIP de prueba, referencia predeterminada de SO en QML.
- [ ] Confirmar el comportamiento en el visor Qt de CachyOS y revisar la persistencia KConfig.
- [ ] Verificar en KWin/Wayland que el área oculta no dificulta clics sobre pestañas de ventanas subyacentes; el detector QML no garantiza transferencia de clics entre ventanas.
- [ ] Incorporar el PNG original al repositorio (ahora está solo en ZIP adjunto a la conversación).

## Contorno SO con parámetros de luz móvil (16/11/2026)

- [x] Control numérico de velocidad de la luz móvil (0,1–3,0 vueltas/s, paso 0,1; inicial 1,0) en «Contorno».
- [x] Longitud editable de la cola, 5–85 % del perímetro, inicial 22 %.
- [x] Estilo del trazo: continuo, punteado y guiones, para la luz móvil.
- [x] Cableado a vista previa de SO, aplicación de cambios, «Restablecer contorno» y KConfig en rama experimental v0.1.
- [ ] Probar en CachyOS con cero y varias ventanas simuladas, el cambio de velocidad, formas geométricas y trazo; verificar persistencia y coste de repintado.
