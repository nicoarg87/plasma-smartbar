// Buscador experimental Malvina: controles en una sola fila y
// proveedores en panel flotante debajo, sin modificar grosor de isla.
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2
import "MalvinaUrlPolicy.js" as UrlPolicy

Item {
    id: search
    property bool expanded: false
    property string googleTemplate: "https://www.google.com/search?q={query}"
    property string duckTemplate: "https://duckduckgo.com/?q={query}"
    property string yahooTemplate: "https://search.yahoo.com/search?p={query}"
    // Precarga experimental q= solo con permiso para cada proveedor.
    // La página podría enviar el texto al cargar; nunca garantizar solo prellenado.
    property string chatGptUrl: "https://chatgpt.com/"
    property string geminiUrl: "https://gemini.google.com/app"
    property string claudeUrl: "https://claude.ai/new"
    property bool allowChatGptPrefill: false
    property bool allowGeminiPrefill: false
    property bool allowClaudePrefill: false
    readonly property var aiPrefillAllowed: [allowChatGptPrefill, allowGeminiPrefill, allowClaudePrefill]
    property int currentSection: 1 // proveedor seleccionado: Web de forma predeterminada (Google)
    property int webIndex: 0
    property int aiIndex: 0
    property bool webGoogleEnabled: true
    property bool webDuckEnabled: true
    property bool webYahooEnabled: true
    readonly property var webEnabled: [webGoogleEnabled, webDuckEnabled, webYahooEnabled]
    // 0: campo de texto, 1: fila Web, 2: fila IA. Es foco visual sin sacar foco al TextField.
    property int navigationSection: 0
    property int navigationIndex: 0
    property bool suppressPopupDismissal: false
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
        // Abrir solo el campo: la fila de proveedores aparece con Tab.
        // Evitar confundir el atajo local Meta+Espacio con la bandeja de opciones.
        expanded = true
        navigationSection = 0
        if (options.visible) {
            suppressPopupDismissal = true
            options.close()
        }
        queryInput.forceActiveFocus()
    }
    function openSelected() {
        const query = queryInput.text.trim()
        const isAi = currentSection === 2
        const template = isAi ? aiUrls[aiIndex] : webUrls[webIndex]
        if (!isAi && !webEnabled[webIndex]) {
            console.warn("Malvina: el buscador Web seleccionado está deshabilitado en Configuración")
            return
        }
        const result = isAi
            ? UrlPolicy.resolveAiPrefill(aiIndex, template, query, aiPrefillAllowed[aiIndex])
            : UrlPolicy.resolve(template, query, false)
        if (!result.ok) {
            console.warn("Malvina: " + result.reason)
            return
        }
        // Apertura exclusivamente al pulsar Enter; nada se transmite en Tab/Espacio.
        // q= es experimental, NO es garantía de precarga ni de envío controlado.
        if (result.warning) console.warn("Malvina: " + result.warning)
        if (result.experimental) console.log("Malvina: enlace IA experimental con permiso explícito")
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
        if (section === 1) {
            if (!webEnabled[index]) {
                console.warn("Malvina: proveedor Web deshabilitado")
                return
            }
            webIndex = index
        }
        else if (section === 2) aiIndex = index
        navigationSection = 0
        queryInput.forceActiveFocus()
    }
    function confirmCandidate() {
        if (navigationSection !== 0)
            chooseProvider(navigationSection, navigationIndex)
    }

    // Clic sobre otra aplicacion: la ventana de ensayo pierde actividad.
    // No intercepta clics externos ni manipula el escritorio KWin.
    Connections {
        target: search.Window.window
        function onActiveChanged() {
            if (target && !target.active && search.expanded)
                search.closeSearch()
        }
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
            QQC2.ToolTip.text: "Hacer búsqueda (Super + Espaciadora; ventana activa)"
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
        // Cerrar al pulsar fuera del panel y del campo que es su padre.
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent
        onClosed: {
            if (search.suppressPopupDismissal) {
                search.suppressPopupDismissal = false
            } else if (search.expanded) {
                search.closeSearch()
            }
        }
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
                        enabled: search.webEnabled[index]
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
