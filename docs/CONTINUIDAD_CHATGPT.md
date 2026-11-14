# Protocolo de continuidad entre conversaciones de ChatGPT

**Proyecto:** Plasma SmartBar  
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
- Los forks están permitidos bajo las condiciones de **GPL-3.0**. Nadie puede modificar el repositorio oficial sin permisos de escritura autorizados.
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
- **Bug de doble clic en Malvina (14/11/2026):** en CachyOS Malvina abría el lanzador, pero **el segundo clic no lo cerraba**. `Popup.CloseOnPressOutside` cerraba el menú al presionar el botón, luego `onClicked` lo reabría. Parche [304f33e](https://github.com/nicoarg87/plasma-smartbar/commit/304f33e89074fa57d71eadded58a461de5043a9d) cambia a `CloseOnPressOutsideParent` y conmuta explícitamente `open()/close()` según el origen. **Implementado en PR #3, NO PROBADO TODAVÍA en CachyOS**. Probar clic M abre/cierra, Esc y clic fuera, y SO sostenido con popup bajo Soledad.
- **Separador SO/bandeja y lanzador por isla (confirmado, 14/11/2026):** en CachyOS el mantenedor **validó** que ambas expansiones pueden convivir. Observó que faltaba distinción entre los iconos; al estar ambas abiertas, mostrar **línea vertical sutil** entre bandeja y fichas SO, sin segunda fila ni modificar grosor. Además, al pulsar **Malvina** el lanzador aparecía erróneamente debajo de **Soledad**: debe abrirse **debajo de Malvina**, mientras el gesto sostenido de SO sigue abriéndolo bajo la posición actual de Soledad. Al abrir desde Malvina, no contraer las expansiones de Soledad por defecto. Parche [d2edf83](https://github.com/nicoarg87/plasma-smartbar/commit/d2edf8327ba764dfba646a7b817bf70f805a0aa2) en PR #3, **pendiente de nueva prueba en CachyOS**, solo apps ficticias.
- **DECISIÓN POSTERIOR CONFIRMADA (14/11/2026):** **Soledad** = isla 1 principal con SO/bandeja/seis puntos; **Malvina** = isla 2 izquierda (visible por defecto, ocultable). **SO y bandeja YA NO son mutuamente excluyentes por defecto:** permanecen ambos desplegados si el espacio horizontal alcanza en una sola fila; si no, se contrae la expansión abierta antes y se mantiene la nueva. Al arrastrar/reducir el ancho mientras ambas están abiertas, conservar la solicitada más recientemente. Esto reemplaza cualquier frase histórica de exclusividad. Flecha de bandeja **◀ cerrada / ▶ expandida**.
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

