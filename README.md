# Plasma SmartBar

**Barra superior inteligente, minimalista y modular para Linux con KDE Plasma 6.**

> **Estado del proyecto:** fase de diseño y documentación. **No existe todavía un complemento funcional ni una versión instalable.** CachyOS será el primer entorno de pruebas; el objetivo es funcionar también en otras distribuciones Linux con Plasma compatible.

## Idea principal
Plasma SmartBar busca concentrar la gestión de ventanas en una **barra superior de grosor constante**, sin llenar el escritorio de tareas visibles de forma permanente:

- Un **lanzador izquierdo** permite buscar e iniciar programas instalados.
- Un botón **SO** a la derecha abre hacia la **izquierda** una fila horizontal de fichas de **aplicaciones ya abiertas**. Por defecto agrupa todas las ventanas de una aplicación en una ficha; puede desagruparse por configuración.
- Una **bandeja expandible** se abre horizontalmente a la izquierda. **SO y bandeja son excluyentes**.
- Los botones de minimizar, restaurar y cerrar se integran arriba al maximizar una ventana.
- SO y bandeja pueden **cubrir temporalmente las pestañas del navegador**, pero jamás bajarlas, agrandar la barra o redimensionar la ventana.
- Video y juegos en **pantalla completa real** ocultan los controles superiores.
- Seleccionar una ventana **contrae SO por defecto**; opciones de configuración permitirán mantenerlo expandido o utilizar visibilidad adaptativa.

**Regla de diseño central:** la altura configurada de la barra es **invariable durante todos los estados**. Los paneles de herramientas secundarias pueden flotar debajo sin modificarla.

## Documentación rectora
- [Constitución técnica](docs/CONSTITUCION_TECNICA.md) — reglas innegociables y autoridad del diseño.
- [Manual Maestro v0.8](docs/MANUAL_MAESTRO.md) — especificación detallada, historia de decisiones, opciones y requisitos.
- [Gobernanza](GOVERNANCE.md) — quién dirige y cómo se aprueban los cambios.
- [Contribuir](CONTRIBUTING.md) — reportar bugs, discutir mejoras y enviar pull requests.
- [Hoja de ruta](ROADMAP.md) — desarrollo por etapas.
- [Continuidad entre conversaciones](docs/CONTINUIDAD_CHATGPT.md) — protocolo para retomar el proyecto sin perder decisiones.
- [Instrucciones para Proyecto ChatGPT](docs/PLANTILLA_INSTRUCCIONES_CHATGPT.md) — texto listo para pegar en la configuración del proyecto.
- [Estado actualizado](docs/ESTADO_PROYECTO.md) — avances realmente hechos y próximos pasos.

## Tecnología y prioridades
Qt 6, QML/Qt Quick, KDE Plasma 6 y KWin. Prioridad: **rendimiento, estabilidad, compatibilidad y accesibilidad**. La primera versión se centrará en el núcleo funcional **sin animaciones complejas ni multimedia MPRIS**; los temas, efectos y herramientas llegarán más adelante.

## Código abierto y dirección
Este repositorio es **público** y utiliza la licencia **GNU GPL versión 3** (ver [LICENSE](LICENSE)). Se permiten uso, estudio, cambios y forks conforme a sus condiciones.

**El mantenedor dirige la versión oficial.** Las personas interesadas pueden reportar errores, proponer funcionalidades o crear sus propias versiones; los cambios externos solo se incorporan al proyecto oficial después de revisión y aprobación. La Constitución Técnica y el Manual Maestro son la referencia funcional del repositorio.

## Estado actual
- [x] Repositorio público y licencia GPL-3.0.
- [x] Especificación funcional y reglas de colaboración iniciales.
- [ ] Diseño e investigación de las APIs necesarias.
- [ ] Primer prototipo de barra y gestión de ventanas.
- [ ] Pruebas de funcionamiento, foco, compatibilidad y fullscreen.
- [ ] Lanzamiento experimental.

**No usar las imágenes conceptuales previamente rechazadas como especificación.**
