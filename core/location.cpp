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

#include <QSqlRecord>
#include <QVariant>

#include "location.h"

Location::Location(QObject *parent)
    : DatabaseUtility(parent)
{
      m_table = "location";
}

QString Location::fullName(int locationId) const
{
    if (locationId < 1)
        return QString();
    QSqlRecord record = recordFromId("location", locationId);

    if (record.isEmpty())
        return QString();

    QString name = record.value("name").toString();
    while (!record.value("parent_id").isNull()) {
        record = recordFromId("location", record.value("parent_id").toInt());
        name = record.value("name").toString() + name;
    }
    return name;
}

QList<QSqlRecord> Location::locations(int plantingId) const
{
    QString queryString = "SELECT * FROM planting_location WHERE planting_id = %1";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);

    QList<QSqlRecord> recordList;
    int id = -1;
    while (query.next()) {
        id = query.value("location_id").toInt();
        recordList.append(recordFromId("location", id));
    }
    return recordList;
}

QList<int> Location::children(int locationId) const
{
    QString queryString("SELECT * FROM location WHERE parent_id = %1");
    return queryIds(queryString.arg(locationId), "location_id");
}

void Location::addPlanting(int plantingId, int locationId) const
{
    addLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

void Location::removePlanting(int plantingId, int locationId) const
{
    removeLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

void Location::removePlantingLocations(int plantingId) const
{
    QString queryString = "DELETE FROM planting_location WHERY planting_id = %1)";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}
