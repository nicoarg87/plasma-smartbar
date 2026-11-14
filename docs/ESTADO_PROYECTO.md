# Estado actual de Plasma SmartBar

**Fecha de corte:** 14 de noviembre de 2026  
**Estado general:** prototipo visual v0.1 de Plasma SmartBar **ejecutado en CachyOS con interacciones básicas comprobadas** (SO/bandeja, arrastre de isla 1, menú del agarre). Sigue en rama experimental, sin conexión a ventanas reales ni fusión a main; la anomalía de recarga del visor continúa sin diagnosticar. **No existe todavía una barra instalable y validada para uso diario.**

## Realmente completado

- [x] Repositorio público oficial: https://github.com/nicoarg87/plasma-smartbar
- [x] Licencia en el repositorio: GNU GPL-3.0.
- [x] [Manual Maestro v0.13](MANUAL_MAESTRO.md), [Constitución Técnica v1.5](CONSTITUCION_TECNICA.md), [GOVERNANCE](../GOVERNANCE.md), [CONTRIBUTING](../CONTRIBUTING.md), [ROADMAP](../ROADMAP.md).
- [x] Regla de ramas `Proteccion de main` **activa** en GitHub, aplica a la rama predeterminada, bloquea borrado y push no fast-forward, según lectura de GitHub el 14/11/2026: https://github.com/nicoarg87/plasma-smartbar/rules/27249133
- [x] Issue inicial: https://github.com/nicoarg87/plasma-smartbar/issues/1 (prueba de concepto v0.1, todavía no ejecutada).
- [x] Código de interfaz **preliminar** en rama `prototype/v0.1-islas-so`, mediante [PR #3 (borrador)](https://github.com/nicoarg87/plasma-smartbar/pull/3): paquete Plasma 6 (`metadata.json` + QML), islas y fichas ficticias, script de ejecución en ventana. **Solo revisado estáticamente**, sin ejecutar en CachyOS; main no incorpora el código aún.
- [x] [Protocolo de continuidad](CONTINUIDAD_CHATGPT.md) y [plantilla de instrucciones](PLANTILLA_INSTRUCCIONES_CHATGPT.md) para conversaciones futuras.
- [x] Diseño aprobado: **islas 1 y 2 visibles por defecto**, isla 3 oculta; controles de ventana a la derecha al maximizar, con viabilidad de solapamiento todavía no probada.
- [x] Requisito aprobado: agarre pequeño de **seis puntos (2 × 3) a la derecha de SO**, que debe permanecer estable al abrir bandeja o SO. **Implementado solo como demo QML en rama experimental**, sin ejecutar en CachyOS ni conectarlo a ventanas reales.
- [x] Aprobado: la isla 1 **vuelve automáticamente a la derecha al desmaximizar por defecto**, con casilla de configuración persistente para desactivarlo. En la demo se incluye simulación de maximización y preferencia KConfig `autoReturnRight=true`; **persistencia y conducta real pendientes de pruebas**.
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

## Próximo hito técnico
**Issue #1 — Prueba de concepto v0.1 (modo superior).** Después de probar su base, abordar el **issue #2 — validación del modo inferior**, respetando los controles en el borde inferior.

**Siguiente paso inmediato:** validar la **preferencia de retorno desactivable/persistente** (el retorno activado por defecto ya fue probado), y verificar exclusividad SO/bandeja y geometría fija. Si reaparece el problema del botón de recarga de `plasmoidviewer`, conservar el registro para diagnosticarlo. Revisar resultados en [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1); el [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) permanece borrador. Después, comenzar la investigación de ventanas reales y KWin/Wayland.

## Próximo hito organizativo
Conservar la sincronía documental entre la Constitución, el Manual Maestro y la plantilla del Proyecto de ChatGPT. **Si la plantilla en GitHub cambia, copiar su versión actualizada a las instrucciones del Proyecto en ChatGPT; la sincronización no es automática.**

## Convención de actualizaciones
Actualizar cuando cambie algún hito: fecha, decisión confirmada, qué cambió en GitHub, qué se ejecutó realmente, resultado y siguiente paso. No marcar como «probado» solo porque exista un issue o un archivo.
