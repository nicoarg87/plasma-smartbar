// Buscador experimental Malvina: controles en una sola fila y
// proveedores en panel flotante debajo, sin modificar grosor de isla.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

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
    property int currentSection: 0 // 0: texto, 1: Web, 2: IA
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

    function focusSearch() {
        expanded = true
        currentSection = 0
        options.open()
        queryInput.forceActiveFocus()
    }
    function openSelected() {
        const query = queryInput.text.trim()
        if (!query.length) return
        let template = currentSection === 2 ? aiUrls[aiIndex] : webUrls[webIndex]
        let url = String(template).trim()
        if (!/^https:\/\//i.test(url)) {
            console.warn("Malvina: se rechazó URL sin HTTPS")
            return
        }
        // En web se sustituye la variable. Si es IA se abre el proveedor:
        // nunca afirmar que un enlace genérico envió el mensaje.
        if (currentSection !== 2) {
            if (url.indexOf("{query}") < 0) {
                console.warn("Malvina: plantilla web sin {query}")
                return
            }
            url = url.split("{query}").join(encodeURIComponent(query))
        }
        Qt.openUrlExternally(url)
    }
    function selectSection(index) {
        currentSection = Math.max(0, Math.min(2, index))
        if (currentSection > 0) options.open()
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
                search.selectSection((search.currentSection + 1) % 3)
                event.accepted = true
            }
            Keys.onBacktabPressed: function(event) {
                search.selectSection((search.currentSection + 2) % 3)
                event.accepted = true
            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Down) {
                    search.selectSection(Math.min(2, search.currentSection + 1))
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    search.selectSection(Math.max(0, search.currentSection - 1))
                    event.accepted = true
                } else if (event.key === Qt.Key_Left && search.currentSection === 1) {
                    search.webIndex = (search.webIndex + 2) % 3
                    event.accepted = true
                } else if (event.key === Qt.Key_Right && search.currentSection === 1) {
                    search.webIndex = (search.webIndex + 1) % 3
                    event.accepted = true
                } else if (event.key === Qt.Key_Left && search.currentSection === 2) {
                    search.aiIndex = (search.aiIndex + 2) % 3
                    event.accepted = true
                } else if (event.key === Qt.Key_Right && search.currentSection === 2) {
                    search.aiIndex = (search.aiIndex + 1) % 3
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    search.expanded = false
                    options.close()
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
                    model: search.webNames
                    delegate: QQC2.Button {
                        required property string modelData
                        required property int index
                        text: modelData
                        Layout.fillWidth: true
                        highlighted: search.currentSection === 1 && search.webIndex === index
                        onClicked: {
                            search.currentSection = 1
                            search.webIndex = index
                            search.openSelected()
                        }
                    }
                }
            }
            RowLayout {
                spacing: 3
                QQC2.Label { text: "IA"; color: "white"; Layout.preferredWidth: 44 }
                Repeater {
                    model: search.aiNames
                    delegate: QQC2.Button {
                        required property string modelData
                        required property int index
                        text: modelData
                        Layout.fillWidth: true
                        highlighted: search.currentSection === 2 && search.aiIndex === index
                        onClicked: {
                            search.currentSection = 2
                            search.aiIndex = index
                            search.openSelected()
                        }
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
