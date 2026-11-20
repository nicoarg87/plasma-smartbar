# Temas visuales de Plasma SmartBar — especificación en preparación

**Fecha:** 18/11/2026. **Autoridad funcional:** mantenedor del repositorio oficial.

## Decisión y alcance

El mantenedor quiere un apartado claramente identificado **«Temas»** en las opciones del prototipo, con **dos motivos iniciales** para el botón SO y las islas:

1. **Atardecer / Playa tropical (actual):** conservar el GIF y la estética vigentes, sin modificarlos ni sustituir el último estado o la estética favorita local del usuario. El archivo de referencia actual se usa en el prototipo como `assets/so-tropical.gif`.
2. **Playa nocturna / Oscura (nueva propuesta visual aceptada como objetivo):** usar el **GIF exacto** de la playa oscura que está elaborando el mantenedor, con una paleta derivada de **esa imagen** para Soledad y Malvina y personalización posterior de ambas islas.

**Estado real del segundo recurso al abrir esta ficha:** el archivo GIF de la playa oscura **no está recibido en formato utilizable en esta sesión**. El adjunto más reciente disponible y verificado corresponde a una **captura de pantalla del launcher**, no a la obra nocturna. No inventar colores, no generar una playa sustitutiva, no agregar la captura como logo y no afirmar que el tema nocturno está implementado en QML.

## Comportamiento deseado del apartado «Temas»

- Tener una lista de temas disponibles con nombre y vista previa de sus imágenes de origen; la elección y aplicación de cada tema debe ser **explícita**.
- El tema nocturno ha de ser seleccionable **solo cuando el recurso real esté incorporado**; no mostrar una opción funcional sin imagen.
- Soledad sirve de base para el launcher y sus fondos; Malvina conserva sus preferencias independientes y deberá poder partir de los tonos propuestos por el mismo tema. No imponer sincronización permanente de colores a quien quiera modificar cada isla.
- Al aplicar un tema puede cargarse una **propuesta de colores y degradados** proveniente del arte correspondiente; el usuario debe poder seguir ajustando colores, opacidades, contornos, formas, respiración y otros parámetros. Si un parámetro es compartido, mostrarlo como compartido.
- No eliminar ni reemplazar por defecto las configuraciones persistidas (`appearanceV1`, `favoriteSoledadV1`, `personalDefaultV1`, KConfig). «Guardar estética favorita» y «Fijar actual como predeterminada» siguen separados de «Elegir tema».
- La selección de temas no debe alterar gestos de SO, atajos, posición o tamaño constante de la barra ni intervenir en el panel KDE instalado.
- Mantener el GIF intacto si se incorpora con licencia acreditada: registrar dimensiones, cuadros/duración cuando corresponda, SHA-256, procedencia y términos de reutilización en `docs/LICENCIAS_RECURSOS_GRAFICOS.md`.

## Implementación pendiente

1. **Recibir y verificar el GIF nocturno correcto** (no una captura de pantalla), analizar su licencia y guardar su hash.
2. Incorporarlo a `prototype/v0.1/package/contents/ui/assets/` sin reemplazar `so-tropical.gif`.
3. Proponer los tonos extraídos de ese GIF y confirmar con el mantenedor el tema de base, respetando la personalización de Soledad y Malvina.
4. Añadir en `SoledadSettings.qml` un apartado **Temas**, con los dos motivos y previsualización sin seleccionar automáticamente el oscuro. Usar un modelo de datos de tema para separar la definición del renderizado QML, evitando configuraciones duplicadas.
5. Conectar aplicación, guardado, preferencias y restauración del tema sin sobrescribir valores existentes ni desactivar la configuración manual.
6. Probar ambos temas en CachyOS con el visor aislado, incluyendo velocidad de GIF, rendimiento, color, gradiente, opacidad, accesibilidad y reversión.

**Estado:** idea de dos temas **confirmada**; recurso del segundo tema **pendiente de archivo correcto**; código de selector de temas **aún no implementado**, sin prueba real. No confundir el concepto/documentación con implementación.

## Implementación experimental de la pestaña Temas — 18/11/2026

**CONFIRMADO Y DESARROLLADO EN RAMA `prototype/v0.1-islas-so`:** nueva sección principal de configuración **Temas**. Presenta miniatura del logo SO actualmente elegido, acceso directo a «Personalizar logo SO», ranura de tema **Día**, ranura **Noche** y ranura **Personalizado**; cada una puede guardar el aspecto actual y aplicar un aspecto previamente guardado. **No se presupone** que el usuario haya creado ya la ranura Noche ni se instala automáticamente un GIF nocturno: el usuario puede elegir su GIF local y luego «Guardar actual» como Noche.

**Alcance exacto de las ranuras:** snapshot JSON V1 del logo (modo, ruta local, forma y recorte), colores/opacidad/degradado/respiración de Soledad y Malvina, colores luminosos SO y trazados de los elementos, y opacidades específicas de los paneles. NO guardan posición del panel, autoocultamiento, lista de ventanas, atajos, proveedores ni permisos IA. Al restaurar, únicamente esos campos visuales se aplican por la ruta de guardado existente del editor. Las preferencias de Soledad y Malvina pueden seguir editándose independientemente.

**Persistencia:** KConfig tiene las claves independientes `themeDayJson`, `themeNightJson` y `themeCustomJson`; el visor experimental las guarda inmediatamente en QtCore.Settings con claves equivalentes. Esas ranuras NO integran `appearanceV1` / `favoriteSoledadV1` / `personalDefaultV1`, para no desaparecer al restaurar un favorito o la predeterminada personal. No se sube a GitHub ni se copia el GIF local: un tema que referencia un archivo externo necesita que ese archivo permanezca disponible en el equipo.

**Creación automática:** botón «Crear automáticamente desde el logo SO» analiza una muestra local de 64×64 de un fotograma de la imagen elegida; propone/aplica **colores reales muestreados** a los fondos y degradados de ambas islas como valores editables, sin cambiar el contorno luminoso, y guarda el resultado en Personalizado. Para verlo en el visor debe pulsarse **Aplicar**; elegir Noche/Día no borra el Personalizado.

**Navegación reorganizada:** sidebar plegable en **Temas, Soledad, Malvina, General y compartidas**. El engranaje de SO abre la portada Temas; Malvina abre directamente sus proveedores Web/IA. Se ocultaron los selectores cruzados de páginas antiguas: cada isla tiene un editor de color/degradado y figura/tamaño propios, con tres accesos locales claros «Color y opacidad», «DEGRADADO», «Respiración y fondo». Los controles de paleta compartida, botones y contornos están en General. No se eliminó ninguna clave KConfig.

**ESTADO:** implementado en código, revisado estáticamente, **sin prueba de carga ni interacción QML en CachyOS** posterior a estos cambios. Pendiente validar guardado Día/Noche/Personalizado, miniatura de GIF, análisis nocturno, saltos a Logo, colores separados, presentación de los menús y rutas locales después de reiniciar. El recurso GIF de la playa nocturna que el usuario seleccionó en su equipo NO se incorporó como binario a esta rama; la ranura Noche puede apuntar al archivo que ya utiliza el usuario. Licencia de cada GIF sigue siendo independiente.


## Licencia confirmada del recurso Playa Noche — 19/11/2026

El mantenedor confirmó expresamente que el GIF de **Playa Noche** utilizado localmente fue generado con ChatGPT/OpenAI por encargo suyo y autorizó dedicar **esta imagen** bajo **Creative Commons CC0 1.0 Universal**, en la medida de sus derechos. Declaración registrada en [Licencias de recursos gráficos](LICENCIAS_RECURSOS_GRAFICOS.md#declaración-de-licencia--gif-playa-nocturna-19112026).

La imagen nocturna aún **no está incorporada como binario al repositorio GitHub**: la licencia está asentada para el archivo exacto, y faltan su incorporación, verificación SHA-256 y metadatos. No publicar capturas de pantalla ni generar sustitutos con esta etiqueta. CC0 del arte es independiente de MIT para el código actual. Los ajustes locales del usuario no cambian por este registro.


## GIF Playa Noche original verificado — 19/11/2026

**Cambio de estado respecto del bloqueo histórico:** ahora **sí se recibió el GIF nocturno original utilizable**. Archivo: `Playa tropical nocturna animada.gif`, **439×217**, 16 cuadros de 140 ms, **600.332 bytes**, SHA-256 `aec76461b1765a838cb9dfd8cbb84e9509a6113b6ffedd66b6d9c06bd57d8ba6`. El mantenedor confirmó su generación en ChatGPT/OpenAI y autorizó **CC0 1.0 Universal** para ese recurso, bajo los límites legales ya documentados en [Licencias gráficas](LICENCIAS_RECURSOS_GRAFICOS.md).

**Código experimental:** `SoledadSettings.qml` reconoce la ruta `assets/so-night.gif`. Si el archivo original está instalado y el usuario pulsa **Aplicar Noche**, reemplaza **solamente la ruta del logo y activa la reproducción GIF**; los valores del tema guardado (colores/degradados, formas, iluminación, respiración y opacidades) permanecen como estaban. Si falta el binario, el tema conserva su ruta anterior. La miniatura de Noche puede mostrar el GIF original disponible. El tema Día permanece sin alterar.

**Entrega del binario:** se preparó un ZIP para colocarlo en el checkout local sin tocar los paneles KDE ni sobreescribir archivos de imagen existentes. El binario exacto **aún no ha sido incorporado al árbol del repositorio GitHub**; solo están allí el código y sus metadatos de autoría/licencia. Pendientes: copiar el GIF a la ruta prevista y probar visualmente en CachyOS, comprobar persistencia, estado de Noche, permisos y ausencia de regresiones. Las paletas exactas del usuario siguen siendo ajustes locales y no se sustituyen por colores inventados.


## Atardecer, respaldo y separación de favorita — 19/11/2026

**Cambio funcional confirmado:** el tema antes visible como «Día» ahora se denomina **Atardecer**. La clave de persistencia **`themeDayJson` se conserva intencionalmente** para leer el estilo antiguo sin migraciones destructivas. `themeNightJson` y `themeCustomJson` continúan separados.

«Aplicar Atardecer» carga los colores, direcciones y demás campos guardados sin sustituirlos forzosamente por los de otra isla. «Actualizar Atardecer con estética actual…» exige confirmación explícita y conserva una copia recuperable en `themeDayPreviousJson`. «Recuperar Atardecer anterior…» intercambia la copia anterior y actual, de modo que la recuperación es reversible. La actualización no se ejecuta al seleccionar un tema, guardar favorita, cerrar el visor ni usar Aplicar. Atardecer y Noche conservan la respiración requerida por el mantenedor.

`favoriteSoledadV1`, `personalDefaultV1` y `appearanceV1` se mantienen independientes de las tres ranuras. Guardar favorita solo modifica la primera clave; al restaurar favorita, se copia al estado activo sin tocar temas y con guardado atómico (un solo guardado final del estado activo). Los nuevos snapshots de temas incorporan otros campos visuales (fondo, texto, controles, fichas); los JSON V1 antiguos no se borran ni reemplazan.

**Pendiente:** validar en Qt/CachyOS, especialmente que la favorita con el degradado recién ajustado pueda restaurarse y fijarse como Atardecer sin alterar Noche. «Día claro» con colores más luminosos sobre una playa similar queda como **propuesta futura**, sin imagen nueva, ranura funcional ni cambios de requisitos confirmados.


## Paleta manual a partir del GIF — nueva política aprobada el 19/11/2026

El usuario confirmó que el anterior sistema de sugerencias automáticas era confuso y debía reemplazarse. La nueva opción **«Abrir paleta del GIF y elegir colores…»** analiza un fotograma del logo SO y ofrece **hasta tres tonos cromáticos frecuentes** que realmente aparezcan en el fotograma. Cada tono se puede editar mediante selector visual o HEX, copiar al portapapeles y asignar explícitamente como color base/final del degradado de Soledad o Malvina. Si hay menos de tres tonos diferenciables, no se inventan colores.

Analizar no aplica ninguna modificación al fondo ni al contorno. El usuario puede sustituir manualmente cualquier tono por `#000000` u otro HEX; los colores activos se guardan mediante **Aplicar** por la ruta existente, con opción de degradado activa/inactiva y dirección independiente en cuatro orientaciones. La luz/contorno SO es un sistema de color separado. Los temas Atardecer/Noche y la favorita no cambian solo por analizar; se actualizan cuando el usuario ejecuta explícitamente su acción de guardado.

Implementación experimental: `PaletteExtractor.js` y `SoledadSettings.qml` en la rama `prototype/v0.1-islas-so`. **NO PROBADO aún con Qt/CachyOS**: ver [issue #15](https://github.com/nicoarg87/plasma-smartbar/issues/15).

## Regla definitiva: tres temas oficiales inmutables (19/11/2026)

**CONFIRMADO POR EL MANTENEDOR:** Día, Atardecer y Noche son los tres temas originales del sistema; sus manifestaciones deben ser **inmutables**. Se muestran en un **único desplegable**; seleccionar uno restaura el conjunto visual original. No habrá botones específicos para guardar o sobrescribir un preset oficial. Los usuarios pueden seguir personalizando la apariencia y guardando temas personales sin modificar ninguno de los tres originales.

- El antiguo identificador local `themeDayJson` corresponde a **Atardecer** (legado histórico); no reutilizarlo para Día.
- Día oficial se almacena en `assets/FactoryDayTheme.js`, Atardecer en `FactorySunsetTheme.js`, Noche en `FactoryNightTheme.js`. Sus imágenes originales permanecen separadas.
- Si se carga una configuración nueva desde la biblioteca personal, no modifica el preset de fábrica ni se trata como su versión oficial.
- **Día debe ser la selección inicial predeterminada únicamente después de que su preset exacto y su GIF de día estén disponibles y validados en el paquete**. No poner una imagen de Atardecer como sustituto.
- En la rama experimental se preparó un sellado de una sola operación de los tres perfiles. Requiere que el autor ya haya guardado Atardecer (`themeDayJson`), Noche (`themeNightJson`) y un tema personal de nombre exactamente «Día» (`themeLibraryJson`). Desde el mismo entorno de CachyOS donde funciona el visor, ejecutar `node prototype/v0.1/scripts/sellar_tres_temas_fabrica.cjs`. Lee la configuración Qt local, verifica que los tres JSON y recursos existan, y crea manifiestos inmutables con hashes **sin tocar las preferencias locales ni el panel KDE**.
- Los módulos de fábrica inicialmente contienen `preset = null`, de manera deliberada. El sellado solo puede activarlos con los valores y recursos **exactos**, nunca con un esquema cromático inventado. El resultado se revisa y prueba antes de publicarse mediante Git.
- **PENDIENTE:** ejecutar el sellado en el equipo del mantenedor, validar en QML carga, GIF, restauración completa y persistencia, revisar derechos de redistribución de cada archivo, publicar los binarios/manifiestos y recién entonces declarar los tres temas oficiales listos para una instalación limpia. Mantener la selección manual; la sincronización con hora/reloj permanece propuesta futura y optativa.

## Asociación de wallpapers fijos al seleccionar tema (19/11/2026)

**Confirmado:** el desplegable oficial de Día/Atardecer/Noche aplica el perfil correspondiente y cambia también la **imagen de fondo de escritorio de Plasma**, sin botones adicionales. Cada wallpaper se **estira** horizontal y verticalmente para cubrir el monitor completo sin recortes; en relaciones de aspecto distintas se admite deformación proporcional visual.

| Tema del selector | Imagen de fondo |
|---|---|
| Día | `prototype/v0.1/package/contents/ui/assets/wallpapers/day.png` |
| Atardecer | `prototype/v0.1/package/contents/ui/assets/wallpapers/sunset.png` |
| Noche | `prototype/v0.1/package/contents/ui/assets/wallpapers/night.png` |

Los tres PNG originales se entregaron en la conversación y se preservaron en un ZIP de recuperación; sus hashes están registrados en `assets/wallpapers/manifest.json`. **No están en GitHub como binarios aún**. La simulación solo puede cambiar wallpaper si el usuario extrae el ZIP en la raíz del repositorio.

**Implementación de prueba:** `QtCore.Settings` transmite únicamente la elección del tema; `vigilar_wallpaper.py` comprueba el SHA-256 del PNG antes de ejecutar `plasma-apply-wallpaperimage --fill-mode stretch`. El monitor está limitado a la duración de `probar_ancho.sh`, respalda la configuración del escritorio y no instala servicios ni modifica paneles. KDE Plasma tiene soporte nativo para `Image.Stretch`; la invocación CLI aún requiere validación en CachyOS.

**Pendiente:** publicar binarios con licencias individuales confirmadas, comprobar cambio efectivo y persistencia en Plasma/Wayland, validar múltiples pantallas y dejar el backend activo en la futura versión instalable. Automatizar por horario es una **propuesta separada**, no incluida aquí.

## Preferencia confirmada: aplicar wallpapers solo en el escritorio SIMULADO (19/11/2026)

Esta decisión **sustituye el alcance de las notas anteriores que hablaban de cambiar el fondo de KDE real**.

Al elegir Día, Atardecer o Noche desde el desplegable, el prototipo muestra la imagen PNG correspondiente **detrás de las islas, dentro de la ventana de prueba `preview_redimensionable.qml`**. El posicionamiento es `Image.Stretch`: cubre todo el ancho y alto de la ventana sin bandas ni recortes. El escritorio real de CachyOS y su wallpaper no se modifican.

En **Configuración → Temas** se incorpora una sola casilla **«Activar wallpaper temático»**, activada inicialmente, persistente por usuario y **separada de los presets inmutables**. Desactivarla oculta la foto únicamente en la simulación; no altera los colores, GIF del botón SO ni la selección de tema. Si se selecciona otro tema con la casilla desactivada, la última imagen se recordará y reaparecerá al volver a activarla.

La función anterior que llamaba a `plasma-apply-wallpaperimage` fue retirada completamente. La aplicación real del fondo KDE se considera **futura y no implementada**, sujeta a una decisión posterior y pruebas específicas. Los PNG originales siguen distribuidos por ZIP y no como binarios del repositorio GitHub.

## Horarios automáticos (19/11/2026)

**Requisito confirmado:** ofrecer en la misma sección **Temas** una opción de cambio automático horario con **3 o 4 franjas**, cuatro inicialmente. No reordenar el menú de temas ni crear botones de guardado.

**Horarios oficiales del perfil personal inicial de cuatro franjas:**

| Desde | Hasta | Tema |
|---|---|---|
| 06:00 | 08:00 | Atardecer |
| 08:00 | 18:00 | Día |
| 18:00 | 21:00 | Atardecer |
| 21:00 | 06:00 (día siguiente) | Noche |

La alternativa de 3 franjas comienza con Día de 08:00 a 18:00, Atardecer de 18:00 a 21:00 y Noche de 21:00 a 08:00. Cada franja tiene hora de inicio, hora de finalización y selector de tema, editables por el usuario; la hora final se mantiene enlazada al inicio de la franja siguiente, evitando huecos y solapamientos. Los perfiles de 3 y 4 franjas se almacenan por separado, y se conserva la preferencia **Activar cambio automático de tema**, inicialmente encendida.

El motor consulta el reloj **local** mientras está abierto el visor (cada 15 segundos); puede volver a comprobar la franja después de cambios de hora o suspensión. No crea servicios residentes, no cambia el fondo real de KDE y no sobreescribe los presets de Día/Atardecer/Noche. Si el perfil elegido no existe aún con sus archivos exactos, el motor no sustituye otro. Al cambiar la franja se restauran de una vez los valores visuales y el **wallpaper del escritorio simulado** asociado, siempre que `Activar wallpaper temático` permita mostrarlo.

**Estado:** implementado solo en el prototipo QML, con comprobaciones positivas del algoritmo y prueba `tests/test_theme_schedule.cjs`; falta retest gráfico y persistencia en CachyOS. La transición **suave** entre imágenes y colores se revisará posteriormente por decisión expresa del mantenedor; no forma parte de esta versión.

## Opacidad predeterminada común y resguardo de Día (19/11/2026)

**Decisión confirmada por el mantenedor:** todos los temas, incluidos Día, Atardecer y Noche, deben utilizar **90 % de opacidad** (10 % de transparencia) en Soledad, Malvina y paneles/botones que disponen de su propio valor de opacidad. La opción sigue siendo editable por el usuario, pero al aplicar un tema se establece esa opacidad común, incluso con instantáneas antiguas de otro porcentaje. No confundir opacidad de isla con grosor/opacidad de contorno, ni volver a dibujar una barra de ancho completo.

**Captura del Día activo:** antes de sustituir sus opacidades, debe conservarse la apariencia local exacta del mantenedor. El script `prototype/v0.1/guardar_dia_actual.sh`, invocado desde Fish mediante `bash`, solicita al visor una captura única de sus preferencias **ya persistidas al cerrar**; guarda una versión de Día personal al 90 %, conserva el Día anterior si existía y archiva por separado el estado anterior al 90 %, la biblioteca y el GIF original si está disponible. Ubicación del respaldo: `~/.local/share/plasma-smartbar/resguardos-dia/`. **No añade botones** ni escribe en el módulo oficial inmutable `FactoryDayTheme.js`.

**Alcance verificado:** cambios de código publicados en rama experimental; todavía debe ejecutarse el script y comprobarse el resultado en CachyOS. No afirmar que el Día activo se guardó realmente ni que se integró al paquete público sin recibir y validar el recurso y la instantánea.
