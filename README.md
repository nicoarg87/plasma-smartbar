# Plasma SmartBar Islands

**Barra inteligente, minimalista y modular para Linux con KDE Plasma 6: arriba por defecto, abajo como modo configurable previsto.**

> **Estado del proyecto:** fase de diseño y documentación. **No existe todavía un complemento funcional ni una versión instalable; tampoco están implementados los modos superior o inferior.** CachyOS será el primer entorno de pruebas; el objetivo es funcionar también en otras distribuciones Linux con Plasma compatible.

## Idea principal
**Nombre oficial elegido por el mantenedor el 16/11/2026:** **Plasma SmartBar Islands** (antes Plasma SmartBar). El nombre refleja las islas independientes que componen la interfaz. Las islas funcionales actuales conservan sus nombres **Soledad** y **Malvina**. Se mantiene por ahora la dirección técnica del repositorio `nicoarg87/plasma-smartbar` y sus identificadores internos para proteger las pruebas v0.1.

Plasma SmartBar Islands busca concentrar la gestión de ventanas en **islas de una barra horizontal de grosor constante**, sin llenar el escritorio de tareas visibles de forma permanente. **Se desarrolla primero arriba y se admite como modo oficial configurable abajo:**

- Un **lanzador izquierdo** permite buscar e iniciar programas instalados.
- Un botón **SO** a la derecha abre hacia la **izquierda** una fila horizontal de fichas de **aplicaciones ya abiertas**. Por defecto agrupa todas las ventanas de una aplicación en una ficha; puede desagruparse por configuración.
- Una **bandeja expandible** se abre horizontalmente a la izquierda. **SO y bandeja pueden permanecer abiertas simultáneamente si hay espacio; si no, al abrir una se contrae la otra**.
- Los botones de minimizar, restaurar y cerrar se integran arriba al maximizar una ventana.
- SO y bandeja pueden **cubrir temporalmente las pestañas del navegador**, pero jamás bajarlas, agrandar la barra o redimensionar la ventana.
- Video y juegos en **pantalla completa real** ocultan los controles superiores.
- Seleccionar una ventana **contrae SO por defecto**; opciones de configuración permitirán mantenerlo expandido o utilizar visibilidad adaptativa.

**Regla de diseño central:** la altura configurada de la barra es **invariable durante todos los estados**, tanto **arriba** como **abajo**. Los paneles secundarios flotan **hacia el interior de la pantalla**, sin modificarla. Al maximizar, los controles de SmartBar están en el borde elegido: **superior o inferior**. Mover los controles **originales** de todas las aplicaciones no está garantizado y requiere pruebas con KWin/Wayland.

**Extensibilidad:** las orientaciones verticales izquierda/derecha quedan como experimentación futura, no como modos comprometidos. La arquitectura debe separar orientación/posición de la lógica de tareas. [Prueba de modo inferior #2](https://github.com/nicoarg87/plasma-smartbar/issues/2).

## Documentación rectora
- [Constitución técnica](docs/CONSTITUCION_TECNICA.md) — reglas innegociables y autoridad del diseño.
- [Manual Maestro v0.11](docs/MANUAL_MAESTRO.md) — especificación detallada, historia de decisiones, opciones y requisitos.
- [Gobernanza](GOVERNANCE.md) — quién dirige y cómo se aprueban los cambios.
- [Contribuir](CONTRIBUTING.md) — reportar bugs, discutir mejoras y enviar pull requests.
- [Hoja de ruta](ROADMAP.md) — desarrollo por etapas.
- [Continuidad entre conversaciones](docs/CONTINUIDAD_CHATGPT.md) — protocolo para retomar el proyecto sin perder decisiones.
- [Instrucciones para Proyecto ChatGPT](docs/PLANTILLA_INSTRUCCIONES_CHATGPT.md) — texto listo para pegar en la configuración del proyecto.
- [Estado actualizado](docs/ESTADO_PROYECTO.md) — avances realmente hechos y próximos pasos.

## Tecnología y prioridades
Qt 6, QML/Qt Quick, KDE Plasma 6 y KWin. Prioridad: **rendimiento, estabilidad, compatibilidad y accesibilidad**. La primera versión se centrará en el núcleo funcional **sin animaciones complejas ni multimedia MPRIS**; los temas, efectos y herramientas llegarán más adelante.

## Código abierto y dirección
Este repositorio es **público**. El código y la documentación propia se publican bajo **licencia MIT** (ver [LICENSE](LICENSE)); los gráficos tienen su propia licencia y procedencia en [Licencias de recursos gráficos](docs/LICENCIAS_RECURSOS_GRAFICOS.md). La futura imagen tropical generada con OpenAI se destinará a **CC0 1.0**, sin que esa dedicación se aplique automáticamente a imágenes externas o de procedencia sin verificar. Las copias históricas GPL-3.0 conservan sus permisos originales.

**El mantenedor dirige la versión oficial.** Las personas interesadas pueden reportar errores, proponer funcionalidades o crear sus propias versiones; los cambios externos solo se incorporan al proyecto oficial después de revisión y aprobación. La Constitución Técnica y el Manual Maestro son la referencia funcional del repositorio.

## Estado actual
- [x] Repositorio público; cambio autorizado a MIT para código/documentación propia el 16/11/2026.
- [x] Especificación funcional y reglas de colaboración iniciales.
- [ ] Diseño e investigación de las APIs necesarias.
- [ ] Primer prototipo superior de barra y gestión de ventanas.
- [ ] Modo inferior con controles SmartBar en la parte baja, pendiente de pruebas técnicas.
- [ ] Pruebas de funcionamiento, foco, compatibilidad y fullscreen.
- [ ] Lanzamiento experimental.

**No usar las imágenes conceptuales previamente rechazadas como especificación.**
