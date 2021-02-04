/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef VARIETYMODEL_H
#define VARIETYMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT VarietyModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int cropId READ cropId WRITE setCropId NOTIFY cropIdChanged)

public:
    explicit VarietyModel(QObject *parent = nullptr, const QString &tableName = "variety_view");
    int cropId() const;
    void setCropId(int cropId);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

signals:
    void cropIdChanged();

private:
    int m_cropId { -1 };
};

#include <QAbstractListModel>
#include "business/family.h"

class VarietyModel2 : public QAbstractListModel
{
    static const QHash<int, QByteArray> sRoleNames;

public:
    explicit VarietyModel2(QObject *parent = nullptr);

    enum VarietyRole { name = Qt::UserRole, isDefault, seedCompanyId, seedCompanyName, id };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override { return sRoleNames; }
    static QString roleName(int r) { return sRoleNames.value(r); }

    int cropId() const { return m_cropId; }
    void setCropId(int cropId);

private:
    int m_cropId;
    qrp::Crop *m_crop;
};

class VarietyProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(int cropId READ cropId WRITE setCropId)

public:
    VarietyProxyModel(QObject *parent = nullptr);
    ~VarietyProxyModel() override;

    int cropId() const { return m_model ? m_model->cropId() : -1; }
    void setCropId(int cropId)
    {
        if (m_model)
            m_model->setCropId(cropId);
    }

    Q_INVOKABLE int sourceRow(int proxyRow) const
    {
        QModelIndex proxyIndex = index(proxyRow, 0);
        return proxyIndex.isValid() ? mapToSource(proxyIndex).row() : -1;
    }

private:
    VarietyModel2 *m_model;
};

#endif // VARIETYMODEL_H
