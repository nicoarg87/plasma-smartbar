// Sincronización visual SOLO entre los dos procesos LayerShell de ensayo.
// El perfil JSON se crea por copia privada del visor. Nunca toca KConfig,
// wallpapers reales, posiciones por AppId ni la configuración del panel KDE.
import QtQuick
import "RuntimeAppearance.js" as RuntimeAppearance

Item {
    id: bridge
    visible: false
    width: 0
    height: 0
    property var target: null
    property var backend: null
    property bool appearanceActive: false
    property string previousJson: ""

    function refresh() {
        if (!appearanceActive || !backend || !target) return
        const raw = backend.readAppearanceJson()
        if (!raw || raw === previousJson) return
        const parsed = RuntimeAppearance.parse(raw)
        if (!parsed) {
            console.warn("SmartBar: perfil visual local inválido, no se aplicó")
            return
        }
        const updated = RuntimeAppearance.applyToBar(target,parsed)
        previousJson = raw
        console.log("SmartBar apariencia: propiedades visuales compartidas", updated)
    }
    function commitPatch(patchJson) {
        if (!appearanceActive || !backend || !target || !patchJson) return
        const changes = RuntimeAppearance.parse(patchJson)
        if (!changes || Object.keys(changes).length === 0) return
        if (!backend.saveAppearancePatch(patchJson)) {
            console.warn("SmartBar apariencia: fallo al guardar perfil visual; cambios descartados")
            return
        }
        previousJson = ""
        refresh()
    }
    Timer {
        // Son 2 procesos independientes: relectura liviana sin abrir
        // continuamente archivos al recibir foco o mover ventanas.
        interval: 1750
        repeat: true
        running: bridge.appearanceActive
        onTriggered: bridge.refresh()
    }
    Component.onCompleted: Qt.callLater(bridge.refresh)
}
