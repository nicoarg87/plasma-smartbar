# Licencias y procedencia de recursos gráficos — Plasma SmartBar

**Decisión del mantenedor:** 16 de noviembre de 2026.  
**Proyecto oficial:** https://github.com/nicoarg87/plasma-smartbar

## Separación de derechos

- **Código fuente y documentación propia**: licencia **MIT**, archivo [LICENSE](../LICENSE). La licencia del código **no se aplica automáticamente** a las imágenes de terceros.
- **Recursos gráficos**: cada archivo debe tener origen, titular/autorización y licencia asentados en un inventario, y respetar posibles derechos de terceros. Publicar una imagen bajo CC0 **no convierte otros gráficos ni marcas en CC0**.
- **Imagen tropical/palmera con bar rústico y atardecer, generada con OpenAI**: el mantenedor autorizó publicarla **bajo CC0 1.0 Universal**, hasta donde tenga derechos para hacerlo. Texto y alcance: https://creativecommons.org/publicdomain/zero/1.0/ . La dedicatoria permite reproducción, modificación, impresión en remeras/tazas y venta por terceros, en la medida legalmente aplicable. **El archivo original exacto todavía no está recuperado ni incluido en este repositorio**: no declarar falsamente que ya existe el recurso descargable o que se validó su hash. Al incorporarlo, incluir nombre/ruta y SHA-256, dimensiones, fecha y esta nota.
- **Logo/huella de Golden Dog**: origen y derechos de autor **sin verificar** (podría provenir de una persona/artista o de la distribución mencionada). **No se autoriza incluirlo como predeterminado ni como opción descargable dentro de la distribución** hasta contar con autorización/licencia verificable. Esto no impide que cada usuario elija por su cuenta un archivo local sobre el que tenga derechos.

## Registro de recursos

| Recurso | Procedencia | Licencia autorizada | Distribución en el proyecto |
|---|---|---|---|
| Imagen tropical con palmera, barra rústica y atardecer | Generación solicitada al servicio de OpenAI por el mantenedor; archivo definitivo aún no recuperado | **CC0 1.0**, para derechos que el mantenedor pueda dedicar | **Pendiente** de archivo exacto, SHA-256 y revisión visual |
| Huella/logo vinculado a Golden Dog | Autoría/licencia no acreditadas | **Sin licencia de redistribución acreditada** | **No incluir**; retirar recurso del prototipo hasta aclararlo |
| Fotos/logos/GIF que el usuario cargue localmente | Aportados individualmente por cada usuario | **No heredan MIT ni CC0** | Solo referencias locales; no copiar ni redistribuir archivos |

## Antecedentes y precauciones

Según https://openai.com/policies/terms-of-use/ , entre el usuario y OpenAI y en la medida permitida por la ley, la propiedad del *output* corresponde al usuario; OpenAI cede los derechos que pueda tener. Esto **no garantiza exclusividad del resultado ni creación de derechos de autor por IA en todos los países**. La dedicatoria CC0 no permite ceder derechos que no se poseen ni elimina derechos de marcas, imagen, privacidad o contenidos de terceros.

**No es correcto afirmar que CC0 garantiza que cualquier uso, en cualquier país y sobre cualquier producto, es legal.** CC0 habilita la mayor libertad posible sobre los derechos de autor que podamos ofrecer. Versiones del programa publicadas anteriormente bajo GPL-3.0 conservan sus licencias históricas y permisos; el cambio a MIT no revoca esos permisos.

## Procedimiento para incorporar la imagen tropical

1. Recuperar el **archivo exacto** elegido en el chat de diseño; no reemplazarlo por una recreación parecida.
2. Verificar que no incluya contenido de terceros que impida la dedicación y que no haya exclusividades o marcas afectadas.
3. Guardarlo en `prototype/v0.1/package/contents/ui/assets/` con nombre inequívoco (por ejemplo, `so-tropical.png`), documentar SHA-256 y dimensiones.
4. Asociar explícitamente ese archivo a **CC0 1.0 Universal**, enlazando la licencia y procedencia; verificar su previsualización y el ajuste por defecto en Qt/CachyOS.
5. Mantener el antiguo logo de Golden Dog **excluido**, incluso si aparece en versiones históricas del repositorio.

**Estado:** política y decisión **confirmadas**; dedicatoria CC0 para la imagen tropical **autorizada**, pero recurso exacto **no incluido y no probado** en la aplicación a 16/11/2026. Este documento no constituye una certificación jurídica de derechos de terceros.
