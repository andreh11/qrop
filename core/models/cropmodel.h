/*
 * Copyright (C) 2018-2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
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

#ifndef CROPMODEL_H
#define CROPMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT CropModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int familyId READ familyId WRITE setFamilyId NOTIFY familyIdChanged)

public:
    explicit CropModel(QObject *parent = nullptr, const QString &tableName = "crop");
    int familyId() const;
    void setFamilyId(int familyId);

signals:
    void familyIdChanged();

private:
    int m_familyId { -1 };
};

#include <QAbstractListModel>
#include "business/family.h"
class Qrop;

class CORESHARED_EXPORT CropModel2 : public QAbstractListModel
{
    static const QHash<int, QByteArray> sRoleNames;

public:
    explicit CropModel2(QObject *parent = nullptr);

    enum CropRole { name = Qt::UserRole, color, id, deleted };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override { return sRoleNames; }
    static QString roleName(int r) { return sRoleNames.value(r); }

    int familyId() const { return m_familyId; }
    void setFamilyId(int familyId);

private:
    int m_familyId;
    qrp::Family *m_family;
};

class CORESHARED_EXPORT CropProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int familyId READ familyId WRITE setFamilyId)

public:
    CropProxyModel(QObject *parent = nullptr);
    ~CropProxyModel() override;

    int familyId() const { return m_model ? m_model->familyId() : -1; }
    void setFamilyId(int familyId)
    {
        if (m_model)
            m_model->setFamilyId(familyId);
    }

    Q_INVOKABLE int sourceRow(int proxyRow) const
    {
        QModelIndex proxyIndex = index(proxyRow, 0);
        return proxyIndex.isValid() ? mapToSource(proxyIndex).row() : -1;
    }

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    CropModel2 *m_model;
};

#endif // CROPMODEL_H
