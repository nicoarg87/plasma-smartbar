# Arquitectura modular y seguridad de Plasma SmartBar

**Aprobado por el mantenedor:** 17/11/2026. **Alcance:** arquitectura interna de Linux/KDE Plasma 6; no cambia comportamiento, diseño ni requisitos funcionales. **Estado:** norma arquitectonica confirmada; aplicacion progresiva en rama experimental v0.1.

## Principios obligatorios

1. **Responsabilidad unica.** Cada componente expone una tarea clara; una isla no implementa internamente la logica de otra.
2. **Bajo acoplamiento.** Las dependencias se expresan mediante propiedades, senales y contratos documentados de Qt/QML. No crear referencias cruzadas arbitrarias ni estado global mutable innecesario.
3. **Seguridad por diseno y permisos minimos.** La capa de busqueda no accede a tareas KWin ni ejecuta comandos. Validar datos externos y rutas antes de utilizarlos. No usar interpolacion de texto usuario para comandos de shell.
4. **Separacion entre interfaz y servicios.** Las vistas dibujan y emiten acciones; los modulos de politica validan y resuelven; la coordinacion del sistema queda en el nucleo.
5. **Configuracion central con responsabilidad delegada.** Una unica entrada general a preferencias; cada isla mantiene su pagina o seccion, evitando duplicacion y dependencias circulares. Persistencia mediante KConfig cuando este validada.
6. **Carga y trabajo bajo demanda.** Evitar temporizadores, repintados, observadores y consultas cuando la funcion no esta activa; medir antes de optimizar. Modular no implica un proceso por cada modulo.
7. **Pruebas en capas.** Validar politicas puras, carga QML, interaccion del visor Qt, KConfig, modelo de ventanas reales y posteriormente KWin/Wayland. Una revision estatica no equivale a prueba en CachyOS.
8. **Mantenibilidad.** Componentes y funciones pequenos, nombres claros, comentarios sobre contratos, sin codigo duplicado. Priorizar componentes Qt 6, QML y KDE con licencias revisadas.
9. **Fallos localizados.** Errores en proveedores de busqueda no deben impedir el uso de SO, bandeja o lanzador; brindar mensajes de diagnostico sin exponer secretos.
10. **Gobernanza.** No modificar requisitos confirmados sin aprobacion del mantenedor. Trabajar en rama experimental, no reemplazar el panel del usuario; registrar resultados y pendientes.

## Distribucion de responsabilidades

| Modulo | Responsable | No debe hacer |
| --- | --- | --- |
| Nucleo/coordinador | Estado compartido, geometria, foco de interfaz y comunicacion entre islas | Contener codigo especifico de proveedores |
| Soledad | SO, fichas, bandeja, agarre y componentes visuales asociados | Construir URLs de Malvina |
| Malvina | Buscador, proveedores, panel y preferencias propias | Activar/cerrar ventanas KDE, modificar posicion de SO |
| Integracion KDE | Adaptadores de TasksModel, KWin/Wayland y capacidades verificadas | Definir la apariencia de las islas |
| Preferencias | KConfig y paginas modulares | Duplicar reglas de negocio |
| Politicas/seguridad | Validacion HTTPS, codificacion, limites de entradas | Ejecutar comandos arbitrarios ni guardar credenciales en QML |

**Contratos de Malvina actuales:** `MalvinaIsland.qml` expone `settingsRequested`, `installedAppsRequested`, `hideRequested`, `hoverStateChanged`, `focusSearch()` y `closeSearch()`. `MalvinaSearch.qml` gestiona teclado/presentacion; `MalvinaUrlPolicy.js` valida y construye el destino web; la apertura externa ocurre unicamente desde `MalvinaSearch.qml`. `MalvinaProvidersPage.qml` contiene la edicion de proveedores y actualmente usa `settingsTarget` del centro global: su desacoplamiento definitivo sigue pendiente.

## Politica de URL y limitaciones

- Solo destinos HTTPS con host publico de dominio completo; rechazar credenciales incrustadas, puertos arbitrarios, controles, espacios, barras invertidas y hosts ambiguos.
- En busqueda web, exigir `{query}` y sustituirla con `encodeURIComponent`.
- En IA, abrir la pagina sin afirmar que el texto fue enviado. No asumir API publica de prompts por URL.
- Esta comprobacion limita entradas accidentales o maliciosas, **no es un aislamiento de navegador**, filtro anti-phishing ni garantia de seguridad del sitio elegido. Una URL HTTPS valida puede apuntar a un sitio hostil.
- Seleccionar un navegador concreto y el atajo global Super+Espacio en KWin/Wayland continuan pendientes de integracion y pruebas. No ejecutar un navegador con `sh -c` a partir de datos editables.

## Estado por etapas — 17/11/2026

**Confirmado:** arquitectura modular, bajo acoplamiento, seguridad, pruebas por niveles y preservacion de todas las funciones aprobadas.

**Implementado en rama experimental:** archivos Malvina ya separados; extraccion de `MalvinaUrlPolicy.js` (validacion/creacion de URL), `MalvinaSearch.qml` delegado y `closeSearch()` definido para la llamada existente de `MalvinaIsland.qml`.

**Probado anteriormente en CachyOS:** diagnostico independiente de lectura dinamica de ventanas KDE. **No probado tras esta refactorizacion:** carga e interaccion Qt del buscador, plantillas personalizadas y nueva politica URL.

**Pendiente:** pruebas QML reales, pruebas de URLs limite, persistencia KConfig, atajo global Wayland, seleccion de navegador, separar secciones demasiado grandes de `SmartBarContent.qml` y `SoledadSettings.qml` en intervenciones pequenas con retest. No dividirlos masivamente sin pruebas intermedias. Superposicion de pestañas/controles y fullscreen en KWin/Wayland no resueltos.

**Licencias:** respetar `LICENSE` del repositorio para el codigo vigente (MIT, ratificada por el mantenedor el 21/11/2026), y el inventario separado para imagenes. No relicenciar material previo ni terceros sin revision.


## Bandeja de Soledad: primer corte modular conectado (26/11/2026)

**Implementado en la rama `prototype/v0.1-islas-so`, todavía no ejecutado en CachyOS tras esta refactorización.** Este corte separa de `SmartBarContent.qml` la bandeja existente en tres módulos con interfaces explícitas, sin incorporar funciones nuevas.

| Archivo | Responsabilidad y límite |
| --- | --- |
| `package/contents/ui/SystemTrayModel.js` | Fuente de datos de demostración de tres iconos, copia de entradas visibles sin mutar el origen; NO consulta KDE. |
| `package/contents/ui/SystemTrayController.js` | Reglas puras de alternancia y autocontracción; devuelve si hace falta comprobar ancho; NO conoce ventanas ni launcher. |
| `package/contents/ui/SystemTrayView.qml` | Renderizado de los botones mediante `Repeater`, con apariencia y señal de activación. Como los elementos repetidos se insertan en la fila padre, se mantienen el ancho, orden, alineación y recorte del color de la isla. |
| `SmartBarContent.qml` | Composición y efectos del contexto: cierre previo del launcher al pulsar la bandeja, garantía de ancho con fichas SO, estilos heredados y conexión a la preferencia `autoCollapseTray`. |
| `tests/test_system_tray_modules.cjs` | Regresión de reglas puras, interfaces de presentación y aislamiento de KDE. |

**Invariantes sin cambios:** flechas ◀/▶, expansión hacia la izquierda en una fila, alto fijo, prioridad de la última expansión solo si no caben ambas, separador entre bandeja y SO, autocontracción independiente y desactivada por defecto, apariencia vigente, panel KDE intacto. No se programa autocierre por temporizador ni por pérdida de foco.

**Verificado internamente:** ejecución de siete casos de funciones JS puras y revisión estructural de 15 contratos del QML. **Pendiente de prueba real**: carga e interacciones de esta composición nueva en CachyOS. La prueba del mantenedor anterior corresponde a la composición vieja, no habilita a clasificar este cambio como probado en Wayland.

**Próxima fase de bandeja:** desarrollar un proveedor StatusNotifierItem/StatusNotifierWatcher para iconos/estados reales con interfaz separada. No afirmar soporte de menús, notificaciones, volumen o redes hasta comprobar interfaces KDE y licencias; no alterar la bandeja habitual del usuario.

**Deuda técnica visible:** `SmartBarContent.qml` y `SoledadSettings.qml` aún concentran muchas responsabilidades. La refactorización de otras áreas debe hacerse por módulos y sin reconstruir o volver a probar funciones estables por rutina.


## Núcleo Soledad: políticas de distribución extraídas (26/11/2026)

**IMPLEMENTADO EN CÓDIGO EXPERIMENTAL:** tres responsabilidades anteriormente mezcladas en `SmartBarContent.qml` ahora pertenecen a módulos puros de JavaScript (`.pragma library`) que no dependen de la IU ni acceden a KDE:

| Módulo | Responsabilidad |
| --- | --- |
| `SoledadExpansionPolicy.js` | Resuelve convivencia/contracción de SO y bandeja por espacio disponible: modo centrado y modo derecho, prioridad de última expansión; devuelve el resultado sin cambiar estado directamente. |
| `SoledadLauncherPlacement.js` | Calcula una sola vez la coordenada horizontal del launcher, para el host LayerShell y el popup Qt; conserva el anclaje a SO, los dos diseños de categoría y los límites de pantalla. |
| `SoledadTaskSizing.js` | Calcula el ancho adicional de los nombres de ventana sin cambiar tamaño de letra, ventana o persistencia; tope 160 px como antes. |

**Composición existente preservada:** `SmartBarContent.qml` conserva las propiedades, señales, `systemIsland`, `systemRow`, `trayToggle`, `SoLauncherPopup`, `QtCore.Settings` y sus gestos. Las funciones originales permanecen como adaptadores delgados. El lanzamiento de aplicaciones, el panel KDE, Malvina, la bandeja real y los fondos no se modifican.

**Pruebas de código:** 720 comparaciones del código puro contra la lógica anterior ejecutadas en V8, sin diferencias; seis contratos de conexión verificados por inspección. `tests/test_soledad_layout_modules.cjs` reproduce los casos para Node; `tests/test_task_separator_resize.cjs` ahora inspecciona el módulo de tamaños en su lugar. No se afirma prueba Qt/Wayland de esta modificación.

**Estado:** parcialmente modularizado. La división de vistas y del centro `SoledadSettings.qml` continúa pendiente. [Issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25), [integración cc00828](https://github.com/nicoarg87/plasma-smartbar/commit/cc0082856a26783b467fc65e5cd09d6b3680b486). No introducir nuevas funciones o repetir pruebas de otras áreas ya aprobadas.


## Páginas extraídas del centro de configuración (26/11/2026)

**IMPLEMENTADO EN LA RAMA EXPERIMENTAL, NO EJECUTADO TODAVÍA EN CACHYOS:**

- `SoledadTaskStylesPage.qml` centraliza exclusivamente la vista de «Cajón y ventanas». Sigue usando las preferencias existentes de `SoledadSettings` mediante `settingsTarget` y reutiliza el `ColorDialog` original como `colorDialog`. No guarda ni restaura ajustes.
- `SoledadAboutPage.qml` centraliza la página informativa «Ayuda/Acerca de», sin dependencias sobre estados de configuración.
- `SoledadSettings.qml` contiene el único flujo de `Aplicar`, `Cancelar`, la captura de valores previos, la persistencia y la navegación; se redujo de 5.539 a **5.295 líneas**. No se modificaron opciones, modelos, valores por defecto, textos, tamaños de ventana, enlaces ni botones.
- Se corrigieron las referencias al `availableWidth` tras el traslado de las páginas; **ambas secciones coinciden con el contenido anterior** al revertir solo la indentación y nombres de referencias locales.
- Se añadió `tests/test_modulos_configuracion_soledad.cjs` y se adaptó `tests/test_task_close_mode.cjs` para inspeccionar los controles que ahora residen en la vista. Ambos contratos pasaron en evaluación interna de JS. La prueba QML real queda pendiente solo para esta composición nueva.

**Contrato:** una página de presentación no escribe preferencias persistentes, no crea botones de guardado y no invoca operaciones KDE. Toda persistencia y decisiones funcionales permanecen en la ventana principal. [Issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25), [integración 3c772e4](https://github.com/nicoarg87/plasma-smartbar/commit/3c772e467e923140851228591c09e5a9c476cb59). La descomposición de las otras páginas y servicios continúa pendiente.


## Modularización incremental — página de comportamiento de Soledad (26/11/2026)

**IMPLEMENTADO EN RAMA EXPERIMENTAL:** `SoledadBehaviorPage.qml` contiene, sin agregar opciones ni alterar valores, los controles anteriormente internos de `SoledadSettings.qml` para el comportamiento de SO y su launcher, y la autocontracción independiente de SO y bandeja. Conserva `settingsTarget` y el diálogo `launcherSwitchColorDialog` como dependencias explícitas; `Aplicar`, `Cancelar`, la línea de base y toda persistencia siguen exclusivamente en `SoledadSettings.qml`. El archivo principal pasó de 5.295 a **5.110 líneas**.

**Commits:** [extraer vista](https://github.com/nicoarg87/plasma-smartbar/commit/3373b995907a90f11868e7156ab549b874962a56), [conectar en configuración](https://github.com/nicoarg87/plasma-smartbar/commit/48fbb5a081a77143acf9e6ef5a53b0f8842174c5), [prueba estructural](https://github.com/nicoarg87/plasma-smartbar/blob/prototype/v0.1-islas-so/prototype/v0.1/tests/test_modulo_comportamiento_soledad.cjs). La revisión remota de la composición comprobó conexiones y preferencias; **NO se ejecutó todavía Node ni se cargó QML en CachyOS** después de este corte. No afecta el panel instalado, ventanas KDE, temas, fondos ni bandeja real. Seguimiento: [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## Modularización de contornos compartidos — 26/11/2026

**IMPLEMENTADO en rama experimental:** `SoledadSharedOutlinesPage.qml` concentra los controles visuales ya existentes para los contornos independientes de Soledad, Malvina, bandeja y agarre. El selector local se expone mediante `currentTargetIndex`, que utiliza `SoledadSettings.qml` para mantener intactos `outlineTargetKey`, `selectedOutline`, `setOutlineField()` y el diálogo de color anterior. Se conservaron las preferencias, los valores predeterminados, los botones y el mecanismo central de Aplicar/Cancelar.

`SoledadSettings.qml` se redujo de **5.110 a 5.028 líneas**; la extracción anterior de comportamiento lo había reducido desde 5.295. Commits: [módulo](https://github.com/nicoarg87/plasma-smartbar/commit/4d786dd9d51fa38ce57ee74ffad5758cae71213c), [integración](https://github.com/nicoarg87/plasma-smartbar/commit/7aaac490016f7a2bc938467ec0c2c34db6004751); prueba estructural `prototype/v0.1/tests/test_modulo_contornos_compartidos.cjs` añadida. **REVISADO por inspección estática; NO ejecutado Node/Qt/CachyOS** tras este corte. El panel KDE instalado permanece intacto. Seguimiento: [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## Modularización incremental: geometría y posición (26/11/2026)

**IMPLEMENTADO en rama `prototype/v0.1-islas-so`:** extracción de la página existente de posición, figuras y tamaños desde `SoledadSettings.qml` hacia `SoledadGeometryPage.qml`. Las preferencias siguen en la ventana principal mediante `settingsTarget`, sin crear controles nuevos ni cambiar valores. La navegación `showGeometry()` continúa volviendo al inicio del scroll con `geometryPage.resetScroll()` y la persistencia Aplicar/Cancelar se mantiene en SoledadSettings.

**Resultado:** `SoledadSettings.qml` pasó de 5.028 a **4.599 líneas** (429 menos en este corte). Se agregó `tests/test_modulo_geometria_soledad.cjs` para comprobar enlaces estructurales. [Módulo 06b8bcd](https://github.com/nicoarg87/plasma-smartbar/commit/06b8bcd80afe4ef694d7a4a6457ca0ba7f332279), [integración bd6c0e7](https://github.com/nicoarg87/plasma-smartbar/commit/bd6c0e730cebe04aaed1ee872fd094386d4e49dc), [test a74b053](https://github.com/nicoarg87/plasma-smartbar/commit/a74b05325003de832202fe806601dad9ed8d20a6). **Revisión estática de conexiones realizada; test Node y ejecución QML en CachyOS todavía no realizados.** No altera el panel KDE ni funciones confirmadas. Continuar [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## Extracción de apariencia y colores — 26/11/2026

**IMPLEMENTADO en `prototype/v0.1-islas-so`:** `SoledadAppearancePage.qml` contiene la página preexistente de colores, degradados y respiración visual de Soledad, Malvina y botones compartidos. `SoledadSettings.qml` continúa como propietario del estado de preferencias, los diálogos de color y las operaciones Aplicar/Cancelar. El módulo expone `currentTargetIndex`, `resetScroll()` y `scrollToBreathing()` para mantener intactos selector, navegación y acceso directo a la intensidad de respiración. Los tres diálogos originales se pasan por propiedades explícitas (color base, paleta y degradado). No se agregaron botones, efectos ni valores por defecto.

**Resultado:** el archivo central se redujo de **4.599 a 3.892 líneas** (707 líneas menos). Commits: [nueva página](https://github.com/nicoarg87/plasma-smartbar/commit/e57d1958906ff354363eebd0388a253acd6f90e9), [conexión](https://github.com/nicoarg87/plasma-smartbar/commit/0423ef29f0c628c3244c5999cfc817b4f7e9da9f) y [prueba estructural](https://github.com/nicoarg87/plasma-smartbar/commit/b1a84b922a85f5efa4cd6666d026df1b99333ed2). Se revisaron referencias tras el traslado y se añadió `tests/test_modulo_apariencia_soledad.cjs`; **no se ejecutó Node ni QML/Qt/CachyOS en este entorno**. No se modificó el panel KDE. Seguimiento: [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## Temas y packs: extracción de página QML (26/11/2026)

**IMPLEMENTADO en la rama experimental `prototype/v0.1-islas-so`:** se extrajo la página existente de temas a `SoledadThemesPage.qml`, con selector desplegable y sus popups, pack Playa 24hs (Día/Atardecer/Noche), programación horaria, ajuste de transición del wallpaper, previsualizaciones y creación de temas y packs personalizados. No se modificaron funciones, controles, valores predeterminados, ni datos de temas. La página importa `ThemePack.js` y `WallpaperFadeDuration.js`, conserva `settingsTarget` como único estado de preferencias y recibe explícitamente `imagePicker` y `paletteSamplerTarget` del anfitrión. `useGifPaletteForTheme.checked` ahora se expone como `themesPage.extractPaletteForNewTheme` para conservar el comportamiento del diálogo de archivos, sin duplicarlo. `Aplicar`/`Cancelar` y la persistencia siguen en `SoledadSettings.qml`.

**Resultado:** `SoledadSettings.qml` pasó de **3.892 a 3.280 líneas** (612 menos en este corte); la página extraída tiene 632 líneas. Commits [vista 771476f](https://github.com/nicoarg87/plasma-smartbar/commit/771476fce46631b28539f89b7cd06af67a595e8f), [integración acf7fe3](https://github.com/nicoarg87/plasma-smartbar/commit/acf7fe324876b8ad5b1cfa694977c7a58c346dd6), [test 462af2c](https://github.com/nicoarg87/plasma-smartbar/commit/462af2c554670277daa82185084d75451995a43f). `tests/test_modulo_temas_soledad.cjs` verifica contratos de dependencia, selector, creación de packs y estado central. **Verificado por inspección estática de referencias; todavía no se ejecutó Node ni se cargó el QML en CachyOS tras esta extracción**. Sin cambios en panel KDE, ventanas reales, SO, Malvina o configuración instalada. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).
