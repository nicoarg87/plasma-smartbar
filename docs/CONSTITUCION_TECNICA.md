# Constitución técnica de Plasma SmartBar
**Estado:** documento rector del proyecto oficial. **Versión:** 1.1 (fase conceptual, islas visuales confirmadas el 14/11/2026).
**Dirección funcional y de diseño:** mantenedor del repositorio oficial [nicoarg87](https://github.com/nicoarg87).
**Manual de especificación:** [Manual Maestro](MANUAL_MAESTRO.md).

## 1. Misión
Construir un complemento libre para **Linux con KDE Plasma 6** que administre ventanas y aplicaciones mediante una barra superior minimalista, previsible y de **grosor constante**. CachyOS es la plataforma inicial de pruebas, no una dependencia exclusiva. La extensión no requiere crear una distribución nueva y no tiene como objetivo GNOME, Cinnamon, Windows o macOS.

## 2. Invariantes no negociables
1. La barra y todos los menús que se **expanden horizontalmente** mantienen idéntica altura. La altura puede configurarse como preferencia del usuario, pero no cambia al maximizar, restaurar, abrir una bandeja o navegar entre ventanas.
2. El botón **SO** muestra aplicaciones/ventanas que ya están abiertas; el lanzador del extremo izquierdo busca programas **instalados**. Son controles diferentes.
3. SO despliega fichas **hacia la izquierda, en una sola fila**. Agrupa por aplicación de manera predeterminada (por ejemplo, tres ventanas Dolphin en una ficha). Se puede desagrupar por configuración.
4. La flecha de bandeja es **izquierda al abrir (◀)** y **derecha al cerrar (▶)**. SO y bandeja **son mutuamente excluyentes**.
5. Cuando una ventana está maximizada, los botones **minimizar, restaurar/maximizar y cerrar** aparecen en la zona derecha de la barra; con ventana normal permanecen en la ventana. Su tamaño y alineación vertical no cambian.
6. Los controles superiores y sus expansiones tienen prioridad de capa sobre la **interfaz de las ventanas maximizadas**, incluidas pestañas de navegador; pueden taparlas **temporalmente**, pero jamás desplazarlas, redimensionarlas o crear otra fila.
7. En **pantalla completa real** (video o videojuego), los controles de escritorio no deben superponerse al contenido.
8. Seleccionar una ventana desde SO la activa y **contrae SO por defecto**; el usuario puede configurar que permanezca abierto. También existen modos de SO contraído, expandido o adaptativo.
9. Los paneles secundarios (calendario, notas, etc.) pueden flotar **debajo** de la barra, sin cambiar su altura. La flecha vertical predeterminada es **↓ para abrir / ↑ para cerrar** y está **dentro de la bandeja**.
10. Elementos accesorios no deben interferir con el cambio de aplicaciones. El reproductor **MPRIS es futuro, no MVP**; cuando exista pertenecerá a la bandeja y se ocultará al contraerla.
11. Los indicadores de escritorios virtuales/monitores son **configurables**, sin ocupar espacio obligatorio permanente.
12. El primer prototipo debe funcionar **sin animaciones**. Los efectos opcionales jamás podrán alterar geometría, foco, accesibilidad ni estabilidad.

## 2.1. Distribución predeterminada en islas — confirmada

- **Isla 1, derecha:** identidad del sistema (botón SO con logo configurable) y flecha de bandeja; controles de ventana de la zona derecha al maximizar, sin desplazar pestañas.
- **Isla 2, izquierda:** lanzador que busca programas instalados.
- **Isla 3, junto al lanzador:** campo de búsqueda visible **opcional y oculto por defecto**.
- **Separación visual por defecto:** solo las islas, sin fondo continuo entre ellas. El usuario puede activar un tema con **fondo continuo/entrelazado** sin modificar geometría ni conducta.
- La minimización con animación tipo **gaveta/ranura temporal de SO** se contempla **únicamente como efecto optativo futuro**, no como requisito del MVP. Su duración objetivo inicial rondaría medio segundo, sujeto a pruebas. La ventana se minimiza igualmente sin efectos.
- **La superposición sobre las pestañas de navegadores maximizados sigue pendiente de validación técnica** y no se considera resuelta por ninguna imagen conceptual.

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
