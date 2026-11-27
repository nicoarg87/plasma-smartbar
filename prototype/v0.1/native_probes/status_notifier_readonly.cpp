// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
// Consulta puntual de SNI con Qt 6/D-Bus, sin registrar hosts ni modificar KDE.
// Esta herramienta NO se construye junto al ensayo normal (EXCLUDE_FROM_ALL).
#include <QCoreApplication>
#include <QByteArray>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QStringList>
#include <QVariant>
#include <cstdio>

static bool parseItem(const QString &raw, QString *service, QString *objectPath) {
    if (raw.isEmpty() || raw.size() > 512) return false;
    const qsizetype slash = raw.indexOf(QLatin1Char('/'));
    *service = slash == -1 ? raw : raw.left(slash);
    *objectPath = slash == -1 ? QStringLiteral("/StatusNotifierItem") : raw.mid(slash);
    static const QRegularExpression servicePattern(
        QStringLiteral(R"(^(?:[A-Za-z_][A-Za-z0-9_-]*\.)+[A-Za-z_][A-Za-z0-9_-]*$)"));
    static const QRegularExpression uniquePattern(QStringLiteral(R"(^:[0-9]+(?:\.[0-9]+)+$)"));
    static const QRegularExpression pathPattern(
        QStringLiteral(R"(^/(?:[A-Za-z0-9_]+(?:/[A-Za-z0-9_]+)*)?$)"));
    return service->size() <= 255 &&
        (servicePattern.match(*service).hasMatch() ||
         uniquePattern.match(*service).hasMatch()) &&
        pathPattern.match(*objectPath).hasMatch();
}

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    if (argc != 1) {
        std::fputs("Uso: smartbar_sni_readonly_probe (sin argumentos)\n", stderr);
        return 2;
    }
    const QDBusConnection bus = QDBusConnection::sessionBus();
    if (!bus.isConnected()) {
        std::fputs("Sin conexión al bus D-Bus de sesión. Ningún cambio.\n", stderr);
        return 3;
    }
    const QStringList watcherNames = {
        QStringLiteral("org.kde.StatusNotifierWatcher"),
        QStringLiteral("org.freedesktop.StatusNotifierWatcher")
    };
    for (const QString &watcherName : watcherNames) {
        QDBusInterface watcher(watcherName, QStringLiteral("/StatusNotifierWatcher"),
                              watcherName, bus);
        watcher.setTimeout(1500);
        if (!watcher.isValid()) continue;
        const QVariant registered = watcher.property("RegisteredStatusNotifierItems");
        if (!registered.isValid() || !registered.canConvert<QStringList>()) continue;

        QJsonArray entries;
        const QStringList ids = registered.toStringList();
        for (const QString &raw : ids) {
            QString service;
            QString objectPath;
            if (!parseItem(raw, &service, &objectPath)) continue;
            QDBusInterface item(service, objectPath,
                               QStringLiteral("org.kde.StatusNotifierItem"), bus);
            item.setTimeout(1500);
            const auto appendEntry = [&](QDBusInterface &source) {
                QJsonObject entry;
                entry.insert(QStringLiteral("service"), service);
                entry.insert(QStringLiteral("objectPath"), objectPath);
                entry.insert(QStringLiteral("id"), source.property("Id").toString());
                entry.insert(QStringLiteral("title"), source.property("Title").toString());
                entry.insert(QStringLiteral("iconName"), source.property("IconName").toString());
                entry.insert(QStringLiteral("status"), source.property("Status").toString());
                entries.append(entry);
            };
            if (item.isValid()) {
                appendEntry(item);
            } else {
                QDBusInterface fallback(service, objectPath,
                                       QStringLiteral("org.freedesktop.StatusNotifierItem"), bus);
                fallback.setTimeout(1500);
                if (fallback.isValid()) appendEntry(fallback);
            }
        }
        QJsonObject report;
        report.insert(QStringLiteral("watcher"), watcherName);
        report.insert(QStringLiteral("registeredCount"), ids.size());
        report.insert(QStringLiteral("readableCount"), entries.size());
        report.insert(QStringLiteral("entries"), entries);
        const QByteArray json = QJsonDocument(report).toJson(QJsonDocument::Indented);
        std::fwrite(json.constData(), 1, size_t(json.size()), stdout);
        return 0;
    }
    std::fputs("No se encontró un watcher SNI legible. No se modificó KDE.\n", stderr);
    return 4;
}
