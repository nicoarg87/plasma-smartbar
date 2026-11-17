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
    // 0: campo de texto, 1: fila Web, 2: fila IA. Es foco visual sin sacar foco al TextField.
    property int navigationSection: 0
    property int navigationIndex: 0
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
        navigationSection = 0
        options.close()
    }
    function focusSearch() {
        expanded = true
        navigationSection = 0
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
    // Navegacion por filas. El foco real permanece en TextField para que Tab
    // no dependa del manejo de foco entre Popup y ventana en Qt/Wayland.
    function moveSection(backwards) {
        if (!options.opened) options.open()
        navigationSection = (navigationSection + (backwards ? 2 : 1)) % 3
        navigationIndex = navigationSection === 1 ? webIndex : aiIndex
    }
    function moveCandidate(delta) {
        if (navigationSection === 0) return
        navigationIndex = (navigationIndex + delta + 3) % 3
    }
    // Solo elegir: no abrir la URL ni modificar la consulta.
    function chooseProvider(section, index) {
        currentSection = section
        if (section === 1) webIndex = index
        else if (section === 2) aiIndex = index
        navigationSection = 0
        queryInput.forceActiveFocus()
    }
    function confirmCandidate() {
        if (navigationSection !== 0)
            chooseProvider(navigationSection, navigationIndex)
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
                if (search.expanded) search.closeSearch()
                else search.focusSearch()
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
            Keys.priority: Keys.BeforeItem
            Keys.onTabPressed: function(event) {
                search.moveSection(false)
                event.accepted = true
            }
            Keys.onBacktabPressed: function(event) {
                search.moveSection(true)
                event.accepted = true
            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                    search.moveSection(event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier))
                    event.accepted = true
                } else if (search.navigationSection !== 0 &&
                           (event.key === Qt.Key_Left || event.key === Qt.Key_Right)) {
                    search.moveCandidate(event.key === Qt.Key_Left ? -1 : 1)
                    event.accepted = true
                } else if (search.navigationSection !== 0 && event.key === Qt.Key_Space) {
                    search.confirmCandidate()
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
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
                QQC2.Label { text: search.navigationSection === 1 ? "▶ Web" : "Web"; color: search.navigationSection === 1 ? "#9be8ff" : "white"; Layout.preferredWidth: 55 }
                Repeater {
                    id: webRepeater
                    model: search.webNames
                    delegate: QQC2.Button {
                        required property string modelData
                        required property int index
                        text: modelData
                        Layout.fillWidth: true
                        highlighted: (search.navigationSection === 1 && search.navigationIndex === index) ||
                                     (search.navigationSection === 0 && search.currentSection === 1 && search.webIndex === index)
                        onClicked: search.chooseProvider(1, index)
                    }
                }
            }
            RowLayout {
                spacing: 3
                QQC2.Label { text: search.navigationSection === 2 ? "▶ IA" : "IA"; color: search.navigationSection === 2 ? "#9be8ff" : "white"; Layout.preferredWidth: 55 }
                Repeater {
                    id: aiRepeater
                    model: search.aiNames
                    delegate: QQC2.Button {
                        required property string modelData
                        required property int index
                        text: modelData
                        Layout.fillWidth: true
                        highlighted: (search.navigationSection === 2 && search.navigationIndex === index) ||
                                     (search.navigationSection === 0 && search.currentSection === 2 && search.aiIndex === index)
                        onClicked: search.chooseProvider(2, index)
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
