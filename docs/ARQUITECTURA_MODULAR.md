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
