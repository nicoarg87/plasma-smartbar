// Opciones del modulo Malvina: no conoce SO ni maneja claves/cookies.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import "MalvinaSlots.js" as Slots

QQC2.ScrollView {
    id: panel
    property var settingsTarget
    property string feedback: ""
    property int sectionIndex: 0 // General, Web, IA, personalizados: no altera proveedores guardados.
    function extrasFor(section) {
        return Slots.extras(section,section === "web" ?
                            settingsTarget.malvinaExtraWeb : settingsTarget.malvinaExtraAi)
    }
    function isHidden(section,id) {
        const hidden=section === "web" ? settingsTarget.malvinaHiddenWeb : settingsTarget.malvinaHiddenAi
        return String(hidden).split(",").indexOf(id)>=0
    }
    function toggleHidden(section,id,visible) {
        const key=section === "web" ? "malvinaHiddenWeb" : "malvinaHiddenAi"
        const list=String(settingsTarget[key]).split(",").filter(x=>x && x!==id)
        if (!visible) list.push(id)
        settingsTarget[key]=list.join(",")
    }
    function addExtra(section,name,url) {
        const key=section === "web" ? "malvinaExtraWeb" : "malvinaExtraAi"
        const hidden=section === "web" ? settingsTarget.malvinaHiddenWeb : settingsTarget.malvinaHiddenAi
        const result=Slots.add(section,settingsTarget[key],name,url,hidden)
        if (result.ok) {
            settingsTarget[key]=result.value
            feedback="Proveedor agregado. Pulsá Aplicar para guardarlo."
        } else feedback=result.reason
        return result.ok
    }
    function updateExtra(section,id,name,url,enabled) {
        const key=section === "web" ? "malvinaExtraWeb" : "malvinaExtraAi"
        const result=Slots.update(section,settingsTarget[key],id,name,url,enabled)
        if (result.ok) {
            settingsTarget[key]=result.value
            feedback="Cambios preparados. Pulsá Aplicar."
        } else feedback=result.reason
    }
    function deleteExtra(section,id) {
        const key=section === "web" ? "malvinaExtraWeb" : "malvinaExtraAi"
        settingsTarget[key]=Slots.remove(section,settingsTarget[key],id)
        feedback="Proveedor quitado. Pulsá Aplicar."
    }
    clip: true
    contentWidth: Math.max(0, availableWidth - 8)
    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
    ColumnLayout {
        width: Math.max(0, panel.availableWidth - 8)
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: ["General", "Web", "IA", "Personalizados"]
                delegate: QQC2.Button {
                    required property int index
                    required property string modelData
                    Layout.fillWidth: true
                    text: modelData
                    highlighted: panel.sectionIndex === index
                    onClicked: { panel.sectionIndex = index; panel.contentItem.contentY = 0 }
                }
            }
        }
        ColumnLayout {
            visible: panel.sectionIndex === 0
            Layout.fillWidth: true
            spacing: 9
        QQC2.Label { text: "Buscador Malvina"; font.bold: true; color: "white" }
        QQC2.CheckBox {
            text: "IA: mostrar lista recortada con desplazamiento horizontal"
            checked: panel.settingsTarget.malvinaCompactAi
            onToggled: panel.settingsTarget.malvinaCompactAi = checked
        }
        QQC2.Label {
            text: "Sin marcar (predeterminado), todas las IA aparecen en una fila horizontal completa; las fichas se adaptan al ancho disponible. Con la casilla marcada, la lista se recorta y se desplaza horizontalmente. La isla no aumenta su grosor."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }

        QQC2.Label {
            text: "Orden y prioridad de búsqueda"
            font.bold: true; color: "white"
        }
        QQC2.Label {
            text: "La fila de arriba tiene prioridad: la primera opción habilitada de izquierda a derecha se usa por defecto al abrir una nueva búsqueda. En el selector podés arrastrar Web/IA verticalmente y cada proveedor horizontalmente. También podés invertir las filas acá."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Button {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaWebFirst ? "Arriba: Web · Abajo: IA — Invertir" :
                                                          "Arriba: IA · Abajo: Web — Invertir"
            onClicked: panel.settingsTarget.malvinaWebFirst = !panel.settingsTarget.malvinaWebFirst
        }
        QQC2.Label {
            text: "Web, izquierda a derecha: " + panel.settingsTarget.malvinaWebOrder
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "IA, izquierda a derecha: " + panel.settingsTarget.malvinaAiOrder
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }

        QQC2.Label {
            text: "Cada proveedor tiene un nombre descriptivo editable y una dirección web independiente. El nombre aparece en el selector, pero no cambia por sí solo el sitio ni sus permisos. Usá Aplicar para guardar."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "Navegador para búsquedas y chats:"
            font.bold: true; color: "white"
        }
        QQC2.ComboBox {
            id: browserChoice
            Layout.fillWidth: true
            model: ["Predeterminado del sistema (KDE)"]
            currentIndex: 0
            enabled: false
        }
        QQC2.Label {
            text: "Se utiliza el navegador predeterminado configurado en KDE. Elegir otro navegador desde Malvina requiere una integración nativa adicional; no se ejecutan comandos arbitrarios."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        }
        ColumnLayout {
            visible: panel.sectionIndex === 1
            Layout.fillWidth: true
            spacing: 9
        QQC2.Label { text: "Buscadores Web: URLs HTTPS con {query}"; font.bold: true; color: "white" }
        QQC2.Label {
            text: "Podés habilitar o deshabilitar cada buscador Web. Los tres están disponibles por defecto; Enter abre la búsqueda en el navegador del sistema. Se compartirá la consulta con el buscador elegido cuando decidas buscar."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.CheckBox {
            text: panel.isHidden("web","google") ? "Restaurar Google en el selector" : "Mostrar Google en el selector"
            checked: !panel.isHidden("web","google")
            onToggled: panel.toggleHidden("web","google",checked)
        }
        QQC2.Label { text: "Nombre visible (Google)"; color: "#ddd6e8" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaGoogleName
            placeholderText: "Google"
            maximumLength: 48
            onTextEdited: panel.settingsTarget.malvinaGoogleName = text
        }
        QQC2.Label { text: "Google"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaGoogleUrl; onEditingFinished: panel.settingsTarget.malvinaGoogleUrl = text }
        QQC2.CheckBox {
            text: "Habilitar búsquedas con Google"
            checked: panel.settingsTarget.malvinaWebGoogleEnabled
            onToggled: panel.settingsTarget.malvinaWebGoogleEnabled = checked
        }
        QQC2.CheckBox {
            text: panel.isHidden("web","duck") ? "Restaurar DuckDuckGo en el selector" : "Mostrar DuckDuckGo en el selector"
            checked: !panel.isHidden("web","duck")
            onToggled: panel.toggleHidden("web","duck",checked)
        }
        QQC2.Label { text: "Nombre visible (DuckDuckGo)"; color: "#ddd6e8" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaDuckName
            placeholderText: "DuckDuckGo"
            maximumLength: 48
            onTextEdited: panel.settingsTarget.malvinaDuckName = text
        }
        QQC2.Label { text: "DuckDuckGo"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaDuckUrl; onEditingFinished: panel.settingsTarget.malvinaDuckUrl = text }
        QQC2.CheckBox {
            text: "Habilitar búsquedas con DuckDuckGo"
            checked: panel.settingsTarget.malvinaWebDuckEnabled
            onToggled: panel.settingsTarget.malvinaWebDuckEnabled = checked
        }
        QQC2.CheckBox {
            text: panel.isHidden("web","yahoo") ? "Restaurar Yahoo en el selector" : "Mostrar Yahoo en el selector"
            checked: !panel.isHidden("web","yahoo")
            onToggled: panel.toggleHidden("web","yahoo",checked)
        }
        QQC2.Label { text: "Nombre visible (Yahoo)"; color: "#ddd6e8" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaYahooName
            placeholderText: "Yahoo"
            maximumLength: 48
            onTextEdited: panel.settingsTarget.malvinaYahooName = text
        }
        QQC2.Label { text: "Yahoo"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaYahooUrl; onEditingFinished: panel.settingsTarget.malvinaYahooUrl = text }
        QQC2.CheckBox {
            text: "Habilitar búsquedas con Yahoo"
            checked: panel.settingsTarget.malvinaWebYahooEnabled
            onToggled: panel.settingsTarget.malvinaWebYahooEnabled = checked
        }
        }
        ColumnLayout {
            visible: panel.sectionIndex === 2
            Layout.fillWidth: true
            spacing: 9
        QQC2.Label { text: "Chats IA: sitios HTTPS"; font.bold: true; color: "white" }
        QQC2.Label {
            text: "El permiso autoriza únicamente a Malvina a enviar la consulta escrita al proveedor indicado al presionar Enter, mediante una URL experimental. La página podría procesarlo o enviarlo automáticamente. No autoriza acceso a archivos, contraseñas ni ventanas. Podés revocarlo destildando la casilla y pulsando Aplicar. El proveedor procesa datos bajo sus propias condiciones."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "EXPERIMENTAL: ChatGPT y Claude pueden recibir la consulta por un enlace con q al pulsar Enter si están autorizados. La web puede precargar, ignorar o incluso enviarla automáticamente. Gemini no admite esta precarga en la prueba realizada: se abre su página sin adjuntar el texto. Nunca se necesita sudo."
            color: "#ffe29a"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.CheckBox {
            text: panel.isHidden("ai","chatgpt") ? "Restaurar ChatGPT en el selector" : "Mostrar ChatGPT en el selector"
            checked: !panel.isHidden("ai","chatgpt")
            onToggled: panel.toggleHidden("ai","chatgpt",checked)
        }
        QQC2.Label { text: "Nombre visible (ChatGPT)"; color: "#ddd6e8" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaChatGptName
            placeholderText: "ChatGPT"
            maximumLength: 48
            onTextEdited: panel.settingsTarget.malvinaChatGptName = text
        }
        QQC2.Label { text: "ChatGPT"; color: "white"; font.bold: true }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaChatGptUrl; onEditingFinished: panel.settingsTarget.malvinaChatGptUrl = text }
        QQC2.CheckBox {
            text: "Autorizo envío de texto a ChatGPT (enlace experimental)"
            checked: panel.settingsTarget.malvinaAllowChatGpt
            onToggled: panel.settingsTarget.malvinaAllowChatGpt = checked
        }
        QQC2.CheckBox {
            text: panel.isHidden("ai","gemini") ? "Restaurar Gemini en el selector" : "Mostrar Gemini en el selector"
            checked: !panel.isHidden("ai","gemini")
            onToggled: panel.toggleHidden("ai","gemini",checked)
        }
        QQC2.Label { text: "Nombre visible (Gemini)"; color: "#ddd6e8" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaGeminiName
            placeholderText: "Gemini"
            maximumLength: 48
            onTextEdited: panel.settingsTarget.malvinaGeminiName = text
        }
        QQC2.Label { text: "Gemini"; color: "white"; font.bold: true }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaGeminiUrl; onEditingFinished: panel.settingsTarget.malvinaGeminiUrl = text }
        QQC2.CheckBox {
            text: "Permiso para Gemini (sin envío disponible todavía)"
            checked: panel.settingsTarget.malvinaAllowGemini
            onToggled: panel.settingsTarget.malvinaAllowGemini = checked
        }
        QQC2.Label {
            text: "Gemini: el parámetro q no funcionó en CachyOS. Tu permiso queda guardado para una integración futura, pero Malvina NO envía texto a Gemini. La sesión del navegador no cambia esta limitación."
            color: "#ffe29a"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.CheckBox {
            text: panel.isHidden("ai","claude") ? "Restaurar Claude en el selector" : "Mostrar Claude en el selector"
            checked: !panel.isHidden("ai","claude")
            onToggled: panel.toggleHidden("ai","claude",checked)
        }
        QQC2.Label { text: "Nombre visible (Claude)"; color: "#ddd6e8" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: panel.settingsTarget.malvinaClaudeName
            placeholderText: "Claude"
            maximumLength: 48
            onTextEdited: panel.settingsTarget.malvinaClaudeName = text
        }
        QQC2.Label { text: "Claude"; color: "white"; font.bold: true }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaClaudeUrl; onEditingFinished: panel.settingsTarget.malvinaClaudeUrl = text }
        QQC2.CheckBox {
            text: "Autorizo envío de texto a Claude (enlace experimental)"
            checked: panel.settingsTarget.malvinaAllowClaude
            onToggled: panel.settingsTarget.malvinaAllowClaude = checked
        }
        }
        ColumnLayout {
            visible: panel.sectionIndex === 3
            Layout.fillWidth: true
            spacing: 9
        QQC2.Label {
            text: "Proveedores personalizados (hasta 10 visibles en Web y 10 en IA)"
            font.bold: true; color: "white"
        }
        QQC2.Label {
            text: "Los agregados por el usuario tienen nombre y URL propios. En Web, la URL debe ser HTTPS e incluir {query}. Las IA nuevas solo abren su página, sin enviar automáticamente el texto. Quitar los originales los oculta y se pueden restaurar."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        Repeater {
            model: ["web","ai"]
            delegate: ColumnLayout {
                required property string modelData
                Layout.fillWidth: true
                spacing: 5
                QQC2.Label {
                    text: modelData === "web" ? "Añadir buscador Web" : "Añadir IA"
                    color: "white"; font.bold: true
                }
                QQC2.TextField {
                    id: extraName
                    Layout.fillWidth: true
                    maximumLength: 48
                    placeholderText: "Nombre descriptivo"
                }
                QQC2.TextField {
                    id: extraUrl
                    Layout.fillWidth: true
                    placeholderText: modelData === "web" ?
                        "https://ejemplo.com/search?q={query}" : "https://ejemplo.com/"
                }
                QQC2.Button {
                    Layout.fillWidth: true
                    text: "Agregar a " + (modelData === "web" ? "Web" : "IA")
                    onClicked: {
                        if (panel.addExtra(modelData,extraName.text,extraUrl.text)) {
                            extraName.text=""
                            extraUrl.text=""
                        }
                    }
                }
                Repeater {
                    model: panel.extrasFor(modelData)
                    delegate: ColumnLayout {
                        id: extraEditor
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 3
                        QQC2.Label {
                            text: "Proveedor: " + extraEditor.modelData.name
                            color: "white"; font.bold: true
                        }
                        QQC2.TextField {
                            id: editName
                            Layout.fillWidth: true
                            text: extraEditor.modelData.name
                            maximumLength: 48
                        }
                        QQC2.TextField {
                            id: editUrl
                            Layout.fillWidth: true
                            text: extraEditor.modelData.url
                        }
                        QQC2.CheckBox {
                            id: extraEnabled
                            checked: extraEditor.modelData.enabled
                            text: "Habilitado"
                        }
                        RowLayout {
                            QQC2.Button {
                                text: "Actualizar"
                                onClicked: panel.updateExtra(
                                    extraEditor.modelData.id.startsWith("web-") ? "web" : "ai",
                                    extraEditor.modelData.id,editName.text,editUrl.text,extraEnabled.checked)
                            }
                            QQC2.Button {
                                text: "Quitar"
                                onClicked: panel.deleteExtra(
                                    extraEditor.modelData.id.startsWith("web-") ? "web" : "ai",
                                    extraEditor.modelData.id)
                            }
                        }
                    }
                }
            }
        }
        QQC2.Label {
            text: panel.feedback
            visible: panel.feedback.length > 0
            color: "#ffe29a"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "Los tres permisos comienzan desactivados. Aplicar guarda tus preferencias sin cerrar la configuración. Seleccionar un proveedor con Tab/Espacio no envía datos."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "Tab selecciona Web y después IA. Las flechas cambian proveedor. Super + Espacio global en Wayland queda pendiente."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        }
    }
}
