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
#include <QDebug>
#include <QSqlRecord>
#include <QVariant>

#include "location.h"
#include "planting.h"
#include "nametree.h"

Location::Location(QObject *parent)
    : DatabaseUtility(parent)
    , planting(new Planting(this))
{
    m_table = "location";
    m_viewTable = "location";
}

// Return a list of all locations in the subtree whose root is locationId.
QList<int> Location::childrenTree(int locationId) const
{
    QList<int> list = children(locationId);
    QList<int> clist;
    int childId = -1;
    int size = list.count();

    for (int i = 0; i < size; i++) {
        childId = list[i];
        clist = children(childId);
        list.append(clist);
        size += clist.count();
    }

    return list;
}

void Location::remove(int id) const
{
    if (id < 1)
        return;

    QString queryString = "DELETE FROM %1 WHERE %2 in (%3)";
    QString idColumnName = table() + "_id";
    QString idString(QString::number(id) + ", ");
    for (int childId : childrenTree(id))
        idString += QString::number(childId) + ", ";
    idString.chop(2);

    QSqlQuery query(queryString.arg(table()).arg(idColumnName).arg(idString));
    query.exec();
    debugQuery(query);
}

int Location::duplicate(int id) const
{
    if (id < 0)
        return -1;
    if (table().isNull())
        return -1;

    QSqlDatabase::database().transaction();
    QVariantMap map = mapFromId(table(), id);
    qDebug() << map;
    map.remove(idFieldName());
    map["name"] = map["name"].toString() + QString(" (copy)");
    int newId = add(map);
    for (int childrenId : children(id))
        duplicateTree(childrenId, newId);
    QSqlDatabase::database().commit();

    return newId;
}

int Location::duplicateTree(int id, int parentId) const
{
    if (id < 0)
        return -1;
    if (table().isNull())
        return -1;

    QVariantMap map = mapFromId(table(), id);
    map.remove(idFieldName());
    map["parent_id"] = QString::number(parentId);
    int newId = add(map);
    for (int childrenId : children(id))
        duplicateTree(childrenId, newId);
    return 0;
}

QString Location::fullName(int locationId) const
{
    if (locationId < 1)
        return {};

    QSqlRecord record(recordFromId("location", locationId));
    if (record.isEmpty())
        return {};

    QString name(record.value("name").toString());
    while (!record.value("parent_id").isNull()) {
        record = recordFromId("location", record.value("parent_id").toInt());
        name = record.value("name").toString() + name;
    }
    return name;
}

QList<QString> Location::pathName(int locationId) const
{
    if (locationId < 1)
        return {};

    QSqlRecord record(recordFromId("location", locationId));
    if (record.isEmpty())
        return {};

    QList<QString> list;
    list.push_front(record.value("name").toString());
    while (!record.value("parent_id").isNull()) {
        record = recordFromId("location", record.value("parent_id").toInt());
        list.push_front(record.value("name").toString());
    }
    return list;
}

QString Location::fullName(QList<int> locationIdList) const
{
    NameTree *root = new NameTree("", 0);
    QList<QString> pathList;
    for (const int id : locationIdList) {
        pathList = pathName(id);
        root->insert(pathList);
    }
    QString name = root->fullName();
    delete root;
    return name;
}

QList<int> Location::locations(int plantingId) const
{
    QString queryString("SELECT * FROM planting_location WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);

    QList<int> recordList;
    while (query.next())
        recordList.push_back(query.value("location_id").toInt());
    return recordList;
}

/* Return the length of plantingId assigned to locationId */
int Location::plantingLength(int plantingId, int locationId) const
{
    QString queryString("SELECT length FROM planting_location "
                        "WHERE planting_id = %1 AND location_id = %2");
    QSqlQuery query(queryString.arg(plantingId).arg(locationId));
    debugQuery(query);

    if (!query.next())
        return 0;

    return query.value("length").toInt();
}

/* Return the ids of all plantings assigned to locationId. */
QList<int> Location::plantings(int locationId) const
{
    QString queryString("SELECT planting_id FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "ORDER BY planting_date DESC");
    return queryIds(queryString.arg(locationId), "planting_id");
}

/* Return the ids of all plantings assigned to locationId befre \a last. */
QList<int> Location::plantings(int locationId, const QDate &last) const
{
    QString lastDateString = last.toString(Qt::ISODate);

    QString queryString("SELECT * FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "AND ((planting_date AND planting_date <= '%2') "
                        "     OR (beg_harvest_date AND beg_harvest_date <= '%2') "
                        "     OR (end_harvest_date AND end_harvest_date <= '%2'))");
    return queryIds(queryString.arg(locationId).arg(lastDateString), "planting_id");
}

/* Return the ids of all plantings assigned to locationId in a given season. */
QList<int> Location::plantings(int locationId, const QDate &seasonBeg, const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);

    QString queryString("SELECT * FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "AND (('%2' <= planting_date AND planting_date <= '%3') "
                        "     OR ('%2' <= beg_harvest_date AND beg_harvest_date <= '%3') "
                        "     OR ('%2' <= end_harvest_date AND end_harvest_date <= '%3'))");
    return queryIds(queryString.arg(locationId).arg(begString).arg(endString), "planting_id");
}

QList<int> Location::children(int locationId) const
{
    QString queryString("SELECT * FROM location WHERE parent_id = %1");
    return queryIds(queryString.arg(locationId), "location_id");
}

/*!
 * Returns a list of planting ids of locationId conflicting with plantingId.
 */
QList<int> Location::conflictingPlantings(int locationId, int plantingId) const
{
    QList<int> clist;
    const QDate plantingDate = planting->plantingDate(plantingId);
    QList<int> plantingIdList = plantings(locationId, plantingDate);
    plantingIdList.removeOne(plantingId);
    const int familyId = planting->familyId(plantingId).toInt();
    const int intervalDays = qAbs(planting->familyInterval(plantingId).toInt()) * 365;

    QDate pdate;
    for (const int pid : plantingIdList) {
        pdate = planting->plantingDate(pid);
        if (familyId == planting->familyId(pid).toInt() && pdate.daysTo(plantingDate) < intervalDays)
            clist.push_back(pid);
    }

    return clist;
}

int Location::availableSpace(int locationId, const QDate &plantingDate, const QDate &endHarvestDate,
                             const QDate &seasonBeg, const QDate &seasonEnd) const
{
    QVariantMap map = mapFromId("location", locationId);
    int length = map.value("bed_length").toInt();

    QList<int> plantingIdList = plantings(locationId, seasonBeg, seasonEnd);

    QDate pdate;
    QDate edate;
    int l = 0;
    int maxl = 0;

    for (int pid : plantingIdList) {
        pdate = planting->plantingDate(pid);
        edate = planting->endHarvestDate(pid);
        l = plantingLength(pid, locationId);
        if (pdate < endHarvestDate && edate > plantingDate && l > maxl)
            maxl = l;
    }
    return length - maxl;
}

int Location::availableSpace(int locationId, int plantingId, const QDate &seasonBeg,
                             const QDate &seasonEnd) const
{
    QDate plantingDate = planting->plantingDate(plantingId);
    QDate endHarvestDate = planting->endHarvestDate(plantingId);
    return availableSpace(locationId, plantingDate, endHarvestDate, seasonBeg, seasonEnd);
}

void Location::addPlanting(int plantingId, int locationId, int length, const QDate &seasonBeg,
                           const QDate &seasonEnd) const
{
    QVariantMap map = mapFromId("location", locationId);
    int lengthToAdd = qMin(length, availableSpace(locationId, plantingId, seasonBeg, seasonEnd));

    if (lengthToAdd < 1)
        return;

    QString queryString("INSERT INTO planting_location (planting_id, location_id, length) "
                        "VALUES (%1, %2, %3)");
    QSqlQuery query(queryString.arg(plantingId).arg(locationId).arg(lengthToAdd));
    query.exec();
    debugQuery(query);
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
