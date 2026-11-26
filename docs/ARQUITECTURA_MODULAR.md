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


## Modularización: logo SO, GIF, reloj y efectos — 26/11/2026

**IMPLEMENTADO en rama experimental:** `SoledadLogoPage.qml` contiene los controles originales del logo SO, imagen/GIF, encuadre, texto, reloj y efectos del contorno. El módulo recibe el estado `settingsTarget` y diez dependencias explícitas (diálogos de imagen, fuente y color; analizador de paleta); no duplica operaciones KDE ni persistencia. `SoledadSettings.qml` mantiene Aplicar/Cancelar, diálogos, configuraciones y funciones de navegación, ahora delegadas a `logoPage.resetScroll()` y `logoPage.scrollToLight()`.

**Resultado:** archivo principal de **3.280 a 2.242 líneas** (1.038 líneas menos). Nueva página de 1.077 líneas, aún grande y susceptible de posterior división cuidadosa. [Vista f74596f](https://github.com/nicoarg87/plasma-smartbar/commit/f74596fc089312793de8b67efeff17f09b264cba), [conexión 59a3df5](https://github.com/nicoarg87/plasma-smartbar/commit/59a3df5110f7dc2da3436949ca82fbd24836e533), [prueba estructural 89f4359](https://github.com/nicoarg87/plasma-smartbar/commit/89f43594692987bfa52332d4dbf312e160da9130). **Verificado por comparación textual del cuerpo trasladado** con el código anterior, descontando renombres de identificadores y dependencias explícitas, y por inspección de las conexiones. **NO ejecutado Node/Qt/CachyOS** tras esta extracción. El panel KDE sigue intacto y no se cambiaron opciones ni comportamientos confirmados. Seguimiento: [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## Modularización: diálogo de fábrica y lector GIF bajo demanda (26/11/2026)

**IMPLEMENTADO en rama experimental `prototype/v0.1-islas-so`:** `SoledadFactoryExportDialog.qml` aloja el diálogo existente de copia de JSON de apariencia de fábrica sin guardar ni sobrescribir presets; recibe únicamente `settingsTarget`. `SoledadPaletteSampler.qml` aloja el `Canvas` de análisis de fotograma GIF y su temporizador original de 3.500 ms, con `settingsTarget` y `appearanceTargetIndex` explícitos. El análisis sigue iniciándose por petición del usuario; conserva protección frente a cambio de imagen durante el muestreo, reglas independientes para isla/contorno/tema y mensajes de error. No se introduce muestreo continuo, acciones nuevas, botones nuevos ni persistencia propia.

**Resultado:** `SoledadSettings.qml` baja de **2.242 a 2.085 líneas** (157 líneas netas menos). Commits [diálogo cc90b19](https://github.com/nicoarg87/plasma-smartbar/commit/cc90b19ae7c74c1a71b53885e82d25816b067c8a), [integración diálogo ce75e06](https://github.com/nicoarg87/plasma-smartbar/commit/ce75e06a0ec8a24a8fc2ae283417f34b8d7ce84c), [muestreador fccc295](https://github.com/nicoarg87/plasma-smartbar/commit/fccc2957ebb89dfb85b5ff0ee06146aa8b416c7f), [integración muestreador 9d8de56](https://github.com/nicoarg87/plasma-smartbar/commit/9d8de568b766c32881e523c1952c2416a4279a98), [test fd44ac3](https://github.com/nicoarg87/plasma-smartbar/commit/fd44ac3b229bf00783dc9c1475a87912fa98bc6d). Revisión estática de vínculos y guardado central realizada, **sin ejecución de Node ni carga QML en CachyOS tras este corte**. El panel KDE instalado permanece intacto. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: matemática de respiración desacoplada — 26/11/2026

**IMPLEMENTADO en rama experimental:** `SoledadBreathingMath.js` aísla dos cálculos puros de los degradados de Soledad y Malvina: `breathingFactor(intensity, phase)` (amplitud/fase) y `nextPhase(phase, speed, dt)` (avance de fase con límites de velocidad). `SmartBarContent.qml` mantiene el temporizador de 50 ms, las tres condiciones de ejecución, la configuración individual/compartida y todas las propiedades de estado; solo delega los cálculos a las funciones nuevas. No cambia la interfaz, la frecuencia del reloj, la duración de efectos ni incorpora animaciones nuevas.

**Commits:** [módulo aa1e50e](https://github.com/nicoarg87/plasma-smartbar/commit/aa1e50ec4f9e7fd92fb89d2480c3b9b59258c5c1), [conexión 84208f8](https://github.com/nicoarg87/plasma-smartbar/commit/84208f86d086de9b0ba0dfef1a22a044db4042b4), [prueba c1fec9d](https://github.com/nicoarg87/plasma-smartbar/commit/c1fec9d0abc1f018e3995c66684ffc8ed76ebb77). Se añadió `tests/test_modulo_respiracion_soledad.cjs` para comparar 204 combinaciones numéricas contra las expresiones originales y revisar los tres enlaces y temporizador en QML. **Se revisaron las sustituciones de código; no se ejecutó aún el test Node ni el nuevo QML en CachyOS.** El panel Plasma del usuario no se modifica. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: controles ficticios de ventana desacoplados — 26/11/2026

**IMPLEMENTADO en rama experimental:** se movió el bloque visual de controles ficticios `− □ ×` de `SmartBarContent.qml` a `SoledadDemoWindowControls.qml`. La instancia principal conserva `id: windowControls`, `visible: root.previewMaximized`, anclaje derecho y centrado vertical. Las dos reservas de espacio que calculan `windowControls.width + 6` continúan en la coordinación existente. El módulo conserva medidas, colores, tres botones deshabilitados y su texto de ayuda; no llama APIs de ventanas reales ni instala nada en KDE. Este componente es únicamente del visor de prueba.

**Resultado:** `SmartBarContent.qml` de **3.988 a 3.967 líneas**. [Módulo e1f6ac6](https://github.com/nicoarg87/plasma-smartbar/commit/e1f6ac626e882f5f728f287c003002b08c0b087a), [conexión 1edee76](https://github.com/nicoarg87/plasma-smartbar/commit/1edee76b957b7aef64a7ad24fb1e3387c14352c6), [test 5851ec4](https://github.com/nicoarg87/plasma-smartbar/commit/5851ec40f7a2ffbb1bf711dd39822219cb86bdda). Se creó `tests/test_modulo_controles_demo_soledad.cjs` para garantizar anclaje, visibilidad, ancho reservado y ausencia de acciones reales. **Revisión de vínculos realizada; test Node y ejecución QML/CachyOS pendientes tras este corte**. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: ficha de ventana real compartida — 26/11/2026

**IMPLEMENTADO en rama experimental:** extracción de las dos definiciones **idénticas** `delegate: IslandButton` para tareas reales (una con SO a la derecha y otra con SO centrada) hacia `SoledadRealTaskChip.qml`. Ambas instancias `Repeater` conservan modelos y condiciones de visibilidad propios y ahora usan `delegate: SoledadRealTaskChip { host: root }`. El nuevo módulo recibe el anfitrión y conserva las propiedades obligatorias `model` e `index` que proporciona el repetidor QML; mantiene visualización de grupos, hover diferido de 420 ms, solicitud de vista previa, activación solicitada de ventana, cierre solicitado desde ficha y personalización previamente existente. No se cambia la lógica de KDE, ni se agregan botones o funciones. La unión elimina el riesgo de que los modos derecha/centro diverjan en futuros cambios.

**Resultado:** `SmartBarContent.qml` pasó de **3.967 a 3.737 líneas** (230 menos); módulo nuevo de 125 líneas. Commits: [módulo 258e128](https://github.com/nicoarg87/plasma-smartbar/commit/258e12813317167ca1fe4f15aee22948567b4ee0), [integración 979efa6](https://github.com/nicoarg87/plasma-smartbar/commit/979efa6593c8f5e1895f5381ff62416326ca84c2), [test estructural 6785237](https://github.com/nicoarg87/plasma-smartbar/commit/678523736d1170c10c71158f8e3557bb037a1554). Se creó `prototype/v0.1/tests/test_modulo_ficha_real_soledad.cjs`. **Inspeccionado estáticamente; aún sin ejecutar Node ni recargar QML en CachyOS** después de esta integración. No afecta al panel KDE instalado. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: botón de reapertura simulada compartido — 26/11/2026

**IMPLEMENTADO en rama experimental:** los dos controles `+` de recuperación de ventanas ficticias —modo Soledad a la derecha y modo centrado— eran equivalentes excepto por el modo/ID. Ahora ambas posiciones usan `SoledadDemoReopenButton.qml` mediante `host: root` y `presentationMode: "right"`/`"center"`. Se conservan dimensiones, accesibilidad, estado habilitado, dibujo del signo `+`, condición de aparición, texto de ayuda y llamada existente `reopenNextDemoWindow()`. No hay nuevas funciones ni operaciones sobre ventanas KDE reales.

**Resultado:** `SmartBarContent.qml` de **3.737 a 3.669 líneas** (68 menos). [Módulo 29440aa](https://github.com/nicoarg87/plasma-smartbar/commit/29440aa44898df6c2d480f454c28d6af0030d73d), [integración e6e9950](https://github.com/nicoarg87/plasma-smartbar/commit/e6e995020e85cd8218521d77ca4a6c90344c65ef), [test 2083a65](https://github.com/nicoarg87/plasma-smartbar/commit/2083a65e41e2e1e3513a644561cf66dda0f79b27). `tests/test_modulo_reapertura_demo_soledad.cjs` creado; **revisión estática de referencias realizada; ejecución Node y validación QML/CachyOS pendientes**. El panel Plasma no fue alterado. Seguimiento: [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: separador arrastrable bandeja/SO extraído — 26/11/2026

**IMPLEMENTADO en rama experimental:** `SoledadTaskWidthSeparator.qml` concentra el separador visual de 14 × 28 px entre bandeja y cajón de ventanas Soledad. Se mantuvieron tres marcas, cursor de ajuste horizontal, disponibilidad únicamente con ambas zonas expandidas, drag relativo a `root`, distribución proporcional entre fichas, doble clic para restablecer el ancho y guardado al soltar. El módulo recibe `host: root` y mantiene las preferencias y persistencia fuera de sí; la ubicación vertical ahora usa `parent.height` equivalente a `systemRow.height` en la ubicación original. Sin cambios a fichas reales, launcher ni panel KDE.

**Resultado:** `SmartBarContent.qml` de **3.669 a 3.619 líneas** (50 menos), nuevo componente de 59 líneas. [Módulo 86ebad3](https://github.com/nicoarg87/plasma-smartbar/commit/86ebad365a660a6aa351f7d3f11a3d9d4332a922), [integración 19f8382](https://github.com/nicoarg87/plasma-smartbar/commit/19f838242c9ecafc94fb3a5b8b2a964f04109072), [test 551ea01](https://github.com/nicoarg87/plasma-smartbar/commit/551ea01e22380aa8e33f62dbbe2b33996bca5459). Verificación de contratos por revisión estática; **test Node y carga QML/CachyOS aún no ejecutados**. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: interruptor de bandeja desacoplado — 26/11/2026

**IMPLEMENTADO en rama experimental:** `SoledadTrayToggle.qml` contiene el `IslandButton` existente para expandir/contraer la bandeja en la fila única de Soledad. Se conservan flechas, forma, colores heredados y propios, transparencia para mostrar el degradado, contorno, texto de ayuda y la acción `toggleTray()`. El anfitrión mantiene `id: trayToggle`, por lo que el cálculo original `trayToggle.implicitWidth` sigue siendo válido. El componente recibe `host: root` sin duplicar preferencias ni persistencia. No afecta al modelo real de ventanas, al launcher ni al panel KDE.

**Resultado:** `SmartBarContent.qml` se reduce de **3.619 a 3.603 líneas**; módulo QML independiente de 26 líneas. Commits: [módulo cda6289](https://github.com/nicoarg87/plasma-smartbar/commit/cda62893dbbbadace53a0aa3da0bcf7df5773e61), [integración 60a3b0d](https://github.com/nicoarg87/plasma-smartbar/commit/60a3b0d1ce81b17d44a3fae2078f868888cc97ef), [test c9bb33a](https://github.com/nicoarg87/plasma-smartbar/commit/c9bb33a409bf9255ede0ea0d25995ba654b3601d). `tests/test_modulo_interruptor_bandeja_soledad.cjs` agregado. **Revisión estática de vínculos realizada; ejecución del test Node y carga QML/CachyOS pendientes**. Continuidad en [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## SmartBarContent: superficies triangulares SO y Malvina — 26/11/2026

**IMPLEMENTADO en rama experimental:** `SoledadTipBackground.qml` y `MalvinaTipSurface.qml` extraen los dos `Canvas` existentes de punta izquierda triangular (`leftTip`), conservando geometría, relleno, dirección/degradado, transparencia, grosor y contorno, respiración y las señales de repintado `Connections`. Ambos reciben `host: root`; el anfitrión conserva `anchors.fill: parent` sobre las instancias, sin alterar posición o grosor de las islas. Los identificadores internos de los Canvas no tenían consumidores externos, así que se mantuvieron locales a cada componente. No se cambiaron controles, accesibilidad ni lógica de ventanas.

**Resultado:** `SmartBarContent.qml` de **3.603 a 3.471 líneas** (132 líneas menos). Commits: [triángulo Soledad 849b5a6](https://github.com/nicoarg87/plasma-smartbar/commit/849b5a6a416daf1f092d9bb039ecb1adddd2934c), [triángulo Malvina af9d2f7](https://github.com/nicoarg87/plasma-smartbar/commit/af9d2f70b8d66fa34eab45971d842777005ee69b), [integración 78a6ca2](https://github.com/nicoarg87/plasma-smartbar/commit/78a6ca2a21822a79995cb304275887963c3d5354), [test 4bc88d1](https://github.com/nicoarg87/plasma-smartbar/commit/4bc88d1887c8d0f6d174f5d9beb8271870c35a8e). Prueba `tests/test_modulos_superficies_triangulares.cjs` agregada para verificar conexiones y propiedades. **Inspección estática completada; ejecución Node y QML en CachyOS pendientes**. No se modificó el panel KDE instalado. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).


## Modularización de SmartBarContent: cuatro bloques adicionales (26/11/2026)

**IMPLEMENTADO en rama experimental:**

- `SoledadIslandSurface.qml` separa el `Canvas` de fondo de Soledad, con relleno, radios, degradado, señales de repintado y máscara `destination-out` detrás de bandeja/agarre. Recibe `host`, `rowTarget`, `islandTarget` y `gripTarget`, manteniendo el cálculo geométrico en la misma fila. [Módulo](https://github.com/nicoarg87/plasma-smartbar/commit/3695a19fb465c8814c0694b632e857eb6ded51ab) · [integración](https://github.com/nicoarg87/plasma-smartbar/commit/8949d5684e569c676786e2f1baa268e1205ba35a).
- `SoledadMainButton.qml` extrae el botón SO, conservando decoración, reloj, GIF, pulsación larga de 400 ms, acciones izquierda/derecha y el ID externo `soButton`. Recibe `host`, `islandTarget` y `launcherPopup`. [Módulo](https://github.com/nicoarg87/plasma-smartbar/commit/a4bc79b38165f173f2b7f351a02579e4b3d24053) · [integración](https://github.com/nicoarg87/plasma-smartbar/commit/bf5b060b5c216a86b08797cfa068b851c539975f).
- `SoledadGripMenu.qml` separa el menú contextual del agarre, sin cambiar sus opciones, callbacks, posición `Popup.Window` o guardado. Sus dependencias explícitas son `host`, `gripTarget`, `positionEditor`, `clockRevealTimer`. [Módulo](https://github.com/nicoarg87/plasma-smartbar/commit/bc5318858072b5f88c1b281ae4e9a19c78cc23d8) · [integración](https://github.com/nicoarg87/plasma-smartbar/commit/440ac5d25bdcc576c4f32fc3b25ce8d84267ffa0).
- `SoledadLauncherHost.qml` extrae las conexiones y anclajes de la instancia `SoLauncherPopup`. Se mantienen `installedAppsPopup`, parent dinámico Wayland/visor, `SoledadLauncherPlacement.screenLeft`, disparadores de cierre, foco y selección, sin modificar las políticas confirmadas. [Módulo](https://github.com/nicoarg87/plasma-smartbar/commit/39536244468b006bf19bf3dee61f900ebb2883a9) · [integración](https://github.com/nicoarg87/plasma-smartbar/commit/e3cbca10d055e9b85fca0420cb7569f728e77f44).

**Resultado:** `SmartBarContent.qml` de **3.471 a 2.982 líneas** (489 líneas menos en este corte). Se agregaron pruebas estructurales `tests/test_modulos_superficie_boton_menu_soledad.cjs` y `tests/test_modulo_host_launcher_soledad.cjs`, commits [4418405](https://github.com/nicoarg87/plasma-smartbar/commit/441840543328c32c9b19a421a4f3e0b5d974de06) y [95026df](https://github.com/nicoarg87/plasma-smartbar/commit/95026df9acca12138bfb23b6c97a264f82d77105). **Estado: implementado y revisado estructuralmente; NO probado con Node ni con QML/Qt en CachyOS.** No se modificaron el panel KDE ni los requisitos funcionales; los bloques todavía acoplados del agarre/arrastre y geometría de Malvina quedan **pendientes de una extracción con comprobación de ejecución**, sin forzar su separación ni alterar el comportamiento aprobado. Seguimiento [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).
