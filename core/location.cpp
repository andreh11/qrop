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

#include <QDate>
#include <QDebug>
#include <QSqlRecord>
#include <QVariant>
#include <QSettings>
#include <QSqlError>
#include <QElapsedTimer>

#include "location.h"
#include "planting.h"
#include "nametree.h"
#include "mdate.h"
#include "helpers.h"

Location::Location(QObject *parent)
    : DatabaseUtility(parent)
    , m_planting(new Planting(this))
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
    auto list = children(locationId);
    QList<int> clist;
    int childId = -1;
    int size = list.count();

    for (int i = 0; i < size; ++i) {
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

    const QString queryString = "DELETE FROM %1 WHERE %2 in (%3)";
    const QString idColumnName = table() + "_id";
    QString idString(QString::number(id) + ", ");
    for (const int childId : childrenTree(id))
        idString += QString::number(childId) + ", ";
    idString.chop(2);

    QSqlQuery query(queryString.arg(table(), idColumnName, idString));
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
    for (const int childrenId : children(id))
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
    for (const int childrenId : children(id))
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

QString Location::fullName(const QList<int> &locationIdList) const
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

std::unique_ptr<QSqlQuery> Location::plantingsQuery(int locationId, const QDate &seasonBeg,
                                                    const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);
    QString queryString("SELECT planting_id, crop, variety, planting_date, end_harvest_date, "
                        "planting_location.length as assigned_length "
                        "FROM planting_location "
                        "LEFT JOIN planting_view USING (planting_id) "
                        "WHERE location_id = %1 "
                        "AND ((planting_date BETWEEN '%2' AND '%3') "
                        "  OR (beg_harvest_date BETWEEN '%2' AND '%3') "
                        "  OR (end_harvest_date BETWEEN '%2' AND '%3')) "
                        "ORDER BY (planting_date)");
    return queryBuilder(queryString.arg(locationId).arg(begString).arg(endString));
}

std::unique_ptr<QSqlQuery> Location::plantingsQuery(int locationId, int season, int year) const
{
    const auto dates = MDate::seasonDates(season, year);
    const auto begin = dates.first.addYears(-10);
    const auto end = dates.second;
    return plantingsQuery(locationId, begin, end);
}

std::unique_ptr<QSqlQuery> Location::allLocationsPlantingsQuery(const QDate &seasonBeg,
                                                                const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);
    QString queryString(
            "SELECT location_id, bed_length, planting_id, crop, variety, planting_date, "
            "beg_harvest_date, end_harvest_date, "
            "planting_location.length AS assigned_length "
            "FROM planting_location "
            "LEFT JOIN planting_view USING (planting_id) "
            "LEFT JOIN location USING (location_id) "
            "WHERE ((planting_date    BETWEEN '%1' AND '%2') "
            "    OR (beg_harvest_date BETWEEN '%1' AND '%2') "
            "    OR (end_harvest_date BETWEEN '%1' AND '%2')) "
            "ORDER BY location_id, planting_date");
    return queryBuilder(queryString.arg(begString).arg(endString));
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
    const QDate plantingDate = m_planting->plantingDate(plantingId);
    const int intervalDays = qAbs(m_planting->familyInterval(plantingId).toInt()) * 365;

    QList<int> clist;
    QList<int> plantingIdList = plantings(locationId, plantingDate);
    plantingIdList.removeOne(plantingId);

    QDate pdate;
    for (const int pid : plantingIdList) {
        pdate = m_planting->plantingDate(pid);
        if (m_planting->hasSameFamily(plantingId, pid) && pdate.daysTo(plantingDate) < intervalDays
            && !overlap(plantingId, pid))
            clist.push_back(pid);
    }

    return clist;
}

bool Location::overlap(int plantingId1, int plantingId2) const
{
    if (plantingId1 < 1 || plantingId2 < 1) {
        qDebug() << "Bad planting ids:" << plantingId1 << plantingId2;
        return false;
    }

    auto dates1 = m_planting->dates(plantingId1);
    auto dates2 = m_planting->dates(plantingId2);

    auto pdate1 = dates1[1];
    auto pdate2 = dates2[1];
    auto edate1 = dates1[3];
    auto edate2 = dates2[3];
    return pdate2 < edate1 && pdate1 < edate2;
}

bool Location::overlap(const QDate &plantingDate1, const QDate &endHarvestDate1,
                       const QDate &plantingDate2, const QDate &endHarvestDate2) const
{
    return plantingDate2 < endHarvestDate1 && plantingDate1 < endHarvestDate2;
}

bool Location::overlap(int plantingId, const QDate &plantingDate, const QDate &endHarvestDate) const
{
    if (plantingId < 1) {
        qDebug() << "Bad planting id:" << plantingId;
        return false;
    }

    auto dates1 = m_planting->dates(plantingId);
    auto pdate1 = dates1[1];
    auto edate1 = dates1[3];
    return plantingDate < edate1 && pdate1 < endHarvestDate;
}

/**
 * Return a list of list of plantings id such as for every list[i],
 * every planting of list[i] can be draw on a single row without any
 * overlap.
 */
QVariantList Location::nonOverlappingPlantingList(int locationId, const QDate &seasonBeg,
                                                  const QDate &seasonEnd)
{
    // Use a single query for performance.
    auto query = plantingsQuery(locationId, seasonBeg, seasonEnd);
    if (!query->next())
        return {};

    QVector<QVariantList> rows;
    rows.push_back({ query->value("planting_id").toInt() });

    // rowDate[i] is pair of the planting and end harvest dates of the last planting we added
    // to row i.
    QVector<QPair<QDate, QDate>> rowDate;
    rowDate.push_back({ MDate::dateFromIsoString(query->value("planting_date").toString()),
                        MDate::dateFromIsoString(query->value("end_harvest_date").toString()) });

    while (query->next()) {
        int plantingId = query->value("planting_id").toInt();
        auto plantingDate = MDate::dateFromIsoString(query->value("planting_date").toString());
        auto endHarvestDate = MDate::dateFromIsoString(query->value("end_harvest_date").toString());

        int i = 0;
        for (; i < rowDate.count(); ++i) {
            if (!overlap(rowDate[i].first, rowDate[i].second, plantingDate, endHarvestDate)) {
                rows[i].push_back(plantingId);
                rowDate[i] = { plantingDate, endHarvestDate };
                break;
            }
        }

        if (i == rowDate.count()) {
            // Current planting overlaps every plantings we've already assigned,
            // so we create a new row for it.
            rowDate.push_back({ plantingDate, endHarvestDate });
            rows.push_back({ plantingId });
        }
    }

    // Since QML cannot use a QList of QList<int>, we convert the
    // list to a QVariantList. This may introduce a performance problem,
    // but it is a working solution.
    QVariantList variantList;
    for (const auto &lst : rows) {
        if (!lst.isEmpty())
            variantList.push_back(lst);
    }
    return variantList;
}

QMap<int, QVariantList> Location::allNonOverlappingPlantingList(const QDate &seasonBeg,
                                                                const QDate &seasonEnd) const
{
    // Use a single query for performance.
    auto query = allLocationsPlantingsQuery(seasonBeg, seasonEnd);
    if (!query->next())
        return {};

    QMap<int, QVariantList> map;
    int locationId = query->value("location_id").toInt();

    QVector<QVariantList> rows;
    rows.push_back({ query->value("planting_id").toInt() });

    // rowDate[i] is pair of the planting and end harvest dates of the last planting we added
    // to row i.
    QVector<QPair<QDate, QDate>> rowDate;
    rowDate.push_back({ MDate::dateFromIsoString(query->value("planting_date").toString()),
                        MDate::dateFromIsoString(query->value("end_harvest_date").toString()) });

    int lid;
    int plantingId;
    int i;
    while (query->next()) {
        lid = query->value("location_id").toInt();
        plantingId = query->value("planting_id").toInt();
        auto plantingDate = MDate::dateFromIsoString(query->value("planting_date").toString());
        auto endHarvestDate = MDate::dateFromIsoString(query->value("end_harvest_date").toString());

        if (lid != locationId) {
            // We've found a new location, so we add the list we've just built to the QMap
            // and clear the temporary lists.
            // Since QML cannot use a QList of QList<int>, we convert the
            // list to a QVariantList. This may introduce a performance problem,
            // but it is a working solution.
            QVariantList variantList;
            for (const auto &lst : rows) {
                if (!lst.isEmpty())
                    variantList.push_back(lst);
            }
            map[locationId] = variantList;
            rows.clear();
            rowDate.clear();
            locationId = lid;
            rows.push_back({ plantingId });
            rowDate.push_back({ plantingDate, endHarvestDate });
            continue;
        }

        i = 0;
        for (; i < rowDate.count(); ++i) {
            if (!overlap(rowDate[i].first, rowDate[i].second, plantingDate, endHarvestDate)) {
                rows[i].push_back(plantingId);
                rowDate[i] = { plantingDate, endHarvestDate };
                break;
            }
        }

        if (i == rowDate.count()) {
            // The current planting overlaps every plantings we've already assigned,
            // so we create a new row for it.
            rowDate.push_back({ plantingDate, endHarvestDate });
            rows.push_back({ plantingId });
        }
    }

    // Add last location.
    QVariantList variantList;
    for (const auto &lst : rows) {
        if (!lst.isEmpty())
            variantList.push_back(lst);
    }
    map[locationId] = variantList;

    return map;
}

std::unique_ptr<QSqlQuery> Location::allPlantingTasksQuery(const QDate &seasonBeg,
                                                           const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);
    QString queryString("SELECT planting_id, group_concat(task_id) AS tasks "
                        "FROM planting_task "
                        "LEFT JOIN task USING (task_id) "
                        "WHERE duration > 0 "
                        "AND ((assigned_date BETWEEN '%1' AND '%2') "
                        "OR (date(assigned_date, duration || ' days') BETWEEN '%1' AND '%2') "
                        "OR (completed_date BETWEEN '%1' AND '%2') "
                        "OR (date(completed_date, duration || ' days') BETWEEN '%1' AND '%2')) "
                        "GROUP BY planting_id "
                        "ORDER BY planting_id");
    return queryBuilder(queryString.arg(begString).arg(endString));
}

std::unique_ptr<QSqlQuery> Location::allLocationTasksQuery(const QDate &seasonBeg,
                                                           const QDate &seasonEnd) const
{
    QString begString = seasonBeg.toString(Qt::ISODate);
    QString endString = seasonEnd.toString(Qt::ISODate);
    QString queryString("SELECT location_id, group_concat(task_id) AS tasks "
                        "FROM location_task "
                        "LEFT JOIN task USING (task_id) "
                        "WHERE duration > 0 "
                        "AND ((assigned_date BETWEEN '%1' AND '%2') "
                        "OR (date(assigned_date, duration || ' days') BETWEEN '%1' AND '%2') "
                        "OR (completed_date BETWEEN '%1' AND '%2') "
                        "OR (date(completed_date, duration || ' days') BETWEEN '%1' AND '%2')) "
                        "GROUP BY location_id "
                        "ORDER BY location_id");
    return queryBuilder(queryString.arg(begString).arg(endString));
}

QMap<int, QVariantList> Location::allNonOverlappingTaskList(const QMap<int, QVariantList> &plantingMap,
                                                            const QDate &seasonBeg,
                                                            const QDate &seasonEnd) const
{
    QMap<int, QVariantList> plantingTaskMap;
    auto query = allPlantingTasksQuery(seasonBeg, seasonEnd);
    while (query->next()) {
        const int plantingId = query->value("planting_id").toInt();
        plantingTaskMap[plantingId] = Helpers::listOfVariant(query->value("tasks").toString());
    }

    QMap<int, QVariantList> locationTaskMap;
    auto locationQuery = allLocationTasksQuery(seasonBeg, seasonEnd);
    while (locationQuery->next()) {
        const int locationId = locationQuery->value("location_id").toInt();
        locationTaskMap[locationId] = Helpers::listOfVariant(locationQuery->value("tasks").toString());
    }

    QMap<int, QVariantList> map;

    // add planting tasks
    for (auto location = plantingMap.cbegin(); location != plantingMap.cend(); ++location) {
        QVariantList taskList;

        for (const QVariant &row : location.value()) {
            QVariantList rowList;
            for (const QVariant &plantingId : row.toList())
                rowList.append(plantingTaskMap[plantingId.toInt()]);
            taskList.push_back(rowList);
        }
        map[location.key()] = taskList;
    }

    // add location tasks
    const auto lend = locationTaskMap.cend();
    for (auto location = locationTaskMap.cbegin(); location != lend; ++location)
        map[location.key()].push_back(location.value());
    return map;
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

    for (int i = 0; i < plantingList.count(); ++i) {
        int plantingId = plantingList.value(i);
        qreal length = plantingLength(plantingId, locationId);

        for (int j = i + 1; j < plantingList.count(); ++j) {
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
    QDate plantingDate = m_planting->plantingDate(plantingId);
    QDate endHarvestDate = m_planting->endHarvestDate(plantingId);
    return availableSpace(locationId, plantingDate, endHarvestDate, seasonBeg, seasonEnd);
}

bool Location::acceptPlanting(int locationId, int plantingId, const QDate &seasonBeg,
                              const QDate &seasonEnd) const
{
    return availableSpace(locationId, plantingId, seasonBeg, seasonEnd) > 0;
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
    debugQuery(query);
    return length;
}

/**
 * Add \a plantingId to \a locationId between \a seasonBeg and \a seasonEnd.
 *
 * Check for available space if planting conflicts aren't authorized.
 *
 * \return the length added to the location.
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

qreal Location::totalBedLength(bool greenhouse) const
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
    debugQuery(query);
    query.first();
    return query.value(0).toDouble();
}

std::unique_ptr<QSqlQuery> Location::allHistoryQuery(int season, int year) const
{
    const auto dates = MDate::seasonDates(season, year);
    const auto begin = dates.first.addYears(-20);
    const auto end = dates.second;
    QString queryString(
            "SELECT location_id, planting_id, crop, variety, planting_date, end_harvest_date, "
            "family_id, family_interval "
            "FROM planting_location "
            "LEFT JOIN planting_view USING (planting_id) "
            "WHERE planting_date BETWEEN '%1' AND '%2' "
            "ORDER BY location_id ASC, planting_date DESC");
    return queryBuilder(queryString.arg(begin.toString(Qt::ISODate)).arg(end.toString(Qt::ISODate)));
}

/**
 */
QMap<int, QVariantList> Location::allRotationConflictingPlantings(int season, int year) const
{
    auto query = allHistoryQuery(season, year);
    if (!query->next())
        return {};

    QMap<int, QVariantList> map;
    QMap<int, CropRotationInfoList> cropMap;

    int locationId = query->value("location_id").toInt();
    CropRotationInfoList infoList;

    const auto push = [&infoList, &query]() {
        infoList.push_back({ query->value("planting_id").toInt(), query->value("crop").toString(),
                             query->value("family_id").toInt(), query->value("family_interval").toInt(),
                             MDate::dateFromIsoString(query->value("planting_date").toString()),
                             MDate::dateFromIsoString(query->value("end_harvest_date").toString()) });
    };

    push();

    while (query->next()) {
        int lid = query->value("location_id").toInt();

        // new location
        if (lid != locationId) {
            cropMap[locationId] = infoList;
            infoList.clear();
            locationId = lid;
        }

        push();
    }
    cropMap[locationId] = infoList;

    auto it = cropMap.cbegin();
    auto end = cropMap.cend();
    for (; it != end; ++it) {
        CropRotationInfoList cropList = it.value();
        QVariantList conflictList;
        int length = cropList.length();
        for (int i = 0; i < length; ++i) {
            CropRotationInfo p1 = cropList[i];
            for (int j = i + 1; j < length; ++j) {
                CropRotationInfo p2 = cropList[j];
                if ((p1.plantingDate.year() - p2.endHarvestDate.year()) > p1.familyInterval)
                    break;
                if ((p1.familyId == p2.familyId)
                    && !overlap(p1.plantingDate, p1.endHarvestDate, p2.plantingDate, p2.endHarvestDate)) {
                    conflictList.push_back(i);
                    break;
                }
            }
        }
        map[it.key()] = conflictList;
    }

    return map;
}

QMap<int, QVariantMap> Location::allSpaceConflictingPlantings(int season, int year) const
{
    const auto dates = MDate::seasonDates(season, year);
    auto query = allLocationsPlantingsQuery(dates.first, dates.second);
    if (!query->next())
        return {};

    QMap<int, QVariantMap> map;
    QMap<int, qreal> locationLength;
    QMap<int, CropSpaceInfoList> cropMap;

    int locationId = query->value("location_id").toInt();
    CropSpaceInfoList infoList;

    auto push = [&infoList, &query]() {
        infoList.push_back({ query->value("planting_id").toInt(), query->value("crop").toString(),
                             query->value("assigned_length").toDouble(),
                             MDate::dateFromIsoString(query->value("planting_date").toString()),
                             MDate::dateFromIsoString(query->value("end_harvest_date").toString()) });
    };

    locationLength[locationId] = query->value("bed_length").toDouble();
    push();

    while (query->next()) {
        int lid = query->value("location_id").toInt();

        // new location
        if (lid != locationId) {
            cropMap[locationId] = infoList;
            infoList.clear();
            locationId = lid;
            locationLength[locationId] = query->value("bed_length").toDouble();
        }

        push();
    }
    cropMap[locationId] = infoList;

    auto it = cropMap.cbegin();
    auto end = cropMap.cend();
    for (; it != end; ++it) {
        qreal bedLength = locationLength[it.key()];
        CropSpaceInfoList cropList = it.value();
        QVariantMap conflictMap;
        int length = cropList.length();
        for (int i = 0; i < length; ++i) {
            CropSpaceInfo p1 = cropList[i];
            for (int j = i + 1; j < length; ++j) {
                CropSpaceInfo p2 = cropList[j];

                if (overlap(p1.plantingDate, p1.endHarvestDate, p2.plantingDate, p2.endHarvestDate)
                    && ((p1.assignedLength + p2.assignedLength) > bedLength))
                    conflictMap[QString::number(p1.id)] = QVariant(p2.id);
            }
        }
        map[it.key()] = conflictMap;
    }
    return map;
}

/**
 * @return a map containing a string description of the planting history for every location.
 */
QMap<int, QString> Location::allHistoryDescription(int season, int year) const
{
    auto query = allHistoryQuery(season, year);
    if (!query->next())
        return {};

    auto formatQuery = [&query]() {
        return QString("%1, %2 <i>%3</i><br/>")
                .arg(query->value("crop").toString())
                .arg(query->value("variety").toString())
                .arg(MDate::dateFromIsoString(query->value("planting_date").toString()).year());
    };

    QMap<int, QString> map;
    int locationId = query->value("location_id").toInt();
    map[locationId] = formatQuery();

    while (query->next()) {
        int lid = query->value("location_id").toInt();
        if (lid != locationId) {
            map[locationId].chop(1);
            locationId = lid;
        }
        map[locationId].append(formatQuery());
    }
    return map;
}

// NOTE: not needed anymore
QString Location::historyDescription(int locationId, int season, int year) const
{
    auto query = plantingsQuery(locationId, season, year);
    QString text;
    while (query->next())
        text += QString("%1, %2 %3\n")
                        .arg(query->value("crop").toString())
                        .arg(query->value("variety").toString())
                        .arg(MDate::dateFromIsoString(query->value("planting_date").toString()).year());
    text.chop(1);
    return text;
}
