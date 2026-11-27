# Auditoría de modularización — 27/11/2026

**Repositorio:** `nicoarg87/plasma-smartbar` · **rama:** `prototype/v0.1-islas-so`.
**Referencia del código evaluado:** `fa79bbffa9fa0f1cdc8c0bfc5d20ab8cfabf60e1` (26/11/2026, anterior al auditor de solo lectura).
**Alcance:** estructura de QML/JavaScript, dependencias visibles y posibles redundancias; no modificación funcional ni del panel KDE.

## Medidas verificadas en GitHub
Comparación histórica con `d6c2e70f7a`:
- `SmartBarContent.qml`: de aproximadamente 4.003 a 2.370 líneas (−1.633; −40,8 %).
- `SoledadSettings.qml`: de aproximadamente 5.541 a 2.083 líneas (−3.458; −62,4 %). Los conteos previos de 2.085 corresponden al corte anterior a la última extracción.
- Archivos QML/JS de interfaz: de 46 a 78 (+32; 24 QML y 8 JS nuevos).
- Total de bytes de QML/JS: 827.459 → 831.665 (+4.206; +0,5 %).
- Por tanto, se **descongestionaron archivos centrales** pero **no se redujo el volumen total del código**. La estructura mejoró, no corresponde atribuir una mejora de rendimiento sin medirla.

## Duplicaciones efectivamente abordadas
- Fichas reales de tareas en dos posiciones: `SoledadRealTaskChip.qml` reutiliza la misma vista.
- Botón de reapertura simulada en dos posiciones: `SoledadDemoReopenButton.qml` evita dos implementaciones.
- Bandeja: `SystemTrayModel.js`, `SystemTrayController.js`, `SystemTrayView.qml` separan datos, transiciones y UI; **proveedor KDE real pendiente**, issue #24.
- `SoledadSettingsSync.js` centraliza la sincronización de 157 preferencias; el guardado sigue en su punto histórico.
- Páginas separadas de `SoledadSettings.qml` comparten el estado central y no introducen persistencia independiente.

Estas extracciones no acreditan por sí solas que se haya eliminado todo código repetido.

## Hallazgos de acoplamiento
Búsqueda textual de accesos a propiedades en los archivos actuales:
- `MalvinaRuntimeIsland.qml`: aproximadamente **134** accesos `host.` en 254 líneas.
- `SoledadRealTaskChip.qml`: aproximadamente **43** accesos `host.` en 125 líneas.
- `SoledadSettingsSync.js`: **156** accesos `host.` y **157** `settings.`; son asignaciones deliberadas de sincronización, no prueba de defecto.
- `SoledadLogoPage.qml` (aprox. 1.077 líneas) y `SoledadAppearancePage.qml` (aprox. 732 líneas) siguen siendo vistas grandes.

**Lectura:** la extracción física está avanzada, pero algunas interfaces todavía dependen de demasiadas propiedades de su anfitrión. Antes de reemplazar `host` por contratos más estrechos hay que identificar los valores leídos y las señales escritas; la modificación afectaría acoplamiento, no diseño funcional.

## Posibles restos heredados, NO código muerto confirmado
- `MalvinaIsland.qml` y `MalvinaRuntimeIsland.qml` coexisten y tienen interfaces distintas. `SmartBarContent.qml` instancia `MalvinaRuntimeIsland`; `main.qml` y el ensayo `preview_malvina_input_mask.qml` consultados no instancian `MalvinaIsland`. **El documento `docs/ARQUITECTURA_MODULAR.md` todavía define contratos del componente anterior.** No eliminarlo sin rastrear consumidores externos, cargadores dinámicos y variantes de empaquetado.
- No se dispone de inventario certificado de funciones o líneas muertas. La ausencia de una referencia textual no demuestra inaccesibilidad en QML.

## Instrumento publicado en esta etapa
`prototype/v0.1/scripts/auditar_modulos_smartbar.cjs` (**solo lectura**, [commit 3924ebd](https://github.com/nicoarg87/plasma-smartbar/commit/3924ebd8d3087cd60ab6204d9602abe2cb126b3b)):
- Enumera archivos QML/JS, líneas, referencias estáticas entre componentes y accesos `host.`.
- Presenta **candidatos** sin referencias evidentes, **nunca ordena borrados**.
- No ejecuta QML, comandos KDE ni cambia configuraciones; excluye tests/documentación del cómputo de consumidores de producción.
- El mecanismo se verificó sintácticamente y con un ejemplo artificial en Node, **no se ejecutó aún sobre la copia completa del proyecto en CachyOS**. Sus resultados pueden omitir referencias dinámicas y contener falsos positivos.

## Priorización sin cambiar requisitos
1. Revisar dependencias efectivas de `MalvinaIsland.qml` sin borrarlo ni sustituir funciones.
2. Reducir acoplamientos **por contrato** de `MalvinaRuntimeIsland` y fichas SO: solo tras identificar interfaces necesarias y preservar geometría, foco, entrada Wayland y todos los clics aprobados.
3. Investigar redundancias reales entre páginas de estilo/logo, sin unificar secciones con responsabilidades diferentes ni alterar temas.
4. Mantener pruebas dirigidas a la integración que se modifica, sin repetir sistemáticamente las pruebas funcionales ya aprobadas.

**Estado:** documentación e instrumento de análisis implementados; ninguna eliminación de código muerto validada; ninguna regresión QML/CachyOS atribuida a esta etapa de auditoría. Seguimiento en [issue #25](https://github.com/nicoarg87/plasma-smartbar/issues/25).
