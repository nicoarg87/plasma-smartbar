// Paso 1, solo lectura. Se usa para respaldar la biblioteca exacta antes
// de quitar DOS entradas específicas. No modificar Qt Settings aquí.
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
        const raw = String(localPreviewSettings.value("themeLibraryJson", "[]"))
        console.log("SMARTBAR_DAY_CLEANUP_LIBRARY=" + JSON.stringify(raw))
        Qt.quit()
    }
}
