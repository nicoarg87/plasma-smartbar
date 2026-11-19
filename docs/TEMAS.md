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
