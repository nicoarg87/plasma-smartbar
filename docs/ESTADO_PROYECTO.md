# Estado actual de Plasma SmartBar

**Fecha de corte:** 14 de noviembre de 2026  
**Estado general:** prototipo visual v0.1 de Plasma SmartBar **ejecutado en CachyOS con interacciones básicas comprobadas** (SO/bandeja, arrastre de isla 1, menú del agarre). Sigue en rama experimental, sin conexión a ventanas reales ni fusión a main; la anomalía de recarga del visor continúa sin diagnosticar. **No existe todavía una barra instalable y validada para uso diario.**

## Realmente completado

- [x] Repositorio público oficial: https://github.com/nicoarg87/plasma-smartbar
- [x] Licencia en el repositorio: GNU GPL-3.0.
- [x] [Manual Maestro v0.30](MANUAL_MAESTRO.md), [Constitución Técnica v1.21](CONSTITUCION_TECNICA.md), [GOVERNANCE](../GOVERNANCE.md), [CONTRIBUTING](../CONTRIBUTING.md), [ROADMAP](../ROADMAP.md).
- [x] Regla de ramas `Proteccion de main` **activa** en GitHub, aplica a la rama predeterminada, bloquea borrado y push no fast-forward, según lectura de GitHub el 14/11/2026: https://github.com/nicoarg87/plasma-smartbar/rules/27249133
- [x] Issue inicial: https://github.com/nicoarg87/plasma-smartbar/issues/1 (prueba de concepto v0.1, todavía no ejecutada).
- [x] Código de interfaz **preliminar** en rama `prototype/v0.1-islas-so`, mediante [PR #3 (borrador)](https://github.com/nicoarg87/plasma-smartbar/pull/3): paquete Plasma 6 (`metadata.json` + QML), islas y fichas ficticias, script de ejecución en ventana. **Solo revisado estáticamente**, sin ejecutar en CachyOS; main no incorpora el código aún.
- [x] [Protocolo de continuidad](CONTINUIDAD_CHATGPT.md) y [plantilla de instrucciones](PLANTILLA_INSTRUCCIONES_CHATGPT.md) para conversaciones futuras.
- [x] Diseño aprobado: **isla 1 principal**, isla 2 (lanzador secundario) visible por defecto pero ocultable, isla 3 oculta; controles de ventana **fijos en el extremo derecho, independientes del arrastre de isla 1**, al maximizar. Viabilidad con KWin/Wayland real todavía no probada.
- [x] Requisito aprobado: agarre pequeño de **seis puntos (2 × 3) a la derecha de SO**, que debe permanecer estable al abrir bandeja o SO. **Implementado solo como demo QML en rama experimental**, sin ejecutar en CachyOS ni conectarlo a ventanas reales.
- [x] Aprobado: la isla 1 **vuelve automáticamente a la derecha al desmaximizar por defecto**, con casilla de configuración persistente para desactivarlo. En la demo se incluye simulación de maximización y preferencia KConfig `autoReturnRight=true`; **persistencia y conducta real pendientes de pruebas**.
- [x] **NUEVA decisión funcional aprobada, NO implementada:** posición horizontal guardada **por aplicación activa/maximizada**. Usuario arrastra isla 1 y hace **clic derecho → «Recordar esta posición para [aplicación]»**. Al volver a esa app maximizada, reaplicar la ubicación; al cambiar de app, cargar su perfil; al desmaximizar, retorno global predeterminado. Mover sin guardar no cambia perfiles. [Issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4) abierto.
- [x] La adaptación automática de altura según la barra de Steam **NO está aprobada**; sigue en estudio técnico, manteniendo grosor global fijo.
- [x] Efecto futuro de minimización «gaveta de SO» documentado; no implementado.
- [x] **Nueva decisión aprobada, no implementada:** modos horizontales **superior (por defecto)** e **inferior (configurable)**. Los controles SmartBar para ventanas maximizadas deben ubicarse en el **mismo borde** elegido, **abajo cuando la barra esté abajo**. La posibilidad de trasladar decoraciones originales es técnicamente incierta. Los bordes verticales izquierdo/derecho se reservan para experimentación futura, no como compromiso de entrega.
- [x] Issue técnico [#2](https://github.com/nicoarg87/plasma-smartbar/issues/2) abierto para investigar/validar el modo inferior y controles abajo.

## Lo que NO se ha hecho
- [x] Primer plasmoide QML/Qt **redactado en rama experimental, NO probado**. Pendiente ejecutar en `plasmoidviewer` y corregir posibles errores.
- [x] Existe código del agarre arrastrable en la demo QML de la rama `prototype/v0.1-islas-so`, con botones de ventana **ficticios**; todavía NO ejecutado ni comprobado.
- [ ] Falta comprobar que el agarre mueva correctamente la isla en `plasmoidviewer`, que no se altere su posición al abrir SO/bandeja, y que el retorno automático sea configurable y persista en el equipo.
- [ ] La detección de maximización/desmaximización en **ventanas reales** no está implementada.
- [ ] **Ningún modo inferior** está implementado/probado; no se verificó integración de sus controles inferiores con la ventana activa ni decoraciones originales.
- [ ] No hay modo vertical experimental funcional; dejar arquitectura preparada no equivale a ofrecerlo.
- [ ] No se ha ejecutado `plasmoidviewer` ni `plasmawindowed` en CachyOS; no se ha instalado Plasma SmartBar como barra o panel.
- [ ] No se ha demostrado detección/activación de ventanas o pestañas con KWin.
- [ ] No existe reconocimiento real de la aplicación activa/maximizada ni **perfiles de posición por aplicación**, interfaz de clic derecho o persistencia de esos perfiles.
- [ ] No se ha probado superposición horizontal en navegadores maximizados ni fullscreen.
- [ ] No se han ejecutado pruebas de consumo de CPU/RAM, rendimiento o compatibilidad entre distribuciones.
- [ ] No hay lanzamiento, paquete, Release ni instalador.
- [x] El usuario informó que creó el Proyecto de ChatGPT **«Plasma Smart Bar»** e incorporó la plantilla de instrucciones; no se verificó desde esta conexión la configuración de su interfaz.

## Decisiones de autoridad y protección
- Director funcional/de diseño: titular de nicoarg87/plasma-smartbar.
- Cualquier usuario puede copiar, bifurcar y proponer, conforme a GPL-3.0, pero no tiene escritura por defecto sobre el repo oficial.
- La regla `Proteccion de main` **no exige actualmente revisión previa por pull request**. No afirmar que GitHub obliga a recibir aprobación para cada commit; eso todavía no está configurado.

## Primera prueba en CachyOS (14/11/2026) — resultado real

- **Probado:** el mantenedor ejecutó `git clone --branch prototype/v0.1-islas-so` y `bash prototype/v0.1/probar.sh`. En CachyOS, `plasmoidviewer` sí arrancó, pero **el applet no cargó**. Paquetes reportados: `plasma-sdk 6.8.2-1.1` y `git 2.56.0-1.1`.
- **Error bloqueante observado:** `main.qml:10:14: Cannot assign to non-existent property "preferredRepresentation"`. Se había usado `Plasmoid.preferredRepresentation` indebidamente.
- **Corrección redactada y publicada en rama experimental:** quitar la asignación; commit [04055cf](https://github.com/nicoarg87/plasma-smartbar/commit/04055cf1b65ce3403506cd782f73a79ea7030ab6). Actualizado también el [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) y [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) (borrador).
- **Pendiente de prueba:** el usuario debe ejecutar `cd ~/plasma-smartbar && git pull && bash prototype/v0.1/probar.sh` para ver si el applet carga tras el parche. No afirmar que se ve la barra ni que el arrastre funciona todavía.
- **No tocado:** panel actual del escritorio y rama principal `main`.

## Segunda ejecución de v0.1 — carga visual confirmada; fallo de recarga pendiente (14/11/2026)

- **PROBADO en CachyOS:** tras el parche QML, el visor `plasmoidviewer` **mostró por primera vez el contenido de la demo**: isla de lanzador a la izquierda, parte de la isla SO a la derecha y un tooltip de SO. Captura aportada en la conversación del mantenedor. La interfaz `Formatos visuales / Ubicación / Configurar contenedor` pertenece al propio visor de Plasma, no a SmartBar.
- **INCIDENTE SIN DIAGNÓSTICO:** al pulsar «actualizar» en `plasmoidviewer`, el usuario informó que el contenido de SmartBar desapareció o dejó de responder; después reinició la prueba. **No se ha recogido todavía el registro del proceso en ese momento**. No atribuirlo a un bug de KWin ni anunciar un crash confirmado.
- **NO PROBADO AÚN:** arrastre real de la maqueta de seis puntos, persistencia de `autoReturnRight`, exclusividad SO/bandeja, geometría constante durante interacción, integraciones reales de ventanas.
- **SIGUIENTE PASO:** ejecutar desde Fish `cd ~/plasma-smartbar; bash prototype/v0.1/probar.sh 2>&1 | tee ~/plasma-smartbar-v01.log` y reunir la salida al reproducir el problema. Continuar la prueba en la rama experimental; no fusionar el PR #3 todavía.

## Tercera prueba v0.1 — interacción básica verificada por el mantenedor (14/11/2026)

**RESULTADO REAL EN CACHYOS (Plasma 6.8.2, maqueta `plasmoidviewer`):**
- **PROBADO:** SO abre y contrae al volver a pulsar, mostrando fichas ficticias de aplicaciones.
- **PROBADO:** bandeja simulada abre y cierra.
- **PROBADO:** el **agarre de seis puntos (2 × 3)** permite arrastrar horizontalmente la isla 1 al centro.
- **PROBADO:** con la isla desplazada, el mantenedor volvió a utilizar SO/bandeja y no observó fallos en esas acciones.
- **PROBADO:** clic simple en el agarre muestra el menú, que incluye una opción de retorno automático a la derecha.

**PENDIENTE DE VALIDACIÓN ESPECÍFICA:** exclusión SO/bandeja abriendo uno mientras el otro está activo; cierre automático al elegir una ficha; prueba de maximización simulada y retorno automático; desactivar la preferencia y comprobar que se guarda tras reiniciar; medición de altura invariable; repetición/diagnóstico de la recarga problemática del visor.

**TODAVÍA NO IMPLEMENTADO:** selección de ventanas reales mediante KWin, estados de maximización reales y configuración de posición en un panel de uso diario. Los resultados no permiten todavía anunciar v0.1 terminada ni fusionar el [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3). Pruebas detalladas en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).

## Cuarta prueba v0.1 — retorno al extremo derecho comprobado (14/11/2026)

- **PROBADO:** en `plasmoidviewer`, el mantenedor activó y desactivó «Simular ventana maximizada»; al desactivar la simulación, la **isla 1 volvió automáticamente a su posición original a la derecha**.
- **COMPORTAMIENTO ESPERADO:** los controles ficticios de minimizar, restaurar y cerrar no realizaron acciones al pulsarlos; en la maqueta v0.1 están deshabilitados. Esto **no es un defecto de las funciones reales**, que todavía no existen.
- **PENDIENTE:** comprobar desactivación y persistencia de la preferencia `autoReturnRight` tras reiniciar; probar exclusividad automática SO/bandeja, constancia geométrica con medidas, recarga del visor y futura integración KWin/Wayland.
- **Estado:** v0.1 ha superado nuevas interacciones manuales de demostración, pero no está lista como barra de uso diario. Registro en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) continúa en borrador.

## Quinta prueba v0.1 — detectado error de acoplamiento en controles de ventana (14/11/2026)

- **PROBADO / FALLO OBSERVADO:** al simular maximización, los botones ficticios `− □ ×` se desplazaban al arrastrar el agarre de la isla 1 hacia el centro. El mantenedor aportó captura. Esta conducta contradice la necesidad de preservar la posición habitual de controles de ventana en el extremo derecho.
- **NUEVO REQUISITO CONFIRMADO:** los controles SmartBar de ventanas maximizadas **permanecen fijos en el extremo derecho**, arriba o abajo según orientación. **No forman parte del grupo arrastrable de SO**. Al maximizar, la isla reserva su espacio; arrastrar isla 1 no mueve los controles.
- **IMPLEMENTADO COMO PARCHE QML, SIN PRUEBA POSTERIOR:** en la rama `prototype/v0.1-islas-so` del [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3), los botones ficticios fueron extraídos de la fila de isla 1 y anclados de modo independiente al borde derecho, con reserva dinámica de ancho. Siguen deshabilitados y no controlan ventanas reales.
- **PRÓXIMA PRUEBA:** `git pull`, ejecutar en `plasmoidviewer`, simular ventana maximizada y arrastrar isla 1. Verificar que SO se mueve pero `− □ ×` permanecen fijos en el extremo derecho. No afirmar todavía que el parche fue probado ni que KWin real usa esta posición.

## Sexta prueba v0.1 — aclarar retorno automático y ordenar regreso inmediato (14/11/2026)

- **REPORTE DEL MANTENEDOR:** en captura de `plasmoidviewer` la isla 1 está desplazada al centro, las opciones **«Simular ventana maximizada»** y **«Volver automáticamente a la derecha»** están marcadas y el usuario informa que **no volvió a la derecha como esperaba** al usar el menú.
- **DIAGNÓSTICO DE CÓDIGO:** en la versión anterior la casilla de retorno automático no desplazaba la isla **al activarse mientras seguía maximizada la simulación**; la función se ejecutaba principalmente al desmaximizar. La captura no acredita por sí sola un fallo específico tras quitar la maximización.
- **CORREGIDO EN CÓDIGO (NO PROBADO AÚN):** commit [93eb1b7](https://github.com/nicoarg87/plasma-smartbar/commit/93eb1b7e6281a31284aad9fa7c826699978ba181) en la rama del [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3): al **activar** retorno automático, isla 1 se restablece inmediatamente; etiqueta «Volver a la derecha al desmaximizar»; acción independiente «Mover isla 1 a la derecha AHORA»; mensajes en consola para observar estados.
- **PENDIENTE:** actualización local (`git pull`) y repetición de ambos casos: (a) activar la preferencia mientras la simulación maximizada está activa, y (b) desmaximizar con la preferencia activada. Revisar que los controles ficticios `− □ ×` se mantengan fijos a la derecha y SO no cambie altura. No cerrar el issue #1 ni fusionar el PR sin comprobación.
- **SIN CAMBIOS DE ALCANCE:** perfiles reales por aplicación aprobados en [issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4) siguen **sin programar**. Aún no se detectan ni controlan ventanas reales de KWin.

## Séptima observación v0.1 — casilla activa y arrastre con maximización simulada (14/11/2026)

- **OBSERVADO por el mantenedor:** al arrastrar isla 1 al centro estando marcada «Simular ventana maximizada» y activado «Volver a la derecha al desmaximizar», la isla permanece desplazada; destildar y volver a tildar el retorno sí la lleva inmediatamente a la derecha.
- **INSPECCIÓN DEL CÓDIGO:** con maximización simulada activa, el diseño permite mover y conservar la posición; la casilla de retorno debe aplicarse **cuando se desmarca la maximización**, no continuamente al soltar el agarre. Reactivar la casilla ejecuta un regreso instantáneo añadido en un parche anterior. **No hay evidencia todavía de que el regreso al desmaximizar falle.**
- **PRUEBA PENDIENTE:** arrastrar al centro manteniendo ambas casillas activas; desactivar solo «Simular ventana maximizada» y comprobar si la isla vuelve a la derecha. Si no vuelve, registrar error y corregir. Cambiar a retorno automático al soltar el agarre incluso maximizada **requeriría aprobación funcional**, por conflicto con la reubicación deliberada de SO para Steam y perfiles por aplicación.
- Documentado en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), sin modificar `main` ni la lógica de la rama experimental.

## Octava observación v0.1 — alineación manual separada del retorno al desmaximizar (14/11/2026)

- **REQUISITO NUEVO CONFIRMADO:** la casilla contextual «Alinear isla 1 a la derecha» comienza tildada; **arrastrar isla 1 hacia el centro la destilda automáticamente** y el desplazamiento permanece al soltar los seis puntos. Para regresar, **tildar la casilla** alinea la isla inmediatamente, a la izquierda de los controles fijos `− □ ×` si están visibles. Destildarla manualmente no mueve nada.
- **SIN CAMBIO:** la preferencia independiente «Volver a la derecha al desmaximizar» sigue activada por defecto y se aplica solo al pasar de maximizada a no maximizada. No bloquea movimientos manuales y no sobrescribe los perfiles por aplicación (issue #4).
- **IMPLEMENTACIÓN EN RAMA EXPERIMENTAL, AÚN NO PROBADA:** [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) contiene estado `alignRightSelected`, casilla contextual de alineación y eliminación del retorno al soltar el agarre. No controla ventanas reales, no se ha modificado `main` ni el panel activo del usuario.
- **PRÓXIMA PRUEBA:** en CachyOS `git pull`, abrir `plasmoidviewer`, activar «Simular ventana maximizada», arrastrar isla 1 hacia el centro **sin destildar antes**, abrir menú y verificar que **«Alinear isla 1 a la derecha»** está desmarcada; marcarla y verificar retorno instantáneo junto a los controles fijos. Comprobar también la preferencia independiente y el retorno al desmaximizar.

## Novena prueba v0.1 — salto al quitar controles sin retorno (14/11/2026)

- **PROBADO EN CACHYOS:** según el último ensayo del mantenedor, **arrastrar isla 1 destilda la alineación derecha**; la casilla contextual y los controles de ventana ficticios separados responden visualmente. La captura anterior muestra isla 1 desplazada con casilla de alineación destildada y controles `− □ ×` fijos a la derecha.
- **ERROR NUEVO OBSERVADO:** al **desactivar «Volver a la derecha al desmaximizar»** y luego **desactivar «Simular ventana maximizada»**, isla 1 se desplaza ligeramente a la derecha por la desaparición del ancho reservado a controles. Esto contradice la conservación de posición manual con retorno desactivado.
- **DIAGNÓSTICO Y PARCHE EN RAMA EXPERIMENTAL:** `anchors.rightMargin = islandOffset + controlsReservation`. El parche [2301eaa](https://github.com/nicoarg87/plasma-smartbar/commit/2301eaad4cd38c8c7d38a6d2276b7076433eb241) guarda el margen visual antes de la transición y compensa la reserva al desaparecer los botones si el retorno está desactivado. **Código revisado, SIN prueba posterior en CachyOS**. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador.
- **PRÓXIMA PRUEBA:** `git pull`; maximizar simulación, arrastrar isla, desactivar retorno y desmaximizar. La isla debe permanecer en la misma posición visual. Con retorno activado debe volver normalmente a la derecha. La integración con ventanas reales aún no existe.

## Décima observación v0.1 — ancho del contenido no acompaña al visor (14/11/2026)

- **REPORTADO por el mantenedor en CachyOS:** la interfaz de SmartBar no llega al extremo derecho de `plasmoidviewer` y tampoco se extiende automáticamente cuando el usuario agranda/maximiza la ventana del visor.
- **REVISADO:** el QML solicitaba `Layout.preferredWidth: 960`, `implicitWidth: 960`, sin `Layout.fillWidth`, mientras `probar.sh` abre el visor con `-s 1000x80`. El visor también tiene sus propias márgenes y restricciones: no se atribuye todo el problema exclusivamente al QML todavía.
- **PARCHE PUBLICADO EN RAMA EXPERIMENTAL, AÚN NO PROBADO EN CACHYOS:** [057368a](https://github.com/nicoarg87/plasma-smartbar/commit/057368ace7d52e8db3b505b9e68a4de5d9ac05ac) incorpora `Layout.fillWidth: true` para usar el ancho disponible y `onWidthChanged` con mensaje `SmartBar v0.1: ancho del contenido = …`. El ancho inicial 960 es sugerencia, no ancho máximo. Se conservan islas visualmente separadas y grosor de 48 unidades en la demo.
- **SIGUIENTE PRUEBA:** `git pull`, abrir el visor, agrandar/maximizar/restaurar y confirmar que isla 1 y controles siguen la derecha útil, y el lanzador la izquierda. Verificar que los valores de ancho registrados cambien; si no cambian, investigar restricciones propias de `plasmoidviewer`. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador. No introducir fondo continuo ni instalar en panel real.

## Undécima observación: Plasmoidviewer no expande el applet y prueba Qt independiente (14/11/2026)

- **PROBADO / NEGATIVO:** el mantenedor volvió a probar la v0.1 en CachyOS tras agregar `Layout.fillWidth: true` y confirmó que **el applet NO se extiende hasta el borde derecho de Plasmoidviewer ni cuando se agranda/maximiza su ventana**. La corrección anterior no resolvió el visor.
- **DIAGNÓSTICO ABIERTO:** no están disponibles todavía los números registrados en Konsole durante el redimensionado. KDE distingue el tamaño del contenedor del tamaño del widget, por lo que no podemos afirmar que el applet deba adoptar necesariamente el tamaño de toda la ventana de Plasmoidviewer.
- **NUEVO CÓDIGO EN RAMA EXPERIMENTAL, AÚN NO PROBADO:** interfaz reutilizable `SmartBarContent.qml`; raíz de Plasma `main.qml` como envoltorio; nueva prueba de ancho `preview_redimensionable.qml` en ventana independiente Qt Quick; `probar_ancho.sh` para ejecutarla con `qml6`. Ambas vistas usan **exactamente el mismo componente de islas y lógica**. La interfaz Qt se ancla a ambos bordes de su propia ventana para aislar la prueba geométrica.
- **SIGUIENTE PASO:** en Fish, `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`, cambiar el tamaño y verificar medida visible y anclajes; si funciona, investigar aparte el contenedor de Plasma. No usar el panel principal del usuario ni declarar resuelto el modo Plasma. Documentado en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador.

## Duodécima prueba v0.1 — ancho completo en vista Qt maximizada (14/11/2026)

- **PROBADO EN CACHYOS MEDIANTE CAPTURA:** el mantenedor ejecutó la vista Qt independiente de `probar_ancho.sh`. En ventana maximizada el indicador muestra **1920 píxeles lógicos de ancho**. La isla 2 aparece en el extremo izquierdo y la isla 1 con SO/agarre de seis puntos, junto al bloque de controles simulados, en el extremo derecho. **La superficie violeta pertenece a la ventana de prueba**; no significa que haya que dibujar fondo continuo entre las islas.
- **COMPROBADO EN ESA CAPTURA:** el componente visual compartido `SmartBarContent.qml` recibe ancho completo y lo utiliza para distribuir islas en los extremos **en estado maximizado**.
- **PENDIENTE:** comprobar redimensionado progresivo (restaurar y agrandar a varios anchos) y nueva interacción en el componente compartido tras refactorizar; comprobar persistencia real de preferencias y funcionamiento en el contenedor Plasmoidviewer (que seguía sin expandir). **No se comprobó integración con KWin, tareas reales, ni panel de uso diario**.
- **PRÓXIMO PASO CONCRETO:** restaurar la ventana de prueba Qt, arrastrar el borde y observar si `Ancho del contenido` cambia inmediatamente, dejando las dos islas ancladas. Resultado registrado en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) aún en borrador.

## Decimotercera prueba v0.1 — redimensionado Qt confirmado (14/11/2026)

- **PROBADO EN CACHYOS:** el mantenedor confirmó que la **vista Qt independiente** de `probar_ancho.sh` **adapta automáticamente la anchura y la distribución de SmartBar cuando redimensiona la ventana**, complementando la captura maximizada de **1920 píxeles lógicos** con islas en extremos.
- **VALIDADO PARA EL COMPONENTE VISUAL Qt:** los extremos izquierdo/derecho reaccionan al ancho de ventana en la vista independiente. **No se requiere seguir corrigiendo a ciegas el ancho de `SmartBarContent.qml`** por este síntoma.
- **NO RESUELTO EN PLASMA:** en `plasmoidviewer`, el contenedor seguía sin conceder al plasmoide todo el ancho al agrandar la ventana. La prueba Qt no verifica el tamaño asignado al applet Plasma ni integración con KWin/Wayland, ventanas reales, controles reales o un panel de escritorio.
- **PRÓXIMO PASO:** investigar la geometría que asigna `plasmoidviewer`/Plasma al plasmoide de manera aislada, sin reemplazar el panel existente; después enlazar el selector SO a la lista real de ventanas abiertas. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador.

## Decimocuarta prueba v0.1 — salto izquierdo al maximizar isla 1 (14/11/2026)

- **FALLO REPORTADO POR EL MANTENEDOR:** con alineación derecha y retorno al desmaximizar desactivados, arrastró **isla 1** manualmente; al marcar «Simular ventana maximizada», la isla se desplazó a la izquierda automáticamente. El usuario corrigió que se refiere a la **isla 1 principal**, nunca isla 2.
- **DIAGNÓSTICO DEL CÓDIGO:** la compensación del margen de los controles `− □ ×` estaba programada solo al **desmaximizar**. Al **maximizar**, agregar `controlsReservation` modificaba la posición visible de la isla sin que el usuario la moviera.
- **CORRECCIÓN EN RAMA EXPERIMENTAL, NO PROBADA AÚN:** [93f119a](https://github.com/nicoarg87/plasma-smartbar/commit/93f119a4663c1ea818d4f16f100d74b522546be2) hace simétrica la compensación del margen visible **al maximizar y al desmaximizar**, siempre que la alineación derecha esté desmarcada. Solo desplaza la isla si es necesario para no tapar el grupo de botones fijos. Con alineación marcada, mantiene la posición normal junto a controles. **No se cambió la altura ni la posición de los botones**.
- **SIGUIENTE PRUEBA:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`; mover isla 1 al centro con casillas desmarcadas, activar/desactivar simulación y comprobar que no salta; repetir junto al extremo derecho, donde es aceptable un desplazamiento mínimo para liberar los controles. La rama principal y panel de KDE no se modificaron. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador.

## Decimoquinta prueba v0.1 — salto de isla 1 al maximizar CORREGIDO y probado (14/11/2026)

- **PROBADO EN CACHYOS:** el mantenedor repitió el escenario de fallo de la isla 1 (arrastre manual hacia el centro, sin alineación, seguida de maximización simulada) después del parche en `SmartBarContent.qml` y confirmó expresamente que **«ya no sucede»**. El salto involuntario hacia la izquierda **dejó de reproducirse en esa prueba**.
- **CORRECCIÓN VALIDADA PARA ESE CASO:** [93f119a](https://github.com/nicoarg87/plasma-smartbar/commit/93f119a4663c1ea818d4f16f100d74b522546be2) en [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3), aún en borrador. Registrado en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).
- **AÚN PENDIENTE:** probar colisión cerca del extremo derecho, demás combinaciones de alineación/retorno al desmaximizar, persistencia de preferencias, restricción de ancho en Plasmoidviewer y conexión con ventanas reales/KWin. **No instalado ni probado en panel de uso diario**.
- **SIGUIENTE PASO RECOMENDADO:** diagnóstico de geometría de contención de Plasma y luego detección de ventanas reales sin actuar sobre ellas, manteniendo aisladas las pruebas.

## Diagnóstico inicial de ventanas reales — QML de solo lectura, sin ejecutar (14/11/2026)

- **BASE REVISADA EN KDE PLASMA-WORKSPACE:** modelo `TaskManager.TasksModel`, import QML `org.kde.taskmanager 0.1`, y roles `AppName`, `IsActive`, `IsMaximized`, `IsMinimized`, `IsGroupParent` y `ChildCount`. El agrupamiento por aplicación está documentado en `GroupApplications`. **Compatibilidad real con CachyOS/Wayland aún no comprobada**.
- **CÓDIGO PUBLICADO EN RAMA EXPERIMENTAL:** `prototype/v0.1/preview_ventanas_reales.qml` (ventana de diagnóstico independiente y **solo lectura**) y `prototype/v0.1/probar_ventanas.sh`. La lista debe reaccionar a aplicaciones/ventanas abiertas sin acciones de activar, cerrar, minimizar ni modificar; la maqueta SmartBar original queda separada.
- **PRUEBA PENDIENTE:** en Fish, `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ventanas.sh`. Verificar importación QML, lista de nombres reales y cambios al abrir/cerrar Dolphin/Konsole normalmente. Si falla, reunir errores exactos antes de tocar el panel o añadir dependencias.
- **NO IMPLEMENTADO:** todavía no se conectó SO a ventanas reales; la ventana del diagnóstico no es el plasmoide definitivo. El ancho limitado en `plasmoidviewer` sigue pendiente. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) y [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) abiertos.

## Nueva decisión: SO pulsación sostenida e isla 2 ocultable sin cambiar valor por defecto (14/11/2026)

- **CONFIRMADO por el mantenedor:** SO con clic breve mantiene la lista de ventanas abiertas/minimizadas; pulsación sostenida algo menor que 0,5 s (umbral de demostración: **400 ms**) abre un lanzador de aplicaciones instaladas. El gesto largo no puede disparar simultáneamente el clic breve.
- **CONFIRMADO:** isla 2 sigue **visible por defecto**, pero se puede ocultar mediante **clic derecho → «Ocultar isla 2»**. El menú de SO permite **«Mostrar isla 2»** de nuevo. No se elimina isla 2 ni se reubica SO; se mantiene la posibilidad de usar solo isla 1. El menú lanzador es flotante, sin incrementar la altura ni añadir filas.
- **PROPUESTA A DEFINIR:** ocultación automática de isla 2. El usuario la sugirió como opción futura, pero **aún no confirmó disparador/recuperación**; no se ha implementado.
- **IMPLEMENTADO SOLO EN RAMA EXPERIMENTAL, NO PROBADO EN CACHYOS TRAS CAMBIO:** `SmartBarContent.qml`: temporizador de 400 ms sobre SO, Popup de aplicaciones **simuladas** (no se ejecutan ni son necesariamente instaladas), clic derecho en isla 2 y SO para ocultar/restaurar; `showLauncherIsland=true` en KConfig, conectado mediante el envoltorio del plasmoide, con ventana Qt independiente de solo sesión. **La persistencia KConfig en Plasma NO está comprobada.**
- **PRUEBA PRÓXIMA:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`. Verificar clic normal SO, pulsación larga para menú flotante, soltar sin abrir SO, clic derecho isla 2 para ocultar y clic derecho SO para restaurar. Confirmar ausencia de cambios en grosor, controles y arrastre. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador.

## Prueba v0.1 — lanzador SO aparecía lejos de isla 1 arrastrada (14/11/2026)

- **FALLO OBSERVADO EN CACHYOS CON CAPTURA:** en la ventana Qt independiente, el mantenedor movió **isla 1** al centro y mantuvo SO presionado; el popup «Aplicaciones (simulación)» apareció en el **extremo derecho**, separado de isla 1. La pulsación sostenida sí abrió el lanzador, pero su anclaje horizontal quedó obsoleto.
- **DIAGNÓSTICO QML:** el `QQC2.Popup.x` utilizaba `soButton.mapToItem(root, 0, 0).x` en lugar de referirse directamente a las propiedades reactivas del contenedor desplazable. El valor del menú podía mantenerse en la ubicación original tras el arrastre.
- **CORREGIDO EN CÓDIGO, NO PROBADO TODAVÍA EN CACHYOS:** [51aad39](https://github.com/nicoarg87/plasma-smartbar/commit/51aad39b0b448074779d15fd131cc7a6ed0e5032) calcula el anclaje con `systemIsland.x` y `systemIsland.width`, centra el popup **debajo de la ubicación actual de isla 1** y limita el margen dentro del ancho útil. Al mover o redimensionar la isla, el popup debe recalcular su posición automáticamente. No se cambia SO clic breve, pulsación sostenida 400 ms, altura, agarre ni controles fijos.
- **RETEST PRÓXIMO:** `git pull` y `bash prototype/v0.1/probar_ancho.sh`; arrastrar isla 1 al centro, mantener SO, verificar popup debajo de isla 1. Repetir a izquierda/derecha y tras redimensionar. Seguir sin actuar sobre ventanas reales. Registrar resultado en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador.

## Coexistencia de Soledad y bandeja, recuperación de Malvina y autocontracción (14/11/2026)

- **PROBADO EN CACHYOS:** el mantenedor confirmó que el lanzador flotante de SO ya sigue correctamente la posición de isla 1 al centro después del parche de anclaje; dijo **«Ahora sí, permitió usarse perfectamente»**. Validación específica del menú en la maqueta Qt, no de aplicaciones reales.
- **NUEVA DECISIÓN CONFIRMADA:** isla 1 = **Soledad** (SO, bandeja y agarre), isla 2 = **Malvina** (lanzador izquierdo, visible por defecto, ocultable). Se mantiene el botón «SO» y el nombre del repositorio/plataforma Plasma SmartBar por ahora; la posible nueva denominación pública de todo el proyecto como «Malvina» necesita aclaración antes de renombrar infraestructura.
- **CAMBIO CONFIRMADO DE REQUISITO:** Soledad debe dejar **SO y bandeja desplegados simultáneamente cuando quepan en una sola fila**. La nueva expansión cierra a la anterior **solo si ambas no caben físicamente**, respetando ancho útil, desplazamiento de Soledad, Malvina cuando está visible y controles fijos de maximizada. Si cambia el espacio disponible, prevalece la expansión solicitada más recientemente.
- **BUG DE RECUPERACIÓN DE MALVINA OBSERVADO:** el mantenedor pudo ocultarla pero no halló una forma simple de mostrarla otra vez. **Implementación experimental:** en el lanzador flotante de SO aparecerá **«Mostrar Malvina (isla 2)»**, accionable mediante un clic, mientras esté oculta, además del menú contextual previo.
- **NUEVA PREFERENCIA CONFIRMADA:** autocontracción independiente y configurable de **SO** (al seleccionar ficha de ventana, **activada por defecto**) y **bandeja** (tras usar icono, **desactivada por defecto**). No hay un temporizador por inactividad aprobado. Abrir el otro conjunto no debe provocar autocontracción si hay espacio; la prioridad por falta de espacio es una condición distinta.
- **IMPLEMENTADO EN RAMA EXPERIMENTAL, NO PROBADO AÚN TRAS CAMBIO:** `SmartBarContent.qml` calcula el ancho físico, conserva ambas expansiones si entran y contrae la anterior si no; incorpora recuperación visible de Malvina, controles independientes de autocontracción en el menú del agarre y clics de prueba de los iconos simulados. KConfig `autoCollapseSO=true`, `autoCollapseTray=false` conectado al envoltorio del plasmoide, sin validar persistencia.
- **PRÓXIMA PRUEBA EN CACHYOS:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`; abrir ambos conjuntos con ventana ancha (deben coexistir), estrechar o mover la isla para provocar falta de espacio (el último solicitado gana), cambiar cada autocontracción y tocar una ficha/icono de muestra, ocultar Malvina y recuperarla desde SO mantenido. No tocar panel actual. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador.

## Prueba guiada: diagnóstico de espacio SO/bandeja en Qt (14/11/2026)

- **CONFIRMADO VIGENTE:** Soledad y bandeja pueden permanecer expandidas simultáneamente si caben físicamente; si falta espacio, se contrae el grupo que estaba abierto antes. SO y bandeja tienen autocontracciones **configurables por separado**; Malvina es visible por defecto y se puede recuperar desde SO sostenido.
- **NUEVO INSTRUMENTO IMPLEMENTADO, PENDIENTE DE PRUEBA EN CACHYOS:** en la rama [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) se agregó exclusivamente a la ventana de prueba Qt un indicador de estados SO/bandeja, visibilidad de Malvina, preferencias de autocontracción, ancho de Soledad versus espacio disponible y prioridad de última expansión. El componente QML expone `actualIslandWidth` solo para diagnosticar y registra números al faltar espacio.
- **VALIDACIÓN SOLICITADA:** `git pull`; `bash prototype/v0.1/probar_ancho.sh`. Con ventana ancha abrir SO y bandeja y comprobar ambos abiertos; disminuir el ancho o desplazar Soledad hasta que falte espacio y verificar que solo la última expansión solicitada quede abierta. Probar opcionalmente autocontracción tras selección y recuperación de Malvina. **No se modificó el panel KDE actual y aún no se ha probado en el equipo del mantenedor.**
- **PENDIENTE DESPUÉS:** revisar resultado de esta prueba en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); si es positivo, continuar con `probar_ventanas.sh` para validar detección real en modo solo lectura. Sin fusión a main.

## Prueba positiva de coexistencia y nuevos ajustes del lanzador Malvina (14/11/2026)

- **PROBADO EN CACHYOS:** el mantenedor confirmó que la apertura conjunta de SO y bandeja «está funcionando como se esperaba» en la ventana Qt experimental. Eso valida su coexistencia en el escenario ensayado, no la bandeja real de Plasma ni todas las geometrías posibles.
- **AJUSTE VISUAL CONFIRMADO:** cuando ambas expansiones horizontales están abiertas, deben diferenciarse mediante **una línea vertical fina y discreta entre iconos de bandeja y fichas SO**, que desaparezca si se contrae una sección. Sin segunda fila ni variación de altura; la anchura de la línea participa del cálculo de espacio.
- **BUG CONFIRMADO:** al hacer clic en Malvina (isla 2 izquierda) el lanzador flotante de prueba aparecía debajo de Soledad (isla 1). **COMPORTAMIENTO CONFIRMADO:** cada origen abre su lanzador inmediatamente debajo de su isla: Malvina a la izquierda; SO sostenido o menú contextual SO bajo la posición actual de Soledad. El menú de Malvina no debe contraer innecesariamente SO/bandeja que estén abiertos.
- **IMPLEMENTADO SOLO EN RAMA EXPERIMENTAL, NO PROBADO DESPUÉS:** [commit d2edf83](https://github.com/nicoarg87/plasma-smartbar/commit/d2edf8327ba764dfba646a7b817bf70f805a0aa2) incorpora `traySOSeparator`, origen `installedLauncherSource` y posicionamiento reactivo respecto de `launcherIsland` o `systemIsland`, con límites de ventana; se mantiene el temporizador de SO de ~400 ms.
- **PRÓXIMA PRUEBA:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`; abrir ambas expansiones y comprobar la línea; cerrarlas por separado y comprobar que desaparece; clic en Malvina para verificar menú bajo la isla izquierda; mover Soledad al centro y sostener SO para verificar menú bajo esa isla. No modifica panel actual. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) sigue borrador.

## Bug de Malvina: segundo clic no cerraba el lanzador — corrección experimental (14/11/2026)

- **OBSERVADO EN CACHYOS:** clic en Malvina abría el lanzador bajo Malvina, pero un segundo clic en Malvina **no lo cerraba**.
- **CAUSA IDENTIFICADA EN QML:** el menú tenía `Popup.CloseOnPressOutside`, que lo cerraba al presionar Malvina fuera del popup; después el mismo clic terminaba en `openInstalledLauncher()` y **lo reabría**.
- **PARCHE PUBLICADO EN RAMA EXPERIMENTAL, PENDIENTE DE PRUEBA:** [304f33e](https://github.com/nicoarg87/plasma-smartbar/commit/304f33e89074fa57d71eadded58a461de5043a9d) usa `CloseOnPressOutsideParent` y cierre explícito si el popup ya está visible y fue abierto desde el mismo botón. Al hacer clic desde el otro origen cambia el anclaje bajo la isla correspondiente, sin abrir un segundo menú. Se conserva cierre mediante Esc o clic fuera de la barra.
- **PRÓXIMA PRUEBA:** `git pull`; `bash prototype/v0.1/probar_ancho.sh`; clic M abre, segundo clic M cierra, tercero abre, Esc y clic fuera cierran, gesto sostenido de SO continúa mostrando menú bajo Soledad. Las fichas e iconos siguen siendo ficticios; la barra instalada del usuario no se modifica. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) sigue borrador.

## Regresión de SO sostenido: lanzador cerraba expansiones horizontales — parche (14/11/2026)

- **PROBADO EN CACHYOS:** el mantenedor confirmó que el lanzador de **Malvina** ahora se abre y se cierra correctamente con clics alternos («Espectacular. Funciona como tiene que funcionar»). Esto valida el parche del segundo clic en la vista Qt independiente, no la integración de un lanzador real.
- **NUEVO FALLO OBSERVADO:** después de abrir SO y bandeja a la vez, mantener pulsado SO para mostrar el lanzador flotante **cerraba ambas expansiones horizontales** sin elección del usuario.
- **CORRECCIÓN FUNCIONAL CONFIRMADA:** el lanzador flotante se abre debajo de Soledad (o de Malvina según el origen) y **no modifica automáticamente ni SO ni bandeja**, que permanecen con su estado anterior. La regla de espacio horizontal y la autocontracción por selección de ficha/icono siguen siendo independientes.
- **CAUSA:** el código de `openInstalledLauncher(source)` contraía SO y bandeja en el caso de origen `so` por una decisión histórica ya sustituida.
- **IMPLEMENTADO EN PR #3, PENDIENTE DE PRUEBA EN CACHYOS:** [9175734](https://github.com/nicoarg87/plasma-smartbar/commit/917573452335e979212a46dd84fb9c3813dd5f15) retiró `soExpanded = false` y `trayExpanded = false` de la apertura del popup. Mantiene el separador, la pulsación de ~400 ms y el anclaje a cada isla. Revisión estática pendiente de ejecución real del parche.
- **SIGUIENTE PRUEBA:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`; abrir las dos expansiones en ventana ancha, mantener SO pulsado para mostrar el menú debajo de Soledad y verificar que las fichas SO y la bandeja **siguen abiertas** durante y después de cerrar el popup. Seguir sin alterar el panel instalado. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador.

## Soledad: clic breve con popup visible cerraba además fichas SO (14/11/2026)

- **PRUEBA ANTERIOR SUPERADA EN CACHYOS:** el mantenedor confirmó «Ahora sí, quedó genial» para la apertura del **lanzador de SO sin contraer fichas SO ni bandeja**. Esa interacción está **PROBADA en la maqueta**, no en ventanas reales.
- **NUEVO BUG OBSERVADO:** luego de abrir el lanzador desde SO sostenido y con las fichas de ventanas abiertas, hacer **clic breve en SO** cerraba el popup, pero **también contraía las fichas de SO**, aunque el usuario pretendía dejarlas expandidas.
- **REQUISITO CONFIRMADO:** si hay lanzador visible, clic breve en SO **lo cierra únicamente** y deja SO/bandeja intactos. Solo cuando no hay lanzador visible el clic breve alterna las fichas de ventanas abiertas.
- **CAUSA Y PARCHE EXPERIMENTAL, PENDIENTE DE RETEST:** `toggleSO()` cerraba el popup y continuaba hacia la alternancia de `soExpanded`. [8a79f3f](https://github.com/nicoarg87/plasma-smartbar/commit/8a79f3fcad849ed252c284ba004bf88e173f00cb) ahora sale temprano tras cerrar `installedAppsPopup.visible`, sin modificar estados horizontales. El clic largo (~400 ms), Malvina y autocontracciones independientes permanecen como antes.
- **PRÓXIMA PRUEBA EN CACHYOS:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh` → abrir SO y bandeja → sostener SO (abre flotante sin contraer) → **clic corto SO (cierra solo flotante)** → clic corto SO de nuevo (contrae fichas normalmente). Sin reemplazar panel KDE; [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador.

## Recuperación de Malvina desde Soledad: menú de agarre accesible (14/11/2026)

- **BUG DE DESCUBRIBILIDAD OBSERVADO EN CACHYOS:** el mantenedor ocultó Malvina (isla 2), pero no encontró un menú evidente en Soledad para restaurarla. Los accesos anteriores en clic derecho de SO y dentro del lanzador sostenido no eran suficientes para el uso cotidiano.
- **REQUISITO CONFIRMADO:** Soledad debe mantener un acceso sencillo y visible para mostrar Malvina otra vez sin exigir clic derecho ni gesto sostenido. El menú **ya existente del agarre de seis puntos**, que se abre con clic normal, presentará la primera acción **«Mostrar Malvina (isla 2)»** cuando esté oculta y **«Ocultar Malvina (isla 2)»** cuando esté visible. No se añade un botón permanente ni se altera la geometría acordada; Malvina sigue visible por defecto.
- **IMPLEMENTADO EN QML EXPERIMENTAL, NO PROBADO DESPUÉS:** [1953f21](https://github.com/nicoarg87/plasma-smartbar/commit/1953f21b1e8db883c0c03fab2aa70478b7f6b4f9) añade esta acción al principio de `gripMenu` con título «Opciones de Soledad»; las ayudas emergentes indican la nueva ruta cuando Malvina está oculta. El evento de visibilidad existente sigue conectado al estado de sesión Qt y al KConfig del envoltorio plasmoide, pero **persistencia real no validada**.
- **PRÓXIMA PRUEBA EN CACHYOS:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`; ocultar Malvina por clic derecho, clic normal en los seis puntos, primera opción «Mostrar Malvina», comprobar reaparición. Volver a abrir para verificar «Ocultar Malvina». Confirmar que SO/bandeja y el cierre del lanzador no sufrieron regresión. [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) / [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador.

## Seis puntos: arrastre izquierdo sin menú, opciones por clic derecho (14/11/2026)

- **FALLO OBSERVADO EN CACHYOS:** al tocar los seis puntos para desplazar Soledad se abría involuntariamente el menú de opciones, y pulsar nuevamente el agarre podía cerrarlo y **reabrirlo en el mismo clic**; el mantenedor lo consideró molesto.
- **CAMBIO FUNCIONAL APROBADO:** **botón izquierdo** del agarre reservado exclusivamente a **arrastrar Soledad**; **clic derecho** sobre los seis puntos **abre y cierra** «Opciones de Soledad». Se conserva **Menú contextual/Mayús+F10** con el control enfocado como alternativa accesible y Esc/clic fuera para cerrar. Se descarta por ahora el doble clic izquierdo (mencionado como opción, no elegido como preferencia). **Esta regla reemplaza el clic izquierdo para abrir el menú aprobado en la versión anterior.**
- **RECUPERACIÓN DE MALVINA:** conserva primera opción visible «Mostrar Malvina (isla 2)» cuando oculta y «Ocultar Malvina» cuando visible, ahora accesible por clic derecho en el agarre; siguen alternativas del menú contextual de SO y lanzador SO sostenido. El texto de ayuda demora 850 ms y no aparece durante el arrastre.
- **IMPLEMENTADO SOLO EN PR EXPERIMENTAL, PENDIENTE DE PRUEBA EN CACHYOS:** [12020b5](https://github.com/nicoarg87/plasma-smartbar/commit/12020b5b6cf9421054101b045d5c0bddfbba8dc2) quitó `moveGrip.onClicked`, agregó `MouseArea` con `Qt.RightButton`, `toggleGripMenu()`, teclado y política de cierre `CloseOnPressOutsideParent`; [9bd07e0](https://github.com/nicoarg87/plasma-smartbar/commit/9bd07e0d4e00b6ae8a5a3fb2ba5240e17ae20f0e) restringió explícitamente `DragHandler` a `Qt.LeftButton`. Código revisado estáticamente, sin prueba posterior del mantenedor.
- **SIGUIENTE PRUEBA SEGURA EN CACHYOS:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`. Clic izquierdo sobre los puntos no abre menú; arrastre izquierdo desplaza isla; clic derecho abre opciones, segundo clic derecho cierra sin reabrir, Esc/clic afuera también cierra; ocultar/mostrar Malvina desde primera opción de menú. **Sin tocar panel instalado, PR #3 sigue borrador**, [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).

## Apertura con derecho validada; cierre con izquierdo breve añadido (14/11/2026)

- **PROBADO EN CACHYOS:** el mantenedor confirmó que **clic derecho en los seis puntos abre correctamente las opciones** de Soledad. Esa apertura está validada en la ventana Qt independiente, no en el panel real.
- **NUEVA DECISIÓN CONFIRMADA:** si el menú de opciones está abierto, un **clic izquierdo breve en el agarre lo cierra**. Con menú cerrado, el izquierdo no lo abre y sigue disponible para arrastrar Soledad. El clic derecho conserva apertura/cierre con clics sucesivos.
- **IMPLEMENTADO EN CÓDIGO, NO PROBADO TODAVÍA EN CACHYOS:** [c083973](https://github.com/nicoarg87/plasma-smartbar/commit/c0839734bd79033d3059e90d1ad7f7a9cb81580c) agrega `draggedDuringPress` a `moveGrip`, lo limpia al presionar y lo marca al activarse `gripDrag`; `onClicked` cierra `gripMenu` únicamente si visible y sin arrastre previo. No modifica apertura por clic derecho/teclado, lista de opciones o recuperación de Malvina.
- **PRÓXIMA PRUEBA EN CACHYOS:** `cd ~/plasma-smartbar; git pull; bash prototype/v0.1/probar_ancho.sh`. Derecho abre, izquierdo corto cierra; izquierdo corto con menú cerrado no abre; arrastrar con izquierdo no dispara cierre accidental; derecho sigue alternando. Comprobar «Mostrar/Ocultar Malvina». [Issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1), [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador. Panel del usuario intacto.

## Próximo hito técnico
**Issue #1 — Prueba de concepto v0.1 (modo superior).** Después de probar su base, abordar el **issue #2 — validación del modo inferior**, respetando los controles en el borde inferior.

**Siguiente paso inmediato:** **ejecutar el diagnóstico de ventanas reales en modo de solo lectura** en CachyOS y comprobar el modelo de tareas de KDE, mientras queda abierta la investigación del ancho asignado en `plasmoidviewer`; después comprobar que la preferencia se conserve tras reiniciar, así como exclusividad SO/bandeja y geometría fija. El nuevo [issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4) de memoria por aplicación se abordará después de obtener datos reales de ventanas. Si reaparece el problema del botón de recarga de `plasmoidviewer`, conservar el registro para diagnosticarlo. Revisar resultados en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); el [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) permanece borrador. Después, comenzar la investigación de ventanas reales y KWin/Wayland.

## Próximo hito organizativo
Conservar la sincronía documental entre la Constitución, el Manual Maestro y la plantilla del Proyecto de ChatGPT. **Si la plantilla en GitHub cambia, copiar su versión actualizada a las instrucciones del Proyecto en ChatGPT; la sincronización no es automática.**

## Convención de actualizaciones
Actualizar cuando cambie algún hito: fecha, decisión confirmada, qué cambió en GitHub, qué se ejecutó realmente, resultado y siguiente paso. No marcar como «probado» solo porque exista un issue o un archivo.
