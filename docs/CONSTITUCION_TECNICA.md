# Constitución técnica de Plasma SmartBar
**Estado:** documento rector del proyecto oficial. **Versión:** 1.3 (orientación superior/inferior aprobada el 14/11/2026; sin implementación).
**Dirección funcional y de diseño:** mantenedor del repositorio oficial [nicoarg87](https://github.com/nicoarg87).
**Manual de especificación:** [Manual Maestro](MANUAL_MAESTRO.md).

## 1. Misión
Construir un complemento libre para **Linux con KDE Plasma 6** que administre ventanas y aplicaciones mediante islas de barra minimalistas, previsibles y de **grosor constante**, configurables **arriba o abajo** de la pantalla. CachyOS es la plataforma inicial de pruebas, no una dependencia exclusiva. La extensión no requiere crear una distribución nueva y no tiene como objetivo GNOME, Cinnamon, Windows o macOS.

## 2. Invariantes no negociables
1. La barra y todos los menús que se **expanden horizontalmente** mantienen idéntico **grosor**. En modo horizontal (superior/inferior), la altura puede configurarse como preferencia del usuario, pero no cambia al maximizar, restaurar, abrir una bandeja o navegar entre ventanas.
2. El botón **SO** muestra aplicaciones/ventanas que ya están abiertas; el lanzador del extremo izquierdo busca programas **instalados**. Son controles diferentes.
3. SO despliega fichas **hacia la izquierda, en una sola fila**. Agrupa por aplicación de manera predeterminada (por ejemplo, tres ventanas Dolphin en una ficha). Se puede desagrupar por configuración.
4. La flecha de bandeja es **izquierda al abrir (◀)** y **derecha al cerrar (▶)**. SO y bandeja **son mutuamente excluyentes**.
5. Cuando una ventana está maximizada, los botones de SmartBar **minimizar, restaurar/maximizar y cerrar** aparecen en la zona derecha de la barra, **en el mismo borde elegido**: arriba si está arriba, **abajo si está abajo**. En ventanas normales siguen existiendo los controles propios de cada aplicación. El tamaño y la alineación respecto de la barra permanecen constantes. El destino exacto de los botones originales de cada aplicación está sujeto a validación técnica y no se presume que KWin pueda trasladarlos universalmente.
6. Las islas y sus expansiones tienen prioridad de capa en el borde horizontal elegido sobre la **interfaz de las ventanas maximizadas**; en modo superior esto incluye las pestañas del navegador, cuya convivencia sigue pendiente de validación. Se puede cubrir contenido temporalmente, pero jamás desplazar pestañas, redimensionar ventanas o crear otra fila.
7. En **pantalla completa real** (video o videojuego), los controles de escritorio no deben superponerse al contenido.
8. Seleccionar una ventana desde SO la activa y **contrae SO por defecto**; el usuario puede configurar que permanezca abierto. También existen modos de SO contraído, expandido o adaptativo.
9. Los paneles secundarios (calendario, notas, etc.) flotan hacia el **interior de la pantalla** (debajo de la barra superior; encima de la inferior), sin cambiar su grosor. La flecha vertical está **dentro de la bandeja**; su iconografía debe adaptarse al borde elegido y verificarse en pruebas de usabilidad.
10. Elementos accesorios no deben interferir con el cambio de aplicaciones. El reproductor **MPRIS es futuro, no MVP**; cuando exista pertenecerá a la bandeja y se ocultará al contraerla.
11. Los indicadores de escritorios virtuales/monitores son **configurables**, sin ocupar espacio obligatorio permanente.
12. El primer prototipo debe funcionar **sin animaciones**. Los efectos opcionales jamás podrán alterar geometría, foco, accesibilidad ni estabilidad.

## 2.1. Distribución predeterminada en islas — confirmada

- **Isla 1, derecha:** identidad del sistema (botón SO con logo configurable), flecha de bandeja y **agarre punteado muy pequeño inmediatamente a la derecha de SO**; los controles de la ventana permanecen todavía más a la derecha al maximizar. El agarre permite reubicar horizontalmente la isla 1; **SO y agarre mantienen posición mientras bandeja/SO expanden su contenido hacia la izquierda**. El agarre no forma parte del menú expandible, no se oculta ni se mueve por su apertura. No desplazar pestañas ni cambiar la altura.
- **Isla 2, izquierda:** lanzador que busca programas instalados.
- **Isla 3, junto al lanzador:** campo de búsqueda visible **opcional y oculto por defecto**.
- **Separación visual por defecto:** solo las islas, sin fondo continuo entre ellas. El usuario puede activar un tema con **fondo continuo/entrelazado** sin modificar geometría ni conducta.
- La minimización con animación tipo **gaveta/ranura temporal de SO** se contempla **únicamente como efecto optativo futuro**, no como requisito del MVP. Su duración objetivo inicial rondaría medio segundo, sujeto a pruebas. La ventana se minimiza igualmente sin efectos.
- **La superposición sobre las pestañas de navegadores maximizados sigue pendiente de validación técnica** y no se considera resuelta por ninguna imagen conceptual.
- **El agarre horizontal es un requisito de diseño confirmado, no una función probada.** Debe ser discreto (tres o cuatro puntos de aspecto arrastrable), pero tener un área de interacción utilizable. Sus límites de movimiento, posición guardada y coordinación con la maximización se validarán en KWin/Wayland; no será obligatorio en la primera prueba v0.1.

## 2.2. Orientación y preparación para extensibilidad — decisión confirmada (14/11/2026)

**Modos oficiales de diseño:**
- **Superior (predeterminado):** las islas 2 y 1 permanecen respectivamente a izquierda y derecha en el borde superior; se conserva la integración superior aprobada y los controles SmartBar de ventanas maximizadas arriba.
- **Inferior (configurable):** las mismas islas mantienen sus funciones y extremos izquierdo/derecho en el borde inferior. **Los controles SmartBar de minimizar, restaurar/maximizar y cerrar para la ventana maximizada también deben estar abajo, junto a la isla 1, nunca separados arriba de ella.**
- En ambos modos, SO y bandeja siguen extendiéndose **horizontalmente hacia la izquierda en una fila**, con altura invariable; el agarre punteado está **inmediatamente a la derecha de SO**, no se desplaza por abrir la bandeja y permite el ajuste horizontal deliberado de isla 1.
- Paneles secundarios flotan **hacia adentro** de la pantalla y no aumentan el grosor.

**Compatibilidad y límite técnico:** ubicar **controles funcionales de SmartBar** abajo es un objetivo confirmado; **mover o suprimir las decoraciones originales que cada aplicación dibuja arriba no se considera resuelto ni garantizado**. KWin/Wayland, ventanas Qt/GTK y navegadores con decoración propia requieren pruebas, sin destruir ni ocultar funciones indispensables de la aplicación. Si algún tipo de ventana no permite una integración segura y coherente, documentar el bloqueo y pedir decisión funcional antes de cambiar el requisito o introducir soluciones intrusivas.

**Lados izquierdo/derecho:** quedan **fuera de los modos oficiales iniciales**. Se permite investigación/experimentación posterior y forks que lo implementen, sin compromiso de que el diseño vertical funcione de inmediato. La arquitectura debe **separar orientación, anclaje y disposición de la lógica de tareas/ventanas**, evitando codificar exclusivamente coordenadas superiores; no sacrificar estabilidad ni rendimiento del modo horizontal por esto.

**Orden de ejecución:** implementar y probar primero el modo superior y sus reglas vigentes; planificar la compatibilidad inferior desde el diseño del código, habilitarla tras pruebas específicas. No introducir modo inferior o lateral como funcionalidad «probada» solo por existir en Plasma una opción de mover paneles.

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
