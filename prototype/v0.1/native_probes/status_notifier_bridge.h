// Copyright (c) Plasma SmartBar contributors. SPDX-License-Identifier: MIT
#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QSet>
#include <QString>

class StatusNotifierBridge final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled CONSTANT)
    Q_PROPERTY(bool available READ available NOTIFY entriesChanged)
    Q_PROPERTY(QVariantList entries READ entries NOTIFY entriesChanged)
public:
    explicit StatusNotifierBridge(bool requested, QObject *parent = nullptr);
    bool enabled() const { return m_enabled; }
    bool available() const { return m_available; }
    QVariantList entries() const { return m_entries; }

signals:
    void entriesChanged();

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
    QTimer m_refreshTimer;
    QSet<QString> m_connectedSignals;
    quint64 m_revision = 0;
};
