# Plasma SmartBar — Prototipo visual v0.1 (rama experimental)

**Estado: código preliminar, todavía NO ejecutado ni validado en CachyOS.** No es una versión instalable ni un reemplazo de tu panel. Relacionado con el [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).

## Qué se puede probar en esta etapa

- Dos **islas visualmente separadas**. Izquierda: lanzador de muestra. Derecha: botón SO y bandeja.
- Pulsar **SO**: aparecen fichas ficticias de Dolphin, Konsole y Brave **hacia la izquierda**, todas en una sola fila.
- Pulsar una ficha: SO se contrae automáticamente (solo cambia el estado de la demo, **no activa ventanas reales**).
- Pulsar **◀**: se expande una bandeja de **muestra** con Wi-Fi, Audio y Bluetooth; abrir bandeja cierra SO, y viceversa.
- El botón **SO** y el agarre punteado **⋮** conservan su posición horizontal mientras crecen las fichas hacia la izquierda.
- El **agarre está deshabilitado**: mover la isla 1 es una etapa futura. La isla 3 (buscador persistente) no aparece.
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

**Importante:** no ejecutes `plasmashell --replace`, no agregues este widget al panel y no borres el panel actual. El script no usa `sudo`, no instala software, no modifica archivos de configuración y no accede a ventanas reales. El único paso que puede modificar paquetes es la instalación de `plasma-sdk`, que el usuario hace explícitamente si lo necesita.

## Pruebas manuales que necesitamos registrar

| Prueba | Resultado esperado |
|---|---|
| Ventana inicial | Isla 2 izquierda, isla 1 derecha; isla 3 ausente |
| Pulsar SO | Aparecen tres fichas a la izquierda, SO permanece a la derecha |
| Pulsar Dolphin | Se ocultan las fichas; Dolphin real permanece igual |
| Pulsar flecha ◀ | Se muestra la bandeja simulada y se oculta SO expandido |
| Abrir SO con bandeja expandida | Se contrae automáticamente la bandeja |
| Repetir muchas veces | No aparece segunda fila ni cambia el grosor |
| Mirar el control ⋮ | Sigue a la derecha de SO, pero NO se puede arrastrar todavía |

Anotá la versión de Plasma (`plasmashell --version`), distribución, sesión (Wayland/X11) y cualquier mensaje de error de Konsole. Si no abre, **no modifiques tu panel**: compartí el error en el [issue #1](https://github.com/nicoarg87/plasma-smartbar/issues/1).

## Qué falta (NO implementado)

- Enumerar ventanas reales, agruparlas, activarlas o minimizarlas con KWin.
- Lanzar aplicaciones instaladas desde isla 2.
- Controles de minimizar/restaurar/cerrar en ventanas maximizadas.
- Arrastre real de la isla 1 y configuraciones persistentes.
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
    └── contents/ui/
        ├── IslandButton.qml
        └── main.qml
```

Fuentes de referencia: [Crear un plasmoide de Plasma 6](https://develop.kde.org/docs/plasma/widget/setup/) y [probarlo mediante plasmoidviewer](https://develop.kde.org/docs/plasma/widget/testing/).

**La constitución y el manual maestro conservan precedencia.** Esta demostración no aprueba cambios funcionales.
