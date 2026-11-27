// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QSet>
#include <QString>

class QQuickImageProvider;
QQuickImageProvider *createStatusNotifierIconProvider();

class StatusNotifierBridge final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled CONSTANT)
    Q_PROPERTY(bool available READ available NOTIFY entriesChanged)
    Q_PROPERTY(QVariantList entries READ entries NOTIFY entriesChanged)
    Q_PROPERTY(QVariantList menuEntries READ menuEntries NOTIFY menuChanged)
    Q_PROPERTY(QString menuService READ menuService NOTIFY menuChanged)
    Q_PROPERTY(QString menuObjectPath READ menuObjectPath NOTIFY menuChanged)
public:
    explicit StatusNotifierBridge(bool requested, QObject *parent = nullptr);
    bool enabled() const { return m_enabled; }
    bool available() const { return m_available; }
    QVariantList entries() const { return m_entries; }
    QVariantList menuEntries() const { return m_menuEntries; }
    QString menuService() const { return m_menuService; }
    QString menuObjectPath() const { return m_menuObjectPath; }
    Q_INVOKABLE bool requestMenu(const QString &service, const QString &objectPath,
                                 int parentId = 0);
    Q_INVOKABLE bool triggerMenuEntry(const QString &service, const QString &objectPath,
                                      int entryId);

    // Acciones solo mediante interacción del usuario y un indicador
    // que siga registrado: nunca aceptar destinos D-Bus arbitrarios.
    Q_INVOKABLE bool activate(const QString &service, const QString &objectPath,
                              int x, int y);
    Q_INVOKABLE bool contextMenu(const QString &service, const QString &objectPath,
                                 int x, int y);

signals:
    void entriesChanged();
    void menuChanged();

private slots:
    void refresh();
    void scheduleRefresh();
    void watcherItemChanged(const QString &id);
    void itemChanged();
    void itemStatusChanged(const QString &status);

private:
    bool m_enabled = false;
    bool m_available = false;
    QVariantList m_entries;
    QVariantList m_menuEntries;
    QString m_menuService;
    QString m_menuObjectPath;
    quint64 m_menuRequest = 0;
    bool menuDestination(const QString &service, const QString &objectPath,
                         QString *menuPath) const;
    QTimer m_refreshTimer;
    QSet<QString> m_connectedSignals;
    quint64 m_revision = 0;
    bool dispatchItemAction(const QString &service, const QString &objectPath,
                            const QString &method, int x, int y);
};
