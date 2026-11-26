import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

// Vista de geometría y posición. La aplicación y persistencia permanecen en SoledadSettings.
QQC2.ScrollView {
    id: page
    required property var settingsTarget
    readonly property var settings: settingsTarget
    function resetScroll() {
        if (contentItem) contentItem.contentY = 0
    }
                // Scroll interno de geometría
                clip: true
                contentWidth: Math.max(0, availableWidth - 32)
                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.width: 16
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
                ColumnLayout {
                    width: Math.max(0, page.availableWidth - 32)
                    spacing: 16
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: "Ubicación"
                            visible: settings.geometryScope === "shared"
                            highlighted: settings.geometrySection === 0
                            onClicked: { settings.geometrySection = 0; page.contentItem.contentY = 0 }
                        }
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: settings.geometryScope === "shared" ? "Botones comunes" : "Figuras"
                            highlighted: settings.geometrySection === 1
                            onClicked: { settings.geometrySection = 1; page.contentItem.contentY = 0 }
                        }
                        QQC2.Button {
                            Layout.fillWidth: true
                            text: "Tamaños"
                            visible: settings.geometryScope !== "shared"
                            highlighted: settings.geometrySection === 2
                            onClicked: { settings.geometrySection = 2; page.contentItem.contentY = 0 }
                        }
                    }
                    ColumnLayout {
                        visible: settings.geometrySection === 0
                        Layout.fillWidth: true
                        spacing: 10
                    QQC2.Label {
                        text: "Ubicación, visibilidad y altura general de la barra"
                        color: "#ddd6e8"; Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Posición general de las islas"
                        font.bold: true
                        color: "white"
                    }
                    QQC2.CheckBox {
                        text: "Activar Malvina (isla 2)"
                        checked: settings.launcherIslandVisible
                        onToggled: settings.launcherIslandVisible = checked
                    }
                    QQC2.Label {
                        text: "Activada significa disponible, no siempre visible. Al desactivarla, Malvina deja de responder y no aparece por proximidad."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.launcherIslandVisible
                        text: "Visibilidad de Malvina"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        visible: settings.launcherIslandVisible
                        Layout.fillWidth: true
                        model: ["Automática: se oculta sola (predeterminado)",
                                "Siempre visible (opcional)"]
                        currentIndex: settings.autoHideMalvina ? 0 : 1
                        onActivated: function(index) {
                            settings.autoHideMalvina = index === 0
                        }
                    }
                    QQC2.Label {
                        visible: settings.launcherIslandVisible
                        text: settings.autoHideMalvina
                            ? "Modo automático: Malvina sigue activa aunque esté escondida. Aparece al sostener el cursor 0,6 s en su ubicación y se oculta al salir. El menú de los seis puntos la muestra 1 s al activarla."
                            : "Modo siempre visible: Malvina permanece a la vista mientras esté activa, salvo protección de ventanas maximizadas o pantalla completa."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        text: "Altura general compartida"
                        font.bold: true
                        color: "white"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura general"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 40; to: 120; stepSize: 2
                            value: settings.panelHeight
                            onMoved: settings.panelHeight = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.panelHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    QQC2.Label {
                        text: "Alineación predeterminada de Soledad"
                        color: "white"
                        font.bold: true
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        model: ["A la derecha (SO abre a la izquierda)",
                                "En el centro (SO abre a la derecha)"]
                        currentIndex: settings.positionMode === "center" ? 1 : 0
                        onActivated: function(index) {
                            settings.positionMode = index === 1 ? "center" : "right"
                            settings.alignmentEdited = false
                        }
                    }
                    QQC2.Label {
                        visible: settings.positionMode === "center"
                        text: "La isla se centra mientras está contraída y las fichas crecen hacia la derecha. La altura no cambia; al expandir se controla el espacio disponible."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.positionMode === "center"
                        text: "Centrar isla 1 al aplicar"
                        onClicked: {
                            settings.positionMode = "center"
                            settings.pendingAlignAction = "center"
                            settings.alignmentEdited = true
                        }
                    }
                    QQC2.CheckBox {
                        visible: settings.positionMode === "right"
                        text: "Alinear isla 1 a la derecha"
                        checked: settings.alignedRight
                        onToggled: settings.alignedRight = checked
                        onClicked: settings.alignmentEdited = true
                    }
                    QQC2.CheckBox {
                        visible: settings.positionMode === "right" && settings.alignedRight
                        text: "Volver a la derecha al desmaximizar"
                        checked: settings.autoReturnRight
                        onToggled: settings.autoReturnRight = checked
                    }
                    QQC2.Label {
                        visible: settings.positionMode === "right" && settings.alignedRight
                        text: "El regreso al desmaximizar está activado por defecto. No impide mover Soledad manualmente."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        visible: settings.positionMode === "right"
                        text: "Mover isla 1 a la derecha al aplicar"
                        onClicked: {
                            settings.positionMode = "right"
                            settings.alignedRight = true
                            settings.pendingAlignAction = "right"
                            settings.alignmentEdited = true
                        }
                    }
                    QQC2.Label {
                        text: "La nueva posición se confirma con Aplicar; Cancelar la descarta. La posición por aplicación sigue pendiente de desarrollo."
                        color: "#ddd6e8"
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: "Restablecer posición y altura general"
                        onClicked: {
                            settings.autoReturnRight = true
                            settings.alignedRight = true
                            settings.positionMode = "right"
                            settings.alignmentEdited = true
                            settings.panelHeight = 48
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "No modifica las figuras ni los tamaños particulares de las islas."
                    }
                    }
                    ColumnLayout {
                        visible: settings.geometrySection === 1
                        Layout.fillWidth: true
                        spacing: 10
                    QQC2.Label {
                        text: "Terminaciones visuales"
                        color: "white"; font.bold: true
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "soledad"
                        text: "Soledad: el modelo inicial conserva la izquierda redondeada y termina recto a la derecha."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "soledad"
                        text: "SOLEDAD · Figura exterior"
                        color: "#cde6f5"; font.bold: true
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "soledad"
                        text: "Forma de Soledad"; color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        visible: settings.geometryScope === "soledad"
                        model: ["Izquierda redondeada / derecha recta (inicial)",
                                "Toda redondeada", "Toda cuadrada",
                                "Izquierda recta / derecha redondeada",
                                "Punta triangular izquierda / derecha recta"]
                        currentIndex: ["leftRoundRightSquare","rounded","square",
                                       "leftSquareRightRound","leftTip"]
                            .indexOf(settings.soledadShape)
                        onActivated: function(i) {
                            settings.soledadShape = ["leftRoundRightSquare","rounded",
                                "square","leftSquareRightRound","leftTip"][i]
                        }
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "malvina"
                        text: "MALVINA · Figura exterior y controles"
                        color: "#cde6f5"; font.bold: true
                    }
                    QQC2.Label {
                        text: "Forma de Malvina";
                        color: "white"
                        visible: settings.geometryScope === "malvina"
                    }
                    QQC2.ComboBox {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        model: ["Redondeada (inicial)", "Cuadrada",
                                "Izquierda redondeada / derecha recta",
                                "Izquierda recta / derecha redondeada",
                                "Punta triangular izquierda / derecha recta",
                                "Cápsula (extremos totalmente redondos)"]
                        id: malvinaFigureSelector
                        currentIndex: Math.max(0, ["rounded","square","leftRoundRightSquare",
                                       "leftSquareRightRound","leftTip","capsule"].indexOf(settings.malvinaShape))
                        onActivated: function(i) {
                            settings.malvinaShape = ["rounded","square",
                                "leftRoundRightSquare","leftSquareRightRound","leftTip","capsule"][i]
                        }
                    }
                    QQC2.Label {
                        text: "Botón engranaje de Malvina"
                        color: "white"
                        visible: settings.geometryScope === "malvina"
                    }
                    QQC2.ComboBox {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        model: ["Cuadrado (inicial)", "Cuadrado con esquinas redondeadas", "Circular", "Cápsula"]
                        currentIndex: Math.max(0,["square","rounded","circle","capsule"].indexOf(settings.malvinaGearButtonShape))
                        onActivated: function(i) {
                            settings.malvinaGearButtonShape = ["square","rounded","circle","capsule"][i]
                        }
                    }
                    QQC2.Label {
                        text: "Botón lupa de Malvina"
                        color: "white"
                        visible: settings.geometryScope === "malvina"
                    }
                    QQC2.ComboBox {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        model: ["Cuadrado (inicial)", "Cuadrado con esquinas redondeadas", "Circular", "Cápsula"]
                        currentIndex: Math.max(0,["square","rounded","circle","capsule"].indexOf(settings.malvinaSearchButtonShape))
                        onActivated: function(i) {
                            settings.malvinaSearchButtonShape = ["square","rounded","circle","capsule"][i]
                        }
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "shared"
                        text: "COMPARTIDAS · Controles del panel"
                        color: "#cde6f5"; font.bold: true
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "shared"
                        text: "Agarre de seis puntos"; color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        visible: settings.geometryScope === "shared"
                        model: ["Cuadrado", "Cuadrado con bordes redondeados (inicial)"]
                        currentIndex: settings.gripShape === "rounded" ? 1 : 0
                        onActivated: function(i) {
                            settings.gripShape = i === 1 ? "rounded" : "square"
                        }
                    }
                    QQC2.Label {
                        visible: settings.geometryScope === "shared"
                        text: "Botón de bandeja simulada"; color: "white"
                    }
                    QQC2.ComboBox {
                        Layout.fillWidth: true
                        visible: settings.geometryScope === "shared"
                        model: ["Redondeado (inicial)", "Cuadrado"]
                        currentIndex: settings.trayButtonShape === "square" ? 1 : 0
                        onActivated: function(i) {
                            settings.trayButtonShape = i === 1 ? "square" : "rounded"
                        }
                    }
                    }
                    ColumnLayout {
                        visible: settings.geometrySection === 2
                        Layout.fillWidth: true
                        spacing: 10
                    QQC2.Label { text: settings.geometryScope === "soledad" ? "Tamaño de Soledad" : "Tamaño de Malvina"; color: "white"; font.bold: true }
                    QQC2.Label {
                        text: "La altura elegida es constante durante el uso. Al aumentar una isla, Aplicar también aumenta la altura general si hace falta (máximo 120 px, con 4 px de margen)."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        visible: settings.geometryScope === "soledad"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura Soledad"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 32; to: 120; stepSize: 2
                            value: settings.soledadHeight
                            onMoved: settings.soledadHeight = Math.min(116, Math.round(value))
                        }
                        QQC2.Label {
                            text: Math.round(settings.soledadHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Altura Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 32; to: 120; stepSize: 2
                            value: settings.malvinaHeight
                            onMoved: settings.malvinaHeight = Math.min(116, Math.round(value))
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaHeight) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.geometryScope === "soledad" && settings.soledadShape !== "square" && settings.soledadShape !== "leftTip"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Esquinas Soledad"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 60; stepSize: 2
                            value: settings.soledadRadius
                            onMoved: settings.soledadRadius = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.soledadRadius) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.geometryScope === "malvina" && settings.malvinaShape !== "square" && settings.malvinaShape !== "leftTip" && settings.malvinaShape !== "capsule"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Esquinas Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 60; stepSize: 2
                            value: settings.malvinaRadius
                            onMoved: settings.malvinaRadius = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaRadius) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.geometryScope === "soledad"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Ancho mínimo Soledad"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 0; to: 420; stepSize: 2
                            value: settings.soledadMinWidth
                            onMoved: settings.soledadMinWidth = Math.round(value)
                        }
                        QQC2.Label {
                            text: settings.soledadMinWidth === 0 ? "Auto" : Math.round(settings.soledadMinWidth) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    RowLayout {
                        visible: settings.geometryScope === "malvina"
                        Layout.fillWidth: true
                        QQC2.Label { text: "Ancho Malvina"; color: "white"; Layout.preferredWidth: 170 }
                        QQC2.Slider {
                            Layout.fillWidth: true
                            from: 52; to: 220; stepSize: 2
                            value: settings.malvinaWidth
                            onMoved: settings.malvinaWidth = Math.round(value)
                        }
                        QQC2.Label {
                            text: Math.round(settings.malvinaWidth) + " px"
                            color: "white"; Layout.preferredWidth: 64
                        }
                    }
                    QQC2.Label {
                        text: "Si la altura de una isla supera la altura general, se limita al espacio disponible. El ancho mínimo de Soledad no reemplaza la expansión automática de fichas."
                        color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
                    }
                    QQC2.Button {
                        text: settings.geometryScope === "soledad"
                            ? "Restablecer figura y tamaño SOLEDAD"
                            : "Restablecer figura y tamaño MALVINA"
                        onClicked: {
                            if (settings.geometryScope === "soledad") {
                                settings.soledadHeight = 44
                                settings.soledadRadius = 22
                                settings.soledadMinWidth = 0
                                settings.soledadShape = "leftRoundRightSquare"
                            } else if (settings.geometryScope === "malvina") {
                                settings.malvinaHeight = 44
                                settings.malvinaRadius = 22
                                settings.malvinaWidth = 52
                                settings.malvinaShape = "rounded"
                            }
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Solo modifica la isla que estás configurando."
                    }
                    }
                }
            }
