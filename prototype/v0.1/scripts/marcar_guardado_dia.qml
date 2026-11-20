// Solicitud local de captura: una vez y sin interfaz adicional.
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
        localPreviewSettings.setValue("captureDayOnce", true)
        localPreviewSettings.sync()
        console.log("SMARTBAR_DAY_CAPTURE_REQUESTED")
        Qt.quit()
    }
}
