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
    property string googleName: "Google"
    property string duckName: "DuckDuckGo"
    property string yahooName: "Yahoo"
    property string chatGptName: "ChatGPT"
    property string geminiName: "Gemini"
    property string claudeName: "Claude"
    property bool allowChatGptPrefill: false
    property bool allowGeminiPrefill: false
    property bool allowClaudePrefill: false
    readonly property var aiPrefillAllowed: [allowChatGptPrefill, allowGeminiPrefill, allowClaudePrefill]
    property int currentSection: 1 // 1: Web, 2: IA; se reinicia a fila superior al abrir
    property int webIndex: 0
    property int aiIndex: 0
    property bool webGoogleEnabled: true
    property bool webDuckEnabled: true
    property bool webYahooEnabled: true
    readonly property var webEnabled: [webGoogleEnabled, webDuckEnabled, webYahooEnabled]
    property bool webFirst: true
    property string webOrder: "google,duck,yahoo"
    property string aiOrder: "chatgpt,gemini,claude"
    readonly property var orderedWebIds: webOrder.split(",")
    readonly property var orderedAiIds: aiOrder.split(",")
    signal requestOrderChange(bool webFirst, string webOrder, string aiOrder)
    function nameFor(id) {
        const names = {
            google: googleName, duck: duckName, yahoo: yahooName,
            chatgpt: chatGptName, gemini: geminiName, claude: claudeName
        }
        return names[id] || id
    }
    function enabledFor(id) {
        return id === "google" ? webGoogleEnabled :
               id === "duck" ? webDuckEnabled :
               id === "yahoo" ? webYahooEnabled : true
    }
    function urlFor(id) {
        const urls = {
            google: googleTemplate, duck: duckTemplate, yahoo: yahooTemplate,
            chatgpt: chatGptUrl, gemini: geminiUrl, claude: claudeUrl
        }
        return urls[id] || ""
    }
    function aiIndexFor(id) { return ["chatgpt", "gemini", "claude"].indexOf(id) }
    function webIdAt(index) { return orderedWebIds[Math.max(0, Math.min(2,index))] }
    function aiIdAt(index) { return orderedAiIds[Math.max(0, Math.min(2,index))] }
    function firstEnabledWebIndex() {
        for (let i=0;i<3;i++) if (enabledFor(webIdAt(i))) return i
        return -1
    }
    function resetDefault() {
        currentSection = webFirst ? 1 : 2
        webIndex = Math.max(0, firstEnabledWebIndex())
        aiIndex = 0
        navigationSection = 0
        navigationIndex = 0
    }
    function applyOrder(firstWeb, webList, aiList) {
        webFirst = firstWeb
        webOrder = webList
        aiOrder = aiList
        resetDefault()
        requestOrderChange(webFirst, webOrder, aiOrder)
    }
    function swapRows() {
        applyOrder(!webFirst, webOrder, aiOrder)
    }
    function reorderProvider(section, fromIndex, destinationIndex) {
        if (fromIndex === destinationIndex || fromIndex < 0 || destinationIndex < 0 ||
            fromIndex > 2 || destinationIndex > 2) return
        const arr = (section === 1 ? orderedWebIds : orderedAiIds).slice()
        const moved = arr.splice(fromIndex, 1)[0]
        arr.splice(destinationIndex, 0, moved)
        if (section === 1) applyOrder(webFirst, arr.join(","), aiOrder)
        else applyOrder(webFirst, webOrder, arr.join(","))
    }
    // 0: campo de texto, 1: fila Web, 2: fila IA. Es foco visual sin sacar foco al TextField.
    property int navigationSection: 0
    property int navigationIndex: 0
    property bool suppressPopupDismissal: false
    property string queryText: ""
    // Único editor: aumenta su superficie hacia abajo, sin otro Popup.
    readonly property int multilineMaxHeight: 220
    property real maximumSearchWidth: 520
    readonly property real desiredEditorWidth: Math.min(maximumSearchWidth,
        queryText.length > 0 ? maximumSearchWidth : 396)
    readonly property bool expandedDown: queryText.indexOf("\n") >= 0 ||
                                          queryText.length > 70
    readonly property real desiredEditorHeight: expandedDown
        ? Math.min(multilineMaxHeight, Math.max(56, queryInput.contentHeight + 12))
        : 32
    function longestLineLength() {
        const lines = queryText.split("\n")
        let longest = 0
        for (let i = 0; i < lines.length; ++i)
            longest = Math.max(longest, lines[i].length)
        return longest
    }
    signal requestSettings()
    signal requestInstalledApps()
    // El Popup ES el único editor: mismo lugar en la isla, sin duplicarlo.
    implicitWidth: expanded ? desiredEditorWidth + 73 : 76
    implicitHeight: 34
    onExpandedChanged: {
        if (expanded) {
            fieldPopup.open()
            queryInput.forceActiveFocus()
        } else {
            fieldPopup.close()
        }
    }

    function closeSearch() {
        expanded = false
        navigationSection = 0
        options.close()
    }
    function focusSearch() {
        // Cada nueva búsqueda empieza en la primera opción válida de la fila superior.
        resetDefault()
        expanded = true
        if (options.visible) {
            suppressPopupDismissal = true
            options.close()
        }
        queryInput.forceActiveFocus()
    }
    function openSelected() {
        const query = queryText.trim()
        const isAi = currentSection === 2
        const providerId = isAi ? aiIdAt(aiIndex) : webIdAt(webIndex)
        const template = urlFor(providerId)
        if (!isAi && !enabledFor(providerId)) {
            console.warn("Malvina: el buscador Web seleccionado está deshabilitado en Configuración")
            return
        }
        const result = isAi
            ? UrlPolicy.resolveAiPrefill(aiIndexFor(providerId), template, query,
                                         aiPrefillAllowed[aiIndexFor(providerId)])
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
    // Navegacion por filas. El foco real permanece en TextArea para que Tab
    // no dependa del manejo de foco entre Popup y ventana en Qt/Wayland.
    function clearQuery() {
        queryInput.text = ""
        queryInput.forceActiveFocus()
        navigationSection = 0
    }
    function addLine() {
        const p = queryInput.cursorPosition
        queryInput.insert(p, "\n")
        queryInput.cursorPosition = p + 1
    }
    function activeEditorFocus() {
        queryInput.forceActiveFocus()
    }
    function handleEditorKey(event) {
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            moveSection(event.key === Qt.Key_Backtab || !!(event.modifiers & Qt.ShiftModifier))
            event.accepted = true
        } else if (navigationSection !== 0 && (event.key === Qt.Key_Left || event.key === Qt.Key_Right)) {
            moveCandidate(event.key === Qt.Key_Left ? -1 : 1)
            event.accepted = true
        } else if (navigationSection !== 0 && event.key === Qt.Key_Space) {
            confirmCandidate()
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            closeSearch()
            event.accepted = true
        } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) &&
                   (event.modifiers & Qt.ShiftModifier)) {
            addLine()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            openSelected()
            event.accepted = true
        }
    }
    function moveSection(backwards) {
        if (!options.opened) options.open()
        const sections = webFirst ? [0, 1, 2] : [0, 2, 1]
        const n = sections.indexOf(navigationSection)
        navigationSection = sections[(n + (backwards ? 2 : 1)) % 3]
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
            if (!enabledFor(webIdAt(index))) {
                console.warn("Malvina: proveedor Web deshabilitado")
                return
            }
            webIndex = index
        }
        else if (section === 2) aiIndex = index
        navigationSection = 0
        activeEditorFocus()
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
        // Área vacía que reserva espacio para el único campo real,
        // alojado en Popup sobre la misma posición para capturar clics.
        Item {
            id: editorAnchor
            visible: search.expanded
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.minimumWidth: 80
        }
    }

    QQC2.Popup {
        id: fieldPopup
        parent: search
        x: 73
        y: 1
        width: Math.max(80, search.width - 73)
        height: search.desiredEditorHeight
        padding: 0
        modal: false
        focus: false
        closePolicy: QQC2.Popup.NoAutoClose
        background: Rectangle {
            radius: 5
            color: "#101d2d"
            border.color: queryInput.activeFocus ? "#54c9e8" : "#4e8499"
            border.width: 1
        }
        contentItem: Item {
            QQC2.ScrollView {
                id: queryScroll
                anchors.fill: parent
                clip: true
                QQC2.TextArea {
                    id: queryInput
                    text: search.queryText
                    onTextChanged: if (search.queryText !== text) search.queryText = text
                    font.pixelSize: 14
                    font.bold: false
                    color: "white"
                    wrapMode: TextEdit.Wrap
                    topPadding: 5
                    bottomPadding: 4
                    leftPadding: 7
                    // Sólo un margen interior para el icono, no una columna.
                    rightPadding: 25
                    selectByMouse: true
                    placeholderText: "Buscar en Web o IA…"
                    cursorVisible: activeFocus && search.navigationSection === 0
                    Keys.priority: Keys.BeforeItem
                    Keys.onTabPressed: function(event) {
                        search.moveSection(false); event.accepted = true
                    }
                    Keys.onBacktabPressed: function(event) {
                        search.moveSection(true); event.accepted = true
                    }
                    Keys.onPressed: function(event) { search.handleEditorKey(event) }
                }
            }
            QQC2.Button {
                id: clearButton
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.top: parent.top
                anchors.topMargin: 6
                width: 17
                height: 17
                visible: search.queryText.length > 0
                padding: 0
                z: 10
                background: Item {}
                contentItem: QQC2.Label {
                    text: "×"
                    font.pixelSize: 17
                    color: clearButton.hovered ? "#ffffff" : "#b8cbd5"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: "Borrar todo el texto"
                onClicked: search.clearQuery()
            }
        }
    }
    QQC2.Popup {
        id: options
        parent: search
        x: 0
        y: search.desiredEditorHeight + 6
        width: 396
        height: 152
        padding: 8
        modal: false
        focus: false
        // El campo crece fuera de los 34 px nominales; no confundir sus clics
        // con clics exteriores al Popup. El detector de la barra gestiona el cierre.
        closePolicy: QQC2.Popup.CloseOnEscape
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
            Repeater {
                model: search.webFirst ? ["web", "ai"] : ["ai", "web"]
                delegate: RowLayout {
                    id: sectionRow
                    required property string modelData
                    readonly property int section: modelData === "web" ? 1 : 2
                    spacing: 3
                    QQC2.Button {
                        Layout.preferredWidth: 53
                        Layout.preferredHeight: 32
                        text: (search.navigationSection === sectionRow.section ? "▶ " : "") +
                              (sectionRow.section === 1 ? "Web" : "IA")
                        font.pixelSize: 12
                        highlighted: search.navigationSection === sectionRow.section
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Invertir prioridad Web / IA (también podés arrastrar verticalmente)"
                        onClicked: search.swapRows()
                        property real rowDragY: 0
                        transform: Translate { y: parent.rowDragY }
                        DragHandler {
                            target: null
                            yAxis.enabled: true
                            xAxis.enabled: false
                            onTranslationChanged: if (active) parent.rowDragY = translation.y
                            onActiveChanged: {
                                if (!active) {
                                    const delta = parent.rowDragY
                                    parent.rowDragY = 0
                                    if (Math.abs(delta) > 18) search.swapRows()
                                }
                            }
                        }
                    }
                    Repeater {
                        model: sectionRow.section === 1 ? search.orderedWebIds : search.orderedAiIds
                        delegate: QQC2.Button {
                            id: providerButton
                            required property string modelData
                            required property int index
                            property real dragX: 0
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            text: search.nameFor(modelData)
                            enabled: search.enabledFor(modelData)
                            highlighted: (search.navigationSection === sectionRow.section &&
                                          search.navigationIndex === index) ||
                                         (search.navigationSection === 0 &&
                                          search.currentSection === sectionRow.section &&
                                          (sectionRow.section === 1 ? search.webIndex : search.aiIndex) === index)
                            z: dragControl.active ? 10 : 0
                            transform: Translate { x: providerButton.dragX }
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: search.nameFor(modelData) + " · Arrastrá para cambiar prioridad"
                            onClicked: search.chooseProvider(sectionRow.section, index)
                            DragHandler {
                                id: dragControl
                                target: null
                                xAxis.enabled: true
                                yAxis.enabled: false
                                onTranslationChanged: if (active) providerButton.dragX = translation.x
                                onActiveChanged: {
                                    if (!active) {
                                        const delta = providerButton.dragX
                                        providerButton.dragX = 0
                                        if (Math.abs(delta) > 18) {
                                            const distance = providerButton.width + sectionRow.spacing
                                            const dest = Math.max(0, Math.min(2,
                                                index + Math.round(delta / Math.max(1, distance))))
                                            search.reorderProvider(sectionRow.section, index, dest)
                                        }
                                    }
                                }
                            }
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
