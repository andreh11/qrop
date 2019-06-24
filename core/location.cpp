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
#include <QSettings>
#include <QSqlError>

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

/**
 * Return a list of the ids of all locations in the subtree whose root
 * is \a locationId.
 */
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

    QSqlQuery query(queryString.arg(table(), idColumnName, idString));
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

qreal Location::length(int locationId) const
{
    QSqlRecord record(recordFromId("location", locationId));
    if (record.isEmpty())
        return 0;

    return record.value("length").toReal();
}

bool Location::isGreenhouse(int locationId) const
{
    QSqlRecord record(recordFromId("location", locationId));
    if (record.isEmpty())
        return false;

    return record.value("greenhouse").toInt() == 1;
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

/** Return the ids of the locations to which \a plantingId is assigned. */
QList<int> Location::locations(int plantingId) const
{
    QString queryString("SELECT * FROM planting_location WHERE planting_id = %1");
    return queryIds(queryString.arg(plantingId), "location_id");
}

/** Return the length of \a plantingId assigned to \a locationId. */
qreal Location::plantingLength(int plantingId, int locationId) const
{
    QString queryString("SELECT length FROM planting_location "
                        "WHERE planting_id = %1 AND location_id = %2");
    QSqlQuery query(queryString.arg(plantingId).arg(locationId));
    debugQuery(query);

    if (!query.next())
        return 0;

    return query.value("length").toReal();
}

/** Return the ids of all plantings assigned to \a locationId. */
QList<int> Location::plantings(int locationId) const
{
    QString queryString("SELECT planting_id FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "ORDER BY planting_date DESC");
    return queryIds(queryString.arg(locationId), "planting_id");
}

/** Return the ids of all plantings assigned to \a locationId before the \a last date. */
QList<int> Location::plantings(int locationId, const QDate &last) const
{
    QString lastDateString = last.toString(Qt::ISODate);

    QString queryString("SELECT * FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "AND ((planting_date AND planting_date <= '%2') "
                        "     OR (beg_harvest_date AND beg_harvest_date <= '%2') "
                        "     OR (end_harvest_date AND end_harvest_date <= '%2')) "
                        "ORDER BY (planting_date)");
    return queryIds(queryString.arg(locationId).arg(lastDateString), "planting_id");
}

/**
 * Return the ids of all plantings assigned to \a locationId in the
 * season [\a seasonBeg, \a seasonEnd].
 */
QList<int> Location::plantings(int locationId, const QDate &seasonBeg, const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);

    QString queryString("SELECT planting_id FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "AND (('%2' <= planting_date AND planting_date <= '%3') "
                        "  OR ('%2' <= beg_harvest_date AND beg_harvest_date <= '%3') "
                        "  OR ('%2' <= end_harvest_date AND end_harvest_date <= '%3')) "
                        "ORDER BY (planting_date)");
    return queryIds(queryString.arg(locationId).arg(begString).arg(endString), "planting_id");
}

QList<int> Location::tasks(int locationId, const QDate &seasonBeg, const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);

    QString queryString("SELECT task_id, assigned_date FROM task "
                        "JOIN location_task USING (task_id) "
                        "WHERE location_id = %1 "
                        "AND (('%2' <= assigned_date AND assigned_date <= '%3')"
                        "  OR ('%2' <= date(assigned_date, duration || ' days') "
                        "      AND date(assigned_date, duration || ' days') <= '%3')) "
                        "UNION "
                        "SELECT task_id, assigned_date FROM task "
                        "JOIN planting_task USING (task_id) "
                        "JOIN planting_location USING (planting_id) "
                        "WHERE location_id = %1 "
                        "AND (('%2' <= assigned_date AND assigned_date <= '%3')"
                        "  OR ('%2' <= date(assigned_date, duration || ' days') "
                        "      AND date(assigned_date, duration || ' days') <= '%3')) "
                        "ORDER BY (assigned_date) ");
    return queryIds(queryString.arg(locationId).arg(begString).arg(endString), "task_id");
}

QList<int> Location::children(int locationId) const
{
    QString queryString("SELECT * FROM location WHERE parent_id = %1");
    return queryIds(queryString.arg(locationId), "location_id");
}

/**
 * Return a list of the planting ids of \a locationId conflicting with
 * \a plantingId because they don't observe the family rotation interval.
 */
QList<int> Location::rotationConflictingPlantings(int locationId, int plantingId) const
{
    QList<int> clist;
    const QDate plantingDate = planting->plantingDate(plantingId);
    QList<int> plantingIdList = plantings(locationId, plantingDate);
    plantingIdList.removeOne(plantingId);
    const int intervalDays = qAbs(planting->familyInterval(plantingId).toInt()) * 365;

    QDate pdate;
    for (const int pid : plantingIdList) {
        pdate = planting->plantingDate(pid);
        if (planting->hasSameFamily(plantingId, pid) && pdate.daysTo(plantingDate) < intervalDays
            && !overlap(plantingId, pid))
            clist.push_back(pid);
    }

    return clist;
}

bool Location::overlap(int plantingId1, int plantingId2) const
{
    auto dates1 = planting->dates(plantingId1);
    auto dates2 = planting->dates(plantingId2);

    auto pdate1 = dates1[1];
    auto pdate2 = dates2[1];
    auto edate1 = dates1[3];
    auto edate2 = dates2[3];
    return pdate2 < edate1 && pdate1 < edate2;
}

bool Location::overlap(int plantingId, const QDate &plantingDate, const QDate &endHarvestDate) const
{
    auto dates1 = planting->dates(plantingId);
    auto pdate1 = dates1[1];
    auto edate1 = dates1[3];
    return plantingDate < edate1 && pdate1 < endHarvestDate;
}

/**
 * Return a list of planting ids of \a locationId conflicting because
 * of space availabilty.
 */
QVariantMap Location::spaceConflictingPlantings(int locationId, const QDate &seasonBeg,
                                                const QDate &seasonEnd) const
{
    QList<int> plantingList = plantings(locationId, seasonBeg, seasonEnd);
    QVariantMap conflictMap;
    int bedLength = recordFromId("location", locationId).value("bed_length").toInt();

    for (int i = 0; i < plantingList.count(); i++) {
        int plantingId = plantingList.value(i);
        qreal length = plantingLength(plantingId, locationId);

        for (int j = i + 1; j < plantingList.count(); j++) {
            int pid = plantingList.value(j);
            qreal l = plantingLength(pid, locationId);
            if (overlap(plantingId, pid) && length + l > bedLength)
                conflictMap[QString::number(plantingId)] = QVariant(pid);
        }
    }

    return conflictMap;
}

qreal Location::availableSpace(int locationId, const QDate &plantingDate, const QDate &endHarvestDate,
                               const QDate &seasonBeg, const QDate &seasonEnd) const
{
    QVariantMap map = mapFromId("location", locationId);
    qreal length = map.value("bed_length").toReal();
    qreal l = 0.0;

    for (int pid : plantings(locationId, seasonBeg, seasonEnd))
        if (overlap(pid, plantingDate, endHarvestDate))
            l += plantingLength(pid, locationId);
    return length - l;
}

qreal Location::availableSpace(int locationId, int plantingId, const QDate &seasonBeg,
                               const QDate &seasonEnd) const
{
    QDate plantingDate = planting->plantingDate(plantingId);
    QDate endHarvestDate = planting->endHarvestDate(plantingId);
    return availableSpace(locationId, plantingDate, endHarvestDate, seasonBeg, seasonEnd);
}

void Location::splitPlanting(int plantingId, int otherPlantingId, int locationId)
{
    qreal bedLength = recordFromId("location", locationId).value("bed_length").toReal();
    qreal otherLength = plantingLength(otherPlantingId, locationId);
    qreal lengthToAdd = bedLength - otherLength;

    removePlanting(plantingId, locationId);
    if (lengthToAdd > 0)
        addPlanting(plantingId, locationId, lengthToAdd);
}

/**
 * Assign \a plantingId to \a locationId.
 *
 * No checking is performed.
 *
 * \return the planting length added to the location
 */
qreal Location::addPlanting(int plantingId, int locationId, qreal length) const
{
    QString queryString("INSERT INTO planting_location (planting_id, location_id, length) "
                        "VALUES (%1, %2, %3)");
    QSqlQuery query(queryString.arg(plantingId).arg(locationId).arg(length));
    query.exec();
    debugQuery(query);
    return length;
}

/**
 * Add \a plantingId to \a locationId between \a seasonBeg and \a seasonEnd.
 *
 * If the location has sublocations, assign the planting to the sublocations,
 * checking for available space if planting conflicts aren't authorized.
 *
 * \return the length added to the location or its sublocations.
 */
qreal Location::addPlanting(int plantingId, int locationId, qreal length, const QDate &seasonBeg,
                            const QDate &seasonEnd) const
{
    QSettings settings;
    bool allowConflicts = settings.value("LocationView/allowPlantingsConflict").toBool();
    qreal lengthToAdd;

    // A planting cannot be assigned several times to the same location.
    if (plantings(locationId, seasonBeg, seasonEnd).contains(plantingId))
        return 0;

    if (allowConflicts) {
        qreal bedLength = recordFromId("location", locationId).value("bed_length").toReal();
        lengthToAdd = qMin(length, bedLength);
    } else {
        lengthToAdd = qMin(length, availableSpace(locationId, plantingId, seasonBeg, seasonEnd));
    }

    if (lengthToAdd < 1)
        return 0;

    QString queryString("INSERT INTO planting_location (planting_id, location_id, length) "
                        "VALUES (%1, %2, %3)");
    QSqlQuery query(queryString.arg(plantingId).arg(locationId).arg(lengthToAdd));
    query.exec();
    debugQuery(query);
    return lengthToAdd;
}

/** Remove \a plantingId from \a locationId. */
void Location::removePlanting(int plantingId, int locationId) const
{
    removeLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

/** Remove \a plantingId from all locations to which it is assigned. */
void Location::removePlantingLocations(int plantingId) const
{
    QString queryString = "DELETE FROM planting_location WHERY planting_id = %1)";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

int Location::totalBedLength(bool greenhouse) const
{
    int inGreenhouse = greenhouse ? 1 : 0;
    QString queryString("SELECT SUM(bed_length) "
                        "FROM location "
                        "WHERE greenhouse = %1 "
                        "AND location_id IN "
                        "(SELECT location_id "
                        " FROM location "
                        " EXCEPT "
                        " SELECT parent_id "
                        " FROM location "
                        " WHERE parent_id IS NOT NULL)");
    QSqlQuery query(queryString.arg(inGreenhouse));
    query.exec();
    debugQuery(query);
    query.first();
    return query.value(0).toInt();
}
