// Lectura aislada de la apariencia ACTIVA YA GUARDADA del visor Qt.
// No cambia pack, franjas, temas, opacidades ni configuración del escritorio.
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
        const raw = {
            appearance: String(saved.value("appearanceV1", "")),
            library: String(saved.value("themeLibraryJson", "[]")),
            sunsetLegacy: String(saved.value("themeDayJson", "")),
            nightLegacy: String(saved.value("themeNightJson", "")),
            selectedPack: String(saved.value("selectedThemePackId", "playa-24hs")),
            themePackLibraryJson: String(saved.value("themePackLibraryJson", "[]")),
            scheduleEnabled: String(saved.value("themeScheduleEnabled", true)),
            scheduleCount: String(saved.value("themeScheduleSlotCount", 4)),
            scheduleSlots3: String(saved.value("themeScheduleSlots3Json", "")),
            scheduleSlots4: String(saved.value("themeScheduleSlots4Json", "")),
            wallpaperPreview: String(saved.value("simulatedWallpaperTheme", ""))
        }
        // Solo viaja al proceso local y a un log temporal modo 0600.
        // Nunca entregar este JSON completo como salida pública.
        console.log("SMARTBAR_PLAYA_FACTORY_CANDIDATE=" + JSON.stringify(raw))
        Qt.quit()
    }
}
