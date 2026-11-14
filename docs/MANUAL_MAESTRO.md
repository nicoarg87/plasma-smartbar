# Manual maestro de diseño y funcionamiento
## Proyecto: barra superior inteligente para un entorno de escritorio

**Versión:** 0.9 — Diseño por islas y efecto de minimización opcional  
**Fecha de actualización:** 14 de noviembre de 2026  
**Plataforma de referencia:** Linux con KDE Plasma 6, KWin y Wayland; CachyOS es la plataforma inicial de desarrollo y pruebas  
**Estado:** Especificación conceptual; todavía no existe un prototipo funcional. Repositorio oficial público: https://github.com/nicoarg87/plasma-smartbar (rama main, licencia GPL-3.0).  
**Propósito adicional:** Este documento debe poder entregarse a otra conversación o a un desarrollador para continuar sin empezar de cero.

> **Para otro chat o desarrollador:** Este manual es la referencia de verdad. Respetar las decisiones CONFIRMADAS y separar los detalles POR DEFINIR, los complementos FUTUROS y las SUGERENCIAS TÉCNICAS. No inventar diseños ni crear renders sin que el autor lo pida. La última infografía sobrecargada y las láminas contradictorias se descartaron. El objetivo inicial no incluye reproductor multimedia ni efectos sofisticados. La meta de distribución es **Linux con KDE Plasma**, independiente de la distribución; GNOME, Cinnamon, Windows y macOS quedan fuera de alcance.

---

## 1. De dónde surgió la idea

El autor utiliza **CachyOS con KDE Plasma** y planteó trasladar la gestión del escritorio a una **barra superior**. Su primer ejemplo fue una captura de un navegador maximizado, con anotaciones que señalaban la zona superior y un posible botón «SO» (sistema operativo). En sucesivas conversaciones se precisó que la intención no era agrandar una ventana ni crear un dock: era **fusionar visualmente los controles de las ventanas maximizadas con una barra superior inmutable**, además de administrar aplicaciones abiertas y bandeja desde dos controles compactos.

La idea evolucionó por correcciones sucesivas: primero el desplazamiento del botón SO al maximizar; después la bandeja contraíble, los menús horizontales, las herramientas secundarias y el reproductor; finalmente, la prioridad de las aplicaciones, el modo pantalla completa y la personalización modular. En los bocetos se cometieron errores que el autor corrigió: menús de aplicaciones verticales, barras engrosadas, pestañas de navegador bajadas, fichas de aplicaciones permanentemente visibles, flechas en sentido contrario y reproductor visible con bandeja cerrada. Esas versiones **no son especificaciones válidas**.

### Meta de experiencia

«Mostrar solo lo necesario; revelar lo demás cuando se necesita; nunca sacrificar el espacio ni el comportamiento de las aplicaciones para acomodar decoración del escritorio».

---

## 2. Términos y alcance

- **Barra principal:** sistema superior lógico de grosor constante, representado por **islas visualmente independientes de forma predeterminada**, sin fondo continuo obligatorio. Su altura se puede configurar globalmente, pero **no cambia automáticamente mientras el sistema opera**.
- **SO:** botón del extremo derecho que despliega **solo aplicaciones y ventanas abiertas**, incluidas las minimizadas. **Por defecto presenta una ficha por aplicación, agrupando sus ventanas**; puede configurarse para mostrar una ficha por ventana. No abre el catálogo de programas instalados. Su visibilidad puede configurarse: contraído, expandido o adaptativo, con contracción automática al abrir aplicaciones con pestañas cuando la opción esté activada.
- **Lanzador izquierdo:** acceso siempre visible por defecto a **programas instalados**, mediante búsqueda y catálogo por categorías. Puede ocultarse o cambiar de icono mediante clic derecho.
- **Bandeja del sistema:** grupo horizontal normalmente contraído que contiene sonido, red, Bluetooth, notificaciones y controles accesorios. Si se habilita multimedia en una versión futura, pertenece aquí.
- **Flecha horizontal:** `◀` para **abrir la bandeja a la izquierda**, `▶` para **contraerla a la derecha**.
- **Flecha vertical:** `↓` abre herramientas secundarias bajo la barra; `↑` las cierra. Es el símbolo por defecto pero puede personalizarse.
- **Subpanel/panel secundario:** **ventanita flotante bajo la barra**, como un calendario o panel de notas. No es otra fila de la barra ni un reemplazo de la pantalla de la aplicación.
- **Centro de control secundario:** subpanel con microiconos de herramientas: notas, calendario, adhesivas, clima, etc.
- **Centro general de configuración:** preferencias del propio proyecto; distinto del centro de control secundario.
- **Reproductor multimedia:** posible módulo FUTURO dentro de la bandeja, con interfaz compacta y subpanel al tocar carátula. El protocolo MPRIS **no es prioridad para la primera versión**.
- **Maximizada:** ventana grande integrada visualmente con el panel superior. Conserva la barra visible y los tres controles de ventana arriba.
- **Pantalla completa real (fullscreen):** videojuego o video a pantalla completa; la barra y sus controles **no deben mostrarse sobre ese contenido**.
- **Escritorios virtuales:** espacios de trabajo lógicos; **no** son lo mismo que **monitores físicos**.

**Estados de una funcionalidad:** CONFIRMADO (regla acordada); OPCIONAL/CONFIGURABLE (el usuario elige); FUTURO (fuera del núcleo inicial); PENDIENTE DE PROBAR (resultado deseado cuyo mecanismo todavía debe validarse).

## 3. Invariantes estructurales — CONFIRMADO

1. **La altura visible de la barra es siempre inmutable durante el uso.** Puede existir una opción de tamaño en la configuración, como en los paneles de KDE, pero maximizar, abrir SO, cerrar la bandeja o mostrar fichas **no reajusta esa altura**.
2. **Todas las expansiones horizontales conservan exactamente el grosor del panel**; no hay doble fila, aumento de altura ni reducción de los botones.
3. Los controles `−`, `□`, `×`, el botón SO y la flecha de bandeja tienen regiones táctiles/clicables independientes, con tamaño y alineación vertical estables.
4. **Ni las pestañas del navegador ni el resto de la ventana se desplazan o redimensionan** al expandir SO o la bandeja. Si ocupan esa zona, el menú desplegado **las cubre temporalmente**.
5. La barra, el lanzador izquierdo, el botón SO, la flecha y los controles de ventana (cuando corresponden) tienen **prioridad de capa sobre una ventana maximizada y sus pestañas**; una pestaña no puede tapar al lanzador o bloquear el menú. Esto incluye **los botones permanentes** con menús contraídos.
6. **SO y bandeja son mutuamente excluyentes:** abrir uno contrae el otro. Sus expansiones nunca compiten simultáneamente por el espacio.
7. Los **subpaneles** (calendario, notas y, más adelante, reproductor) sí se despliegan hacia **abajo**, flotando sobre la aplicación y **sin alterar el panel**.
8. El **modo fullscreen real** tiene prioridad sobre los controles del escritorio. Se ocultan en videojuegos y videos a pantalla completa; maximizada no es fullscreen.
9. Ningún efecto decorativo, animación, variación de tema o módulo adicional puede modificar la prioridad de capas, secuencia de focos ni geometría acordada.
10. **La prioridad es abrir y seleccionar aplicaciones** antes que disponer de controles accesorios. El producto debe seguir siendo funcional con todos los efectos desactivados.

**Punto que se validará con prototipos:** la idea de que pestañas y panel ocupen una misma franja es clara visualmente, pero los navegadores poseen interfaces distintas. La superposición es posible como objetivo, aunque la convivencia de controles permanentes encima de una pestaña puede **ocultar su zona clicable** salvo que se reserve espacio o se integre por aplicación. No prometer compatibilidad universal ni proponer bajar las pestañas para resolverlo.

## 4. Componentes estables y distribución

### Lanzador de aplicaciones instaladas — extremo izquierdo

- **Visible por defecto**, situado arriba a la izquierda y siempre por encima de pestañas de una ventana maximizada.
- Ocultable desde clic derecho/configuración; el autor prefiere conservarlo por comodidad de acceso.
- Icono inicial posible: KDE o una **lupa**. Icono, tamaño dentro de la altura del panel y apariencia personalizables.
- Al pulsarlo, apertura de búsqueda rápida; posibilidad de desplegar un catálogo compacto de todas las aplicaciones instaladas y categorías (Sistema, Internet, Oficina, Multimedia, Juegos, Accesorios, etc.).
- Su menú de búsqueda/catálogo **puede aparecer debajo de la barra** porque no es una expansión horizontal de fichas SO. No obliga a redimensionar el navegador.
- Clic derecho sobre el lanzador, SO o flecha de bandeja puede mostrar opciones comunes: editar ícono, visibilidad, color/tema, efectos, orden, configuración general. Debe respetar la función propia de cada control.

### Islas visuales superiores — CONFIRMADO (14/11/2026)

La organización por islas distingue **componentes funcionales y superficies visuales separadas**. No obliga a mostrar una franja de fondo conectándolas. La geometría superior permanece alineada y de altura constante.

- **Isla 1 (extremo derecho):** botón de identidad del sistema **SO**, con **logo configurable** (por ejemplo, la distribución que usa el usuario), y control horizontal de **bandeja expandible**. SO continúa mostrando exclusivamente las aplicaciones/ventanas **abiertas**. Si una ventana está maximizada, los botones `− □ ×` aparecen junto a SO **en esta zona derecha**, según el diseño previamente aprobado.
- **Isla 2 (extremo izquierdo):** **lanzador de aplicaciones instaladas**, mediante logo o icono personalizable. La búsqueda sigue disponible al activar este lanzador, sin necesitar un campo visible permanentemente.
- **Isla 3 (junto a la isla 2):** campo o acceso visual persistente a **«Buscar aplicaciones…»**, **opcional, oculto/no añadido por defecto**. El usuario puede habilitarlo desde la configuración. No sustituye la función de búsqueda de la isla 2.
- **Fondo entre islas:** **transparente o ausente por defecto**. Es configurable una alternativa visual en la que el fondo parezca **continuo o entrelazado**, sin unir obligatoriamente las áreas funcionales ni alterar la altura.
- **Al maximizar:** las islas ocupan la misma franja superior que la interfaz maximizada y conservan prioridad de capa. Las pestañas del navegador **no deben desplazarse ni redimensionarse**; la convivencia de superposición y sus áreas clicables sigue **PENDIENTE DE VALIDACIÓN** en KWin/Wayland.
- **Al expandir SO o bandeja:** las fichas siguen expandiéndose solo **horizontalmente hacia la izquierda en una fila**, sin crear una fila nueva, cambiar el grosor ni abrir ambas a la vez.

Los ejemplos gráficos sirven para comunicar la distribución, pero **no certifican el comportamiento en KWin** ni autorizan introducir controles que no hayan sido aprobados.

### Grupo derecho de controles

- **Flecha de bandeja** horizontal.
- **Botón SO** (aplicaciones actualmente abiertas).
- **Minimizar, restaurar/maximizar y cerrar** de la ventana activa **cuando esté maximizada**.
- Las apps abiertas no se listan persistentemente; sus fichas **solo existen cuando se abre SO**.
- La bandeja contraída no muestra accesorios; en una fase futura, multimedia estará dentro de ella.

### Orden de prioridad al dibujar

1. Sin fullscreen: lanzador izquierdo y controles permanentes superiores están disponibles por encima de la interfaz de la ventana maximizada.
2. SO y bandeja pueden cubrir temporalmente las pestañas del navegador durante su expansión.
3. Fullscreen real: el video/juego deja oculta la barra.

Los diagramas ASCII representan el **orden funcional**, no anchuras exactas ni un render terminado.

## 5. Estados de uso confirmados

### A. Sin ventana maximizada

Extremo derecho en **modo compacto inicial**: `[ ◀ ] [ SO ]`

- Según configuración, SO también podrá iniciar expandido o utilizar visibilidad adaptativa sin alterar la altura.
- Flecha cerrada a la izquierda, botón SO a su derecha.
- Nada de fichas de Dolphin/Konsole/Brave de forma permanente.
- Las ventanas normales conservan sus propios botones tradicionales.

### B. Ventana maximizada

Extremo derecho: `[ ◀ ] [ SO ] [ − ] [ □ ] [ × ]`

- Aparecen los controles de ventana a la derecha.
- SO y bandeja se desplazan horizontalmente a la izquierda; **en la primera versión esto será inmediato, sin animación**.
- Se mantiene la altura fija; no se baja ni reestructura la fila superior de un navegador.
- Al restaurar vuelve a A, sin efectos obligatorios.

### C. SO expandido: selector de aplicaciones abiertas

Ejemplo **del modo predeterminado agrupado**: `[ ◀ ] [ Dolphin (3) ] [ Konsole ] [ Brave ] [ SO ] [ − ] [ □ ] [ × ]`

- Se abre horizontalmente hacia la **izquierda**, dentro del **mismo grosor** de la barra, mediante fichas compactas con icono y nombre.
- Solo programas/ventanas abiertos, incluyendo los minimizados, no el catálogo de apps instaladas.
- **CONFIRMADO: agrupación por aplicación activada por defecto.** Si existen tres ventanas de Dolphin, SO muestra **una única ficha Dolphin**, no tres fichas consecutivas. El indicador `(3)` es ilustrativo; la forma gráfica exacta de señalar la cantidad puede personalizarse.
- **Al pulsar una ficha agrupada con varias ventanas**, se presenta un selector de esas ventanas para elegir cuál activar. Este selector secundario debe identificar cada ventana mediante nombre y, cuando esté disponible, miniatura. Su ubicación y forma exactas todavía deben diseñarse; no confundirlo con convertir el selector SO principal en menú vertical de cascada.
- **OPCIONAL/CONFIGURABLE: modo desagrupado.** El usuario puede elegir en las preferencias que SO muestre cada ventana en una ficha independiente, incluso tres fichas Dolphin una al lado de la otra. La elección es global por defecto, con posibles reglas por aplicación solo como mejora futura.
- La agrupación **reduce** la necesidad de desplazamiento horizontal, pero no elimina la navegación de una sola fila cuando hay muchas aplicaciones.
- La flecha de bandeja permanece en el extremo izquierdo del grupo; no desaparece.
- La expansión puede **tapar** pestañas del navegador; no desplazar, achicar ni reordenar ese navegador.
- Las fichas pueden mostrar una **miniatura real de la ventana al pasar el puntero**: ejemplo, Dolphin mostrando sus archivos. En modo agrupado, la vista previa puede indicar que existen varias ventanas y facilitar su distinción; **el clic** sobre una ficha agrupada con varias ventanas abre el selector entre ellas. Reutilizar las previsualizaciones de KDE/KWin si las APIs lo permiten.
- **Muchas ventanas:** desplazar horizontalmente con rueda de mouse, gesto equivalente de touchpad y/o flechas pequeñas de navegación. Una sola fila; sin agrandar la barra.
- Si el usuario selecciona una ficha, la ventana correspondiente debe activarse. **CONFIRMADO:** por defecto, al seleccionar una aplicación o una ventana concreta, SO se contrae automáticamente después de activarla. **OPCIONAL:** el usuario puede desactivar el cierre automático y mantener SO abierto para alternar entre aplicaciones con menos clics.
- Cierre manual volviendo a pulsar SO; autocierre por salida de puntero, por ejemplo tras cinco segundos, **opcional** y configurable.
- **Escritorios virtuales:** el autor propone una integración opcional del selector de escritorios **al extremo izquierdo del desplegable SO**. Cada escritorio podría mostrar ícono y, al posar el puntero, una miniatura del escritorio. Clic para cambiar de escritorio. También puede ofrecerse como widget discreto independiente según configuración.

### C.1. Visibilidad adaptativa del selector SO — CONFIRMADO COMO OPCIÓN

La barra no debe obligar al usuario a abrir SO de nuevo cada vez que cambia de aplicación. Se incorporarán **tres modos de presentación** como opción en el centro general de configuración y en el menú contextual de SO:

- **Contraído:** SO inicia/permanece cerrado salvo que el usuario lo pulse. Es el esquema minimalista original.
- **Expandido:** SO puede permanecer desplegado para alternar repetidamente entre programas, conservando las fichas horizontales en una sola fila de altura invariable.
- **Automático/adaptativo:** SO puede mostrarse desplegado mientras convenga y **contraerse automáticamente al abrir o activar una aplicación con interfaz superior ocupada**, como Brave, Chrome o Firefox con pestañas, cuando el usuario habilite dicha regla. Los disparadores exactos (por nombre de app, por tipo de ventana o detección de pestañas) deben investigarse; no asegurar detección universal de pestañas.

**Selección de aplicaciones:** al elegir una ficha individual o una ventana concreta dentro de una ficha agrupada, la ventana se activa y **SO se contrae por defecto**. El usuario puede cambiar a **«mantener abierto después de seleccionar»**. La contracción automática y el modo permanentemente expandido deben coordinarse con esta preferencia para evitar estados contradictorios; se definirán reglas explícitas de precedencia en el prototipo.

**Acceso a configuración:** menú contextual mediante clic derecho sobre SO y acceso al mismo centro general desde la flecha de bandeja o el lanzador. No sobrecargar la barra con controles de ajustes permanentes.

**Invariantes:** si SO queda expandido mientras una ventana con pestañas se activa, sus fichas pueden tapar pestañas, pero **no** desplazar ni reducir la ventana. Video/juego en fullscreen real siempre oculta la barra.

### D. Bandeja expandida

- `◀` abre a la izquierda y se convierte en `▶` para cerrarla.
- Aparecen controles habituales de sistema, sin modificar altura de franja.
- El botón de herramientas secundarias `↓` solo aparece **dentro de esta bandeja expandida**; `↑` cuando su panel inferior esté abierto.
- Si SO estaba abierto, primero se contrae SO.
- Contraer bandeja oculta sus iconos, subpaneles dependientes y cualquier futuro reproductor compacto.

### E. Centro secundario y herramientas bajo la barra — ampliación posterior al núcleo

- Pulsar `↓` en la bandeja abierta presenta una **ventanita flotante debajo de la barra**, inicialmente con microíconos seleccionables de calendario, notas y otras herramientas.
- Pulsar `↑` la cierra sin cambiar el panel superior.
- La misma lógica visual puede abrir un calendario mensual, notas adhesivas, tiempo, impresoras, pantallas y discos. Los módulos deben ser configurables.
- Por ahora se define comportamiento y familia visual, no se exige implementar todos en la primera versión.

### F. Reproductor compacto y ampliado — FUTURO, NO MVP

- Más adelante se podrá habilitar un mini reproductor **dentro de la bandeja expandida**. No permanece cuando la bandeja se contrae.
- Clic sobre carátula abre **subpanel** debajo de la barra, con proporción coherente con calendario/notas; puede mostrar título, artista, progreso, reproducción, volumen y abrir app de origen.
- Utilizar MPRIS si corresponde, pero **su integración no condiciona la primera entrega**.

### G. Pantalla completa real

- Video o juego fullscreen oculta barra, lanzador, SO y bandeja, y los paneles flotantes no deben interferir.
- Al volver del fullscreen reaparece el panel según las ventanas visibles.
- En varios monitores, la política se probará por pantalla/ventana fullscreen.

## 6. Capas visuales y aplicaciones con pestañas

**Comportamiento pedido:** el navegador permanece tal como estaba. No se mueven las pestañas ni su tamaño, y las expansiones superiores **se dibujan por encima** cuando se necesite espacio. Al cerrarse el menú, se vuelven a ver las pestañas originales en su sitio.

**Controles siempre visibles:** cuando NO hay fullscreen, el lanzador en la esquina superior izquierda y los controles esenciales a la derecha deben permanecer visibles **por encima de las pestañas**, incluso con SO/bandeja contraídos. El usuario puede ocultar voluntariamente el lanzador desde clic derecho; nunca debería desaparecer solo porque un navegador exhiba pestañas.

**Matiz técnico honesto:** superponer un botón significa también que la pestaña situada *exactamente debajo de ese botón* no se puede clicar mientras esté tapada. El usuario acepta expresamente ese comportamiento temporal con menús expandidos; lo que hay que probar es la convivencia en estado contraído, donde una interfaz adaptada podría reservar solo las áreas de botones. La integración con Brave, Firefox y otras apps de decoración propia depende de sus diseños y de capacidades de Plasma/KWin.

**Full screen real:** no se dibuja la barra sobre juegos ni videos fullscreen. Es un caso distinto de ventanas maximizadas.

**Error prohibido:** añadir una barra separada que reduzca la altura del navegador o baje las pestañas para hacer lugar a SO o bandeja.

## 7. Personalización y animaciones — FUTURO POR ETAPAS

### Clic derecho, tema y búsqueda

- Lanzador, SO, flecha y herramientas deberán permitir menú contextual con opciones pertinentes, incluida entrada común a «Configurar esta barra».
- Apariencia por separado: panel principal, expansión SO, bandeja, fichas y subpaneles. Colores sólidos o transparentes, opacidad, blur, separaciones y bordes, sin modificar geometría vertical.
- Iconos reemplazables: logo SO, lupa/lanzador, flechas y símbolo del centro secundario. El control predeterminado de herramientas es `↓`/`↑`; se puede reemplazar por cuatro cuadros u otro ícono.
- Altura de barra configurable como **preferencia global del usuario**, con equivalentes de píxeles lógicos y escala de pantalla, de modo similar a Plasma. **Una vez elegida, es fija en todos los estados**.

### Primera versión SIN efectos

La primera entrega debe funcionar con movimientos **inmediatos**, sin blur, estelas ni desplazamientos animados. Eso facilita detectar fallas reales de tamaños, foco y ventanas. La automatización de visibilidad de SO puede añadirse detrás de una opción, sin cambiar la regla de altura constante.

### Después

Se podrán habilitar/deshabilitar deslizamientos, fundidos, blur, transparencias y estelas, reutilizando mecanismos de Qt Quick/KWin donde sea posible.

**Efecto opcional confirmado para una fase posterior: «gaveta de SO» (inspiración Magic Lamp de KWin).** Al minimizar una ventana normal o maximizada, esta se reduce visualmente hacia SO; **SO abre brevemente hacia la izquierda una ranura/ficha de altura igual a la barra**, se muestra el **icono/nombre de la aplicación minimizada** y la ranura se cierra sola. El estado real de la ventana pasa a minimizada y sigue localizable en SO; el efecto es **puramente visual**, nunca bloquea la minimización. La intención es un movimiento **rápido, alrededor de medio segundo como referencia inicial**, no un tiempo definitivo: se ajustará según pruebas de fluidez y accesibilidad. Solo funciona si los efectos están habilitados y el usuario lo permite; sin efectos la minimización ocurre normalmente. **No se incluye en el MVP, no existe implementación ni está validada la integración KWin/Wayland.**

El caso de **Nyan Cat** fue únicamente una ilustración del potencial de animaciones personalizadas. No se añade por defecto ni es un requisito para el núcleo; los paquetes futuros deben mantener áreas clicables, direcciones de flechas, rendimiento, seguridad y geometría inmutable.

**Prioridad:** primero funcionamiento, después pulido visual. Los temas no deben convertirse en un segundo motor de escritorio ni comprometer la accesibilidad.

## 8. Escritorios virtuales y monitores físicos — ACTUALIZADO

Se distinguen dos cosas diferentes:

1. **Escritorios virtuales:** espacios de trabajo de Plasma dentro de un monitor o sesión.
2. **Monitores físicos:** pantallas conectadas, con ventanas distribuidas entre ellas.

### Escritorios virtuales: nuevas preferencias expresadas

El usuario reconsideró la decisión anterior de ocultar siempre el indicador: **quiere un acceso práctico, sin convertirlo en una gran barra permanente**.

Modalidades a ofrecer/configurar:
- **Dentro de SO:** cuando se despliega la lista de aplicaciones, en su extremo izquierdo aparecen pequeños indicadores de escritorios. Hover = miniatura de vista previa; clic = cambiar de escritorio.
- **Ícono discreto independiente:** un botón pequeño en la barra que expande un selector de escritorios (sin aumentar el alto de la barra).
- **Visible siempre / oculto:** opción de preferencia del usuario.

**Pendiente de elegir como predeterminado:** integración dentro de SO o pequeño indicador autónomo. No afirmar que esté decidido. En todos los casos se reutilizarán mecanismos existentes de Plasma/KWin si es técnicamente viable.

### Monitores físicos

Indicadores permanentes **no son obligatorios** ni deben llenar la barra. Se contempla activarlos en configuración, con acceso discreto a las pantallas y ventanas correspondientes. Debe probarse si la barra se reproduce en cada monitor, se fija a uno o actúa contextualmente. No mezclar este tema con el selector de escritorios virtuales.

## 9. Interacciones, vista previa y subpaneles

### Exclusividad — CONFIRMADO

SO y bandeja no permanecen abiertos simultáneamente. Abrir uno contrae el otro. Contraer bandeja cierra sus subpaneles y oculta cualquier futuro controlador multimedia.

### Vista previa y selección de ventanas agrupadas — AGRUPACIÓN CONFIRMADA

- Por defecto el selector SO **agrupa las ventanas de la misma aplicación en una sola ficha**.
- Hover sobre una ficha SO, por ejemplo Dolphin, puede mostrar miniatura de la ventana real (como las previews del administrador de tareas de KDE) sin abrir otra fila ni cambiar el alto superior.
- Si hay varias ventanas de la misma aplicación, **clic en la ficha agrupada** abre el selector para distinguir y elegir una de ellas.
- Como **propuesta a prototipar**, ese selector puede ser un popup flotante con las miniaturas **debajo de la barra**, sin cambiar la altura del SO horizontal. Su presentación exacta no está confirmada; no confundir con el menú principal SO, que jamás se convierte en cascada vertical.
- En el **modo desagrupado opcional** cada ventana tiene ficha propia y puede activarse directamente.
- Aprovechar, cuando sea posible, las vistas previas y modelos de ventanas de KDE/KWin en lugar de implementarlos desde cero.

### ¿Qué significa «subpanel»?

No es una nueva barra horizontal. Es una **ventanita temporal que aparece debajo del botón relevante**, por ejemplo:
- clic en `↓`: aparece cuadro de herramientas con calendario, notas y clima;
- clic en calendario: se muestra una cuadrícula mensual utilizable;
- clic en carátula multimedia futura: aparece información y controles de la reproducción;
- clic en lanzador: búsqueda y catálogo de aplicaciones instaladas.

Todos comparten lenguaje de diseño y proporciones coherentes, pero pueden tener distinta anchura/altura según contenido. No se impone que todo sea cuadrado exacto.

### Cuando se cambia de estado — PROPUESTA A PROBAR

- Elegir una ficha **individual** activa su ventana y **contrae SO por defecto**. Si la ficha está **agrupada y contiene varias ventanas**, primero se abre el selector de ventanas; elegir una de ellas la activa y también **contrae SO por defecto**. En ambos casos existe la opción de **mantener SO abierto tras seleccionar**, para personas que alternan repetidamente entre programas.
- Si se cierra bandeja se cierra el subpanel dependiente.
- Abrir SO mientras hay un subpanel de bandeja lo cierra.
- Entrar en fullscreen oculta los subpaneles y controles de escritorio en el monitor correspondiente.
- Un autocierre opcional no se dispara mientras el puntero siga dentro del botón, selector o popup relevante.

La lógica exacta de foco y cierre se verificará con mouse, touchpad, teclado y herramientas de accesibilidad. **La regla por defecto de contraer SO tras seleccionar una ventana ya está confirmada.**

## 10. Recomendación de tecnologías — ACTUALIZADO Y VERIFICABLE

**Elección preferida: Qt 6 + QML/Qt Quick, desarrollando componentes nativos de KDE Plasma.** No elegir tecnología por supuesta novedad: elegir la que mejor se integra con el escritorio existente.

| Opción | Evaluación para ESTE proyecto |
|---|---|
| **Qt 6 + QML/Qt Quick** | Recomendado. Plasma utiliza QML y Qt Quick; ofrece controles visuales, integración con estilos de Plasma y futura animación fluida. |
| **GTK** | Framework maduro y moderno para aplicaciones Linux, pero no es la base natural de los widgets del panel de Plasma. No lo usaríamos como tecnología principal. |
| **Electron** | Usa Chromium y un modelo multiproceso web; sería una capa de recursos y complejidad innecesaria para este módulo estrechamente integrado con KDE. No elegido. |

**Componentes probables de la solución, sujetos a un prototipo técnico:**
- Plasmoid(s) con **QML** para interfaz superior, botones, lista/fichas y preferencias.
- Integración con **KWin** para detectar foco, maximización, minimización, fullscreen y activación de ventanas.
- Reutilización de componentes existentes de Plasma: lanzador, modelos de tareas, bandeja, vistas previas, temas y mecanismos de configuración, evitando recrearlos sin necesidad.
- Código adicional nativo solo donde QML/widget no cubra la integración requerida; no asumir que un script de KWin resuelve por sí solo cualquier superposición y decoración de aplicaciones Wayland.
- MPRIS reservado para una **fase posterior**.

**Tamaños:** emplear una preferencia de grosor como la de Plasma, trabajando con píxeles lógicos y respetando escalado HiDPI. No fijar aún un número universal de píxeles físicos.

**Limitación real:** algunas aplicaciones dibujan pestañas y decoraciones propias (client-side decoration). No todas permiten eliminarlas o integrarles controles externamente. Se deben probar Brave, Firefox y otras, sin prometer compatibilidad universal. El criterio aprobado sigue siendo **superponer antes que desplazar o reducir**.

**Fuentes de referencia para el próximo equipo:**
- KDE Plasma Widgets: https://develop.kde.org/docs/plasma/widget/
- API QML de Plasma: https://develop.kde.org/docs/plasma/widget/plasma-qml-api/
- API scripting de KWin: https://develop.kde.org/docs/plasma/kwin/api/
- Qt Quick/QML: https://doc.qt.io/qt-6/qtquick-index.html
- Qt comparación de tecnologías UI: https://doc.qt.io/qt-6/topics-ui.html
- Arquitectura multiproceso Electron: https://github.com/electron/electron/blob/main/docs/tutorial/process-model.md

## 11. Pruebas de aceptación: mínimo viable y fases futuras

### Imprescindibles para MVP funcional (sin efectos)

1. Panel arriba con altura configurada y constante, con controles SO y bandeja.
2. Lanzador izquierdo visible por defecto y superpuesto al contenido de ventana maximizada; buscar/abrir aplicaciones instaladas.
3. Al maximizar: aparecer `− □ ×` a la derecha sin cambiar geometría de la barra; al restaurar, desaparecer de panel y permanecer los controles propios de la ventana normal.
4. SO abre **solo** programas/ventanas activos y minimizados en una fila horizontal hacia la izquierda, con icono y nombre; **una ficha por aplicación por defecto**, agrupando ventanas de esa aplicación. No aparece lista fija al estar contraído.
5. Si una app tiene varias ventanas (p. ej., tres Dolphin), pulsar su ficha agrupada permite **elegir la ventana concreta y activarla**; el modo desagrupado debe poder habilitarse y mostrar una ficha por ventana.
6. Selector SO y bandeja con alturas idénticas a barra; sin desplazar pestañas de navegador, aunque las cubran temporalmente.
7. Bandeja `◀` al cerrar y `▶` al abrir, mostrando y ocultando componentes básicos de sistema.
8. SO y bandeja se contraen recíprocamente al activar el otro.
9. Fullscreen real (video y juego) oculta barra y popup correspondiente; maximizada mantiene controles.
10. Comportamiento correcto sin una sola animación; clics y estados estables.
11. Fichas extra no engrosan el panel: navegación horizontal con rueda/touchpad y/o flechas.
12. Compatibilidad real probada al menos con Dolphin, Konsole, Brave y Firefox, documentando límites.

### Complementos siguientes — no bloquean MVP

13. Preview real de ventana al hacer hover y, en agrupadas, selector visual de ventanas reutilizando los mecanismos de KDE cuando resulte viable.
14. Selector de escritorios virtuales integrado en SO o indicador independiente configurable, con miniaturas.
15. Centro secundario `↓`/`↑` y herramientas básicas como calendario/notas, con popups de familia visual coherente.
16. Menús contextuales completos, personalización de iconos y temas, tamaño de panel configurable a nivel de preferencias.
17. MPRIS y controlador multimedia en la bandeja, posterior; clic sobre carátula abre popup inferior y al contraer la bandeja desaparece el controlador.
18. Animaciones y efectos especiales modulares, incluidos futuros efectos divertidos, sin romper el núcleo.
19. Configuración multimonitor avanzada y opciones de visibilidad de indicadores, con pruebas por pantalla.

**Criterio:** ningún complemento debe retrasar la entrega de un núcleo que ya permita abrir, activar, minimizar, maximizar, restaurar y cerrar correctamente las ventanas. Para el MVP, la visibilidad automática compleja puede quedar desactivada, pero el cierre tras selección y su preferencia forman parte del diseño aprobado.

## 12. Decisiones confirmadas — no volver a plantearlas como abiertas

- Plataforma de partida: CachyOS + KDE Plasma, preferentemente **Qt 6 + QML** para integrar el proyecto; **no Electron**.
- Barra arriba; **grosor fijo en todos los estados** (configurable globalmente por usuario, sin autoajuste durante interacción).
- Sin ventana maximizada: `[ ◀ ] [ SO ]`; con ventana maximizada: `[ ◀ ] [ SO ] [ − ] [ □ ] [ × ]`.
- Menú SO **horizontal hacia la izquierda**, una sola fila. **Agrupación por aplicación como predeterminada**, una ficha por app, con clic para elegir entre sus múltiples ventanas. **Vista desagrupada configurable**, una ficha por ventana. Nunca cascada vertical del menú principal ni lista permanente.
- Sobreposición de controles permanentes y desplegables encima de pestañas de un navegador maximizado; **no mover ni redimensionar** las pestañas ni el navegador.
- Lanzador de aplicaciones instaladas **a la izquierda y visible por defecto**, por encima de pestañas. Puede ocultarse y cambiarse por icono de lupa u otro.
- SO y bandeja **mutuamente excluyentes**.
- Flecha bandeja `◀` cerrado / `▶` abierto.
- Flecha secundaria `↓` abrir popup bajo barra / `↑` cerrar, con icono personalizable.
- Paneles bajo barra no cambian su grosor; pueden tener dimensiones acordes al contenido.
- Reproductor multimedia **no es prioridad inicial**; cuando exista irá en la bandeja y se ocultará al contraerla.
- Selector SO con navegación horizontal por rueda/touchpad y/o flechas discretas para muchas apps; hover puede revelar previews de ventanas sin alterar geometría.
- Escritorios virtuales con acceso **configurable**, preferiblemente explorando integración dentro de SO o icono independiente; miniaturas bajo hover como comportamiento deseado.
- Monitores físicos se configuran por separado de escritorios virtuales.
- Fullscreen real (video/juego) tiene prioridad y oculta la barra; maximizada no.
- **Primera versión sin efectos animados**; personalización y efectos son posteriores.
- Reutilizar widgets, modelos, vistas previas, controles y servicios de Plasma/KWin siempre que sea viable.
- No usar las láminas rechazadas como fuente de verdad.

## 13. Soluciones y bocetos descartados

- Agrandar la altura del panel al expandir SO, bandeja o cualquier otro grupo.
- Pestañas desplazadas a una franja inferior o aplicación achicada para dejar sitio a menús de la barra.
- Menú de aplicaciones abiertas en cascada vertical.
- Fichas Dolphin/Konsole/Brave permanentemente visibles con SO contraído.
- Centro secundario representado como un botón independiente fuera de la bandeja.
- Orientaciones erróneas de flechas: bandeja abierta `◀` o cerrada `▶`; subpanel abierto `↓` o cerrado `↑`.
- Reproductor fijo fuera de la bandeja que ocupe espacio cuando se intenta expandir SO.
- Gran panel multimedia o centro de control excesivo no solicitado.
- Electron como capa principal del panel KDE.
- Añadir MPRIS, animaciones complejas o efectos visuales como requisitos bloqueantes de la primera versión.
- Imágenes conceptuales gigantes, mezcladas o sobrecargadas que no respetan geometría y prioridades.

**Si cualquier boceto contradice este manual, prevalece la descripción funcional escrita.**

## 14. Cuestiones todavía pendientes (reales y acotadas)

1. **Navegadores con decoraciones propias:** validar en Brave, Firefox y otros que las capas y los controles sean accesibles en el mismo plano vertical. La prioridad de capas **ya está definida**; pendiente es el mecanismo técnico y su compatibilidad concreta.
2. **Diseño exacto del selector secundario de ventanas agrupadas:** la **agrupación por defecto y el modo desagrupado configurable ya están CONFIRMADOS**. Falta decidir solo la presentación visual y ubicación del selector que aparece al tocar una ficha con varias ventanas, y su comportamiento detallado con mouse/teclado. Las miniaturas al hover siguen siendo objetivo.
3. **Escritorios virtuales:** decidir opción predeterminada entre ficha/indicador dentro de SO (extremo izquierdo) o pequeño ícono independiente visible. Ambas alternativas deben ser configurables si resulta viable.
4. **Monitores físicos:** cómo aparece el panel en dos o más pantallas y qué lista SO de cada una. No confundir con escritorios virtuales.
5. **Foco y cierre fino de popups:** cerrar SO al elegir ficha **ya está confirmado por defecto y es configurable**; falta ajustar prioridades entre opciones automáticas, temporizador por salida del puntero, y recorridos con teclado y accesibilidad.
6. **Diseño final:** tamaños en píxeles lógicos, separación de fichas, opacidad, iconos y accesibilidad con escalado HiDPI. El usuario pide adoptar criterios habituales de Plasma y ofrecer configuración manual.
7. **Compatibilidad y seguridad de efectos personalizados:** se investigará después de que el núcleo esté estable; no exige una solución definida hoy.
8. **Algunas interacciones de herramientas secundarias:** calendario, notas y reproductor podrán cerrarse al cerrar bandeja, seleccionar app, abrir otro subpanel o entrar en fullscreen; detalles finos a validar con prototipo.

No repetir preguntas ya contestadas: exclusividad SO/bandeja, prioridad sobre pestañas, comportamiento fullscreen, posición de lanzador, flechas o necesidad de una altura fija.

## 14.1. Publicación libre y gobernanza — DECISIÓN ACTUAL
**Repositorio oficial:** https://github.com/nicoarg87/plasma-smartbar, mantenido por su propietario. La documentación fundacional tiene valor normativo para el proyecto oficial; véase [CONSTITUCION_TECNICA.md](CONSTITUCION_TECNICA.md), [GOVERNANCE.md](../GOVERNANCE.md) y [CONTRIBUTING.md](../CONTRIBUTING.md).

**Alcance:** extensión libre para distribuciones Linux con KDE Plasma 6 compatible, empezando por CachyOS. No se plantea portar a GNOME, Cinnamon, Windows ni macOS.

**Licencia seleccionada:** GNU GPL versión 3.0, según el archivo [LICENSE](../LICENSE) existente en el repositorio. Se permiten uso, estudio, copia, modificación, redistribución y forks bajo sus condiciones; quien distribuya obras derivadas alcanzadas por la licencia debe respetar sus obligaciones. Este hecho sustituye las comparaciones de licencias que aparecen en el historial de versiones anteriores.

**Dirección del proyecto:** el titular y mantenedor del repositorio oficial establece los objetivos funcionales y los criterios de diseño. Los colaboradores pueden abrir issues, proponer cambios mediante pull requests y crear forks, pero sus propuestas no se incorporan automáticamente. Nadie recibe permiso de escritura por contribuir. Una versión alternativa no representa por sí misma el proyecto oficial.

**Colaboración deseada:** revisión de bugs, pruebas entre distribuciones Plasma, corrección de fallos, rendimiento, accesibilidad y mejoras que respeten las reglas de geometría constante, foco, superposición y pantalla completa. Las grandes modificaciones de diseño requieren discusión y aprobación explícita antes de implementarse.

**Prioridad:** estabilidad y compatibilidad por encima de efectos decorativos. La primera versión funcional se construye sin animaciones complejas ni MPRIS. Cualquier reutilización de código de terceros debe ser compatible con GPL-3.0 y mantener avisos de autoría y licencias correspondientes.

**Protección de la rama main:** configurar las reglas de ramas y permisos desde la interfaz de GitHub; la existencia de esta cláusula por sí sola no activa las protecciones de GitHub. Ninguna regla puede impedir que otra persona haga un fork conforme a la GPL.

**Registro del origen:** las decisiones de diseño y el manual se documentan con versiones y cambios. Las aportaciones posteriores son contribuciones de sus autores conforme a sus licencias; el rol de director funcional no supone poseer automáticamente los derechos de autor de todo código futuro.

## 15. Hoja de ruta recomendada (todavía no ejecutada)

### Fase 1 — MVP núcleo estable, sin animaciones ni multimedia

1. Panel superior de altura configurable y estable; lanzador a la izquierda; SO y flecha a la derecha.
2. Detectar maximizada/restaurada; mostrar y manejar `− □ ×` de manera coherente.
3. Selector SO horizontal hacia la izquierda para listar aplicaciones **agrupadas por defecto**, activar ventanas desde fichas individuales o desde el selector del grupo, y permitir **modo desagrupado** mediante configuración; probar también minimizadas.
4. Bandeja horizontal que abre/cierra mediante `◀` y `▶`; exclusividad SO/bandeja. SO se contrae por defecto al activar una ventana, con preferencia de mantener abierto; preparar opciones de visibilidad adaptativa para probar en una etapa posterior sin comprometer el núcleo.
5. Garantizar capas sobre navegadores maximizados y ocultación total en fullscreen real.
6. Verificar estabilidad con Dolphin, Konsole, Brave y Firefox.
7. Fichas con scroll horizontal/gestos de touchpad y controles discretos de navegación en caso de desbordamiento.

### Fase 2 — Mejora de navegación y escritorio

1. Mejorar las previsualizaciones de ventanas al posar cursor sobre fichas y el selector visual de ventanas agrupadas (usar mecanismos KDE); mantener la selección funcional mínima desde la fase 1.
2. Escritorios virtuales: integración opcional dentro SO y/o icono discreto, con miniaturas.
3. Configuración general básica, clic derecho y variación global de altura de barra sin autoajustes.
4. Centro secundario bajo barra, con calendario/notas básicos, si el núcleo ya es estable.

### Fase 3 — Complementos y personalización

1. Reproductor multimedia vía MPRIS dentro de bandeja; subpanel al tocar carátula.
2. Temas independientes, opacidad y blur opcionales, iconos modificables.
3. Animaciones suaves opcionales, desactivadas inicialmente, incluida la futura «gaveta de SO» al minimizar ventanas (referencia de duración aproximada 0,5 s, pendiente de pruebas).
4. Mejoras multimonitor, pruebas de monitores/escritorios y accesibilidad.

### Fase 4 — Ecosistema de efectos

Permitir paquetes de animaciones temáticas o humorísticas, con límites de rendimiento y seguridad. Nyan Cat es un ejemplo conceptual; no es una funcionalidad prometida.

**Orden obligatorio:** primero funcionamiento fiable; luego navegación; después complementos y apariencia.

## 16. Texto de traspaso — pegar al iniciar otro chat

Estoy diseñando una interfaz superior inteligente para **CachyOS con KDE Plasma/KWin (Wayland)**; aún no estamos programando. Quiero **Qt 6 + QML/Qt Quick**, aprovechando lo existente en KDE; **no** una aplicación Electron ni reescribir todo el entorno. La primera versión debe ser **funcional y SIN animaciones ni MPRIS**: abrir/activar/minimizar/maximizar/restaurar/cerrar ventanas, selector horizontal SO, bandeja, prioridad de capas, comportamiento fullscreen.

Hay una **barra superior de altura fija** (el usuario podrá configurar una altura preferida al estilo KDE, pero las interacciones nunca la cambian). SO también tendrá **modo de visibilidad contraído, siempre expandido o adaptativo** (contracción opcional al abrir/activar apps con pestañas). **Por defecto, seleccionar una ventana contrae SO; esto podrá desactivarse.** En la esquina izquierda hay **lanzador de programas instalados** con lupa/búsqueda y catálogo; es **visible por defecto** y puede ocultarse/cambiar icono con clic derecho. En el extremo derecho están **flecha de bandeja** y **SO** (este último lista solo **aplicaciones y ventanas que ya están abiertas**). Si una ventana está maximizada, aparecen a la derecha `− □ ×`; SO y flecha se corren lateralmente sin variar alto. Sin max no aparecen esos tres controles globales.

Al tocar SO se expande una **única fila horizontal de fichas hacia la izquierda**, mostrando icono/nombre de aplicaciones abiertas; **POR DEFECTO una ficha por aplicación (ventanas agrupadas)**, y al tocar una ficha que tiene varias ventanas (p. ej., tres Dolphin) se abre un selector para elegir una. Debe existir la opción **DESAGRUPAR**, donde cada ventana aparece en ficha independiente. El selector visual secundario aún no tiene forma definitiva. NO menú SO principal vertical, NO fichas permanentemente visibles. Las fichas pueden **superponerse por encima de las pestañas de Brave/Firefox** sin desplazar, achicar ni bajar esas pestañas ni la ventana. **Lanzador izquierdo, SO, flecha y controles globales permanentes deben permanecer por encima de las pestañas** incluso en estado contraído. Al pasar el puntero por una ficha se desea mostrar **miniatura real de esa ventana**, reutilizando vistas previas de KDE. Si hay muchas fichas, desplazamiento con **rueda de mouse, gesto de touchpad y/o flechas de navegación**, siempre sin doble fila ni aumento de altura.

Flecha bandeja `◀` = abrir horizontalmente a la izquierda; `▶` = cerrar. **SO y bandeja son excluyentes**: abrir uno contrae el otro. Dentro de bandeja expandida la flecha secundaria `↓` abre un **subpanel flotante ABAJO** de la barra (calendario, notas, adhesivas, etc.) y `↑` lo cierra; iconos configurables. Un reproductor MPRIS podrá incorporarse **después**, dentro de bandeja, ocultándose con ella y abriendo subpanel armonizado al tocar la carátula. El **fullscreen real** (juego/video fullscreen) oculta completamente los controles superiores; maximizada no.

Se quieren **escritorios virtuales** de forma discreta y configurable: opción de indicadores al extremo izquierdo del selector SO, con miniatura al hover y clic para cambiar, o ícono independiente pequeño en la barra. **Todavía no está decidido cuál es la presentación por defecto.** Los **monitores físicos múltiples** son un tema distinto, también configurable. Personalización, transparencias, temas y efectos vendrán **después de estabilizar el núcleo**; el ejemplo Nyan Cat es solo una demostración de lo que podría admitir un sistema de efectos modular.

El proyecto tiene repositorio oficial público **https://github.com/nicoarg87/plasma-smartbar**, bajo **GPL-3.0**, para **Linux con KDE Plasma**. No se busca compatibilidad con otros escritorios ni Windows/macOS. No usar las imágenes conceptuales recargadas y descartadas como referencia. Esta especificación escrita prevalece. Preguntar solo ante verdaderas contradicciones o decisiones técnicas abiertas; evitar repetir preguntas ya contestadas.

---

## 17. Cambios de la versión 0.5 respecto a 0.4

- **Arquitectura sugerida:** Qt 6 + QML/Qt Quick + integración Plasma/KWin; GTK no prioritario; Electron descartado para la barra.
- **MVP sin efectos ni MPRIS:** multimedia y personalización visual avanzada pasan a fases posteriores.
- **Capa superior:** se explicita que los **controles permanentes y el lanzador izquierdo** siempre están por encima de las pestañas cuando no hay fullscreen.
- **Lista SO:** navegación horizontal por rueda/touchpad/flechas; vista previa real de ventana al hover reutilizando KDE si se puede.
- **Escritorios virtuales:** se incorpora opción dentro de SO, con miniaturas, o botón independiente discreto; la elección del predeterminado aún no está cerrada.
- **Lanzador:** búsqueda rápida por lupa y catálogo de apps instaladas; clic derecho para ocultar o personalizar.
- **Tamaño:** altura configurable como propiedad global, pero inmutable durante uso; respetar píxeles lógicos/escala.
- **Subpaneles:** definición explícita de las ventanas flotantes debajo de barra, sus disparadores y cierre dependiente.
- **Compatibilidad:** se mantiene como prueba con navegadores y Wayland, sin inventar que todas las apps podrán integrar decoraciones automáticamente.


---

## 18. Cambios de la versión 0.6 respecto a 0.5

- **CONFIRMADO:** en SO la vista predeterminada **agrupa ventanas por aplicación**. Tres ventanas de Dolphin se representan en **una ficha Dolphin**.
- **CONFIRMADO:** hacer clic sobre una ficha agrupada con varias ventanas permite verlas individualmente y seleccionar la deseada.
- **CONFIRMADO:** el usuario puede activar **modo desagrupado** desde configuración; entonces cada ventana ocupa una ficha independiente.
- **PENDIENTE SOLO EN PRESENTACIÓN:** forma exacta del selector secundario de ventanas del grupo, uso de miniaturas y la opción de volver/cerrar. Un popup flotante con miniaturas es una propuesta, **no un compromiso ya aprobado**.
- Se actualizan las pruebas del MVP, el texto de traspaso y la sección de decisiones cerradas para que ningún chat futuro vuelva a preguntar si agrupar o desagrupar por defecto.


---

## 19. Cambios de la versión 0.7 respecto a 0.6

- **Alcance Linux/Plasma:** desarrollo distribuible entre distros compatibles con **KDE Plasma 6**, sin planes de portación a GNOME, Cinnamon, Windows o macOS.
- **SO adaptable:** puede permanecer expandido, permanecer contraído o cerrarse automáticamente ante activación de aplicaciones con pestañas; configurable y sujeto a pruebas en diferentes navegadores.
- **SO tras selección:** confirmado el cierre/contracción **por defecto** luego de activar ventana; opción de **mantener abierto** para cambios frecuentes.
- **GitHub:** objetivo explícito de repositorio público abierto, con documentación previa al código y fork/redistribución permitidos; ya publicado como repositorio inicial.
- **Licencias:** se distingue MIT (permisiva) y GPL-3.0-or-later (copyleft), y se aclara que ausencia de licencia no implica permiso general de reutilización. Licencia elegida posteriormente: GPL-3.0; esta frase pertenece al historial de la v0.7.
- **Reglas que no cambian:** altura constante, ventanas y pestañas no desplazadas, SO agrupado por aplicación por defecto, bandeja y SO excluyentes, fullscreen oculta todo, multimedia y animaciones quedan para fases posteriores.

### Apéndice breve para el próximo chat

A lo definido en el traspaso del apartado 16 se agrega: el usuario quiere **código abierto en GitHub para Linux con Plasma** (CachyOS primero, luego otras distros), sin objetivos GNOME/Windows/macOS; **SO tiene modos de visibilidad contraído, expandido y automático**. Configurable, puede retraerse al abrir o activar navegadores con pestañas. **Al elegir una app/ventana, por defecto SO se contrae**, aunque el usuario puede configurarlo para permanecer expandido. El primer lanzamiento debe priorizar estabilidad sin MPRIS ni efectos; buscar compatibilidad real en KWin/Wayland. **La licencia elegida posteriormente es GPL-3.0**, y el repositorio oficial ya existe en https://github.com/nicoarg87/plasma-smartbar.

## 20. Constitución técnica y jerarquía de decisiones — NUEVO EN v0.8

La especificación funcional vigente es la de este Manual Maestro, bajo la dirección funcional del mantenedor oficial. Se distinguen: **(a)** invariantes obligatorias del diseño, **(b)** preferencias configurables, **(c)** ideas de futuras fases y **(d)** hipótesis técnicas a validar. Una sugerencia o pull request externo no cambia automáticamente un requisito confirmado.

**Orden de autoridad dentro del repositorio oficial:** requisitos confirmados de la constitución técnica y este manual > especificaciones aprobadas para una etapa concreta > propuestas e issues abiertos > bocetos o ilustraciones conceptuales. Ante una contradicción, documentar y pedir decisión al mantenedor antes de cambiar el comportamiento.

**Principios operativos:** no romper programas ni sus pestañas; respetar el fullscreen real; mantener grosor constante; conservar control de foco; no introducir efectos que cambien la geometría; preferir código existente compatible, rendimiento y pruebas; no anunciar compatibilidad universal sin haberla probado.

**Derechos de terceros:** los forks son libres conforme a GPL-3.0. Las decisiones de incorporación y publicación de la versión oficial permanecen en manos de los mantenedores autorizados. La marca o nombre del proyecto podrá regirse separadamente de la licencia del código, cuando se documente de forma adecuada.

**Evolución del manual:** registrar fecha, número de versión, requisito modificado, motivo y aprobación. No borrar la historia de decisiones cuando sea relevante para comprender el proyecto.

**Nota de vigencia:** las referencias antiguas que describen a GitHub como no creado, MIT como preferencia, o la licencia como no elegida corresponden a versiones históricas; fueron sustituidas por esta actualización y la sección 14.1 actual.


## 21. Historial de decisiones — 14 de noviembre de 2026 (v0.9)

**CONFIRMADO:** la interfaz predeterminada se representa mediante **dos islas visibles**: isla 2 (lanzador izquierdo) e isla 1 (SO + bandeja, a la derecha). La **isla 3 (buscador visible)** es opcional y está oculta por defecto. El fondo que conecta las islas es transparente o inexistente por defecto, pero puede configurarse como **fondo continuo/entrelazado**. El logo de SO es configurable para identificar visualmente el sistema/distribución. Se mantienen todas las reglas de grosor constante, expansión a izquierda y fullscreen real.

**CONFIRMADO COMO FUNCIÓN FUTURA:** animación de minimización tipo «gaveta de SO», inspirada en KWin Magic Lamp, con una ficha temporal que muestra el nombre/icono del programa y se repliega automáticamente; aproximadamente medio segundo es solo referencia de diseño. Debe poder desactivarse sin perder ninguna funcionalidad.

**PENDIENTE TÉCNICO:** validar superposición frente a pestañas y coordinación del efecto con KWin; **no son funciones implementadas ni probadas**.

**AUTORIDAD:** los bocetos conceptuales pueden mostrar componentes extra o posiciones de controles inexactas; solo lo escrito como CONFIRMADO en las secciones normativas constituye especificación. No se altera la constitución de control de decisiones del repositorio oficial.
