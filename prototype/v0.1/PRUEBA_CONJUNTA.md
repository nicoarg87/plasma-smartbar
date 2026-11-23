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
