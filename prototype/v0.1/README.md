# Plasma SmartBar — Prototipo visual v0.1 (rama experimental)

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