// Empaquetado KDE Plasma 6. La interfaz es compartida con la prueba Qt.
// El tamaño del contenido depende de lo que entregue el contenedor de KDE.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: plasmoidRoot

    Layout.fillWidth: true
    Layout.minimumWidth: 750    // Solo requisito de la maqueta horizontal.
    Layout.preferredWidth: 960  // Sugerencia, no ancho máximo.
    Layout.minimumHeight: 48
    Layout.preferredHeight: 48
    Layout.maximumHeight: 48
    implicitWidth: 960
    implicitHeight: 48

    onWidthChanged: console.log("SmartBar v0.1: ancho del applet Plasma =", width)

    SmartBarContent {
        id: demo
        anchors.fill: parent

        // La configuración de Plasma se mantiene en el envoltorio;
        // SmartBarContent no depende de Plasmoid y es reutilizable.
        autoReturnRight: Plasmoid.configuration.autoReturnRight
        launcherIslandVisible: Plasmoid.configuration.showLauncherIsland
        autoCollapseSO: Plasmoid.configuration.autoCollapseSO
        autoCollapseTray: Plasmoid.configuration.autoCollapseTray
        onRequestAutoReturnRightChange: function(newValue) {
            Plasmoid.configuration.autoReturnRight = newValue
        }
        onRequestLauncherIslandVisibilityChange: function(newValue) {
            Plasmoid.configuration.showLauncherIsland = newValue
        }
        onRequestAutoCollapseSOChange: function(newValue) {
            Plasmoid.configuration.autoCollapseSO = newValue
        }
        onRequestAutoCollapseTrayChange: function(newValue) {
            Plasmoid.configuration.autoCollapseTray = newValue
        }
    }
}
