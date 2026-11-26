import QtQuick
import "SoledadLauncherPlacement.js" as SoledadLauncherPlacement

// Enlace del popup a la barra y sus anclajes. No cambia la política Wayland.
SoLauncherPopup {
    id: popup
    required property var host
    required property var soButtonTarget
    required property var malvinaButtonTarget
    required property var islandTarget
    required property var malvinaHoverTarget
    required property var malvinaHideTimerTarget
        // En el ensayo real Wayland, Popup.Window debe tener como parent
        // el BOTÓN que lo abrió, igual que gripMenu (que KWin sí ubica
        // debajo de los seis puntos). Con parent:raíz, la superficie de
        // LayerShell de 44 px hacía que el popup apareciera desde y=0,
        // cubriendo SO aunque y fuese host.fixedHeight+8.
        // El visor/maqueta mantienen su anclaje original, sin cambios.
        // LayerShell real: el popup Item vive en el Window flotante propio.
        // El visor Qt anterior conserva su alojamiento original.
        parent: host.layerShellLauncherHost
            ? host.layerShellLauncherHost.contentItem
            : (host.realAppLaunchEnabled
               ? ((host.installedLauncherSource === "so" || !host.launcherIslandVisible)
                  ? soButtonTarget : malvinaButtonTarget)
               : host)
        x: {
            if (host.layerShellLauncherHost) return 0
            const fromSo = host.installedLauncherSource === "so" ||
                           !host.launcherIslandVisible
            // Misma política de coordenada física que la ventana LayerShell.
            // Solo la conversión a origen LOCAL sigue siendo trabajo de QML.
            const left = SoledadLauncherPlacement.screenLeft({
                popupWidth: width,
                screenWidth: host.width,
                requirePositiveScreenWidth: false,
                fromSo: fromSo,
                systemIslandX: islandTarget.x,
                systemIslandWidth: islandTarget.width,
                launcherCenter: fromSo ? 0 : malvinaButtonTarget.mapToItem(
                    host, malvinaButtonTarget.width / 2, 0).x,
                categoryLayout: categoryLayout,
                showCategoryPanel: showCategoryPanel,
                filesMode: filesMode,
                expandedCanvas: expandedCanvas,
                primaryWidth: primaryWidth
            })
            if (!host.realAppLaunchEnabled) return left
            const anchor = fromSo ? soButtonTarget : malvinaButtonTarget
            return left - anchor.mapToItem(host, 0, 0).x
        }
        // Y relativo al botón ancla; no usar la altura del Window
        // LayerShell: no es el mismo sistema de coordenadas que Popup.Window.
        // En modo visor tradicional se preserva el posicionamiento anterior.
        y: host.layerShellLauncherHost ? 0 :
           (host.realAppLaunchEnabled
            ? ((host.installedLauncherSource === "so" || !host.launcherIslandVisible)
               ? soButtonTarget.height + 8 : malvinaButtonTarget.height + 8)
            : host.fixedHeight + 8)
        popupHeightLimit: host.realAppLaunchEnabled
            ? Math.max(270, Math.min(host.launcherAvailableHeight, 760))
            : host.launcherAvailableHeight
        categoryLayout: host.launcherCategoryLayout
        availableScreenWidth: host.width
        maxVisibleSlots: host.launcherMaxSlots
        iconsWithNames: host.launcherIconsWithNames
        switchShape: host.launcherSwitchShape
        switchCustomColor: host.launcherSwitchColorOverride
        switchColor: host.displayLauncherSwitchColor
        islandColor: host.displaySoledadColor
        islandGradientEnd: host.displaySoledadGradientEnd
        islandGradientThird: host.displaySoledadGradientThird
        islandGradientColorCount: host.soledadGradientColorCount
        islandOpacity: host.launcherOpacityOverride
            ? host.launcherOpacity : host.soledadOpacity
        islandGradientEnabled: host.soledadGradientEnabled
        islandGradientDirection: host.soledadGradientDirection
        islandBreathingFactor: host.gradientBreathingFactor
        outlineColor: host.displayOutlineSoColor
        outlineOpacity: host.outlineConfig.soledad.opacity
        outlineWidth: host.outlineConfig.soledad.width
        outlineStyle: host.outlineConfig.soledad.style
        malvinaVisible: host.launcherIslandVisible
        installedApplications: host.localAppCatalog
        catalogIsReal: host.localCatalogReady
        realLaunchEnabled: host.realAppLaunchEnabled
        autoCollapseOnSelection: true
        layerSurfaceHosted: host.realAppLaunchEnabled &&
                            host.layerShellLauncherHost !== null
        onLaunchDesktopEntry: function(desktopId) {
            // Desmontar ambas superficies ANTES de solicitar el inicio KDE.
            host.closeInstalledLauncher()
            console.log("SmartBar launcher: aplicación elegida; caja cerrada")
            host.requestLaunchDesktopEntry(desktopId)
        }
        onRequestDismiss: host.closeInstalledLauncher()
        triggerButtonHovered: host.installedLauncherSource === "so" && soButtonTarget.hovered
        onRequestShowMalvina: {
            host.setLauncherIslandVisible(true)
            host.closeInstalledLauncher()
        }
        onAppSelected: function(name, realCatalog) {
            host.closeInstalledLauncher()
            // En maqueta hacer visible la selección, sin ejecutar procesos.
            if (!realCatalog && host.demoOpenedApps.indexOf(name) >= 0)
                host.selectDemoApp(name)
            console.log("SmartBar: aplicación seleccionada:",
                        realCatalog ? "(catálogo sin ID ejecutable)" : "(simulación)",
                        name)
        }
        onClosed: {
            if (host.autoHideMalvina && !malvinaHoverTarget.hovered)
                malvinaHideTimerTarget.restart()
        }
    }
