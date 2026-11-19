// Lee las ranuras del mismo Qt Settings que usa preview_redimensionable.qml.
// Solo lectura; no modifica el escritorio ni las preferencias del mantenedor.
import QtQuick
import QtCore as QtCore

Item {
    width: 1
    height: 1
    QtCore.Settings {
        id: localPreviewSettings
        category: "plasma-smartbar-v01-preview-appearance"
    }
    Component.onCompleted: {
        const data = {
            themeDayJson: String(localPreviewSettings.value("themeDayJson", "")),
            themeNightJson: String(localPreviewSettings.value("themeNightJson", "")),
            themeLibraryJson: String(localPreviewSettings.value("themeLibraryJson", "[]"))
        }
        console.log("SMARTBAR_PRESETS_EXPORT=" + JSON.stringify(data))
        Qt.quit()
    }
}
