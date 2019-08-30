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

#include "seedlistmonthmodel.h"

SeedListMonthModel::SeedListMonthModel(QObject *parent, const QString &tableName)
    : SeedListModel(parent, tableName)
{
    setSortColumn("crop_id");
}

void SeedListMonthModel::setSortColumn(const QString &columnName)
{
    m_sortColumn = columnName;
    sort(0, m_sortOrder == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    sortColumnChanged();
}

void SeedListMonthModel::setSortOrder(const QString &order)
{
    m_sortOrder = order;
    sort(0, m_sortOrder == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    sortOrderChanged();
}

bool SeedListMonthModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int year = rowValue(sourceRow, sourceParent, "year").toInt();
    return (year == m_year) && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}

int SeedListMonthModel::groupLessThan(const QModelIndex &left, const QModelIndex &right) const
{
    int leftMonth = rowValue(left.row(), left.parent(), QStringLiteral("month")).toInt();
    int rightMonth = rowValue(right.row(), right.parent(), QStringLiteral("month")).toInt();
    if (leftMonth < rightMonth)
        return -1;
    else if (leftMonth == rightMonth)
        return 0;
    else
        return 1;
}
