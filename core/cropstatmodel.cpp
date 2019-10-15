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

#include "cropstatmodel.h"
#include <QDate>

CropStatModel::CropStatModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop");
}

bool CropStatModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int year = sourceRowValue(sourceRow, sourceParent, "year").toInt();
    return ((year == m_year) && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent));
}
