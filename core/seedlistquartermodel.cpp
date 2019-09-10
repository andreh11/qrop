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

#include "seedlistquartermodel.h"

SeedListQuarterModel::SeedListQuarterModel(QObject *parent, const QString &tableName)
    : SeedListModel(parent, tableName)
{
    setSortColumn("crop_id");
}

int SeedListQuarterModel::groupLessThan(const QModelIndex &left, const QModelIndex &right) const
{
    int leftQuarter = sourceRowValue(left.row(), left.parent(), QStringLiteral("trimester")).toInt();
    int rightQuarter =
            sourceRowValue(right.row(), right.parent(), QStringLiteral("trimester")).toInt();
    if (leftQuarter < rightQuarter)
        return -1;
    if (leftQuarter == rightQuarter)
        return 0;
    else
        return 1;
}
