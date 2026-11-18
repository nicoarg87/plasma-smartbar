# Protocolo de continuidad entre conversaciones de ChatGPT

**Proyecto:** Plasma SmartBar Islands  
**Repositorio oficial:** https://github.com/nicoarg87/plasma-smartbar  
**Propósito:** impedir pérdida de contexto, cambios de criterio no aprobados y afirmaciones incorrectas sobre el estado del software.

## 1. Fuente de verdad y jerarquía

Para retomar el desarrollo, consultar **la versión actual en GitHub**, no basarse exclusivamente en recuerdos o conversaciones anteriores.

1. [Constitución técnica](CONSTITUCION_TECNICA.md): invariantes y autoridad funcional.
2. [Manual Maestro](MANUAL_MAESTRO.md): diseño detallado, estados, variantes y decisiones.
3. [Estado actual](ESTADO_PROYECTO.md): qué se creó, qué se comprobó y qué falta.
4. [Hoja de ruta](../ROADMAP.md) e [issues](https://github.com/nicoarg87/plasma-smartbar/issues): siguiente trabajo.
5. [Gobernanza](../GOVERNANCE.md) y [normas de contribución](../CONTRIBUTING.md).
6. Conversaciones y bocetos: contexto histórico, **no** autoridad por encima de decisiones confirmadas.

**No considerar que un chat, su memoria o un resumen sustituye leer las fuentes.** Si GitHub no estuviera accesible, indicar con precisión qué documento falta antes de modificar especificaciones o escribir código que dependa de él.

## 2. Arranque obligatorio de un nuevo chat

Ante «retomemos Plasma SmartBar», el asistente debe:
1. Identificar que se trata del repositorio **nicoarg87/plasma-smartbar**, distinto de **proyecto-editor**.
2. Revisar los documentos anteriores, especialmente la Constitución, Manual y Estado actual, usando el conector de GitHub si está disponible.
3. Resumir en pocas líneas: **decisiones confirmadas / estado real verificado / siguiente paso pendiente / riesgos abiertos**.
4. No pedir al usuario que repita decisiones ya documentadas.
5. Antes de proponer una nueva arquitectura, comprobar si contradice requisitos aprobados. Las nuevas ideas se etiquetan **PROPUESTA**, nunca **CONFIRMADO** sin decisión del director funcional.

## 3. Identidad, autoridad y licencia

- Director funcional y de diseño: titular del repositorio oficial (usuario GitHub **nicoarg87**).
- Se puede delegar programación, pruebas, documentación y revisión; los colaboradores proponen mediante issues y pull requests.
- **Decisión posterior del 16/11/2026:** el código y la documentación propios usan **MIT**; versiones históricas GPL-3.0 conservan permisos previos. Los recursos gráficos se documentan con licencia propia. Nadie puede modificar el repositorio oficial sin permisos de escritura autorizados.
- No cambiar licencia, visión principal, requisitos confirmados o reglas de gobernanza sin aprobación explícita del director.
- Rama principal: **main**. La regla activa de GitHub **«Proteccion de main»** se creó para bloquear borrado y force pushes; no equivale a revisión obligatoria de PR.

## 4. Resumen de diseño irrenunciable

- Complemento para **Linux + KDE Plasma 6**, primero probado en **CachyOS / Wayland**; GNOME, Cinnamon, Windows y macOS no son objetivos.
- Barra de **grosor invariable** con dos ubicaciones horizontales aprobadas: **superior (predeterminada)** e **inferior (configurable, no implementada)**. **No ajustar automáticamente la altura de SmartBar según la ventana activa**; medición de barra de título externa en investigación y no aprobada. Al expandirse, ninguna lista crea una segunda fila, mueve pestañas ni redimensiona la aplicación.
- Lanzador izquierdo: aplicaciones **instaladas**. Botón **SO** derecho: aplicaciones/ventanas **abiertas**.
- **Ancho del contenedor:** ambos extremos deben seguir el **ancho útil real**, con isla 2 a la izquierda e isla 1 y controles fijos a la derecha; al redimensionar visor/panel deben reajustarse sin recargar. No agregar fondo continuo: solo superficies separadas por defecto. **Parche `Layout.fillWidth` publicado en PR #3, pendiente de comprobar en CachyOS**; Plasmoidviewer puede agregar sus márgenes y restricciones.
- **Lanzador flotante anclado a isla 1 (confirmado y bug observado, pendiente de retest):** al mantener SO, el menú de aplicaciones debe abrirse **debajo de la POSICIÓN ACTUAL de isla 1**, incluso después de arrastrarla al centro/izquierda. En CachyOS se observó el popup a la derecha a pesar de SO en el centro; QML calculaba `x` con `soButton.mapToItem()` sin dependencia explícita del arrastre. Parche [51aad39](https://github.com/nicoarg87/plasma-smartbar/commit/51aad39b0b448074779d15fd131cc7a6ed0e5032) usa `systemIsland.x + systemIsland.width` para centrarlo y ajustarlo a los límites. **CÓDIGO MODIFICADO, AÚN NO PROBADO EN CACHYOS**. No variar altura ni controles, en modo inferior futuro abrirá hacia arriba.
- **SO con dos gestos (confirmado, 14/11/2026):** clic breve sigue mostrando aplicaciones/ventanas abiertas; mantener SO ~400 ms abre lanzador de aplicaciones **instaladas** (en v0.1 solo menú flotante **simulado**). Soltar tras gesto largo no activa clic breve. Isla 2 **visible por defecto**; clic derecho sobre ella → ocultar. SO → clic derecho → mostrar isla 2. KConfig `showLauncherIsland=true` declarado, **pendiente de comprobar**. El ocultamiento automático es **propuesta futura SIN disparador aprobado**, no implementado. Prototipo en PR #3 aún no probado en CachyOS tras cambio.
- **Islas visuales:** isla 1 derecha (**principal**, SO y bandeja), isla 2 izquierda (**secundaria**, lanzador ocultable, visible por defecto), isla 3 (buscador visible) opcional y oculta por defecto; sin fondo continuo por defecto.
- **Memoria aprobada de posición por aplicación:** con Steam, Dolphin, Brave u otra ventana **activa/maximizada**, el usuario arrastra isla 1 y hace **clic derecho sobre ella → «Recordar esta posición para [aplicación]»**. Al volver a activar/maximizar esa app, la isla recupera la posición; al activar otra, su perfil; en segundo plano no aplica. El retorno global al desmaximizar sigue activado por defecto. Controles de ventana NO se mueven. **Pendiente de programar y probar**; [issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4).
- **Geometría simétrica de maximización (corrección experimental pendiente de prueba):** si la **isla 1** fue arrastrada manualmente y «Alinear a la derecha» está destildado, al **activar** la maximización **NO debe saltar hacia la izquierda** simplemente porque aparezca la reserva de botones `− □ ×`. Conservar su coordenada visual; si está demasiado cerca, desplazarla solo lo imprescindible para no cubrir controles. A la inversa, al desmaximizar con retorno desactivado, conservar posición compensando controles que desaparecen. Parche en `SmartBarContent.qml` del PR #3, registrado en issue #1, **NO probado aún en CachyOS tras cambio**.
- **Geometría de desmaximización:** con «Volver a la derecha al desmaximizar» **desactivada**, al quitarse los controles fijos no debe moverse visualmente la isla 1: compensar el margen que liberan esos controles. Con retorno activado, volver a la derecha como antes. **Fallo observado en CachyOS, parche QML en PR #3, aún no vuelto a probar** (issue #1).
- **Alineación de isla 1 (confirmada, v0.1 sin probar después de editar):** casilla contextual «Alinear isla 1 a la derecha» marcada por defecto. Arrastrar la isla con los seis puntos **la destilda automáticamente**, sin exigir destildarla antes, y la isla se queda donde se soltó. Volver a tildar **reubica inmediatamente** isla 1 en su referencia derecha (junto a controles fijos si maximizada). La opción independiente «Volver a la derecha al desmaximizar» sigue activada por defecto y **no hace retornar al soltar el agarre**, solo cuando se desmaximiza. Mover no guarda perfil por aplicación.
- **Agarre horizontal aprobado (sin mover los controles de ventana):** **seis puntos discretos (dos columnas de tres)** **inmediatamente a la derecha de SO**, antes de controles de ventana si está maximizada. **SO y agarre no se mueven al expandir/contraer bandeja o SO**. El agarre reubica horizontalmente la isla 1. **Cuando se desmaximiza, la isla vuelve por defecto al extremo derecho**, mediante preferencia persistente y desactivable en configuración; con opción desactivada puede conservar su ubicación. **Hay una implementación solo en demo QML en rama experimental**, usando maximización ficticia y casilla KConfig; límites y comportamiento con KWin/Wayland reales pendientes de probar.
- SO expande fichas hacia **la izquierda en una única fila**; agrupa ventanas por aplicación por defecto, con opción de desagrupar.
- **Personalización visual confirmada y código de prueba sin validar (14/11/2026):** el usuario envió huella violeta/azul como **logo predeterminado del botón SO dentro de Soledad**, elegible desde menú de clic derecho seis puntos. Se permite foto PNG/JPG/WebP/SVG o GIF, editor de encuadre/zoom no destructivo, máscara **cuadrado, círculo, rombo ♦, corazón ♥, estrella ★**. Gif opcional y pausable; no cambiar tamaño ni gestos SO. Distribuidor de distro puede empaquetar logo; detección automática aún pendiente. Soledad/Malvina con color y transparencia separados, **fondo general opcional desactivado por defecto**. No sustituir la antigua **isla 3 buscadora** por la nueva capa de fondo sin confirmación de numeración. Implementado solo en PR #3 con `LogoArtwork.qml`, `LogoEditor.qml`, `AppearanceEditor.qml`, `IslandButton.qml` y PNG `assets/so-paw.png`; KConfig prevista, **todo pendiente de prueba real en CachyOS**. [Issue #5](https://github.com/nicoarg87/plasma-smartbar/issues/5).
- **ANTECEDENTE SUPERADO el 16/11/2026 — Nuevo indicador SO condicional (14/11/2026):** **sin ventanas → botón normal, sin brillo ni animación de contorno**; con ventanas → borde fino en la misma forma del logo, modo **off/fijo/recorrido sutil**, color editable, grosor **0,5–2 px**, movimiento opcional. Predeterminado **brillo fijo sin movimiento**. Contar ventanas reales incluidas minimizadas con KDE TasksModel **todavía pendiente**. En la maqueta hay simulación de **3 o 0** ventanas desde menú de seis puntos; efecto `SoActivityOutline.qml` solo se crea cuando hay ventanas y está habilitado, temporizador opcional ~15fps solo en modo recorrido. Editor `SoActivityEditor.qml` y claves KConfig nuevas. Esta es una excepción autorizada y delimitada a «MVP sin animaciones», sin animar SO/bandeja/islas en general. **No ejecutado todavía en CachyOS**.
- **SO clic breve con popup abierto (confirmado 14/11/2026, pendiente de retest):** usuario confirmó que SO sostenido abre lanzador **sin cerrar fichas ni bandeja**, pero luego detectó que **clic corto sobre SO para cerrar el popup también contraía fichas SO**. Regla vigente: si el lanzador flotante está visible, el clic breve en SO **cierra SOLO el popup y retorna**, preservando `soExpanded` y `trayExpanded`. Si no hay popup, SO abre/contrae fichas normalmente. Parche [8a79f3f](https://github.com/nicoarg87/plasma-smartbar/commit/8a79f3fcad849ed252c284ba004bf88e173f00cb) en PR #3, **pendiente de prueba en CachyOS**. Se mantienen autocontracciones tras selección/falta de espacio.
- **SO sostenido sin contraer ya PROBADO EN CACHYOS:** el mantenedor dijo «Ahora sí, quedó genial» después del cambio 9175734 para mantener los grupos horizontales mientras abre el flotante; no extender esta validación al nuevo cierre por clic corto.
- **SO sostenido NO contrae SO ni bandeja (decisión corregida 14/11/2026):** el mantenedor observó en CachyOS que al tener **SO y bandeja expandidos** y mantener presionado SO ~400 ms, el menú flotante se abría pero cerraba ambos grupos. Este comportamiento **está rechazado**: el menú flotante debe aparecer bajo la isla de origen **sin alterar `soExpanded` ni `trayExpanded`**. La falta de ancho horizontal entre ambos conjuntos y la autocontracción por selección real siguen siendo reglas separadas. Se eliminó el cierre heredado en `openInstalledLauncher()` del PR #3, [commit 9175734](https://github.com/nicoarg87/plasma-smartbar/commit/917573452335e979212a46dd84fb9c3813dd5f15); **parche aún sin retest en CachyOS**.
- **Malvina toggle VALIDADO en CachyOS:** el mantenedor confirmó «Espectacular. Funciona como tiene que funcionar» al probar que segundo clic en Malvina cierra el lanzador. El fix 304f33e queda **PROBADO para ese caso de la maqueta**, no para integraciones reales.
- **Bug de doble clic en Malvina (14/11/2026):** en CachyOS Malvina abría el lanzador, pero **el segundo clic no lo cerraba**. `Popup.CloseOnPressOutside` cerraba el menú al presionar el botón, luego `onClicked` lo reabría. Parche [304f33e](https://github.com/nicoarg87/plasma-smartbar/commit/304f33e89074fa57d71eadded58a461de5043a9d) cambia a `CloseOnPressOutsideParent` y conmuta explícitamente `open()/close()` según el origen. **Implementado en PR #3, NO PROBADO TODAVÍA en CachyOS**. Probar clic M abre/cierra, Esc y clic fuera, y SO sostenido con popup bajo Soledad.
- **Separador SO/bandeja y lanzador por isla (confirmado, 14/11/2026):** en CachyOS el mantenedor **validó** que ambas expansiones pueden convivir. Observó que faltaba distinción entre los iconos; al estar ambas abiertas, mostrar **línea vertical sutil** entre bandeja y fichas SO, sin segunda fila ni modificar grosor. Además, al pulsar **Malvina** el lanzador aparecía erróneamente debajo de **Soledad**: debe abrirse **debajo de Malvina**, mientras el gesto sostenido de SO sigue abriéndolo bajo la posición actual de Soledad. Al abrir desde Malvina, no contraer las expansiones de Soledad por defecto. Parche [d2edf83](https://github.com/nicoarg87/plasma-smartbar/commit/d2edf8327ba764dfba646a7b817bf70f805a0aa2) en PR #3, **pendiente de nueva prueba en CachyOS**, solo apps ficticias.
- **DECISIÓN POSTERIOR CONFIRMADA (14/11/2026):** **Soledad** = isla 1 principal con SO/bandeja/seis puntos; **Malvina** = isla 2 izquierda (visible por defecto, ocultable). **SO y bandeja YA NO son mutuamente excluyentes por defecto:** permanecen ambos desplegados si el espacio horizontal alcanza en una sola fila; si no, se contrae la expansión abierta antes y se mantiene la nueva. Al arrastrar/reducir el ancho mientras ambas están abiertas, conservar la solicitada más recientemente. Esto reemplaza cualquier frase histórica de exclusividad. Flecha de bandeja **◀ cerrada / ▶ expandida**.
- **CIERRE CON IZQUIERDO DEL MENÚ DE LOS SEIS PUNTOS (confirmado 14/11/2026):** el mantenedor **PROBÓ** en CachyOS que el derecho abre opciones. Nueva regla: **clic izquierdo BREVE en los seis puntos CIERRA el menú solo si está abierto**; con menú cerrado **NO lo abre**. Arrastrar con izquierdo debe seguir moviendo Soledad sin confundirse con un clic corto de cierre. Clic derecho sigue alternando abrir/cerrar, teclado Menú/Mayús+F10 y Esc se mantienen. Parche [c083973](https://github.com/nicoarg87/plasma-smartbar/commit/c0839734bd79033d3059e90d1ad7f7a9cb81580c) con `draggedDuringPress`, **pendiente de nueva prueba CachyOS**. El resto del párrafo de gesto anterior debe leerse conforme a esta excepción de cierre.
- **GESTO ACTUAL DE LOS SEIS PUNTOS (confirmado 14/11/2026, pendiente de test):** clic o arrastre con botón **izquierdo** mueve Soledad y NUNCA abre menú; **si ya está abierto, un clic izquierdo breve también lo CIERRA**, sin interferir con el arrastre. **Clic derecho** sobre agarre abre «Opciones de Soledad» y segundo clic derecho lo cierra, sin reabrir. **Tecla Menú** o **Mayús+F10** enfocando agarre como alternativa. Esc y clic fuera cierran el menú. Ya no se abre con clic izquierdo: esta decisión más reciente sustituye expresamente la antigua. Doble clic izquierdo se mencionó pero **NO fue elegido**. Parche [12020b5](https://github.com/nicoarg87/plasma-smartbar/commit/12020b5b6cf9421054101b045d5c0bddfbba8dc2) y [9bd07e0](https://github.com/nicoarg87/plasma-smartbar/commit/9bd07e0d4e00b6ae8a5a3fb2ba5240e17ae20f0e) en PR #3, **todavía sin prueba en CachyOS**. Primera opción de menú sigue «Mostrar Malvina» al ocultarse.
- **Malvina debe ser recuperable desde menú de los seis puntos (CONFIRMADO 14/11/2026):** el mantenedor ocultó Malvina en CachyOS y **no encontró** cómo volver a mostrarla usando los accesos anteriores (clic derecho de SO y lanzador sostenido). La **primera acción del menú habitual del agarre de seis puntos de Soledad** (ahora por clic derecho) debe ser **«Mostrar Malvina (isla 2)»** cuando está oculta, y **«Ocultar Malvina (isla 2)»** cuando está visible; mostrar ayuda contextual cuando falta Malvina. La preferencia sigue visible por defecto y ligada a KConfig. Parche [1953f21](https://github.com/nicoarg87/plasma-smartbar/commit/1953f21b1e8db883c0c03fab2aa70478b7f6b4f9) PR #3, **pendiente de prueba en CachyOS**.
- **Recuperar Malvina:** si está oculta, abrir lanzador SO con pulsación sostenida (~400 ms) → botón **«Mostrar Malvina (isla 2)»** de un clic, además del menú contextual SO. El mantenedor reportó que la forma anterior no era fácil de descubrir. **Código experimental, no probado después de añadirlo**.
- **Autocontracción independiente aprobada:** menú de seis puntos → «Configuración de autocontracción»: **SO al seleccionar ventana** activada por defecto, **bandeja tras usar icono** desactivada por defecto. Son opciones distintas y no impiden que ambos estén abiertos cuando entran. No hay autocierre por temporizador aprobado. KConfig `autoCollapseSO`/`autoCollapseTray` y demo QML, pendientes de prueba en CachyOS y con iconos reales.
- **Marca del producto:** el usuario mencionó «Malvina» también al hablar del nombre del proyecto. Se conservó `nicoarg87/plasma-smartbar` sin renombrar hasta aclarar el alcance. Las denominaciones de las ISLAS Soledad/Malvina sí quedaron anotadas.
- **VALIDACIÓN en CachyOS:** el mantenedor confirmó que el popup SO sigue a isla 1 arrastrada, «Ahora sí, permitió usarse perfectamente». Este punto pasó a **probado para la maqueta Qt**, no para aplicación real.
- SO se contrae tras seleccionar ventana por defecto; configuración alternativa de permanencia y modo de visibilidad adaptable a navegadores.
- Con ventana maximizada, los controles **propios de SmartBar** minimizar/restaurar/cerrar están **ANCLADOS al extremo derecho, independientes de isla 1 y de su agarre** (no siguen el arrastre). Aparecen en el mismo borde elegido: arriba en modo superior, **abajo en modo inferior**. No afirmar que los botones originales de cualquier aplicación pueden reubicarse: las decoraciones propias y KWin/Wayland requieren pruebas. En modo superior, la barra prioriza su capa sobre pestañas **sin desplazarlas**, viabilidad técnica por demostrar.
- **Fullscreen real** oculta las islas. Los paneles secundarios flotan hacia el interior de la pantalla (**debajo** desde el modo superior, **encima** desde el inferior); la flecha vertical pertenece a la bandeja.
- **Laterales verticales izquierdo/derecho:** experimentales, fuera del compromiso de versiones iniciales. Diseñar lógica de ventanas independiente de orientación y anclaje para facilitar futuras pruebas; no afirmar soporte vertical probado. El modo inferior se registró en el [issue #2](https://github.com/nicoarg87/plasma-smartbar/issues/2), posterior a la primera prueba [#1](https://github.com/nicoarg87/plasma-smartbar/issues/1).
- Primero rendimiento, estabilidad, accesibilidad y **sin animaciones**. MPRIS, temas avanzados, efectos decorativos y expansiones futuras solo después del MVP. La animación opcional «gaveta de SO» al minimizar queda para una fase posterior. El agarre se incluyó ya en la **demostración v0.1 no ejecutada**; la integración real con KWin se abordará más adelante.
- No generar imágenes conceptuales salvo que el usuario las pida; los renders rechazados no son requisitos.

## 4.1. Decisión posterior sobre SO y errores visuales (14/11/2026)

**PRIORIDAD VIGENTE POR ENCIMA DE LAS REFERENCIAS HISTÓRICAS DE ESTE ARCHIVO:** el mantenedor corrigió la maqueta y aprobó **clic derecho en SO → abrir DIRECTAMENTE el lanzador de aplicaciones**, sin menú contextual intermedio; **clic izquierdo breve SO → ventanas abiertas**; **izquierdo sostenido ~400 ms → mismo lanzador**. «Mostrar/Ocultar Malvina» debe ser la **primera acción de Opciones de Soledad, accesibles por clic derecho en los seis puntos**, y deja de ofrecerse al hacer derecho en SO. Otras rutas específicas de Malvina (menú propio y botón de recuperación del lanzador) se conservan.

El menú de los **seis puntos** debe abrir **debajo de la posición horizontal actual de Soledad**, sin taparla; botón izquierdo breve lo cierra si está abierto y el arrastre izquierdo mueve la isla como antes. En modo inferior futuro el menú abre hacia arriba. El logo SO debe presentar **una sola forma elegida** (cuadrado/círculo/rombo/corazón/estrella): no combinar fondo redondo de botón con borde luminoso de figura diferente. El contorno de actividad, si se activa, sigue la misma forma; con cero ventanas no aparece.

**IMPLEMENTADO SOLO EN QML EXPERIMENTAL, NO PROBADO TRAS LOS PARCHES EN CACHYOS:** `SmartBarContent.qml` y `IslandButton.qml` modificados en PR #3 ([87ff742](https://github.com/nicoarg87/plasma-smartbar/commit/87ff74286db19a0e2a87b80411e98468a9886416), [715160e](https://github.com/nicoarg87/plasma-smartbar/commit/715160e105c0865eab403540f38fa61199a2d465), [dc5453a](https://github.com/nicoarg87/plasma-smartbar/commit/dc5453ab9a9d347e70bd477f8e3d29ed1cf912a4)). Menú con `QQC2.Popup.Window` requiere validar posición/cierre en KWin/Wayland. Editor de zoom, encuadre y GIF existe pero necesita pruebas. Guía actualizada `prototype/v0.1/README.md`. **Documentación rector vigente:** Constitución v1.24, Manual Maestro v0.33. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [issue #5](https://github.com/nicoarg87/plasma-smartbar/issues/5).

## 4.2. Centro de Configuración de Soledad (14/11/2026)

**DECISIÓN CONFIRMADA MÁS RECIENTE:** el usuario pidió reemplazar las tres ventanas de personalización separadas (logo/GIF, colores/transparencia, contorno de actividad) por **una sola ventana «Configuración de Soledad»**, con acceso desde clic derecho en los seis puntos. Debe contener cinco pestañas: **Logo SO, Apariencia, Contorno, Autocontracción, Islas y posición**. Añade en estas últimas las preferencias de SO/bandeja, Malvina visible/oculta, alineación, retorno a la derecha al desmaximizar y comando inmediato para mover la isla a la derecha. El acceso rápido «Mostrar/Ocultar Malvina» sigue siendo primera entrada del menú de los seis puntos; el clic derecho sobre SO abre directamente el lanzador de aplicaciones como ya estaba aprobado.

**Reglas de uso:** una ventana dimensionada para el contenido de mayor tamaño, con desplazamiento por pestaña en pantallas más bajas; botones **Aplicar** (aplica y NO cierra) y **Cerrar** (cierra) siempre visibles. Al cerrar sin aplicar, el próximo ingreso debe leer los últimos valores aplicados. No forzar alineación al aplicar otros ajustes si el usuario movió Soledad y no cambió esa casilla. **La posibilidad futura «Añadir isla extra» se difiere explícitamente**, sin programarla ni modificar la isla 3 buscadora.

**Estado de implementación:** nuevo `SoledadSettings.qml` y cambios de `SmartBarContent.qml` publicados **solo en PR #3 experimental**; los tres editores anteriores permanecen como archivos históricos, pero ya no se instancian al abrir configuración desde el menú. [Guía v0.1](https://github.com/nicoarg87/plasma-smartbar/blob/prototype/v0.1-islas-so/prototype/v0.1/README.md) actualizada; Constitución Técnica **v1.25**, Manual Maestro **v0.34**, Estado del Proyecto y ROADMAP también. **Todavía no hay prueba ejecutada después de estos cambios en CachyOS/Wayland**, y la persistencia real de KConfig sigue pendiente. Mantener issues #1/#5 y PR #3 abiertos; proteger panel KDE instalado.

## 4.3. Geometría personalizable, rotación y Acerca de (15/11/2026)

**DECISIONES FUNCIONALES CONFIRMADAS POSTERIORES:** el usuario puede elegir la **altura global de la barra**, constante durante la apertura de SO/bandeja, y **dimensiones y esquinas de Soledad y Malvina** por separado. El botón SO puede ser más ancho: cuadrado clásico, rectángulo de esquinas rectas, redondeado, cápsula u óvalo horizontal, con ancho ajustable. El logo foto/GIF admite control gradual de rotación, no destructivo. Sigue vigente una sola fila, controles de ventana fijos y ausencia de alteración del panel instalado.

**Orden de pestañas aprobado:** Logo SO, Contorno, Apariencia, Islas y posición, Autocontracción, Acerca de. Botones **Restablecer** por cada una de las cinco pestañas editables, además de Aplicar que no cierra y Cerrar independiente. **Actualización del 15/11/2026:** la pestaña Acerca de muestra autor **nicoarg87**, correo público de consultas **nicoarg87@gmail.com** confirmado expresamente, enlace al GitHub oficial y a la licencia **GNU GPL versión 3**, con advertencia visible **SIN NINGUNA GARANTÍA** (en la medida legal aplicable). Un botón abre el cliente de correo mediante `mailto:` sin enviar automáticamente nada. **PayPal/Cafecito se dejan de lado por ahora, no incluir enlaces de donaciones**. Personalización futura de agarre/bandeja y nueva isla diferidas.

**ESTADO:** código creado en rama experimental [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) y enlazado con KConfig previsto y vista Qt aislada; revisión estática de enlaces y delimitadores, **SIN test real en CachyOS/Wayland de esta versión**. Constitución **v1.28**, Manual Maestro **v0.37**, Estado/ROADMAP/README actualizados. No afirmar que el panel Plasma real respeta tamaño solicitado hasta prueba. Issues #1 y #5 siguen abiertos.

## 4.4. Nuevas terminaciones y orden de Acerca de (15/11/2026)

**CONFIRMADO POR EL MANTENEDOR:** «Acerca de» muestra autor `nicoarg87`, correo `nicoarg87@gmail.com`, **repositorio GitHub y botón inmediatamente debajo del contacto**, luego explicación GNU GPL v3 y aviso **SIN NINGUNA GARANTÍA** con botón de lectura LICENSE. Sin donaciones. Soledad adopta por defecto **izquierda redondeada/derecha recta**; agarre de seis puntos **cuadrado**. En «Islas y posición» se configuran estilos de Soledad (redondeada completa, cuadrada completa, dos mixtas y punta triangular izquierda opcional), Malvina (cuatro formas básicas, redondeada inicial), agarre (cuadrado/redondeado) y botón de bandeja simulada (redondeado/cuadrado). Cambiar forma no cambia alto ni bloquea arrastre; el texto/icono personalizado de bandeja y agarre sigue diferido.

**IMPLEMENTACIÓN:** rama experimental PR #3 con `SmartBarContent.qml`, `SoledadSettings.qml`, `IslandButton.qml`, `preview_redimensionable.qml`, `main.qml`, `main.xml`. Las esquinas independientes de QtQuick Rectangle (desde Qt 6.7, `tech preview` en 6.8) y el Canvas triangular necesitan validar en CachyOS/Wayland. No se ha ejecutado el nuevo QML, no se ha fusionado PR ni modificado el panel KDE habitual. Constitución **v1.29**, Manual Maestro **v0.38**, Estado y README actualizados; issues #1/#5 abiertos.

## 5. Reglas del trabajo diario

- Separar siempre **HECHO Y PROBADO**, **IMPLEMENTADO PERO NO PROBADO**, **PLANIFICADO** y **PROPUESTA**.
- Para resultados técnicos, mencionar versión del entorno, fecha, evidencia y limitaciones reales.
- No inventar APIs, código ya ejecutado, resultados de pruebas ni compatibilidad universal.
- Preferir piezas reutilizables de Qt 6, QML, Plasma 6 y KWin, verificando versión, licencia y coste en recursos; no introducir dependencias pesadas por comodidad.
- Probar los prototipos inicialmente **sin sustituir el panel KDE en uso**. Toda prueba debe ser reversible y acompañada de instrucciones de recuperación.
- Registrar en GitHub las decisiones aprobadas, descubrimientos y problemas. Para funcionalidades, usar issues/PR y actualizar manual y estado al cerrar una etapa.
- Si aparece una contradicción entre fuentes, mostrarla y solicitar resolución; nunca corregirla silenciosamente mediante una interpretación propia.

## 6. Cierre de cada sesión relevante

Antes de dar por terminado un avance, registrar:
- **Qué quedó confirmado** por la dirección funcional.
- **Qué archivos/issues/commits cambiaron realmente** (con enlaces).
- **Qué se verificó ejecutando pruebas y qué no**.
- **Qué falta / bloqueo o riesgo**.
- **Próxima acción concreta**.

Actualizar [ESTADO_PROYECTO.md](ESTADO_PROYECTO.md) cuando haya un hito o cambio de fase. No convertir una conversación en la única copia del conocimiento.

## 7. Proyecto de ChatGPT (opcional pero recomendado)

El usuario informó que creó un **Proyecto de ChatGPT llamado «Plasma Smart Bar»**, con instrucciones basadas en [PLANTILLA_INSTRUCCIONES_CHATGPT.md](PLANTILLA_INSTRUCCIONES_CHATGPT.md). Los cambios futuros de la plantilla **no se sincronizan solos** con las instrucciones de ese Proyecto. Si se modifica la plantilla, actualizar manualmente el texto de las instrucciones.

El Proyecto de ChatGPT organiza conversaciones e instrucciones, pero **no es el repositorio GitHub**. Los archivos adjuntados al Proyecto pueden quedar desactualizados si se modifican en GitHub: consultar preferentemente las versiones vigentes del repositorio. No asumir que guardar un enlace GitHub sincroniza automáticamente los archivos.

## 8. Mensaje breve para iniciar cualquier conversación

«Retomemos Plasma SmartBar desde el repositorio https://github.com/nicoarg87/plasma-smartbar. Leé la Constitución Técnica, el Manual Maestro, el Estado del Proyecto y el issue de trabajo pendiente. Recordá que dirijo el diseño y no se deben modificar requisitos confirmados sin mi aprobación. Decime qué está realmente hecho, qué falta y cuál es el siguiente paso, sin reinventar la especificación ni generar imágenes.»


## 9. Decisión más reciente: MIT, imagen CC0 y SO estirable (16/11/2026)

- **CONFIRMADO:** cambiar software/documentación propia a MIT; mantener licencias gráficas separadas. Imagen tropical de OpenAI destinada a CC0 1.0 con permiso de explotación comercial en la medida que se posean los derechos; **archivo exacto recuperado en ZIP de prueba**, pero falta incorporar el binario a GitHub.
- **NO INCLUIR** el recurso huella Golden Dog sin comprobar autoría/permiso. Mientras la imagen tropical no esté disponible en el checkout, conservar fallback **texto SO**, sin generar un reemplazo visual ni afirmar que se distribuye la imagen exacta.
- **EDITOR DE SO CONFIRMADO:** lista única de formas geométricas y anchas; modos encajar/rellenar/estirar con zoom que persiste y conserva la deformación, sin modificar bytes de archivos del usuario.
- **PENDIENTE:** retest de la rama experimental PR #3 en CachyOS; se recibió el original tropical durante la conversación y se empaquetó para prueba local, no se distribuye aún desde GitHub. Ver [licencias gráficas](LICENCIAS_RECURSOS_GRAFICOS.md) y [Estado del Proyecto](ESTADO_PROYECTO.md).

## 10. Estado de prueba v0.1 (16/11/2026)

**Nombre público:** Plasma SmartBar Islands; repo técnico sin cambios. **Malvina:** autoocultamiento activo por defecto (`autoHideMalvina=true`), aparición tras 600 ms de hover sostenido, ocultamiento tras 250 ms de salida, opción de desactivar en «Islas y posición». No equiparar autoocultamiento con deshabilitar Malvina. Probar que el área de detección no intercepte clics sobre pestañas reales con KWin/Wayland: todavía no comprobado.

**Imagen tropical:** original recuperado como PNG 1774×887, SHA-256 `0c6e646886ba293db5b53d13f81a7421b4ceaee56d6bd92ed99745da273d4137`. Ruta de la rama: `prototype/v0.1/package/contents/ui/assets/so-tropical.png`; binario solo en ZIP local del chat, no en GitHub. El fallback de texto SO sigue disponible. Ejecutar únicamente el visor Qt con `bash prototype/v0.1/probar_ancho.sh` y registrar pruebas; no instalar panel.

## 11. Contorno luminoso SO: velocidad, estela y tipo de trazo (16/11/2026)

**CONFIRMADO:** agregar en «Configuración de Soledad» → «Contorno» velocidad por número editable (vueltas/s), longitud de la cola (porcentaje del perímetro) y estilo de la luz en movimiento (continuo, puntos o guiones). La rama experimental v0.1 usa valores por defecto 1,0 vuelta/s, 22 % de estela y trazo continuo; permite 0,1–3,0 vueltas/s (paso 0,1), 5–85 % de estela. Coma y punto decimales aceptados. «Restablecer contorno» debe resetear también los tres nuevos controles; «Aplicar» conserva parámetros en la sesión de Qt o KConfig del applet. Cambios en `SoActivityOutline.qml`, `IslandButton.qml`, `SoledadSettings.qml`, `SmartBarContent.qml`, visor Qt y KConfig; el efecto repinta solo cuando la condición de visualización configurada está habilitada (desde el 16/11 también puede ser cero ventanas).

**PROBADO:** análisis estático de propiedades/cableado y API Qt; **NO probado** en el entorno gráfico CachyOS. No alterar el panel existente ni presentar integración KWin/Wayland como resuelta.

## 12. Nuevo default: SO ilumina el acceso a aplicaciones cuando no hay ventanas (16/11/2026)

**CONFIRMADO POR EL MANTENEDOR, CON PRIORIDAD SOBRE EL COMPORTAMIENTO ANTIGUO:** ahora **0 ventanas → luz giratoria predeterminada** y **1+ ventanas → contorno apagado predeterminado**. No interpretar las reglas históricas anteriores que dicen «cero ventanas sin efecto» como vigentes. En «Configuración de Soledad» → «Contorno» hay dos casillas independientes: `soActivityShowWhenEmpty=true` y `soActivityShowWhenOpen=false` al restablecer. `soActivityStyle=orbit` predeterminado; seleccionar «Desactivado» apaga todo. Las combinaciones de casillas permiten ambos, ninguno o uno u otro estado. El reloj de Canvas solo corre si corresponde mostrar la luz móvil en el estado actual.

**SO con cero ventanas:** clic izquierdo breve abre directamente el lanzador/buscador de aplicaciones de muestra; con ventanas mantiene apertura de tareas, clic derecho y pulsación sostenida siguen lanzando búsqueda. No afirmar inicio de apps reales (prototipo). Para probar, cambiar «Simular ventanas abiertas» en la vista previa y «Simular SO SIN ventanas / CON ventanas» en el menú de seis puntos. Aplicar sin cerrar; Restablecer vuelve a los nuevos defaults. Pendiente de prueba visual Qt/CachyOS, persistencia KConfig y TasksModel real. No modificar el panel de usuario.


## 13. Defaults visuales provisionales y autoaparición segura (16/11/2026)

**SO aprobado como diseño inicial:** logo tropical exacto, **cápsula horizontal** de ancho de ensayo 96 px, modo **Estirar** (no cuadrado/encajar), incluido botón «Restablecer logo». El PNG original está en ZIP local del chat; aún no dentro de GitHub.

**Contorno PROVISIONAL para prueba a la espera de OK final:** luz móvil orbit, **1,5 vueltas/s**, **0,75 px**, cola **75 %**, **guiones**, sin ventanas encendido y con ventanas apagado. Aplicar y Restablecer usan esos valores ahora; Qt/CachyOS sin ejecutar tras estos commits.

**Apariencia:** Soledad color muy oscuro `#010111` provisional (el código hexadecimal dictado contenía siete cifras, por lo que se eligió uno válido de seis temporalmente), opacidad 50 %. Bandeja y agarre de seis puntos heredan color y alfa de Soledad, pero cada categoría ofrece color y opacidad propios mediante selector, con persistencia experimental KConfig.

**SEGURIDAD de Malvina e islas futuras autoaparecibles:** prohibido autoabrir islas o lanzadores sobre ventanas maximizadas/fullscreen (juegos, videos). En visor, simulaciones y estado maximizado/fullscreen de ventana Qt bloquean aparición; en plasmoide experimental `windowStateKnown=false` impide toda autoaparición hasta que KWin informe estado global real. No afirmar que se probó con videojuegos ni que el clic atraviesa otras ventanas. No modificar panel del usuario.


## 14. GIF exacto elegido como logo SO definitivo (16/11/2026)

El mantenedor aporta el archivo original **`playa definitiva.gif`**, generado con ChatGPT, y confirma que es **el recurso predeterminado de SO** en lugar de la imagen PNG anterior; informa que el GIF **ya fue probado y es funcional**. Conservar forma **cápsula horizontal**, ancho inicial 96 px, modo **Estirar** y opción para pausar GIF. El archivo es un GIF89a de 439×217 px, 16 cuadros de 140 ms, SHA-256 `a10b34548abae1d3e699d5b92a23f38745b349f9cf73ebc59806fce6f56f5621`. Ya se modificaron `SmartBarContent.qml` para usar `assets/so-tropical.gif` como recurso predeterminado y animarlo en modo «default» y `SoledadSettings.qml` para mostrarlo animado en el editor. **El GIF original está preservado solo en ZIP de prueba del chat, NO incorporado al árbol GitHub**; al ensayar debe extraerse en `prototype/v0.1/package/contents/ui/assets/`. El texto SO sigue como respaldo.

El usuario indica que el GIF fue producido con ChatGPT, por lo que se registra **la misma política gráfica CC0 1.0** que el arte previo, dentro de los derechos disponibles; código MIT independiente. Ver inventario. **Pendiente:** comprobar la nueva integración por defecto en el visor CachyOS tras actualizar GitHub y extraer el ZIP; no afirmar que ese test lo hizo la IA.


## 15. Hora y fecha temporal sobre SO y hover Malvina (16/11/2026)

**REQUISITO CONFIRMADO:** después de posar cursor **180 ms** sobre el **agarre de seis puntos** (no sobre SO), mostrar en la cápsula SO hora local `HH:mm` y fecha `dd/MM/yyyy` durante **3 s**, volviendo al GIF al terminar. Cancelar cuando se pulsa/arrastra/abre menú del agarre. Fuente, tamaño (9–28 px) y color de texto personalizables en pestaña «Logo SO» (inicial Sans Serif, 16 px, `#ffffff`), con restablecimiento y persistencia experimental KConfig. Implementado en rama v0.1, no probado aún gráficamente en CachyOS; no alterar panel instalado.

**MALVINA NO APARECÍA POR HOVER:** en el visor había bloqueo si la **propia ventana de prueba** estaba maximizada; esto confundía prueba de barra con juego/video externo. Se corrigió en [commit 340c8aa](https://github.com/nicoarg87/plasma-smartbar/commit/340c8aa1a690fb0c832346be3facaae6f100c3d5): maximizar solo el visor no bloquea Malvina; «Simular ventana maximizada», «Simular pantalla completa» y fullscreen propio sí lo hacen. Diagnóstico visible en ventana de ensayo. Verificar en CachyOS. El applet experimental mantiene `windowStateKnown=false` y bloquea toda autoaparición por seguridad hasta detección KWin/Wayland, aún sin solución real para otras ventanas. Si Malvina sigue sin abrir en visor normal, investigar HoverHandler y ejecución Qt.

**GIF SO NO VISIBLE:** si se ve texto SO tras la actualización, comprobar que existe `prototype/v0.1/package/contents/ui/assets/so-tropical.gif`: todavía NO está en GitHub (solo en ZIP del chat); `probar_ancho.sh` advierte si no existe. El GIF sigue siendo el predeterminado oficial.


## 16. Primera ejecución del diagnóstico de ventanas reales y corrección de parseo QML (17/11/2026)

El mantenedor ejecutó `bash prototype/v0.1/probar_ventanas.sh` en CachyOS/Fish y el visor **falló antes de mostrar una ventana** con siete mensajes en líneas 86–92: `Property names cannot begin with an upper case letter`. Causa en `preview_ventanas_reales.qml`: propiedades `required property` con inicial mayúscula para roles `AppName`, `IsWindow`, `IsGroupParent`, `ChildCount`, `IsActive`, `IsMaximized`, `IsMinimized`. **Corregido en código** [commit 486db01](https://github.com/nicoarg87/plasma-smartbar/commit/486db01dc1930129d96c1b8cbd79878df477b3a1) usando `required property var model` y lecturas de `model.AppName`, etc., con propiedades locales en minúscula.

**NO probado todavía:** que el QML abra, que exista el import `org.kde.taskmanager` en el equipo, que Qt exponga los roles o que se vean aplicaciones reales. Solo revisión estática; no hay Qt gráfico en el entorno del asistente. Próximo retest en Fish: `cd ~/plasma-smartbar; git pull --ff-only; bash prototype/v0.1/probar_ventanas.sh`. Si falla, recoger nuevo error completo. No modificar panel KDE. Seguir [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).


## 17. Prueba positiva: ventanas reales visibles y reactivas en CachyOS (17/11/2026)

**PROBADO POR EL MANTENEDOR:** después de aplicar [486db01](https://github.com/nicoarg87/plasma-smartbar/commit/486db01dc1930129d96c1b8cbd79878df477b3a1), `bash prototype/v0.1/probar_ventanas.sh` **abre y muestra el modelo real de ventanas KDE**. Captura en la conversación: 3 tareas (Alacritty Normal, Brave Maximizada, qml6 Activa). Confirmó expresamente que **las aplicaciones aparecen/desaparecen** en la lista al abrirlas y cerrarlas. Es una **validación de lectura real de TasksModel en CachyOS**, no solamente análisis estático.

**AÚN NO IMPLEMENTADO:** enlazar el `TasksModel` con las fichas del SO de la barra; agrupación con múltiples ventanas de igual aplicación no comprobada; acciones reales de activar/cerrar/minimizar tampoco probadas. Los estados de juegos/fullscreen, coordinación con KWin, click-through y panel integrado siguen pendientes. No reemplazar el panel del usuario.

**SIGUIENTE PASO CONVENIDO:** integrar solo lectura de ventanas KDE en la vista experimental de SO y validar que su única fila se expanda a la izquierda sin mover pestañas ni controles. Recién después habilitar acciones por etapas. Registrar pruebas en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) / [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3).


## 18. SO con TasksModel real solo lectura (implementado, pendiente de retest; 17/11/2026)

La prueba aislada `probar_ventanas.sh` ya está **PROBADA** en CachyOS por el mantenedor; su `TaskManager.TasksModel` enumera apps y reacciona a apertura/cierre. Se avanzó al paso siguiente **sin alterar el panel ni habilitar acciones reales**: `SmartBarContent.qml` acepta `realTaskModel` opcional, usa su `count` y muestra fichas del `Repeater` con `model.AppName` y roles `IsGroupParent`/`ChildCount`; clic en ficha real solamente `console.log` (no activa/cierra/minimiza). Si el valor es null, mantiene las fichas simuladas anteriores. `preview_redimensionable.qml` crea el modelo real con agrupación por aplicación e incluye una casilla **«Usar ventanas reales de KDE en SO (solo lectura)»**, inicialmente desmarcada para no romper la demo. El menú de simulación de ventanas queda deshabilitado en modo real.

**IMPLEMENTADO Y REVISADO ESTÁTICAMENTE, NO PROBADO** todavía ejecutando Qt tras estos commits: [SO](https://github.com/nicoarg87/plasma-smartbar/commit/ae20fc1d98129f86e98940fe5fbb0e934ff145d1) / [visor](https://github.com/nicoarg87/plasma-smartbar/commit/663c35dcf2d7d01165bbcfcfbc4bf87a9a2cb96a). **SIGUIENTE PRUEBA Fish:** `cd ~/plasma-smartbar; git pull --ff-only; bash prototype/v0.1/probar_ancho.sh`; marcar casilla, abrir SO, abrir/cerrar Dolphin y Konsole, probar varias ventanas de Brave, alternar simulación y evaluar fila de anchura limitada. Si falla, copiar error QML. **PENDIENTE:** activación de ventanas (no implementar antes de aprobar y validar integración), agrupación probada, interacción segura con KWin/Wayland, problemas de pestañas/maximizadas y recursos binarios. `main.qml` sigue como demo sin modelos KDE; no modificar panel.

## 19. Reloj del SO SIN ocultar/reiniciar el GIF: corrección solicitada (17/11/2026)

**DECISIÓN POSTERIOR VIGENTE**: el reloj debe ser **pequeño y transparente encima del GIF**, no un panel opaco que reemplaza la imagen. Motivo: el mantenedor vio que al aparecer fecha/hora grandes, SO perdía la foto y luego reaparecía, lo cual es un bug. `IslandButton.qml` quitó `!clockVisible` del `iconLoader.active`, sustituyó `Rectangle` opaco por `Item` transparente, usa letras con `Text.Outline` y `Text.Fit` con espacio limitado. El GIF permanece activo todo el tiempo; solo aparecen/desaparecen los números al hover de 180 ms en seis puntos durante 3 s. Nueva fuente inicial Sans Serif, tamaño **11 px** en vez de 16, texto blanco personalizable en Logo SO. Cambios sincronizados en SmartBarContent, SoledadSettings/Restablecer, preview_redimensionable y KConfig. Los valores viejos guardados por usuarios no se sobrescriben automáticamente. **IMPLEMENTADO EN RAMA v0.1, PENDIENTE DE EJECUCIÓN CACHYOS**. El panel instalado sigue intacto.

## 20. Modularidad y seguridad aprobadas, primer corte de Malvina (17/11/2026)

**Fuente rectora nueva:** [Arquitectura modular](ARQUITECTURA_MODULAR.md). Mantenedor aprobo separar Soledad, Malvina, coordinador, adaptadores KDE, preferencias y politicas; interfaces por senales y propiedades; permisos minimos, calidad y testeo por etapas. No alterar requisitos aprobados.

**Codigo en rama experimental:** `MalvinaUrlPolicy.js` (HTTPS y `{query}`), `MalvinaSearch.qml` delega, `closeSearch()` resuelve la llamada de `MalvinaIsland.qml`. El formulario `MalvinaProvidersPage.qml` sigue separado visualmente pero acoplado al `settingsTarget` global; separar despues de pruebas.

**Pendiente prioritario:** `cd ~/plasma-smartbar; git switch prototype/v0.1-islas-so; git pull --ff-only; bash prototype/v0.1/probar_ancho.sh`; verificar Malvina, URLs web/IA y cierre. No se ejecuto Qt/CachyOS tras los commits. Luego dividir `SmartBarContent.qml` y `SoledadSettings.qml` en pasos reversibles y probados. Nunca reemplazar panel instalado para estas pruebas.

## 21. Seleccion de buscador Malvina con teclado (17/11/2026)

**Aprobado y codificado en rama v0.1:** proveedor Google inicial; Enter desde texto busca. Tab pasa a opciones y recorre proveedores Web/IA; Mayus+Tab retrocede; Espacio selecciona y devuelve foco con consulta intacta; Enter ejecuta posteriormente. Clic en proveedor tambien solo selecciona. No hacer busqueda ni navegar al elegir con Espacio. Para IA solo abrir pagina, sin enviar prompt. Commit [f67cc6e](https://github.com/nicoarg87/plasma-smartbar/commit/f67cc6e3f35e15eae53f0b3a5d8e99d83e4d2f69). **Falta prueba real Qt/CachyOS** de foco entre Popup y campo de texto.

## 22. Alcance confirmado de Malvina: navegador y chats IA (17/11/2026)

**CONFIRMADO:** buscadores Web pueden tener respuestas IA propias; se usan como búsquedas web normales. Chats IA tendrán autorización informada por proveedor **solo para el envío directo de texto desde Malvina**, apagada por defecto, revocable, sin sudo. Si el servicio necesita login, el usuario inicia su sesión directamente en el navegador; Malvina no manipula contraseñas/cookies. Sesión abierta no significa permiso ni garantiza integración web oficial. Mientras no exista vía compatible verificada, abrir página de IA sin enviar consulta. **Función directa aún pendiente de investigación, implementación y test en CachyOS.**

## 23. Atajo Meta+Espacio: local, no global (17/11/2026)

En SmartBarContent.qml existe Shortcut Meta+Space con Qt.WindowShortcut. Se limita a ventana Qt activa; no registra atajo global KWin/Wayland. El método focusSearch() abría indebidamente opciones junto al campo; [commit fc3e990](https://github.com/nicoarg87/plasma-smartbar/commit/fc3e990039c519f5f3b181c3e7c45de268f14f8b) separa apertura del campo de selección Web/IA (Tab). **Pendiente retest en CachyOS y desarrollar atajo global KDE sin sobrescribir atajos existentes.**

## 24. Cerrar Malvina por clic exterior — pendiente de retest (17/11/2026)

**Nueva regla confirmada:** si el usuario clica fuera del campo de búsqueda de Malvina y del popup de herramientas, cerrar ambos. Con autoocultamiento activado, ocultar isla; si está desactivado, solo contraer búsqueda. Mantener interacciones normales sobre SO/otras ventanas. **Código experimental:** `TapHandler` pasivo en SmartBarContent, `Connections` para ventana Qt inactiva, y política de cierre exterior en popup de MalvinaSearch. Commits 85cabed, a000e97, 0a78dac. **Sin test Qt/CachyOS.** Retest con `bash prototype/v0.1/probar_ancho.sh` tras `git pull --ff-only`, incluyendo clic sobre campo, Web/IA, fondo, SO y otras aplicaciones; también preferencia autoHideMalvina=false.

## 25. Configuración Malvina: navegador KDE y autorizaciones IA (17/11/2026)

**Codificado en rama experimental, sin prueba de CachyOS:** MalvinaProvidersPage muestra navegador predeterminado KDE (única opción funcional, selector deshabilitado hasta disponer de integración nativa) y tres casillas explícitas para consentimiento futuro ChatGPT/Gemini/Claude, falsas por defecto. `SoledadSettings` emite `saveMalvinaConsentsRequested` al Aplicar; `SmartBarContent` retransmite mediante `requestMalvinaConsentsChange`; `main.qml` y `main.xml` persistencia KConfig; visor persiste opciones locales. **NO envía consultas automáticamente:** la autorización queda guardada pero el chat web solo se abre; todavía falta integración compatible y pruebas. Comprobar casillas, avisos, persistencia y revocación en `probar_ancho.sh`; no tocar panel actual.

## 26. Proveedores habilitables y navegador predeterminado Malvina (17/11/2026)

**CODIFICADO, NO PROBADO EN CACHYOS:** en MalvinaProvidersPage la opción de navegador es el predeterminado KDE (única operativa, selector deshabilitado); buscadores Web Google/DDG/Yahoo con habilitación individual true por defecto; chats IA con autorización futura individual false por defecto, sin envío automático. Conexión de valores y Aplicar por SoledadSettings/SmartBarContent, KConfig (`main.qml` y `main.xml`) y visor local (`preview_redimensionable.qml`). `MalvinaSearch` evita buscar con proveedor Web deshabilitado y desactiva su botón. Test prioritario: visor Qt CachyOS, abrir ajustes Malvina, modificar casillas y Aplicar, cerrar/abrir/reiniciar y probar Tab/Espacio/Enter con cada proveedor habilitado/deshabilitado. No tocar panel instalado ni prometer elección de navegador específico o chat IA directo.

## 27. Permisos IA conectados a URL experimental (17/11/2026)

**FALLO REPORTADO:** ChatGPT autorizado no recibía consulta: solo existía casilla, sin integración. **PARCHE EXPERIMENTAL:** URL `?q=` para ChatGPT, Gemini y Claude, codificado y limitado a dominio/ruta oficial exacta, con autorización individual previa. No incluir consulta en sitios personalizados ni al seleccionar con Tab/Espacio. Texto de opciones aclara posible precarga, ignorar parámetro o autoenvío; no prometer que funcione. `MalvinaUrlPolicy.js`, `MalvinaSearch.qml`, `SmartBarContent.qml`, `MalvinaProvidersPage.qml` y tests actualizados. **NO PROBADO Qt/CachyOS**. Próxima prueba: Fish `cd ~/plasma-smartbar; git pull --ff-only; node prototype/v0.1/tests/test_malvina_url_policy.cjs; bash prototype/v0.1/probar_ancho.sh`. Autorizar por separado con texto de prueba inocuo; desautorizar y comprobar ausencia de transmisión; observar si el chat rellena o envía. El comportamiento externo es variable. No modificar panel KDE.

## 28. Gemini no precarga por URL q — prueba negativa (17/11/2026)

Usuario probó en CachyOS: Gemini autorizado, el texto de Malvina no apareció en el chat. Búsqueda externa confirmó ausencia de documentación oficial del parámetro `q` como precarga nativa Gemini web; hay extensiones externas que lo implementan. En rama v0.1: política `resolveAiPrefill` deja de añadir `q` para índice Gemini (1) aun con permiso, la interfaz informa la limitación, tests actualizados. Commits 77c06e6, cb6f8a8, 656b89c. Falta volver a ejecutar tests Node y visor Qt. Buscar solución oficial por proveedor, no inventar que una URL nueva funciona ni instalar extensiones sin pedido expreso.

## 29. Claude funciona con sesión web — prueba del mantenedor (17/11/2026)

El usuario confirma en CachyOS que Claude **funciona** desde Malvina tras registrarse/iniciar sesión en su cuenta. Registrar como **PROBADO positivamente con autenticación**, no como compatibilidad universal ni sin cuenta. Separar permiso IA Malvina de credenciales del proveedor; no pedir contraseña ni sudo. Pendientes: verificar revocación, comportamiento con/sin sesión, si `?q=` precarga o envía, y mantener criterio experimental. Gemini sigue sin precarga funcional.

## 30. Nombres descriptivos por enlace de Malvina (17/11/2026)

**CONFIRMADO E IMPLEMENTADO EXPERIMENTALMENTE:** el usuario elige nombre visible de cada uno de los seis proveedores Web/IA sin alterar URL ni permisos. Campos individuales «Nombre visible» (máximo 48, no vacío) en MalvinaProvidersPage; validación en SoledadSettings; propiedades/señales en SmartBarContent; etiquetas dinámicas en MalvinaSearch; persistencia en KConfig y visor. Identificadores de proveedor permanecen fijos: renombrar no modifica autorización ni habilita enviar texto a otros dominios. No se incorporaron proveedores nuevos. **Sin prueba de CachyOS**: abrir Opciones de Malvina, renombrar «DuckDuckGo» a «Buscador privado», Aplicar, comprobar lista Tab y persistencia reiniciando visor. Mantener panel KDE intacto.

## 31. Campo Malvina más legible y edición multilínea (17/11/2026)

El mantenedor adjuntó captura de visor: «vino tinto» se veía demasiado grande y arriba; Google buscó, pero mostró verificaciones de su sitio. Requisitos: centrar letra, tamaño proporcional; X borra todo; Mayús+Enter agrega línea; pegado largo muestra editor expandido hacia abajo sin modificar grosor de isla; Tab elige Web/IA sin cursor titilando; tras confirmar por Espacio/clic vuelve cursor y Enter ejecuta texto completo. **Código experimental en MalvinaSearch.qml** con fuente 14, TextField, botón X, TextArea en popup limitado a ~220 px, texto sincronizado, pulsaciones diferenciadas, cursorVisible condicional y desplazamiento popup proveedores. **AÚN NO PROBADO EN CACHYOS TRAS ESTOS CAMBIOS**. Solicitar ejecutar visor con Fish y reportar errores QML exactos. No tocar panel KDE. Gemini sigue sin precarga; Claude funciona tras login, ChatGPT enlace experimental.

## 32. Malvina — un único campo que crece, sin recuadro adicional (17/11/2026)

El mantenedor rechazó expresamente crear una segunda ventana de texto: Mayús+Enter y textos largos deben expandir **el mismo espacio de búsqueda**, verticalmente y a derecha hasta media pantalla aprox., sin cubrir las otras islas y conservando altura fija de la barra. También informó que la X no era visible. Se corrigió en rama experimental eliminando `editorPopup` y `longInput`, usando único TextArea+ScrollView en MalvinaSearch, X dentro del campo, ancho dinámico limitado, altura dinámica, Tab/Espacio/Enter y detector de clic exterior adaptado. Commits ff395c8, 57a748c, f7338c7. **NO PROBADO en CachyOS tras estos cambios.** Próximo paso: visor con Fish, comprobar QML y las interacciones, resolver fallos antes de nuevas funciones. El diseño previo de editor emergente queda **descartado**, no reintroducirlo.

## 33. Campo Malvina: clics atraviesan extensión vertical (17/11/2026)

**FALLO REAL REPORTADO**: al escribir y extender el campo hacia abajo, la parte inferior deja pasar clics al fondo; el ancho no llega a media pantalla. La superficie `TextArea` estaba fuera de los límites interactivos de un Item de 34 px. **CORRECCIÓN EXPERIMENTAL**: único `TextArea` dentro de un `QQC2.Popup` no modal alineado en el campo original (no duplicarlo ni crear una segunda caja), ancho máximo al escribir, límite horizontal incluye 73 px de botones. Commits 037ecc3 y 6fde6a3. **No retestado en CachyOS**. Prioridad absoluta: verificar clic/selección en el último renglón y no sobre el fondo, ancho casi media pantalla, X, Enter/Shift+Enter, Tab y Espacio antes de otras funciones. No tocar panel KDE.

## 34. X de borrar sin franja vertical (17/11/2026)

El usuario reportó que el botón X reservaba una columna entera. Ajustado `MalvinaSearch.qml` en rama experimental: se quitó el margen derecho de 28 px del ScrollView, la X ahora es un botón transparente de 17×17 px superpuesto en esquina superior derecha; se deja padding de texto de 25 px por legibilidad. Commit 841351f. Sin retest en CachyOS. No reintroducir columnas ni recuadros para X.

## 35. Orden de filas Web/IA y proveedores arrastrables (17/11/2026)

Usuario confirmó arrastre vertical de Web/IA y horizontal de proveedores, con **primera opción habilitada a izquierda de fila superior como predeterminada para nueva búsqueda**. Implementación experimental en `MalvinaSearch.qml` mediante Repeater dinámico por fila, DragHandler, rótulo ↕ para invertir, función de default al abrir, orden por IDs y validación. Orden persiste con señales en SmartBarContent, ajustes en SoledadSettings/MalvinaProvidersPage, KConfig/main.xml/main.qml y visor local. **NO PROBADO AÚN EN CACHYOS**. Probar invertir filas, arrastrar Claude a la izquierda, cerrar/abrir y verificar Enter apunta al nuevo predeterminado; reiniciar visor, verificar persistencia y consentimiento propio. Mantener altura de isla, sin tocar panel KDE.
