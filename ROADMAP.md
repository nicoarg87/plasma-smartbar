# Hoja de ruta de Plasma SmartBar Islands

> **Estado real (17/11/2026):** prototipo visual QML en rama experimental y diagnóstico independiente de **ventanas reales KDE probado en CachyOS**, con actualización dinámica de la lista. **SO todavía usa fichas simuladas; no hay versión instalable validada para uso diario.**
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
- [ ] **Contorno SO configurable por estado (actualización 16/11/2026):** cero ventanas → luz giratoria por defecto; una o más → contorno apagado por defecto; casillas independientes habilitan cada estado. Efecto apagado/fijo/luz móvil, color, grosor, movimiento, velocidad, cola y trazo. **Implementado en rama v0.1, falta prueba real y conexión a KDE TasksModel**. El temporizador se limita a los estados habilitados; revisar recursos y accesibilidad.
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


## Contorno SO invertido para buscar aplicaciones (16/11/2026)

- [x] Mostrar luz móvil en SO con **cero ventanas por defecto**; apagarla con ventanas abiertas salvo habilitación explícita.
- [x] Dos casillas independientes para mostrar contorno sin ventanas y con ventanas; «Efecto: Desactivado» apaga ambos.
- [x] Clic izquierdo en SO sin ventanas abre buscador de aplicaciones simulado; con ventanas conserva listado de tareas.
- [x] Conectar opciones en QML del botón, vista previa, centro Contorno, Main y KConfig; `soActivityStyle=orbit`, `soActivityShowWhenEmpty=true`, `soActivityShowWhenOpen=false` al restaurar valores.
- [ ] Probar en CachyOS con simulación 0/3, ambas casillas, off/fijo/móvil, clic izquierdo, Aplicar/Restablecer, cero consumo cuando está desactivado y fluidez.
- [ ] Validar el cambio cuando KDE TasksModel informe ventanas reales; el visor v0.1 no detecta apps abiertas verdaderas.


## Defaults para probar e interacción segura (16/11/2026)

- [x] SO cápsula horizontal (96 px de ensayo), imagen tropical predeterminada con modo Estirar; editor y visor tienen defaults y Restablecer coherentes.
- [x] Contorno de prueba 1,5 vueltas/s, 0,75 px, cola 75 %, guiones; **pendiente aprobación final** después de la prueba.
- [x] Soledad color provisional `#010111` y opacidad 50 %; bandeja y agarre heredan color/alfa o permiten valores independientes.
- [x] En visor, impedir que Malvina se revele por hover cuando se simula maximizada/fullscreen o la ventana Qt está así.
- [x] En applet sin KWin real, bloquear autoaparición por estado de ventana desconocido, como medida precautoria.
- [ ] Validar aspecto, selector de colores, guardar/restablecer y QML en CachyOS.
- [ ] Detectar estado real de KWin/Wayland, ventanas maximizadas y fullscreen, por pantalla; permitir autoaparición solo cuando no interfiera en juegos, videos y clics.
- [ ] Incorporar imagen binaria exacta al repositorio GitHub (por ahora está solo en ZIP adjunto).


## GIF tropical definitivo en SO (16/11/2026)

- [x] Recibir y verificar GIF original generado con ChatGPT (439×217, 16 cuadros, 140 ms c/u, SHA-256 `a10b34548abae1d3e699d5b92a23f38745b349f9cf73ebc59806fce6f56f5621`). El mantenedor dice que lo probó y funciona.
- [x] Reemplazar referencia predeterminada `assets/so-tropical.png` por `assets/so-tropical.gif` y activar reproducción en modo «Predeterminada» en visor y editor.
- [x] Preparar ZIP local con GIF original intacto en ruta de assets y registro de licencia CC0 (recurso gráfico independiente del código MIT).
- [ ] Incorporar **binario GIF exacto** al repositorio GitHub; ahora solo en ZIP adjunto al chat.
- [ ] Probar carga del **GIF como Predeterminada** en CachyOS y confirmación de Estirar, cápsula horizontal, pausa, zoom y uso de recursos; no reemplazar panel existente.


## Reloj SO y recuperación de Malvina en visor (16/11/2026)

- [x] Mostrar hora/fecha temporal dentro de SO tras 180 ms de hover en agarre de seis puntos, mantener 3 s y volver al GIF sin alterar posición, tamaño ni gestos.
- [x] Agregar fuente, tamaño y color configurables en pestaña «Logo SO», restablecimiento y KConfig.
- [x] Corregir error del visor: maximizar **la propia ventana de prueba** no debe activar bloqueo de Malvina; solo simulaciones de aplicación max/fullscreen o fullscreen del visor.
- [x] Agregar diagnóstico visible que distinga Malvina bloqueada/deshabilitada/esperando hover y advertencia en lanzador cuando falta GIF.
- [ ] Probar reloj, colores/fuentes, arrastre y restauración del GIF; probar hover de Malvina en visor normal y maximizado con simulación desactivada.
- [ ] Integrar estado real de aplicaciones ajenas mediante KWin/Wayland. Mientras no esté, el plasmoide experimental bloquea autoaparición.
- [ ] Incluir binario GIF original en GitHub; por ahora se requiere ZIP adjunto.


## Prueba de conexión de solo lectura con KDE TasksModel (17/11/2026)

- [x] Ejecutar por primera vez el diagnóstico `probar_ventanas.sh` en CachyOS: **falló por siete declaraciones QML `required property` con mayúscula** antes de cargar el modelo.
- [x] Corregir en `preview_ventanas_reales.qml` usando `required property var model` y roles `model.AppName`, etc. ([commit 486db01](https://github.com/nicoarg87/plasma-smartbar/commit/486db01dc1930129d96c1b8cbd79878df477b3a1)); revisión estática de sintaxis y bindings.
- [x] **PROBADO en CachyOS 17/11/2026:** `bash prototype/v0.1/probar_ventanas.sh` carga y detecta ventanas reales; el mantenedor confirma que la lista cambia al abrir y cerrar aplicaciones (Alacritty, Brave y qml6 en captura).
- [ ] Tras prueba positiva, empezar el enlace de solo lectura de tareas reales con SO; no conectar acciones de cerrar/activar ni instalar el panel antes de validar.

- [ ] Conectar el mismo modelo en modo solo lectura al listado de fichas SO del visor experimental, sin tocar el panel CachyOS.
- [ ] Comprobar agrupación real de dos o más ventanas de una aplicación, ancho de una sola fila y estabilidad del bloque SO al actualizar tareas.
- [ ] Solo tras pruebas positivas, implementar activación/minimización por etapas, con pruebas KWin/Wayland de foco y fullscreen.


## SO con ventanas reales: primera integración aislada (17/11/2026)

- [x] Implementar `realTaskModel` opcional en `SmartBarContent.qml`, manteniendo su simulación previa sin cambios cuando el modelo real no está conectado.
- [x] Agregar en visor Qt un selector «Usar ventanas reales de KDE en SO (solo lectura)», con `TaskManager.TasksModel` y agrupación por aplicación.
- [x] Dibujar las fichas reales en el mismo `Row` de SO, contador real y etiquetas de agrupación; los clics **no activan ni cambian ventanas**. KConfig y `main.qml` permanecen sin integración real.
- [x] Revisar estáticamente referencias QML/roles y ausencia de comandos sobre ventanas.
- [ ] **PRUEBA DEL MANTENEDOR EN CACHYOS:** ejecutar `bash prototype/v0.1/probar_ancho.sh`, activar la casilla de tareas reales, expandir SO y comprobar altas/bajas y agrupación con varias ventanas de una misma app.
- [ ] Medir comportamiento cuando la suma de fichas excede el ancho útil de Soledad; evitar solapamiento o desplazar ventanas/pestañas y definir tratamiento de exceso sin cambiar requisitos.
- [ ] Recién después de validar el modo lectura, considerar selección/activación de ventanas reales en una segunda fase y con KWin/Wayland.

## Corregir superposición del reloj en SO (17/11/2026)

- [x] Mantener cargado y reproduciéndose el GIF de SO al mostrar hora/fecha.
- [x] Quitar rectángulo opaco del reloj; mostrar caracteres sobre la foto con contorno para legibilidad.
- [x] Disminuir tamaño inicial de hora de 16 px a 11 px, ajustar fecha, conservar tipografía/tamaño/color configurables y restablecimiento coherente.
- [x] Mantener gesto de 180 ms sobre seis puntos y desaparición **solo del texto** tras tres segundos.
- [ ] **Probar visualmente en CachyOS** continuidad del GIF sin reinicio, legibilidad, fuentes alternativas, restablecer y que el texto no sobresalga de la cápsula.

## Modularidad, mantenibilidad y seguridad (aprobado 17/11/2026)

- [x] Formalizar responsabilidad unica, contratos Qt/QML, bajo acoplamiento, validacion, permisos minimos, pruebas aisladas y gobernanza en [docs/ARQUITECTURA_MODULAR.md](docs/ARQUITECTURA_MODULAR.md).
- [x] Separar la politica de URL de Malvina en `MalvinaUrlPolicy.js`; delegar desde `MalvinaSearch.qml` y definir cierre del buscador existente.
- [ ] Probar politica URL, navegador KDE predeterminado, Web/IA, Tab/Shift+Tab/Enter/Esc y configuracion en el visor aislado CachyOS.
- [ ] Desacoplar el formulario Malvina de propiedades internas de Soledad conservando la unica entrada a preferencias.
- [ ] Extraer progresivamente componentes de `SmartBarContent.qml` y `SoledadSettings.qml`, con contratos claros y retest en cada etapa.
- [ ] Automatizar verificaciones estaticas y unitarias de politicas puras; medir memoria, CPU, repintado e inicializacion antes/despues.
- [ ] Investigar atajo global Super+Espacio y seleccion de navegador en KWin/Wayland, sin ejecutar comandos de shell fabricados con la consulta.
- [ ] Mantener lectura KDE de solo lectura, fullscreen y controles/pestanas como tareas independientes pendientes de validacion.

## Selector Malvina por teclado (17/11/2026)

- [x] Implementar Google predeterminado y Enter para buscar con proveedor elegido.
- [x] Tab y Mayus+Tab recorren los seis proveedores Web/IA.
- [x] Espacio/clic elige proveedor sin lanzar la URL; retorna al texto conservado.
- [ ] Validar foco y secuencia Tab → Espacio → escritura → Enter en visor Qt real de CachyOS, incluyendo Shift+Tab, Esc y cambios repetidos de proveedor.
- [ ] Revisar accesibilidad visual del proveedor enfocado en popup y comportamiento de atajos con lector de pantalla.

## Retest del selector Web/IA de Malvina (17/11/2026)

- [x] Registrar fallo observado: Tab no desplazaba el foco a fila Web/IA al buscar «cerveza».
- [x] Reemplazar paso de foco a Popup por navegación por filas con foco real en campo y resaltado explícito (`▶ Web`, `▶ IA`).
- [ ] Retest en CachyOS: texto «cerveza», Tab Web, Tab IA, flechas, Espacio para elegir, Enter para abrir, Mayús+Tab y Esc; verificar que no se borre la búsqueda.

## Consentimiento explícito para envío IA desde Malvina (confirmado 17/11/2026)

- [x] Definir que no se usa `sudo`: permisos propios de Malvina, específicos por proveedor, apagados por defecto, revocables e informados.
- [ ] Diseñar texto accesible de autorización: datos enviados, destino, momento, terceros y modo de retirar permiso, sin casillas premarcadas.
- [ ] Verificar integraciones oficiales por proveedor y distinguir enlaces de chats web vs API con credenciales/costos.
- [ ] Implementar preferencias persistentes y control estricto de envío solo en Enter y solo con autorización vigente.
- [ ] Pruebas negativas: sin permiso nunca se transmite; selección Tab/Espacio nunca transmite; revocar bloquea la siguiente consulta.
- [ ] Validar en CachyOS el flujo completo y cualquier uso futuro de KWallet/secretos, antes de etiquetar la función como disponible.
