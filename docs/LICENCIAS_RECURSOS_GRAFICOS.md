# Licencias y procedencia de recursos gráficos — Plasma SmartBar Islands

**Decisión del mantenedor:** 16 de noviembre de 2026.  
**Proyecto oficial:** https://github.com/nicoarg87/plasma-smartbar

## Separación de derechos

- **Código fuente y documentación propia**: licencia **MIT**, archivo [LICENSE](../LICENSE). La licencia del código **no se aplica automáticamente** a las imágenes de terceros.
- **Recursos gráficos**: cada archivo debe tener origen, titular/autorización y licencia asentados en un inventario, y respetar posibles derechos de terceros. Publicar una imagen bajo CC0 **no convierte otros gráficos ni marcas en CC0**.
- **Imagen tropical/palmera con bar rústico y atardecer, generada con OpenAI**: el mantenedor autorizó publicarla **bajo CC0 1.0 Universal**, hasta donde tenga derechos para hacerlo. Texto y alcance: https://creativecommons.org/publicdomain/zero/1.0/ . La dedicatoria permite reproducción, modificación, impresión en remeras/tazas y venta por terceros, en la medida legalmente aplicable. **El archivo exacto está recuperado en un ZIP de prueba local, pero todavía no está incluido en GitHub**: no declarar falsamente que ya existe el recurso descargable o que se validó su hash. Al incorporarlo, incluir nombre/ruta y SHA-256, dimensiones, fecha y esta nota.
- **Logo/huella de Golden Dog**: origen y derechos de autor **sin verificar** (podría provenir de una persona/artista o de la distribución mencionada). **No se autoriza incluirlo como predeterminado ni como opción descargable dentro de la distribución** hasta contar con autorización/licencia verificable. Esto no impide que cada usuario elija por su cuenta un archivo local sobre el que tenga derechos.

## Registro de recursos

| Recurso | Procedencia | Licencia autorizada | Distribución en el proyecto |
|---|---|---|---|
| Imagen tropical con palmera, barra rústica y atardecer | Generación solicitada al servicio de OpenAI por el mantenedor; archivo definitivo recuperado en el chat, no subido a GitHub | **CC0 1.0**, para derechos que el mantenedor pueda dedicar | **Disponible en ZIP local**, SHA-256 registrado; pendiente de inclusión en GitHub y prueba Qt |
| Huella/logo vinculado a Golden Dog | Autoría/licencia no acreditadas | **Sin licencia de redistribución acreditada** | **No incluir**; retirar recurso del prototipo hasta aclararlo |
| Fotos/logos/GIF que el usuario cargue localmente | Aportados individualmente por cada usuario | **No heredan MIT ni CC0** | Solo referencias locales; no copiar ni redistribuir archivos |

## Antecedentes y precauciones

Según https://openai.com/policies/terms-of-use/ , entre el usuario y OpenAI y en la medida permitida por la ley, la propiedad del *output* corresponde al usuario; OpenAI cede los derechos que pueda tener. Esto **no garantiza exclusividad del resultado ni creación de derechos de autor por IA en todos los países**. La dedicatoria CC0 no permite ceder derechos que no se poseen ni elimina derechos de marcas, imagen, privacidad o contenidos de terceros.

**No es correcto afirmar que CC0 garantiza que cualquier uso, en cualquier país y sobre cualquier producto, es legal.** CC0 habilita la mayor libertad posible sobre los derechos de autor que podamos ofrecer. Las publicaciones anteriores conservan los permisos de sus licencias originales; MIT es la licencia vigente para código y documentación propios.

## Procedimiento para incorporar la imagen tropical

1. Recuperar el **archivo exacto** elegido en el chat de diseño; no reemplazarlo por una recreación parecida.
2. Verificar que no incluya contenido de terceros que impida la dedicación y que no haya exclusividades o marcas afectadas.
3. Guardarlo en `prototype/v0.1/package/contents/ui/assets/` con nombre inequívoco (por ejemplo, `so-tropical.png`), documentar SHA-256 y dimensiones.
4. Asociar explícitamente ese archivo a **CC0 1.0 Universal**, enlazando la licencia y procedencia; verificar su previsualización y el ajuste por defecto en Qt/CachyOS.
5. Mantener el antiguo logo de Golden Dog **excluido**, incluso si aparece en versiones históricas del repositorio.

**Estado:** política y decisión **confirmadas**; dedicatoria CC0 para la imagen tropical **autorizada**, pero recurso exacto **no incluido y no probado** en la aplicación a 16/11/2026. Este documento no constituye una certificación jurídica de derechos de terceros.


## Archivo original recibido y prueba local (16/11/2026)

El mantenedor volvió a suministrar la **imagen tropical exacta** en la conversación del proyecto: PNG RGBA de **1774 × 887** píxeles, SHA-256 `0c6e646886ba293db5b53d13f81a7421b4ceaee56d6bd92ed99745da273d4137`. Para probarla se entrega el archivo intacto `so-tropical.png` en un ZIP local, con destino `prototype/v0.1/package/contents/ui/assets/so-tropical.png`; su licencia prevista y autorizada por el mantenedor es **CC0 1.0 Universal**, en la medida legalmente aplicable.

**Distribución real:** la imagen se recuperó y existe en el paquete de prueba adjunto a la conversación; **aún no está incorporada al repositorio GitHub**. La rama experimental ya referencia esa ruta, pero requiere copiar el archivo o extraer el ZIP. No confundir «archivo recibido para prueba local» con «archivo publicado en GitHub». No incluir el recurso Golden Dog.


## GIF tropical definitivo de SO (16/11/2026)

**DECISIÓN DEL MANTENEDOR:** el archivo animado **`playa definitiva.gif`**, generado con ChatGPT y aportado directamente por el mantenedor, sustituye al PNG anterior como **logo gráfico predeterminado del botón SO** en Plasma SmartBar Islands. No es necesario recrear ni convertir el GIF para visualizarlo: se preserva su contenido original y su animación.

**Datos técnicos verificados a partir del archivo aportado:** formato GIF89a, **439 × 217 píxeles**, **16 cuadros**, **140 milisegundos por cuadro**, duración aproximada del bucle **2,24 segundos**, reproducción continua. **SHA-256:** `a10b34548abae1d3e699d5b92a23f38745b349f9cf73ebc59806fce6f56f5621`. Tamaño original **771.293 bytes**.

**Licencia gráfica:** el mantenedor indica que fue generado por ChatGPT y desea seguir **el mismo criterio CC0 1.0 Universal** usado para el arte tropical anterior, **únicamente sobre los derechos que efectivamente pueda dedicar**. Es una licencia de recurso gráfico **separada de MIT** (código/documentación) y no incluye marcas ni recursos de terceros. Referencia: https://creativecommons.org/publicdomain/zero/1.0/ . Registrar procedencia y conservar los archivos originales sin transformaciones destructivas.

**Destino del recurso en el prototipo:** `prototype/v0.1/package/contents/ui/assets/so-tropical.gif`, **GIF animado predeterminado** con forma de cápsula horizontal y modo Estirar. El fichero suministrado se encuentra en un **ZIP de prueba adjunto a esta conversación**. **La integración del binario en GitHub sigue pendiente**: se modificó el código QML para referenciarlo, pero el GIF no ha sido subido al árbol del repositorio desde esta sesión. Si no está en el checkout, mostrar la alternativa textual SO por error de carga.

**Prueba declarada por el mantenedor:** indica que el GIF ya fue ensayado y es funcional. **Pendiente por verificar en la rama actualizada:** carga, máscara de cápsula, estiramiento, loop y consumo de recursos al iniciarse como logo predeterminado sin seleccionar un GIF personalizado. No confundir esta revisión pendiente con la prueba previa del usuario.

## Ratificación vigente — 21/11/2026

**MIT** es la única licencia vigente para código, documentación y metadatos propios de Plasma SmartBar (ver `LICENSE`); **CC0 1.0 Universal** es la dedicación autorizada por el mantenedor, sobre los derechos que pueda conceder, para **todas las imágenes, GIF y wallpapers propios aportados al proyecto que declara creados mediante ChatGPT u otras herramientas de imagen por IA**, incluidos Día, Atardecer y Noche de **Playa 24hs**. Esta declaración de licencia NO significa que los binarios de los tres temas hayan sido incorporados a `main`: el prototipo sigue en rama experimental, PR #3 borrador.

**Separación imprescindible:** el arte de terceros, marcas/recursos de procedencia no acreditada (Golden Dog continúa excluido hasta aclarar), bibliotecas externas y archivos de usuarios distintos del mantenedor no reciben por esta declaración licencia MIT ni CC0. Identificar hashes, archivos originales y procedencia antes de empaquetar; conservar las licencias de publicaciones anteriores en sus respectivas copias y permisos sin alterar retrospectivamente su historial.

**Organización:** ninguna modificación de diseño, botones o menús se aprueba tácitamente por una propuesta de IA. La posición general de Soledad y los perfiles de ubicación por aplicación activa/maximizada están ratificados por el mantenedor ([issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4)), pero la integración KWin/Wayland y la memoria per-app siguen pendientes. Priorizar prueba KDE real aislada y extracción modular gradual ([issue #11](https://github.com/nicoarg87/plasma-smartbar/issues/11)) sin reemplazar el panel ni fusionar el prototipo automáticamente.
