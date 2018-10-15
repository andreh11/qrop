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

#include <QDebug>
#include <QDate>
#include <QVector>

#include "databaseutility.h"
#include "sqltablemodel.h"
#include "plantingmodel.h"

PlantingModel::PlantingModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop");

//    int varietyColumn = fieldColumn("variety_id");
//    setRelation(varietyColumn, QSqlRelation("variety", "variety_id", "variety"));

//    select();
}

bool PlantingModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
//    int dtt = rowValue(sourceRow, sourceParent, "dtt").toInt();
//    int dtm = rowValue(sourceRow, sourceParent, "dtm").toInt();
//    int harvestWindow = rowValue(sourceRow, sourceParent, "harvest_window").toInt();
    QDate sowingDate = fieldDate(sourceRow, sourceParent, "sowing_date");
    QDate plantingDate = fieldDate(sourceRow, sourceParent, "planting_date");
    QDate harvestBeginDate = fieldDate(sourceRow, sourceParent, "beg_haverst_date");
    QDate harvestEndDate = fieldDate(sourceRow, sourceParent, "end_harvest_date");
//    QDate harvestBeginDate = plantingDate.addDays(dtm);
//    QDate harvestEndDate = harvestBeginDate.addDays(harvestWindow);
//    QDate seedingDate;

//    auto type = static_cast<PlantingType>(rowValue(sourceRow, sourceParent, "planting_type").toInt());
//    if (type == PlantingType::TransplantRaised)
//        seedingDate = plantingDate.addDays(-dtt);
//    else
//        seedingDate = plantingDate;

    bool inRange = isDateInRange(sowingDate)
            || isDateInRange(plantingDate)
            || isDateInRange(harvestBeginDate)
            || isDateInRange(harvestEndDate);

    return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent) && inRange;
}
