// Buscador experimental Malvina: controles en una sola fila y
// proveedores en panel flotante debajo, sin modificar grosor de isla.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import "MalvinaUrlPolicy.js" as UrlPolicy

Item {
    id: search
    property bool expanded: false
    property string googleTemplate: "https://www.google.com/search?q={query}"
    property string duckTemplate: "https://duckduckgo.com/?q={query}"
    property string yahooTemplate: "https://search.yahoo.com/search?p={query}"
    // Sin contrato universal para enviar prompts por enlaces públicos.
    // Los servicios de IA se abren en su sitio, sin enviar la consulta.
    property string chatGptUrl: "https://chatgpt.com/"
    property string geminiUrl: "https://gemini.google.com/app"
    property string claudeUrl: "https://claude.ai/new"
    property int currentSection: 1 // proveedor seleccionado: Web de forma predeterminada (Google)
    property int webIndex: 0
    property int aiIndex: 0
    signal requestSettings()
    signal requestInstalledApps()
    readonly property var webNames: ["Google", "DuckDuckGo", "Yahoo"]
    readonly property var aiNames: ["ChatGPT", "Gemini", "Claude"]
    readonly property var webUrls: [googleTemplate, duckTemplate, yahooTemplate]
    readonly property var aiUrls: [chatGptUrl, geminiUrl, claudeUrl]
    implicitWidth: expanded ? 396 : 76
    implicitHeight: 34

    function closeSearch() {
        expanded = false
        options.close()
    }
    function focusSearch() {
        expanded = true
        options.open()
        queryInput.forceActiveFocus()
    }
    function openSelected() {
        const query = queryInput.text.trim()
        const isAi = currentSection === 2
        const template = isAi ? aiUrls[aiIndex] : webUrls[webIndex]
        const result = UrlPolicy.resolve(template, query, isAi)
        if (!result.ok) {
            console.warn("Malvina: " + result.reason)
            return
        }
        // Una unica salida hacia el navegador predeterminado de KDE.
        // Nunca ejecutar comandos del sistema ni enviar prompts IA por enlaces genericos.
        Qt.openUrlExternally(result.url)
    }
    // Seleccionar no navega: la salida externa ocurre solo con Enter en el campo.
    function chooseProvider(section, index) {
        currentSection = section
        if (section === 1) webIndex = index
        else aiIndex = index
        queryInput.forceActiveFocus()
    }
    function focusProvider(section, index) {
        options.open()
        const repeater = section === 1 ? webRepeater : aiRepeater
        const button = repeater.itemAt(index)
        if (button) button.forceActiveFocus()
    }
    function advanceProvider(section, index, backwards) {
        const linearIndex = section === 1 ? index : (3 + index)
        const next = (linearIndex + (backwards ? 5 : 1)) % 6
        focusProvider(next < 3 ? 1 : 2, next % 3)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 3
        QQC2.Button {
            id: gear
            Layout.preferredWidth: 34; Layout.preferredHeight: 32
            icon.name: "configure"
            text: ""
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Configuración de Malvina"
            onClicked: search.requestSettings()
        }
        QQC2.Button {
            Layout.preferredWidth: 34; Layout.preferredHeight: 32
            icon.name: "edit-find"
            text: ""
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Abrir búsqueda"
            onClicked: {
                if (search.expanded) {
                    search.expanded = false
                    options.close()
                } else search.focusSearch()
            }
        }
        QQC2.TextField {
            id: queryInput
            visible: search.expanded
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            placeholderText: "Buscar en Web o IA…"
            selectByMouse: true
            onAccepted: search.openSelected()
            Keys.onTabPressed: function(event) {
                search.focusProvider(1, 0)
                event.accepted = true
            }
            Keys.onBacktabPressed: function(event) {
                search.focusProvider(2, 2)
                event.accepted = true
            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    search.closeSearch()
                    event.accepted = true
                }
            }
        }
    }
    QQC2.Popup {
        id: options
        parent: search
        x: 0
        y: search.height + 6
        width: 396
        height: 152
        padding: 8
        modal: false
        focus: false
        closePolicy: QQC2.Popup.CloseOnEscape
        background: Rectangle {
            radius: 10
            color: "#172a3d"
            border.width: 1
            border.color: "#4e8499"
        }
        contentItem: ColumnLayout {
            spacing: 4
            RowLayout {
                spacing: 3
                QQC2.Label { text: "Web"; color: "white"; Layout.preferredWidth: 44 }
                Repeater {
                    id: webRepeater
                    model: search.webNames
                    delegate: QQC2.Button {
                        required property string modelData
                        required property int index
                        text: modelData
                        Layout.fillWidth: true
                        highlighted: search.currentSection === 1 && search.webIndex === index
                        onClicked: search.chooseProvider(1, index)
                        Keys.onTabPressed: function(event) {
                            search.advanceProvider(1, index, false)
                            event.accepted = true
                        }
                        Keys.onBacktabPressed: function(event) {
                            search.advanceProvider(1, index, true)
                            event.accepted = true
                        }
                        Keys.onEscapePressed: search.closeSearch()
                    }
                }
            }
            RowLayout {
                spacing: 3
                QQC2.Label { text: "IA"; color: "white"; Layout.preferredWidth: 44 }
                Repeater {
                    id: aiRepeater
                    model: search.aiNames
                    delegate: QQC2.Button {
                        required property string modelData
                        required property int index
                        text: modelData
                        Layout.fillWidth: true
                        highlighted: search.currentSection === 2 && search.aiIndex === index
                        onClicked: search.chooseProvider(2, index)
                        Keys.onTabPressed: function(event) {
                            search.advanceProvider(2, index, false)
                            event.accepted = true
                        }
                        Keys.onBacktabPressed: function(event) {
                            search.advanceProvider(2, index, true)
                            event.accepted = true
                        }
                        Keys.onEscapePressed: search.closeSearch()
                    }
                }
            }
            QQC2.Button {
                Layout.fillWidth: true
                text: "Aplicaciones (maqueta)"
                icon.name: "applications-all"
                onClicked: {
                    options.close()
                    search.expanded = false
                    search.requestInstalledApps()
                }
            }
        }
    }
}
