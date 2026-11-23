// Buscador experimental Malvina: controles en una sola fila y
// proveedores en panel flotante debajo, sin modificar grosor de isla.
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2
import "MalvinaUrlPolicy.js" as UrlPolicy
import "MalvinaSlots.js" as Slots
import "MalvinaKeyboard.js" as Keyboard

Item {
    id: search
    property bool expanded: false
    // Los controles heredan el relleno de la isla; solo cambia la silueta.
    property string gearButtonShape: "square"
    property string searchButtonShape: "square"
    // El editor comparte la silueta elegida para la isla Malvina.
    property string islandShape: "rounded"
    property real islandRadius: 18
    // Apariencia compartida con la superficie de la isla Malvina.
    property color islandColor: "#101e31"
    property real islandOpacity: 1
    // Solo el panel de opciones Web/IA: sigue a la isla salvo anulación.
    property real optionsPanelOpacity: islandOpacity
    property real optionsPanelBreathingFactor: 1
    property bool islandGradientEnabled: false
    property color islandGradientEnd: "#445577"
    property color islandGradientThird: "#445577"
    property int islandGradientColorCount: 2
    property string islandGradientDirection: "topBottom"
    // Los paneles flotantes heredan los contornos de la isla 2.
    property color islandOutlineColor: "#4e8499"
    property real islandOutlineOpacity: 1
    property real islandOutlineWidth: 1
    property string islandOutlineStyle: "solid"
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
    // Formato de fichas compartido con la isla de Soledad.
    property string extraWeb: "[]"
    property string extraAi: "[]"
    property string hiddenWeb: ""
    property string hiddenAi: ""
    property bool compactAi: false
    // En una capa LayerShell de tamaño ajustado al Popup, calcular
    // optionsWidth desde Window.width formaría una dependencia circular.
    // El ensayo provee el ancho disponible de pantalla por separado.
    // Valor 0 mantiene INTACTO el cálculo tradicional del visor/panel.
    property real optionsViewportWidthOverride: 0
    readonly property real fullOptionsWidth: Math.max(396,Math.min(
        optionsViewportWidthOverride > 0
            ? Math.max(360, optionsViewportWidthOverride - 26)
            : (search.Window.window ? Math.max(360, search.Window.window.width - 26) : 970),
        92 + 96 * Math.max(orderedWebIds.length, compactAi ? 0 : orderedAiIds.length)))
    readonly property real optionsWidth: compactAi
        ? Math.max(396, Math.min(fullOptionsWidth, 92 + 96 * orderedWebIds.length))
        : fullOptionsWidth
    property string taskFrameShape: "rounded"
    property color taskFrameColor: "#ffffff"
    property real taskFrameOpacity: 0.12
    property real taskFrameWidth: 1

    readonly property var webExtras: Slots.extras("web",extraWeb)
    readonly property var aiExtras: Slots.extras("ai",extraAi)
    readonly property var orderedWebIds: Slots.order("web",extraWeb,webOrder,hiddenWeb)
    readonly property var orderedAiIds: Slots.order("ai",extraAi,aiOrder,hiddenAi)
    signal requestOrderChange(bool webFirst, string webOrder, string aiOrder)
    function nameFor(id) {
        const names = {
            google: googleName, duck: duckName, yahoo: yahooName,
            chatgpt: chatGptName, gemini: geminiName, claude: claudeName
        }
        const extra=webExtras.concat(aiExtras).find(x=>x.id===id)
        return extra ? extra.name : (names[id] || id)
    }
    function enabledFor(id) {
        const extra=webExtras.concat(aiExtras).find(x=>x.id===id)
        if(extra) return extra.enabled
        return id === "google" ? webGoogleEnabled :
               id === "duck" ? webDuckEnabled :
               id === "yahoo" ? webYahooEnabled : true
    }
    function urlFor(id) {
        const urls = {
            google: googleTemplate, duck: duckTemplate, yahoo: yahooTemplate,
            chatgpt: chatGptUrl, gemini: geminiUrl, claude: claudeUrl
        }
        const extra=webExtras.concat(aiExtras).find(x=>x.id===id)
        return extra ? extra.url : (urls[id] || "")
    }
    function aiIndexFor(id) { return ["chatgpt", "gemini", "claude"].indexOf(id) }
    function webIdAt(index) { return orderedWebIds[Math.max(0, Math.min(orderedWebIds.length-1,index))] }
    function aiIdAt(index) { return orderedAiIds[Math.max(0, Math.min(orderedAiIds.length-1,index))] }
    function firstEnabledWebIndex() {
        for (let i=0;i<orderedWebIds.length;i++) if (enabledFor(webIdAt(i))) return i
        return -1
    }
    function resetDefault() {
        const firstWeb = firstEnabledWebIndex()
        const firstAi = orderedAiIds.findIndex(id => enabledFor(id))
        currentSection = webFirst
            ? (firstWeb >= 0 ? 1 : (firstAi >= 0 ? 2 : 0))
            : (firstAi >= 0 ? 2 : (firstWeb >= 0 ? 1 : 0))
        webIndex = Math.max(0, firstWeb)
        aiIndex = Math.max(0, firstAi)
        navigationSection = 0
        navigationIndex = 0
    }
    function applyOrder(firstWeb, webList, aiList) {
        // Emitir hacia el coordinador sin romper los bindings de KConfig/visor.
        requestOrderChange(firstWeb, webList, aiList)
        resetDefault()
    }
    function swapRows() {
        applyOrder(!webFirst, webOrder, aiOrder)
    }
    function reorderProvider(section, fromIndex, destinationIndex) {
        const size=section === 1 ? orderedWebIds.length : orderedAiIds.length
        if (fromIndex === destinationIndex || fromIndex < 0 || destinationIndex < 0 ||
            fromIndex >= size || destinationIndex >= size) return
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
    // Regiones de entrada de la prueba LayerShell. Estos valores leen la
    // geometría de los Popup existentes y NO crean controles nuevos.
    // X/Y son locales al Item de MalvinaSearch.
    readonly property bool fieldRegionVisible: fieldPopup.visible
    readonly property real fieldRegionX: fieldPopup.x
    readonly property real fieldRegionY: fieldPopup.y
    readonly property real fieldRegionWidth: fieldPopup.visible ? fieldPopup.width : 0
    readonly property real fieldRegionHeight: fieldPopup.visible ? fieldPopup.height : 0
    readonly property bool optionsRegionVisible: options.visible
    readonly property real optionsRegionX: options.x
    readonly property real optionsRegionY: options.y
    readonly property real optionsRegionWidth: options.visible ? options.width : 0
    readonly property real optionsRegionHeight: options.visible ? options.height : 0
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
        if (currentSection === 0) {
            console.warn("Malvina: no hay proveedores visibles y habilitados")
            return
        }
        const providerId = isAi ? aiIdAt(aiIndex) : webIdAt(webIndex)
        const template = urlFor(providerId)
        if (!providerId || !enabledFor(providerId)) {
            console.warn("Malvina: el buscador Web seleccionado está deshabilitado en Configuración")
            return
        }
        const officialAi = aiIndexFor(providerId)
        // Los proveedores IA añadidos por usuarios abren su web sin incluir el
        // texto. Nunca heredan permisos de ChatGPT/Claude por nombre ni posición.
        const result = isAi && officialAi >= 0
            ? UrlPolicy.resolveAiPrefill(officialAi, template, query,
                                         aiPrefillAllowed[officialAi])
            : UrlPolicy.resolve(template, query, isAi)
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
            // Enter en una ficha destacada la CONFIRMA sin transmitir texto.
            // Recién una segunda pulsación, con navegación de vuelta en 0,
            // busca. No tratar la repetición de la tecla sostenida como otra.
            if (!event.isAutoRepeat) {
                if (Keyboard.enterAction(navigationSection) === "confirm")
                    confirmCandidate()
                else
                    openSelected()
            }
            event.accepted = true
        }
    }
    function enabledIndices(section) {
        const ids = section === 1 ? orderedWebIds : orderedAiIds
        const valid = []
        for (let i = 0; i < ids.length; ++i)
            if (enabledFor(ids[i])) valid.push(i)
        return valid
    }
    function moveSection(backwards) {
        if (!options.visible) options.open()
        const sections = [0]
        if (webFirst) {
            if (enabledIndices(1).length) sections.push(1)
            if (enabledIndices(2).length) sections.push(2)
        } else {
            if (enabledIndices(2).length) sections.push(2)
            if (enabledIndices(1).length) sections.push(1)
        }
        const current = Math.max(0, sections.indexOf(navigationSection))
        const step = backwards ? -1 : 1
        navigationSection = sections[(current + step + sections.length) % sections.length]
        if (navigationSection !== 0) {
            const enabled = enabledIndices(navigationSection)
            const stored = navigationSection === 1 ? webIndex : aiIndex
            navigationIndex = enabled.indexOf(stored) >= 0 ? stored : enabled[0]
        }
        queryInput.forceActiveFocus()
    }
    function moveCandidate(delta) {
        if (navigationSection === 0) return
        const enabled = enabledIndices(navigationSection)
        if (!enabled.length) return
        // Cada paso recorre una lista estable de índices habilitados.
        let at = enabled.indexOf(navigationIndex)
        if (at < 0) at = delta > 0 ? -1 : 0
        const next = enabled[(at + (delta > 0 ? 1 : -1) + enabled.length) % enabled.length]
        navigationIndex = next
        if (!options.visible) options.open()
        queryInput.forceActiveFocus()
    }
    // Solo elegir: no abrir la URL ni modificar la consulta.
    function chooseProvider(section, index) {
        if (section === 2 && !enabledFor(aiIdAt(index))) return
        if (section === 1) {
            if (!enabledFor(webIdAt(index))) {
                console.warn("Malvina: proveedor Web deshabilitado")
                return
            }
            webIndex = index
        }
        else if (section === 2) aiIndex = index
        currentSection = section
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
            padding: 3
            background: Rectangle {
                radius: search.gearButtonShape === "circle" ? Math.min(width,height)/2 :
                        search.gearButtonShape === "rounded" ? Math.min(7,height/4) :
                        search.gearButtonShape === "capsule" ? height/2 : 0
                // Contorno fino siempre visible: permite distinguir
                // cuadrado/círculo sin tapar color ni degradado de Malvina.
                color: gear.down ? "#30ffffff" :
                       (gear.hovered ? "#18ffffff" : "#09000000")
                border.width: 1
                border.color: gear.activeFocus ? "#9be8ff" :
                              (gear.hovered ? "#668fc1d2" : "#405f8598")
            }
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: "Configuración de Malvina"
            onClicked: search.requestSettings()
        }
        QQC2.Button {
            id: magnifier
            Layout.preferredWidth: 34; Layout.preferredHeight: 32
            icon.name: "edit-find"
            text: ""
            padding: 3
            background: Rectangle {
                radius: search.searchButtonShape === "circle" ? Math.min(width,height)/2 :
                        search.searchButtonShape === "rounded" ? Math.min(7,height/4) :
                        search.searchButtonShape === "capsule" ? height/2 : 0
                // Contorno fino siempre visible: permite distinguir
                // cuadrado/círculo sin tapar color ni degradado de Malvina.
                color: magnifier.down ? "#30ffffff" :
                       (magnifier.hovered ? "#18ffffff" : "#09000000")
                border.width: 1
                border.color: magnifier.activeFocus ? "#9be8ff" :
                              (magnifier.hovered ? "#668fc1d2" : "#405f8598")
            }
            QQC2.ToolTip.visible: hovered && !search.expanded
            QQC2.ToolTip.text: "Buscar · Super+Espacio (ventana activa)"
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
        // Dos Popup hermanos: al abrir Web/IA, el campo no puede usar
        // cierre exterior porque Google/ChatGPT están fuera de su rectángulo.
        // Cuando el menú Web/IA NO está abierto, sí permitimos que un clic
        // exterior cierre el campo y la búsqueda, como pidió el mantenedor.
        closePolicy: options.visible ? QQC2.Popup.NoAutoClose
                                     : QQC2.Popup.CloseOnPressOutside
        onClosed: {
            if (search.expanded && !options.visible)
                search.closeSearch()
        }
        background: Rectangle {
            radius: search.islandShape === "square" ? 0 :
                    search.islandShape === "capsule" ? height / 2 :
                    Math.max(0, Math.min(search.islandRadius, height / 2))
            topLeftRadius: search.islandShape === "leftSquareRightRound" ? 0 : radius
            bottomLeftRadius: search.islandShape === "leftSquareRightRound" ? 0 : radius
            topRightRadius: search.islandShape === "leftRoundRightSquare" ? 0 : radius
            bottomRightRadius: search.islandShape === "leftRoundRightSquare" ? 0 : radius
            clip: true
            color: search.islandGradientEnabled ? "transparent" :
                   Qt.rgba(search.islandColor.r, search.islandColor.g,
                           search.islandColor.b, search.islandOpacity)
            Rectangle {
                anchors.fill: parent
                visible: search.islandGradientEnabled
                radius: parent.radius
                topLeftRadius: parent.topLeftRadius
                bottomLeftRadius: parent.bottomLeftRadius
                topRightRadius: parent.topRightRadius
                bottomRightRadius: parent.bottomRightRadius
                gradient: Gradient {
                    orientation: search.islandGradientDirection === "leftRight" ||
                                 search.islandGradientDirection === "rightLeft"
                        ? Gradient.Horizontal : Gradient.Vertical
                    GradientStop {
                        position: 0
                        color: {
                            const reverse = search.islandGradientDirection === "bottomTop" ||
                                            search.islandGradientDirection === "rightLeft"
                            const value = reverse
                                ? (search.islandGradientColorCount === 3
                                   ? search.islandGradientThird : search.islandGradientEnd)
                                : search.islandColor
                            return Qt.rgba(value.r, value.g, value.b, search.islandOpacity)
                        }
                    }
                    GradientStop {
                        position: search.islandGradientColorCount === 3 ? 0.5 : 1
                        color: {
                            const reverse = search.islandGradientDirection === "bottomTop" ||
                                            search.islandGradientDirection === "rightLeft"
                            const value = search.islandGradientColorCount === 3
                                ? search.islandGradientEnd
                                : (reverse ? search.islandColor : search.islandGradientEnd)
                            return Qt.rgba(value.r, value.g, value.b, search.islandOpacity)
                        }
                    }
                    GradientStop {
                        position: 1
                        color: {
                            const reverse = search.islandGradientDirection === "bottomTop" ||
                                            search.islandGradientDirection === "rightLeft"
                            const value = reverse ? search.islandColor
                                : (search.islandGradientColorCount === 3
                                   ? search.islandGradientThird : search.islandGradientEnd)
                            return Qt.rgba(value.r, value.g, value.b, search.islandOpacity)
                        }
                    }
                }
            }
            // El foco conserva indicación accesible, sin marco fluorescente
            // permanente que esconda la estética personalizada.
            border.width: 0
            OutlineStyle {
                anchors.fill: parent
                lineColor: search.islandOutlineColor
                lineOpacity: search.islandOutlineOpacity
                lineWidth: search.islandOutlineWidth
                lineStyle: search.islandOutlineStyle
                topLeft: parent.topLeftRadius
                topRight: parent.topRightRadius
                bottomLeft: parent.bottomLeftRadius
                bottomRight: parent.bottomRightRadius
            }
        }
        contentItem: Item {
            QQC2.ScrollView {
                id: queryScroll
                anchors.fill: parent
                // Evitar el fondo rectangular del estilo Qt que tapa la
                // geometría del extremo derecho del Popup redondeado.
                background: Item {}
                clip: true
                QQC2.TextArea {
                    id: queryInput
                    background: Item {}
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
                    placeholderText: "Tab: Web/IA · Enter: elegir, Enter: buscar…"
                    cursorVisible: activeFocus && search.navigationSection === 0
                    Keys.priority: Keys.BeforeItem
                    Keys.onTabPressed: function(event) {
                        search.moveSection(false); event.accepted = true
                    }
                    Keys.onBacktabPressed: function(event) {
                        search.moveSection(true); event.accepted = true
                    }
                    Keys.onPressed: function(event) {
                        // Tab/Shift+Tab ya los interceptan sus handlers propios.
                        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab)
                            event.accepted = true
                        else
                            search.handleEditorKey(event)
                    }
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
        width: search.optionsWidth
        // No dejar una fila vacía si el usuario quitó todos los Web o IA.
        height: 58 + (search.orderedWebIds.length ? 38 : 0) +
                     (search.orderedAiIds.length ? 38 : 0)
        padding: 8
        modal: false
        focus: false
        // Mantener el cierre exterior/ESC en el panel de opciones, NO en
        // el campo: sus coordenadas son distintas y deben poder coexistir.
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
        onClosed: {
            if (search.suppressPopupDismissal) {
                search.suppressPopupDismissal = false
            } else if (search.expanded) {
                search.closeSearch()
            }
        }
        background: IslandPopupSurface {
            cornerRadius: 10
            baseColor: search.islandColor
            endColor: search.islandGradientEnd
            thirdColor: search.islandGradientThird
            gradientColorCount: search.islandGradientColorCount
            gradientEnabled: search.islandGradientEnabled
            gradientDirection: search.islandGradientDirection
            baseOpacity: search.optionsPanelOpacity
            breathingFactor: search.optionsPanelBreathingFactor
            opaqueAtMaximum: true
            // Al 100 %, respirar cambia luminosidad, no transparencia.
            outlineColor: search.islandOutlineColor
            outlineOpacity: search.islandOutlineOpacity
            outlineWidth: search.islandOutlineWidth
            outlineStyle: search.islandOutlineStyle
        }
        contentItem: ColumnLayout {
            spacing: 4
            Repeater {
                model: search.webFirst ? ["web", "ai"] : ["ai", "web"]
                delegate: RowLayout {
                    id: sectionRow
                    visible: section === 1 ? search.orderedWebIds.length > 0 : search.orderedAiIds.length > 0
                    required property string modelData
                    readonly property int section: modelData === "web" ? 1 : 2
                    spacing: 3
                    QQC2.Button {
                        id: sectionButton
                        // El texto predeterminado del Button se elidía como "...".
                        // Etiqueta propia y ancho suficiente, sin ocupar otra fila.
                        Layout.preferredWidth: 72
                        Layout.minimumWidth: 72
                        Layout.preferredHeight: 32
                        padding: 1
                        text: sectionRow.section === 1 ? "Web" : "IA"
                        contentItem: QQC2.Label {
                            text: (search.navigationSection === sectionRow.section ? "▶ " : "↕ ") +
                                  (sectionRow.section === 1 ? "Web" : "IA")
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: search.navigationSection === sectionRow.section
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideNone
                        }
                        highlighted: search.navigationSection === sectionRow.section
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Invertir prioridad Web / IA (también podés arrastrar verticalmente)"
                        onClicked: search.swapRows()
                        property real rowDragY: 0
                        transform: Translate { y: sectionButton.rowDragY }
                        DragHandler {
                            target: null
                            yAxis.enabled: true
                            xAxis.enabled: false
                            onTranslationChanged: if (active) sectionButton.rowDragY = translation.y
                            onActiveChanged: {
                                if (!active) {
                                    const delta = sectionButton.rowDragY
                                    sectionButton.rowDragY = 0
                                    if (Math.abs(delta) > 18) search.swapRows()
                                }
                            }
                        }
                    }
                    // Una sola fila aunque haya diez fichas. Desplazamiento
                    // horizontal; no aumentar alto del popup ni altura de isla.
                    QQC2.ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        clip: true
                        QQC2.ScrollBar.horizontal.policy: sectionRow.section === 2 && search.compactAi ? QQC2.ScrollBar.AsNeeded : QQC2.ScrollBar.AlwaysOff
                        QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOff
                        Row {
                            id: providersRow
                            spacing: 4
                            Repeater {
                                model: sectionRow.section === 1 ? search.orderedWebIds : search.orderedAiIds
                                delegate: IslandButton {
                                    id: providerButton
                                    required property string modelData
                                    required property int index
                                    property real dragX: 0
                                    width: sectionRow.section === 2 && search.compactAi
                                        ? 96
                                        : Math.max(45, Math.floor(
                                            (search.optionsWidth - 92 -
                                            ((sectionRow.section === 1 ? search.orderedWebIds.length : search.orderedAiIds.length) - 1) * 4) /
                                            Math.max(1, sectionRow.section === 1 ?
                                                search.orderedWebIds.length : search.orderedAiIds.length)))
                                    height: 30
                                    text: search.nameFor(modelData)
                                    enabled: search.enabledFor(modelData)
                                    inheritIslandFill: true
                                    taskDisplayMode: "text"
                                    taskFrameShape: search.taskFrameShape
                                    taskFrameColor: search.taskFrameColor
                                    taskFrameOpacity: search.taskFrameOpacity
                                    taskFrameWidth: search.taskFrameWidth
                                    taskIsActive: (search.navigationSection === sectionRow.section &&
                                                   search.navigationIndex === index) ||
                                                  (search.navigationSection === 0 &&
                                                   search.currentSection === sectionRow.section &&
                                                   (sectionRow.section === 1 ? search.webIndex : search.aiIndex) === index)
                                    taskActiveGlowEnabled: false
                                    taskActiveDoubleBorderEnabled: true
                                    taskActiveBorderColor: Qt.lighter(search.islandOutlineColor, 1.7)
                                    taskActiveBorderWidth: 2
                                    taskActiveBorderOpacity: 1
                                    z: dragControl.active ? 10 : 0
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Math.min(7, height / 4)
                                        color: "transparent"
                                        border.color: Qt.lighter(search.islandOutlineColor, 1.7)
                                        border.width: 2
                                        visible: search.navigationSection === sectionRow.section &&
                                                 search.navigationIndex === index
                                        enabled: false
                                    }
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
                                                    const step = providerButton.width + providersRow.spacing
                                                    const count = sectionRow.section === 1 ?
                                                        search.orderedWebIds.length : search.orderedAiIds.length
                                                    const dest = Math.max(0, Math.min(count - 1,
                                                        index + Math.round(delta / Math.max(1, step))))
                                                    search.reorderProvider(sectionRow.section,index,dest)
                                                }
                                            }
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
