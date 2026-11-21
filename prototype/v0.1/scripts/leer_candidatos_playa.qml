// Solo lectura: audita la biblioteca del visor Qt sin aplicar ni guardar temas.
// No abre ventanas del panel, no escribe Settings, no activa un tema.
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
        const raw = String(saved.value("themeLibraryJson", "[]"))
        console.log("SMARTBAR_PLAYA_AUDIT_LIBRARY=" + JSON.stringify(raw))
        console.log("SMARTBAR_PLAYA_AUDIT_CONTEXT=" + JSON.stringify({
            selectedPackId: String(saved.value("selectedThemePackId", "playa-24hs")),
            historicalSunset: String(saved.value("themeDayJson", "")).length > 0,
            historicalNight: String(saved.value("themeNightJson", "")).length > 0
        }))
        Qt.quit()
    }
}
