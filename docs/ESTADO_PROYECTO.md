# Estado actual de Plasma SmartBar

**Fecha de corte:** 14 de noviembre de 2026  
**Estado general:** documentación y organización del proyecto. **NO existe todavía código funcional de la barra, aplicación instalable ni pruebas ejecutadas en CachyOS.**

## Realmente completado

- [x] Repositorio público oficial: https://github.com/nicoarg87/plasma-smartbar
- [x] Licencia en el repositorio: GNU GPL-3.0.
- [x] [Manual Maestro v0.8](MANUAL_MAESTRO.md), [Constitución Técnica](CONSTITUCION_TECNICA.md), [GOVERNANCE](../GOVERNANCE.md), [CONTRIBUTING](../CONTRIBUTING.md), [ROADMAP](../ROADMAP.md).
- [x] Regla de ramas `Proteccion de main` **activa** en GitHub, aplica a la rama predeterminada, bloquea borrado y push no fast-forward, según lectura de GitHub el 14/11/2026: https://github.com/nicoarg87/plasma-smartbar/rules/27249133
- [x] Issue inicial: https://github.com/nicoarg87/plasma-smartbar/issues/1 (prueba de concepto v0.1, sin ejecución todavía).
- [x] [Protocolo de continuidad](CONTINUIDAD_CHATGPT.md) y [plantilla de instrucciones](PLANTILLA_INSTRUCCIONES_CHATGPT.md) para conversaciones futuras.

## Lo que NO se ha hecho
- [ ] No se ha creado el primer plasmoide QML/Qt.
- [ ] No se ha ejecutado `plasmawindowed` ni instalado Plasma SmartBar.
- [ ] No se ha demostrado detección/activación de ventanas o pestañas con KWin.
- [ ] No se ha probado superposición horizontal en navegadores maximizados ni fullscreen.
- [ ] No se han ejecutado pruebas de consumo de CPU/RAM, rendimiento o compatibilidad entre distribuciones.
- [ ] No hay lanzamiento, paquete, Release ni instalador.
- [ ] Crear y configurar el **Proyecto de ChatGPT** debe hacerse desde la interfaz de ChatGPT; GitHub no lo crea automáticamente.

## Decisiones de autoridad y protección
- Director funcional/de diseño: titular de nicoarg87/plasma-smartbar.
- Cualquier usuario puede copiar, bifurcar y proponer, conforme a GPL-3.0, pero no tiene escritura por defecto sobre el repo oficial.
- La regla `Proteccion de main` **no exige actualmente revisión previa por pull request**. No afirmar que GitHub obliga a recibir aprobación para cada commit; eso todavía no está configurado.

## Próximo hito técnico
**Issue #1 — Prueba de concepto v0.1.**

Objetivo inicial seguro: componente mínimo de interfaz que se abra en una ventana de pruebas (sin sustituir panel de usuario), botón SO, fichas ficticias horizontales y altura constante; después, validar modelo de ventanas reales y arquitectura posible de integración con KWin/Wayland.

## Próximo hito organizativo
Crear dentro de ChatGPT un proyecto privado **Plasma SmartBar — Desarrollo** y agregarle las instrucciones de [PLANTILLA_INSTRUCCIONES_CHATGPT.md](PLANTILLA_INSTRUCCIONES_CHATGPT.md). Si la UI lo permite, mover esta conversación de diseño al proyecto.

## Convención de actualizaciones
Actualizar cuando cambie algún hito: fecha, decisión confirmada, qué cambió en GitHub, qué se ejecutó realmente, resultado y siguiente paso. No marcar como «probado» solo porque exista un issue o un archivo.
