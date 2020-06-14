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

#include <QDebug>
#include "sqltablemodel.h"
#include "varietymodel.h"

VarietyModel::VarietyModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setFilterKeyStringColumn("variety");
    setSortColumn("variety");
}

int VarietyModel::cropId() const
{
    return m_cropId;
}

void VarietyModel::setCropId(int cropId)
{
    if (cropId == m_cropId)
        return;

    m_cropId = cropId;
    invalidateFilter();
    emit cropIdChanged();
}

bool VarietyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int cropId = sourceRowValue(sourceRow, sourceParent, "crop_id").toInt();
    return cropId == m_cropId && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
