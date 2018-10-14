/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

#ifndef SQLPLANTINGMODEL_H
#define SQLPLANTINGMODEL_H

//#include <QSortFilterProxyModel>
#include <QVariantMap>

#include "sortfilterproxymodel.h"
#include "core_global.h"

class SqlTableModel;

class CORESHARED_EXPORT PlantingModel : public SortFilterProxyModel
{
    Q_OBJECT

public:
    PlantingModel(QObject *parent = nullptr, const QString &tableName = "planting_view");

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
};

#endif // SQLPLANTINGMODEL_H
