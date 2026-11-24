// SPDX-License-Identifier: MIT
// Sondeo de tipos QML exclusivamente. Nunca solicita streaming ni captura.
import QtQuick
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.pipewire as KPipeWire

Item {
    // Estas plantillas se compilan, pero NO se instancian. Una petición de
    // screencast solo es segura tras seleccionar una ventana y validar su UUID.
    Component {
        id: requestTemplate
        TaskManager.ScreencastingRequest {
            uuid: ""
        }
    }
    Component {
        id: imageTemplate
        KPipeWire.PipeWireSourceItem {
            visible: false
        }
    }
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            console.log("SmartBar miniaturas: tipos QML cargados, SIN crear capturas.")
            Qt.quit()
        }
    }
}
