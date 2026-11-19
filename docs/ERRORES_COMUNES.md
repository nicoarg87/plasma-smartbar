# Registro de errores y regresiones — Plasma SmartBar

**Inicio:** 18/11/2026. **Entorno de referencia:** KDE Plasma 6, Qt 6/QML, KWin/Wayland y pruebas iniciales del mantenedor en CachyOS. **Rama de desarrollo:** `prototype/v0.1-islas-so`.

## Para qué existe

Centralizar **todos** los defectos funcionales, visuales, de accesibilidad, rendimiento, guardado, seguridad e integración detectados en el proyecto, incluidos los corregidos. Identificar componentes frágiles, reincidencias y problemas estructurales. No tratar la última corrección de código como prueba exitosa sin un nuevo ensayo real.

Las decisiones funcionales siguen perteneciendo al mantenedor. Este archivo registra observaciones, diagnósticos y pruebas; no cambia requisitos confirmados.

## Método obligatorio al aparecer un error

1. Buscar por síntoma o componente en este archivo **antes** de programar. Si ya existe un caso, actualizar su identificador y marcar **regresión recurrente**, sin abrir una ficha duplicada.
2. Registrar: fecha; entorno/versión/commit; pasos para reproducir; resultado esperado y resultado real; frecuencia observada (sin inventar estadísticas); severidad; captura o texto de Konsole cuando exista.
3. Diferenciar **confirmado por ensayo**, **causa demostrada**, **hipótesis**, **corrección implementada**, **prueba pendiente** y **resuelto tras nueva prueba**. Registrar enlaces al commit y al issue si existen.
4. Registrar el componente responsable y los componentes relacionados; no atribuir la causa a un archivo únicamente por aparecer en un error QML.
5. Antes de volver a editar ese componente, ejecutar la **prueba de regresión** de todas sus fichas relacionadas. Si vuelve a ocurrir, marcar «REINCIDIÓ» y revisar la lógica compartida, no seguir acumulando parches locales.
6. Al cerrar un hito, actualizar este registro y `docs/ESTADO_PROYECTO.md`. Mantener un enlace desde `docs/CONTINUIDAD_CHATGPT.md`. Sin modificar ni reemplazar el panel KDE instalado.

**Escala de prioridad:** P0 = pérdida de datos/seguridad; P1 = impide usar función esencial o arrancar visor; P2 = comportamiento incorrecto recuperable; P3 = acabado visual/usabilidad. La prioridad puede cambiar tras pruebas.

## Índice de incidencias históricas

| ID | Área/componentes principales | Síntoma y frecuencia conocida | Prioridad | Estado de validación |
|---|---|---|---|---|
| ERR-001 | `SmartBarContent.qml`, `SoLauncherPopup.qml` | **Recurrente:** un clic en SO cierra y reabre el launcher; también falló alternar correctamente. Varias observaciones del mantenedor en sesiones sucesivas. | P1 | Parche experimental; **retest CachyOS pendiente** |
| ERR-002 | QML `Popup`, `Overlay`, `MalvinaSearch.qml` | **Recurrente:** al pulsar categorías, campos o proveedores Web/IA, el panel se cierra como si se hubiera tocado afuera. | P1 | Varias correcciones; **retest pendiente** |
| ERR-003 | `MalvinaSearch.qml` | Flechas Web/IA no recorren proveedores o desaparece el resaltado; Tab/foco problemáticos. | P2 | Parche experimental; **retest pendiente** |
| ERR-004 | `SmartBarContent.qml` y zona de hover | Malvina activa/autooculta a veces no reaparece al acercar el puntero. | P2 | Observado; **causa no confirmada** |
| ERR-005 | `SoLauncherPopup.qml` | Aplicaciones → Archivos → Aplicaciones perdía categoría, ancho y alto desplegado. | P2 | Parche experimental; **retest pendiente** |
| ERR-006 | `SoLauncherPopup.qml`, `QQC2.Popup` | Qt rechazó redefinir propiedad `FINAL availableHeight`: visor no arrancaba. | P1 | Corregido en código; posteriores pruebas del launcher indican que se pudo volver a abrir |
| ERR-007 | `SoledadSettings.qml`, ScrollView, layout | Etiquetas cortadas, controles desplazados horizontalmente y pestañas con scroll no deseado. | P2 | Iteraciones de diseño; **verificar todas las vistas y escalado** |
| ERR-008 | `SoledadSettings.qml`, Qt Settings/KConfig | Cambios de Malvina/Soledad no siempre se aplicaban o persistían; estética favorita incompleta. | P1 | Cableado de guardado añadido; **retest exhaustivo pendiente** |
| ERR-009 | `IslandPopupSurface.qml`, `MalvinaSearch.qml` | Opacidad al 100 % aún dejaba ver el fondo por el factor respiratorio. | P2 | Parche separó opacidad y pulso; **retest pendiente** |
| ERR-010 | `SmartBarContent.qml`, popup Malvina | Clic afuera no cerraba el buscador Web/IA; Escape sí. Intentos de arreglarlo provocaron ERR-002. | P2 | **Pendiente de validar** cierre exterior sin romper clic interior |
| ERR-011 | `MalvinaSearch.qml`, formas de isla | Fondo rectangular del editor tapaba bordes/redondeos de Malvina y campos de búsqueda no respetaban la forma. | P3 | Correcciones experimentales; prueba visual pendiente |
| ERR-012 | `SoLauncherPopup.qml`, catálogo `.desktop` | Categorías/lista originalmente sin íconos; extractor omitía `Icon`. | P3 | Se incorporaron metadatos; comprobar íconos reales/fallback en CachyOS |
| ERR-013 | `preview_redimensionable.qml`, ventana de pruebas | Superposición de launcher y controles inferiores; tamaño inicial insuficiente para popup ancho/alto. | P2 | Visor ampliado; bordes y pantallas pequeñas pendientes |
| ERR-014 | `SmartBarContent.qml`, `MalvinaSearch.qml` | Combinaciones de atajos (Super sola, Super+Espacio) y foco todavía no garantizadas globalmente en Wayland. | P2 | **Pendiente** de solución segura KWin y ensayo local |
| ERR-015 | Soledad/Malvina: gobernanza de preferencias | Configuración compartida en pestaña de isla incorrecta; color/gradiente o controles de panel imposibles de encontrar. | P2 | Menús reordenados; comprobar navegación y persistencia |

**Nota sobre frecuencia:** «recurrente» significa al menos dos observaciones o regresiones inequívocas en el historial del mantenedor, **no** un conteo automático de ejecuciones. No hay instrumentación de telemetría ni deben enviarse preferencias personales fuera del equipo.

## Fichas técnicas prioritarias

### ERR-001 — Doble acción del clic sobre SO

- **Resultado esperado:** un clic asignado al launcher abre; el siguiente cierra. El orden izquierdo/derecho es configurable; valor inicial vigente: izquierdo = cajón de aplicaciones (ventanas abiertas), derecho = launcher de aplicaciones.
- **Falla observada:** Qt podía cerrar automáticamente el `Popup` por `CloseOnPressOutside` en `mouse-press` cuando se tocaba SO, que está fuera del popup; después, el `onClicked` encontraba el popup cerrado y lo abría otra vez **en el mismo gesto**.
- **Causa probable en código:** interacción entre `closePolicy` del popup, orden `pressed/released/clicked`, `HoverHandler` y `openInstalledLauncher()`. El mecanismo debe verificarse gráficamente.
- **Corrección experimental:** desactivar cierre exterior mientras el puntero está en el botón disparador; capturar el estado anterior al pulsar para no reabrir al soltar. Commits [e4c8f07](https://github.com/nicoarg87/plasma-smartbar/commit/e4c8f0777151445e551bce6e6c39ff5c0643fe47) y [a2ec10c](https://github.com/nicoarg87/plasma-smartbar/commit/a2ec10c61ac7d599e9760665fcc7dfe319e6650f).
- **Regresión obligatoria:** abrir/cerrar 10 veces con el clic asignado; mantener pulsado; clic alternativo; Escape; cerrar afuera; abrir con Super local; popup con subpanel de Internet y modo Archivos; cero y varias ventanas activas.
- **Hipótesis arquitectónica si reincide:** el estado visible del popup y la lógica de gestos están repartidos; evaluar un controlador de estado/acciones **único**, primero bajo pruebas y con autorización antes de alterar diseño.

### ERR-002 y ERR-010 — Clic interior confundido con clic exterior (SO/Malvina)

- **Resultado esperado:** elegir categoría, proveedor Web/IA o cambiar interruptor **no cierra el panel**; clic fuera debe cerrarlo; Escape permite cierre individual.
- **Falla observada:** `Overlay.onPressed` se ejecutaba también sobre controles de popup y cerraba ambos. En Malvina, dos popups hermanos (campo y proveedores) hacían que seleccionar un proveedor fuera interpretado como clic externo al campo.
- **Correcciones experimentales:** se retiró el listener global `Overlay.onPressed` y se ajustaron `closePolicy` según los popups visibles; commits [60f9be5](https://github.com/nicoarg87/plasma-smartbar/commit/60f9be5be809ec495a48ef958328f56113fa54b0) y [3ac226a](https://github.com/nicoarg87/plasma-smartbar/commit/3ac226a8ba03c34fab0d7832b1245b845b127172).
- **Regresión obligatoria:** abrir SO → Internet → una app → Archivos → Aplicaciones; abrir Malvina → Tab → Web → IA, recorrer flechas y elegir Google/ChatGPT; abrir ambos a la vez; clic afuera; Escape en el panel con foco. Repetir tras cerrar y reabrir.
- **Hipótesis arquitectónica si reincide:** reemplazar cierres distribuidos por una política única de foco y límites geométricos verificable con tests Qt, manteniendo comportamientos confirmados.

### ERR-003 — Navegación Web/IA por teclado

- **Falla observada:** flechas izquierda/derecha perdían selección o saltaban entre ningún candidato y uno fijo.
- **Corrección experimental:** índices reales solo entre proveedores habilitados, resaltado visible y foco conservado en el campo. Commit [cb8cea5](https://github.com/nicoarg87/plasma-smartbar/commit/cb8cea50b3fb66c185b1aaaef6189d53154d429f).
- **Prueba:** 1, 3 y 10 proveedores de cada categoría, habilitados y ocultos; Tab/Mayús+Tab/flechas/Espacio/Enter, sin cierre involuntario.

### ERR-006 — Reutilización accidental de propiedad FINAL de Qt

- **Evidencia real:** consola CachyOS `SoLauncherPopup.qml:26:5: Cannot override FINAL property` y `Final member availableHeight is overridden`.
- **Corrección experimental:** renombrar `availableHeight` a `popupHeightLimit`; commits [9914e84](https://github.com/nicoarg87/plasma-smartbar/commit/9914e8400dd19b16d5f4b81aa3ad9eb4647b54f6) y [d555782](https://github.com/nicoarg87/plasma-smartbar/commit/d555782b503a7c308666375082cfdb5e3de998e7).
- **Prevención:** comprobar nombres heredados de `Popup`, `Item`, `Control` y `Window` antes de añadir propiedades; prueba de carga QML obligatoria.

### ERR-008 — Guardado y restauración de configuración

- **Riesgo:** perder estética elegida, permisos o estado de Malvina, especialmente al modificar formularios.
- **Regla:** no sobrescribir configuraciones personales; asegurar `Aplicar`, `appearanceV1`, `favoriteSoledadV1`, `personalDefaultV1`, KConfig, cambio y cierre; revisar cada nueva propiedad en todos los enlaces de guardado.
- **Prueba:** cambiar un ajuste por apartado, Aplicar, cerrar visor, reiniciar, restaurar favorita, restaurar personal. No introducir defaults en el repositorio como si fueran los valores particulares del mantenedor.

## Zonas de fragilidad (diagnóstico preliminar, no estadística)

| Área | Señal de fragilidad | Recomendación técnica condicionada |
|---|---|---|
| **Popups, focos y gestos (SO + Malvina)** | ERR-001, ERR-002, ERR-003, ERR-010; fallas recurrentes con correcciones cruzadas | Priorizar tests de interacción Qt y, si vuelven a fallar, proponer un controlador de estado dedicado antes de añadir más parches |
| **Preferencias y persistencia** | ERR-008, ERR-015; varias rutas del dato | Centralizar contratos de ajustes y pruebas de guardado, sin perder valores existentes |
| **Geometría y layouts** | ERR-005, ERR-007, ERR-011, ERR-013 | Pruebas en varios tamaños y escalas de fuente, sin scroll horizontal ni cambios al panel KDE |
| **Compatibilidad KDE/Qt** | ERR-004, ERR-006, ERR-014 | Validar módulos, propiedades reservadas, Wayland y atajos globales en CachyOS antes de declararlos compatibles |
| **Legibilidad/estilo** | ERR-009, ERR-012 | Probar fondos opacos, respiración, íconos locales y fallback accesible |

Los grupos son una **priorización provisional** basada en las observaciones documentadas, no cifras automáticas ni una declaración de que el problema está resuelto.

## Plantilla para nuevas incidencias

```text
ID: ERR-0XX
Fecha / reportado por:
Componente(s) y ruta(s):
Categoría / severidad:
Versión / rama / commit / entorno:
Pasos exactos:
Esperado:
Observado:
Evidencia (captura / Konsole / issue):
¿Recurrió? Fechas y vínculos:
Causa confirmada / hipótesis diferenciadas:
Corrección implementada y commit:
Regresión a probar:
Resultado REAL de prueba en CachyOS:
Estado (observado / diagnosticado / corregido-no-probado / resuelto-probado / reabierto):
Impacto en guardado / seguridad / panel existente:
```

## Historial de mantenimiento del registro

- **18/11/2026:** creado por indicación del mantenedor, incorporando incidencias históricas de las pruebas v0.1 y la prioridad de detectar debilidades arquitectónicas por recurrencia. Pendiente de confirmar cada solución en CachyOS. No se ha activado telemetría ni capturado información del usuario automáticamente.
