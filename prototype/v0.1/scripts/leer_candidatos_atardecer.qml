// Diagnóstico privado de perfiles Atardecer; solo lectura de Qt Settings.
// No modifica temas, horarios, archivos de usuario ni panel Plasma.
import QtQuick
import QtCore as QtCore
Item {
    width: 1
    height: 1
    QtCore.Settings {
        id: saved
        category: "plasma-smartbar-v01-preview-appearance"
    }
    Component.onCompleted: {
        console.log("SMARTBAR_SUNSET_CANDIDATES=" + JSON.stringify({
            legacy: String(saved.value("themeDayJson", "")),
            previous: String(saved.value("themeDayPreviousJson", "")),
            library: String(saved.value("themeLibraryJson", "[]"))
        }))
        Qt.quit()
    }
}
