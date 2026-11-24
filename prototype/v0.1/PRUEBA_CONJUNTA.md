# Sesión conjunta experimental: Soledad + Malvina

**Rama:** `prototype/v0.1-islas-so`. **Estado:** código nuevo pendiente de validación en CachyOS/KWin/Wayland. No es una instalación ni un autoinicio.

## Qué hace

`probar_islas_juntas.sh` compila **una sola vez** el puente Qt temporal existente, después lanza **dos procesos independientes**: Soledad en el borde superior derecho y Malvina en el izquierdo. Mantiene el panel KDE habitual (incluido el panel inferior) sin modificar sus ajustes. Se siguen usando regiones de entrada limitadas y no se reserva una nueva zona de panel. Soledad conserva las tareas reales agrupadas en **solo lectura** y los perfiles de posición del ensayo; Malvina mantiene sus búsquedas Web/IA, navegador elegido, consentimiento separado y autoocultamiento tras 600 ms de hover.

En esta sesión se eliminan únicamente los autocierres de 90/180 segundos. Si una isla se cierra o falla, el lanzador termina la otra. **No** se activa ningún autoinicio ni se instala un plasmoide. No cambia fondos reales de KDE, horario Playa 24hs ni previsualizaciones reales; esas integraciones quedan pendientes.

## Ejecutar desde Fish (CachyOS)

```fish
cd ~/plasma-smartbar
and git switch prototype/v0.1-islas-so
and git pull --ff-only
and node prototype/v0.1/tests/test_islas_juntas.cjs
and bash prototype/v0.1/probar_islas_juntas.sh
```

Se requiere Wayland, `cmake`, compilador C++ y dependencias Qt/LayerShell ya instaladas para los ensayos anteriores. Si falta algo, el script se detiene sin instalar paquetes. **Dejar Konsole abierta o minimizada** mientras se usa; `Ctrl+C` detiene ambas. No ejecutar una segunda copia en paralelo; se utiliza bloqueo `flock` si está disponible.

## Logs de la sesión

Cada arranque genera una carpeta privada bajo `~/.local/state/plasma-smartbar/ensayos/` (o `$XDG_STATE_HOME/plasma-smartbar/ensayos/`), con:

- `compilacion.log` — errores de CMake y compilador.
- `soledad.log` — mensajes QML/KDE y cambios de la isla SO.
- `malvina.log` — mensajes QML y estados del buscador.

La terminal imprime la ruta exacta. En otra Konsole se puede seguir el registro con `tail -f` usando las rutas mostradas. `ultima_sesion.txt` apunta al directorio de la última ejecución.

Los logs se guardan **localmente y con permisos restringidos**; no se suben a GitHub y **no registran deliberadamente cada tecla o consulta escrita**. Pueden contener títulos, identificadores de ventanas, rutas u otra información del sistema, por lo que se deben revisar antes de compartir. No hay rotación automática todavía; borrar sesiones antiguas debe ser una decisión manual. No guardar contraseñas ni contenido completo de búsquedas en los diagnósticos nuevos.

## Restricciones y límites

- Al no ser un panel KDE instalado, las islas pueden superponerse a controles o pestañas maximizadas. No está demostrada una solución universal para esa geometría.
- No usar la prueba conjunta como prueba completa de compatibilidad fullscreen, varios monitores o escalado.
- La prueba conjunta preserva los perfiles existentes del **ensayo** de Soledad y las preferencias aisladas de Malvina; no los mezcla con el visor Qt habitual ni con KConfig del panel.
- Soledad y Malvina siguen siendo procesos distintos **solo en este ensayo descartable**. Integrarlas en una arquitectura final compartida es un hito separado; no convertir esto en un sistema de dos procesos permanentes sin diseño y autorización.
- Si falla una isla, conservar `soledad.log` y `malvina.log` para reproducir el caso; no repetir decenas de pruebas que ya pasaron.

**Prueba de aceptación mínima pendiente:** arrancar el script, comprobar que ambas islas aparecen (Malvina por hover), seleccionar un buscador Web, expandir SO con tareas reales, verificar que el panel inferior de KDE sigue operativo y detener con Ctrl+C. Reportar únicamente anomalías.

## Apariencia compartida del visor y las dos islas

**Problema anterior:** en la sesión conjunta, los cambios de Color/Degradado/Figura de Malvina y la opción «Ícono y nombre» del cajón se podían editar en Configuración, pero pulsar **Aplicar** no los enviaba a los procesos LayerShell. Tampoco cargaban el `appearanceV1` real del visor `preview_redimensionable.qml`: ambos procesos iniciaban con sus valores de prueba. Los cambios visuales hechos *solo* en esa antigua sesión, sin persistencia, pueden no ser recuperables. La configuración original del visor permanece intacta.

**Solución experimental, pendiente de ensayo nativo:** el primer inicio de `probar_islas_juntas.sh` ejecuta el lector Qt existente `scripts/leer_apariencia_playa.qml` para leer el `appearanceV1` guardado **del visor Qt** y lo importa a `~/.local/state/plasma-smartbar/ensayos/appearance-runtime.json` (o `$XDG_STATE_HOME`, permisos privados); **no sobrescribe un archivo ya existente**. El log bruto de importación se elimina inmediatamente para evitar conservar allí la configuración detallada. Si no existe `qml6`, Node o una apariencia válida, muestra un aviso y no genera un falso perfil.

El nuevo `RuntimeAppearanceBridge.qml` se ejecuta dentro de cada proceso Soledad/Malvina: aplica únicamente las propiedades visuales permitidas del perfil mediante `RuntimeAppearance.js` y revalida cambios del otro proceso cada 1,75 segundos. Al pulsar **Aplicar**, compara los valores con la instantánea del propio editor y escribe **solo las propiedades modificadas**; el puente C++ guarda el JSON en archivo local con escritura atómica y bloqueo entre procesos. Las 94 propiedades de estilo incluidas abarcan modos «Ícono / Ícono + nombre / Texto» del cajón, ícono/nombre del launcher, colores y opacidad de ambas islas, degradados/respiración, figura de Malvina y sus controles, contornos, elementos decorativos SO, tipografía y algunos tamaños horizontales.

**No se modifican:** los Qt Settings originales del visor, temas y originales inmutables de Playa 24hs, fondos de escritorio reales, altura física fija de las ventanas de ensayo, perfiles por AppId, consentimiento de IA, navegación del escritorio, panel inferior, comportamiento contextual de clic izquierdo/derecho SO ni autoocultamiento de Malvina. El JSON del ensayo es una **copia operativa privada**, no un nuevo tema ni un perfil de fábrica: cambios futuros hechos en el visor original no reemplazan automáticamente ediciones guardadas desde las islas. Para consolidar ambos editores en una única fuente de preferencias, hará falta un hito posterior aprobado.

**Prueba breve (Fish):** finalizar la sesión vieja con `Ctrl+C`, actualizar la rama, correr `node prototype/v0.1/tests/test_apariencia_compartida.cjs` y arrancar `bash prototype/v0.1/probar_islas_juntas.sh`. Verificar sin repetir búsquedas ni ventanas: el aspecto guardado previamente (figura, degradado, transparencia) se ve al iniciar; cambiar **ícono y nombre** desde Configuración y aplicar; comprobar que cambia el cajón; cambiar un color/figura de Malvina y aplicar y comprobar que se ve en su isla. Si falla, copiar sólo las advertencias relevantes de `soledad.log` o `malvina.log`; **no compartir el archivo JSON completo** porque puede contener rutas personales y preferencias locales.

**Estado:** código publicado y test estructural/lógico comprobado en JS contra fuentes de GitHub. **Pendiente validación real en CachyOS/Wayland/Qt 6**.
