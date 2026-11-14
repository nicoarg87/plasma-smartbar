# Constitución técnica de Plasma SmartBar
**Estado:** documento rector del proyecto oficial. **Versión:** 1.13 (anclaje del lanzador SO al desplazamiento de isla 1; 14/11/2026).
**Dirección funcional y de diseño:** mantenedor del repositorio oficial [nicoarg87](https://github.com/nicoarg87).
**Manual de especificación:** [Manual Maestro](MANUAL_MAESTRO.md).

## 1. Misión
Construir un complemento libre para **Linux con KDE Plasma 6** que administre ventanas y aplicaciones mediante islas de barra minimalistas, previsibles y de **grosor constante**, configurables **arriba o abajo** de la pantalla. CachyOS es la plataforma inicial de pruebas, no una dependencia exclusiva. La extensión no requiere crear una distribución nueva y no tiene como objetivo GNOME, Cinnamon, Windows o macOS.

## 2. Invariantes no negociables
1. La barra y todos los menús que se **expanden horizontalmente** mantienen idéntico **grosor**. En modo horizontal (superior/inferior), la altura puede configurarse como preferencia del usuario, pero no cambia al maximizar, restaurar, abrir una bandeja o navegar entre ventanas.
2. El botón **SO** muestra aplicaciones/ventanas que ya están abiertas; el lanzador del extremo izquierdo busca programas **instalados**. Son controles diferentes.
3. SO despliega fichas **hacia la izquierda, en una sola fila**. Agrupa por aplicación de manera predeterminada (por ejemplo, tres ventanas Dolphin en una ficha). Se puede desagrupar por configuración.
4. La flecha de bandeja es **izquierda al abrir (◀)** y **derecha al cerrar (▶)**. SO y bandeja **son mutuamente excluyentes**.
5. Cuando una ventana está maximizada, los botones de SmartBar **minimizar, restaurar/maximizar y cerrar** aparecen **anclados al extremo derecho de la ventana/franja horizontal**, **en el mismo borde elegido**: arriba si está arriba, **abajo si está abajo**. **No se arrastran junto a la isla 1**, no siguen a SO ni cambian de posición al abrir su bandeja. **La isla 1 debe apartarse a la izquierda de los botones al maximizar**, y el agarre solo mueve la isla. En ventanas normales siguen existiendo los controles propios de cada aplicación. El tamaño y la alineación respecto de la barra permanecen constantes. El destino exacto de los botones originales de cada aplicación está sujeto a validación técnica y no se presume que KWin pueda trasladarlos universalmente.
6. Las islas y sus expansiones tienen prioridad de capa en el borde horizontal elegido sobre la **interfaz de las ventanas maximizadas**; en modo superior esto incluye las pestañas del navegador, cuya convivencia sigue pendiente de validación. Se puede cubrir contenido temporalmente, pero jamás desplazar pestañas, redimensionar ventanas o crear otra fila.
7. En **pantalla completa real** (video o videojuego), los controles de escritorio no deben superponerse al contenido.
8. Seleccionar una ventana desde SO la activa y **contrae SO por defecto**; el usuario puede configurar que permanezca abierto. También existen modos de SO contraído, expandido o adaptativo.
9. Los paneles secundarios (calendario, notas, etc.) flotan hacia el **interior de la pantalla** (debajo de la barra superior; encima de la inferior), sin cambiar su grosor. La flecha vertical está **dentro de la bandeja**; su iconografía debe adaptarse al borde elegido y verificarse en pruebas de usabilidad.
10. Elementos accesorios no deben interferir con el cambio de aplicaciones. El reproductor **MPRIS es futuro, no MVP**; cuando exista pertenecerá a la bandeja y se ocultará al contraerla.
11. Los indicadores de escritorios virtuales/monitores son **configurables**, sin ocupar espacio obligatorio permanente.
12. El primer prototipo debe funcionar **sin animaciones**. Los efectos opcionales jamás podrán alterar geometría, foco, accesibilidad ni estabilidad.

## 2.1. Distribución predeterminada en islas — confirmada

- **Isla 1, derecha:** identidad del sistema (botón SO con logo configurable), flecha de bandeja y **agarre de seis puntos inmediatamente a la derecha de SO**. **Los controles de ventana forman un bloque separado, fijo en el extremo derecho**, no pertenecen al contenido arrastrable de isla 1. Al maximizar, la isla se coloca a la izquierda de esos controles; el agarre solo reubica la isla. **SO y agarre mantienen posición mientras bandeja/SO expanden su contenido hacia la izquierda**. El agarre no forma parte del menú expandible. No desplazar pestañas ni cambiar la altura.
- **Isla 2, izquierda:** lanzador que busca programas instalados; es un componente **secundario respecto de la isla 1**. Su presencia por defecto se mantiene; el usuario puede ocultarlo por configuración sin desactivar las funciones de SO.
- **Isla 3, junto al lanzador:** campo de búsqueda visible **opcional y oculto por defecto**.
- **Separación visual por defecto:** solo las islas, sin fondo continuo entre ellas. El usuario puede activar un tema con **fondo continuo/entrelazado** sin modificar geometría ni conducta.
- La minimización con animación tipo **gaveta/ranura temporal de SO** se contempla **únicamente como efecto optativo futuro**, no como requisito del MVP. Su duración objetivo inicial rondaría medio segundo, sujeto a pruebas. La ventana se minimiza igualmente sin efectos.
- **La superposición sobre las pestañas de navegadores maximizados sigue pendiente de validación técnica** y no se considera resuelta por ninguna imagen conceptual.
- **El agarre horizontal es un requisito de diseño confirmado, no una función probada.** Debe tener **exactamente seis puntos en dos columnas de tres**, con apariencia discreta y arrastrable, pero tener un área de interacción utilizable. Sus límites de movimiento, posición guardada y coordinación con la maximización se validarán en KWin/Wayland; no será obligatorio en la primera prueba v0.1.

## 2.2. Orientación y preparación para extensibilidad — decisión confirmada (14/11/2026)

**Modos oficiales de diseño:**
- **Superior (predeterminado):** las islas 2 y 1 permanecen respectivamente a izquierda y derecha en el borde superior; se conserva la integración superior aprobada y los controles SmartBar de ventanas maximizadas arriba.
- **Inferior (configurable):** las mismas islas mantienen sus funciones y extremos izquierdo/derecho en el borde inferior. **Los controles SmartBar de minimizar, restaurar/maximizar y cerrar para la ventana maximizada deben estar abajo, fijos en el extremo derecho**, con isla 1 a su izquierda por defecto, **nunca en una barra superior ni moviéndose con la isla**.
- En ambos modos, SO y bandeja siguen extendiéndose **horizontalmente hacia la izquierda en una fila**, con altura invariable; el agarre punteado está **inmediatamente a la derecha de SO**, no se desplaza por abrir la bandeja y permite el ajuste horizontal deliberado de isla 1.
- Paneles secundarios flotan **hacia adentro** de la pantalla y no aumentan el grosor.

**Compatibilidad y límite técnico:** ubicar **controles funcionales de SmartBar** abajo es un objetivo confirmado; **mover o suprimir las decoraciones originales que cada aplicación dibuja arriba no se considera resuelto ni garantizado**. KWin/Wayland, ventanas Qt/GTK y navegadores con decoración propia requieren pruebas, sin destruir ni ocultar funciones indispensables de la aplicación. Si algún tipo de ventana no permite una integración segura y coherente, documentar el bloqueo y pedir decisión funcional antes de cambiar el requisito o introducir soluciones intrusivas.

**Lados izquierdo/derecho:** quedan **fuera de los modos oficiales iniciales**. Se permite investigación/experimentación posterior y forks que lo implementen, sin compromiso de que el diseño vertical funcione de inmediato. La arquitectura debe **separar orientación, anclaje y disposición de la lógica de tareas/ventanas**, evitando codificar exclusivamente coordenadas superiores; no sacrificar estabilidad ni rendimiento del modo horizontal por esto.

**Orden de ejecución:** implementar y probar primero el modo superior y sus reglas vigentes; planificar la compatibilidad inferior desde el diseño del código, habilitarla tras pruebas específicas. No introducir modo inferior o lateral como funcionalidad «probada» solo por existir en Plasma una opción de mover paneles.


## 2.3. Retorno horizontal automático de isla 1 — decisión confirmada

- **Al maximizar una ventana**, el agarre punteado inmediatamente a la derecha de SO debe permitir **mover manualmente la isla 1 en el eje horizontal**, sin modificar la altura. El agarre siempre acompaña SO, sin saltar por las expansiones de SO o bandeja.
- **Al dejar de estar maximizada la ventana**, la isla 1 **vuelve automáticamente a su posición predeterminada en el extremo derecho**, salvo que el usuario haya desactivado expresamente la opción.
- La preferencia «**Volver automáticamente a la derecha al desmaximizar**» está **activada por defecto** y debe ser **configurable y persistente** en las opciones de Plasma SmartBar. Si está desactivada, puede conservarse el desplazamiento manual al dejar de estar maximizada.
- La coordinación con los controles de ventana, los márgenes válidos, el tratamiento de múltiples monitores y la lectura real del estado de KWin/Wayland deben investigarse y probarse. No se permite que el agarre o la isla queden fuera de pantalla o tapen controles indispensables de forma irreversible.
- La **v0.1 experimental** puede simular el estado maximizado para probar el movimiento y los ajustes, **sin afirmar que ya se detectan las ventanas reales**.

## 2.4. Controles de ventana independientes de las islas — corrección aprobada tras prueba real

- **CONFIRMADO:** al maximizar, los botones de SmartBar `− □ ×` ocupan una **zona fija en el extremo derecho del borde horizontal activo** y no participan del arrastre de isla 1. En modo superior quedan arriba a la derecha; en modo inferior, abajo a la derecha.
- **Composición:** isla 1 (bandeja, SO, seis puntos) es el bloque desplazable; el grupo de controles es **otro bloque independiente**. En su posición predeterminada son vecinos; si el usuario mueve la isla hacia el centro, **los tres controles permanecen en la esquina derecha**, con separación visible.
- **Maximización:** al entrar en estado maximizado se reserva el espacio de controles en el borde; al salir desaparecen los controles SmartBar simulados y se aplica el retorno automático de isla 1 según la preferencia aprobada. Abrir SO o bandeja no modifica los controles.
- **Prevención:** no desplazar ni redimensionar la ventana real, sus controles originales ni sus pestañas. **La viabilidad en ventanas reales de KWin/Wayland aún no está demostrada**; un boceto o simulador no la certifica.
- **Origen:** el mantenedor detectó durante la prueba v0.1 en CachyOS que la maqueta arrastraba incorrectamente los tres controles junto con isla 1 y exigió mantenerlos en el extremo derecho. Esta corrección sustituye cualquier referencia anterior a controles que se desplazan junto al agarre.

## 2.5. Posición recordada de isla 1 por aplicación — decisión confirmada (14/11/2026)

- **Prioridad funcional:** **isla 1**, con SO, bandeja y agarre de seis puntos, es el elemento principal de Plasma SmartBar. **Isla 2** es el lanzador de programas instalados, secundario y ocultable por preferencia, **visible por defecto** hasta decisión diferente.
- **Guardar por elección del usuario:** con una aplicación maximizada y activa (Steam, Dolphin, Brave u otra), el usuario **arrastra horizontalmente la isla 1** hasta el punto deseado y realiza **clic derecho sobre la isla 1** para acceder a «**Recordar esta posición para [aplicación]**». La posición queda guardada localmente para esa aplicación. Debe poder **modificarse o borrarse** luego mediante ajustes/contexto, sin obligar a editar archivos.
- **Recuperación automática:** cuando vuelve a estar **activa y maximizada** la misma aplicación, Plasma SmartBar identifica su pertenencia y **recoloca isla 1 en el lugar guardado**, sin exigir un nuevo arrastre ni clic. Si se activa otra aplicación maximizada con su propia posición guardada, se usa la de esa otra aplicación. Con ninguna regla almacenada, se usa la ubicación general predeterminada.
- **No basta con que una app siga abierta en segundo plano**: la aplicación **activa/maximizada** determina el perfil aplicable. Así pueden coexistir Steam y Dolphin sin órdenes contradictorias de posicionamiento.
- **Precedencia con retorno global ya aprobado:** mientras una aplicación esté activa/maximizada, **su perfil guardado prevalece** sobre la ubicación general; al desmaximizar, continúa rigiendo «Volver automáticamente a la derecha» (activada por defecto), salvo que el usuario la desactive. Un desplazamiento manual **no modifica el perfil almacenado hasta que se elija guardar**.
- **Controles independientes:** los botones propios de SmartBar `− □ ×` permanecen **fijos en el extremo derecho**, sin seguir a isla 1. Los perfiles no trasladan los controles originales de la aplicación, ni alteran pestañas, tamaño de ventana, grosor de SmartBar o fullscreen real.
- **Persistencia y seguridad:** guardar la relación con un identificador estable de aplicación (no solo el título variable de la ventana), aplicar límites válidos en cada pantalla/escala y garantizar una forma de restaurar posiciones predeterminadas. Determinar compatibilidad con KWin/Wayland, Steam/XWayland, múltiples ventanas y varios monitores mediante pruebas.
- **Estado de desarrollo:** **CONFIRMADO COMO REQUISITO FUNCIONAL, NO IMPLEMENTADO NI PROBADO**. Su construcción depende de poder identificar ventanas reales y su aplicación, todavía pendiente de la prueba v0.1. Se registra en [issue #4](https://github.com/nicoarg87/plasma-smartbar/issues/4).
- **Altura:** **no se autoriza** cambiar automáticamente el grosor según Steam u otra aplicación; permanece la altura común y constante aprobada. Medir o alinear visualmente títulos de aplicaciones será investigación separada, sin cambios de diseño hasta nueva aprobación.

## 2.6. Alineación derecha de isla 1 — control de estado y arrastre (14/11/2026)

**CONFIRMADO:** la casilla contextual **«Alinear isla 1 a la derecha»** representa la alineación **actual** y comienza marcada en la posición predeterminada. No es la misma opción que la preferencia persistente «Volver automáticamente a la derecha al desmaximizar».

- **Arrastre directo:** cuando el usuario mueve isla 1 mediante los seis puntos, **la casilla «Alinear a la derecha» se destilda automáticamente**. La isla permanece en la posición horizontal elegida cuando se suelta el agarre. No se exige destildar manualmente nada antes de arrastrar.
- **Activar alineación:** al tildar **«Alinear isla 1 a la derecha»**, la isla regresa **inmediatamente** a su posición predeterminada: a la izquierda del bloque de controles `− □ ×` si hay ventana maximizada y esos controles están visibles, o al extremo derecho si no están. Los controles de ventana permanecen en el borde derecho y **no se desplazan**.
- **Desactivar alineación manualmente:** simplemente deja libre el posicionamiento; no mueve la isla por sí sola.
- **Retorno al desmaximizar:** la preferencia independiente, configurada **activada por defecto**, conserva su regla anterior: cuando una ventana deja de estar maximizada, la isla regresa a la derecha si el usuario no la desactivó. **No se aplica al soltar el agarre.**
- **Perfiles por aplicación:** si Steam, Dolphin u otra aplicación tiene una posición guardada, debe poder recuperarse sin tener que modificar a mano la casilla. Un movimiento manual destilda la alineación, **pero no guarda ni sobrescribe perfiles**; el guardado requiere la acción contextual «Recordar esta posición para [aplicación]» ya aprobada.
- **Invariantes:** no alterar altura, expansión en una sola fila, bandeja/SO excluyentes, fullscreen real, compatibilidad de aplicaciones ni el posicionamiento fijo de controles de ventana.
- **Estado:** lógica de alineación incorporada **solo a la maqueta QML en la rama v0.1**, **todavía sin repetir pruebas en CachyOS**; integración con ventanas reales/KWin pendiente. La persistencia de preferencias globales continúa por validar.

## 2.7. Mantener la posición física al retirar los controles de ventana (14/11/2026)

**CONFIRMADO por comportamiento ya aprobado:** cuando la opción «Volver a la derecha al desmaximizar» está **desactivada** y una ventana deja de estar maximizada, la isla 1 debe **permanecer en la misma coordenada visual horizontal**, en vez de correrse hacia la derecha por la mera desaparición de los controles `− □ ×`.

- El bloque de controles está fijo a la derecha y deja libre un ancho al desaparecer. Si el desplazamiento se mide respecto al espacio disponible a la izquierda de los controles, ese cambio **NO debe arrastrar la isla**: el posicionamiento debe compensar la diferencia geométrica.
- **Retorno activado:** al desmaximizar, sigue rigiendo el regreso al extremo derecho. **Retorno desactivado:** conservar posición visual salvo ajuste mínimo imprescindible por límites físicos de pantalla.
- La casilla contextual «Alinear isla 1 a la derecha» mantiene su independencia: al arrastrar se destilda, al tildar retorna inmediatamente. Un perfil de posición por aplicación guardado mediante clic derecho no se modifica solo por desmaximizar.
- **Estado:** la corrección existe **solo en QML experimental del PR #3, no probada aún en CachyOS tras ese parche**. El posicionamiento con ventanas reales y varios monitores sigue pendiente. No cambia el grosor ni la separación de controles.

## 2.8. Adaptación al ancho disponible (14/11/2026)

- **CONFIRMADO:** en orientación horizontal, SmartBar debe **distribuir sus islas a lo largo de todo el ancho útil disponible** del panel/contenedor, sin conservar un ancho máximo fijo que deje la isla 1 lejos del extremo derecho.
- **Respuesta a cambios:** si la pantalla, resolución, escalado, contenedor o ventana de ensayo cambian de ancho, la **isla 2 sigue anclada al extremo izquierdo útil** y **la isla 1 y los controles independientes de ventana siguen el extremo derecho útil**, respetando desplazamiento manual, reserva para controles y límites de pantalla. No se exige recargar el widget para reajustarlo.
- **No confundir ancho con aspecto:** «ocupar el ancho disponible» significa que **las posiciones/anclajes usan el ancho completo**, **NO** que deba aparecer un fondo continuo entre islas. De forma predeterminada solo se ven islas separadas, como se aprobó.
- **Altura invariable:** cambios en el ancho no hacen que aparezcan segundas filas ni cambian el grosor de SmartBar. Al reducirse mucho el ancho, el comportamiento ante falta de espacio debe probarse y decidirse antes de sacrificar requisitos confirmados.
- **Limitación de prueba:** `plasmoidviewer` puede agregar márgenes o restricciones propias. Esto no exime a SmartBar de redimensionarse correctamente cuando recibe nueva geometría. La integración de pantalla y KWin/Wayland **no está verificada** por la ventana de ensayo.
- **Estado:** el QML del [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) solicita `Layout.fillWidth` y registra cambios de anchura, pero **esta corrección no ha sido probada todavía en CachyOS**.

## 2.9. Compensar reservas de controles en ambos sentidos (14/11/2026)

**Aclaración técnica de reglas ya confirmadas, tras prueba del mantenedor en CachyOS:** cuando la isla 1 ha sido **desplazada manualmente** (casilla «Alinear a la derecha» destildada), **activar** la maximización no debe empujarla involuntariamente hacia la izquierda por el mero hecho de reservar espacio para los controles `− □ ×`. Del mismo modo, **desmaximizar** con retorno desactivado no debe moverla hacia la derecha por retirar esa reserva.

- En ambas transiciones se debe conservar la **posición visual horizontal** elegida por el usuario, compensando el espacio que aparece o desaparece.
- **Excepción de seguridad:** al maximizar, si la posición previa se superpondría al bloque fijo de controles, la isla se desplaza **únicamente lo necesario** para no taparlos. Los propios controles siguen fijos al extremo derecho.
- Cuando la casilla «Alinear a la derecha» esté **tildada**, maximizar coloca isla 1 normalmente **inmediatamente a la izquierda** de los controles. La opción de retorno al **desmaximizar** conserva la conducta que ya fue aprobada y es independiente de la alineación contextual.
- No modificar automáticamente el grosor, tamaño de ventanas reales ni sus controles originales. **Pendiente de verificar el parche en CachyOS; no probado con ventanas reales/KWin**.

## 2.10. SO como acceso alternativo al lanzador, con isla 2 opcional (14/11/2026)

**DECISIÓN CONFIRMADA:** se mantiene **isla 2 visible por defecto**, a la izquierda, como lanzador de aplicaciones instaladas, **pero el usuario puede ocultarla fácilmente** si prefiere una configuración simplificada con solo isla 1. La isla 2 no se elimina del diseño.

- **SO, clic breve:** continúa abriendo/cerrando la lista de aplicaciones/ventanas **abiertas**, incluidas las minimizadas, agrupadas por aplicación. Esta función no se sustituye.
- **SO, pulsación sostenida:** tras un intervalo inferior a medio segundo (referencia inicial para prueba **400 ms**), abre un **lanzador flotante de aplicaciones instaladas**. Al soltar después de una pulsación sostenida **NO** se ejecuta además el clic breve. Debe existir alternativa accesible por menú contextual/teclado.
- **Isla 2, clic derecho:** muestra una acción directa **«Ocultar isla 2»**. Desde el menú contextual del botón SO debe poderse **«Mostrar isla 2»** de nuevo. La preferencia de visibilidad debe poder guardarse; estado inicial **visible**.
- **Regla visual:** un lanzador flotante secundario sale hacia el interior de la pantalla, sin cambiar el grosor constante de las islas ni crear una segunda fila de SO/bandeja. En modo inferior el flotante deberá orientarse hacia arriba. SO, agarre de seis puntos y controles de ventana no cambian de posición por ello.
- **Exclusividad:** abrir el lanzador desde SO cierra las listas desplegadas de SO y bandeja para evitar superposiciones; el menú del lanzador no reemplaza el listado de ventanas.
- **Ocultación automática de isla 2:** **PROPUESTA EN ESTUDIO, NO APROBADA PARA IMPLEMENTAR TODAVÍA**. Deben especificarse el disparador, la recuperación accesible, la preferencia y compatibilidad con el foco antes de añadirla; no activar por defecto ni inventar temporizadores.
- **Alcance actual:** el prototipo de prueba usa fichas de aplicaciones **simuladas**, con clic sostenido de 400 ms y opción de ocultación/restitución. **NO hay aún enumeración de aplicaciones instaladas ni lanzamiento real**, ni prueba posterior de esta nueva interacción en CachyOS. No se debe presentar la funcionalidad final como terminada.

## 2.11. Anclaje del lanzador flotante a la isla 1 desplazable (14/11/2026)

**CONFIRMADO POR OBSERVACIÓN DEL MANTENEDOR:** el menú flotante que abre una pulsación sostenida sobre **SO** pertenece a **isla 1**, y debe aparecer **inmediatamente debajo de su posición actual en el modo superior**, incluso si la isla fue arrastrada manualmente hacia el centro o hacia la izquierda. No debe reaparecer en el extremo derecho predeterminado mientras la isla permanezca desplazada.

- **Geometría reactiva:** el lanzador sigue horizontalmente la posición de **isla 1** al arrastrarla o al redimensionar el contenedor. En modo superior se muestra **debajo** de la isla; en el modo inferior futuro debe abrirse **por encima** (según el diseño aprobado de los paneles secundarios).
- **Límites:** el popup permanece dentro de los márgenes útiles de la pantalla/contenedor, incluso cerca de los bordes. El ajuste por límites no mueve isla 1 ni los controles independientes de ventana.
- **No cambia:** clic breve SO para ventanas abiertas, pulsación de prueba ~400 ms para lanzador, islas separadas, bandeja/SO excluyentes, grosor fijo, agarre de seis puntos ni controles anclados a la derecha.
- **Estado técnico:** parche únicamente en la maqueta QML de [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3), pasando a usar `systemIsland.x` y `systemIsland.width` como dependencias reactivas del popup. **Todavía no probado en CachyOS tras la corrección**, ni conectado al catálogo real de aplicaciones.

## 3. Prioridad técnica
**Estabilidad, seguridad, rendimiento, compatibilidad real y accesibilidad preceden a las animaciones y decoración.** Reutilizar componentes de KDE/Plasma/KWin cuando su licencia y API lo permitan. No introducir capas pesadas innecesarias. La base prevista es **Qt 6 / QML / Plasma / KWin**.

## 4. Gobierno de decisiones
El mantenedor del repositorio oficial define y aprueba el comportamiento fundamental. Cualquier persona puede proponer ideas o soluciones, pero **ningún issue ni pull request modifica esta constitución por sí solo**. Una modificación sustancial requiere discusión previa y aprobación explícita del mantenedor, con actualización versionada del Manual Maestro y de las pruebas de aceptación.

## 5. Software libre y contribuciones
El código oficial se publica bajo la **GPL-3.0** indicada en [LICENSE](../LICENSE). Se permiten forks, modificaciones y redistribuciones con las obligaciones de esa licencia. La GPL **no otorga a terceros permisos de escritura** en este repositorio. Las contribuciones son aportes de sus respectivos autores según los términos aplicables; el control de la línea oficial no implica poseer automáticamente derechos sobre todo el código aportado.

## 6. Autoridad documental
En caso de contradicción: (1) esta constitución y requisitos confirmados del [Manual Maestro](MANUAL_MAESTRO.md); (2) decisiones aprobadas para la versión; (3) propuestas no aprobadas; (4) mockups. **Los renders recargados y rechazados no constituyen requisitos.**

## 7. Cambios y control de calidad
Registrar motivo, impactos y pruebas de cada cambio. Favorecer PRs pequeños, revisables y con pruebas. Nadie debe recibir acceso directo a la rama principal solo por colaborar. Configurar reglas de protección de ramas desde GitHub: este documento por sí solo no activa controles técnicos de la plataforma.

**Este documento es una base acordada para el proyecto oficial, no una prohibición de que la comunidad desarrolle forks diferentes.**
