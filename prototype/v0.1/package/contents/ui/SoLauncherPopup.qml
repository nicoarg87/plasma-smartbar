// Lanzador/cajón visual SO: categorías + subpanel lateral y búsqueda de archivos.
// Archivo local se inspecciona en el equipo; no transmite rutas ni contenidos.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Qt.labs.folderlistmodel
import QtCore

QQC2.Popup {
    id: launcher
    property bool malvinaVisible: true
    property var installedApplications: []
    property bool catalogIsReal: false
    property string selectedCategory: ""
    property bool showMoreCategories: false
    property bool filesMode: false
    // Después de abrir una categoría, conservar el ancho completo al
    // pasar a Archivos. El panel de apps se retira, pero no salta el popup.
    property bool expandedCanvas: false
    property real heightOnFileSwitch: 0
    // Iconos de tema KDE (sin modo de solo iconos: el nombre siempre visible).
    property bool iconsWithNames: true
    property int primaryWidth: 285
    property int filesWidth: 500
    property int categoryWidth: 280
    // Opción A (predeterminada): las aplicaciones aparecen a la derecha
    // y el panel principal se desplaza hacia la izquierda, como en la prueba.
    // Opción B: aplicaciones a la izquierda, panel principal fijo a la derecha.
    property int categoryLayout: 0
    property int maxVisibleSlots: 20
    // Disponible hasta la parte inferior del visor. El ScrollView toma el excedente.
    // Evitar availableHeight: es una propiedad FINAL del tipo Popup en Qt 6.
    property real popupHeightLimit: 470
    // Valores heredados de Soledad: ninguna copia de colores de Malvina.
    property color islandColor: "#010111"
    property color islandGradientEnd: "#ee9852"
    property real islandOpacity: 1
    property bool islandGradientEnabled: false
    property string islandGradientDirection: "topBottom"
    property real islandBreathingFactor: 1
    property color outlineColor: "#4e8499"
    property real outlineOpacity: 1
    property real outlineWidth: 1
    property string outlineStyle: "solid"
    // El interruptor hereda Soledad por defecto; puede tener geometría/color propios.
    property string switchShape: "capsule"
    property bool switchCustomColor: false
    property color switchColor: "#010111"
    readonly property color effectiveSwitchColor: switchCustomColor ? switchColor : islandColor
    readonly property int visibleCount: filesMode ? fileList.count :
        (searchInput.text.trim().length ? appMatches().length :
         (showCategoryPanel ? appsForCategory().length : categoryOptions().length))
    readonly property int rowsToShow: Math.min(maxVisibleSlots, Math.max(0, visibleCount))
    readonly property int rowHeight: filesMode ? 70 : 35
    readonly property int headerHeight: filesMode ? 240 : 122
    property var demoApplications: [
        {name: "Brave", category: "Internet"}, {name: "Firefox", category: "Internet"},
        {name: "Akregator", category: "Internet"}, {name: "Alligator", category: "Internet"},
        {name: "LibreOffice Writer", category: "Oficina"},
        {name: "LibreOffice Calc", category: "Oficina"},
        {name: "VLC", category: "Multimedia"}, {name: "Elisa", category: "Multimedia"},
        {name: "Configuración del sistema", category: "Sistema"},
        {name: "Konsole", category: "Sistema"},
        {name: "Dolphin", category: "Utilidades"},
        {name: "Ark", category: "Utilidades"},
        {name: "Krita", category: "Gráficos"},
        {name: "KDevelop", category: "Desarrollo"},
        {name: "GCompris", category: "Educación"},
        {name: "KPatience", category: "Juegos"}
    ]
    readonly property var primaryCategories: ["Internet", "Oficina", "Multimedia", "Sistema", "Utilidades"]
    readonly property var moreCategories: ["Educación", "Juegos", "Gráficos", "Desarrollo", "Ciencia", "Otras"]
    readonly property var currentApplications: catalogIsReal ? installedApplications : demoApplications
    readonly property bool showCategoryPanel: !filesMode && selectedCategory.length > 0
    // La posición y el orden del subpanel son configurables (A/B).
    width: filesMode ? (expandedCanvas ? primaryWidth + categoryWidth + 1 : filesWidth) :
        (showCategoryPanel ? primaryWidth + categoryWidth + 1 : primaryWidth)
    height: Math.min(Math.max(170, popupHeightLimit),
        Math.max(filesMode ? Math.max(240, heightOnFileSwitch) :
                 Math.max(170, heightOnFileSwitch),
                 headerHeight + rowsToShow * rowHeight))
    padding: 9
    modal: false
    focus: true
    // Qt distingue clic dentro del launcher de clic fuera, incluso con panel lateral.
    // Si el cursor está sobre el botón que abrió el launcher, NO usar
    // autocierre por clic exterior: Qt podía cerrarlo en mouse-press
    // y el onClicked de SO lo volvía a abrir en el mismo gesto.
    // Fuera del botón se conserva clic exterior y Escape.
    property bool triggerButtonHovered: false
    closePolicy: QQC2.Popup.CloseOnEscape |
        (triggerButtonHovered ? QQC2.Popup.NoAutoClose :
                                QQC2.Popup.CloseOnPressOutside)
    signal requestShowMalvina()
    signal appSelected(string name, bool realCatalog)
    function categoryOptions() {
        const cats = primaryCategories.slice()
        if (showMoreCategories)
            return cats.concat(moreCategories)
        return cats.concat(["+"])
    }
    function appsForCategory() {
        const query = searchInput.text.toLowerCase().trim()
        return currentApplications.filter(function(app) {
            return app.category === selectedCategory &&
                (!query || app.name.toLowerCase().includes(query))
        })
    }
    function appMatches() {
        const query = searchInput.text.toLowerCase().trim()
        return currentApplications.filter(function(app) {
            return app.name.toLowerCase().includes(query)
        })
    }
    function categoryIcon(category) {
        const names = {
            "Internet": "applications-internet",
            "Oficina": "applications-office",
            "Multimedia": "applications-multimedia",
            "Sistema": "applications-system",
            "Utilidades": "applications-utilities",
            "Educación": "applications-education",
            "Juegos": "applications-games",
            "Gráficos": "applications-graphics",
            "Desarrollo": "applications-development",
            "Ciencia": "applications-science",
            "Otras": "applications-other",
            "+": "list-add"
        }
        return names[category] || "applications-other"
    }
    component LauncherActionButton: QQC2.Button {
        id: action
        implicitHeight: 34
        background: IslandPopupSurface {
            baseColor: launcher.islandColor
            endColor: launcher.islandGradientEnd
            gradientEnabled: launcher.islandGradientEnabled
            gradientDirection: launcher.islandGradientDirection
            baseOpacity: Math.max(0.32, Math.min(1, launcher.islandOpacity *
                (action.down ? 1 : action.highlighted ? 0.92 : action.hovered ? 0.85 : 0.66)))
            breathingFactor: launcher.islandBreathingFactor
            outlineColor: launcher.outlineColor
            outlineOpacity: Math.min(1, launcher.outlineOpacity *
                (action.activeFocus || action.highlighted ? 1 : 0.6))
            outlineWidth: launcher.outlineWidth
            outlineStyle: launcher.outlineStyle
            cornerRadius: launcher.switchShape === "square" ? 0 :
                launcher.switchShape === "rounded" ? 6 : 13
        }
        // El contenido predeterminado de QQC2.Button sí renderiza
        // icon.name y icon.source del tema KDE; el Text propio anterior no.
        palette.buttonText: "white"
        icon.width: 19
        icon.height: 19
    }
    function resetAndFocus() {
        filesMode = false
        selectedCategory = ""
        expandedCanvas = false
        heightOnFileSwitch = 0
        showMoreCategories = false
        searchInput.text = ""
        fileList.folder = homeFolder
        searchInput.forceActiveFocus()
    }
    function focusInput() { searchInput.forceActiveFocus() }
    readonly property url homeFolder: "file://" + StandardPaths.writableLocation(StandardPaths.HomeLocation)
    background: IslandPopupSurface {
        baseColor: launcher.islandColor
        endColor: launcher.islandGradientEnd
        gradientEnabled: launcher.islandGradientEnabled
        gradientDirection: launcher.islandGradientDirection
        baseOpacity: launcher.islandOpacity
        breathingFactor: launcher.islandBreathingFactor
        opaqueAtMaximum: true
        outlineColor: launcher.outlineColor
        outlineOpacity: launcher.outlineOpacity
        outlineWidth: launcher.outlineWidth
        outlineStyle: launcher.outlineStyle
        cornerRadius: 12
    }
    contentItem: RowLayout {
        spacing: 9
        layoutDirection: launcher.categoryLayout === 0 ? Qt.RightToLeft : Qt.LeftToRight
        IslandPopupSurface {
            visible: launcher.showCategoryPanel
            Layout.preferredWidth: launcher.categoryWidth - 8
            Layout.fillHeight: true
            cornerRadius: 9
            baseColor: launcher.islandColor
            endColor: launcher.islandGradientEnd
            gradientEnabled: launcher.islandGradientEnabled
            gradientDirection: launcher.islandGradientDirection
            baseOpacity: launcher.islandOpacity
            breathingFactor: launcher.islandBreathingFactor
            opaqueAtMaximum: true
            outlineColor: launcher.outlineColor
            outlineOpacity: launcher.outlineOpacity
            outlineWidth: launcher.outlineWidth
            outlineStyle: launcher.outlineStyle
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 9
                QQC2.Label {
                    text: launcher.selectedCategory
                    color: "white"
                    font.bold: true
                }
                QQC2.Label {
                    text: launcher.catalogIsReal ? "Programas de esta categoría"
                        : "Aplicaciones de muestra"
                    color: "#acc7db"
                    font.pixelSize: 11
                }
                QQC2.ScrollView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    ListView {
                        id: appsList
                        clip: true
                        spacing: 5
                        model: launcher.appsForCategory()
                        delegate: LauncherActionButton {
                            required property var modelData
                            width: appsList.width - 5
                            height: 32
                            text: modelData.name
                            icon.name: modelData.icon || launcher.categoryIcon(launcher.selectedCategory)
                            icon.source: modelData.iconSource || ""
                            display: launcher.iconsWithNames
                                ? QQC2.AbstractButton.TextBesideIcon
                                : QQC2.AbstractButton.TextOnly
                            onClicked: launcher.appSelected(modelData.name, launcher.catalogIsReal)
                        }
                    }
                }
            }
        }
        ColumnLayout {
            // En modo Archivos ocupa todo el recuadro que se abrió para
            // la categoría, sin dejar un panel vacío y sin volver a estrecharse.
            Layout.preferredWidth: (launcher.filesMode ? launcher.width :
                                    launcher.primaryWidth) - 18
            Layout.minimumWidth: (launcher.filesMode ? launcher.width :
                                  launcher.primaryWidth) - 18
            Layout.fillHeight: true
            spacing: 7
            QQC2.Label {
                Layout.fillWidth: true
                text: "Launcher de aplicaciones"
                font.bold: true
                color: "#eaf7ff"
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                QQC2.Label {
                    text: "Aplicaciones"
                    color: launcher.filesMode ? "#aab8c3" : "#ffffff"
                    font.bold: !launcher.filesMode
                }
                QQC2.Switch {
                    id: appFileSwitch
                    Layout.alignment: Qt.AlignHCenter
                    checked: launcher.filesMode
                    implicitWidth: 58
                    implicitHeight: 30
                    indicator: Item {
                        implicitWidth: 58
                        implicitHeight: 28
                        x: appFileSwitch.leftPadding
                        y: (appFileSwitch.height - height) / 2
                        IslandPopupSurface {
                            anchors.fill: parent
                            baseColor: launcher.effectiveSwitchColor
                            endColor: launcher.switchCustomColor ? launcher.switchColor : launcher.islandGradientEnd
                            gradientEnabled: launcher.islandGradientEnabled && !launcher.switchCustomColor
                            gradientDirection: launcher.islandGradientDirection
                            baseOpacity: Math.max(0.35, launcher.islandOpacity)
                            breathingFactor: launcher.islandBreathingFactor
                            outlineColor: launcher.outlineColor
                            outlineOpacity: launcher.outlineOpacity
                            outlineWidth: launcher.outlineWidth
                            outlineStyle: launcher.outlineStyle
                            cornerRadius: launcher.switchShape === "square" ? 0 :
                                launcher.switchShape === "rounded" ? 6 : 14
                        }
                        Rectangle {
                            width: 23
                            height: 23
                            x: appFileSwitch.checked ? parent.width - width - 3 : 3
                            y: 2.5
                            radius: launcher.switchShape === "square" ? 0 :
                                launcher.switchShape === "rounded" ? 5 : width / 2
                            color: launcher.outlineColor
                            border.color: launcher.islandColor
                            border.width: Math.max(1, launcher.outlineWidth)
                        }
                    }
                    onToggled: {
                        if (checked) {
                            // Conservar categoría y altura originales mientras
                            // Archivos ocupa la misma superficie ensanchada.
                            launcher.expandedCanvas = launcher.showCategoryPanel
                            launcher.heightOnFileSwitch = launcher.height
                        } else {
                            // selectedCategory se conserva: al volver se
                            // reabre Internet/Oficina/etc. sin salto de ancho.
                            launcher.expandedCanvas = false
                        }
                        // Primero limpiar la búsqueda mientras todavía está
                        // activo el modo anterior. No tocar selectedCategory.
                        searchInput.text = ""
                        launcher.filesMode = checked
                        if (checked) fileList.folder = launcher.homeFolder
                        searchInput.forceActiveFocus()
                    }
                    Accessible.name: "Elegir búsqueda entre aplicaciones y archivos"
                }
                QQC2.Label {
                    text: "Archivos"
                    color: launcher.filesMode ? "#ffffff" : "#aab8c3"
                    font.bold: launcher.filesMode
                }
            }
            QQC2.TextField {
                id: searchInput
                Layout.fillWidth: true
                color: "white"
                background: IslandPopupSurface {
                    cornerRadius: 8
                    baseColor: launcher.islandColor
                    endColor: launcher.islandGradientEnd
                    gradientEnabled: launcher.islandGradientEnabled
                    gradientDirection: launcher.islandGradientDirection
                    baseOpacity: Math.max(0.45, launcher.islandOpacity)
                    breathingFactor: launcher.islandBreathingFactor
                    outlineColor: launcher.outlineColor
                    outlineOpacity: launcher.outlineOpacity
                    outlineWidth: launcher.outlineWidth
                    outlineStyle: launcher.outlineStyle
                }
                placeholderText: launcher.filesMode ? "Buscar archivo en esta carpeta…" : "Buscar aplicación…"
                onTextChanged: {
                    if (!launcher.filesMode && text.length > 0)
                        launcher.selectedCategory = ""
                }
            }
            LauncherActionButton {
                visible: !launcher.malvinaVisible
                Layout.fillWidth: true
                text: "Activar Malvina (isla 2)"
                onClicked: launcher.requestShowMalvina()
            }
            QQC2.Label {
                visible: launcher.filesMode
                Layout.fillWidth: true
                text: "Carpeta: " + decodeURIComponent(String(fileList.folder).replace("file://", ""))
                color: "#ffffff"
                font.pixelSize: 11
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 3
                elide: Text.ElideRight
                QQC2.ToolTip.visible: folderPathHover.hovered
                QQC2.ToolTip.text: text
                // El texto completo puede consultarse sin barra horizontal.
                HoverHandler { id: folderPathHover }
            }
            RowLayout {
                visible: launcher.filesMode
                Layout.fillWidth: true
                LauncherActionButton {
                    text: "Inicio"
                    onClicked: fileList.folder = launcher.homeFolder
                }
                LauncherActionButton {
                    text: "Subir carpeta"
                    onClicked: {
                        const path = String(fileList.folder).replace(/\/$/, "")
                        const cut = path.lastIndexOf("/")
                        if (cut > "file://".length)
                            fileList.folder = path.slice(0,cut)
                    }
                }
            }
            QQC2.Label {
                Layout.fillWidth: true
                text: launcher.filesMode ? "Explorar archivos (solo lectura)"
                    : (launcher.catalogIsReal ? "Aplicaciones instaladas" : "Categorías de muestra · sin ejecutar")
                color: "#a8c3d1"
                font.pixelSize: 11
            }
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: launcher.filesMode ? 1 : 0
                ListView {
                    id: categoryList
                    clip: true
                    spacing: 4
                    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }
                    model: searchInput.text.trim().length
                        ? launcher.appMatches() : launcher.categoryOptions()
                    delegate: LauncherActionButton {
                        required property var modelData
                        width: categoryList.width - 5
                        height: 31
                        readonly property string label: typeof modelData === "string"
                            ? modelData : modelData.name
                        text: label + (searchInput.text.trim() ? " · aplicación" : "")
                        icon.name: typeof modelData === "string"
                            ? launcher.categoryIcon(label)
                            : (modelData.icon || launcher.categoryIcon(modelData.category))
                        icon.source: typeof modelData === "string" ? "" : (modelData.iconSource || "")
                        display: launcher.iconsWithNames
                            ? QQC2.AbstractButton.TextBesideIcon
                            : QQC2.AbstractButton.TextOnly
                        highlighted: label === launcher.selectedCategory
                        onClicked: {
                            if (label === "+")
                                launcher.showMoreCategories = true
                            else if (searchInput.text.trim())
                                launcher.appSelected(label, launcher.catalogIsReal)
                            else {
                                launcher.selectedCategory = label
                                launcher.expandedCanvas = true
                            }
                        }
                    }
                }
                ListView {
                    id: filesList
                    clip: true
                    spacing: 4
                    QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: QQC2.ScrollBar.AsNeeded }
                    model: fileList
                    Text {
                        anchors.centerIn: parent
                        visible: fileList.count === 0
                        text: "Sin archivos coincidentes en esta carpeta"
                        color: "#ffffff"
                    }
                    delegate: LauncherActionButton {
                        required property string fileName
                        required property bool fileIsDir
                        required property url fileUrl
                        width: filesList.width - 5
                        height: 66
                        readonly property string fileLabel: fileName
                        readonly property string fullPath: decodeURIComponent(
                            String(fileUrl).replace("file://", ""))
                        text: fileLabel + (fileIsDir ? "  📁" : "")
                        contentItem: Column {
                            spacing: 3
                            Text {
                                width: parent.width
                                text: fileLabel + (fileIsDir ? "  📁" : "")
                                color: "white"
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                text: fullPath
                                font.pixelSize: 10
                                color: "#ececec"
                                wrapMode: Text.WrapAnywhere
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: fullPath
                        onClicked: {
                            if (fileIsDir) {
                                fileList.folder = fileUrl
                                searchInput.text = ""
                            } else {
                                // La primera prueba no abre ni ejecuta archivos.
                                console.log("Archivo local seleccionado:", fileLabel)
                            }
                        }
                    }
                }
            }
        }

    }
    FolderListModel {
        id: fileList
        folder: launcher.homeFolder
        nameFilters: searchInput.text.trim().length
            ? ["*" + searchInput.text.trim() + "*"] : ["*"]
        caseSensitive: false
        showDirs: searchInput.text.trim().length === 0
        showFiles: true
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }
}
