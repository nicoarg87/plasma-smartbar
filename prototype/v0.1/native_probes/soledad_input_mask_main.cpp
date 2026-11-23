// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Ensayo diagnóstico nativo: ventana LayerShellQt FIJA + región de entrada.
// NO instala plasmoides, no modifica ventanas externas ni guarda preferencias.
#include <QGuiApplication>
#include <QDesktopServices>
#include <QProcess>
#include <QStandardPaths>
#include <QFileInfo>
#include <QDir>
#include <QSet>
#include <QList>
#include <QVariantList>
#include <QVariantMap>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QRegion>
#include <QRect>
#include <QTimer>
#include <QDebug>
#include <QUrl>
#include <QtMath>
#include <QObject>
#include <algorithm>
#include <cmath>

class InputMaskBridge final : public QObject {
    Q_OBJECT
public:
    explicit InputMaskBridge(QObject *parent = nullptr) : QObject(parent) {}

    void attach(QQuickWindow *window) { m_window = window; }

    // Selección EXCLUSIVA del ensayo nativo de Malvina: los nombres y las
    // rutas de ejecutables son fijos. El usuario nunca introduce comandos.
    // Solo se muestran navegadores encontrados realmente en PATH.
    Q_INVOKABLE QVariantList availableBrowsers() const {
        QVariantList choices;
        choices.append(QVariantMap{{"id", "system"}, {"name", "Predeterminado del sistema (KDE)"}});
        QSet<QString> discovered;
        for (const BrowserCandidate &item : browserCandidates()) {
            const QString id = QString::fromLatin1(item.id);
            if (discovered.contains(id)) continue;
            if (QStandardPaths::findExecutable(QString::fromLatin1(item.executable)).isEmpty())
                continue;
            choices.append(QVariantMap{{"id", id},
                                       {"name", QString::fromUtf8(item.name)}});
            discovered.insert(id);
        }
        // Brave se distribuye también como Flatpak: puede tener escritorio
        // com.brave.Browser.desktop pero ningún binario "brave" en PATH.
        // Solo ofrecerlo si detectamos su exportación y el runtime flatpak.
        if (!discovered.contains(QLatin1String("brave")) &&
            !flatpakBraveExecutable().isEmpty())
            choices.append(QVariantMap{{"id", "brave"}, {"name", "Brave"}});
        return choices;
    }

    // Un navegador elegido aplica indistintamente a Web y chat IA.
    // Nunca usar shell, concatenación de comandos ni una URL como ejecutable.
    Q_INVOKABLE bool launchWebUrl(const QString &browserId,
                                 const QString &urlText) const {
        const QUrl url(urlText, QUrl::StrictMode);
        if (!url.isValid() || url.scheme() != QLatin1String("https") ||
            url.host().isEmpty() || !url.userInfo().isEmpty() ||
            url.port() != -1) {
            qWarning() << "SmartBar Malvina: se rechazó una URL no HTTPS válida";
            return false;
        }
        if (browserId == QLatin1String("system"))
            return QDesktopServices::openUrl(url);
        for (const BrowserCandidate &item : browserCandidates()) {
            if (browserId != QLatin1String(item.id)) continue;
            const QString program =
                QStandardPaths::findExecutable(QString::fromLatin1(item.executable));
            if (program.isEmpty()) continue;
            const bool started = QProcess::startDetached(
                program, QStringList{url.toString(QUrl::FullyEncoded)});
            if (!started)
                qWarning() << "SmartBar Malvina: el navegador elegido no arrancó:"
                           << browserId;
            return started;
        }
        if (browserId == QLatin1String("brave")) {
            const QString flatpak = flatpakBraveExecutable();
            if (!flatpak.isEmpty()) {
                // ID Flatpak fijo, nunca obtenido de una URL, archivo
                // .desktop ni campo libre del usuario.
                const bool started = QProcess::startDetached(
                    flatpak, QStringList{"run", "com.brave.Browser",
                                         url.toString(QUrl::FullyEncoded)});
                if (!started)
                    qWarning() << "SmartBar Malvina: no arrancó Brave Flatpak";
                return started;
            }
        }
        qWarning() << "SmartBar Malvina: navegador no disponible:" << browserId;
        return false;
    }

    Q_INVOKABLE void setIslandRect(qreal x, qreal y, qreal width, qreal height) {
        if (!m_window || !std::isfinite(x) || !std::isfinite(y) ||
            !std::isfinite(width) || !std::isfinite(height) ||
            width <= 0 || height <= 0)
            return;

        // Región de entrada únicamente sobre el rectángulo VISIBLE de la isla.
        // Redondear hacia AFUERA evita recortar el grip o sus bordes al escalar.
        const int left = std::max(0, int(std::floor(x)));
        const int top = std::max(0, int(std::floor(y)));
        const int right = std::min(m_window->width(), int(std::ceil(x + width)));
        const int bottom = std::min(m_window->height(), int(std::ceil(y + height)));
        if (right <= left || bottom <= top)
            return;

        const QRegion requested(QRect(left, top, right - left, bottom - top));
        if (m_window->mask() != requested) {
            m_window->setMask(requested);
        }
    }


    // Exclusivo del ensayo de Malvina. Su editor y el menú Web/IA son
    // Popups: la máscara debe seguir su tamaño real al desplegarlos.
    // Unir regiones SOLO de elementos interactivos; no hacer clicable
    // una banda rectangular transparente sobre pestañas/ventanas KDE.
    Q_INVOKABLE void setMalvinaInputRegions(
        qreal islandWidth, qreal islandHeight,
        qreal fieldX, qreal fieldY, qreal fieldWidth, qreal fieldHeight,
        qreal optionsX, qreal optionsY, qreal optionsWidth, qreal optionsHeight)
    {
        if (!m_window) return;
        QRegion allowed;
        const auto includeRect = [&](qreal x, qreal y, qreal width, qreal height) {
            if (!std::isfinite(x) || !std::isfinite(y) ||
                !std::isfinite(width) || !std::isfinite(height) ||
                width <= 0 || height <= 0) return;
            // Evitar cualquier área fuera del rectángulo Qt visible.
            // Rechazar dimensiones extremas antes de convertir a int.
            if (std::abs(x) > 100000 || std::abs(y) > 100000 ||
                width > 100000 || height > 100000) return;
            const int left = std::max(0, int(std::floor(x)));
            const int top = std::max(0, int(std::floor(y)));
            const int right = std::min(m_window->width(), int(std::ceil(x + width)));
            const int bottom = std::min(m_window->height(), int(std::ceil(y + height)));
            if (right > left && bottom > top)
                allowed += QRegion(QRect(left, top, right - left, bottom - top));
        };
        includeRect(0, 0, islandWidth, islandHeight);
        includeRect(fieldX, fieldY, fieldWidth, fieldHeight);
        includeRect(optionsX, optionsY, optionsWidth, optionsHeight);
        if (allowed.isEmpty()) return;
        if (m_window->mask() != allowed)
            m_window->setMask(allowed);
    }

private:
    // Comprobar únicamente rutas estándar de exportación de Brave Flatpak;
    // no interpretar el campo Exec del .desktop ni ejecutarlo como shell.
    static QString flatpakBraveExecutable() {
        const QString flatpak = QStandardPaths::findExecutable("flatpak");
        if (flatpak.isEmpty()) return {};
        QStringList desktopFiles;
        for (const QString &dataDir :
             QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)) {
            desktopFiles.append(dataDir + "/applications/com.brave.Browser.desktop");
        }
        desktopFiles.append(QDir::homePath() +
                            "/.local/share/flatpak/exports/share/applications/com.brave.Browser.desktop");
        desktopFiles.append(
            "/var/lib/flatpak/exports/share/applications/com.brave.Browser.desktop");
        for (const QString &file : desktopFiles) {
            if (QFileInfo(file).isFile()) return flatpak;
        }
        return {};
    }

    struct BrowserCandidate {
        const char *id;
        const char *name;
        const char *executable;
    };
    static const QList<BrowserCandidate> &browserCandidates() {
        static const QList<BrowserCandidate> candidates = {
            {"falkon", "Falkon", "falkon"},
            {"brave", "Brave", "brave"},
            {"brave", "Brave", "brave-browser"},
            {"brave", "Brave", "brave-browser-stable"},
            {"brave", "Brave", "brave-bin"},
            {"brave", "Brave", "com.brave.Browser"},
            {"firefox", "Firefox", "firefox"},
            {"chromium", "Chromium", "chromium"},
            {"chrome", "Google Chrome", "google-chrome-stable"},
            {"chrome", "Google Chrome", "google-chrome"},
            {"vivaldi", "Vivaldi", "vivaldi-stable"},
            {"vivaldi", "Vivaldi", "vivaldi"},
            {"opera", "Opera", "opera"},
            {"librewolf", "LibreWolf", "librewolf"},
            {"zen", "Zen Browser", "zen-browser"},
            {"floorp", "Floorp", "floorp"},
            {"epiphany", "GNOME Web", "epiphany"},
            {"qutebrowser", "qutebrowser", "qutebrowser"}
        };
        return candidates;
    }
    QQuickWindow *m_window = nullptr; // propiedad del motor QQmlApplicationEngine
};

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    if (argc != 2) {
        qCritical() << "Uso: soledad-input-mask <qml-de-prueba>";
        return 2;
    }

    InputMaskBridge input;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("soledadInputMask", &input);
    // Solo el lanzador conjunto habilita sesiones sin autocierre; el resto
    // de los ensayos conserva sus límites de tiempo y su seguridad.
    engine.rootContext()->setContextProperty(
        "smartbarContinuousMode", qEnvironmentVariableIntValue("SMARTBAR_CONTINUOUS") == 1);
    engine.load(QUrl::fromLocalFile(QString::fromLocal8Bit(argv[1])));
    if (engine.rootObjects().size() != 1) {
        qCritical() << "SmartBar: QML no creó exactamente una superficie.";
        return 3;
    }
    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (!window) {
        qCritical() << "SmartBar: objeto raíz no es una ventana Qt Quick.";
        return 4;
    }
    // Crear la superficie NATIVA aún oculta. Qt guarda QWindow::mask()
    // antes de crearla, pero QtWayland requiere recibir setMask() cuando
    // QWaylandWindow ya existe: si no, podría conservar input de pantalla
    // COMPLETA durante la primera exposición (nunca permitir ese estado).
    window->create();
    // No mostrar el Window antes de aplicar su input mask inicial.
    input.attach(window);
    if (!QMetaObject::invokeMethod(window, "refreshInputRegion",
                                   Qt::DirectConnection) ||
        window->mask().isEmpty()) {
        qCritical() << "SmartBar: sin región de entrada segura; abortar.";
        return 5;
    }

    // Malvina exige prioridad absoluta de fullscreen real. Su ensayo
    // comienza OCULTO y lo muestra exclusivamente después de leer el
    // estado de ventanas KDE; nunca forzar show() sobre un fullscreen
    // todavía desconocido. Soledad conserva su flujo ya probado.
    if (window->property("malvinaMaskProbe").toBool()) {
        if (!QMetaObject::invokeMethod(window, "bridgeReady",
                                        Qt::DirectConnection)) {
            qCritical() << "SmartBar Malvina: sin control seguro de fullscreen.";
            return 6;
        }
    } else {
        window->show();
    }
    // Volver a aplicar después del primer configure Wayland (tamaño real).
    QTimer::singleShot(0, window, [window]() {
        QMetaObject::invokeMethod(window, "refreshInputRegion",
                                  Qt::DirectConnection);
    });
    qInfo() << "SmartBar: región de entrada acotada activa. Ensayo sin panel.";
    return app.exec();
}

#include "soledad_input_mask_main.moc"
