// Opciones del modulo Malvina: no conoce SO ni maneja claves/cookies.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

QQC2.ScrollView {
    id: panel
    property var settingsTarget
    clip: true
    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
    ColumnLayout {
        width: Math.max(0, panel.availableWidth - 8)
        spacing: 10
        QQC2.Label { text: "Buscador Malvina"; font.bold: true; color: "white" }
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
        QQC2.Label { text: "Buscadores Web: URLs HTTPS con {query}"; font.bold: true; color: "white" }
        QQC2.Label {
            text: "Podés habilitar o deshabilitar cada buscador Web. Los tres están disponibles por defecto; Enter abre la búsqueda en el navegador del sistema. Se compartirá la consulta con el buscador elegido cuando decidas buscar."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
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
        QQC2.Label { text: "Chats IA: sitios HTTPS"; font.bold: true; color: "white" }
        QQC2.Label {
            text: "El permiso autoriza únicamente a Malvina a enviar la consulta escrita al proveedor indicado al presionar Enter, mediante una URL experimental. La página podría procesarlo o enviarlo automáticamente. No autoriza acceso a archivos, contraseñas ni ventanas. Podés revocarlo destildando la casilla y pulsando Aplicar. El proveedor procesa datos bajo sus propias condiciones."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "EXPERIMENTAL: ChatGPT y Claude pueden recibir la consulta por un enlace con q al pulsar Enter si están autorizados. La web puede precargar, ignorar o incluso enviarla automáticamente. Gemini no admite esta precarga en la prueba realizada: se abre su página sin adjuntar el texto. Nunca se necesita sudo."
            color: "#ffe29a"; Layout.fillWidth: true; wrapMode: Text.WordWrap
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
