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
    property int primaryWidth: 285
    property int categoryWidth: 280
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
    width: showCategoryPanel ? primaryWidth + categoryWidth + 13 : primaryWidth
    height: 391
    padding: 9
    modal: false
    focus: true
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutsideParent
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
    function resetAndFocus() {
        filesMode = false
        selectedCategory = ""
        showMoreCategories = false
        searchInput.text = ""
        fileList.folder = homeFolder
        searchInput.forceActiveFocus()
    }
    function focusInput() { searchInput.forceActiveFocus() }
    readonly property url homeFolder: "file://" + StandardPaths.writableLocation(StandardPaths.HomeLocation)
    background: Rectangle {
        radius: 12
        color: "#102538"
        border.color: "#4e8499"
        border.width: 1
    }
    contentItem: RowLayout {
        spacing: 9
        ColumnLayout {
            Layout.preferredWidth: launcher.primaryWidth - 18
            Layout.minimumWidth: launcher.primaryWidth - 18
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
                    onToggled: {
                        launcher.filesMode = checked
                        launcher.selectedCategory = ""
                        searchInput.text = ""
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
                placeholderText: launcher.filesMode ? "Buscar archivo en esta carpeta…" : "Buscar aplicación…"
                onTextChanged: {
                    if (!launcher.filesMode && text.length > 0)
                        launcher.selectedCategory = ""
                }
            }
            QQC2.Button {
                visible: !launcher.malvinaVisible
                Layout.fillWidth: true
                text: "Mostrar Malvina (isla 2)"
                onClicked: launcher.requestShowMalvina()
            }
            QQC2.Label {
                visible: launcher.filesMode
                Layout.fillWidth: true
                text: "Archivos locales · " + String(fileList.folder).replace("file://", "")
                color: "#d9e5ed"
                elide: Text.ElideMiddle
                font.pixelSize: 11
            }
            RowLayout {
                visible: launcher.filesMode
                Layout.fillWidth: true
                QQC2.Button {
                    text: "Inicio"
                    onClicked: fileList.folder = launcher.homeFolder
                }
                QQC2.Button {
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
                    model: searchInput.text.trim().length
                        ? launcher.appMatches() : launcher.categoryOptions()
                    delegate: QQC2.Button {
                        required property var modelData
                        width: categoryList.width - 5
                        height: 31
                        readonly property string label: typeof modelData === "string"
                            ? modelData : modelData.name
                        text: label + (searchInput.text.trim() ? " · aplicación" : "")
                        highlighted: label === launcher.selectedCategory
                        onClicked: {
                            if (label === "+")
                                launcher.showMoreCategories = true
                            else if (searchInput.text.trim())
                                launcher.appSelected(label, launcher.catalogIsReal)
                            else
                                launcher.selectedCategory = label
                        }
                    }
                }
                ListView {
                    id: filesList
                    clip: true
                    spacing: 4
                    model: fileList
                    delegate: QQC2.Button {
                        required property var model
                        width: filesList.width - 5
                        height: visible ? 32 : 0
                        readonly property string fileLabel: String(model.fileName)
                        visible: !searchInput.text.trim() ||
                            fileLabel.toLowerCase().includes(searchInput.text.toLowerCase())
                        text: fileLabel + (model.fileIsDir ? "  📁" : "")
                        onClicked: {
                            if (model.fileIsDir) {
                                fileList.folder = model.fileURL
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
        Rectangle {
            visible: launcher.showCategoryPanel
            Layout.preferredWidth: launcher.categoryWidth - 8
            Layout.fillHeight: true
            radius: 9
            color: "#172d42"
            border.color: "#365a74"
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
                        delegate: QQC2.Button {
                            required property var modelData
                            width: appsList.width - 5
                            height: 32
                            text: modelData.name
                            onClicked: launcher.appSelected(modelData.name, launcher.catalogIsReal)
                        }
                    }
                }
            }
        }
    }
    FolderListModel {
        id: fileList
        folder: launcher.homeFolder
        showDirs: true
        showFiles: true
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }
}
