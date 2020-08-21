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

#include "seedlistmonthmodel.h"

SeedListMonthModel::SeedListMonthModel(QObject *parent, const QString &tableName)
    : SeedListModel(parent, tableName)
{
    setSortColumn("crop_id");
}

int SeedListMonthModel::groupLessThan(const QModelIndex &left, const QModelIndex &right) const
{
    int leftMonth = sourceRowValue(left.row(), left.parent(), QStringLiteral("month")).toInt();
    int rightMonth = sourceRowValue(right.row(), right.parent(), QStringLiteral("month")).toInt();
    if (leftMonth < rightMonth)
        return -1;
    if (leftMonth == rightMonth)
        return 0;
    else
        return 1;
}
