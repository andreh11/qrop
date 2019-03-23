/*
 * Copyright (C) 2018, 2019 André Hoarau <ah@ouvaton.org>
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
#include <QtMath>

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

// map has planting table's fields and a "keyword_ids" field.
int Planting::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString = newMap.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    QList<QVariant> keywordIdList = newMap.take("keyword_ids").toList();

    // Check if unit id foreign key seems to be valid. If not, remove it.
    if (newMap.contains("unit_id") && newMap.value("unit_id").toInt() < 1)
        newMap.remove("unit_id");

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
    QDate plantingDate = QDate::fromString(map["planting_date"].toString(), Qt::ISODate);
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
                return mapFromId("planting", plantingId);
            }
        }
    }

    return {};
}

/** \brief Given a \a key, return its value in \a map if contains this key.
 *  Otherwise returs the value of the \a record for this key.
 */
QVariant Planting::get(const QVariantMap &map, const QSqlRecord &record, const QString &key) const
{
    if (map.contains(key))
        return map.value(key);
    else if (record.contains(key))
        return record.value(key);
    else
        return {};
}

void Planting::setGreenhouseValues(QVariantMap &map, const QSqlRecord &record)
{
    int plantsNeeded = get(map, record, "plants_needed").toInt();
    int greenhouseLoss = get(map, record, "estimated_gh_loss").toInt();
    int seedsPerHole = get(map, record, "seeds_per_hole").toInt();
    double seedsPerGram = get(map, record, "seeds_per_gram").toDouble();
    int traySize = get(map, record, "tray_size").toInt();

    int plantsToStart = qCeil(static_cast<double>(plantsNeeded) / (1 - greenhouseLoss / 100));

    double traysToStart = plantsToStart / traySize;

    int seedsNumber = plantsToStart * seedsPerHole;
    double seedsQuantity = seedsNumber / seedsPerGram;

    map["plants_to_start"] = plantsToStart;
    map["trays_to_start"] = traysToStart;
    map["seeds_number"] = seedsNumber;
    map["seeds_quantity"] = seedsQuantity;
}

void Planting::update(int id, const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString;

    if (newMap.contains("planting_date"))
        plantingDateString = newMap.take("planting_date").toString();

    QSqlRecord record = recordFromId("planting_view", id);

    // If the length, the number of rows or the in-row spacing have changed,
    // recompute the number of plants needed.
    if (newMap.contains("length") || newMap.contains("rows") || newMap.contains("spacing_plants")) {
        double length = get(newMap, record, "length").toDouble();
        int rows = get(newMap, record, "rows").toInt();
        int spacing = get(newMap, record, "spacing_plants").toInt();

        int plantsNeeded = spacing > 0 ? qCeil(length / spacing * 100 * rows) : 0;
        newMap["plants_needed"] = plantsNeeded;
    }

    int plantingType = get(newMap, record, "planting_type").toInt();

    // If the planting type has changed from TP, raised to DS or TP, bought,
    // we set the DTT to 0 and remove the nursery seeding task.
    if ((record.value("planting_type").toInt() == 2) && (plantingType != 2)) {
        newMap["dtt"] = 0;
        task->removeNurseryTask(id);
    }

    // Recompute seeds number for direct seeding.
    if ((newMap.contains("plants_needed") && plantingType == 1) || newMap.contains("seeds_per_hole")
        || newMap.contains("seeds_percentage")) {
        int plantsNeeded = get(newMap, record, "plants_needed").toInt();
        int seedsPerHole = get(newMap, record, "seeds_per_hole").toInt();
        int seedsPercentage = get(newMap, record, "seeds_percentage").toInt();

        int seedsNumber =
                qCeil(plantsNeeded * seedsPerHole * (1 + static_cast<double>(seedsPercentage) / 100));
        newMap["seeds_number"] = seedsNumber;
    }

    // Recompute plants to start.
    if ((newMap.contains("plants_needed") && plantingType == 2)
        || newMap.contains("estimated_gh_loss")) {
        int plantsNeeded = get(newMap, record, "plants_needed").toInt();
        int greenhouseLoss = get(newMap, record, "estimated_gh_loss").toInt();
        newMap["plants_to_start"] =
                qCeil(plantsNeeded / (1 - static_cast<double>(greenhouseLoss) / 100));
    }

    // Recompute trays to start.
    if (newMap.contains("plants_to_start") || newMap.contains("tray_size")) {
        int plantsToStart = get(newMap, record, "plants_to_start").toInt();
        int traySize = get(newMap, record, "tray_size").toInt();
        newMap["trays_to_start"] = static_cast<double>(plantsToStart) / traySize;
    }

    // Recompute seeds number for raised transplants.
    if (newMap.contains("plants_to_start") || (plantingType == 2 && newMap.contains("seeds_per_hole"))) {
        int plantsToStart = get(newMap, record, "plants_to_start").toInt();
        int seedsPerHole = get(newMap, record, "seeds_per_hole").toInt();
        newMap["seeds_number"] = plantsToStart * seedsPerHole;
    }

    // Recompute seeds quantity (in grams).
    if (newMap.contains("seeds_number") || newMap.contains("seeds_per_gram")) {
        int seedsNumber = get(newMap, record, "seeds_number").toInt();
        double seedsPerGram = get(newMap, record, "seeds_per_gram").toDouble();
        newMap["seeds_quantity"] = static_cast<double>(seedsNumber) / seedsPerGram;
    }

    // Handle bulk editing of keywords.
    if (newMap.contains("keyword_new_ids")) {
        const auto &keywordIdList = newMap.take("keyword_new_ids").toList();
        const auto &oldKeywordIdList = newMap.take("keyword_old_ids").toList();
        QList<int> toAdd;
        QList<int> toRemove;

        for (auto &newid : keywordIdList)
            if (!oldKeywordIdList.contains(newid.toInt()))
                toAdd.push_back(newid.toInt());

        for (auto &oldid : oldKeywordIdList)
            if (!keywordIdList.contains(oldid))
                toRemove.push_back(oldid.toInt());

        for (int keywordId : toAdd)
            keyword->addPlanting(id, keywordId);

        for (int keywordId : toRemove)
            keyword->removePlanting(id, keywordId);
    }

    DatabaseUtility::update(id, newMap);

    if (!plantingDateString.isNull()) {
        QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
        task->updateTaskDates(id, plantingDate);
    }
}

int Planting::duplicate(int id) const
{
    int newId = DatabaseUtility::duplicate(id);
    task->duplicatePlantingTasks(id, newId);
    return newId;
}

QVariantMap Planting::commonValues(const QList<int> &idList) const
{
    if (idList.empty())
        return {};

    QVariantMap common = DatabaseUtility::commonValues(idList);

    // Add common keywords
    QList<int> commonKeywords = keyword->keywordIdList(idList.value(0));
    for (const auto plantingId : idList) {
        QList<int> keywords = keyword->keywordIdList(plantingId);
        for (const auto kid : commonKeywords) {
            if (!keywords.contains(kid))
                commonKeywords.removeOne(kid);
        }
    }

    // Convert to QVariantList
    QVariantList vlist;
    for (const auto id : commonKeywords)
        vlist.append(QVariant(id));

    common["keyword_ids"] = vlist;

    return common;
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

/** \brief Return the already assigned bed length for \a plantingId */
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
