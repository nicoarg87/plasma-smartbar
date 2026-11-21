# Plasma SmartBar Islands

**Barra inteligente, minimalista y modular para Linux con KDE Plasma 6: arriba por defecto, abajo como modo configurable previsto.**

> **Estado del proyecto:** documentación en main y prototipo visual v0.1 en rama experimental, con ensayos parciales ya realizados en CachyOS. **Todavía no hay versión instalable validada ni control real de ventanas.** El modo inferior sigue pendiente de implementación y pruebas.

## Idea principal
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
Este repositorio es **público**. El código y la documentación propia se publican bajo **licencia MIT** (ver [LICENSE](LICENSE)); los gráficos tienen su propia licencia y procedencia en [Licencias de recursos gráficos](docs/LICENCIAS_RECURSOS_GRAFICOS.md). Los GIF originales del botón SO generados con ChatGPT y aportados por el mantenedor se dedican a **CC0 1.0 Universal** en la medida de sus derechos, sin que esa dedicación se aplique automáticamente a imágenes externas o de procedencia sin verificar. Las publicaciones históricas conservan las autorizaciones concedidas originalmente; el proyecto actual usa MIT para código propio y CC0 para imágenes propias autorizadas.

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


**Prueba actual v0.1:** interfaz con nombre público Plasma SmartBar Islands, imagen SO tropical incluida en ZIP de ensayo por separado, y Malvina con autoocultamiento predeterminado y hover retardado configurable. Código experimental en rama `prototype/v0.1-islas-so`; para instrucciones ver [README de prueba](https://github.com/nicoarg87/plasma-smartbar/blob/prototype/v0.1-islas-so/prototype/v0.1/README.md). No reemplazar el panel existente.
