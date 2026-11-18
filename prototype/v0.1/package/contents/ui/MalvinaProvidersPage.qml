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
        QQC2.Label { text: "Google"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaGoogleUrl; onEditingFinished: panel.settingsTarget.malvinaGoogleUrl = text }
        QQC2.Label { text: "DuckDuckGo"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaDuckUrl; onEditingFinished: panel.settingsTarget.malvinaDuckUrl = text }
        QQC2.Label { text: "Yahoo"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaYahooUrl; onEditingFinished: panel.settingsTarget.malvinaYahooUrl = text }
        QQC2.Label { text: "Chats IA: sitios HTTPS"; font.bold: true; color: "white" }
        QQC2.Label {
            text: "El permiso autoriza únicamente a Malvina a enviar la consulta escrita al proveedor indicado al presionar Enter, cuando exista una integración verificada. No autoriza acceso a archivos, contraseñas ni ventanas. Podés revocarlo destildando la casilla y pulsando Aplicar. El proveedor procesa datos bajo sus propias condiciones."
            color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "IMPORTANTE: el envío directo al chat todavía NO está implementado. Aunque autorices un proveedor, por ahora solo se abre su sitio sin enviar el texto. Iniciás sesión personalmente en tu navegador si lo necesitás; nunca se pide sudo."
            color: "#ffe29a"; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }
        QQC2.Label { text: "ChatGPT"; color: "white"; font.bold: true }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaChatGptUrl; onEditingFinished: panel.settingsTarget.malvinaChatGptUrl = text }
        QQC2.CheckBox {
            text: "Autorizo envío de texto a ChatGPT (cuando esté disponible)"
            checked: panel.settingsTarget.malvinaAllowChatGpt
            onToggled: panel.settingsTarget.malvinaAllowChatGpt = checked
        }
        QQC2.Label { text: "Gemini"; color: "white"; font.bold: true }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaGeminiUrl; onEditingFinished: panel.settingsTarget.malvinaGeminiUrl = text }
        QQC2.CheckBox {
            text: "Autorizo envío de texto a Gemini (cuando esté disponible)"
            checked: panel.settingsTarget.malvinaAllowGemini
            onToggled: panel.settingsTarget.malvinaAllowGemini = checked
        }
        QQC2.Label { text: "Claude"; color: "white"; font.bold: true }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaClaudeUrl; onEditingFinished: panel.settingsTarget.malvinaClaudeUrl = text }
        QQC2.CheckBox {
            text: "Autorizo envío de texto a Claude (cuando esté disponible)"
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
