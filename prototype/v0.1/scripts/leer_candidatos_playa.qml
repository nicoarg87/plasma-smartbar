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
        // Los nombres de estas ranuras son históricos: themeDayJson era
        // Atardecer, NO el Día de fábrica. Solo comparar, nunca seleccionar.
        const legacySunset = String(saved.value("themeDayJson", ""))
        const legacyNight = String(saved.value("themeNightJson", ""))
        console.log("SMARTBAR_PLAYA_AUDIT_LIBRARY=" + JSON.stringify(raw))
        console.log("SMARTBAR_PLAYA_AUDIT_CONTEXT=" + JSON.stringify({
            selectedPackId: String(saved.value("selectedThemePackId", "playa-24hs")),
            historicalSunset: legacySunset.length > 0,
            historicalNight: legacyNight.length > 0
        }))
        // El JSON íntegro llega exclusivamente al analizador local y se
        // descarta junto con el log temporal; no se imprime en su resumen.
        console.log("SMARTBAR_PLAYA_AUDIT_LEGACY=" + JSON.stringify({
            sunset: legacySunset,
            night: legacyNight
        }))
        Qt.quit()
    }
}
