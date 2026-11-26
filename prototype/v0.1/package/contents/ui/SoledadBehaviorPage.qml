import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

// Vista de comportamiento de Soledad; la persistencia sigue centralizada.
QQC2.ScrollView {
    id: page
    required property var settingsTarget
    required property var switchColorDialog
    readonly property var settings: settingsTarget
                id: collapseScroll
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.width: 16
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, page.availableWidth - 32)
                    spacing: 16
                    ColumnLayout {
                        visible: settings.behaviorScope === "soledad"
                        Layout.fillWidth: true
                        spacing: 12
                    QQC2.Label {
                        text: "Isla y launcher · Soledad"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Posición de la isla en la barra…"
                        onClicked: settings.showSharedLayout()
                    }
                    QQC2.Button {
                        Layout.fillWidth: true
                        text: "Figura y tamaño de la isla Soledad…"
                        onClicked: settings.showSoledadShape()
                    }
                    QQC2.Label {
                        text: "Acciones del botón SO"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: [
                            "Izquierdo: Launcher de aplicaciones · Derecho: Cajón de aplicaciones",
                            "Izquierdo: Cajón de aplicaciones · Derecho: Launcher de aplicaciones (inicial)"
                        ]
                        currentIndex: settings.soLeftClickOpensLauncher ? 0 : 1
                        onActivated: function(i) { settings.soLeftClickOpensLauncher = i === 0 }
                    }
                    QQC2.Label {
                        text: "Podés invertir los clics cuando quieras. El mensaje al pasar el cursor sobre SO muestra las acciones elegidas. Mantener pulsado el botón sigue abriendo el lanzador."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Launcher de aplicaciones · Soledad"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.Label {
                        text: "El fondo, degradado, contorno, transparencia y respiración del launcher siguen automáticamente los de Soledad."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Íconos de sectores y aplicaciones"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Ícono y nombre (predeterminado)", "Solo nombre"]
                        currentIndex: settings.launcherIconsWithNames ? 0 : 1
                        onActivated: function(i) { settings.launcherIconsWithNames = i === 0 }
                    }
                    QQC2.Label {
                        text: "Ubicación del panel de aplicaciones"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: [
                            "A · Original: opciones a la derecha, cerca del cursor (inicial)",
                            "B · Opciones a la izquierda, cuadro principal fijo"
                        ]
                        currentIndex: settings.launcherCategoryLayout
                        onActivated: function(i) { settings.launcherCategoryLayout = i }
                    }
                    QQC2.Label {
                        text: "Forma del interruptor Aplicaciones / Archivos"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["Cápsula", "Cuadrado redondeado", "Cuadrado"]
                        currentIndex: ["capsule", "rounded", "square"].indexOf(settings.launcherSwitchShape)
                        onActivated: function(i) {
                            settings.launcherSwitchShape = ["capsule", "rounded", "square"][i]
                        }
                    }
                    QQC2.CheckBox {
                        text: "Elegir un color propio para el interruptor"
                        checked: settings.launcherSwitchColorOverride
                        onToggled: settings.launcherSwitchColorOverride = checked
                    }
                    QQC2.Button {
                        text: "Elegir color del interruptor…"
                        visible: settings.launcherSwitchColorOverride
                        onClicked: switchColorDialog.open()
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        QQC2.Label {
                            text: "Máximo de filas antes de desplazarse"
                            color: "white"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                        QQC2.SpinBox {
                            from: 5
                            to: 20
                            editable: true
                            value: settings.launcherMaxSlots
                            onValueChanged: settings.launcherMaxSlots = value
                        }
                    }
                    QQC2.Label {
                        text: "El launcher también se limita al espacio inferior disponible. En Archivos busca por nombre dentro de la carpeta actual; la búsqueda global sigue pendiente."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "soledad"
                        text: "Autocontracción del cajón de aplicaciones"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        visible: settings.behaviorScope === "soledad"
                        text: "SO: contraer después de elegir una ventana"
                        checked: settings.autoCollapseSO
                        onToggled: settings.autoCollapseSO = checked
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "soledad"
                        text: "Desactivado por defecto: SO permanece abierto al seleccionar una ventana."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "shared"
                        text: "Cajón de sistema (bandeja)"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        visible: settings.behaviorScope === "shared"
                        text: "Bandeja: contraer después de utilizar un icono"
                        checked: settings.autoCollapseTray
                        onToggled: settings.autoCollapseTray = checked
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "shared"
                        text: "Desactivado por defecto. La apertura del lanzador no contrae ninguna sección."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.behaviorScope === "shared"
                        text: "Sin temporizador de inactividad: el cierre solo se dispara por la acción aprobada o por falta de espacio."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.behaviorScope === "soledad"
                        text: "Restablecer autocontracción SO"
                        onClicked: settings.autoCollapseSO = false
                    }
                    QQC2.Button {
                        visible: settings.behaviorScope === "shared"
                        text: "Restablecer autocontracción de bandeja"
                        onClicked: settings.autoCollapseTray = false
                    }
                }
            }
