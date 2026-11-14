# Protocolo de continuidad entre conversaciones de ChatGPT

**Proyecto:** Plasma SmartBar  
**Repositorio oficial:** https://github.com/nicoarg87/plasma-smartbar  
**Propósito:** impedir pérdida de contexto, cambios de criterio no aprobados y afirmaciones incorrectas sobre el estado del software.

## 1. Fuente de verdad y jerarquía

Para retomar el desarrollo, consultar **la versión actual en GitHub**, no basarse exclusivamente en recuerdos o conversaciones anteriores.

1. [Constitución técnica](CONSTITUCION_TECNICA.md): invariantes y autoridad funcional.
2. [Manual Maestro](MANUAL_MAESTRO.md): diseño detallado, estados, variantes y decisiones.
3. [Estado actual](ESTADO_PROYECTO.md): qué se creó, qué se comprobó y qué falta.
4. [Hoja de ruta](../ROADMAP.md) e [issues](https://github.com/nicoarg87/plasma-smartbar/issues): siguiente trabajo.
5. [Gobernanza](../GOVERNANCE.md) y [normas de contribución](../CONTRIBUTING.md).
6. Conversaciones y bocetos: contexto histórico, **no** autoridad por encima de decisiones confirmadas.

**No considerar que un chat, su memoria o un resumen sustituye leer las fuentes.** Si GitHub no estuviera accesible, indicar con precisión qué documento falta antes de modificar especificaciones o escribir código que dependa de él.

## 2. Arranque obligatorio de un nuevo chat

Ante «retomemos Plasma SmartBar», el asistente debe:
1. Identificar que se trata del repositorio **nicoarg87/plasma-smartbar**, distinto de **proyecto-editor**.
2. Revisar los documentos anteriores, especialmente la Constitución, Manual y Estado actual, usando el conector de GitHub si está disponible.
3. Resumir en pocas líneas: **decisiones confirmadas / estado real verificado / siguiente paso pendiente / riesgos abiertos**.
4. No pedir al usuario que repita decisiones ya documentadas.
5. Antes de proponer una nueva arquitectura, comprobar si contradice requisitos aprobados. Las nuevas ideas se etiquetan **PROPUESTA**, nunca **CONFIRMADO** sin decisión del director funcional.

## 3. Identidad, autoridad y licencia

- Director funcional y de diseño: titular del repositorio oficial (usuario GitHub **nicoarg87**).
- Se puede delegar programación, pruebas, documentación y revisión; los colaboradores proponen mediante issues y pull requests.
- Los forks están permitidos bajo las condiciones de **GPL-3.0**. Nadie puede modificar el repositorio oficial sin permisos de escritura autorizados.
- No cambiar licencia, visión principal, requisitos confirmados o reglas de gobernanza sin aprobación explícita del director.
- Rama principal: **main**. La regla activa de GitHub **«Proteccion de main»** se creó para bloquear borrado y force pushes; no equivale a revisión obligatoria de PR.

## 4. Resumen de diseño irrenunciable

- Complemento para **Linux + KDE Plasma 6**, primero probado en **CachyOS / Wayland**; GNOME, Cinnamon, Windows y macOS no son objetivos.
- Barra de **grosor invariable** con dos ubicaciones horizontales aprobadas: **superior (predeterminada)** e **inferior (configurable, no implementada)**. Al expandirse, ninguna lista crea una segunda fila, mueve pestañas ni redimensiona la aplicación.
- Lanzador izquierdo: aplicaciones **instaladas**. Botón **SO** derecho: aplicaciones/ventanas **abiertas**.
- **Islas visuales:** isla 1 derecha (SO y bandeja), isla 2 izquierda (lanzador), isla 3 (buscador visible) opcional y oculta por defecto; sin fondo continuo por defecto.
- **Agarre horizontal aprobado:** tres o cuatro puntos discretos **inmediatamente a la derecha de SO**, antes de controles de ventana si está maximizada. **SO y agarre no se mueven al expandir/contraer bandeja o SO**. El agarre reubica horizontalmente la isla 1. **Cuando se desmaximiza, la isla vuelve por defecto al extremo derecho**, mediante preferencia persistente y desactivable en configuración; con opción desactivada puede conservar su ubicación. **Hay una implementación solo en demo QML en rama experimental**, usando maximización ficticia y casilla KConfig; límites y comportamiento con KWin/Wayland reales pendientes de probar.
- SO expande fichas hacia **la izquierda en una única fila**; agrupa ventanas por aplicación por defecto, con opción de desagrupar.
- SO y bandeja son mutuamente excluyentes. Flecha de bandeja **◀ cerrada / ▶ expandida**.
- SO se contrae tras seleccionar ventana por defecto; configuración alternativa de permanencia y modo de visibilidad adaptable a navegadores.
- Con ventana maximizada, los controles **propios de SmartBar** minimizar/restaurar/cerrar están a la derecha, **en el mismo borde elegido**: arriba en modo superior, **abajo en modo inferior**. No afirmar que los botones originales de cualquier aplicación pueden reubicarse: las decoraciones propias y KWin/Wayland requieren pruebas. En modo superior, la barra prioriza su capa sobre pestañas **sin desplazarlas**, viabilidad técnica por demostrar.
- **Fullscreen real** oculta las islas. Los paneles secundarios flotan hacia el interior de la pantalla (**debajo** desde el modo superior, **encima** desde el inferior); la flecha vertical pertenece a la bandeja.
- **Laterales verticales izquierdo/derecho:** experimentales, fuera del compromiso de versiones iniciales. Diseñar lógica de ventanas independiente de orientación y anclaje para facilitar futuras pruebas; no afirmar soporte vertical probado. El modo inferior se registró en el [issue #2](https://github.com/nicoarg87/plasma-smartbar/issues/2), posterior a la primera prueba [#1](https://github.com/nicoarg87/plasma-smartbar/issues/1).
- Primero rendimiento, estabilidad, accesibilidad y **sin animaciones**. MPRIS, temas avanzados, efectos decorativos y expansiones futuras solo después del MVP. La animación opcional «gaveta de SO» al minimizar queda para una fase posterior. El agarre se incluyó ya en la **demostración v0.1 no ejecutada**; la integración real con KWin se abordará más adelante.
- No generar imágenes conceptuales salvo que el usuario las pida; los renders rechazados no son requisitos.

## 5. Reglas del trabajo diario

- Separar siempre **HECHO Y PROBADO**, **IMPLEMENTADO PERO NO PROBADO**, **PLANIFICADO** y **PROPUESTA**.
- Para resultados técnicos, mencionar versión del entorno, fecha, evidencia y limitaciones reales.
- No inventar APIs, código ya ejecutado, resultados de pruebas ni compatibilidad universal.
- Preferir piezas reutilizables de Qt 6, QML, Plasma 6 y KWin, verificando versión, licencia y coste en recursos; no introducir dependencias pesadas por comodidad.
- Probar los prototipos inicialmente **sin sustituir el panel KDE en uso**. Toda prueba debe ser reversible y acompañada de instrucciones de recuperación.
- Registrar en GitHub las decisiones aprobadas, descubrimientos y problemas. Para funcionalidades, usar issues/PR y actualizar manual y estado al cerrar una etapa.
- Si aparece una contradicción entre fuentes, mostrarla y solicitar resolución; nunca corregirla silenciosamente mediante una interpretación propia.

## 6. Cierre de cada sesión relevante

Antes de dar por terminado un avance, registrar:
- **Qué quedó confirmado** por la dirección funcional.
- **Qué archivos/issues/commits cambiaron realmente** (con enlaces).
- **Qué se verificó ejecutando pruebas y qué no**.
- **Qué falta / bloqueo o riesgo**.
- **Próxima acción concreta**.

Actualizar [ESTADO_PROYECTO.md](ESTADO_PROYECTO.md) cuando haya un hito o cambio de fase. No convertir una conversación en la única copia del conocimiento.

## 7. Proyecto de ChatGPT (opcional pero recomendado)

El usuario informó que creó un **Proyecto de ChatGPT llamado «Plasma Smart Bar»**, con instrucciones basadas en [PLANTILLA_INSTRUCCIONES_CHATGPT.md](PLANTILLA_INSTRUCCIONES_CHATGPT.md). Los cambios futuros de la plantilla **no se sincronizan solos** con las instrucciones de ese Proyecto. Si se modifica la plantilla, actualizar manualmente el texto de las instrucciones.

El Proyecto de ChatGPT organiza conversaciones e instrucciones, pero **no es el repositorio GitHub**. Los archivos adjuntados al Proyecto pueden quedar desactualizados si se modifican en GitHub: consultar preferentemente las versiones vigentes del repositorio. No asumir que guardar un enlace GitHub sincroniza automáticamente los archivos.

## 8. Mensaje breve para iniciar cualquier conversación

«Retomemos Plasma SmartBar desde el repositorio https://github.com/nicoarg87/plasma-smartbar. Leé la Constitución Técnica, el Manual Maestro, el Estado del Proyecto y el issue de trabajo pendiente. Recordá que dirijo el diseño y no se deben modificar requisitos confirmados sin mi aprobación. Decime qué está realmente hecho, qué falta y cuál es el siguiente paso, sin reinventar la especificación ni generar imágenes.»

