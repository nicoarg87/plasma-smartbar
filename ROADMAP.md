# Hoja de ruta de Plasma SmartBar Islands

> **Estado real (17/11/2026):** prototipo visual QML en rama experimental y diagnóstico independiente de **ventanas reales KDE probado en CachyOS**, con actualización dinámica de la lista. **SO todavía usa fichas simuladas; no hay versión instalable validada para uso diario.**
> Las etapas se subordinan a la [Constitución técnica](docs/CONSTITUCION_TECNICA.md).

## Fase 0 — Fundamentos y organización
- [x] Abrir repositorio público para Linux con KDE Plasma.
- [x] Establecer constitución, Manual Maestro y gobernanza; **licencia MIT vigente para código propio**, ratificada por el mantenedor; se conserva el historial de licenciamiento anterior.
- [x] Redactar reglas de contribución y visión inicial.
- [x] Activar regla de protección de rama main (bloqueo de borrado y force push; confirmado 14/11/2026).
- [ ] Revisar periódicamente colaboradores autorizados y evaluar exigencia de PRs cuando haya equipo.
- [ ] Investigar qué piezas de Plasma/KWin/Qt pueden reutilizarse y bajo qué licencias.

- [x] Documentar separación entre licencia MIT del código y licencia de recursos gráficos (CC0 1.0 previsto para imagen tropical de OpenAI, aún falta recuperar su archivo exacto). No incluir logo Golden Dog de procedencia no verificada.
- [ ] Integrar imagen tropical original cuando esté disponible y registrar integridad/autoría; no usar sustitutos visuales como si fueran el original.
- [ ] Retest en CachyOS de forma única del botón SO (figuras normales y anchas) y ajuste `Estirar` + zoom y desplazamiento sin reescribir la imagen.

## Prioridad de ejecución ratificada — 21/11/2026

- [x] **Licencia inequívoca:** código, documentación y `KPlugin.License` de obra propia bajo **MIT**; GIF, logos y wallpapers originales generados mediante IA y aportados por el mantenedor bajo **CC0 1.0 Universal**, sobre derechos que puede conceder. `wallpapers/manifest.json` declara `CC0-1.0` para Día/Atardecer/Noche. Esto no incorpora binarios todavía ausentes ni autoriza material de terceros. Revisión documental en rama experimental.
- [x] **Disciplina funcional:** el mantenedor propone ideas mientras prueba en CachyOS; registrar sin frenar ese método, pero la IA **no puede crear botones/menús/reorganizaciones no solicitados**. La modularización es obligación de ingeniería de la implementación, no tarea de recordatorio para el mantenedor.
- [ ] **Ensayo KDE real aislado como siguiente prioridad técnica:** primero validar en CachyOS lectura de aplicación/ventana activa y maximizada, identificador estable, TasksModel y fullscreen; después medir compatibilidad y foco con Dolphin/Konsole/Steam/navegadores. No instalar en el panel principal ni habilitar acciones destructivas de KWin antes de pruebas.
- [ ] **Posición general anclada + memoria por aplicación activa y maximizada:** ratificación del [issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4); aprovechar el agarre/menús existentes, sin botón añadido. Probar primero con ventanas simuladas y sin mover controles propios de SmartBar del extremo derecho. Poner límites por monitor/escalado y regreso a posición general para aplicaciones sin perfil.
- [ ] **Refactor gradual y pruebas:** extraer módulos acotados de `SoledadSettings.qml`/`SmartBarContent.qml` con contratos Qt/QML y test de regresión después de cada cambio. Mantener el PR #3 como borrador [#11](https://github.com/nicoarg87/plasma-smartbar/issues/11).
- [ ] **Volver a ejecutar la suite Node ampliada** (`test_license_policy.cjs` incluido), verificar carga QML/CachyOS; última ejecución certificada por el mantenedor antes de estos cambios: **29/29**.

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
- [ ] **Acerca de (prueba pendiente):** autor público nicoarg87, correo para consultas **nicoarg87@gmail.com** (autorizado), licencia MIT con enlace al LICENSE oficial y aviso **SIN NINGUNA GARANTÍA**. Código en PR #3; verificar apertura de cliente de correo y legibilidad en CachyOS. **PayPal y Cafecito se posponen**; sin links ni botones de donaciones.
- [ ] Validar todos los cambios en CachyOS/Wayland usando exclusivamente ventana de prueba Qt; PR #3 y issues #1/#5 abiertos. Iconos personalizados del agarre y bandeja e isla extra siguen diferidos.

## Terminaciones por isla y orden de Acerca de — validar en CachyOS (15/11/2026)

- [ ] **Geometría predeterminada nueva:** Soledad redondeada izquierda / recta derecha y agarre cuadrado. Alternar Soledad entre redondeada, cuadrada, ambas mixtas y punta triangular izquierda (experimental); Malvina entre redondeada, cuadrada y ambas mixtas; agarre y flecha de bandeja cuadrado/redondeado. `Restablecer` vuelve a defaults. Verificar gesto de arrastre y barra fija.
- [ ] **Acerca de:** correo autorizado `nicoarg87@gmail.com`, repositorio GitHub inmediatamente debajo del contacto, licencia MIT y aviso SIN NINGUNA GARANTÍA por debajo. Verificar botones con teclado, sin donaciones.
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

## Temas y reorganización integral del centro de configuración — 18/11/2026

- [x] Apartado principal **Temas** con vista previa/miniatura del logo SO y botón que abre la personalización del logo.
- [x] Ranuras Día/Noche/Personalizado con guardado/aplicación explícitos de logo y estética de ambas islas, separadas de favoritos y predeterminada personal.
- [x] Opción «Crear automáticamente desde el logo SO»: extraer tonos de la imagen/GIF local e iniciar un estilo editable para Soledad y Malvina, conservando la iluminación del contorno.
- [x] Menú lateral plegable Temas/Soledad/Malvina/General con entradas separadas y degradado claramente visible en cada isla.
- [x] Ocultar el selector de isla cruzado dentro de Soledad/Malvina; limitar el selector compartido a fondo/bandeja/agarre; mover copiar paleta SO→Malvina a General.
- [x] Mostrar figura/tamaño exclusivos por isla, altura general y botones comunes en General, sin eliminar funciones existentes.
- [x] Guardar tres temas en KConfig/Qt Settings sin afectar las otras ranuras ni favoritos personales.
- [ ] PROBAR EN CACHYOS: carga QML, desplegables de menú, color/degradado, saltos entre páginas, miniatura GIF, Día/Noche/Personalizado, creación automática, Aplicar/reapertura y persistencia de favoritos.
- [ ] Posterior: incorporar GIF nocturno con derechos y SHA si se autoriza distribuirlo; las ranuras hoy usan ruta local del archivo elegido por el mantenedor.

## Menús exclusivos y compatibilidad de muestreo — 18/11/2026

- [x] SO recibe menú propio «Launcher y botón SO» y autocontracción SO; bandeja y opciones comunes quedan en General con reset individual.
- [x] Permitir editar figura y tamaño de Malvina aunque la isla esté desactivada.
- [x] Sustituir manejador no compatible `Canvas.onImageLoadingFailed` por `isImageError()` y Timer, según Qt 6.
- [ ] Probar en CachyOS menús plegables, SO y Malvina sin cruces, nuevo Temas, tres espacios guardados y error/timeout de archivo GIF ausente.
- [ ] Asegurar accesibilidad por teclado a encabezados y controles con escalado de fuentes KDE.


## Reparación de persistencia Atardecer y favorita — 19/11/2026

- [x] Renombrar visualmente Día → **Atardecer**, conservando `themeDayJson` como clave antigua para no perder el perfil local.
- [x] Eliminar sobrescritura automática de la paleta y dirección de Malvina al aplicar Atardecer.
- [x] Actualización explícita y confirmada de Atardecer con respaldo recuperable independiente `themeDayPreviousJson`.
- [x] Separar escritura de favorito/predeterminada del último estado, suprimir autoguardados intermedios en restauración y ampliar campos de estética capturados.
- [x] Agregar `prototype/v0.1/tests/test_theme_persistence.cjs` (prueba estática de regresión).
- [ ] Ejecutar Node y visor Qt en CachyOS; aplicar/restaurar Atardecer y Noche; comparar colores, dirección y respiración de ambas islas, miniaturas, favorita, predeterminada y reinicio.
- [ ] Capturar con acción explícita del usuario la favorita local recién guardada como nuevo Atardecer; nunca inventar ni publicar sus valores de configuración.
- [ ] Estudiar tema **Día claro** como opción futura, separado de Atardecer y Noche, previa confirmación funcional del mantenedor y sin generar imagen ahora.


## Paleta visual explícita desde GIF — 19/11/2026

- [x] Sustituir el algoritmo anterior de sugerencias escondidas por extracción local de hasta tres tonos cromáticos frecuentes de un fotograma, bajo demanda.
- [x] Editor de cada tono con HEX de seis dígitos, copia al portapapeles y diálogo cromático.
- [x] Asignar cualquier tono al color 1/base o color 2/final de Soledad/Malvina, conservando la independencia por isla.
- [x] Mantener control existente de activación del degradado y cuatro orientaciones, sin paleta forzada ni modificación automática del contorno SO.
- [x] Quitar del flujo de creación de tema la aplicación automática de colores a ambas islas; analizar, elegir y Aplicar es explícito.
- [x] Agregar prueba estática `prototype/v0.1/tests/test_palette_extractor.cjs`.
- [ ] Ejecutar test Node y QML en CachyOS, comprobar RGB de GIF real, copiar/pegar HEX, selección, ColorDialog, transparencia y respiración, 4 orientaciones, persistencia y no alterar Atardecer/Noche/Favorita. Ver [issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15).


## Gradiente configurable de 2/3 colores — 19/11/2026
- [x] La lectura de GIF asigna automáticamente los dos tonos dominantes al degradado de la isla actual; mantiene un tercero disponible.
- [x] Modo **2 colores predeterminado** y **3 colores opcional**, por isla (0 %, 50 %, 100 %), con selectores compactos y copia/edición HEX.
- [x] Vista previa opaca y controles para cuatro direcciones; brillo SO independiente.
- [x] Persistir cuarto conjunto de campos `GradientColorCount` y `GradientThird` en KConfig, Qt Settings y snapshots sin sobrescribir temas anteriores.
- [x] Superficies de Soledad, Malvina, launcher y subpaneles Web/IA dibujan dos o tres paradas.
- [x] Crear prueba de regresión estática `prototype/v0.1/tests/test_gradient_palette.cjs`.
- [ ] **Probar en CachyOS** extracción de colores con GIF real, selección 1+2/1+3, modo 3, 4 direcciones, pulsación de Aplicar, guardado y reapertura, luz independiente y consumo CPU/GPU. Issue #15.


## Menú y respiración por isla integrados — 19/11/2026
- [x] Ordenar accesos de Soledad: Anchura primero; Logo SO; Efectos; Color y transparencia; Figura/tamaño; Cajón/ventanas; Launcher.
- [x] Eliminar accesos redundantes «Degradado Soledad» y «Degradado Malvina»; mostrar opacidad, 2/3 colores, dirección y respiración juntos bajo Color.
- [x] Activar sincronización con SO por defecto en configuraciones nuevas y respetar valores locales previos.
- [x] Respiración habilitada separadamente, intensidad independiente por isla y velocidad local cuando se desconecta sincronización; reloj único condicional.
- [x] Los temas guardados recuperan su respiración real sin forzar sincronización.
- [x] Añadir prueba estática `prototype/v0.1/tests/test_breathing_menu.cjs` (PASS en V8).
- [ ] Ejecutar tests Node y ensayo Qt/CachyOS de la nueva pantalla y respiración; comprobar efectos en SO y Malvina, paneles flotantes, opacidad, preferencias, rendimiento y compatibilidad. [Issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15).


## Afinado de UI y opacidad inicial 70 % — 19/11/2026

- [x] Fusionar navegación «Anchura del botón SO» y «Logo SO» en «Botón de inicio SO», editor de anchura junto con imagen y recorte.
- [x] Scrollbars verticales visibles y ancho reservado; evitar colisión entre HEX/copiar/editar y scroll con rejilla responsive y edición de colores activos en dos renglones.
- [x] Desde Color y transparencia incluir enlace directo a Efectos luminosos → Brillo y respiración SO, con opción de activar efecto Respiración y ajustar duración de ciclo en ms.
- [x] Valores iniciales/fallback del 70 % de opacidad para Soledad, Malvina, launcher, panel Web/IA y fondo continuo opcional, sin tocar preferencias personales ya guardadas ni activar el fondo.
- [x] Actualizar test `test_breathing_menu.cjs`: PASS estático junto a otros tres tests.
- [ ] Probar en CachyOS barra lateral, scrollbar y Editar con ventana reducida, 70 % en nuevas configuraciones, duración ms/ciclo e intensidad del brillo. Mantener el panel KDE existente sin cambios. [Issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15).
- [ ] Para consolidar todos los demás valores estéticos locales actuales como predeterminados personales, pulsar **«Fijar actual como predeterminada»** en el visor, confirmar restauración tras reinicio y no copiar datos privados a GitHub sin permiso.


## Corrección final de configuración Soledad y licencias — 19/11/2026


- [x] Unificar «Botón de inicio SO» y «Efectos luminosos SO» bajo una entrada lateral única, con subpestañas visibles para Logo/ancho/texto y Efectos; mover «Launcher y botón SO» al primer lugar de Soledad. [0274f6d](https://github.com/nicoarg87/plasma-smartbar/commit/0274f6dcc6f70a274ff7f336f40f80adc036cc5c).
- [x] Agregar en el apartado Brillo y respiración SO acceso directo a Color y transparencia → Degradado y respiración de Soledad, sin mezclar controles y velocidades. Mantener enlace inverso.
- [x] Abrir ventana de configuración más ancha si cabe; reservar margen de scrollbar y separar botones HEX/Copiar/Editar en filas que no desborden. Verificar cada vista y escala de KDE en pruebas.
- [x] Corregir el antiguo `KPlugin.License` a MIT para respetar licencia vigente del software y documentación propios. [6b4c3c2](https://github.com/nicoarg87/plasma-smartbar/commit/6b4c3c23ac3ff1aaa1d27f5843877d050433a384).
- [x] Ratificar dedicación CC0 1.0 Universal del arte/GIF original de botones SO generado por ChatGPT y aportado por el mantenedor, separado de MIT del código. No aplicar CC0 a terceros; conservar hash y original.
- [x] Actualizar regresión `test_breathing_menu.cjs` para orden, navegación, scrollbar y metadatos. [c9c59a9](https://github.com/nicoarg87/plasma-smartbar/commit/c9c59a957178226ac54d00aa8a2b6466a7a5e19f).
- [ ] **Prueba real en CachyOS:** ejecutar test Node + visor, confirmar que no se oculta ningún botón por la barra vertical a resolución normal/ventana angosta/escalado KDE, los saltos de degradado/contorno llegan al apartado correcto, el launcher queda primero y los temas/ajustes actuales sobreviven.
- [ ] Confirmar que los dos GIF originales pueden leerse desde sus rutas locales sin cambiar archivos personales; incorporar a GitHub solo cuando el archivo exacto y el alcance de su licencia se verifiquen.
- [ ] Mantener [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) como borrador y [issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15) abiertos hasta prueba visual en CachyOS. No sustituir el panel real.


## Prioridad aprobada — Isla y launcher y respiración SO independiente (19/11/2026)

- [x] Cambiar «Launcher y botón SO» por **«Isla y launcher»** como primer acceso, incluyendo enlaces al posicionamiento compartido y a figura/tamaño de Soledad.
- [x] Mantener «Botón de inicio SO» en segundo lugar, con **Brillo y respiración** como primer apartado de su subpestaña «Efectos luminosos SO».
- [x] Hacer respiración del contorno el estilo inicial para configuraciones nuevas, con **0,3 ciclos/s** en vez de 0,6; sin sobrescribir preferencias guardadas.
- [x] Mantener velocidades de la línea SO y de los degradados Soledad/Malvina independientes para perfiles nuevos; casillas existentes de sincronización de ritmo siguen disponibles por isla.
- [x] Incorporar casilla «Sincronizar degradado Soledad con la línea SO (ritmo e intensidad)», botón «Desvincular» y ajuste «Igualar intensidad» en Color, guardado como `soledadGradientSyncIntensity=false` por defecto.
- [x] Propagar nueva preferencia por render QML, señales de Aplicar, KConfig, Qt Settings del visor, favoritos y temas sin migrar valores existentes.
- [x] Prueba de regresión estática [a222be0](https://github.com/nicoarg87/plasma-smartbar/commit/a222be07888284191c4a945a8416cb32262916c5): PASS 139 comprobaciones V8. Junto con temas y paleta, 245 PASS.
- [ ] **Validar Qt en CachyOS**: contorno con velocidad propia; al ajustar SO no variar fondos desacoplados; al sincronizar reproducir ritmo e intensidad de SO; al desvincular recuperar parámetros independientes, sin afectar Malvina.
- [ ] Comprobar intensidad 0 %, estilos, animación, visibilidad, consumo y persistencia tras Aplicar/reabrir, junto a temas Atardecer/Noche y predeterminada personal.
- [ ] Mantener [issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15) y [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) abiertos hasta validación. No modificar el panel KDE instalado.



## Incidencia de prueba 19/11/2026 — velocidades bloqueadas en interfaz

- [x] Identificar bloqueo real en `SoledadSettings.qml`: la fila de velocidad del degradado estaba deshabilitada si un tema/restauración mantenía `GradientSyncBreathing=true`, aunque «Igualar intensidad» estuviera apagado.
- [x] Permitir editar **siempre** la velocidad propia de Soledad/Malvina con slider y botones ±; modificarla desacopla ritmo de SO en esa isla (y también el vínculo de intensidad de Soledad), sin alterar línea SO.
- [x] Reordenar el primer apartado de Efectos luminosos del botón SO para situar velocidad, duración de ciclo e intensidad del pulso arriba, con ± accesibles y activación del efecto al modificar dichos controles.
- [x] Ofrecer actualización inmediata de vista previa del pulso SO sin comprometer el guardado vía Aplicar.
- [x] Explicar cuándo la línea SO está oculta con ventanas abiertas y facilitar casilla de prueba, conservando el valor guardado.
- [x] Corregir botón «Ir a Color y transparencia → Degradado y respiración» para que salte al apartado de velocidad del degradado, no al principio de la página larga.
- [x] Regresión de lógica JS QML y presencia de controles sobre fuentes GitHub, 275 PASS distribuidos en tres tests ([UI 7ac071b](https://github.com/nicoarg87/plasma-smartbar/commit/7ac071bf32ad60d94cf9e7c4a091384b64d14394)).
- [ ] **Prueba visual del mantenedor en CachyOS**: confirmar edición de velocidad con sincronización heredada activa, persistencia, cambios en preview, controles ±, scroll de navegación y pulsación visible en SO con/sin ventanas. Registrar captura/log de error en [issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15).
- [ ] Mantener panel KDE actual intacto y [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador hasta validación.


## Hito aprobado 19/11/2026 — una sola página de SO y pie Cancelar/Aplicar

- [x] Fusionar **Logo, ancho y texto** con **Efectos luminosos del botón SO** en un único `ScrollView`, colocando los efectos **debajo de los ajustes del logo, encuadre y reloj**, sin subpestaña independiente.
- [x] Eliminar la pestaña `Texto` redundante: selector Predeterminada / Imagen propia / Texto SO dentro del bloque principal, con edición de texto contextual al elegir ese modo. Conservar ajustes de fuente, fondo, imagen/GIF, tamaño y color.
- [x] Integrar **Restablecer logo y formato** junto a las opciones del logo, no como sección/pestaña suelta; conservar salto directo desde Color y transparencia a los efectos.
- [x] Sustituir pie **Aplicar + Cerrar** por **Cancelar (izquierda) + Aplicar (derecha)** en todos los menús; la X descarta pendientes también.
- [x] Crear snapshot recuperable de las **139 propiedades de la configuración cargadas en el visor**, con manejo de colores y objetos anidados. `Aplicar` actualiza el checkpoint; `Cancelar` revierte los cambios posteriores, sin modificar favoritos ni configuración ya guardada.
- [x] Deferir guardado de Atardecer/Noche/Personalizado y rotación de respaldo hasta Aplicar; permitir Cancelar para descartar un tema preparado.
- [x] Deferir comandos «Centrar» y «Mover a derecha» hasta Aplicar; evitar mover isla antes de que el usuario pueda cancelar, conservar alineación efectiva después de aplicar.
- [x] Regresión sobre fuentes de GitHub **470 comprobaciones PASS** (349 configuración/respiración/cancelación, 77 temas, 44 gradientes). Código [12983ef](https://github.com/nicoarg87/plasma-smartbar/commit/12983eff1634240ff49276c33a61d35f5a2f7a95), [5eca518](https://github.com/nicoarg87/plasma-smartbar/commit/5eca51815222368930b18ae4e8637f6a2feeb4d8), [426a78f](https://github.com/nicoarg87/plasma-smartbar/commit/426a78f188a805410495a4151f9d74d3469e2f99), [481505c](https://github.com/nicoarg87/plasma-smartbar/commit/481505cbf253d40d10eda1bddcf05e68936b139b).
- [ ] **Prueba real Qt/CachyOS**: navegación única, velocidad/intensidad de línea SO al final; modo Texto SO editable sin pestaña; botones Cancelar y Aplicar en cada menú; Cancelar/X antes y después de Aplicar, temas guardados/descartados y movimiento diferido de isla.
- [ ] Mantener issue #15 abierto, PR #3 borrador y panel KDE del usuario intacto.


## Tema Noche de fábrica — entrega dividida y captura real pendiente (19/11/2026)

- [x] **Decisión funcional:** Noche es tema oscuro original del sistema, no regrabable por el usuario; el botón «Restaurar Noche de fábrica» recupera siempre sus valores originales, permitiendo personalizar después sin modificar el preset.
- [x] Reemplazar la Noche mutable `themeNightJson` por origen independiente `assets/FactoryNightTheme.js`. Conservar ranuras antiguas sin borrarlas. Quitar «Fijar tema Noche».
- [x] Impedir miniaturas engañosas: la imagen de Noche proviene del preset y el GIF real empaquetado, no del logo actual, una imagen de Atardecer ni una ruta fallback. Comprobar que cargue la imagen.
- [x] Exponer «Restaurar Noche de fábrica» deshabilitado si falta su perfil o recurso; no inventar estética, ni sobreescribir el aspecto personal, ni publicar una Noche incorrecta.
- [x] Agregar exportación de los ajustes visuales exactos actuales desde Temas y script `prototype/v0.1/scripts/fijar_noche_fabrica.cjs` para copiar GIF/imagen, construir preset fijo, eliminar rutas locales del archivo distribuido y calcular SHA-256; rechazar sustituciones automáticas.
- [x] Ampliar la instantánea visual con ancho de botón SO, alturas/radios y modo de fichas para recuperar realmente la apariencia de barra.
- [x] Validaciones V8/FS sobre código GitHub: `test_factory_night.cjs` 35 PASS, más pruebas anteriores 470 PASS = 505.
- [ ] **Bloqueante:** recibir de CachyOS el JSON exportado desde la apariencia que el mantenedor usa **ahora mismo** y el archivo GIF/imagen correspondiente (o identificar inequívocamente su SHA). Todavía `FactoryNightTheme.js` contiene `preset=null`: **NO es un tema de fábrica completo ni restaurable**.
- [ ] Incorporar perfil exacto + binarios al paquete, verificar licencia/origen de las imágenes, actualizar manifest con hash, ejecutar pruebas reales Node/Qt/CachyOS, validar miniatura, restauración después de cambios y recuperación tras reinstalación.
- [ ] Mantener issue #15 y PR #3 en borrador, sin modificar panel KDE del usuario ni fusionar a main.


## Segundo tema de fábrica: Atardecer original; Día se agregará después (19/11/2026)

- [x] **Decisión:** Atardecer, como Noche, es un tema de fábrica **original, inmutable desde la UI y siempre restaurable**. Los usuarios podrán personalizar la barra activa pero no sobrescribir el preset. **Día será un tema futuro separado**; no reutilizar `themeDayJson` histórico que pertenecía a Atardecer.
- [x] Crear `assets/FactorySunsetTheme.js` con `preset=null` hasta importar datos auténticos, y carga en QML desde ruta distinta a Noche.
- [x] Añadir tarjeta «Atardecer de fábrica»: miniatura del GIF/imagen propia, «Restaurar Atardecer de fábrica», exportación de apariencia activa y aviso claro cuando falte imagen o preset. No mostrar paletas inventadas ni miniaturas del tema en uso.
- [x] Eliminar UI anterior «Fijar Atardecer», «Actualizar Atardecer con estética actual», «Recuperar Atardecer anterior» y diálogos de reescritura; guardar preferencias históricas en disco sin borrarlas ni modificarlas. No mezclar personal/favorita/Noche.
- [x] Crear `scripts/fijar_atardecer_fabrica.cjs` para empaquetar una única vez la captura actual real, imagen/GIF y posible fondo de texto con hash SHA-256, sin publicar rutas locales.
- [x] Actualizar regresiones de configuración, temas históricos y fábricas: **562 comprobaciones de fuentes PASS** en V8/FS simulado, pero no valida Qt/CachyOS.
- [ ] **Bloqueante:** recibir `~/atardecer-actual.json` exportado desde el visor en el estado visual Atardecer exacto, y el GIF/imagen real. El original **no está fijado todavía**: `preset = null`, «Restaurar» deshabilitado.
- [ ] Verificar licencia del gráfico, empaquetar binarios, probar miniatura/recuperación tras cambios y nuevas instalaciones; probar Noche por separado; registrar hashes y capturas reales en issue #15.
- [ ] **Posteriormente**, cuando el mantenedor establezca Día, crear su propio original/preferencias sin reemplazar Atardecer ni Noche, preservando los históricos.
- [ ] No instalar sobre el panel KDE ni fusionar PR #3 sin prueba y aprobación.


## Temas en un solo desplegable con scroll — 19/11/2026

- [x] Sustituir **mosaico de tarjetas** de Atardecer/Noche por **un único selector cerrado por defecto** («Seleccionar tema ▾»); al clic abrir una lista de temas vertical con scroll.
- [x] Mantener visibles en la lista de opciones Atardecer/Noche de fábrica (deshabilitados mientras falta el recurso real), Día pendiente y los perfiles existentes: `themeCustomJson`, `themeDayJson`, `themeDayPreviousJson`, `themeNightJson`, predeterminada personal y favorita locales.
- [x] Permitir sumar **nuevos temas con nombre** usando «Guardar tema» dentro de la lista; guardar de inmediato cada tema en una biblioteca nueva `themeLibraryJson` (sin reemplazar temas previos).
- [x] Cablear biblioteca por configuración Soledad → SmartBarContent → QtCore.Settings del visor/KConfig del plasmoide: `preview_redimensionable.qml`, `main.qml`, `main.xml`. Proteger Cancelar (cambios posteriores), mantener el pie Cancelar/Aplicar y no tocar el panel del sistema.
- [x] Test de regresión `test_theme_selector.cjs` junto con los anteriores: **631 aserciones de código PASS** en simulación V8/FS.
- [ ] **Prueba QML/CachyOS**: botón contraído por defecto, scroll vertical correcto en pantalla reducida, listado de predeterminada/favorita y temas históricos, guardar dos temas distintos, cerrar/reabrir el visor y restaurar cada uno.
- [ ] Continúa pendiente recibir capturas exactas y archivos gráficos para habilitar Atardecer/Noche de fábrica, y crear Día definitivo cuando el mantenedor lo indique; no confundirlos con temas personales.
- [ ] Mantener issue #15 y PR #3 borrador. Ningún reemplazo del panel KDE existente.


## Cajón SO: ventanas ficticias manejables y audio para versión posterior — 20/11/2026

**Decisión del mantenedor:** los **controles de audio por aplicación, silencio/volumen y multimedia/MPRIS** quedan agendados **para la versión siguiente a v0.1**, no forman parte del prototipo actual. Referencia: [issue #16](https://github.com/nicoarg87/plasma-smartbar/issues/16). Las miniaturas y las demás opciones del gestor de tareas deberán evaluarse con Qt/KDE y KWin/Wayland antes de implementarse en ventanas reales; por ahora solo simular fichas.

**Prueba v0.1 en rama experimental** (solo visor Qt, nunca el panel instalado):

- [x] Modelo puro `DemoWindows.js`: abrir/cerrar/reabrir fichas ficticias por nombre, sin ejecutar comandos ni acciones de KWin/TasksModel.
- [x] Ficha `DemoTaskChip.qml`: conservar botón de selección SO y agregar **×** de cierre ficticio solamente en el visor.
- [x] Control **+** dentro del cajón SO, deshabilitado cuando están presentes todas las ventanas del catálogo ficticio; reabre las fichas cerradas, en posición derecha y centrada.
- [x] Permitir acceder al cajón SO vacío con el gesto explícito de ventanas durante el ensayo, incluso después de cerrar todas las ficticias. No alterar comportamiento con TasksModel real ni uso en el plasmoide.
- [x] Sin persistir estado ficticio ni reescribir preferencias de temas y apariencia.
- [x] Nueva prueba `test_demo_windows.cjs` PASS en entorno V8/FS simulado, con modelo puro, coordinación QML aislada, cierre total, reapertura y guardas para tareas reales.
- [ ] **CachyOS/Qt:** suite completa de **20 pruebas** con Node v22+, abrir el visor, mostrar cajón SO con clic derecho (o gesto configurado), cerrar y reabrir Dolphin/Konsole/Brave ficticios, cerrar los tres, comprobar que **+** queda accesible, alternar posición derecha/centro y verificar que la prueba de tareas reales continúa de solo lectura.

No se incorporan ventanas reales ni controles para cerrarlas; el objetivo es ensayar la interacción del cajón sin dañar el entorno del mantenedor. PR #3 borrador, licencias e imágenes sin cambios.

## Pack inicial «Playa 24hs» y packs personalizados — 20/11/2026

- [x] **Requisito del mantenedor:** Playa 24hs agrupa Día/Atardecer/Noche y queda elegido en instalaciones nuevas; permite selección manual o cambio automático por horarios. Los usuarios podrán construir temas y packs propios manteniendo el selector único.
- [x] **Primer prototipo en rama `prototype/v0.1-islas-so`:** `ThemePack.js` nuevo módulo de datos/schedules; `SoledadSettings.qml` ofrece Playa, packs personales, selección manual, creación a partir de temas guardados, y editor horario compartido. Nuevas preferencias independientes `selectedThemePackId` y `themePackLibraryJson` en visor y KConfig. Sin activar reloj en panel real.
- [x] **Regresión creada:** `test_theme_packs.cjs`; `test_theme_schedule.cjs` adaptada. Revisión V8 focalizada positiva.
- [x] **Suite Node completa: 29/29 PASS en CachyOS (21/11/2026)** tras los cambios de modo/3-4 por pack; el mantenedor también confirmó visualmente la conservación de Playa 24hs (4 franjas) y pack de prueba (3 franjas) al alternar, sin cambios inesperados.
- [ ] **Validación restante Qt/CachyOS:** documentar explícitamente la conservación de preferencias tras cerrar y reabrir por completo el visor; no dar por probada integración real con panel KDE/KWin/Wayland.
- [ ] **Perfiles originales empaquetados:** los tres `Factory*Theme.js` todavía tienen `preset=null`; recibir las capturas auténticas y archivos GIF/imagen correspondientes, revisar derechos y empaquetar. No inferir colores ni activos desde capturas.
- [x] **Decisión funcional de fábrica confirmada (21/11/2026):** usar el **Playa 24hs vigente del mantenedor**, con Día/Atardecer/Noche como único pack original e inmutable. Se preparó `resguardar_original_playa.sh` (**detección `auto` predeterminada por SHA-256 de imágenes**) para guardar localmente la apariencia activa completa, referencias intactas, horarios y recursos, sin cambiar modo automático, Qt Settings, panel ni GitHub. Rechaza perfiles ambiguos. **Pendiente ejecución real en CachyOS, capturas de los tres temas y empaquetado**.
- [ ] **Resguardar y validar originales de Playa 24hs:** **Noche 1/3 resguardado realmente en CachyOS (21/11/2026)** mediante `resguardar_original_playa.sh`, con apariencia Qt completa y referencia histórica separada, **2 recursos gráficos copiados** a carpeta local privada, sin alterar preferencias. **Pendientes:** resguardar Día y Atardecer por cambio horario automático; contrastar los tres perfiles, wallpapers, licencias y recursos, sin fabricar los 14/34 campos ausentes de los históricos. Incorporar a `Factory*Theme.js` solo después de revisión.
- [x] **Auditoría histórica de solo lectura completada en CachyOS (21/11/2026):** suite **29/29 Node PASS**; Día **0 campos faltantes** con logo/fondo disponibles; Atardecer histórico `themeDayJson` **14 campos faltantes** con imágenes disponibles; Noche histórica `themeNightJson` **34 campos faltantes** con imagen disponible. Los históricos NO son perfiles de fábrica y no se rellenan con valores inventados. Pendiente inspección visual y captura exacta por el mantenedor; licencias y wallpapers no verificados.
- [x] **Aprobación funcional 21/11/2026 y código experimental:** modo automático y elección de **3/4 franjas independientes por pack**, con compatibilidad de packs históricos sin borrar horarios. Código [9b59da9](https://github.com/nicoarg87/plasma-smartbar/commit/9b59da9912440ee7d7c473692b39ad0560d8baa8), [8436f49](https://github.com/nicoarg87/plasma-smartbar/commit/8436f499904f0c3e1e0787d5288e51610f25fc73), [d00d54c](https://github.com/nicoarg87/plasma-smartbar/commit/d00d54cb91f9b145eb53fa0b55678c1091743543), [c95e4f7](https://github.com/nicoarg87/plasma-smartbar/commit/c95e4f7aec50ce585c880779d1e539b648f1bfc6). Revisión JS aislada 17/17 positiva, **suite Node nativa 29/29 aprobada en CachyOS** y prueba visual de aislamiento entre packs positiva; continúa pendiente verificación puntual de reinicio completo del visor y compatibilidad final KDE.
- [ ] Evaluar, mediante aprobación del mantenedor, edición de integrantes de packs existentes y wallpapers específicos de temas personales. [Issue #17](https://github.com/nicoarg87/plasma-smartbar/issues/17), arquitectura [#11](https://github.com/nicoarg87/plasma-smartbar/issues/11).

## 23/11/2026 — Prioridad visual de ventanas maximizadas apiladas

- [x] **Confirmado por el mantenedor:** Soledad se alinea con la ventana maximizada **más alta en el apilamiento visual**, aunque la activa sea una ventana normal. Si hay varias maximizadas, no elegir por foco o orden alfabético; al desmaximizar la superior, seguir la próxima; solo con ninguna max retornar a la derecha según preferencia.
- [x] Código experimental en `prototype/v0.1-islas-so`: `RealActiveWindow.topmostMaximizedProfile`, lectura del rol `StackingOrder` de KDE, reconciliación de posiciones y protección para índices inválidos/duplicados; sin tocar panel ni preferencias guardadas.
- [x] **Prueba lógica:** 275 aserciones PASS en V8 con fuentes actuales de GitHub, incluyendo cambios de apilamiento sin cambiar foco; no confundir con Qt/KWin nativos.
- [ ] **Prueba real CachyOS/Wayland:** Steam maximizada → Brave maximizada encima → desmaximizar Brave dejando Steam maximizada → Steam de nuevo; después alternar entre **dos maximizadas** y comprobar `StackingOrder`. Verificar perfiles, estabilidad, ausencia de solapamiento y fullscreen. Si los roles no son fiables, registrar trazas y revisar alcance antes de integrar.
- [ ] Validar por separado multi-monitor, escritorios virtuales, perfiles ausentes, escala y navegadores; no cerrar [issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4) ni fusionar PR #3 todavía.

## 23/11/2026 — Islas sin hueco superior

- [x] **Aprobado:** Soledad y Malvina deben aparecer pegadas al borde superior del contenedor de la barra; en el ensayo LayerShell anclado a la pantalla, margen físico superior 0 px. No cambiar alto configurable, geometrías, posición horizontal ni panel KDE del usuario.
- [x] **Código experimental:** eliminar `top:6` de ambos ensayos LayerShell de Soledad y cambiar `malvinaHotspot`/`systemIsland` de centrado vertical a anclaje superior en `SmartBarContent.qml`. Tests estáticos/de política JS/V8 con fuentes vigentes: 281 comprobaciones PASS.
- [ ] **Prueba real:** `node prototype/v0.1/tests/test_fixed_input_region.cjs` y `bash prototype/v0.1/probar_soledad_entrada_fija.sh` para comprobar Soledad en el límite físico superior, y `bash prototype/v0.1/probar_ancho.sh` para comprobar simultáneamente Soledad y Malvina en el visor, sin reemplazar el panel instalado. Si la barra instalada es flotante, no asumir que alinear componentes mueve el contenedor.

## 23/11/2026 — Malvina LayerTop sobre ventanas, excepto fullscreen

- [x] **Política confirmada:** Malvina debe poder aparecer delante de ventanas normales y maximizadas; en fullscreen real debe ocultarse. Mantener habilitación y autoocultamiento como preferencias separadas, sin alterar ajustes personales.
- [x] Eliminar `previewMaximized` y `hostMaximized` de bloqueo de visibilidad en `SmartBarContent.qml`, conservando `!windowStateKnown`, `previewFullscreen` y `hostFullscreen`.
- [x] Preparar un ensayo **independiente y descartable** de Malvina con LayerShell LayerTop, exclusión -1, anclaje superior izquierdo y máscara de entrada del tamaño de la isla; el nuevo visor fuerza visibilidad SOLO para diagnosticar, sin modificar valores persistidos. El puente nativo espera una lectura segura de `TasksModel.IsFullScreen` antes de mostrar.
- [x] Pruebas JS/V8 simuladas con fuentes GitHub: nuevo contrato 62/62 PASS; regresión de Soledad 281/281 PASS.
- [ ] **Ejecutar Node + QML/KWin real en CachyOS:** `node prototype/v0.1/tests/test_malvina_superposicion.cjs`, `node prototype/v0.1/tests/test_fixed_input_region.cjs`, `bash prototype/v0.1/probar_malvina_superposicion.sh`. Comprobar capa sobre Brave/Steam normal/maximizada, fullscreen real oculta y Esc restaura sin clic, entrada solo sobre isla y autocierre a 90 segundos.
- [ ] Diagnosticar en el visor principal `probar_ancho.sh` las preferencias guardadas `demoLauncherIslandVisible`/`demoAutoHideMalvina`, la simulación de maximización y `Qt.WindowShortcut` de Meta+Space: el ensayo nativo fuerza visibilidad solo para aislar la causa. No dar por corregido el problema del visor hasta observarlo.

## 23/11/2026 — Teclado y clics de Malvina sobre ventanas: regresión prioritaria

- [x] **Probado por mantenedor antes del parche:** Malvina sobre Brave/Steam restauradas y maximizadas; sin interferencia observada durante fullscreen de YouTube y Steam Big Picture.
- [x] **Bug reproducido:** desplegar búsqueda de Malvina deja clics llegar a pestañas de debajo y el editor no acepta teclado. No confundir con fallo de superposición.
- [x] **Fix experimental limitado:** cambiar `KeyboardInteractivityNone` por `KeyboardInteractivityOnDemand`; redimensionar la superficie cuando aparecen el editor y Web/IA, actualizar la máscara de entrada con unión de regiones de controles (sin bloquear el resto del escritorio) y evitar bucle de ancho Popup/Window. No modificar el puente de máscara usado por Soledad ni opciones persistidas. Contrato Malvina: 100 PASS V8, Soledad 281 PASS V8.
- [ ] **Validación nativa inmediata:** `bash prototype/v0.1/probar_malvina_superposicion.sh` tras test Node y git pull: clic lupa→campo no debe activar pestañas detrás, escribir sin Enter; abrir Web/IA y hacer clic; cerrar y verificar clic exterior; repetir fullscreen YouTube para descartar regresiones.
- [ ] Resolver por separado si la versión con preferencias originales del visor `probar_ancho.sh` sigue sin mostrar Malvina: examinar etiqueta de diagnóstico, no resetear valores.

## 23/11/2026 — Malvina: input validado, consulta IA pendiente

- [x] **PROBADO en CachyOS (mantenedor):** Malvina supera ventanas normales/maximizadas, se oculta en fullscreen de YouTube/Big Picture y después del parche recibe teclado (palabra `cerveza`), Tab/Enter, y **clics/arrastre NO atraviesan a pestañas debajo**.
- [x] **Aclaración de foco:** Brave se vuelve translúcida por un efecto KWin de ventana inactiva cuando Malvina recibe foco. No cambiar efectos o impedir foco para ocultarlo; sería romper el buscador.
- [ ] **Consulta Web:** comprobar que `{query}` se entrega al seleccionar Google/DDG mediante la fila Web.
- [ ] **Consulta IA:** ChatGPT/Gemini abren Falkon pero no reciben `cerveza`. El código preserva consentimiento: sin permiso no añade texto, con permiso el `?q=` de ChatGPT es experimental, Gemini no admite precarga fiable por enlace. Necesita una solución explícita de integración y consentimiento; **no** agregar botones, mecanismos de portapapeles automático ni extensiones sin autorización.
- [x] **Cierre del ensayo:** después de 90 segundos se cierra intencionalmente, no es evidencia de error.

## 23/11/2026 — Ordenamiento temporal Web/IA en ensayo Malvina

- [x] **Comprobado en CachyOS:** Web Google y DuckDuckGo recibieron la palabra `cerveza` desde Malvina y abrieron resultados correctos en Falkon; comprobación antirrobot de Google corresponde al servicio externo.
- [x] **Corregido en código experimental:** el ensayo aislado no manejaba `requestMalvinaOrderChange`, a diferencia del visor principal; se agregaron variables de orden exclusivamente de sesión, sin alterar preferencias persistentes ni interfaz. Timeout de este ensayo de 90 a 180 segundos para permitir arrastre, y log de gesto para diagnóstico.
- [x] **Prueba de regresión simulada:** contrato Malvina 115 comprobaciones PASS, Soledad 281 PASS, `MalvinaSlots.order` devuelve `duck,google,yahoo` como corresponde. **No son pruebas QML/Wayland nativas.**
- [ ] **Comprobar en CachyOS:** arrastrar DuckDuckGo hasta el primer lugar de la fila Web, verificar orden visual y de selección; si falla distinguir ausencia de log del gesto de la señal de orden temporal. Mantener orden de la sesión, no persistirlo desde el ensayo.

## 23/11/2026 — Restauración del foco de Malvina tras reordenar proveedores

- [x] **PROBADO POR EL MANTENEDOR:** el ensayo permite arrastrar un proveedor y cambiar su orden; luego, `Enter` para confirmar y segundo `Enter` para buscar NO hacían nada hasta volver a clicar el campo con la consulta.
- [x] **FIX EXPERIMENTAL:** `MalvinaSearch.applyOrder` devuelve foco al editor; `activeEditorFocus` reafirma foco después del evento mediante `Qt.callLater`; `DragHandler` hace lo mismo al soltar. No se modifican búsqueda Web, URL, consentimientos IA, máscara de entrada, fullscreen, orden guardado ni panel KDE.
- [x] **TESTS SIMULADOS:** Malvina 139 PASS, con simulación de `Tab → Enter confirma → Enter busca` después del cambio de orden y restauración inmediata/diferida de foco; Soledad 281 PASS. No sustituye prueba Qt/KWin nativa.
- [ ] **RETEST EN CACHYOS:** arrastrar DuckDuckGo a primer lugar de Web, mantener el texto `cerveza`, usar `Tab` hasta Web y dos veces `Enter` sin hacer clic en el editor; debe abrir Falkon con resultados de DuckDuckGo. Repetir después de elegir una ficha con el mouse. Si falla, conservar logs de Konsole. Orden temporal del ensayo continúa sin persistirse y autocierre sigue en 180 s.

## 23/11/2026 — Navegador elegido de Malvina para Web e IA; Gemini en espera

- [x] **Requisito confirmado:** Configuración → Malvina → General contiene una **única** opción de navegador para **toda búsqueda Web y acceso IA**, con alternativa **«Predeterminado del sistema (KDE)»** y navegadores instalados detectados, sin cambiar el predeterminado global KDE. Mantener los campos de proveedor separados y autorización IA por proveedor. No añadir pestañas ni botones.
- [x] **Ensayo nativo implementado (no validado aún en CachyOS):** `MalvinaProvidersPage.qml` ComboBox conecta navegador al modelo; `SoledadSettings.qml` guarda solo con Aplicar; `SmartBarContent.qml` recibe una sola señal `requestOpenUrl` de `MalvinaSearch.qml`; `native_probes/soledad_input_mask_main.cpp` detecta ejecutables de lista fija mediante `QStandardPaths::findExecutable`, y los abre mediante `QProcess::startDetached(program, [url])` o usa `QDesktopServices::openUrl` para KDE. No ejecutar comandos arbitrarios ni shell.
- [x] **Persistencia del ensayo aislada:** `preview_malvina_input_mask.qml` usa `plasma-smartbar-v01-malvina-layer-probe-browser/selectedBrowserV1`; inicia en `system`; valida ID antes de guardar; conservados por separado los consentimientos IA confirmados por el usuario.
- [x] **Pruebas limitadas:** `test_malvina_browser_choice.cjs`; tests de Enter y compilación QtCore actualizados. Inspección directa de fuentes GitHub 27/27 checks PASS y simulación de manejadores 3/3; **no es ejecución Node/CachyOS**.
- [ ] **Prueba funcional en Fish/CachyOS:** selector muestra navegador KDE y alternativas detectadas; elegir Brave, Aplicar, buscar con DuckDuckGo y confirmar que abre Brave; reiniciar ensayo y comprobar selección; volver a KDE y comprobar que abre el predeterminado Falkon; asegurar que Web e IA comparten selección sin repetir inicios de sesión. Si falla, conservar error CMake/QML de Konsole.
- [ ] **Integración futura en visor/plasmoide real:** soporte equivalente en anfitriones sin el puente del ensayo, detección de instalaciones Flatpak y compatibilidad de otros navegadores solo después de validar esta etapa. Actualmente estos anfitriones siguen abriendo con KDE, no presentar la selección como terminada para ellos.
- [ ] **Gemini:** se aplaza la precarga de consultas mientras no exista una vía verificada y aprobada. **No bloquear el resto de Plasma SmartBar** ni usar portapapeles/extensiones por iniciativa propia.

## 23/11/2026 — Cierre automático de Malvina tras buscar

- [x] **Requisito confirmado:** después del Enter que **ejecuta** una consulta, cerrar campo y selector de motores Web/IA y ocultar la isla Malvina, independientemente del proveedor y del navegador elegido. El Enter previo que solo confirma proveedor NO cierra. No cambiar preferencias de habilitación/autoocultamiento.
- [x] **Implementación experimental:** `SmartBarContent.qml` recibe la apertura Web/IA ya compartida por `MalvinaSearch.qml`; si `launchWebUrl` o `Qt.openUrlExternally` acepta la apertura, `dismissMalvinaAfterSearch()` cierra la búsqueda y oculta temporalmente Malvina. Si no acepta el inicio, permanece abierta. Reaparece con nuevo hover de 600 ms o activación explícita, sin añadir botones. [c72d59d](https://github.com/nicoarg87/plasma-smartbar/commit/c72d59db3401bebed4d5d193f4fe7dc99c4a301b), [c3eadbf](https://github.com/nicoarg87/plasma-smartbar/commit/c3eadbf81536bcaa75c25764e5212eb70cf2b700).
- [x] **Pruebas de código añadidas/actualizadas:** `test_malvina_browser_choice.cjs` ([e10920f](https://github.com/nicoarg87/plasma-smartbar/commit/e10920fbf0152b7857a96fad7379a30e2747eef9)) y `test_malvina_dismiss_on_search.cjs` ([35f4772](https://github.com/nicoarg87/plasma-smartbar/commit/35f4772db774d16f3d82b08cbe628acb1e3c98c9)); 8/8 comprobaciones V8 aisladas PASS, no son pruebas Qt nativas.
- [ ] **Prueba en CachyOS, comandos Fish:** tras `git pull --ff-only`, correr ambos tests Node y `bash prototype/v0.1/probar_malvina_superposicion.sh`; buscar `cerveza` con DuckDuckGo/Google usando Brave, verificar desaparición inmediata de Malvina y vuelta tras salir/reingresar con el cursor; comprobar segundo Enter de IA sin revalidar login y confirmar que fullscreen/panel KDE quedan intactos.


## Modularización de la bandeja — 26/11/2026

- [x] Separar el modelo de muestra (`SystemTrayModel.js`), las reglas puras de alternancia/autocontracción (`SystemTrayController.js`) y el delegado visual (`SystemTrayView.qml`) en componentes propios y enlazarlos a Soledad.
- [x] Mantener los iconos simulados anteriores, su aspecto y sus gestos; conservar el modelo directo `Row`/ `Repeater` para que los botones sigan ocupando una sola fila sin alterar transparencias.
- [x] Añadir test Node `prototype/v0.1/tests/test_system_tray_modules.cjs` y revisar estructuralmente las conexiones.
- [ ] Ejecutar la nueva composición en CachyOS cuando corresponda usarla; no imponer baterías de regresión para funciones ya aprobadas.
- [ ] **Bandeja real KDE:** construir el proveedor StatusNotifierItem/StatusNotifierWatcher en módulo aislado, descubrir iconos y acciones auténticas y verificar compatibilidad real; [issue #24](https://github.com/nicoarg87/plasma-smartbar/issues/24).
- [ ] Seguir dividiendo progresivamente `SmartBarContent.qml` y `SoledadSettings.qml`, cuidando estados cruzados sin reconstruir funciones estables ni cambiar el panel actual.

**Estado:** primer corte modular conectado, pruebas JS puras aprobadas, ejecución QML de la nueva composición y proveedor KDE real pendientes.


## Segundo corte de modularización — 26/11/2026
- [x] `SoledadExpansionPolicy.js`: separar reglas de convivencia SO/bandeja del estado y la vista.
- [x] `SoledadLauncherPlacement.js`: compartir el cálculo de posición horizontal del launcher en los contextos Qt y LayerShell.
- [x] `SoledadTaskSizing.js`: separar cálculo de ancho de nombres de ventanas manteniendo el máximo de 160 px y la persistencia original.
- [x] Integrar estas políticas en `SmartBarContent.qml` ([cc00828](https://github.com/nicoarg87/plasma-smartbar/commit/cc0082856a26783b467fc65e5cd09d6b3680b486)), y agregar `test_soledad_layout_modules.cjs` ([85ced0c](https://github.com/nicoarg87/plasma-smartbar/commit/85ced0ce6d74ee9f26e8fb9809563764479e3462)).
- [x] Verificación interna: 720 comparaciones contra la lógica anterior y seis contratos QML verificados, sin diferencias.
- [ ] Ejecutar la composición QML refactorizada en CachyOS cuando corresponda: no invalida pruebas anteriores de funciones estables ni requiere repetirlas por costumbre.
- [ ] Continuar extracción progresiva de vistas y configuraciones, especialmente `SoledadSettings.qml`, sin rediseñar funciones.
- [ ] Conectar indicadores reales KDE de la bandeja por proveedor separado ([issue #24](https://github.com/nicoarg87/plasma-smartbar/issues/24)); seguimiento general de modularización [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).
