# Cómo colaborar con Plasma SmartBar

Gracias por querer colaborar. El proyecto está en **fase conceptual**: aún no hay un complemento funcional listo para instalar.

## Antes de proponer cambios
Leé la [Constitución técnica](docs/CONSTITUCION_TECNICA.md), el [Manual Maestro](docs/MANUAL_MAESTRO.md) y las reglas de [gobernanza](GOVERNANCE.md).

La dirección funcional y de diseño del proyecto oficial corresponde al mantenedor. La comunidad es bienvenida para mejorar rendimiento, corregir bugs, investigar compatibilidad de Plasma/KWin y aportar pruebas. **Las propuestas no se fusionan automáticamente.**

## Reportar errores
Indicá versión de Plasma/KWin, distribución, Wayland/X11, pasos para reproducir, resultado esperado/observado y evidencias libres de datos personales. Antes de abrir un issue, comprobá si ya existe uno similar.

## Proponer funcionalidades
Describí qué problema resuelve la función y a qué sección del manual corresponde. Si modifica alguna regla confirmada, pedí discusión y aprobación **antes** de programarla. Evitá modificar el diseño fundamental por iniciativa propia.

## Enviar un pull request
- Trabajá en tu fork y rama; PRs pequeños y documentados son más fáciles de revisar.
- Incorporá pruebas cuando exista código ejecutable.
- No aumentes la altura de la barra durante cambios de estado; no desplaces pestañas ni alteres la prioridad fullscreen.
- Evitá dependencias innecesariamente pesadas y regresiones de rendimiento.
- Si reutilizás componentes ajenos, verificá compatibilidad con la licencia GPL-3.0 del repositorio y conservá los avisos aplicables.
- No incluyas secretos, credenciales, información privada ni recursos gráficos sin permiso.
- La aceptación requiere revisión técnica y aprobación del mantenedor.

## Primeras contribuciones útiles
Investigación documentada de APIs de Qt 6/QML, Plasma y KWin; inventario de controles existentes reutilizables; matriz de pruebas en CachyOS/Fedora KDE/Debian KDE; pruebas de maximización, fullscreen y manejo de foco.

## Nota sobre forks
Podés crear y mantener una variante independiente conforme a la GPL-3.0. Tu variante no debe presentarse engañosamente como una publicación oficial del mantenedor.
