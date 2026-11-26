// Página de Ayuda/Acerca de trasladada sin alterar textos ni enlaces.
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

QQC2.ScrollView {
    id: page
    clip: true
    contentWidth: Math.max(0, availableWidth - 32)
    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
    QQC2.ScrollBar.vertical.width: 16
    QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn
    ColumnLayout {
        width: Math.max(0, page.availableWidth - 32)
        spacing: 16
        QQC2.Label {
            text: "Ayuda rápida"
            color: "white"
            font.bold: true
            font.pixelSize: 16
        }
        QQC2.Label {
            text: "Soledad: botón SO, logo, efectos y fichas de ventanas.\n" +
                  "Malvina: proveedores Web/IA, figura, controles y colores propios.\n" +
                  "Compartidas: geometría, posición, comportamiento y fondos.\n" +
                  "Colores: seleccioná la isla o superficie que querés editar.\n" +
                  "Aplicar guarda los cambios sin cerrar la ventana."
            color: "#ddd6e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        QQC2.Button {
            text: "Abrir manual del proyecto"
            icon.name: "help-contents"
            onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar/blob/prototype/v0.1-islas-so/docs/MANUAL_MAESTRO.md")
        }
        QQC2.Label {
            text: "Acerca de Plasma SmartBar Islands"
            color: "white"; font.bold: true; font.pixelSize: 18
        }
        QQC2.Label { text: "Autor: nicoarg87"; color: "white" }
        QQC2.Label {
            text: "Contacto para consultas: nicoarg87@gmail.com"
            color: "white"
            Layout.fillWidth: true
            wrapMode: Text.WrapAnywhere
        }
        QQC2.Button {
            text: "Enviar una consulta por correo"
            onClicked: Qt.openUrlExternally("mailto:nicoarg87@gmail.com")
        }
        QQC2.Label {
            text: "Repositorio oficial: github.com/nicoarg87/plasma-smartbar"
            color: "#9bdfff"
            wrapMode: Text.WrapAnywhere
            Layout.fillWidth: true
        }
        QQC2.Button {
            text: "Abrir repositorio oficial"
            onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar")
        }
        QQC2.Label {
            text: "Plasma SmartBar es software libre: código y documentación propios bajo licencia MIT. Permite uso, modificación, redistribución y comercialización, conservando los avisos de copyright y licencia. Los recursos gráficos se licencian por separado."
            color: "#ddd6e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        QQC2.Label {
            text: "SIN NINGUNA GARANTÍA: el programa se distribuye tal cual, sin garantía de comerciabilidad ni de adecuación para un propósito particular, en la medida permitida por la legislación aplicable. Consultá el texto completo de MIT."
            color: "#ffd6aa"
            font.bold: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        QQC2.Button {
            text: "Leer licencia MIT"
            onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar/blob/main/LICENSE")
        }
        QQC2.Label {
            text: "Imágenes: licencias independientes. El GIF tropical de OpenAI es el recurso predeterminado de SO (CC0 1.0 según los derechos disponibles). La imagen exacta se distribuye en el ZIP de prueba hasta incorporarla al repositorio. Golden Dog sigue excluido."
            color: "#ddd6e8"
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        QQC2.Button {
            text: "Licencias de recursos gráficos"
            onClicked: Qt.openUrlExternally("https://github.com/nicoarg87/plasma-smartbar/blob/main/docs/LICENCIAS_RECURSOS_GRAFICOS.md")
        }

    }
}
