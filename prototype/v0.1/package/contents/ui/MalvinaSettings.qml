// Editor aislado de proveedores Malvina, dentro del visor experimental.
// No cambia el navegador predeterminado de KDE ni instala programas.
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

Window {
    id: editor
    visible: false
    flags: Qt.Dialog
    title: "Malvina · búsqueda Web e IA"
    width: 620
    height: 620
    minimumWidth: 480
    minimumHeight: 460
    color: "#242236"
    property string googleTemplate: "https://www.google.com/search?q={query}"
    property string duckTemplate: "https://duckduckgo.com/?q={query}"
    property string yahooTemplate: "https://search.yahoo.com/search?p={query}"
    property string chatGptUrl: "https://chatgpt.com/"
    property string geminiUrl: "https://gemini.google.com/app"
    property string claudeUrl: "https://claude.ai/new"
    signal saveRequested(string google, string duck, string yahoo,
                         string chatGpt, string gemini, string claude)
    function validTemplate(url) {
        return /^https:\/\//i.test(url.trim()) && url.indexOf("{query}") >= 0
    }
    function validSite(url) {
        return /^https:\/\//i.test(url.trim())
    }
    function save() {
        if (!validTemplate(googleTemplate) ||
            !validTemplate(duckTemplate) ||
            !validTemplate(yahooTemplate) ||
            !validSite(chatGptUrl) ||
            !validSite(geminiUrl) ||
            !validSite(claudeUrl)) {
            status.text = "Las URLs Web deben usar HTTPS e incluir {query}; IA debe usar HTTPS."
            return
        }
        saveRequested(googleTemplate.trim(), duckTemplate.trim(), yahooTemplate.trim(),
                      chatGptUrl.trim(), geminiUrl.trim(), claudeUrl.trim())
        status.text = "Preferencias de búsqueda guardadas."
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 9
        QQC2.Label {
            text: "Configuración de Malvina"
            color: "white"
            font.bold: true
            font.pixelSize: 18
        }
        QQC2.Label {
            text: "Navegador: se utiliza el predeterminado de KDE. Elegir un ejecutable concreto requiere integrar un lanzador nativo; este visor no cambia el navegador del sistema."
            color: "#ddd6e8"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        QQC2.Label {
            text: "Buscadores Web · {query} será reemplazado por el texto codificado"
            color: "white"
            font.bold: true
        }
        QQC2.Label { text: "Google"; color: "white" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: editor.googleTemplate
            onEditingFinished: editor.googleTemplate = text
        }
        QQC2.Label { text: "DuckDuckGo"; color: "white" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: editor.duckTemplate
            onEditingFinished: editor.duckTemplate = text
        }
        QQC2.Label { text: "Yahoo"; color: "white" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: editor.yahooTemplate
            onEditingFinished: editor.yahooTemplate = text
        }
        QQC2.Label { text: "Servicios IA · se abre el sitio; no se envía el texto automáticamente"; color: "white"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        QQC2.Label { text: "ChatGPT"; color: "white" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: editor.chatGptUrl
            onEditingFinished: editor.chatGptUrl = text
        }
        QQC2.Label { text: "Gemini"; color: "white" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: editor.geminiUrl
            onEditingFinished: editor.geminiUrl = text
        }
        QQC2.Label { text: "Claude"; color: "white" }
        QQC2.TextField {
            Layout.fillWidth: true
            text: editor.claudeUrl
            onEditingFinished: editor.claudeUrl = text
        }
        QQC2.Label {
            id: status
            text: "Enter busca en Google; Tab: Web, luego IA; flechas horizontales eligen proveedor."
            color: "#ddd6e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        RowLayout {
            Layout.fillWidth: true
            QQC2.Button {
                text: "Guardar"
                highlighted: true
                onClicked: editor.save()
            }
            QQC2.Button { text: "Cerrar"; onClicked: editor.close() }
        }
    }
}
