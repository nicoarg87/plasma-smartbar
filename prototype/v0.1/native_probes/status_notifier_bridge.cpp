// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Observador SNI experimental: lectura, señales y acciones por clic explícito.
// No registra hosts/watchers ni modifica la configuración del panel KDE.
// Activate y ContextMenu se envían solo a los indicadores SNI vigentes.
#include "status_notifier_bridge.h"
#include <QDebug>
#include <QIcon>
#include <QPixmap>
#include <QQuickImageProvider>
#include <QRegularExpression>
#include <QStringList>
#include <QUrl>
#include <QVariantMap>
#include <QtGlobal>

#ifdef SMARTBAR_HAS_DBUS
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDBusServiceWatcher>
#endif

class StatusNotifierIconProvider final : public QQuickImageProvider {
public:
    StatusNotifierIconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override {
        // No tratar el identificador de imagen como ruta de archivo o URL.
        const QString name = QUrl::fromPercentEncoding(id.section(QLatin1Char('?'), 0, 0).toUtf8());
        static const QRegularExpression safe(QStringLiteral(R"(^[A-Za-z0-9_+-][A-Za-z0-9_.+-]{0,127}$)"));
        const int px = requestedSize.width() > 0 && requestedSize.height() > 0
            ? qBound(16, qMin(requestedSize.width(), requestedSize.height()), 64)
            : 24;
        const QSize requested(px, px);
        if (size) *size = requested;
        const QString iconName = safe.match(name).hasMatch() ? name
                                                             : QStringLiteral("application-x-executable");
        QIcon icon = QIcon::fromTheme(iconName);
        if (icon.isNull()) icon = QIcon::fromTheme(QStringLiteral("application-x-executable"));
        return icon.pixmap(requested);
    }
};

QQuickImageProvider *createStatusNotifierIconProvider() {
    return new StatusNotifierIconProvider();
}

#ifdef SMARTBAR_HAS_DBUS
namespace {
const QStringList watchers() {
    return {QStringLiteral("org.kde.StatusNotifierWatcher"),
            QStringLiteral("org.freedesktop.StatusNotifierWatcher")};
}
bool parseItem(const QString &raw, QString *service, QString *objectPath) {
    if (raw.isEmpty() || raw.size() > 512) return false;
    const qsizetype slash = raw.indexOf(QLatin1Char('/'));
    *service = slash == -1 ? raw : raw.left(slash);
    *objectPath = slash == -1 ? QStringLiteral("/StatusNotifierItem") : raw.mid(slash);
    static const QRegularExpression validService(
        QStringLiteral(R"(^(?:(?:[A-Za-z_][A-Za-z0-9_-]*\.)+[A-Za-z_][A-Za-z0-9_-]*|:[0-9]+(?:\.[0-9]+)+)$)"));
    static const QRegularExpression validPath(
        QStringLiteral(R"(^/(?:[A-Za-z0-9_]+(?:/[A-Za-z0-9_]+)*)?$)"));
    return service->size() <= 255 && validService.match(*service).hasMatch() &&
           validPath.match(*objectPath).hasMatch();
}
QString clean(const QString &value) {
    QString result = value.left(128);
    for (qsizetype i = 0; i < result.size(); ++i) {
        const QChar ch = result.at(i);
        if (ch.isNull() || (ch.isSpace() && ch != QLatin1Char(' ')))
            result[i] = QLatin1Char(' ');
    }
    return result;
}
QString iconUrl(const QString &name, quint64 revision) {
    static const QRegularExpression safe(QStringLiteral(R"(^[A-Za-z0-9_+-][A-Za-z0-9_.+-]{0,127}$)"));
    if (!safe.match(name).hasMatch()) return QString();
    return QStringLiteral("image://smartbar-sni/") +
        QString::fromLatin1(QUrl::toPercentEncoding(name)) +
        QStringLiteral("?v=") + QString::number(revision);
}
} // namespace
#endif

StatusNotifierBridge::StatusNotifierBridge(bool requested, QObject *parent)
    : QObject(parent) {
#ifdef SMARTBAR_HAS_DBUS
    m_enabled = requested && QDBusConnection::sessionBus().isConnected();
#else
    Q_UNUSED(requested);
#endif
    m_refreshTimer.setSingleShot(true);
    m_refreshTimer.setInterval(120);
    connect(&m_refreshTimer, &QTimer::timeout, this, &StatusNotifierBridge::refresh);

#ifdef SMARTBAR_HAS_DBUS
    if (!m_enabled) return;
    QDBusConnection bus = QDBusConnection::sessionBus();
    auto *ownerWatcher = new QDBusServiceWatcher(QString(), bus,
                             QDBusServiceWatcher::WatchForOwnerChange, this);
    connect(ownerWatcher, &QDBusServiceWatcher::serviceOwnerChanged,
            this, [this](const QString &, const QString &, const QString &) {
                scheduleRefresh();
            });
    for (const QString &watcherName : watchers()) {
        ownerWatcher->addWatchedService(watcherName);
        bus.connect(watcherName, QStringLiteral("/StatusNotifierWatcher"), watcherName,
                    QStringLiteral("StatusNotifierItemRegistered"),
                    this, SLOT(watcherItemChanged(QString)));
        bus.connect(watcherName, QStringLiteral("/StatusNotifierWatcher"), watcherName,
                    QStringLiteral("StatusNotifierItemUnregistered"),
                    this, SLOT(watcherItemChanged(QString)));
    }
    QTimer::singleShot(0, this, &StatusNotifierBridge::refresh);
#endif
}

void StatusNotifierBridge::scheduleRefresh() {
    if (m_enabled) m_refreshTimer.start();
}
void StatusNotifierBridge::watcherItemChanged(const QString &) {
    scheduleRefresh();
}
void StatusNotifierBridge::itemChanged() {
    scheduleRefresh();
}
void StatusNotifierBridge::itemStatusChanged(const QString &) {
    scheduleRefresh();
}

bool StatusNotifierBridge::activate(const QString &service, const QString &objectPath,
                                    int x, int y) {
    return dispatchItemAction(service, objectPath, QStringLiteral("Activate"), x, y);
}

bool StatusNotifierBridge::contextMenu(const QString &service, const QString &objectPath,
                                       int x, int y) {
    return dispatchItemAction(service, objectPath, QStringLiteral("ContextMenu"), x, y);
}

// Sólo se invoca tras un clic real en una entrada publicada por este mismo
// observador. No se aceptan nombres/rutas arbitarios ni se lanza otro proceso.
bool StatusNotifierBridge::dispatchItemAction(
    const QString &service, const QString &objectPath,
    const QString &method, int x, int y) {
#ifdef SMARTBAR_HAS_DBUS
    if (!m_enabled || !m_available ||
        (method != QStringLiteral("Activate") && method != QStringLiteral("ContextMenu")))
        return false;

    QString itemInterface;
    for (const QVariant &value : m_entries) {
        const QVariantMap entry = value.toMap();
        if (entry.value(QStringLiteral("service")).toString() == service &&
            entry.value(QStringLiteral("objectPath")).toString() == objectPath) {
            itemInterface = entry.value(QStringLiteral("itemInterface")).toString();
            break;
        }
    }
    if (itemInterface != QStringLiteral("org.kde.StatusNotifierItem") &&
        itemInterface != QStringLiteral("org.freedesktop.StatusNotifierItem")) {
        qWarning() << "SmartBar SNI: acción rechazada, indicador no registrado";
        return false;
    }

    const QDBusConnection bus = QDBusConnection::sessionBus();
    if (!bus.isConnected()) return false;
    // Las coordenadas son una pista de ubicación del menú o ventana, no
    // autoridad para mover/redimensionar nada. Acotar valores extremos.
    const int safeX = qBound(-32768, x, 32767);
    const int safeY = qBound(-32768, y, 32767);
    QDBusMessage call = QDBusMessage::createMethodCall(
        service, objectPath, itemInterface, method);
    call << safeX << safeY;
    auto *pending = new QDBusPendingCallWatcher(bus.asyncCall(call, 1800), this);
    connect(pending, &QDBusPendingCallWatcher::finished, this,
            [method](QDBusPendingCallWatcher *done) {
                const QDBusPendingReply<> reply = *done;
                if (reply.isError())
                    qWarning() << "SmartBar SNI: acción" << method
                               << "no atendida:" << reply.error().name();
                else
                    qInfo() << "SmartBar SNI: acción" << method << "enviada";
                done->deleteLater();
            });
    return true; // Encolada, no implica que la aplicación la haya ejecutado.
#else
    Q_UNUSED(service);
    Q_UNUSED(objectPath);
    Q_UNUSED(method);
    Q_UNUSED(x);
    Q_UNUSED(y);
    return false;
#endif
}

void StatusNotifierBridge::refresh() {
#ifdef SMARTBAR_HAS_DBUS
    if (!m_enabled) return;
    QDBusConnection bus = QDBusConnection::sessionBus();
    bool available = false;
    QStringList ids;
    for (const QString &name : watchers()) {
        QDBusInterface watcher(name, QStringLiteral("/StatusNotifierWatcher"), name, bus);
        watcher.setTimeout(750);
        if (!watcher.isValid()) continue;
        const QVariant received = watcher.property("RegisteredStatusNotifierItems");
        if (!received.isValid() || !received.canConvert<QStringList>()) continue;
        available = true;
        ids = received.toStringList();
        break; // Nunca duplicar KDE y Freedesktop cuando apuntan al mismo watcher.
    }

    const quint64 version = ++m_revision;
    QVariantList next;
    QSet<QString> desiredConnections;
    QSet<QString> seen;
    const int limit = qMin(ids.size(), 32); // Límites de trabajo por señal.
    for (int i = 0; i < limit; ++i) {
        QString service, objectPath;
        if (!parseItem(ids.at(i), &service, &objectPath)) continue;
        const QString key = service + QLatin1Char('|') + objectPath;
        if (seen.contains(key)) continue;
        seen.insert(key);

        const QStringList ifaces = {QStringLiteral("org.kde.StatusNotifierItem"),
                                   QStringLiteral("org.freedesktop.StatusNotifierItem")};
        QString itemInterface;
        QVariantMap entry;
        for (const QString &interfaceName : ifaces) {
            QDBusInterface item(service, objectPath, interfaceName, bus);
            item.setTimeout(750);
            if (!item.isValid()) continue;
            const QString id = item.property("Id").toString();
            const QString title = item.property("Title").toString();
            const QString status = item.property("Status").toString();
            const QString iconName = item.property("IconName").toString();
            if (id.isEmpty() && title.isEmpty() && iconName.isEmpty()) continue;
            itemInterface = interfaceName;
            entry.insert(QStringLiteral("service"), service);
            entry.insert(QStringLiteral("objectPath"), objectPath);
            entry.insert(QStringLiteral("itemInterface"), interfaceName);
            entry.insert(QStringLiteral("itemIsMenu"), item.property("ItemIsMenu").toBool());
            entry.insert(QStringLiteral("title"), clean(title.isEmpty() ? id : title));
            entry.insert(QStringLiteral("status"), clean(status));
            entry.insert(QStringLiteral("iconName"), iconName.left(128));
            entry.insert(QStringLiteral("iconSource"), iconUrl(iconName, version));
            break;
        }
        if (itemInterface.isEmpty()) continue;
        next.append(entry);
        desiredConnections.insert(key + QLatin1Char('|') + itemInterface);
    }

    // Suscribirse solo a los emisores vivos. Sin consultas periódicas.
    for (const QString &signalKey : desiredConnections) {
        if (m_connectedSignals.contains(signalKey)) continue;
        const QStringList parts = signalKey.split(QLatin1Char('|'));
        if (parts.size() != 3) continue;
        const QString &service = parts.at(0), &objectPath = parts.at(1), &iface = parts.at(2);
        bus.connect(service, objectPath, iface, QStringLiteral("NewIcon"),
                    this, SLOT(itemChanged()));
        bus.connect(service, objectPath, iface, QStringLiteral("NewAttentionIcon"),
                    this, SLOT(itemChanged()));
        bus.connect(service, objectPath, iface, QStringLiteral("NewTitle"),
                    this, SLOT(itemChanged()));
        bus.connect(service, objectPath, iface, QStringLiteral("NewStatus"),
                    this, SLOT(itemStatusChanged(QString)));
        m_connectedSignals.insert(signalKey);
    }
    for (const QString &old : m_connectedSignals - desiredConnections) {
        const QStringList parts = old.split(QLatin1Char('|'));
        if (parts.size() != 3) continue;
        const QString &service = parts.at(0), &objectPath = parts.at(1), &iface = parts.at(2);
        bus.disconnect(service, objectPath, iface, QStringLiteral("NewIcon"),
                       this, SLOT(itemChanged()));
        bus.disconnect(service, objectPath, iface, QStringLiteral("NewAttentionIcon"),
                       this, SLOT(itemChanged()));
        bus.disconnect(service, objectPath, iface, QStringLiteral("NewTitle"),
                       this, SLOT(itemChanged()));
        bus.disconnect(service, objectPath, iface, QStringLiteral("NewStatus"),
                       this, SLOT(itemStatusChanged(QString)));
    }
    m_connectedSignals = desiredConnections;
    // El número de versión en iconSource fuerza la actualización al recibir NewIcon.
    if (m_available != available || m_entries != next) {
        m_available = available;
        m_entries = next;
        emit entriesChanged();
    }
#endif
}
