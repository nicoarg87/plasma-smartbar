// Paso 3: escribir usando el MISMO QtCore.Settings que el visor.
// La etapa de respaldo externo debe completarse ANTES de ejecutar este QML.
// Solo afecta themeLibraryJson, no los slots oficiales, la apariencia o KWin.
import QtQuick
import QtCore as QtCore
import "../package/contents/ui/DayEntryCleanup.js" as DayEntryCleanup

Item {
    width: 1
    height: 1
    QtCore.Settings {
        id: localPreviewSettings
        category: "plasma-smartbar-v01-preview-appearance"
    }
    Component.onCompleted: {
        try {
            const original = String(localPreviewSettings.value("themeLibraryJson", "[]"))
            const items = JSON.parse(original)
            const result = DayEntryCleanup.plan(items)
            if (!result.ok) throw new Error(result.reason)

            // Respaldo interno de emergencia: conservar el primero, jamás
            // sobrescribir su contenido en ejecuciones posteriores.
            const previous = String(localPreviewSettings.value("dayEntriesRemovedBackupV1", ""))
            if (!previous.length) {
                localPreviewSettings.setValue("dayEntriesRemovedBackupV1", original)
                localPreviewSettings.sync()
                if (String(localPreviewSettings.value("dayEntriesRemovedBackupV1", "")) !== original)
                    throw new Error("No se pudo verificar el respaldo secundario.")
            }

            const updated = JSON.stringify(result.items)
            localPreviewSettings.setValue("themeLibraryJson", updated)
            localPreviewSettings.sync()
            if (String(localPreviewSettings.value("themeLibraryJson", "")) !== updated) {
                // Intentar recuperar solo la misma clave si la escritura no fue correcta.
                localPreviewSettings.setValue("themeLibraryJson", original)
                localPreviewSettings.sync()
                throw new Error("Fallo al verificar la biblioteca; se intentó restaurar.")
            }
            console.log("SMARTBAR_DAY_CLEANUP_DONE=2")
        } catch (error) {
            console.warn("SMARTBAR_DAY_CLEANUP_ERROR=" + String(error))
        }
        Qt.quit()
    }
}
