// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Ensayo diagnóstico nativo: ventana LayerShellQt FIJA + región de entrada.
// NO instala plasmoides, no modifica ventanas externas ni guarda preferencias.
#include <QGuiApplication>
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

private:
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
    // No mostrar el Window antes de aplicar su input mask inicial.
    input.attach(window);
    if (!QMetaObject::invokeMethod(window, "refreshInputRegion",
                                   Qt::DirectConnection) ||
        window->mask().isEmpty()) {
        qCritical() << "SmartBar: sin región de entrada segura; abortar.";
        return 5;
    }

    window->show();
    // Volver a aplicar después del primer configure Wayland (tamaño real).
    QTimer::singleShot(0, window, [window]() {
        QMetaObject::invokeMethod(window, "refreshInputRegion",
                                  Qt::DirectConnection);
    });
    qInfo() << "SmartBar: región de entrada acotada activa. Ensayo sin panel.";
    return app.exec();
}

#include "soledad_input_mask_main.moc"
