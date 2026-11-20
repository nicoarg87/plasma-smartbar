# Auditoría de mantenimiento y optimización — 20/11/2026

**Repositorio oficial:** nicoarg87/plasma-smartbar. **Rama auditada:** `prototype/v0.1-islas-so` (PR #3, borrador).
**Alcance:** lectura de documentos rectores, ROADMAP, issues abiertos, estructura de 91 entradas en el árbol GitHub, archivos QML/JS principales, utilidades y pruebas. No se ejecutó el visor Qt en CachyOS, no se reemplazó el panel KDE ni se modificaron los temas originales.

## Evaluación

El visor está avanzando funcionalmente y el mantenedor reporta pocos errores de interfaz en CachyOS. No obstante, la calidad de uso del prototipo no demuestra todavía compatibilidad de producción con KWin/Wayland: siguen pendientes controles de ventana reales, superposición sobre pestañas maximizadas, fullscreen, rendimiento prolongado, configuración KConfig y compatibilidad con futuras versiones de Plasma.

**Datos observados:** `SoledadSettings.qml` ~5.153 líneas, `SmartBarContent.qml` ~2.847 líneas, `preview_redimensionable.qml` ~1.556 líneas. La rama contiene 18 tests `test_*.cjs`, pero el árbol examinado no incluye `.github/workflows/`. Los tres scripts `fijar_{dia,noche,atardecer}_fabrica.cjs` comparten ~91–93 % de líneas no vacías (aproximación textual; no significa equivalencia semántica).

## Hallazgos confirmados

| Área | Observación | Recomendación | Riesgo |
| --- | --- | --- | --- |
| Arquitectura | QML de Soledad y orquestador central muy extensos | Modularizar por responsabilidad, una extracción a la vez, siguiendo issue #11 | Alto si se hace masivamente |
| Código repetido | Scripts de empaquetado Día/Noche/Atardecer casi idénticos | Después de sellar y probar originales, evaluar motor común parametrizado preservando SHA-256, licencias y rutas | Alto; no tocar todavía |
| Verificación | 18 pruebas Node, sin ejecución automática de GitHub Actions verificada | Ejecutar la suite completa en CachyOS; después evaluar CI read-only | Bajo para ejecutar pruebas; medio para implantar CI sin verificar |
| Renderizado | Temporizador compartido de respiración de 50 ms en `SmartBarContent.qml`; temporizador de contorno de 50 ms en `SoActivityOutline.qml`; 19 interpolaciones de color; varios Canvas | Medir CPU/GPU, repintados y temporizadores activos antes de modificar frecuencias | Medio/alto sin perfilado |
| Documentación | Constitución/Manual/Estado/Continuidad/ROADMAP acumulativos; encabezados desfasados respecto de actualizaciones | Crear resúmenes/indexación y conservar historial, nunca sobreescribir reglas rectoras sin aprobación | Medio |
| Licencia | `LICENSE`, README y `metadata.json` del GitHub vigente indican MIT; algunas instrucciones de trabajo señalan GPL-3.0 | Solicitar aclaración expresa del mantenedor; **no modificar ni relicenciar** en limpieza | Alto/legal |

## Candidatos a código antiguo o no instanciado (NO confirmado como eliminable)

Los siguientes componentes no muestran referencias directas desde los caminos QML habituales examinados: `LogoEditor.qml` (se autodenomina **LEGADO**), `AppearanceEditor.qml`, `SoActivityEditor.qml`, `MalvinaIsland.qml`. Podrían conservar una interfaz alternativa, servir a scripts externos o estar reservados para la modularización aprobada. **No se borró ninguno.** Verificar referencias dinámicas, cargadores QML y tests antes de proponer eliminación.

También hay funciones con solo la definición visible en las rutas revisadas: `toggleSO()` y `dismissSoClock()` en `SmartBarContent.qml`; `storeTheme()`, `showSharedSizes()` y `showMalvinaGradient()` en `SoledadSettings.qml`. Algunas pueden ser API pública llamada dinámicamente y otras pueden proteger acciones de compatibilidad. **Una sola coincidencia de texto no demuestra código muerto.** No se modificaron.

Las claves históricas `themeDayJson`, `themeNightJson`, favoritas y predeterminada personal **NO son basura**: mantienen perfiles del usuario y compatibilidad de restauración. No eliminarlas ni migrarlas por estética.

## Cambios de riesgo bajo realizados en esta auditoría

1. `MalvinaSlots.js`: la expresión regular para validar IDs de proveedores se compila **una vez por consulta de lista** en vez de una vez por elemento. **Resultado:** 1.260 comparaciones de equivalencia de entradas/salidas anteriores y nuevas superadas en V8; pruebas aisladas `test_malvina_slots.cjs` y `test_malvina_url_policy.cjs` pasaron con un sistema de archivos simulado. Commit [bbcb448](https://github.com/nicoarg87/plasma-smartbar/commit/bbcb448d5fd00a138bc815d8a7c2a1a86fb3b1a7).
2. `prototype/v0.1/tests/ejecutar_todos.cjs`: ejecutor unificado que descubre `test_*.cjs` y lanza cada archivo por Node, sin iniciar KDE ni tocar panel/configuración; se revisaron las 18 pruebas disponibles para escrituras/operaciones peligrosas y no se encontraron ejecuciones reales de comandos de escritorio. Permite `--list`. **Archivo añadido, no se ejecutó toda la suite en Node real aquí** porque el entorno de auditoría no permite clonar GitHub. Commit [59258af](https://github.com/nicoarg87/plasma-smartbar/commit/59258af9bce60efc417fc2630551250bfb39bd93).

## Orden de trabajo sugerido

**Primero:** ejecutar la suite Node en CachyOS y comprobar visor por separado; guardar logs. **Segundo:** añadir CI solamente tras confirmar que todas las pruebas funcionan en una instalación limpia y definir qué tests requieren archivos originales. **Tercero:** perfilar temporizadores y Canvas/GIF antes de tocar renderizado. **Cuarto:** extraer primero un pequeño bloque sin estado de `SoledadSettings.qml` o `SmartBarContent.qml` con pruebas de ida/vuelta, un commit cada vez. **Último:** evaluar archivos no referenciados y unificar scripts de fábrica tras completar las capturas originales.

**Prueba recomendada:**

```bash
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
node prototype/v0.1/tests/ejecutar_todos.cjs
bash prototype/v0.1/probar_ancho.sh
```

**Estado de validación:** estática y V8 aislado: sí. Suite Node real en checkout: **pendiente**. Gráfica Qt/CachyOS posterior a esta optimización: **pendiente**. No se fusionó nada a `main`; PR #3 sigue en borrador.
