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

#ifndef SEEDCOMPANYMODEL_H
#define SEEDCOMPANYMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT SeedCompanyModel : public SortFilterProxyModel
{
    Q_OBJECT
public:
    explicit SeedCompanyModel(QObject *parent = nullptr, const QString &tableName = "seed_company");
};

#include <QAbstractListModel>
class Qrop;

class SeedCompanyModel2 : public QAbstractListModel
{
    static const QHash<int, QByteArray> sRoleNames;

public:
    explicit SeedCompanyModel2(Qrop *qrop, QObject *parent = nullptr);

    enum SeedCompanyRole { name = Qt::UserRole, isDefault, id };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override { return sRoleNames; }

private:
    Qrop *m_qrop;
};

class SeedCompanyProxyModel : public QSortFilterProxyModel
{
public:
    SeedCompanyProxyModel(Qrop *qrop, QObject *parent = nullptr);
    ~SeedCompanyProxyModel() override;

    Q_INVOKABLE int sourceRow(int proxyRow) const
    {
        QModelIndex proxyIndex = index(proxyRow, 0);
        return proxyIndex.isValid() ? mapToSource(proxyIndex).row() : -1;
    }

private:
    SeedCompanyModel2 *m_model;
};

#endif // SEEDCOMPANYMODEL_H
