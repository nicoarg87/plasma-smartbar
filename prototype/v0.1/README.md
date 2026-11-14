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
