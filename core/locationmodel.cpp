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
#include <QSqlQuery>

#include "locationmodel.h"

LocationModel::LocationModel(QObject *parent)
    : SqlTableModel(parent)
{
    setTable("location");

//    int parentColumn = fieldColumn("parent_id");
//    setRelation(parentColumn, QSqlRelation("location", "location_id", "name"));
}

void LocationModel::removePlantingLocations(int plantingId)
{
    qDebug() << "[LocationModel] Removing planting" << plantingId
             << "from all locations";
    QString queryString("DELETE FROM planting_location WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}
