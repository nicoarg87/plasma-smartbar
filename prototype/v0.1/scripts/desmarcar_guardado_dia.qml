// Limpia la petición temporal aunque el visor haya fallado al iniciar.
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
        localPreviewSettings.setValue("captureDayOnce", false)
        localPreviewSettings.sync()
        Qt.quit()
    }
}
