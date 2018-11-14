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
    : DatabaseUtility(parent),
      task(new Task(this)),
      keyword(new Keyword(this))
{
    m_table = "planting";
    m_idFieldName = "planting_id";
}

//QList<int> Planting::keywordListFromString(const QString &idString) const
//{

//}

// map has planting table's fields and a "keyword_ids" field.
int Planting::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString = newMap["planting_date"].toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    QList<QVariant> keywordIdList = newMap.take("keyword_ids").toList();

    int id = DatabaseUtility::add(newMap);

    if (id < 1)
        return -1;

    task->createTasks(id, plantingDate);

    for (const auto &keywordId : keywordIdList)
        keyword->addPlanting(id, keywordId.toInt());

    return id;
}

QList<int> Planting::addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const
{
    const int daysBetween = weeksBetween * 7;
    QDate sowingDate = QDate::fromString(map["sowing_date"].toString(), Qt::ISODate);
    QDate plantingDate = QDate::fromString(map["planting_date"].toString(), Qt::ISODate);
    QDate begHarvestDate = QDate::fromString(map["beg_harvest_date"].toString(), Qt::ISODate);
    QDate endHarvestDate = QDate::fromString(map["end_harvest_date"].toString(), Qt::ISODate);
    QVariantMap newMap(map);
    QList<int> ids;

    QSqlDatabase::database().transaction();
    for (int i = 0; i < successions; i++) {
        int days = i * daysBetween;
        newMap["sowing_date"] = sowingDate.addDays(days).toString(Qt::ISODate);
        newMap["planting_date"] = plantingDate.addDays(days).toString(Qt::ISODate);
        newMap["beg_harvest_date"] = begHarvestDate.addDays(days).toString(Qt::ISODate);
        newMap["end_harvest_date"] = endHarvestDate.addDays(days).toString(Qt::ISODate);

        int id = add(newMap);
        ids.append(id);
    }
    QSqlDatabase::database().commit();

    return ids;
}

QVariantMap Planting::lastValues(const int varietyId,
                                 const int cropId,
                                 const int plantingType,
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

    for (int i = 0; i < queryList.length(); i++) {
        QSqlQuery query(queryList[i]);
        query.exec();
        debugQuery(query);

        if (query.first()) {
            int plantingId = query.record().value("planting_id").toInt();
            if (plantingId >= 1)
                return mapFromId("planting", plantingId);
        }
        qDebug() << "lastValues: trying with less constraints...";
    }
    qDebug() << "Couldn't find prefill values!";

    return QVariantMap();
}

QVariantMap Planting::commonValues(const QList<int> &plantingIdList) const
{
    if (plantingIdList.length() < 1)
        return QVariantMap();

    QList<QVariantMap> list = mapListFromIdList("planting", plantingIdList);
    QVariantMap common = list[0];

    if (list.length() == 1)
        return common;

    for (auto &key : common.keys()) {
        int i;
        for (i = 1; i < list.length(); i ++)
            if (list[i].value(key) != common.value(key))
                break;
        if (i != list.length())
            common.remove(key);
    }

    return common;
}

void Planting::update(int id, const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString = newMap.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    DatabaseUtility::update(id, newMap);
    task->updateTaskDates(id, plantingDate);
}
