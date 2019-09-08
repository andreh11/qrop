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

#include <QDate>

#include "transplantlistmodel.h"

TransplantListModel::TransplantListModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop_id");
}

bool TransplantListModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int year = sourceRowValue(sourceRow, sourceParent, "year").toInt();
    return (year == m_year) && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}

bool TransplantListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_sortColumn == QStringLiteral("planting_date")) {
        auto lhs = sourceFieldDate(left.row(), left.parent(), "planting_date");
        auto rhs = sourceFieldDate(right.row(), right.parent(), "planting_date");
        return lhs < rhs;
    } else if (m_sortColumn == QStringLiteral("crop")) {
        auto leftCrop = sourceRowValue(left.row(), left.parent(), "crop").toString();
        auto rightCrop = sourceRowValue(right.row(), right.parent(), "crop").toString();
        int cmp = leftCrop.localeAwareCompare(rightCrop);
        if (cmp < 0) {
            return true;
        } else if (cmp == 0) {
            auto leftVariety = sourceRowValue(left.row(), left.parent(), "variety").toString();
            auto rightVariety = sourceRowValue(right.row(), right.parent(), "variety").toString();
            return leftVariety.localeAwareCompare(rightVariety) < 0;
        }
    } else if (m_sortColumn == QStringLiteral("variety")
               || m_sortColumn == QStringLiteral("seed_company")) {
        auto leftVariety = sourceRowValue(left.row(), left.parent(), m_sortColumn).toString();
        auto rightVariety = sourceRowValue(right.row(), right.parent(), m_sortColumn).toString();
        return leftVariety.localeAwareCompare(rightVariety) < 0;
    } else if (m_sortColumn == QStringLiteral("seeds_number")
               || m_sortColumn == QStringLiteral("seeds_quantity")) {
        auto lhs = sourceRowValue(left.row(), left.parent(), m_sortColumn).toInt();
        auto rhs = sourceRowValue(right.row(), right.parent(), m_sortColumn).toInt();
        return lhs < rhs;
    }
    return SortFilterProxyModel::lessThan(left, right);
}
