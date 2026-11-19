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

## Integración de buscadores con IA y sesión del navegador (17/11/2026)

- [x] Registrar que buscadores Web pueden ofrecer IA propia, distinta del envío directo al chat autorizado en Malvina.
- [x] Confirmar que autenticación web corresponde al usuario y no habilita acceso de Malvina a contraseñas, cookies o sesión.
- [ ] Verificar por proveedor si hay mecanismo compatible para abrir conversación web con texto sin automatizar el navegador ni capturar sesiones.
- [ ] Distinguir claramente «abrir sitio» de «enviar consulta al chat» en la interfaz y pruebas; con ausencia de compatibilidad, no enviar automáticamente.

## Atajo local y global de Malvina (17/11/2026)

- [x] Identificar que Meta+Espacio ya estaba declarado como Qt.WindowShortcut, no global.
- [x] Evitar que focusSearch() abra popup de proveedores al invocar atajo local; Tab abre selección.
- [ ] Retest del visor Qt en CachyOS: Meta+Espacio solo campo, Tab Web/IA, Enter búsqueda, Esc cierra.
- [ ] Investigar KGlobalAccel/KF6 para un atajo global configurable desde cualquier ventana, respetando atajos existentes y fullscreen.

## Cierre por clic exterior de Malvina (17/11/2026)

- [x] Implementar cierre de campo y herramientas por clic fuera dentro del visor, sin MouseArea que absorba controles de Soledad.
- [x] Aplicar cierre del popup por clic exterior y por pérdida de actividad de la ventana Qt.
- [ ] Retest CachyOS: clic dentro de buscador/popup, fuera en fondo/SO, sobre otras aplicaciones, Tab/Espacio/Enter/Esc, autoocultamiento activo e inactivo.
- [ ] Validar comportamiento externo real en KWin/Wayland y ausencia de consumo de clics ajenos antes de instalar como plasmoide.

## Ajustes de navegador y permisos IA en Malvina (17/11/2026)

- [x] Incorporar casillas explícitas ChatGPT, Gemini y Claude con valores falsos por defecto, explicación informada y revocación al Aplicar.
- [x] Conectar permisos a SoledadSettings, SmartBarContent, KConfig/main.qml y visor local sin habilitar tráfico de consultas.
- [x] Mostrar navegador predeterminado KDE como opción efectiva; evitar mostrar selección de navegador particular que todavía no funciona.
- [ ] Probar preferencias y persistencia real en CachyOS, incluyendo revocación, scroll, reabrir ajustes y reinicio del visor.
- [ ] Implementar cuando esté verificada la integración nativa la elección segura de navegador alternativo, sin shell construido con texto del usuario.
- [ ] Investigar por proveedor el envío compatible a chat y agregar pruebas de consentimiento antes de habilitar cualquier transmisión.

## Preferencias Malvina implementadas en código (17/11/2026)

- [x] Añadir opciones de habilitación individual de Web (Google, DuckDuckGo, Yahoo, activas inicialmente).
- [x] Añadir casillas informadas y revocables IA (ChatGPT, Gemini, Claude, desactivadas inicialmente).
- [x] Conectar las seis preferencias a Aplicar, KConfig y persistencia local del visor; impedir búsqueda Web en proveedor deshabilitado.
- [x] Mostrar navegador predeterminado KDE como opción operativa, sin ofrecer ejecución insegura de navegadores alternativos.
- [ ] Probar en CachyOS configuración, botones Web deshabilitados, selección por teclado, guardar/reabrir/reiniciar y consentimiento IA sin envío.
- [ ] Resolver caso de todos los buscadores Web deshabilitados con una indicación visible y accesible al usuario.
- [ ] Investigar selección segura de navegador específico con integración nativa KF6/KDE, sin comandos shell desde texto.
- [ ] Implementar envío a chat solo tras verificar compatibilidad del proveedor y mecanismo de consentimiento efectivo.

## Ensayo de integración de ChatGPT, Gemini y Claude con consentimiento (17/11/2026)

- [x] Conectar permisos guardados con `MalvinaSearch`, antes desconectados.
- [x] Añadir política URL experimental `?q=` solo para las tres bases oficiales y usuarios que autorizaron el proveedor.
- [x] Advertir que un enlace puede precargar, ignorar o enviar texto, sin garantía oficial universal.
- [x] Agregar pruebas estáticas automatizables de URL, permiso apagado, dominio no oficial y codificación.
- [ ] Ejecutar tests Node y visor Qt en CachyOS. Comprobar cada proveedor con permiso activo y desactivado; registrar resultados reales.
- [ ] Determinar si `q` precarga/autoenvía/ignora según navegador y sesión; si no funciona, deshabilitar el ensayo por proveedor y diseñar alternativa oficialmente compatible.
- [ ] Comprobar que solo Enter abre la URL y que no hay filtración durante escritura, Tab o Espacio.

## Gemini — corrección tras prueba fallida (17/11/2026)

- [x] Registrar prueba del mantenedor: Gemini autorizado no recibía consulta desde Malvina.
- [x] Investigar: `?q=` no está documentado como interfaz web nativa compatible; depender de extensiones de terceros no es solución obligatoria.
- [x] Desactivar `q` de Gemini aunque tenga permiso, abrir página sin consulta y mostrar aviso honesto en Configuración.
- [x] Ajustar pruebas automatizadas para impedir `q` accidental con permiso Gemini.
- [ ] Retest Node y CachyOS para validar mitigación y conservar navegación Web/IA.
- [ ] Investigar alternativa oficial para precargar chat Gemini y validar permisos específicos antes de proponer implementación.

## Claude — prueba positiva con autenticación (17/11/2026)

- [x] Registrar que el mantenedor probó Claude desde Malvina: el enlace experimental funciona **después de iniciar sesión con una cuenta registrada**.
- [ ] Comprobar persistencia del resultado con sesión abierta, ingreso sin sesión y nueva autenticación.
- [ ] Verificar revocación del permiso Malvina y ausencia de consulta en URL cuando esté desautorizado.
- [ ] Determinar si la página precarga o envía automáticamente, sin presumir un comportamiento no informado por la prueba.
- [ ] Mantener la integración clasificada como experimental hasta validar compatibilidad más amplia.

## Etiquetas descriptivas personalizadas por proveedor (17/11/2026)

- [x] Permitir editar y almacenar nombre visible independiente para Google, DuckDuckGo, Yahoo, ChatGPT, Gemini y Claude.
- [x] Usar etiquetas configuradas en las filas Web e IA, con nombres predeterminados y validación de longitud y vacío.
- [x] Persistir nombres en KConfig y preferencias locales del visor sin alterar permisos ni validación de URL.
- [ ] Ejecutar visor en CachyOS, probar renombrado, Aplicar, reabrir y reiniciar; verificar Tab/flechas/Espacio/Enter.
- [ ] Verificar visualización de etiquetas largas en una sola fila sin alterar altura de isla y accesibilidad con lector de pantalla.
- [ ] Tratar la incorporación/eliminación de nuevos proveedores como otro requisito y preservar seguridad por identificador, no nombre de presentación.

## Malvina — campo de búsqueda y edición de consultas largas (17/11/2026)

- [x] Ajustar visualmente campo: tipografía normal de 14 px y centrado vertical.
- [x] Incorporar X contextual para borrar consulta completa.
- [x] Programar Mayús+Enter para nueva línea, Enter para ejecutar, y popup editor para texto largo o pegado, hasta 220 px con scroll.
- [x] Ocultar cursor de escritura al navegar con Tab por Web/IA y recuperarlo al confirmar Espacio o clic.
- [x] Conservar altura de isla constante y mostrar selector bajo editor flotante.
- [ ] Probar QML real en CachyOS: alineación, editor multilinea, Ctrl+V, Tab/Espacio/clic, Enter, X, Esc, clic fuera, cambios de tamaño/escala y compatibilidad con Popup.
- [ ] Confirmar con prueba que el editor largo no cubra incorrectamente contenido o se recorte cerca del límite de pantalla; ajustar geometría en función de espacio disponible, sin redimensionar barra.
- [ ] Registrar las verificaciones de Google como comportamiento del sitio, sin intentar eludir captchas ni exigir autenticación desde Malvina.

## Reemplazo del editor duplicado de Malvina (17/11/2026)

- [x] Eliminar segundo Popup de edición: conservar **un solo campo** en todo momento.
- [x] Permitir crecer hacia abajo con Mayús+Enter/texto largo y hacia derecha hasta media pantalla (máximo provisional 520 px) sin cambiar grosor de barra.
- [x] Mantener X siempre dentro del extremo derecho de la superficie de escritura cuando exista texto.
- [x] Conservar Tab hacia Web/IA, flechas, Espacio para elegir y Enter para buscar; ajustar detector de clic exterior.
- [ ] Retest en CachyOS: verificar único campo visible, X, salto de línea, Ctrl+V largo, Enter, selector, clic exterior, control de foco y ausencia de choque con Soledad.
- [ ] Revisar el límite 520 px con pantallas pequeñas/grandes, anchos configurados y comportamiento KWin/Wayland real antes de cerrar este hito.

## Corregir superficie interactiva del campo expansible Malvina (17/11/2026)

- [x] Registrar fallos probados: ancho no crece y clics atraviesan renglones inferiores.
- [x] Reemplazar superficie desbordada fuera del Item por un único TextArea en Popup no modal superpuesto sobre el campo original, sin duplicación.
- [x] Dar ancho máximo disponible al comenzar a escribir, con presupuesto de media pantalla que incluye botones.
- [ ] Retest Qt/CachyOS de todo el campo extendido: clic final y selección, escritura de múltiples líneas, X, Tab Web/IA, Espacio, Enter, clic exterior y límite Soledad.
- [ ] Confirmar interacción y forma visual exacta antes de cerrar el fallo.

## Prioridad y orden modular de Web/IA (17/11/2026)

- [x] Implementar inversión de filas Web/IA por rótulo y por botón en preferencias.
- [x] Programar arrastre horizontal de los tres proveedores dentro de cada fila.
- [x] Definir primer elemento habilitado de fila superior como default al abrir búsqueda.
- [x] Persistir prioridad y órdenes en KConfig y visor, sin tocar URL, nombres ni permisos.
- [x] Validar representación de órdenes canónicos por IDs, no por etiquetas.
- [ ] Retest en CachyOS: arrastrar Web/IA y fichas, selección vs arrastre, activar/desactivar proveedores, Tab y Espacio, orden predeterminado y persistencia tras reinicio.
- [ ] Verificar usabilidad de arrastre con accesibilidad, etiquetas largas y escalas KDE, sin modificar altura de isla ni invadir Soledad.

## Hasta diez proveedores por categoría y fila IA completa — 17/11/2026

- [x] Registrar hasta diez proveedores visibles Web y diez IA; no forzar mínimo de tres.
- [x] Implementar módulo de datos con ID estable, HTTPS, marcador Web, alta/baja y ocultación/restauración de originales.
- [x] Agregar en opciones los controles de proveedores y preferencia IA en fila completa (predeterminada) o recortada con desplazamiento horizontal.
- [x] Generar filas únicas dinámicas en selector, usar IslandButton y apariencia de fichas de Soledad.
- [x] Conectar persistencia de preferencias en visor y KConfig; no conceder envíos IA a nuevos dominios.
- [x] Crear test Node aislado de orden, límites, ocultación y validación, **no ejecutado**.
- [ ] Ejecutar pruebas Node y Qt/CachyOS; comprobar render, altas hasta diez, bajas, restauraciones, Tab, flechas, arrastre y Enter.
- [ ] Confirmar IA totalmente visible por defecto en distintos tamaños y alternativa compacta con scroll utilizable.
- [ ] Probar permisos individuales, restauración estética favorita, ocultación de isla desde Soledad y compatibilidad KWin/Wayland.
- [ ] Cerrar issue [#12](https://github.com/nicoarg87/plasma-smartbar/issues/12) solo después de evidencia real y corrección de errores.

## Apariencia de Malvina (17/11/2026)

- [x] Eliminar relleno fijo del campo y fondos opacos predeterminados de engranaje/lupa.
- [x] Usar color, degradado, transparencia y orientación de la isla Malvina en el editor.
- [x] Agregar opciones cuadrada/redonda independientes y persistencia de ambas.
- [ ] Probar en CachyOS actualización cromática y degradados al Aplicar, botones, guardado/reinicio y clics del editor.
- [ ] Verificar contraste con transparencias elevadas sin alterar altura fija de isla ni panel KDE.

## Ajustes de la captura del buscador Malvina (17/11/2026)

- [x] Tooltip compacto de lupa, oculto durante búsqueda abierta.
- [x] Contorno perceptible pero sutil para distinguir engranaje/lupa cuadrados o circulares.
- [x] Borde del campo menos llamativo.
- [x] Aplicar al campo único la misma forma/radio/esquinas mixtas que la isla Malvina, además de degradado/opacidad/color.
- [ ] Retest Qt/CachyOS de la apariencia aplicada, foco, clipping, cambios de forma/gradiente y tooltip.

## Personalización Malvina según sistema Soledad (17/11/2026)

- [x] Agregar copiar colores/degradado de Soledad a Malvina como acción explícita, sin acoplarlos permanentemente.
- [x] Usar una fase temporal compartida para respiración de degradado en Soledad y Malvina con intensidad separada, dependiente de Respiración luminosa de SO.
- [x] Hacer que isla y campo de Malvina compartan la modulación de opacidad de su degradado.
- [x] Guardar sincronización/intensidad en KConfig y visor, incluidas estéticas favoritas.
- [x] Ofrecer a lupa y engranaje Cuadrado, Cuadrado redondeado, Circular y Cápsula por separado.
- [ ] Probar QML en CachyOS: copia de paleta, Aplicar, ritmo compartido, intensidades, desactivar cada sincronía, reinicio, bordes y fondos.
- [ ] Evaluar compatibilidad de otras siluetas de SO en controles pequeños y accesibilidad, antes de agregarlas.

## Figura de isla Malvina al estilo Soledad (17/11/2026)

- [x] Ampliar forma de isla Malvina a seis variantes, incluyendo punta triangular izquierda y cápsula.
- [x] Añadir punta con Canvas, contorno y relleno/degradado/respiración, sin botones en el vértice estrecho.
- [x] Conectar radio de cápsula al editor y conservar guardado en propiedad `malvinaShape` existente.
- [ ] Ejecutar prueba Qt/CachyOS de seis figuras: margen de controles, clics, campo, X, navegación, gradiente/respiración y persistencia.
- [ ] Revisar recorte/contorno con punta y alta transparencia, sin agrandar altura de barra.
- [ ] Solo considerar formas complejas de SO (rombo/corazón/estrella) para la isla completa si pueden preservar usabilidad, sin prometer compatibilidad antes de prueba.

## Prioridad máxima: preservar y aplicar ajustes del usuario (18/11/2026)

- [x] Detectar y eliminar retorno temprano que impedía aplicar geometría/colores por URLs/nombres inválidos de Malvina.
- [x] Añadir 24 observadores de cambios de Malvina ausentes del autoguardado del visor.
- [x] Forzar persistencia completa inmediata después de Aplicar y antes de cerrar el visor, reutilizando Qt Settings actuales.
- [x] Mantener favoritos y configuración activa como claves locales separadas, sin resetear datos existentes.
- [ ] Prueba en CachyOS: guardar favoritos en visor antiguo aún abierto, cerrar, actualizar, relanzar y verificar migración sin valores predeterminados.
- [ ] Probar Aplicar y cerrar/reabrir tras modificar figuras, color/degradado, respiración, orden/alta/baja de proveedores y nombres.
- [ ] Confirmar mensaje de error de proveedores inválidos sin pérdida de ajustes visuales.
- [ ] Verificar persistencia con QtCore.Settings del runner instalado en CachyOS; conservar salida de Konsole ante cualquier fallo.

## Predeterminada personal de estética (18/11/2026)

- [x] Añadir fijación explícita de todos los valores actuales en `personalDefaultV1`, separada de favorito y última apariencia.
- [x] Permitir restaurar esa predeterminada personal sin borrar las otras preferencias.
- [ ] Validar en CachyOS fijar, editar, cerrar/abrir, restaurar y comprobar que favoritos antiguos permanecen.
- [ ] Solo publicar estética exacta del mantenedor como valores por defecto del repositorio si proporciona su configuración y autoriza compartir esos ajustes.

## Configuración organizada y campo de Malvina coherente — 18/11/2026

- [x] Separar accesos principales por Soledad (logo, efectos, fichas), Malvina (Web/IA, figura, colores) y Compartidas (geometría, posición, comportamiento, fondos).
- [x] Reutilizar páginas, señales y propiedades anteriores en lugar de borrar/renombrar las claves locales.
- [x] Hacer desplazable la navegación para alturas reducidas y enlazar la figura de Malvina.
- [x] Eliminar fondos rectangulares del ScrollView/TextArea del editor para respetar la esquina derecha redondeada.
- [ ] Verificar en CachyOS la carga QML, enlaces, desplazamiento, Aplicar, autoguardado, figuras, transparencia, gradiente y teclado.
- [ ] Evaluar mejora posterior de distribución interna en páginas extensas a partir de pruebas del mantenedor, sin ocultar controles o cambiar requisitos.

## Soledad: gestos reversibles y tooltip contextual — 18/11/2026

- [x] Implementar predeterminado SO: clic izquierdo lanzador; clic derecho aplicaciones activas, y opción reversible persistible con valor inicial verdadero.
- [x] Tooltip sobre SO/GIF con acciones izquierda/derecha actuales; aclarar que Archivos aún no funciona.
- [x] Conectar Configuración a KConfig y preferencias locales/favoritos del visor sin sobrescribir claves previas.
- [ ] Validar clics, tooltip, pulsación sostenida y guardado/reinicio en CachyOS.
- [ ] En etapa separada, implementar el lanzador real por categorías (Internet, Oficina, Multimedia, Sistema, Utilidades y +) y conmutador Aplicaciones/Archivos con búsqueda KDE de archivos validada, sin afectar el panel.

## Corrección terminológica y primer launcher SO local — 18/11/2026

- [x] Actualizar especificación VIGENTE: cajón de aplicaciones = ventanas activas/abiertas, launcher de aplicaciones = programas; cajón de sistema = bandeja; clic IZQUIERDO SO abre cajón y DERECHO SO launcher (reversible). Sustituye texto histórico anterior en esta hoja.
- [x] Crear UI de launcher SO con conmutador Aplicaciones/Archivos, cinco categorías y +, panel lateral y búsqueda por nombre.
- [x] Conectar al visor un catálogo local efímero de entradas .desktop para listar aplicaciones instaladas sin ejecutarlas; muestras solo como fallback.
- [x] Exploración de carpetas/archivos en modo solo lectura mediante FolderListModel, con filtro por nombre en carpeta actual.
- [x] Al pulsar SO, ocultar ayuda contextual para no cubrir launcher/cajón; tooltip conciso y contextual.
- [x] Malvina: mostrar texto guía «Buscador: pulsá Tab para elegir Web o IA…».
- [x] Malvina: vista indicativa de un segundo al mostrar/ocultar desde menú de seis puntos, respetando autoocultamiento y bloqueo KWin.
- [ ] Probar nuevas páginas en CachyOS/Qt (carga módulos, lista .desktop, scroll, clics, archivos, visibilidad de Malvina y persistencia).
- [ ] Implementar ejecución real de aplicaciones mediante integración KDE aprobada, no por comandos arbitrarios del .desktop; comprobar seguridad.
- [ ] Investigar e implementar búsqueda global de archivos (KRunner/Baloo u otra API verificada) y apertura segura, por ahora solo exploración/filtro de carpeta.
- [ ] Revisar compatibilidad del archivo local XHR utilizado solo por el visor experimental y alternativa de producción sin permisos globales de lectura de archivos.

## Activación y visibilidad de Malvina como estados distintos — 18/11/2026

- [x] Clarificar requisito del mantenedor: Malvina activa con autoocultamiento por defecto; activa NO implica siempre visible. Siempre visible es opción adicional voluntaria.
- [x] Diferenciar `Activar Malvina` de `Visibilidad de Malvina (Automática / Siempre visible)` en centro de configuración, reutilizando `launcherIslandVisible` y `autoHideMalvina`.
- [x] Añadir `Mantener Malvina siempre visible` al menú de seis puntos con estado marcado persistible y mantener allí Activar/Desactivar Malvina.
- [x] Nombrar «Activar Malvina» al botón de recuperación del launcher y conservar aviso temporal de 1 s al habilitar/deshabilitar desde el menú del agarre.
- [ ] Probar en CachyOS con preferencia autoocultar, siempre visible, desactivada, persistencia tras reinicio, ventana maximizada/fullscreen y alternativa sin panel instalado.

## Launcher SO A/B y herencia de estilo de islas — 18/11/2026

- [x] Registrar opción A predeterminada confirmada (apps a la derecha cerca del cursor, el principal se desplaza) y B alternativa (apps a la izquierda, principal fijo).
- [x] Implementar A/B con selector persistente en SoledadSettings, conexión a SmartBarContent, main.qml/KConfig y visor Qt Settings, conservando perfiles locales previos.
- [x] Ajustar launcher de Archivos a ancho mayor, altura proporcional a resultados de carpeta actual, tope configurable 5–20 filas, scroll vertical y rutas de archivo.
- [x] Incorporar estilo de Soledad al launcher (color/transparencia/degradado/contorno/respiración) y configuración de forma/color del interruptor; reutilizar IslandPopupSurface.
- [x] Aplicar apariencia independiente de Malvina al popup Web/IA, con contorno/gradiente y factor de respiración del propio buscador Malvina.
- [x] Registrar prueba positiva del mantenedor: confirmación de mostrar/ocultar Malvina por 1 s desde menú de los seis puntos.
- [ ] Verificar en CachyOS que A no desplace el cursor fuera de las aplicaciones, que B conserve posición sin sobresalir, que archivos se filtren correctamente y que scroll/colores/gradiente/contorno/respiración y preferencia tras reiniciar funcionen.
- [ ] Integrar búsqueda global de archivos y ejecución segura de apps en una etapa independiente con pruebas KDE/KWin; nunca inventar que el prototipo ya ejecuta o indexa todo el equipo.

## Launcher: iconos, transparencia propia y ancho estable al buscar archivos — 18/11/2026

- [x] Configurar opacidad del launcher heredada de Soledad por defecto, deslizador independiente solo al activar excepción; guardar en visor/KConfig.
- [x] Configurar opacidad del panel Web/IA que se abre con Tab en Malvina, heredada de la isla 2 salvo excepción explícita.
- [x] Agregar iconos de categorías del tema KDE y recuperar Icon de entradas .desktop; modo ícono+nombre predeterminado o solo nombre, sin modo solo íconos.
- [x] Al cambiar Aplicaciones → Archivos después de abrir categoría, conservar el ancho del launcher desplegado y aprovecharlo para el buscador; sin panel lateral vacío.
- [ ] Probar CACHYOS Qt: íconos/fallback, transparencia propia, guardado al cerrar/reabrir, inspiración visual de ambas islas y cambio de modo con tamaño/anclaje sin salto.
- [ ] Mantener búsqueda de archivos limitada a carpeta actual hasta validar búsqueda global; no ejecutar apps ni archivos de usuario en visor.

## Estabilidad del launcher, foco y opacidad Web/IA — 18/11/2026

- [x] Mantener categoría seleccionada y altura/ancho al alternar Aplicaciones → Archivos → Aplicaciones, sin cerrar popup.
- [x] Sustituir detector de clic exterior localizado en barra por evento de superposición Qt, para cerrar ambos paneles en clic fuera y preservar cierre individual por Escape (implementación pendiente de test gráfico).
- [x] Hacer más accesible el hover de Malvina ampliando margen del HoverHandler, sin cambiar geometría visual de isla ni capturar clics externos.
- [x] Separar opacidad y respiración del panel Web/IA y launcher: al 100 % mostrar fondo opaco y respiración de luminosidad; a valores menores conservar transparencia dinámica.
- [x] Agrupar transparencia del launcher de Soledad en su pestaña Color, equivalente a la transparencia del panel Web/IA de Malvina. No sobrescribir valores de estética ya guardados.
- [ ] Probar en CachyOS cierres por clic exterior (dos popups), Escape individual, alternancia repetida, hover Malvina, opacidades al 80/100 % y persistencia.
- [ ] Investigar si quedan casos de hover intermitente en sesión real KWin/Wayland y de eventos de superposición no recibidos por Popup no modal; si falla, mantener evidencia de Konsole y corregir de manera acotada.

## Regresión de clic interior en launcher SO y panel Web/IA — 18/11/2026

- [x] Reconocer regresión probada por el mantenedor: launcher SO se cerraba al tocar controles internos; Malvina cerraba al seleccionar proveedor Web/IA.
- [x] Eliminar cierre global `Overlay.onPressed` de `SmartBarContent.qml`; usar política nativa de clic exterior en el popup SO. Mantener abierto launcher si se selecciona app de muestra sin ejecución.
- [x] Diferenciar campo de Malvina de popup hermano de proveedores; el campo desactiva cierre exterior cuando Web/IA está visible, y recupera cierre exterior cuando solo está abierto el campo.
- [ ] Reprobar en CachyOS/Wayland el clic dentro de ambos popups, alternancia, selección Web/IA, Escape individual, clic exterior, foco de escritura, dos paneles simultáneos; registrar fallos si persisten.
- [ ] Ejecutar test funcional con Qt gráfico y comprobar que `closePolicy` de dos popups hermanos no afecta el flujo; no declarar corrección comprobada antes de ensayo.

## Registro de defectos y dos temas de Soledad — 18/11/2026

- [x] Crear `docs/ERRORES_COMUNES.md` para **todos** los errores, con recurrencia, origen, pasos, enlaces y pruebas, incluyendo ERR-001 (clic SO reabre popup), ERR-002 (clic interior cierra popups), ERR-003 (Web/IA flechas) y 12 incidencias adicionales.
- [ ] Reprobar en CachyOS los errores recurrentes con el visor aislado y documentar resultados verificables; priorizar controlador de gestos y foco si vuelven a aparecer.
- [x] Documentar en `docs/TEMAS.md` dos motivos de tema: atardecer tropical actual y GIF de playa nocturna todavía pendiente de recibir.
- [ ] Obtener el **GIF nocturno correcto**, no una captura del visor; verificar origen/licencia/hash y guardar en assets sin reemplazar el GIF actual.
- [ ] Implementar `Temas` en opciones con dos entradas, previsualización y paleta base del arte nocturno, personalizable en Soledad y Malvina, sin sobrescribir presets/favoritos.
- [ ] Probar rendimiento/animación, gradientes, opacidad, contorno y restauración de temas en CachyOS antes de integrar en panel real.

## ERR-016: fidelidad del GIF nocturno frente a contornos y degradados — 18/11/2026

- [x] Diagnosticar en código y registrar [ERR-016](docs/ERRORES_COMUNES.md): derivación explícita de paleta desde contorno brillante, muestreo GIF 32×32 con luminosidad alta fija, copia Soledad→Malvina solo de fondo/degradado, respiración como modulación de opacidad y Restablecer colores con valores estáticos para ambas islas.
- [ ] Verificar en CachyOS con el GIF nocturno real y valores guardados cuál de esos caminos produjo el celeste; conservar evidencia y no sobrescribir estética favorita.
- [ ] Proponer para aprobación separar «paleta derivada del contorno» de «paleta extraída del GIF» y preservar luminosidad real del material nocturno, sin alterar automáticamente paletas personalizadas.
- [ ] Consultar al mantenedor si «Restablecer colores» debe afectar la isla actual o ambas, y si debería restaurar una paleta del tema elegido, antes de modificar la función.
- [ ] Una vez aprobados los cambios, agregar pruebas de extracción/copia/respiración/Aplicar/cerrar/reabrir y comprobar que no aparecen colores heredados del GIF anterior.

## ERR-016: correcciones aplicadas con aprobación — 18/11/2026

- [x] Aprobación funcional del mantenedor para separar contorno/fondo, mejorar extracción nocturna, reset acotado y corregir restauración aun si requiere reconfigurar estilos.
- [x] Separar sugerencias de GIF y contorno, invalidar sugerencias de imagen obsoleta y exigir aplicación explícita al fondo.
- [x] Pasar de Canvas 32×32 con HSV de brillo fijo a 64×64 con muestras RGB reales y recarga local de la imagen para evitar caché de un GIF cambiado en la misma ruta.
- [x] «Restablecer colores de esta superficie» modifica solo el destino seleccionado y limpia gradientes obsoletos; no borrar GIF, contorno ni otras islas.
- [x] Documentar el diagnóstico/corrección en `docs/ERRORES_COMUNES.md` ERR-016 y mantener intacto el panel KDE existente.
- [ ] PROBAR con el GIF nocturno real en CachyOS: tonos propuestos, Aplicar y reabrir, contorno celeste separado, respiración, copiar a Malvina, restablecer Soledad sin afectar Malvina y viceversa. Si falla, registrar Konsole y captura.
- [ ] Validar más adelante muestras de varios cuadros GIF si el muestreo de uno solo no representa adecuadamente su paleta, sin modificar ni redistribuir el recurso privado del mantenedor.
