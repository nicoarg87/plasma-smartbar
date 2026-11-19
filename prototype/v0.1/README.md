# Plasma SmartBar Islands — Prototipo visual v0.1 (rama experimental)

**Estado: prototipo QML preliminar YA probado parcialmente en CachyOS con SO, bandeja, arrastre de isla 1 y retorno al desmaximizar simulados.** No es una versión instalable ni un reemplazo de tu panel. Una corrección reciente del menú de retorno todavía debe verificarse en el equipo. Relacionado con el [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).

## Qué se puede probar en esta etapa

- Dos **islas visualmente separadas**. Izquierda: lanzador de muestra. Derecha: botón SO y bandeja.
- Pulsar **SO**: aparecen fichas ficticias de Dolphin, Konsole y Brave **hacia la izquierda**, todas en una sola fila.
- Pulsar una ficha: SO se contrae automáticamente (solo cambia el estado de la demo, **no activa ventanas reales**).
- Pulsar **◀**: se expande una bandeja de **muestra** con Wi-Fi, Audio y Bluetooth; abrir bandeja cierra SO, y viceversa.
- El botón **SO** y el agarre de **seis puntos (2 × 3)** conservan su posición horizontal mientras crecen las fichas hacia la izquierda.
- El **agarre de seis puntos funciona en la demostración**: se puede arrastrar la isla 1 horizontalmente, con límites de desplazamiento. Está inmediatamente a la derecha de SO y no se mueve por desplegar bandeja/SO.
- **Clic en el agarre de seis puntos** abre el menú de prueba. Activá «Simular ventana maximizada» para mostrar botones ficticios `− □ ×` en **un grupo separado, anclado al extremo derecho**. **Esos botones NO se mueven cuando arrastrás isla 1**. Siguen deshabilitados y no controlan ventanas reales.
- **Alinear isla 1 a la derecha:** nueva casilla del menú, **marcada por defecto**. Al arrastrar isla 1 con los seis puntos, se **destilda automáticamente** y la isla permanece donde la soltaste; **tildarla de nuevo** la devuelve inmediatamente a la posición de referencia (junto a los controles de ventana simulados, cuando están visibles). Esta casilla representa la alineación actual y es independiente de la preferencia de retorno al desmaximizar.
- Al **desactivar la maximización simulada**, la isla 1 **vuelve automáticamente al extremo derecho por defecto**. La preferencia **«Volver a la derecha al desmaximizar»** se puede desactivar desde el menú o desde la configuración del widget. **Al volver a activarla con un clic, la isla también regresa inmediatamente al extremo derecho**, incluso si la simulación sigue maximizada. Para moverla directamente sin modificar la preferencia usá **«Mover isla 1 a la derecha AHORA»**. Se declara en la configuración KConfig de Plasma, aunque su persistencia efectiva en `plasmoidviewer` se comprobará en CachyOS.
- **Arrastrar NO obliga al regreso inmediato**, esté maximizada o no la simulación. La preferencia de retorno actúa en la transición de **maximizada a no maximizada**; el nuevo control de alineación funciona aparte.
- La isla 3 (buscador persistente) no aparece. La maximización **es una simulación**; aún no leemos el estado de ventanas reales mediante KWin.
- El grosor visual de la franja sigue fijo; **sin animaciones ni MPRIS**.

## Prueba alternativa: ventana Qt redimensionable (14/11/2026)

**Segundo resultado real comunicado por el mantenedor:** aunque se incorporó `Layout.fillWidth: true`, **agrandar/maximizar `plasmoidviewer` siguió sin expandir la representación de SmartBar**. Por tanto, esa primera corrección por sí sola **no ha resuelto** la prueba dentro del visor. No repetirla a ciegas ni afirmar que el contenedor de Plasma necesariamente entrega toda la anchura.

### Ensayo recomendado, sin riesgo para tu panel

El código se dividió en un **componente compartido** `package/contents/ui/SmartBarContent.qml` (con todas las islas, SO, bandeja, agarre, controles de muestra y lógica de estado). El envoltorio `package/contents/ui/main.qml` lo utiliza dentro del plasmoide. Y `preview_redimensionable.qml` reutiliza **ese mismo componente** en una ventana Qt Quick normal, donde su ancho está enlazado explícitamente a los bordes de la ventana.

En **Fish**, estando en `~/plasma-smartbar`, ejecutá:

```fish
git pull
bash prototype/v0.1/probar_ancho.sh
```

El script usa `qml6` o `/usr/lib/qt6/bin/qml` de Qt 6 (normalmente disponible mediante `qt6-declarative` en CachyOS/Arch), **sin instalar nada**. Si falta, muestra un diagnóstico.

**Comprobaciones:**
1. Abrir la ventana independiente: isla 2 a la izquierda e isla 1 a la derecha. Solo aparece una superficie de fondo del **visor de prueba**; no conecta visualmente las islas.
2. Agrandar/maximizar/restaurar la ventana: el número «Ancho del contenido» debe cambiar; SO y los controles de muestra deben seguir el extremo derecho.
3. Activar «Simular ventana maximizada» y arrastrar isla 1: controles `− □ ×` se quedan al extremo derecho. SO y bandeja continúan expandiendo hacia la izquierda, a una sola fila.
4. Cerrar con la X, sin dejar nada instalado ni cambiar el panel real.

Si esta ventana responde al ancho pero `plasmoidviewer` no, sabremos que **la interfaz compartida puede adaptarse** y que el siguiente problema está en cómo el contenedor de `plasmoidviewer` dimensiona el applet (aún por investigar). Si tampoco responde, revisaremos el componente QML. **La ventana Qt no acredita todavía la integración con un panel real ni con KWin/Wayland.**

### Estado
**Código escrito y verificado por lectura estática, pero NO ejecutado en CachyOS después de refactorizar.** El [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) sigue siendo borrador. `probar.sh` sigue disponible para la prueba original con `plasmoidviewer`.

## Ancho adaptable del visor — parche en espera de prueba (14/11/2026)

**Reporte del mantenedor:** la interfaz ocupaba aproximadamente el ancho inicial de la maqueta y **no llegaba al extremo derecho** de `plasmoidviewer`; al maximizar o redimensionar la ventana del visor, la isla derecha **no seguía el nuevo borde**. Es un comportamiento incorrecto para el diseño final; puede existir además un margen propio del visor, que aún hay que comprobar.

**Corrección preliminar, NO PROBADA aún:** se agregó `Layout.fillWidth: true` a la raíz `PlasmoidItem`. `Layout.preferredWidth: 960` queda **solo como sugerencia de tamaño inicial**, no como ancho máximo. Los elementos de isla 2 se anclan a la izquierda; SO, agarre y controles a la derecha del **ancho real que el contenedor entregue al plasmoide**. La altura se mantiene fija en 48 unidades lógicas. Para diagnosticar, la consola imprime `SmartBar v0.1: ancho del contenido = …` cada vez que el plasmoide recibe una anchura distinta.

**Prueba específica:**
1. Abrir la demo con el script.
2. Comprobar la posición de SO en el extremo derecho del **contenido disponible**, teniendo en cuenta posibles márgenes internos propios de Plasmoidviewer. **No hay que dibujar una barra de fondo que una visualmente las islas.**
3. Cambiar varias veces el ancho del visor (agrandar, maximizar, restaurar). SO y controles deberían **seguir el borde derecho** e isla 2 conservar el izquierdo; la altura y el estado de SO/bandeja no deberían modificarse.
4. Mirar Konsole: los mensajes `ancho del contenido` deberían cambiar con el redimensionamiento. Si **no cambian**, puede que Plasmoidviewer imponga un ancho fijo al applet. Compartir esa salida y una captura: no considerar resuelto el problema ni atribuirlo exclusivamente a QML.
5. Probar el arrastre de seis puntos y la simulación de maximización tras cambiar ancho, comprobando que las islas no queden fuera de pantalla.

`plasmoidviewer` **no equivale** a una barra de pantalla real y tiene controles y márgenes propios; este ensayo no demuestra todavía integración a pantalla completa ni KWin/Wayland. El panel de escritorio del usuario no debe reemplazarse.

## Cómo probarlo de manera reversible en CachyOS

1. Abrí **Konsole** y, si todavía no lo tenés, instalá la herramienta oficial para probar widgets de Plasma 6:

   ```bash
   sudo pacman -S --needed plasma-sdk
   ```

2. Descargá **solamente la rama experimental**, sin tocar tu configuración de Plasma:

   ```bash
   git clone --branch prototype/v0.1-islas-so --single-branch https://github.com/nicoarg87/plasma-smartbar.git
   cd plasma-smartbar
   ```

3. Ejecutá la prueba:

   ```bash
   bash prototype/v0.1/probar.sh
   ```

   Se abre una **ventana independiente** de `plasmoidviewer`, no una barra colocada en tu escritorio. La cerrás con **X** como cualquier ventana.

4. Si ya descargaste esta rama antes, en la carpeta del proyecto hacé `git pull` y repetí el paso 3.

**Importante:** no ejecutes `plasmashell --replace`, no agregues este widget al panel y no borres el panel actual. El script no usa `sudo`, no instala software ni accede a ventanas reales. **Solo si modificás una preferencia dentro de la demostración**, Plasma puede guardarla en su sistema normal de configuración del widget; no reemplaza ni configura el panel que usás. El único paso que puede modificar paquetes es la instalación de `plasma-sdk`, que el usuario hace explícitamente si lo necesita.

## Pruebas manuales que necesitamos registrar

| Prueba | Resultado esperado |
|---|---|
| Ventana inicial | Isla 2 izquierda, isla 1 derecha; isla 3 ausente |
| Pulsar SO | Aparecen tres fichas a la izquierda, SO permanece a la derecha |
| Pulsar Dolphin | Se ocultan las fichas; Dolphin real permanece igual |
| Pulsar flecha ◀ | Se muestra la bandeja simulada y se oculta SO expandido |
| Abrir SO con bandeja expandida | Se contrae automáticamente la bandeja |
| Repetir muchas veces | No aparece segunda fila ni cambia el grosor |
| Mover isla 1 con la maximización simulada activada | **Los botones `− □ ×` permanecen fijos en el extremo derecho**, mientras SO y agarre se mueven horizontalmente; no cambia el grosor |
| Arrastrar `⋮` horizontalmente | La isla 1 se mueve a izquierda/derecha dentro de límites seguros; SO y agarre permanecen juntos |
| Clic en el agarre de seis puntos de seis puntos, activar «Simular ventana maximizada» | Se ven botones ficticios `− □ ×` a la derecha; el agarre funciona sin cambiar la altura |
| Arrastrar en maximizada simulada y luego desactivar | Por defecto, la isla regresa al extremo derecho |
| Arrastrar con «Alinear isla 1 a la derecha» marcada | La casilla se destilda sola y la isla permanece desplazada al soltar los seis puntos; no es necesario destildarla antes |
| Marcar «Alinear isla 1 a la derecha» tras arrastrar | La isla vuelve inmediatamente junto a los controles fijos si están visibles; si no hay simulación maximizada, al extremo derecho de la franja |
| Desmarcar «Volver a la derecha al desmaximizar» y luego desmaximizar | La isla **conserva su posición visual exacta** mientras desaparecen los controles ficticios. La posición interna se recalcula para compensar el ancho liberado; solo se ajusta si llega a un límite de pantalla |
| Volver a marcar «Volver a la derecha al desmaximizar» | **La isla retorna inmediatamente** a su posición predeterminada, también con la simulación maximizada; los controles `− □ ×` quedan fijos |
| Pulsar «Mover isla 1 a la derecha AHORA» | La isla retorna de inmediato sin cambiar la preferencia guardada |
| Abrir SO/bandeja después de desplazar isla | SO y agarre no saltan de posición; solo aparecen fichas hacia la izquierda |
| Reabrir prueba tras guardar opción | Comprobar si la preferencia se conserva en `plasmoidviewer` y registrar resultado; aún no probado |

Anotá la versión de Plasma (`plasmashell --version`), distribución, sesión (Wayland/X11) y cualquier mensaje de error de Konsole. Si no abre, **no modifiques tu panel**: compartí el error en el [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).

## Qué falta (NO implementado)

- Enumerar ventanas reales, agruparlas, activarlas o minimizarlas con KWin.
- Lanzar aplicaciones instaladas desde isla 2.
- Controles de minimizar/restaurar/cerrar en ventanas maximizadas.
- **Arrastre de isla 1 conectado a ventanas reales de KWin** y detección de maximización/desmaximización automática. El arrastre actual solo mueve la maqueta QML en la ventana de ensayo; la configuración KConfig está añadida pero aún debe verificarse su persistencia.
- Apertura de paneles secundarios y bandeja real.
- Modo inferior; compatibilidad con aplicaciones y superposición de pestañas.
- Pruebas reales en CachyOS (el código fue redactado desde ChatGPT y debe ejecutarse allí para validar QML).

## Estructura

```text
prototype/v0.1/
├── probar.sh
├── README.md
└── package/
    ├── metadata.json
    └── contents/
        ├── config/
        │   ├── config.qml
        │   └── main.xml
        └── ui/
            ├── IslandButton.qml
            ├── configGeneral.qml
            └── main.qml
```

Fuentes de referencia: [Crear un plasmoide de Plasma 6](https://develop.kde.org/docs/plasma/widget/setup/) y [probarlo mediante plasmoidviewer](https://develop.kde.org/docs/plasma/widget/testing/).

**La constitución y el manual maestro conservan precedencia.** Esta demostración no aprueba cambios funcionales.

## Si descargaste una versión anterior de esta rama

Desde la carpeta `plasma-smartbar` ejecutá `git pull` antes de abrir la prueba, para que `⋮` deje de estar deshabilitado. Si todavía no clonaste, los comandos de arriba ya obtienen la versión actualizada.

**No se prometen todavía tiempos de entrega ni compatibilidad confirmada:** primero necesitamos ejecutar QML con `plasmoidviewer` en el equipo real.


## Nota de la corrección sobre el retorno automático — 14/11/2026

El mantenedor observó en CachyOS que, con **«Simular ventana maximizada»** y el retorno automático marcados, la isla no se desplazaba a la derecha por el mero hecho de activar la casilla. La maqueta anterior **solo aplicaba el regreso al desmaximizar**, lo que generaba una expectativa confusa. El menú ahora separa una **preferencia** (que actúa al desmaximizar y regresa inmediatamente al activarla) de una **acción instantánea** («Mover isla 1 a la derecha AHORA»). Todavía falta probar esta corrección en CachyOS: no se puede afirmar que el comportamiento nuevo funcione hasta repetir el ensayo. Las ventanas reales siguen sin estar conectadas a KWin.


## Actualización de alineación de isla 1 — 14/11/2026

**Función aprobada y codificada en rama experimental, sin nueva prueba real todavía:** el control «Alinear isla 1 a la derecha» comienza tildado. Un **arrastre manual** destilda esa alineación y deja la isla en el lugar elegido (sin obligar a usar antes el menú). Al tildar de nuevo se alinea de inmediato con el borde de referencia (a la izquierda de los botones `− □ ×` cuando se simula maximización). Esto es **distinto** de la preferencia global persistente «Volver a la derecha al desmaximizar»: esa última sigue activada por defecto y se aplica al **desmaximizar**, no cada vez que se suelta el agarre. El posicionamiento guardado por aplicación (Steam/Dolphin) permanece aprobado, pero aún no implementado.


## Corrección de salto horizontal al desmaximizar sin retorno — 14/11/2026

**Informe del mantenedor:** una vez probada la alineación contextual, al desactivar **«Volver a la derecha al desmaximizar»** y luego destildar **«Simular ventana maximizada»**, isla 1 se movía ligeramente hacia la derecha sin haberlo ordenado. Esto ocurría porque se liberaba el ancho reservado a los controles `− □ ×` pero el valor interno del desplazamiento no se compensaba.

**Corrección aplicada solo en la rama experimental:** antes de modificar la simulación, guardar la posición horizontal visible (margen derecho = desplazamiento manual + espacio de controles); cuando desaparecen los controles con **retorno desactivado**, recalcular el desplazamiento interno para mantener ese margen visible. Si el usuario activó el retorno al desmaximizar, conservar la conducta aprobada de regresar a la derecha. En cualquier caso, respetar los límites de pantalla.

**Prueba pendiente en CachyOS:** con ventana simulada maximizada, mover isla 1 al centro, **destildar «Volver a la derecha al desmaximizar»** y después **destildar «Simular ventana maximizada»**. Los botones ficticios deben desaparecer **sin que isla 1 cambie de lugar**. Repetir con el retorno tildado: isla 1 debe regresar a la derecha. Esta prueba no demuestra compatibilidad con ventanas reales de KWin.


## Corrección inversa al maximizar sin alineación manual (14/11/2026)

**Fallo comunicado por el mantenedor:** con todas las casillas desmarcadas, desplaza isla 1 hacia el centro o un poco a la derecha y activa «Simular ventana maximizada». Isla 1 se corre a la izquierda sin que se haya arrastrado: se sumaba el espacio reservado para los controles `− □ ×` al margen visual, sin compensar el desplazamiento manual. Es el inverso del salto al desmaximizar detectado antes.

**Parche en `SmartBarContent.qml`, aún sin probar en CachyOS:** `setPreviewMaximized()` guarda el margen derecho visual anterior y recalcula el desplazamiento en **ambas** transiciones. Si «Alinear isla 1 a la derecha» está **desmarcada**, conserva la posición visual al maximizar **si deja suficiente espacio para los controles**. Si la isla invadiría `− □ ×`, se la aparta **solo lo necesario**, nunca se mueve el grupo de controles fijos. Si «Alinear» está marcada, se ubica normalmente junto a esos controles. Al desmaximizar, se sigue respetando la preferencia separada de retorno.

**Prueba recomendada usando la ventana Qt independiente:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Con «Simular ventana maximizada» desactivada, mover **isla 1** manualmente hacia el centro.
2. Comprobar que «Alinear isla 1 a la derecha» quedó desmarcada. Desactivar también «Volver a la derecha al desmaximizar».
3. Activar «Simular ventana maximizada»; **isla 1 debe quedarse en el mismo lugar visual** si no invade los controles; los botones aparecen fijos a la derecha.
4. Desactivar la simulación: la isla debe seguir en el mismo lugar.
5. Como control, poner la isla **muy cerca** de la derecha antes de maximizar: solo allí es correcto que se mueva mínimamente a la izquierda para dejar libres los controles.
6. Repetir con «Alinear isla 1 a la derecha» marcada: debe quedar contigua al grupo fijo.

**Estado:** código corregido y revisión estática pendiente de validación real. No se administran ventanas reales ni se altera el panel instalado.

## Primer diagnóstico de ventanas reales — SOLO LECTURA (14/11/2026)

Esta es **una prueba nueva, sin resultados de CachyOS todavía**. KDE Plasma 6 publica un modelo QML de tareas (`TaskManager.TasksModel`, módulo `org.kde.taskmanager 0.1`), con información sobre nombres de aplicación, ventanas agrupadas y estado de maximización. Se preparó una **ventana independiente** para verificar que el módulo está disponible y detecta aplicaciones reales sin ninguna operación de control.

Ejecutá desde **Fish**:

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ventanas.sh
```

**Resultados esperados:** aparece una ventana titulada «Plasma SmartBar — ventanas reales (solo lectura)» con una lista que muestra las apps abiertas y sus estados. Abrí Dolphin o Konsole por tu cuenta y comprobá si aparece una fila nueva, o cambia la agrupación. Cerrá esa aplicación con sus controles habituales y comprobá que la fila desaparece. **La lista no tiene botones para activar, cerrar, maximizar o minimizar nada.**

**Si falla:** copiá la salida de Konsole, especialmente si aparece `module "org.kde.taskmanager" is not installed` o un error de tipos. La compatibilidad del import `TasksModel` ejecutado mediante `qml6`/Qt 6 **todavía no está probada en CachyOS**, aunque el modelo esté documentado en KDE. No instales dependencias al azar, ni uses `plasmashell --replace` para esta prueba. El visor anterior `probar_ancho.sh` sigue intacto.

**Alcance:** solamente detecta y enumera. La ventana independiente de Qt no es todavía SO con fichas reales, ni demuestra coexistencia con las islas dentro del panel Plasma. El siguiente paso, **solo si esta prueba funciona**, es alimentar las fichas de SO con el modelo de tareas, manteniendo las acciones de control deshabilitadas al principio.

**Referencias:** https://github.com/KDE/plasma-workspace/blob/master/libtaskmanager/tasksmodel.h , https://github.com/KDE/plasma-workspace/blob/master/libtaskmanager/abstracttasksmodel.h , y [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).


## SO de dos gestos e isla 2 ocultable — PRUEBA NUEVA (14/11/2026)

**Decisión funcional confirmada por el mantenedor:** isla 2 **visible por defecto**, pero se puede ocultar con clic derecho. SO permite usar un lanzador desde isla 1 mediante pulsación sostenida (< 0,5 s). La ocultación automática quedó **como idea futura sin comportamiento aprobado**.

**Implementado solo como demostración QML, aún sin probar en CachyOS después de estos cambios:**

- **Clic breve en SO:** abre/cierra las **ventanas ficticias** de Dolphin, Konsole, Brave, como antes.
- **Mantener SO ~400 ms:** abre un **lanzador flotante de muestra** con búsqueda y nombres de ejemplo. **NO enumera ni ejecuta apps instaladas**; no equivale al lanzador real de KDE. La pulsación sostenida no debe generar un clic breve al soltar.
- **Clic derecho sobre isla 2 (diamante a la izquierda):** menú «Ocultar isla 2». No hay autocierre ni autohide temporal.
- **Con isla 2 oculta, clic derecho en SO:** «Mostrar isla 2» para recuperarla. Ese mismo menú incluye «Abrir lanzador de aplicaciones (muestra)» como alternativa al gesto sostenido. La tecla Menú contextual enfocando SO debe ofrecer acceso alternativo.
- **Persistencia:** `showLauncherIsland=true` en KConfig para el plasmoide; **sin comprobar aún** si el visor conserva la elección entre sesiones. En `probar_ancho.sh` la preferencia es **solo de la sesión**, no se guarda en disco.
- **Exclusividad:** abrir el lanzador cierra SO y bandeja; grosor y anclajes siguen fijos. La isla 2 oculta no reserva espacio para los límites de desplazamiento del agarre.

**Prueba sin instalar paneles:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Clic corto SO → observar fichas de ventanas **simuladas**. Clic SO para contraer.
2. Mantener SO unos 0,4 s → debe aparecer el menú **«Aplicaciones (simulación)»** debajo de la barra. Soltar → no deben abrirse las fichas de ventanas.
3. Clic derecho sobre isla 2 → «Ocultar isla 2». Debe desaparecer solo esa isla; SO y agarre no se mueven.
4. Clic derecho en SO → «Abrir lanzador de aplicaciones (muestra)» y «Mostrar isla 2». Seleccionar «Mostrar isla 2» debe restaurar el botón izquierdo.
5. Verificar que el menú flotante no aumente la altura de las islas y que bandeja/SO sigan excluyéndose. Si aparece un error de QML, conservar el texto de Konsole.

**Pendiente:** sustituir las apps de ejemplo por la lista real de aplicaciones **instaladas** e implementar el lanzamiento efectivo (en una etapa posterior, con pruebas seguras). La prueba de ventanas **reales** en `probar_ventanas.sh` sigue disponible, separada de esta demostración.

## Corrección: el lanzador flotante sigue a isla 1 (14/11/2026)

**FALLO OBSERVADO por el mantenedor en CachyOS (con captura):** tras arrastrar **isla 1 al centro** y mantener presionado SO, el menú «Aplicaciones (simulación)» aparecía cerca del extremo derecho de la ventana, **desconectado de isla 1**. La interacción de pulsación sostenida sí abrió el menú, pero su posición horizontal no siguió el arrastre.

**CAUSA identificada:** la posición `x` del `QQC2.Popup` se calculaba mediante `soButton.mapToItem(root, 0, 0).x` dentro de un enlace QML. Ese cálculo no hacía explícita la dependencia de la coordenada horizontal del contenedor arrastrable, por lo que la posición del menú podía quedar desactualizada después de mover la isla.

**PARCHE EN CÓDIGO (no probado aún en CachyOS):** ahora el menú se centra **debajo de la posición actual de isla 1** mediante `systemIsland.x` y `systemIsland.width`, propiedades que reaccionan a arrastre y cambios de tamaño. Se limita su `x` al ancho útil de la ventana, evitando que quede fuera de pantalla. No se modifican el largo de la pulsación (400 ms), la lógica del clic corto, la altura constante ni los botones fijos.

**PRUEBA:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Con la ventana Qt abierta, mantené SO 0,4 s **sin mover isla 1**: el menú debe aparecer justo debajo de esa isla a la derecha.
2. Cerrá el menú (Esc), arrastrá **isla 1 al centro** con los seis puntos y mantené SO: el menú debe abrirse **debajo de la isla en el centro**, no en el extremo derecho.
3. Con el menú visible, mové la isla con los seis puntos si la interacción lo permite: el menú debe acompañarla horizontalmente. Si el foco o un clic fuera cierra el menú, no confundir ese cierre con el error de anclaje.
4. Probá también con isla 1 cerca del extremo izquierdo y después ampliá/restaurá la ventana Qt: el menú no debe quedar fuera del área visible.
5. Verificá que clic corto SO sigue mostrando ventanas de muestra y que el grupo de controles de ventana no acompaña al agarre.

**Estado:** el parche existe únicamente en PR #3 (borrador), **pendiente de retest en CachyOS**. El menú aún presenta aplicaciones ficticias y no ejecuta programas. No tocar el panel KDE instalado.

## Soledad y Malvina: coexistencia de expansiones y autocontracción independiente (14/11/2026)

**CAMBIO CONFIRMADO POR EL MANTENEDOR:** isla 1 se llama **Soledad**, isla 2 **Malvina** (por ahora se conserva el texto «SO» del botón). El nombre visible actual del programa es Plasma SmartBar Islands; el repositorio mantiene su ruta técnica. **SO y bandeja ya NO deben excluirse automáticamente**: si las dos expansiones caben horizontalmente, permanecen visibles las dos hasta que el usuario decida cerrarlas. Si falta espacio, la expansión pedida más recientemente prevalece y se contrae la anterior. El ancho se mide respecto del lugar actual de Soledad, la visibilidad de Malvina y la reserva de controles `− □ ×`.

**Recuperación accesible:** si ocultaste Malvina por clic derecho, mantené pulsado **SO** para abrir el menú flotante. Verás un botón **«Mostrar Malvina (isla 2)»**. Un clic la restaura, sin necesidad de abrir el menú de clic derecho de SO.

**Dos ajustes separados de autocontracción:** en el **menú de los seis puntos → «Configuración de autocontracción»**:
- **«SO: contraer tras elegir ventana»**, activado por defecto (respeta la conducta que ya estaba confirmada). Si lo desactivás, tocar una ficha simulada de SO deja las fichas abiertas.
- **«Bandeja: contraer tras usar icono»**, desactivado por defecto. Si lo activás, tocar cualquier icono **de muestra** de bandeja hace que esa expansión se contraiga. No se cambia Wi-Fi, audio ni Bluetooth del equipo.
Las opciones se configuran por separado. La **selección de una ficha/icono** es el disparador de esta primera prueba: no se introducen temporizadores ni cierre por inactividad. Abrir una expansión no dispara la autocontracción de la otra mientras haya lugar. Si no entra todo, la regla de espacio manda.

**Estado del código:** lógica programada en `SmartBarContent.qml`, KConfig `autoCollapseSO=true` y `autoCollapseTray=false` declarados para la vista plasmoide; en la vista Qt independiente se mantienen solo durante la sesión. **Todavía NO probado en CachyOS después de estas modificaciones.** No se probó con ventanas o bandeja reales.

### Prueba segura en Fish

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. En una ventana Qt suficientemente ancha, clic breve SO para desplegar fichas; después flecha para desplegar la bandeja. **Deben verse ambas** en una sola fila, sin que el agarre ni SO se desplacen.
2. Reducí el ancho o mové Soledad hacia la izquierda hasta que no quepan ambas y repetí. **La última expansión solicitada debe permanecer abierta y la anterior contraerse**, sin salirse de pantalla.
3. Abrí con SO las fichas; tocá Dolphin de muestra con la autocontracción SO tildada (se contrae), desmarcá la opción en el menú de los seis puntos y repetí (no se contrae).
4. Abrí la bandeja, tocá Wi-Fi de muestra con autocontracción desactivada (permanece); activá su opción y repetí (se contrae). **No hay acciones reales**.
5. Ocultá Malvina con clic derecho en su botón. Mantené SO unos 400 ms; desde el menú flotante elegí **«Mostrar Malvina (isla 2)»** y comprobá que reaparece de inmediato.
6. Comprobá el arrastre de los seis puntos, el menú flotante debajo de Soledad y los controles de ventana fijos.

Si falla la ejecución, conservá el texto de Konsole. El prototipo es una ventana independiente y **no reemplaza el panel de KDE**.


### Indicadores de diagnóstico para la prueba de convivencia (14/11/2026)

Se añadió **solo a `preview_redimensionable.qml`**, no a la barra que ejecutará Plasma, una lectura en la parte inferior de la ventana Qt: estado de **SO**, **bandeja**, visibilidad de **Malvina**, preferencias de **autocontracción**, **ancho de Soledad** frente al **espacio horizontal disponible**, y **última expansión solicitada**. Los valores se actualizan con los estados QML y permiten identificar por qué la lógica decide contraer el grupo anterior cuando falta ancho.

**Qué verificar en CachyOS:** con ventana de prueba ancha, abrir SO y bandeja; el indicador debe decir «SO abierto · bandeja abierta», con ancho de Soledad **menor o igual** al disponible. Luego reducir el ancho de la ventana o arrastrar Soledad hasta que ambas no entren: el indicador debe mostrar únicamente el grupo más recientemente expandido. Mantener la autocontracción desactivada en ambas opciones para aislar esta prueba de la regla de falta de espacio.

**Limitación:** es diagnóstico de la **maqueta con fichas de muestra**, todavía no comprobado después de publicarlo. No permite concluir compatibilidad con bandeja real, controles de KWin o contenido de Plasma. Si los números no cambian o aparece superposición, guardar captura o texto de Konsole. La banda de indicadores bajo la barra **no forma parte del diseño final**.

## Separador entre SO/bandeja y lanzador bajo Malvina — nueva prueba (14/11/2026)

**PRUEBA ANTERIOR SUPERADA EN CACHYOS:** el mantenedor confirmó que la simultaneidad de las expansiones **SO y bandeja** ya funciona como esperaba en la vista Qt. Reportó después dos detalles: faltaba una distinción visual entre sus iconos, y al pulsar **Malvina**, el lanzador aparecía lejos, bajo **Soledad**.

**IMPLEMENTADO, SIN RETEST EN CACHYOS:** `SmartBarContent.qml` dibuja un **separador vertical fino** entre las fichas de bandeja y SO **solo cuando ambos grupos están expandidos**. El separador ocupa ancho real de la fila (entra en el cálculo de colisión), no modifica grosor ni el agarre.

**Lanzador desde la isla correcta:** al pulsar Malvina (lado izquierdo), se abre **debajo de Malvina**; manteniendo SO ~400 ms o usando su menú contextual, aparece **debajo de Soledad**, incluso si se movió con los seis puntos. Ambos accesos usan un único popup compartido que cambia su **origen explícito** (`malvina` o `so`) y limita la posición a los bordes de la ventana. Abrirlo desde Malvina deja abiertas las expansiones de Soledad si la persona las había dejado desplegadas; abrirlo desde SO conserva la regla anterior de cerrar temporalmente las expansiones de ese sector.

**Prueba sin riesgo para el panel instalado:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. En ventana ancha, desplegá primero SO y luego bandeja. Debe aparecer **una línea delgada entre los iconos de bandeja y las fichas de SO**. Contraé uno: la línea debe desaparecer.
2. **Clic en Malvina (M, extremo izquierdo):** el menú «Aplicaciones (simulación)» debe aparecer **abajo a la izquierda**, debajo de M, no debajo de SO. El menú es de muestra, no lanza aplicaciones.
3. Cerrá el menú con Esc, mové **Soledad al centro** con los seis puntos y mantené SO ~400 ms: el lanzador debe aparecer debajo de Soledad, no debajo de Malvina ni del borde derecho original.
4. Dejá SO y bandeja abiertos, hacé clic en Malvina: el menú flotante debe mostrarse **debajo de Malvina** sin cerrar inesperadamente las fichas de Soledad.
5. Probá una ventana más estrecha o mové Soledad para comprobar que el separador participa en el cálculo de espacio y que se contrae el grupo anterior si ya no entran ambos.

**Pendiente:** ejecución en CachyOS, persistencia de preferencias y reemplazo de las fichas/menús ficticios por datos KDE reales. No se instaló ni fusionó la barra. [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) sigue borrador.

## Corrección: segundo clic en Malvina cierra su lanzador (14/11/2026)

**BUG OBSERVADO EN CACHYOS POR EL MANTENEDOR:** tras hacer clic en **Malvina (isla 2)** para abrir el lanzador flotante, un **segundo clic en Malvina no lo cerraba**. El comportamiento esperado es apertura/cierre con clics alternados desde el mismo botón.

**CAUSA IDENTIFICADA EN CÓDIGO:** la política `QQC2.Popup.CloseOnPressOutside` cerraba el popup ya al *presionar* Malvina (fuera del cuadro emergente). Luego el handler `onClicked` llamaba a `openInstalledLauncher()` y **lo reabría**. La falta de un caso explícito para cerrar el mismo lanzador agravaba el efecto.

**CORRECCIÓN PUBLICADA, AÚN NO PROBADA EN CACHYOS:** `openInstalledLauncher(source)` distingue si el popup está visible **y fue abierto desde ese mismo origen**: en ese caso llama a `close()` y sale, sin abrirlo nuevamente. `closePolicy` pasa a `CloseOnEscape | CloseOnPressOutsideParent`: Malvina está dentro del padre `root`, así que su pulsación llega al botón; clic fuera del área de la barra y Esc siguen cerrando. El cambio conserva el único popup compartido con SO y sus dos posiciones ancladas.

**Prueba (Fish):**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Clic Malvina → menú aparece **debajo de Malvina**.
2. Segundo clic Malvina → **menú desaparece**. Tercer clic → reaparece.
3. Con menú abierto desde Malvina, hacer clic fuera de la barra o pulsar Esc → se cierra; otro clic en Malvina debe abrirlo una sola vez.
4. Mantener SO unos 400 ms con Soledad al centro → abre menú bajo Soledad como antes; cuando está abierto, clic en Malvina cambia el origen y muestra el menú bajo Malvina, sin cerrar fichas SO/bandeja por una acción no solicitada.
5. Comprobar que el separador entre SO/bandeja, agarre y controles fijos no se alteren.

**Alcance:** interfaz QML de simulación, sin ejecutar aplicaciones reales ni modificar panel de KDE. Código revisado estáticamente; **validación final pendiente del usuario**.

## Corrección: mantener SO y bandeja visibles al abrir lanzador desde SO (14/11/2026)

**BUG OBSERVADO POR EL MANTENEDOR EN CACHYOS:** con SO expandido y bandeja expandida, mantener presionado el botón SO unos 400 ms abría correctamente el lanzador flotante bajo Soledad, pero **contraía automáticamente ambas expansiones horizontales**. El usuario pidió que los tres contenidos puedan coexistir sin que el lanzador provoque cierres.

**CAUSA:** `openInstalledLauncher(source)` ejecutaba `soExpanded = false` y `trayExpanded = false` cuando el origen era `so` (una antigua regla de exclusividad). **PARCHE IMPLEMENTADO, AÚN NO RETESTEADO:** se eliminó ese cierre forzado para ambos orígenes. Se conserva el comportamiento de posición del popup: SO → debajo de Soledad, Malvina → debajo de Malvina; Malvina sigue abriendo/cerrando con clics alternados.

**Prueba segura en Fish:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Usá una ventana de prueba ancha, hacé clic breve SO para mostrar fichas de ejemplo y abrí la bandeja. Deben quedar ambas secciones visibles y separadas por la línea vertical.
2. **Mantené SO ~400 ms**, sin soltar antes del umbral. Debe aparecer el menú de aplicaciones de muestra **debajo de Soledad**, y las fichas SO + los iconos de bandeja deben **seguir abiertos arriba**.
3. Cerrá el menú flotante con Esc o clic afuera y comprobá que **las fichas SO y bandeja sigan igual de visibles**.
4. Abrí el lanzador desde Malvina (clic a la izquierda), comprobá que aparece bajo Malvina sin cerrar Soledad, y que un segundo clic en Malvina lo cierre.
5. Verificá aparte que **seleccionar una ficha SO** contraiga el selector solo si la opción `autoCollapseSO` está activada, que **usar un icono simulado de bandeja** lo contraiga solo si `autoCollapseTray` está activada, y que siga funcionando la exclusión **por falta de espacio real** cuando ambas expansiones horizontales no entren.

**Estado de este parche:** revisión de código, pendiente de validación efectiva en CachyOS. No hay aplicaciones, controles ni bandeja reales y no se toca el panel instalado.

## Clic breve SO con lanzador abierto: cerrar solo menú, conservar fichas (14/11/2026)

**YA PROBADO EN CACHYOS:** abrir lanzador flotante desde SO sostenido **sin contraer las fichas SO ni la bandeja** funciona según el mantenedor.

**BUG NUEVO OBSERVADO:** con lanzador flotante visible, un clic breve posterior sobre SO cerraba el menú pero **también contraía las fichas de ventanas abiertas**. **COMPORTAMIENTO CONFIRMADO:** ese clic cierra **solo el lanzador**; las fichas SO y la bandeja conservan exactamente su estado anterior.

**PARCHE IMPLEMENTADO, PENDIENTE DE RETEST:** en `SmartBarContent.qml`, `toggleSO()` ahora hace `if (installedAppsPopup.visible) { installedAppsPopup.close(); return; }` antes de alternar `soExpanded`. Si no hay popup visible, el clic breve conserva su función normal de abrir/cerrar las fichas.

**Prueba desde Fish (sin tocar panel KDE):**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. En ventana ancha, clic breve SO → fichas de ventanas de ejemplo desplegadas. Opcional: expandir además la bandeja.
2. Mantener SO ~400 ms → aparece el lanzador flotante bajo Soledad; las fichas SO y la bandeja se mantienen.
3. **Clic breve SO con el lanzador abierto** → debe desaparecer **solo el lanzador**; fichas SO y bandeja siguen visibles y el separador continúa si ambas expansiones están abiertas.
4. **Otro clic breve SO**, ahora sin lanzador → contrae solo las fichas SO, como control manual habitual.
5. Repetir con Malvina: clic M abre y siguiente clic M cierra, sin contraer fichas SO/bandeja. Confirmar que falta de espacio o preferencias de autocontracción por selección conservan sus reglas previas.

**Estado:** código revisado, **no probado todavía en CachyOS después del parche**; apps ficticias; PR #3 borrador.

## Recuperar Malvina directamente desde el menú de los seis puntos (14/11/2026)

**ERROR DE USABILIDAD CONFIRMADO por el mantenedor en CachyOS:** pudo ocultar Malvina (isla 2), pero después no encontró forma evidente de mostrarla. Existían clic derecho sobre SO y opción en el lanzador de SO sostenido, pero no eran descubribles.

**NUEVO CAMINO DIRECTO PROGRAMADO, PENDIENTE DE PRUEBA:** en **Soledad** (isla 1), hacer un **clic normal en los seis puntos** junto a SO; el menú «Opciones de Soledad» ahora tiene como **primera acción** «Mostrar Malvina (isla 2)» cuando está oculta o «Ocultar Malvina (isla 2)» cuando está visible. Un solo clic cambia su estado, sin afectar la bandeja, las fichas SO ni el anclaje de Soledad. El mensaje de ayuda del agarre también explica qué hacer cuando Malvina está oculta.

**Cómo comprobarlo en Fish:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Clic derecho en el botón M de Malvina (izquierda) → «Ocultar Malvina (isla 2)». Debe desaparecer el botón izquierdo.
2. **Clic normal en los seis puntos de Soledad** (junto a SO, siempre visibles) → menú «Opciones de Soledad». La primera opción debe decir **«Mostrar Malvina (isla 2)»**.
3. Clic en «Mostrar Malvina» → debe volver a aparecer el botón M a la izquierda, sin tocar las fichas SO o la bandeja.
4. Reabrí el menú de seis puntos: la primera acción ahora debe indicar **«Ocultar Malvina (isla 2)»**. Ocultá desde allí y recuperá con un nuevo clic en el agarre.
5. Comprobá además que SO sostenido todavía abre el lanzador debajo de Soledad y que un clic breve en SO con el lanzador abierto solo cierra el flotante. El menú de Malvina sigue abriendo/cerrando con clics alternos.

**Alcance:** solo maqueta de Qt Quick, con iconos y aplicaciones simulados. El estado de Malvina en la vista independiente dura una sesión; persistencia en el applet Plasma todavía no comprobada. No toca el panel original del usuario.

## Gesto de los seis puntos: arrastrar con izquierdo, opciones con derecho (14/11/2026)

**BUG DE INTERACCIÓN OBSERVADO POR EL MANTENEDOR EN CACHYOS:** al tocar los seis puntos para desplazar Soledad, se abría el menú de opciones. Repetir clic sobre el agarre podía cerrar/reabrir inmediatamente el menú, resultando molesto e impidiendo usar cómodamente el arrastre.

**SOLUCIÓN FUNCIONAL CONFIRMADA:** el mantenedor prefirió **clic derecho para abrir las opciones** en vez de clic izquierdo; el doble clic izquierdo quedó como alternativa no elegida para esta prueba.

**CÓDIGO EXPERIMENTAL IMPLEMENTADO, SIN RETEST EN CACHYOS:** se quitó `onClicked: gripMenu.popup()` del botón `moveGrip`. Ahora el agarre sólo usa **clic izquierdo para mover Soledad** a través de `DragHandler`; un `MouseArea` con `acceptedButtons: Qt.RightButton` **abre/cierra** `gripMenu` mediante función de alternancia. Se configuró `CloseOnPressOutsideParent` y `CloseOnEscape` para evitar la doble reapertura cuando se pulsa derecho dos veces. Tecla **Menú** o **Mayús+F10** sirven como alternativa por teclado. La ayuda emergente aparece con demora y no durante el arrastre.

**IMPORTANTE:** «Mostrar Malvina (isla 2)» / «Ocultar Malvina (isla 2)» **sigue siendo la primera opción** del menú de los seis puntos, ahora accesible con clic derecho. También se conservan los accesos del menú contextual de SO y del lanzador flotante. Malvina sigue visible por defecto.

**Prueba en Fish (sin instalar ni reemplazar paneles):**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Hacer **clic izquierdo** simple sobre los seis puntos: **NO debe abrirse ningún menú**.
2. Arrastrar Soledad con botón izquierdo desde los seis puntos al centro y luego hacia un borde: **debe moverse sin abrir opciones** y conservar la posición elegida.
3. Hacer **clic derecho** sobre los seis puntos: aparece «Opciones de Soledad». Repetir clic derecho sobre los puntos: **se cierra sin reabrirse**; tercer clic derecho vuelve a abrir.
4. Cerrar el menú con **Esc** o clic fuera del agarre; reabrir desde el mismo botón con derecho.
5. Ocultar Malvina desde el menú y **recuperarla usando nuevamente clic derecho sobre los seis puntos** → primera opción «Mostrar Malvina (isla 2)». También comprobar acceso contextual de SO si fuera necesario.
6. Comprobar que clic breve/sostenido de SO, expansiones SO/bandeja, separador, simulación de ventana maximizada y controles fijos continúen sin cambios.

**Estado:** corrección QML subida solo al PR #3 en borrador, **pendiente de probar en CachyOS**. No hay ventanas o bandeja reales y el panel KDE existente sigue intacto.

## Segundo cierre del menú de los seis puntos: clic izquierdo breve (14/11/2026)

**PRUEBA POSITIVA REPORTADA:** en CachyOS, el mantenedor comprobó que el clic derecho **ya abre el menú de opciones del agarre** como se esperaba. Ahora quiere poder **cerrarlo también con clic izquierdo simple**, sin necesidad de otro derecho.

**COMPORTAMIENTO CONFIRMADO EN ESTA MODIFICACIÓN:** clic derecho abre/cierra opciones; clic izquierdo corto, **solo cuando hay menú abierto**, cierra ese menú, sin reabrirlo; clic izquierdo con menú cerrado no abre nada; arrastrar con izquierdo continúa desplazando Soledad sin generar un cierre accidental tras el gesto.

**IMPLEMENTACIÓN QML, PENDIENTE DE PRUEBA EN CACHYOS:** `moveGrip` tiene un indicador `draggedDuringPress` que se limpia al pulsar y se activa si comienza `gripDrag`. El `onClicked` cierra `gripMenu` únicamente cuando `visible && !draggedDuringPress`. Menú por derecho, teclas de accesibilidad y primera opción «Mostrar Malvina» permanecen.

**Prueba Fish sin tocar panel:**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Clic derecho en seis puntos → se abre «Opciones de Soledad». **Clic izquierdo corto** en seis puntos → se cierra y no reaparece.
2. Clic izquierdo corto con menú cerrado → **no se abre** ninguna opción.
3. Clic derecho abre, otro derecho cierra; seguir verificando que no reabra inesperadamente.
4. Con menú abierto, **arrastrar** los seis puntos hacia el centro: mover Soledad, sin que la acción de arrastre se confunda con un clic simple.
5. Abrir menú por derecho, ocultar Malvina, recuperar Malvina desde la primera opción. El menú de SO/bandeja, su separador y el lanzador flotante deben seguir intactos.

**Estado:** código publicado únicamente en la rama experimental de PR #3; todavía falta ejecutar esta prueba en CachyOS. No hay apps/ventanas reales ni se toca el panel existente.

## Personalización de SO y del aspecto — logo/GIF, recortes, colores y contorno de actividad (14/11/2026)

**SOLICITADO Y CONFIRMADO:** la huella violeta/azul enviada por el mantenedor se agregó como imagen PNG predeterminada del botón SO. El botón admite foto o logo personalizado y GIF opcional, siempre dentro de Soledad y sin cambiar altura, controles ni clic breve/sostenido. Un editor visual permite **arrastrar la imagen, elegir encuadre, zoom/escala, pausar o reproducir GIF** y máscaras de **cuadrado, círculo, rombo ♦, corazón ♥ y estrella ★**. No se recorta ni guarda destructivamente el archivo original: solo parámetros de imagen.

**APARIENCIA:** Soledad y Malvina tienen color/tonalidad y opacidad editables por separado. El fondo continuo opcional detrás de la barra se puede activar y colorear, con opacidad independiente. **Por defecto queda desactivado** para conservar la barra formada por islas independientes. La isla 3 de búsqueda que figuraba antes NO se ha eliminado, reemplazado ni renombrado; falta confirmar si el usuario quiere denominar al fondo «isla 3».

**INDICADOR CONDICIONAL DE SO (nueva decisión):** si no hay ventanas para mostrar, botón SO **normal, sin brillo ni temporizador de contorno**. Cuando hay ventanas, su contorno respeta la forma del logo y puede estar **apagado**, **luminoso fijo** o **con un tramo luminoso que recorre suavemente el borde**. Color seleccionable, grosor **0,5–2 píxeles**, movimiento desactivable. El modo predeterminado de esta maqueta es **brillo fijo sin movimiento**. En la implementación real la condición debe depender del modelo de tareas de KDE/KWin, incluyendo minimizadas, **NO del estado del botón desplegado**. La maqueta permite simular tres ventanas o ninguna.

**Cómo probar en CachyOS (Fish):**

```fish
cd ~/plasma-smartbar
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. **Clic derecho en seis puntos** → «Personalizar logo de SO (imagen o GIF)…». Se abre el editor independiente. Elegí un PNG/JPG/WebP/SVG/GIF, hacé zoom, desplazá el encuadre y probá cuadrado, círculo, rombo, corazón y estrella. Elegí entre **«Imagen completa (encajar)»**, que muestra toda la imagen en la forma, y **«Rellenar forma (recortar)»**, que puede omitir bordes, sin deformar la proporción. «Aplicar» debe actualizar el logo en SO. «Texto SO» devuelve el botón tradicional. GIF: tildar/destildar «Reproducir GIF animados». El archivo original no se altera.
2. En el menú de los seis puntos → «Colores y transparencia de islas y fondo…»: elegí color y opacidad de Soledad y Malvina, luego «Fondo opcional». Activá/desactivá la capa de fondo para comprobar que la altura, la fila, el agarre y la bandeja no se alteran. Por defecto el fondo está **apagado**.
3. En las mismas opciones → «Contorno de actividad de SO…». Se abre un editor con vista previa de brillo y forma actuales. Elegí modo desactivado/fijo/móvil, color y grosor 0,5–2 px. **Desmarcá «Simular ventanas abiertas en esta vista previa»**: contorno debe desaparecer aun si modo móvil está habilitado. Aplicá.
4. Menú de los seis puntos → «Simular SO SIN ventanas (0)». SO debe quedar normal, sin contorno ni animación y sin fichas ficticias al abrirlo. Luego → «Simular SO CON ventanas (3)». El borde debe volver si el efecto está activado. Cambiar a modo móvil y comprobar recorrido suave, sin sacudir el logo ni la isla.
5. Repetí con GIF personalizado, SO expandido/bandeja simultánea, Malvina oculta/visible y Soledad movida al centro. Confirmá que el botón sigue disponible, con el texto «SO» si el logo falla.
6. Si aparece error Qt, guardá el texto exacto de la consola. **No instalar el plasmoide sobre el panel de uso diario**. El editor se cierra con «Cancelar» o «Aplicar» sin modificar archivos de imagen fuente.

**ESTADO:** código implementado en PR #3, pero **NO PROBADO todavía por el mantenedor en CachyOS** tras este conjunto de cambios. `main.xml` y `main.qml` declaran preferencias para la integración Plasma, **persistencia real pendiente de prueba**. El recuento es ficticio: **NO** se detectaron aún ventanas de KDE. Priorizar rendimiento y accesibilidad; las únicas animaciones autorizadas en esta maqueta son GIF elegido y movimiento opcional del borde con ventanas. [Issue #5](https://github.com/nicoarg87/plasma-smartbar/issues/5).

## Retest de menús y logo tras reporte visual — 14/11/2026

**Estado: correcciones QML publicadas en la rama experimental, todavía NO probadas en CachyOS tras estos cambios.** Esta sección reemplaza cualquier instrucción histórica anterior que indique «clic derecho SO → menú contextual» o «clic en agarre → menú» con botón izquierdo. El panel KDE instalado no se cambia.

**Cambios implementados:**
- `SmartBarContent.qml`: **clic derecho SO** abre directamente «Aplicaciones (simulación)», sin menú intermedio ni «Mostrar/Ocultar Malvina». **Clic izquierdo breve SO** conserva fichas de ventanas abiertas; pulsación sostenida izquierda ~400 ms sigue abriendo el lanzador. Las listas de esta versión **siguen siendo ficticias**, no son ventanas ni programas reales.
- **Clic derecho en los seis puntos** abre/cierra «Opciones de Soledad» **debajo de la isla**. El menú se calcula desde la posición horizontal actual de Soledad y se limita al ancho de la ventana. Usa `QQC2.Popup.Window` (Qt 6.8+) para poder aparecer fuera del alto de 48 unidades de la barra; esto **necesita retest en KWin/Wayland**, incluido el cierre con segundo clic derecho. Con opciones abiertas, izquierdo breve sobre agarre cierra; arrastrar con izquierdo desplaza la isla.
- **Primera opción de los seis puntos:** «Mostrar/Ocultar Malvina (isla 2)». Las preferencias de logo, colores, actividad y autocontracción también permanecen allí.
- `IslandButton.qml`: si el botón tiene imagen, se oculta su **marco de botón redondeado adicional**. La máscara seleccionada y su contorno opcional de actividad mantienen la **misma forma** (cuadrado/círculo/rombo/corazón/estrella). Fichas sin imagen conservan su aspecto. No se quita el indicador configurable.
- `LogoEditor.qml`: ya contenía zoom, desplazamiento horizontal y vertical, encajar/rellenar y «Restablecer encuadre»; **no se afirma que estén probados**. Los archivos originales no deben alterarse.

### Prueba segura con la ventana independiente

```fish
cd ~/plasma-smartbar
git branch --show-current
git pull
bash prototype/v0.1/probar_ancho.sh
```

La rama esperada es `prototype/v0.1-islas-so`. **No cambiar de rama automáticamente si tu carpeta local tiene modificaciones pendientes**; en ese caso, revisar la salida de Git antes de continuar.

1. **Posición del menú:** clic derecho en los seis puntos: el menú debe abrir **debajo de Soledad**, sin taparla y sin perder opciones. Segundo clic derecho debe cerrarlo. Mover Soledad hacia el centro y repetir; probar Esc e izquierdo breve para cerrar y comprobar que el arrastre no abre menús.
2. **Gestos de SO:** clic izquierdo breve muestra/oculta las fichas de Dolphin/Konsole/Brave; clic derecho muestra directamente «Aplicaciones (simulación)», sin opciones de Malvina; pulsación izquierda sostenida sigue abriendo ese mismo lanzador. Comprobar que abrir el flotante no cierra fichas SO ni bandeja ya desplegadas.
3. **Malvina:** «Mostrar/Ocultar Malvina» aparece como primera entrada **solo en las opciones de los seis puntos**, y sigue funcionando. Verificar también su acceso desde el botón del lanzador flotante cuando está oculta, si corresponde.
4. **Logo:** observar la huella antes/después y probar en «Personalizar logo de SO» las cinco máscaras. No debe aparecer un segundo marco redondeado ajeno a la forma seleccionada. En «Contorno de actividad» alternar apagado/fijo/recorrido y simular 0/3 ventanas; el indicador solo corresponde a la figura elegida y debe desaparecer con 0 ventanas.
5. **Editor:** cambiar zoom, horizontal, vertical, encajar/rellenar y «Restablecer encuadre», con una foto y un GIF (si se dispone). Comprobar centrado y que no se modifique el archivo original.
6. **Regresión:** arrastrar Soledad, abrir SO y bandeja juntos, simular maximización y verificar que `− □ ×` permanece a la derecha y la altura no cambia.

Si algo falla, **guardar la salida exacta de Konsole y una captura** e informar los pasos usados. Las pruebas QML y de compatibilidad visual deben hacerse en CachyOS; la revisión de código no las sustituye. Registrar resultados en los issues [#1](https://github.com/nicoarg87/plasma-smartbar/issues/1) y [#5](https://github.com/nicoarg87/plasma-smartbar/issues/5) antes de dar los bugs por cerrados.

## Retest de posición del menú de seis puntos (reporte posterior, 14/11/2026)

**REGRESIÓN OBSERVADA EN CACHYOS:** después del cambio que pretendía situar «Opciones de Soledad» debajo de isla 1, el mantenedor observó que **clic derecho sobre los seis puntos abría el menú debajo de Malvina (isla 2)**, lejos del puntero. Es un fallo real de posicionamiento de la rama experimental, no un cambio de diseño. El cálculo anterior `x: Math.max(0, Math.min(root.width - width, systemIsland.x + systemIsland.width - width))`, con `parent: root`, permitía que el menú acabara en el borde izquierdo en vez de mantener una relación directa con el control que lo invoca.

**PARCHE EXPERIMENTAL (PENDIENTE DE RETEST):** `gripMenu` cambia a `parent: moveGrip`, define ancho explícito de 380 píxeles lógicos, alinea el **borde derecho del menú con el borde derecho del agarre** mediante `x: moveGrip.width - width` y lo sitúa debajo del botón con `y: moveGrip.height + 10`. Conserva `popupType: QQC2.Popup.Window` para no limitarlo a la altura de 48 unidades, y los gestos de apertura/cierre ya aprobados. Commit [30aebc0](https://github.com/nicoarg87/plasma-smartbar/commit/30aebc0f66aff9ff660b5e404c74ec8146efbbe8).

**Retest seguro, sin instalar paneles:**

```bash
cd ~/plasma-smartbar
git branch --show-current  # debería ser prototype/v0.1-islas-so
git pull
bash prototype/v0.1/probar_ancho.sh
```

En la ventana Qt de prueba:
1. Con Soledad a la derecha, **clic derecho en seis puntos**: «Opciones de Soledad» debe abrir **debajo del agarre y cerca del puntero**, no debajo de Malvina. Sin tapar el logo, fichas ni seis puntos.
2. Cerrá con otro clic derecho, volvé a abrir; comprobá también izquierdo breve (cierra), Esc y arrastre izquierdo (mueve sin abrir).
3. Desplazá Soledad al centro y repetí: el menú debe seguir a Soledad y no saltar al extremo izquierdo. Abrí SO y bandeja y repetí; sus expansiones no deben desplazar los seis puntos.
4. Si el menú se abre cortado, fuera de pantalla o debajo de Malvina, adjuntá **captura** y salida de Konsole. El cálculo está revisado estáticamente, **todavía no validado en el CachyOS del mantenedor ni en Wayland**.

Mantener [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) abierto y [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) en borrador. No fusionar ni modificar el panel instalado antes de validar la prueba.

## Retest: arrastre con opciones abiertas y ayuda emergente (14/11/2026)

**FALLO REPORTADO EN CACHYOS:** luego de abrir «Opciones de Soledad», al usar el botón izquierdo sobre los seis puntos para mover isla 1 hacia la izquierda, el menú/ayuda podía permanecer en su posición anterior y el arrastre de regreso hacia la derecha dejaba de funcionar correctamente. El usuario observó que la isla podía terminar desplazada hacia el extremo izquierdo. **No hay evidencia de un crash**: no se ejecutaron todavía pruebas con más menús abiertos. El resultado de abrir el menú **debajo** de Soledad sí fue confirmado.

**PARCHE EXPERIMENTAL (AÚN NO PROBADO):** [752be30](https://github.com/nicoarg87/plasma-smartbar/commit/752be306abde9db5b329008ec4ac4474ff8aef01) en `SmartBarContent.qml` cierra el menú al **presionar con izquierdo el agarre**, antes de empezar el arrastre, y vuelve a garantizar el cierre cuando `DragHandler` se activa. También inhibe el `ToolTip` mientras el menú está abierto, se pulsa o se arrastra el agarre, y hasta que el puntero sale del botón. Conserva la casilla de alineación y el cálculo de movimiento existentes; no reubica la isla automáticamente por cerrar un popup.

**Prueba segura (solo ventana Qt):**

```bash
cd ~/plasma-smartbar
git branch --show-current  # debe mostrar prototype/v0.1-islas-so
git pull
bash prototype/v0.1/probar_ancho.sh
```

1. Abrí opciones con **derecho** sobre los seis puntos: tienen que aparecer **debajo de Soledad**.
2. Sin cerrar las opciones manualmente, **presioná y arrastrá con izquierdo** los seis puntos de Soledad hacia el centro/izquierda: las opciones y la ayuda deben **desaparecer de inmediato**; no deben quedarse visibles en la ubicación anterior.
3. **Sin volver a abrir el menú**, arrastrá los seis puntos hacia la derecha y comprobá que Soledad **puede recuperar su posición original**. Soltar no debe provocar un nuevo salto horizontal.
4. Reabrí opciones con derecho, cerralas con **izquierdo breve** y repetí el arrastre; verificá también Esc y segundo derecho. Si cambia la posición sin arrastrar, anotá exactamente en qué paso.
5. Con SO y bandeja de muestra abiertos, repetí a ancho grande y reducido. Verificá que el grosor no cambie, los seis puntos queden junto a SO y los controles de maximización simulada permanezcan fijos.
6. Si se reproduce bloqueo de arrastre, menú que queda visible, salto al extremo izquierdo o error de QML, compartí captura y mensajes de Konsole.

**Estado:** comprobación de código únicamente; todavía falta validación del mantenedor en CachyOS/Wayland. No reemplazar el panel KDE habitual; PR #3 sigue en borrador.

## Centro unificado de Configuración de Soledad (14/11/2026)

**PEDIDO FUNCIONAL CONFIRMADO:** el mantenedor reportó que las tres ventanas de personalización requerían agrandarse manualmente y que pulsar Aplicar las cerraba. Se aprobó una **única ventana con pestañas**, donde **Aplicar no cierra** y **Cerrar es un botón separado**. La posibilidad de **añadir una isla extra** se registrará como idea futura; **no se implementa** ahora.

**IMPLEMENTADO SOLO EN PR #3, PENDIENTE DE PRUEBA REAL:** componente nuevo SoledadSettings.qml; abierto con clic derecho en los seis puntos → **Configuración de Soledad…**. Incluye actualmente **seis pestañas** en este orden: **Logo SO**, **Contorno**, **Apariencia**, **Islas y posición**, **Autocontracción** y **Acerca de**. Dimensiones iniciales de hasta 750 × 850 unidades lógicas según pantalla, suficientes como referencia para el editor de logo; cada pestaña ofrece desplazamiento propio si el espacio es menor. Aplicar y Cerrar están siempre en el pie de la ventana, fuera de las áreas desplazables.

- **Logo SO:** huella, imagen personalizada, texto SO, GIF, cinco máscaras, encajar/rellenar, zoom y desplazamientos, restablecimiento sin editar el archivo original.
- **Apariencia:** colores y opacidad independientes de Soledad, Malvina y fondo continuo opcional (apagado por defecto).
- **Contorno:** vista previa de cero/tres ventanas, efecto off/fijo/recorrido, color, grosor y movimiento opcional.
- **Autocontracción:** dos controles independientes: SO tras seleccionar ficha (activado por defecto); bandeja tras usar icono (desactivado por defecto). Sin temporizador por inactividad.
- **Islas y posición:** visibilidad de Malvina, alineación a la derecha, retorno al desmaximizar y acción inmediata Mover isla 1 a la derecha AHORA. La entrada rápida de Mostrar/Ocultar Malvina sigue primera en el menú de los seis puntos.
- **Aplicar** envía todos los valores a los eventos de configuración existentes y **NO cierra** la ventana. **Cerrar** cierra; al abrirla nuevamente se cargan los últimos valores aplicados. En la vista independiente Qt las preferencias solo duran la sesión; la persistencia KConfig del plasmoide aún no está validada.

### Prueba segura en CachyOS
~~~bash
cd ~/plasma-smartbar
git branch --show-current
git pull
bash prototype/v0.1/probar_ancho.sh
~~~

Confirmar que la rama es prototype/v0.1-islas-so. No sobrescribir modificaciones locales si Git informa conflictos.

1. Derecho en seis puntos → Configuración de Soledad…: comprobar que se abre **una ventana** con las seis pestañas y no tres diálogos separados.
2. En Logo SO, probar imagen/GIF, formas, zoom, encuadre y restablecimiento; comprobar que cualquier control se alcanza sin agrandar la ventana manualmente (usar desplazamiento en pantallas pequeñas).
3. En Apariencia y Contorno cambiar valores, pulsar **Aplicar**: la ventana debe seguir abierta y permitir seguir cambiando de pestaña. **Cerrar** sí debe cerrarla.
4. En Autocontracción cambiar las dos preferencias, aplicar, tocar fichas SO y bandeja simuladas; volver a abrir configuración y verificar los estados de sesión.
5. En Islas y posición ocultar/mostrar Malvina, aplicar, probar retorno, alineación y Mover a la derecha AHORA. No mover los controles de ventana simulados.
6. Achicar la ventana de configuración: todas las pestañas deben poder recorrerse y **Aplicar/Cerrar** deben seguir visibles. Confirmar que SmartBar conserva su altura fija.
7. Si aparece un fallo Qt, registrar salida de Konsole y captura. Mantener [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) y [issue #5](https://github.com/nicoarg87/plasma-smartbar/issues/5) abiertos.

**Estado:** implementación QML publicada en rama experimental; **NO probada todavía en CachyOS/Wayland** después de este cambio. PR #3 continúa en borrador; el panel KDE instalado permanece intacto.

## Personalización de geometría, rotación y Acerca de (15/11/2026)

**CONFIRMADO POR EL MANTENEDOR:** permitir que el botón SO sea más ancho que el cuadrado actual, con rectángulo de esquinas rectas, redondeadas, cápsula horizontal y óvalo. Mantener también el modo cuadrado. El **ancho del SO es configurable** y la altura de la barra es un valor **elegido por el usuario**, pero **constante durante las expansiones**. Las islas Soledad y Malvina disponen de alto, ancho (mínimo de Soledad/ancho de Malvina) y radio de esquinas propios. No redimensionar ventanas del sistema ni pestañas del navegador.

**Nuevo estado experimental:**
- **Logo SO:** selector de formato cuadrado/rectangular/cápsula/oval, ancho horizontal ajustable (44–180 px lógicos en modo ancho), control de rotación de -180 a +180 grados que actúa sobre la foto o **todos los cuadros GIF** sin tocar el archivo original. Las formas previas cuadrado/círculo/rombo/corazón/estrella siguen disponibles en el selector de recorte; cuando se elige un formato horizontal, ese formato determina la máscara y el contorno exterior.
- **Islas y posición:** altura general 40–120 unidades lógicas, altura Soledad y Malvina por separado (limitada a la altura disponible), radio de esquinas por isla, ancho mínimo opcional de Soledad (0=automático por fichas), ancho de Malvina, además de las opciones de posición confirmadas.
- **Pestañas, orden:** Logo SO → Contorno → Apariencia → Islas y posición → Autocontracción → **Acerca de**.
- **Restablecer:** botón independiente en todas las pestañas que modifican preferencias: Logo, Contorno, Apariencia, Islas/posición y Autocontracción. Los valores restablecidos quedan **pendientes hasta pulsar Aplicar**. La pestaña Acerca de no contiene opciones modificables.
- **Acerca de (actualización 15/11/2026):** proyecto, autor público **nicoarg87**, correo **nicoarg87@gmail.com** autorizado para consultas, botón que abre el cliente de correo, licencia **GNU GPL versión 3**, enlace al archivo LICENSE y aviso visible **SIN NINGUNA GARANTÍA** con salvedad legal. **No mostrar PayPal/Cafecito ni enlaces de donaciones** por ahora: postergados expresamente por el mantenedor.
- **El editor sigue una sola ventana**, con botones Aplicar (no cierra) y Cerrar separados, scroll por pestaña y tamaño adaptable a pantalla.

**Código publicado en PR #3, PENDIENTE DE PRUEBA EN CACHYOS/KWIN/WAYLAND:** `SoledadSettings.qml`, `LogoArtwork.qml`, `SoActivityOutline.qml`, `IslandButton.qml`, `SmartBarContent.qml`, `preview_redimensionable.qml`, `main.qml` y `main.xml` enlazados. En la ventana Qt las preferencias son solo de sesión; no se ha demostrado que un plasmoide dentro de un panel de KDE pueda solicitar su altura preferida a la geometría del contenedor. **No instalar sobre el panel de uso diario.**

### Prueba manual segura

~~~bash
cd ~/plasma-smartbar
git branch --show-current
git pull
bash prototype/v0.1/probar_ancho.sh
~~~

Confirmar la rama `prototype/v0.1-islas-so` antes de actualizar. Si hay cambios locales o conflictos, revisarlos sin forzar.

1. Clic derecho en los seis puntos → Configuración de Soledad. Comprobar el **orden de seis pestañas** y la presencia de **Restablecer** en las cinco editables. Aplicar no cierra.
2. Logo SO: probar cuadrado, rectángulo recto, redondeado, cápsula y óvalo. Ajustar ancho horizontal y comprobar que el logo y el contorno luminoso siguen la misma forma y **no se dibujan marcos distintos**.
3. Cargar foto y GIF; rotar -30°, 0°, +30° y comprobar que el encuadre se aplica sin modificar archivos, que la imagen no se estira al cambiar ancho y que el GIF sigue animado si está permitido.
4. Islas y posición: cambiar **altura general**, alturas, anchos y radio de esquinas de **cada isla**. Verificar que Soledad y Malvina siguen una sola fila y se mantienen centradas verticalmente; SO y bandeja se expanden a la izquierda sin modificar el grosor en cada estado. Probar anchura mínima automática (0).
5. Usar Restablecer en Logo, Contorno, Apariencia, Islas y posición y Autocontracción, pulsar Aplicar y reabrir para confirmar predeterminados. Comprobar que la alineación NO se restablece al aplicar cambios que no tocaron su casilla.
6. Acerca de: comprobar que se muestre solo **nicoarg87** como autor, enlace al GitHub oficial y correo público confirmado para consultas. Las donaciones están pospuestas y no deben aparecer en la interfaz.
7. Probar ventanas más angostas, mover Soledad a ambos extremos, activar máximización simulada y abrir SO/bandeja. Si una opción se corta o un menú detiene el arrastre, guardar captura y salida de Konsole.

**Estado:** código y documentación escritos; revisión estática de delimitadores/referencias. **No probada aún la ejecución de Qt/Wayland de estos nuevos cambios** ni la persistencia KConfig; PR #3 sigue en borrador, issues #1/#5 abiertos.

### Verificación posterior: contacto y aviso GPL v3 (15/11/2026)

1. Entrar en seis puntos → Configuración de Soledad… → última pestaña **Acerca de**. Debe mostrar **Autor: nicoarg87**, **nicoarg87@gmail.com**, nombre Plasma SmartBar y el aviso **SIN NINGUNA GARANTÍA**, con texto sobre ausencia de garantía de comerciabilidad y de aptitud para un fin particular, en la medida legal aplicable.
2. Pulsar **Enviar una consulta por correo**: solo debe abrirse el cliente de correo predeterminado con destinatario preparado. **No debe enviar un mensaje automáticamente**.
3. Pulsar **Leer licencia GNU GPL versión 3**: debe abrir el archivo oficial `LICENSE` de este repositorio. Verificar legibilidad y acceso con teclado.
4. No deben verse botones ni leyendas de PayPal o Cafecito. El panel KDE habitual no se modifica. **Prueba en CachyOS/Wayland pendiente**.

## Retest: orden de Acerca de y formas configurables de islas (15/11/2026)

**NUEVAS OBSERVACIONES CONFIRMADAS POR EL MANTENEDOR:** en Acerca de, GitHub estaba demasiado abajo; debe aparecer inmediatamente debajo del contacto por correo, con nombre y botón; después la licencia GNU GPL v3 y el aviso SIN NINGUNA GARANTÍA. Soledad parecía demasiado redondeada: **estética inicial nueva = izquierda redondeada / derecha recta**; el botón de seis puntos pasa a **cuadrado de forma predeterminada**. Ambos y sus alternativas deben ser configurables. También se pide formato rectangular para el acceso de bandeja y una posible punta triangular izquierda donde la bandeja se ubique correctamente.

**IMPLEMENTADO EN LA RAMA EXPERIMENTAL, NO PROBADO TODAVÍA EN CACHYOS:**
- «Acerca de»: orden `autor → contacto + botón de correo → enlace de GitHub + botón de repositorio → explicación licencia GNU GPL v3 → SIN NINGUNA GARANTÍA → botón leer LICENSE`. Se conserva correo público `nicoarg87@gmail.com` y autor `nicoarg87`; sin PayPal/Cafecito.
- «Islas y posición»: selectores **Forma de Soledad** (mixta izquierda redondeada/derecha recta [inicial], toda redondeada, toda cuadrada, inversa, punta triangular izquierda opcional), **Forma de Malvina** (redondeada [inicial], cuadrada, mixta en ambas direcciones), **Agarre de seis puntos** (cuadrado [inicial] o redondeado) y **Botón de bandeja simulada** (redondeado [inicial] o cuadrado).
- Los radios de esquina configurados previamente siguen actuando donde haya esquinas redondeadas. Las esquinas por lado usan propiedades de `Rectangle` disponibles desde Qt 6.7 (Qt 6.8 las documenta como *tech preview*); la punta triangular opcional utiliza un Canvas estático detrás de los controles y reserva más espacio a la izquierda para no tapar la flecha ni reducir su área de clic. **Esta variante es experimental y debe validar visual, foco y accesibilidad**.
- **Restablecer islas y posición** vuelve a las formas y dimensiones iniciales. El alto general queda constante durante las expansiones; el agarre no cambia de ubicación con SO/bandeja.
- En `SmartBarContent.qml` siguen los mismos gestos de clic izquierdo/derecho y arrastre del agarre. Los perfiles por aplicación, iconos externos personalizados y nueva isla siguen diferidos.

**Cómo probar sin modificar el panel KDE:**

~~~bash
cd ~/plasma-smartbar
git branch --show-current
git pull
bash prototype/v0.1/probar_ancho.sh
~~~

Continuar solo si la rama es `prototype/v0.1-islas-so` y no hay cambios locales por preservar.

1. Abrir **Acerca de** y verificar orden autor/contacto/GitHub/licencia/ausencia de garantía. Pulsar «Abrir repositorio oficial» y «Leer licencia»; no enviar correo automáticamente.
2. Ver Soledad inicial **izquierda redondeada, derecha recta** y agarre **cuadrado**. Comprobar que la flecha de bandeja conserva aspecto redondeado inicial.
3. En «Islas y posición», elegir **toda redondeada, toda cuadrada y mixta inversa** en Soledad, pulsar Aplicar y comprobar cambio visual sin cerrar Configuración. Cambiar Malvina a cuadrada y viceversa.
4. Cambiar el agarre de **cuadrado a redondeado** y el botón de bandeja de **redondeado a cuadrado**; comprobar que clic derecho del agarre sigue abriendo opciones debajo de Soledad y clic izquierdo/arrastre permiten moverla **a izquierda y derecha**.
5. Seleccionar **punta triangular izquierda**. Asegurarse de que la flecha y su área clicable no queden recortadas, que el Canvas no cubra las fichas, que SO/bandeja sigan en la misma fila y que no cambie el alto. Mover Soledad y probar extremos de la ventana y controles de maximización simulada.
6. Restablecer Islas y posición, **Aplicar** sin cierre y comprobar que el estilo vuelve al inicial. Reducir ancho de la ventana: verificar que se respeten los límites y la isla no quede irrecuperable.
7. Si aparecen errores QML, glitches, bloqueo del ratón o desaparición de opciones, conservar captura y mensajes de Konsole.

**Estado real:** código publicado y comprobado solo por inspección de referencias y delimitadores QML; sin prueba con Qt ejecutado en CachyOS/KWin/Wayland. La integración y compatibilidad efectiva de las esquinas individuales, especialmente la punta triangular y sus hitboxes, queda pendiente. No tocar el panel instalado, mantener [PR #3](https://github.com/nicoarg87/plasma-smartbar/pull/3) borrador e [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1) abierto.


## Actualización 16/11/2026 — licencias y edición de imágenes SO

- **Software MIT** también en esta rama experimental (`LICENSE`). Los recursos gráficos no heredan MIT. La imagen tropical de OpenAI con palmera y atardecer está **autorizada para CC0 1.0**; **su archivo exacto no está disponible todavía**, así que **SO en texto** es el respaldo visual seguro de la maqueta.
- La huella PNG preexistente se **retiró del árbol distribuible** por ausencia de licencia de Golden Dog acreditada; no llamarla libre ni mantenerla como opción empaquetada mientras falte el permiso. Los archivos personales que el usuario elija no se redistribuyen.
- En **Configuración de Soledad → Logo SO**, el **único selector de forma** muestra cuadrado, círculo, rombo, corazón, estrella, rectángulo recto, rectángulo redondeado, cápsula y óvalo. Ancho modificable para formas horizontales. Ajustes: **Encajar**, **Rellenar** y **Estirar (deformar)**. La escala/zoom y el desplazamiento se aplican después de elegir el modo, conservándolo y sin modificar archivo original.
- **Cómo probar**: `bash prototype/v0.1/probar_ancho.sh` (solo ventana Qt de prueba, nunca instalar en panel). Seleccionar una foto local apaisada/vertical con autorización propia, probar Estirar → zoom 150–250 % → mover imagen → Aplicar; reabrir la configuración y verificar que sigue elegido «Estirar». Repetir en formatos anchos (cápsula, rectángulo, óvalo) y formas normales; comprobar que el ancho no aumenta la altura y el control sigue en una fila. Restaurar «Predeterminada» mientras el archivo tropical no existe debe mostrar texto SO en vez de imagen rota.
- **Verificación**: los cambios se han escrito en QML y están pendientes de ejecución en CachyOS/Qt/Wayland. La incorporación exacta del archivo tropical y su SHA-256 es **pendiente**. Ver [registro de licencias](https://github.com/nicoarg87/plasma-smartbar/blob/main/docs/LICENCIAS_RECURSOS_GRAFICOS.md).


## Prueba del logo tropical original (16/11/2026)

**Nombre visible del prototipo:** Plasma SmartBar Islands. El identificador de Plasma y la dirección del repositorio NO se modificaron. El archivo predeterminado de SO se busca en `prototype/v0.1/package/contents/ui/assets/so-tropical.png`. Se utiliza la imagen suministrada directamente por el mantenedor; la copia original en alta resolución puede colocarse allí sin renombrar ni modificar el código. Si el archivo no está presente, el botón tiene respaldo de texto `SO`. La imagen original **no se ha subido a GitHub desde esta sesión**, por eso el archivo se distribuye en un paquete de prueba aparte.

Desde la carpeta del repositorio en la rama `prototype/v0.1-islas-so`, copiá el `so-tropical.png` original a la ruta indicada, o extraé el ZIP de prueba preparado con la estructura exacta de carpetas. Después ejecutá `bash prototype/v0.1/probar_ancho.sh`, **sin modificar el panel instalado**. En «Configuración de Soledad» → «Logo SO», verificá Predeterminada tropical, Encajar/Rellenar/Estirar, zoom y arrastre, las nueve formas y ancho horizontal; pulsá Aplicar (no cierra), y luego Cerrar. Revisá si guarda al volver a abrir la ventana; los valores de la vista Qt solo viven en la sesión. La prueba de KConfig del plasmoide real y el comportamiento KWin/Wayland siguen pendientes.

La imagen se considera recurso gráfico separado, destinado a CC0 1.0 dentro de los derechos disponibles; ver `docs/LICENCIAS_RECURSOS_GRAFICOS.md`.


## Ajustar velocidad y estilo de la luz móvil de SO (16/11/2026)

En esta rama experimental, abrí la ventana de prueba independiente con:

```bash
cd ~/plasma-smartbar
git fetch origin
git switch prototype/v0.1-islas-so
git pull --ff-only
bash prototype/v0.1/probar_ancho.sh
```

Hacé clic derecho sobre los seis puntos de Soledad → «Configuración de Soledad…» → **Contorno**. Elegí **«Luz que recorre el contorno»**; dejá marcado «Permitir movimiento sutil del borde» y «Simular ventanas abiertas en esta vista previa». Los tres parámetros se reflejan en el botón SO de muestra:

- **Velocidad (vueltas/segundo):** campo numérico editable con botones +/−, entre **0,1 y 3,0** (paso 0,1, permite coma o punto). Inicial **1,0**: una vuelta aproximada por segundo; probá 2,0 si lo querés más rápido.
- **Longitud de la cola:** porcentaje del perímetro del botón, de **5 a 85**; inicial **22**.
- **Trazo:** **Línea continua**, **Punteado** o **Guiones**. Afecta a la estela luminosa que se mueve.

Pulsá **Aplicar**, comprobá que la ventana sigue abierta, luego **Cerrar** y reabríla para verificar la preferencia. En la **prueba Qt** los cambios persisten mientras dura la sesión de la ventana; KConfig está conectado para el plasmoide, pero todavía **no fue comprobado con el panel real**. «Restablecer contorno» vuelve al estado inicial de los tres parámetros. Si simulás cero ventanas o desactivás el contorno, no debe ejecutarse el temporizador de animación.

**Estado:** implementación y revisión estática publicadas; **prueba visual en CachyOS pendiente**. No instalar ni reemplazar el panel KDE existente. En formas irregulares, velocidad y tamaño se calculan mediante estimaciones del perímetro y pueden ser aproximados.


## SO: luz giratoria cuando no hay ventanas (16/11/2026)

**Cambio funcional aprobado y aplicado en esta rama:** por defecto, **sin ventanas de muestra** el botón SO presenta la luz giratoria; **con ventanas de muestra** se apaga. «Configuración de Soledad» → «Contorno» contiene dos opciones independientes: **«Mostrar contorno cuando NO hay ventanas»** (activada por defecto) y **«Mostrar contorno cuando HAY ventanas»** (desactivada por defecto). Podés usar cualquiera, ambas o ninguna. «Efecto → Desactivado» apaga todo. El estilo inicial del efecto pasa a «Luz que recorre el contorno»; velocidad, estela y tipos de trazo conservan sus ajustes.

**Cómo probar en Fish sin tocar el panel:**

```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
bash prototype/v0.1/probar_ancho.sh
```

Abrí «Configuración de Soledad» desde el clic derecho en los seis puntos y elegí «Contorno». La casilla **«Simular ventanas abiertas en esta vista previa»** comienza desactivada, así que la luz debe estar girando. Activala: la luz debe detenerse y desaparecer. Volvé a desactivarla: la luz debe reaparecer. Probá las dos casillas nuevas y el modo «Desactivado». Pulsá «Aplicar» sin cerrar el diálogo, luego «Cerrar» y reabrilo para comprobar los valores.

En la ventana principal del ensayo, el menú de los seis puntos permite cambiar «Simular SO SIN ventanas (0)» / «CON ventanas (3)». **Con cero ventanas**, un clic izquierdo breve sobre SO abre directamente el buscador de aplicaciones de muestra; con tres ventanas, abre/cierra la lista de tareas ficticias. Ni estas apps ni esas ventanas son reales: aún no hay integración KWin/TasksModel. Con cero ventanas y contorno desactivado, el lienzo y el reloj de animación deben quedar inactivos.

**Por probar en CachyOS:** cambios visuales de estado, casillas independientes, perfil guardado durante la sesión Qt, atajos de teclado, cierre del popup y rendimiento. La versión del plasmoide y la persistencia real KConfig siguen pendientes; no instalarlo como reemplazo del panel diario.


## Predeterminados para el siguiente ensayo y bloqueo preventivo Malvina (16/11/2026)

**SO se abre por defecto con** imagen tropical `assets/so-tropical.png`, **cápsula horizontal (ancho 96 px)** y **Estirar**. Estos mismos valores aparecen en «Logo SO» y tras «Restablecer logo y formato». **Importante:** el PNG original exacto todavía NO está en GitHub; tenés que extraer el ZIP con la imagen en la raíz del repositorio, sin reemplazar el código de la rama.

**Contorno PROVISIONAL hasta el OK del mantenedor:** «Luz que recorre el contorno», velocidad **1,5 vueltas por segundo**, grosor **0,75 píxeles**, largo de cola **75 %**, tipo **Guiones**. Estos son ahora los valores iniciales del visor, KConfig y «Restablecer contorno». La preferencia anterior con cero ventanas encendido y con ventanas apagado continúa.

**Apariencia:** Soledad color oscuro `#010111` **provisional** (el hexadecimal dictado tenía siete cifras), **50 % de opacidad**. En «Apariencia» elegí «Botones de bandeja» o «Botón de seis puntos (agarre)» para comprobar que **heredan el color y alfa de Soledad** cuando está desmarcada «Usar color y opacidad propios». Activando esa casilla podés ponerles otros colores/opacidades por separado; probá «Aplicar», cerrar/reabrir y «Restablecer colores».

**Malvina:** no debe aparecer al pasar el ratón mientras se simula una ventana maximizada o fullscreen. Abrí el menú de los seis puntos, activá «Simular ventana maximizada» o «Simular pantalla completa (bloquea Malvina)» y dejá el cursor 600 ms en su posición. **No debería aparecer ni abrir lanzador**. Si desactivás esas simulaciones, debería volver el funcionamiento de hover. Cuando el **visor** Qt está maximizado/fullscreen también se bloquea. El plasmoide real **todavía NO consulta KWin**: por seguridad desactiva toda autoaparición hasta resolver el estado global de ventanas. Esto no acredita protección sobre juegos reales.

**Instrucciones Fish (sin instalar ni reemplazar el panel):**

```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
# Solo si falta la imagen tropical en la ruta de assets:
unzip -o ~/Descargas/Plasma-SmartBar-Islands-prueba-v0.1.zip -d .
bash prototype/v0.1/probar_ancho.sh
```

Validar en CachyOS: logo/imagen/máscara, estiramiento, 1,5 vueltas/s y trazo en guiones, vista previa, alfa 50 %, herencia y controles independientes de color de bandeja/agarre, bloqueo por simulación maximizada/fullscreen, retorno al modo normal, guardado/Restablecer y rendimiento. **El código está publicado y revisado estáticamente; pruebas Qt/Wayland de esta tanda aún pendientes.**


## GIF original definitivo de SO: nueva prueba (16/11/2026)

**CONFIRMADO:** el mantenedor seleccionó el GIF `playa definitiva.gif` generado con ChatGPT, lo reporta **probado y funcional** y pide sustituir el PNG estático anterior como predeterminado. En esta rama, `SmartBarContent.qml` apunta a `assets/so-tropical.gif` y activa reproducción animada también con «Predeterminada»; `SoledadSettings.qml` activa la vista previa de GIF por defecto. Se conserva **cápsula horizontal + Estirar**, ancho inicial 96 px, y el checkbox «Reproducir GIF animados» para pausar el recurso si se desmarca.

**Archivo exacto recibido y verificado:** GIF 439×217, 16 cuadros, 140 ms por cuadro (2,24 s), 771.293 bytes, SHA-256 `a10b34548abae1d3e699d5b92a23f38745b349f9cf73ebc59806fce6f56f5621`. **El binario NO está incorporado a GitHub**: el ZIP `Plasma-SmartBar-Islands-GIF-SO-definitivo.zip` del chat contiene el archivo intacto en `prototype/v0.1/package/contents/ui/assets/so-tropical.gif` y una nota con licencia gráfica **CC0 1.0** dentro de los derechos disponibles, separada del código MIT.

**Para probar desde Fish:**

```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
unzip -o ~/Descargas/Plasma-SmartBar-Islands-GIF-SO-definitivo.zip -d .
bash prototype/v0.1/probar_ancho.sh
```

Comprobá en «Configuración de Soledad» → «Logo SO» que está elegida **Predeterminada**, «Cápsula horizontal», **Estirar** y «Reproducir GIF animados», y que **la animación se reproduce tanto en SO como en el editor de vista previa**. Si desmarcás «Reproducir GIF animados», debería quedar quieta. «Restablecer logo y formato» vuelve al GIF predeterminado con máscara cápsula y Estirar. **Pendiente** probar la integración con el archivo original en CachyOS/Qt; la afirmación de GIF funcional es el resultado comunicado por el mantenedor, no una prueba nueva del asistente. Este procedimiento no instala ni modifica el panel KDE existente.


## Reloj de SO y prueba de hover de Malvina (16/11/2026)

**RELOJ:** posar el puntero sobre el agarre de **seis puntos** durante aproximadamente **180 ms**, sin presionar, muestra la hora (`HH:mm`) y fecha (`dd/MM/yyyy`) en el botón SO durante **tres segundos** y luego restaura el GIF. El reloj no abre popup ni cambia tamaño. Abrir «Configuración de Soledad» → «Logo SO» para elegir tipografía, tamaño 9–28 px y color de texto. Valores iniciales: Sans Serif, 16 px y blanco; «Aplicar» no cierra; restablecimiento de reloj independiente. En el visor Qt los valores duran toda la sesión; KConfig está conectado, aún sin prueba de plasmoide real.

**MALVINA NO APARECE AL PASAR EL CURSOR:** la prueba corregida distingue maximizar **la ventana del visor** de simular que hay una **aplicación externa** maximizada. En el visor actualizado, podés **maximizar la ventana sin bloquear Malvina**. Si está encendida la opción «Simular ventana maximizada» o «Simular pantalla completa (bloquea Malvina)» en el menú de los seis puntos, o el visor está en fullscreen, **Malvina permanece oculta a propósito**. Desactivá esas simulaciones para comprobar el hover de **600 ms** en los primeros 52 px aproximados del extremo izquierdo de la barra (sin hacer clic). El texto de diagnóstico inferior dice «BLOQUEADA», «deshabilitada» o «esperando cursor». El cambio del visor se publicó en [commit 340c8aa](https://github.com/nicoarg87/plasma-smartbar/commit/340c8aa1a690fb0c832346be3facaae6f100c3d5). **Pendiente de prueba Qt/CachyOS.** El plasmoide real aún no conoce el estado KWin global y mantiene el auto-hover bloqueado hasta validarlo de forma segura; no es equivalente al visor Qt.

**RECURSO GIF:** si aparece texto `SO`, falta el GIF `assets/so-tropical.gif`. El script ahora advierte la ausencia. Extraer el ZIP original del chat desde la raíz del repositorio, sin reemplazar el panel instalado.

```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
unzip -o ~/Descargas/Plasma-SmartBar-Islands-GIF-SO-definitivo.zip -d .
bash prototype/v0.1/probar_ancho.sh
```


## SO con ventanas reales de KDE (solo lectura, 17/11/2026)

**Nuevo hito experimental, publicado en código y NO probado todavía en la ventana completa.** El mantenedor ya probó en CachyOS `probar_ventanas.sh`: enumeración dinámica real de ventanas KDE (Alacritty, Brave y qml6, incluyendo estado activo/maximizado). Esta prueba extiende esa fuente real al **SO de `SmartBarContent.qml`**, sin reemplazar el panel CachyOS.

**Cómo ensayar desde Fish:**

```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
bash prototype/v0.1/probar_ancho.sh
```

En la ventana redimensionable, **marcá** la nueva casilla **«Usar ventanas reales de KDE en SO (solo lectura)»** situada debajo de la barra. El visor arranca todavía en modo **simulado** para preservar las pruebas anteriores. Al activar el modo real, el contador bajo la barra indica «Grupos reales KDE»; abrí SO con un clic izquierdo para mostrar fichas horizontales de las aplicaciones abiertas. Abrí y cerrá una aplicación (por ejemplo Dolphin o Konsole) para comprobar si el contador y las fichas cambian automáticamente. Si abrís dos ventanas de una misma aplicación, el modelo está configurado para agruparlas por aplicación, pero **ese caso todavía no fue validado**. Con el modelo real activo, el menú «Simular SO SIN/CON ventanas» queda deshabilitado y no se pueden confundir cifras simuladas con cifras reales.

**Seguridad:** las fichas reales se muestran **solo para lectura**: el clic sobre una ficha únicamente escribe un mensaje de diagnóstico en Konsole; **NO activa, minimiza, cierra ni cambia el foco** de aplicaciones. La bandeja y el buscador de aplicaciones siguen simulados. El plasmoide `main.qml` **NO se ha conectado todavía** a este modelo; no instalarlo como reemplazo del panel en uso. El visor no cambia el tamaño de las ventanas del escritorio. **PENDIENTE:** prueba real de esta integración, rendimiento, comportamiento al haber muchos grupos/ancho insuficiente, agrupación con varias ventanas, posicionamiento y KWin/Wayland. No dar por resuelta la superposición sobre pestañas ni el fullscreen.

Para volver a las fichas de muestra, desmarcá el control. Si falla QML, conservá el error exacto de Konsole y agregalo al [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1). El módulo de tareas utilizado es `org.kde.taskmanager 0.1`, que el mantenedor ya confirmó disponible en su CachyOS.


## Reloj compacto superpuesto al GIF de SO (17/11/2026)

**Corrección solicitada tras prueba visual:** el reloj anterior era grande y, durante los 3 segundos en que aparecía, **tapaba/descargaba el GIF**. Ahora el GIF **nunca se oculta, pausa ni se vuelve a cargar** cuando aparece la hora. Un `Item` transparente superpone **solo las letras de la hora y fecha**, con contorno para contraste sobre el video animado. La hora usa **11 px por defecto** (antes 16), la fecha se muestra aún más pequeña; la tipografía, tamaño y color siguen editables en «Configuración de Soledad» → «Logo SO». «Restablecer texto del reloj» recupera Sans Serif, 11 px y blanco.

**Prueba en CachyOS (Fish, no instala nada):**

```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
bash prototype/v0.1/probar_ancho.sh
```

Con el GIF tropical presente en `prototype/v0.1/package/contents/ui/assets/so-tropical.gif`, colocá el cursor quieto sobre los **seis puntos** unos 180 ms: fecha y hora aparecen por **3 segundos superpuestas al GIF**. Observá que la animación del atardecer sigue avanzando durante el reloj y no vuelve a comenzar cuando se ocultan los números. Probá cambiar fuente, tamaño y color y pulsá **Aplicar**. Si el GIF falta, `probar_ancho.sh` lo anuncia en Konsole y SO muestra el fallback de texto; para comprobar continuidad del GIF debe estar copiado el recurso original del ZIP.

**Estado:** publicado y revisado en código; falta el retest visual del mantenedor. El panel KDE habitual no cambia y las acciones de ventanas reales continúan en modo solo lectura experimental.


## Revisión 19/11/2026 — probar menú SO unificado y metadatos MIT


El mantenedor confirmó que el menú lateral Soledad debe comenzar por **«Launcher y botón SO»**, seguido de **«Botón de inicio SO»**. Este último contiene **dos subpestañas visibles**: «Logo, ancho y texto» y «Efectos luminosos SO». El brillo, contorno, fases y duración del pulso se editan dentro del botón SO. Hay un botón para saltar desde **Efectos luminosos → Brillo y respiración** a **Color y transparencia → Degradado y respiración de Soledad**, y otro para volver al brillo SO desde Color. Los controles del fondo siguen independientes de los del contorno.

En el prototipo se amplió la ventana hasta 1180 px si la pantalla lo permite y se dejaron 32 px de margen para que la barra vertical no tape controles. Color/HEX/Copiar/Editar se distribuyen en filas más pequeñas, conservando los tres tonos del GIF y sus cuatro direcciones.

**Prueba segura desde Fish** (sin instalar nada en el panel):
```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
node prototype/v0.1/tests/test_breathing_menu.cjs
bash prototype/v0.1/probar_ancho.sh
```

**Verificar:** primero Launcher, segundo Botón SO; abrir ambas subpestañas y volver; entrar en Brillo y respiración y pulsar acceso a Degradado; comprobar que aparece la edición cromática y su velocidad, y volver al brillo con el enlace inverso. Reducir y ampliar ventana y, si es posible, probar escalado KDE mayor: ningún HEX, Copiar, Editar o selector debajo del scrollbar. Aplicar, cerrar y volver a abrir para verificar persistencia de Soledad/Malvina y temas. Si falla, conservar salida de Konsole.

**Licencia:** `LICENSE` y `KPlugin.License` contienen **MIT**. GIF propios de ChatGPT autorizados por el mantenedor para **CC0 1.0 Universal** conforme al inventario de gráficos; las licencias no se extienden a otros archivos aportados por usuarios o terceros. Los GIF originales de prueba se conservan localmente; actualizar Git no debe sustituirlos.

**Estado:** modificaciones codificadas en rama experimental; no se ha ejecutado aquí una interfaz Qt/CachyOS. PR #3 continúa en borrador.


## Comprobación de Isla y launcher y respiración SO — 19/11/2026

**Navegación vigente:** menú Soledad → **Isla y launcher** primero, con accesos a posición y figura/tamaño de la isla, seguido por **Botón de inicio SO → Efectos luminosos SO**. Allí «Brillo y respiración» es el primer apartado. Para nuevas configuraciones se inicia en `breathe` y `0.3` ciclos/s (aprox. un ciclo cada 3,33 s); las preferencias locales anteriores conservan sus propios valores.

**Independencia y sincronización:** la línea SO tiene velocidad y profundidad de pulso propias. Soledad y Malvina conservan ritmo propio por defecto en instalaciones nuevas. Desde Efectos luminosos SO se puede activar «Sincronizar degradado Soledad con la línea SO (ritmo e intensidad)» y luego «Desvincular degradado». Desde Color y transparencia → Soledad se mantiene la opción de compartir solo fase/velocidad y se agrega la de igualar intensidad de pulso. La intensidad personal del degradado no se borra al sincronizar; se recupera al desvincular. Malvina no cambia automáticamente al activar la sincronización de Soledad.

**Prueba en Fish**, sin instalar ni reemplazar el panel:
```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
node prototype/v0.1/tests/test_breathing_menu.cjs
node prototype/v0.1/tests/test_theme_persistence.cjs
node prototype/v0.1/tests/test_gradient_palette.cjs
bash prototype/v0.1/probar_ancho.sh
```

**Ensayo visual:** comprobar «Isla y launcher» primero, que los accesos a posición y figura llevan a sus ajustes; entrar en Botón de inicio SO y Efectos luminosos y encontrar Brillo y respiración primero. Desactivar sincronización, mover el deslizador de velocidad de la línea SO y comprobar que el degradado mantiene su propio ritmo. Activar sincronización de ritmo e intensidad de Soledad, variar la velocidad y la intensidad de la línea SO y observar que el fondo acompaña el pulso. Desvincular, comprobar que se recuperan velocidad/intensidad propias. Ensayar Malvina independientemente, Aplicar, cerrar/reabrir y verificar los temas y favorita existentes. Preservar logs de Konsole y registrar en issue #15.

**Estado:** test estático PASS en V8 (245 comprobaciones agrupadas); pendiente ejecución Node en el equipo y vista real Qt/KWin/Wayland. Metadatos KDE y código propio MIT; GIF originales de ChatGPT del botón SO dedicados CC0 1.0 según inventario de recursos.


## Prueba de regresión de velocidad de respiración — 19/11/2026

**Error reportado por el mantenedor en CachyOS:** dentro de Color y transparencia, deslizador de velocidad del degradado bloqueado (p. ej. 0,2 ciclos/s), aun con «Igualar intensidad a SO» desactivado. En Efectos luminosos del botón SO no encontraba con claridad ni podía modificar bien la velocidad/intensidad de la línea.

**Arreglo en rama experimental:** [7ac071b](https://github.com/nicoarg87/plasma-smartbar/commit/7ac071bf32ad60d94cf9e7c4a091384b64d14394) coloca los controles de **Velocidad de la respiración · línea SO** y **Intensidad del pulso · línea SO** al principio de «Brillo y respiración». Los botones ± y los deslizadores son operativos aunque hubiera un efecto distinto seleccionado; al moverlos se activa respiración. La vista previa SO se refresca al modificar dichos ajustes, sin guardar hasta pulsar Aplicar. Una casilla de visibilidad permite ver la línea con ventanas abiertas; por defecto no se cambia el ajuste personal anterior.

En **Color y transparencia → Respiración del fondo y los menús → Velocidad propia del degradado**, los botones ± y el deslizador siempre son accesibles: cambiar velocidad propia desactiva la sincronización de ritmo de la isla y el vínculo de intensidad opcional de Soledad, para evitar controles bloqueados. Si el ritmo sigue sincronizado aparece el valor vigente del botón SO como información, y el valor editable propio se muestra aparte. El enlace desde Efectos luminosos SO desplaza a este apartado, no a la cabecera de colores.

**Repetir prueba desde Fish** (no instala nada en el sistema):
```fish
cd ~/plasma-smartbar
git switch prototype/v0.1-islas-so
git pull --ff-only
node prototype/v0.1/tests/test_breathing_menu.cjs
node prototype/v0.1/tests/test_theme_persistence.cjs
node prototype/v0.1/tests/test_gradient_palette.cjs
bash prototype/v0.1/probar_ancho.sh
```
En la ventana de configuración: 1) Color y transparencia → Respiración del fondo: pulsar + o mover deslizador aun si la antigua sincronización estaba activa; comprobar que el valor cambia y su estado pasa a propio. 2) Ir a botón SO → Efectos luminosos → primera sección Brillo y respiración: tocar ± de velocidad e intensidad, ver inmediatamente la vista previa y probar la casilla de ventanas abiertas si no aparece la línea. 3) Pulsar Aplicar, cerrar, reabrir, volver a comprobar velocidad de cada superficie y temas. Si no responde, copiar mensajes de Konsole y registrar en issue #15.

**Verificación:** regresión V8 con JS extraído del QML y FS simulado PASS: 169 controles + 62 temas + 44 degradados = 275. **No se probó aún Qt/CachyOS en el entorno de desarrollo del asistente.** No tocar panel real ni fusionar PR #3.
