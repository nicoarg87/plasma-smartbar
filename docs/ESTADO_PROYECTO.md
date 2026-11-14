# Estado actual de Plasma SmartBar

**Fecha de corte:** 14 de noviembre de 2026  
**Estado general:** documentación y organización del proyecto. **Primera prueba visual v0.1 ESCRITA en rama experimental**, todavía no ejecutada en KDE/CachyOS, no incorporada a main ni probada con ventanas reales. **No existe aún una barra funcional e instalable para uso diario.**

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

## Próximo hito técnico
**Issue #1 — Prueba de concepto v0.1 (modo superior).** Después de probar su base, abordar el **issue #2 — validación del modo inferior**, respetando los controles en el borde inferior.

**Siguiente paso inmediato:** abrir y probar localmente el [prototipo de la rama experimental](https://github.com/nicoarg87/plasma-smartbar/blob/prototype/v0.1-islas-so/prototype/v0.1/README.md) mediante `plasmoidviewer`, sin sustituir el panel de usuario. Revisar en #1 qué funciona y qué falla; luego integrar el [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) únicamente tras revisión y aprobación funcional. Posteriormente, validar modelo de ventanas reales y arquitectura KWin/Wayland.

## Próximo hito organizativo
Conservar la sincronía documental entre la Constitución, el Manual Maestro y la plantilla del Proyecto de ChatGPT. **Si la plantilla en GitHub cambia, copiar su versión actualizada a las instrucciones del Proyecto en ChatGPT; la sincronización no es automática.**

## Convención de actualizaciones
Actualizar cuando cambie algún hito: fecha, decisión confirmada, qué cambió en GitHub, qué se ejecutó realmente, resultado y siguiente paso. No marcar como «probado» solo porque exista un issue o un archivo.
