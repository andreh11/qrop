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

#ifndef SEEDLISTMODEL_H
#define SEEDLISTMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT SeedListModel : public SortFilterProxyModel
{
    Q_OBJECT
public:
    explicit SeedListModel(QObject *parent = nullptr, const QString &tableName = "seed_list_view");
    Q_INVOKABLE void csvExport(const QUrl &path);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    virtual int groupLessThan(const QModelIndex &left, const QModelIndex &right) const;
};

#endif // SEEDLISTMODEL_H
