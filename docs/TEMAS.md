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
