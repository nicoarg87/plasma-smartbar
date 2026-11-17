import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

QQC2.ScrollView {
    id: panel
    property var settingsTarget
    clip: true
    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded
    ColumnLayout {
        width: panel.availableWidth - 8
        spacing: 10
        QQC2.Label { text: "Buscador Malvina"; font.bold: true; color: "white" }
        QQC2.Label { text: "Navegador: predeterminado del sistema KDE. Elegir otro ejecutable requiere integración nativa posterior."; color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
        QQC2.Label { text: "Buscadores Web: URLs HTTPS con {query}"; font.bold: true; color: "white" }
        QQC2.Label { text: "Google"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaGoogleUrl; onEditingFinished: panel.settingsTarget.malvinaGoogleUrl = text }
        QQC2.Label { text: "DuckDuckGo"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaDuckUrl; onEditingFinished: panel.settingsTarget.malvinaDuckUrl = text }
        QQC2.Label { text: "Yahoo"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaYahooUrl; onEditingFinished: panel.settingsTarget.malvinaYahooUrl = text }
        QQC2.Label { text: "Servicios IA: se abre la página, sin enviar automáticamente el texto"; color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
        QQC2.Label { text: "ChatGPT"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaChatGptUrl; onEditingFinished: panel.settingsTarget.malvinaChatGptUrl = text }
        QQC2.Label { text: "Gemini"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaGeminiUrl; onEditingFinished: panel.settingsTarget.malvinaGeminiUrl = text }
        QQC2.Label { text: "Claude"; color: "white" }
        QQC2.TextField { Layout.fillWidth: true; text: panel.settingsTarget.malvinaClaudeUrl; onEditingFinished: panel.settingsTarget.malvinaClaudeUrl = text }
        QQC2.Label { text: "Tab selecciona Web y después IA. Las flechas cambian proveedor. Super + Espacio global en Wayland queda pendiente."; color: "#ddd6e8"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
    }
}
