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
#include <QVariantMap>

#include "planting.h"
#include "task.h"
#include "keyword.h"

Planting::Planting(QObject *parent)
    : DatabaseUtility(parent)
    , task(new Task(this))
    , keyword(new Keyword(this))
{
    m_table = "planting";
    m_viewTable = "planting_view";
    m_idFieldName = "planting_id";
}

// QList<int> Planting::keywordListFromString(const QString &idString) const
//{

//}

// map has planting table's fields and a "keyword_ids" field.
int Planting::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString = newMap.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    QList<QVariant> keywordIdList = newMap.take("keyword_ids").toList();
    qDebug() << newMap.value("unit_id");

    // Check if foreign seems to be valid, otherwise remove it.
    if (newMap.contains("unit_id") && newMap.value("unit_id").toInt() < 1)
        newMap.remove("unit_id");

    int id = DatabaseUtility::add(newMap);
    if (id < 1)
        return -1;
    qDebug() << plantingDate;

    task->createTasks(id, plantingDate);
    for (const auto &keywordId : keywordIdList)
        keyword->addPlanting(id, keywordId.toInt());

    return id;
}

QList<int> Planting::addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const
{
    const int daysBetween = weeksBetween * 7;
    //    QDate sowingDate = QDate::fromString(map["sowing_date"].toString(), Qt::ISODate);
    QDate plantingDate = QDate::fromString(map["planting_date"].toString(), Qt::ISODate);
    //    QDate begHarvestDate = QDate::fromString(map["beg_harvest_date"].toString(), Qt::ISODate);
    //    QDate endHarvestDate = QDate::fromString(map["end_harvest_date"].toString(), Qt::ISODate);
    QVariantMap newMap(map);
    QList<int> ids;

    QSqlDatabase::database().transaction();
    for (int i = 0; i < successions; i++) {
        int days = i * daysBetween;
        newMap["planting_date"] = plantingDate.addDays(days).toString(Qt::ISODate);

        int id = add(newMap);
        if (id > 0)
            ids.append(id);
    }
    QSqlDatabase::database().commit();

    return ids;
}

QVariantMap Planting::lastValues(const int varietyId, const int cropId, const int plantingType,
                                 const bool inGreenhouse) const
{
    const QString cropQueryString("SELECT planting_id FROM planting_view"
                                  " WHERE crop_id = %1 ORDER BY planting_id DESC");
    const QString varietyQueryString("SELECT planting_id FROM planting_view"
                                     " WHERE variety_id = %1 ORDER BY planting_id DESC");
    const QString plantingTypeQueryString("SELECT planting_id FROM planting_view"
                                          " WHERE variety_id = %1"
                                          " AND planting_type = %2"
                                          " ORDER BY planting_id DESC");
    const QString inGhQueryString("SELECT planting_id FROM planting_view"
                                  " WHERE variety_id = %1"
                                  " AND planting_type = %2"
                                  " AND in_greenhouse = %3"
                                  " ORDER BY planting_id DESC");

    QSqlQuery query1(inGhQueryString.arg(varietyId).arg(plantingType).arg(inGreenhouse ? 1 : 0));
    QSqlQuery query2(plantingTypeQueryString.arg(varietyId).arg(plantingType));
    QSqlQuery query3(varietyQueryString.arg(varietyId));
    QSqlQuery query4(cropQueryString.arg(cropId));

    QList<QSqlQuery> queryList;
    queryList.push_back(query1);
    queryList.push_back(query2);
    queryList.push_back(query3);
    queryList.push_back(query4);

    for (auto query : queryList) {
        query.exec();
        debugQuery(query);

        if (query.first()) {
            int plantingId = query.record().value("planting_id").toInt();
            if (plantingId >= 1) {
                qDebug() << mapFromId("planting", plantingId);
                return mapFromId("planting", plantingId);
            }
        }
    }

    return {};
}

void Planting::update(int id, const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString;
    if (newMap.contains("planting_date"))
        plantingDateString = newMap.take("planting_date").toString();
    DatabaseUtility::update(id, newMap);

    if (!plantingDateString.isNull()) {
        QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
        task->updateTaskDates(id, plantingDate);
    }

    if (newMap.contains("keyword_ids")) {
        QList<QVariant> keywordIdList = newMap.take("keyword_ids").toList(); // TODO: update keyword
    }
}

int Planting::duplicate(int id) const
{
    int newId = DatabaseUtility::duplicate(id);
    task->duplicatePlantingTasks(id, newId);
    return newId;
}

QString Planting::cropName(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("crop").toString();
}

QString Planting::cropId(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("crop_id").toString();
}

QString Planting::cropColor(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("crop_color").toString();
}

QString Planting::varietyName(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("variety").toString();
}

QString Planting::familyId(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("family_id").toString();
}

QString Planting::familyInterval(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("family_interval").toString();
}

QString Planting::familyColor(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("family_color").toString();
}

int Planting::type(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("planting_type").toInt();
}

QDate Planting::sowingDate(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};

    return QDate::fromString(map.value("sowing_date").toString(), Qt::ISODate);
}

QDate Planting::plantingDate(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};

    return QDate::fromString(map.value("planting_date").toString(), Qt::ISODate);
}

QDate Planting::begHarvestDate(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};

    return QDate::fromString(map.value("beg_harvest_date").toString(), Qt::ISODate);
}

QDate Planting::endHarvestDate(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};

    return QDate::fromString(map.value("end_harvest_date").toString(), Qt::ISODate);
}

int Planting::totalLength(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("length").toInt();
}

/* Return the already assigned bed length for plantingId */
int Planting::assignedLength(int plantingId) const
{
    if (plantingId < 1)
        return 0;

    QString queryString("SELECT SUM(length) FROM planting_location WHERE planting_id=%1");
    QSqlQuery query(queryString.arg(plantingId));
    query.exec();
    debugQuery(query);

    if (!query.next())
        return 0;

    return query.value(0).toInt();
}

int Planting::lengthToAssign(int plantingId) const
{
    QVariantMap map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return 0;

    int length = map.value("length").toInt();
    return length - assignedLength(plantingId);
}
