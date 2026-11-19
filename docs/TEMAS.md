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
