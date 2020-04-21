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
#include <QFile>
#include <QSettings>
#include <QSqlRecord>
#include <QVariantMap>
#include <QtMath>
#include <QSettings>
#include <QStringRef>
#include <QStringBuilder>
#include <QElapsedTimer>

#include "databaseutility.h"
#include "family.h"
#include "keyword.h"
#include "location.h"
#include "mdate.h"
#include "planting.h"
#include "task.h"
#include "variety.h"
#include "helpers.h"

Planting::Planting(QObject *parent)
    : DatabaseUtility(parent)
    , m_crop(new DatabaseUtility(this))
    , m_family(new Family(this))
    , m_seedCompany(new DatabaseUtility(this))
    , m_keyword(new Keyword(this))
    , m_task(new Task(this))
    , m_unit(new DatabaseUtility(this))
    , m_variety(new Variety(this))
    , m_settings(new QSettings(this))
{
    m_table = "planting";
    m_viewTable = "planting_view";
    m_idFieldName = "planting_id";

    m_crop->setTable("crop");
    m_crop->setViewTable("crop");

    m_seedCompany->setTable("seed_company");
    m_seedCompany->setViewTable("seed_company");

    m_unit->setTable("unit");
    m_unit->setViewTable("unit");
}

// map has planting table's fields and a "keyword_ids" field.
int Planting::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    auto plantingDateString = newMap.take("planting_date").toString();
    auto plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    auto keywordIdList = newMap.take("keyword_ids").toList();

    // Check if unit id foreign key seems to be valid. If not, set it to NULL.
    if (newMap.contains("unit_id") && newMap.value("unit_id").toInt() < 1)
        newMap["unit_id"] = QVariant(QVariant::Int);

    int id = DatabaseUtility::add(newMap);
    Q_ASSERT(id > 0);

    m_task->createTasks(id, plantingDate);
    for (const auto &keywordId : keywordIdList)
        m_keyword->addPlanting(id, keywordId.toInt());

    return id;
}

/**
 * Create several planting successions based on the same values.
 *
 * \param successions the number of successions to add
 * \param weeksBetween the number of weeks between each succession
 * \param map the value map used to create the planting successions
 * \return the list of the ids of the plantings created
 */
QList<int> Planting::addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const
{
    const int daysBetween = weeksBetween * 7;
    const auto plantingDate = QDate::fromString(map["planting_date"].toString(), Qt::ISODate);
    QVariantMap newMap(map);
    QList<int> idList;

    QSqlDatabase::database().transaction();
    int i = 0;
    for (; i < successions; i++) {
        int days = i * daysBetween;
        newMap["planting_date"] = plantingDate.addDays(days).toString(Qt::ISODate);

        int id = add(newMap);
        Q_ASSERT(id > 0);
        idList.append(id);
    }

    if (i < successions)
        QSqlDatabase::database().rollback();
    else
        QSqlDatabase::database().commit();

    return idList;
}

/**
 * Return a map of the last planting which shares the most common values.
 *
 * First try to find a planting which is in (or not in) greenhouse and has the
 * same planting type and variety. If this planting cannot be found, try to find
 * a planting which has the same planting type and variety. If not found, only
 * look for the variety. As a last resort, look for the crop.
 *
 * \param varietyId the id of the variety
 * \param cropId the id of the crop
 * \param plantingType the planting type (an integer in [1,3])
 * \param inGreenhouse a boolean (true if we look for a greenhouse planting, false otherwise)
 * \return a value map for the planting found (which is empty of no planting is found)
 */
QVariantMap Planting::lastValues(int varietyId, int cropId, int plantingType, bool inGreenhouse) const
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

    QList<QString> queryStringList;
    queryStringList.push_back(
            inGhQueryString.arg(varietyId).arg(plantingType).arg(inGreenhouse ? 1 : 0));
    queryStringList.push_back(plantingTypeQueryString.arg(varietyId).arg(plantingType));
    queryStringList.push_back(varietyQueryString.arg(varietyId));
    queryStringList.push_back(cropQueryString.arg(cropId));

    for (const auto &queryString : queryStringList) {
        QSqlQuery query(queryString);
        debugQuery(query);

        if (query.first()) {
            int plantingId = query.record().value("planting_id").toInt();
            if (plantingId >= 1)
                return mapFromId("planting", plantingId);
        }
    }

    return {};
}

/**
 * Given a \a key, return its value in \a map if \a map contains this key.
 * Otherwise, return the value of the \a record for \a key.
 */
QVariant Planting::get(const QVariantMap &map, const QSqlRecord &record, const QString &key) const
{
    if (map.contains(key))
        return map.value(key);
    if (record.contains(key))
        return record.value(key);
    return {};
}

void Planting::setGreenhouseValues(QVariantMap &map, const QSqlRecord &record)
{
    const int plantsNeeded = get(map, record, "plants_needed").toInt();
    const int greenhouseLoss = get(map, record, "estimated_gh_loss").toInt();
    const int seedsPerHole = get(map, record, "seeds_per_hole").toInt();
    const qreal seedsPerGram = get(map, record, "seeds_per_gram").toDouble();
    const int traySize = get(map, record, "tray_size").toInt();

    const int plantsToStart = qCeil(static_cast<double>(plantsNeeded) / (1 - greenhouseLoss / 100));
    const double traysToStart = plantsToStart / traySize;
    const int seedsNumber = plantsToStart * seedsPerHole;
    const qreal seedsQuantity = seedsNumber * 1.0 / seedsPerGram;

    map["plants_to_start"] = plantsToStart;
    map["trays_to_start"] = traysToStart;
    map["seeds_number"] = seedsNumber;
    map["seeds_quantity"] = seedsQuantity;
}

int Planting::plantsNeeded(const QVariantMap &map, const QSqlRecord &record) const
{
    double length = get(map, record, "length").toDouble();
    int rows = get(map, record, "rows").toInt();
    int spacing = get(map, record, "spacing_plants").toInt();
    return spacing > 0 ? qCeil(length / spacing * 100 * rows) : 0;
}

void Planting::updateKeywords(int plantingId, const QVariantList &newList, const QVariantList &oldList) const
{
    QList<int> toAdd;
    QList<int> toRemove;

    for (const auto &newId : newList)
        if (!oldList.contains(newId.toInt()))
            toAdd.push_back(newId.toInt());

    for (const auto &oldId : oldList)
        if (!newList.contains(oldId))
            toRemove.push_back(oldId.toInt());

    for (const int keywordId : toAdd)
        m_keyword->addPlanting(plantingId, keywordId);

    for (const int keywordId : toRemove)
        m_keyword->removePlanting(plantingId, keywordId);
}

void Planting::update(int id, const QVariantMap &map) const
{
    update(id, map, {});
}

void Planting::update(int id, const QVariantMap &map, const QVariantMap &locationLengthMap) const
{
    Q_ASSERT(id > 0);
    QVariantMap newMap(map);
    QString plantingDateString;

    if (newMap.contains("planting_date"))
        plantingDateString = newMap.take("planting_date").toString();

    auto record = recordFromId("planting_view", id);

    // If the length, the number of rows or the in-row spacing have changed,
    // recompute the number of plants needed.
    if (newMap.contains("length") || newMap.contains("rows") || newMap.contains("spacing_plants"))
        newMap["plants_needed"] = plantsNeeded(newMap, record);

    auto newPlantingType = static_cast<PlantingType>(get(newMap, record, "planting_type").toInt());
    auto oldPlantingType = static_cast<PlantingType>(record.value("planting_type").toInt());
    int plantingTaskId = m_task->plantingTask(id);

    if (oldPlantingType == PlantingType::DirectSeeded) {
        if (newPlantingType == PlantingType::TransplantRaised) {
            m_task->updateType(plantingTaskId, TaskType::Transplant);

            // Create greenhouse sowing task.
            int dtt = get(newMap, record, "dtt").toInt();
            QDate pdate = plantingDateString.isNull()
                    ? plantingDate(id)
                    : QDate::fromString(plantingDateString, Qt::ISODate);
            m_task->createNurseryTask(id, pdate, dtt);
        } else if (newPlantingType == PlantingType::TransplantBought) {
            m_task->updateType(plantingTaskId, TaskType::Transplant);
        }
    } else if (oldPlantingType == PlantingType::TransplantRaised) {
        if (newPlantingType == PlantingType::DirectSeeded) {
            newMap["dtt"] = 0;
            m_task->updateType(plantingTaskId, TaskType::DirectSow);
            m_task->removeNurseryTask(id);
        } else if (newPlantingType == PlantingType::TransplantBought) {
            newMap["dtt"] = 0;
            m_task->removeNurseryTask(id);
        }
    } else if (oldPlantingType == PlantingType::TransplantBought) {
        if (newPlantingType == PlantingType::DirectSeeded) {
            m_task->updateType(plantingTaskId, TaskType::DirectSow);
        } else if (newPlantingType == PlantingType::TransplantRaised) {
            // Create greenhouse sowing task.
            int dtt = get(newMap, record, "dtt").toInt();
            QDate pdate = plantingDateString.isNull()
                    ? plantingDate(id)
                    : QDate::fromString(plantingDateString, Qt::ISODate);
            m_task->createNurseryTask(id, pdate, dtt);
        }
    }

    // Recompute seeds number for direct seeding.
    if ((newMap.contains("plants_needed") && newPlantingType == PlantingType::DirectSeeded)
        || newMap.contains("seeds_per_hole") || newMap.contains("seeds_percentage")) {
        int plantsNeeded = get(newMap, record, "plants_needed").toInt();
        int seedsPerHole = get(newMap, record, "seeds_per_hole").toInt();
        int seedsPercentage = get(newMap, record, "seeds_percentage").toInt();

        int seedsNumber =
                qCeil(plantsNeeded * seedsPerHole * (1 + static_cast<double>(seedsPercentage) / 100));
        newMap["seeds_number"] = seedsNumber;
    }

    // Recompute plants to start.
    if ((newMap.contains("plants_needed") && newPlantingType == PlantingType::TransplantRaised)
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
    if (newMap.contains("plants_to_start")
        || (newPlantingType == PlantingType::TransplantRaised && newMap.contains("seeds_per_hole"))) {
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
        const auto &newKeywordIdList = newMap.take("keyword_new_ids").toList();
        const auto &oldKeywordIdList = newMap.take("keyword_old_ids").toList();
        updateKeywords(id, newKeywordIdList, oldKeywordIdList);
    }

    // Update locations.
    if (newMap.contains("location_new_ids")) {
        const auto &locationIdList = newMap.take("location_new_ids").toList();
        const auto &oldLocationIdList = newMap.take("location_old_ids").toList();
        QList<int> toAdd;
        QList<int> toRemove;
        for (const auto &newId : locationIdList)
            if (!oldLocationIdList.contains(newId.toInt()))
                toAdd.push_back(newId.toInt());

        for (const auto &oldId : oldLocationIdList)
            if (!locationIdList.contains(oldId))
                toRemove.push_back(oldId.toInt());

        Location location;
        for (const int locationId : toAdd) {
            auto locationString = QString::number(locationId);
            if (locationLengthMap.contains(locationString))
                location.addPlanting(id, locationId, locationLengthMap.value(locationString).toInt());
            else
                qDebug() << "Planting::update() Cannot find length for location" << locationId;
        }

        for (const int locationId : toRemove)
            location.removePlanting(id, locationId);
    }

    DatabaseUtility::update(id, newMap);

    if (!plantingDateString.isNull()) {
        QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
        m_task->updateTaskDates(id, plantingDate);
        m_task->updateHarvestLinkedTasks(id);
    } else if (newMap.contains("dtm") || newMap.contains("harvest_window")) {
        m_task->updateHarvestLinkedTasks(id);
    }
}

int Planting::duplicate(int id) const
{
    int newId = DatabaseUtility::duplicate(id);
    m_task->duplicatePlantingTasks(id, newId);
    m_keyword->duplicateKeywords(id, newId);
    return newId;
}

/**
 * Duplicate a planting to another \a year.
 *
 * The seeding and planting tasks will also be duplicated. Dates of week 53 of
 * year Y will be duplicated to week 1 of year Y + 1.
 *
 * \param id the id of the planting to duplicate
 * \param year the targeted year
 * \return the id of the planting created
 */
int Planting::duplicateToYear(int id, int year) const
{
    Q_ASSERT(id > 0);

    QDate fromDate = plantingDate(id);
    auto map = mapFromId(table(), id);
    map.remove(idFieldName());

    int fromWeek = fromDate.weekNumber();
    QDate toDate;
    if (fromWeek == 53)
        toDate = MDate::mondayOfWeek(1, year + 1).addDays(fromDate.dayOfWeek() - 1);
    else
        toDate = MDate::mondayOfWeek(fromWeek, year).addDays(fromDate.dayOfWeek() - 1);
    map["planting_date"] = toDate.toString(Qt::ISODate);

    int newId = add(map);
    m_keyword->duplicateKeywords(id, newId);

    return -1;
}

void Planting::duplicateListToYear(const QList<int> &idList, int year) const
{
    qDebug() << "Batch duplicate to year:" << idList << year;
    QSqlDatabase::database().transaction();
    for (const int id : idList)
        duplicateToYear(id, year);
    QSqlDatabase::database().commit();
}

QList<int> Planting::yearPlantingList(int year) const
{
    QString queryString("SELECT *, strftime('%Y', planting_date) AS planting_year "
                        "FROM planting_view "
                        "WHERE planting_year = '%1'");

    return queryIds(queryString.arg(year), "planting_id");
}

/** Duplicate all plantings of \a fromYear to \a toYear. */
void Planting::duplicatePlan(int fromYear, int toYear) const
{
    auto idList = yearPlantingList(fromYear);
    duplicateListToYear(idList, toYear);
}

QVariantMap Planting::commonValues(const QList<int> &idList) const
{
    Q_ASSERT(!idList.empty());

    QVariantMap common = DatabaseUtility::commonValues(idList);

    // Add common keywords
    auto commonKeywords = m_keyword->keywordIdList(idList.value(0));
    for (const auto plantingId : idList) {
        auto keywordIdList = m_keyword->keywordIdList(plantingId);
        for (const auto keywordId : commonKeywords) {
            if (!keywordIdList.contains(keywordId))
                commonKeywords.removeOne(keywordId);
        }
    }

    // Convert to QVariantList
    QVariantList vlist;
    for (const auto id : commonKeywords)
        vlist.append(QVariant(id));

    common["keyword_ids"] = vlist;

    return common;
}

/**
 * Check if all plantings in \a plantingIdList are of the same crop specie.
 */
bool Planting::sameCrop(const QList<int> &plantingIdList) const
{
    if (plantingIdList.empty())
        return true;

    int cid = cropId(plantingIdList.first());
    for (const int plantingId : plantingIdList)
        if (cropId(plantingId) != cid)
            return false;
    return true;
}

QVariant Planting::value(int plantingId, const QString &field) const
{
    auto record = recordFromId("planting_view", plantingId);
    if (record.isEmpty())
        return {};
    return record.value(field);
}

QString Planting::cropName(int plantingId) const
{
    return value(plantingId, "crop").toString();
}

int Planting::cropId(int plantingId) const
{
    return value(plantingId, "crop_id").toInt();
}

QString Planting::cropColor(int plantingId) const
{
    return value(plantingId, "crop_color").toString();
}

QString Planting::varietyName(int plantingId) const
{
    return value(plantingId, "variety").toString();
}

int Planting::familyId(int plantingId) const
{
    return value(plantingId, "family_id").toInt();
}

bool Planting::hasSameFamily(int plantingId1, int plantingId2) const
{
    return familyId(plantingId1) == familyId(plantingId2);
}

QString Planting::familyInterval(int plantingId) const
{
    return value(plantingId, "family_interval").toString();
}

QString Planting::familyColor(int plantingId) const
{
    return value(plantingId, "family_color").toString();
}

QString Planting::unit(int plantingId) const
{
    return value(plantingId, "unit").toString();
}

int Planting::type(int plantingId) const
{
    return value(plantingId, "planting_type").toInt();
}

int Planting::rank(int plantingId) const
{
    return value(plantingId, "planting_rank").toInt();
}

QVector<QDate> Planting::dates(int plantingId) const
{
    auto record = recordFromId("planting_view", plantingId);
    if (record.isEmpty())
        return {};
    return { MDate::dateFromIsoString(record.value("sowing_date").toString()),
             MDate::dateFromIsoString(record.value("planting_date").toString()),
             MDate::dateFromIsoString(record.value("beg_harvest_date").toString()),
             MDate::dateFromIsoString(record.value("end_harvest_date").toString()) };
}

QDate Planting::sowingDate(int plantingId) const
{
    return dateFromField("planting_view", "sowing_date", plantingId);
}

QDate Planting::plantingDate(int plantingId) const
{
    return dateFromField("planting_view", "planting_date", plantingId);
}

QDate Planting::begHarvestDate(int plantingId) const
{
    return dateFromField("planting_view", "beg_harvest_date", plantingId);
}

QDate Planting::endHarvestDate(int plantingId) const
{
    return dateFromField("planting_view", "end_harvest_date", plantingId);
}

QDate Planting::plannedSowingDate(int plantingId) const
{
    return dateFromField("planting_view", "planned_sowing_date", plantingId);
}

QDate Planting::plannedPlantingDate(int plantingId) const
{
    return dateFromField("planting_view", "planned_planting_date", plantingId);
}

QDate Planting::plannedBegHarvestDate(int plantingId) const
{
    return dateFromField("planting_view", "planned_beg_harvest_date", plantingId);
}

QDate Planting::plannedEndHarvestDate(int plantingId) const
{
    return dateFromField("planting_view", "planned_end_harvest_date", plantingId);
}

bool Planting::isActive(int plantingId) const
{
    int sowingTaskId;
    int plantingTaskId;
    std::tie(sowingTaskId, plantingTaskId) = m_task->sowPlantTaskIds(plantingId);
    return m_task->isComplete(sowingTaskId) || m_task->isComplete(plantingTaskId);
}

qreal Planting::totalLength(int plantingId) const
{
    return value(plantingId, "length").toDouble();
}

/** Return the already assigned bed length for \a plantingId */
qreal Planting::assignedLength(int plantingId) const
{
    Q_ASSERT(plantingId > 0);
    QString queryString("SELECT SUM(length) FROM planting_location WHERE planting_id=%1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);

    if (!query.next())
        return 0;

    return query.value(0).toDouble();
}

qreal Planting::lengthToAssign(int plantingId) const
{
    return totalLength(plantingId) - assignedLength(plantingId);
}

qreal Planting::totalLengthForWeek(int week, int year, int keywordId, bool greenhouse) const
{
    QDate date;
    std::tie(date, std::ignore) = MDate::weekDates(week, year);
    int inGreenhouse = greenhouse ? 1 : 0;
    QString queryString;
    QSqlQuery query;
    if (keywordId > 0) {
        queryString = ("select sum(length) "
                       "from planting_view "
                       "join planting_keyword using (planting_id) "
                       "where ('%1' between planting_date and end_harvest_date) "
                       "and in_greenhouse = %2 "
                       "and keyword_id = %3");
        query.exec(queryString.arg(date.toString(Qt::ISODate)).arg(inGreenhouse).arg(keywordId));
    } else {
        queryString = ("select sum(length) "
                       "from planting_view "
                       "where ('%1' between planting_date and end_harvest_date) "
                       "and in_greenhouse = %2");
        query.exec(queryString.arg(date.toString(Qt::ISODate)).arg(inGreenhouse));
    }

    debugQuery(query);
    query.first();
    return query.value(0).toDouble();
}

qreal Planting::totalLengthForYear(int year, bool greenhouse) const
{
    QString queryString("SELECT SUM(length) "
                        "FROM planting_view "
                        "WHERE strftime(\"%Y\", beg_harvest_date) = \"%1\" "
                        "AND in_greenhouse = %2");
    QSqlQuery query(queryString.arg(year).arg(greenhouse ? 1 : 0));
    debugQuery(query);
    query.next();
    return query.value(0).toDouble();
}

int Planting::numberOfCrops(int year, bool greenhouse) const
{
    QString queryString("SELECT COUNT(DISTINCT crop_id) "
                        "FROM planting_view "
                        "WHERE strftime(\"%Y\", beg_harvest_date) = \"%1\" "
                        "AND in_greenhouse = %2");
    QSqlQuery query(queryString.arg(year).arg(greenhouse ? 1 : 0));
    debugQuery(query);
    query.next();
    return query.value(0).toInt();
}

int Planting::revenue(int year) const
{
    QString queryString("SELECT SUM(bed_revenue) "
                        "FROM planting_view WHERE strftime(\"%Y\", beg_harvest_date) = \"%1\"");
    QSqlQuery query(queryString.arg(year));
    query.next();
    return query.value(0).toInt();
}

QVariantList Planting::totalLengthByWeek(int season, int year, int keywordId, bool greenhouse) const
{
    QVariantList list;
    QDate beg;
    QDate end;
    std::tie(beg, end) = MDate::seasonDates(season, year);

    while (beg <= end) {
        int w;
        int y;
        w = beg.weekNumber(&y);
        list.push_back(totalLengthForWeek(w, y, keywordId, greenhouse));
        beg = beg.addDays(7);
    }
    return list;
}

QVariantList Planting::longestCropNames(int year, bool greenhouse) const
{
    QString queryString("select crop, sum(length), sum(bed_revenue), "
                        "strftime('%Y', planting_date) as year "
                        "from planting_view "
                        "where year = '%1' "
                        "and in_greenhouse = %2 "
                        "group by year, crop_id "
                        "order by year, sum(length) asc");
    int inGreenhouse = greenhouse ? 1 : 0;
    QSqlQuery query(queryString.arg(year).arg(inGreenhouse));
    debugQuery(query);
    QVariantList list;
    while (query.next())
        list.push_back(query.value(0));
    return list;
}

QVariantList Planting::longestCropLengths(int year, bool greenhouse) const
{
    QString queryString("select crop, sum(length), sum(bed_revenue), "
                        "strftime('%Y', sowing_date) as year "
                        "from planting_view "
                        "where year = '%1' "
                        "and in_greenhouse = %2 "
                        "group by crop_id "
                        "order by sum(length) asc");
    int inGreenhouse = greenhouse ? 1 : 0;
    QSqlQuery query(queryString.arg(year).arg(inGreenhouse));
    debugQuery(query);
    QVariantList list;
    while (query.next()) {
        list.push_back(Helpers::bedLength(query.value(1).toDouble()));
        qDebug() << QString("%1;%2")
                            .arg(query.value(0).toString())
                            .arg(Helpers::bedLength(query.value(1).toDouble()));
    }
    return list;
}

QVariantList Planting::highestRevenueCropNames(int year, bool greenhouse) const
{
    QString queryString("select crop, sum(bed_revenue), "
                        "strftime('%Y', planting_date) as year "
                        "from planting_view "
                        "where year = '%1' "
                        "and in_greenhouse = %2 "
                        "group by year, crop_id "
                        "order by year, sum(bed_revenue) asc");
    int inGreenhouse = greenhouse ? 1 : 0;
    QSqlQuery query(queryString.arg(year).arg(inGreenhouse));
    debugQuery(query);
    QVariantList list;
    while (query.next())
        list.push_back(query.value(0));
    return list;
}

QVariantList Planting::highestRevenueCropRevenues(int year, bool greenhouse) const
{
    QString queryString("select crop, sum(bed_revenue), sum(yield_per_bed_meter*length), "
                        "strftime('%Y', planting_date) as year "
                        "from planting_view "
                        "where year = '%1' "
                        "and in_greenhouse = %2 "
                        "group by year, crop_id "
                        "order by year, sum(bed_revenue) asc");
    int inGreenhouse = greenhouse ? 1 : 0;
    QSqlQuery query(queryString.arg(year).arg(inGreenhouse));
    debugQuery(query);
    QVariantList list;
    while (query.next()) {
        list.push_back(query.value(1));
        qDebug() << QString("%1;%2").arg(query.value(0).toString()).arg(query.value(2).toDouble());
    }
    return list;
}

void Planting::csvImportPlan(int year, const QUrl &path) const
{
    if (year < 1000 || year > 3000)
        return;

    QFile f(path.toLocalFile());
    if (!f.open(QIODevice::ReadOnly))
        return;

    QTextStream ts(&f);
    QList<QString> fieldList = ts.readLine().split(";");
    QSqlDatabase::database().transaction();
    while (!ts.atEnd()) {
        auto line = ts.readLine().split(";");

        QVariantMap map;
        int familyId = -1;
        int cropId = -1;
        int seedCompanyId = -1;
        int varietyId = -1;
        int unitId = -1;
        QString varietyName;

        QList<int> keywordIdList;
        int inGreenhouse = 0;
        int plantingType = -1;

        QDate sdate;
        QDate pdate;
        QDate bhdate;
        QDate ehdate;

        for (int i = 0; i < line.length(); i++) {
            QString field = fieldList[i];

            if (field.trimmed().isEmpty())
                continue;

            if (field == "family") {
                QString queryString("SELECT family_id FROM family WHERE family='%1'");
                QString familyName = line[i].trimmed();
                QSqlQuery query(queryString.arg(familyName));
                debugQuery(query);
                if (query.first()) {
                    familyId = query.record().value("family_id").toInt();
                } else {
                    QVariantMap m;
                    m["family"] = familyName;
                    m["color"] = "#000000";
                    familyId = m_family->add(m);
                }
            } else if (field == "crop") {
                QString queryString("SELECT crop_id FROM crop WHERE crop='%1'");
                QString cropName = line[i].trimmed();
                QSqlQuery query(queryString.arg(cropName));
                debugQuery(query);
                if (query.first()) {
                    cropId = query.record().value("crop_id").toInt();
                } else {
                    QVariantMap m;
                    m["crop"] = cropName;
                    m["color"] = "#000000";
                    m["family_id"] = familyId;
                    cropId = m_crop->add(m);
                }
            } else if (field == "seed_company") {
                QString queryString(
                        "SELECT seed_company_id FROM seed_company WHERE seed_company='%1'");
                QString seedCompanyName = line[i].trimmed();
                QSqlQuery query(queryString.arg(seedCompanyName));
                debugQuery(query);
                if (query.first()) {
                    seedCompanyId = query.record().value("seed_company_id").toInt();
                } else {
                    QVariantMap m;
                    m["seed_company"] = seedCompanyName;
                    seedCompanyId = m_seedCompany->add(m);
                }
            } else if (field == "variety") {
                varietyName = line[i].trimmed();
            } else if (field == "unit") {
                QString queryString("SELECT unit_id FROM unit WHERE abbreviation='%1'");
                QString unitString = line[i].trimmed();
                QSqlQuery query(queryString.arg(unitString));
                debugQuery(query);
                if (query.first()) {
                    unitId = query.record().value("unit_id").toInt();
                } else {
                    QVariantMap m;
                    m["unit"] = unitString;
                    unitId = m_unit->add(m);
                }
                map["unit_id"] = unitId;
            } else if (field == "keywords") {
                keywordIdList = m_keyword->keywordListFromString(line[i]);
                map.take("keywords");
            } else if (field == "planting_type") {
                plantingType = line[i].trimmed().toInt();
            } else if (field == "sowing_date") {
                sdate = MDate::dateFromWeekString(line[i].trimmed(), year);
                if (!sdate.isValid()) {
                    qDebug() << "Bad date format, should be week number:" << line[i];
                    return;
                }
            } else if (field == "planting_date") {
                pdate = MDate::dateFromWeekString(line[i].trimmed(), year);
                if (!pdate.isValid()) {
                    qDebug() << "Bad date format, should be week number:" << line[i];
                    return;
                }
                map[field] = pdate;
            } else if (field == "beg_harvest_date") {
                bhdate = MDate::dateFromWeekString(line[i].trimmed(), year);
                if (!bhdate.isValid()) {
                    qDebug() << "Bad date format, should be week number:" << line[i];
                    return;
                }
            } else if (field == "end_harvest_date") {
                ehdate = MDate::dateFromWeekString(line[i].trimmed(), year);
                if (!ehdate.isValid()) {
                    qDebug() << "Bad date format, should be week number:" << line[i];
                    return;
                }
            } else if (field == "in_greenhouse") {
                inGreenhouse = line[i].toInt();
            } else {
                map[field] = line[i].trimmed();
            }
        }

        // If seed company isn't found, set one
        if (seedCompanyId < 0) {
            QString queryString("SELECT seed_company_id FROM seed_company WHERE seed_company='%1'");
            QSqlQuery query(queryString.arg(tr("Unknown company")));
            debugQuery(query);
            if (query.first()) {
                seedCompanyId = query.record().value("seed_company_id").toInt();
            } else {
                QVariantMap m;
                m["seed_company"] = tr("Unkown company");
                seedCompanyId = m_seedCompany->add(m);
            }
        }

        // Set variety
        QString queryString("SELECT variety_id FROM variety WHERE variety='%1'");
        QSqlQuery query(queryString.arg(varietyName.trimmed()));
        debugQuery(query);
        if (query.first()) {
            varietyId = query.record().value("variety_id").toInt();
        } else {
            QVariantMap m;
            m["variety"] = varietyName.trimmed();
            m["crop_id"] = cropId;
            m["seed_company_id"] = seedCompanyId;
            varietyId = m_variety->add(m);
        }
        map["variety_id"] = varietyId;

        if (plantingType < 0) {
            if (sdate < pdate)
                plantingType = 2;
            else
                plantingType = 1;
        }

        if (!map.contains("unit_id")) {
            QString queryString("SELECT unit_id FROM unit WHERE abbreviation='kg'");
            QSqlQuery query(queryString);
            debugQuery(query);
            if (query.first()) {
                unitId = query.record().value("unit_id").toInt();
            } else {
                QVariantMap m;
                m["unit"] = "kg";
                unitId = m_unit->add(m);
            }
            map["unit_id"] = unitId;
        }

        if (!map.contains("dtt"))
            map["dtt"] = sdate.daysTo(pdate);
        if (!map.contains("dtm"))
            map["dtm"] = pdate.daysTo(bhdate);
        if (!map.contains("harvest_window"))
            map["harvest_window"] = bhdate.daysTo(ehdate);

        map["planting_type"] = plantingType;
        map["in_greenhouse"] = inGreenhouse;

        int plantingId = add(map);
        if (plantingId < 0)
            continue;
        for (const int keywordId : keywordIdList)
            m_keyword->addPlanting(plantingId, keywordId);
    }
    QSqlDatabase::database().commit();
    f.close();
}

void Planting::csvExportPlan(int year, const QUrl &path) const
{
    QFile f(path.toLocalFile());

    if (f.exists())
        f.remove();

    if (!f.open(QIODevice::ReadWrite))
        return;

    QTextStream ts(&f);
    auto idList = yearPlantingList(year);

    QList<QString> keyList = { "family",
                               "crop",
                               "seed_company",
                               "variety",
                               "sowing_date",
                               "planting_date",
                               "beg_harvest_date",
                               "end_harvest_date",
                               "planting_type",
                               "in_greenhouse",
                               "dtt",
                               "dtm",
                               "harvest_window",
                               "length",
                               "rows",
                               "surface",
                               "spacing_rows",
                               "spacing_plants",
                               "plants_needed",
                               "estimated_gh_loss",
                               "plants_to_start",
                               "tray_size",
                               "trays_to_start",
                               "yield_per_hectare",
                               "seeds_per_hole",
                               "seeds_per_gram",
                               "seeds_number",
                               "seeds_quantity",
                               "seeds_percentage",
                               "unit",
                               "yield_per_bed_meter",
                               "average_price" };

    // Write headers
    for (auto const &field : keyList)
        ts << field << ";";
    ts << "keywords";
    ts << "\n";

    QSettings settings;
    QString dateType = settings.value("dateType").toString();
    for (const int plantingId : idList) {
        auto map = mapFromId(plantingId);
        map.take("planting_id");
        for (auto const &field : keyList) {
            if (dateType == "week"
                && (field == "sowing_date" || field == "planting_date"
                    || field == "beg_harvest_date" || field == "end_harvest_date")) {
                int y;
                int w = QDate::fromString(map.value(field).toString(), Qt::ISODate).weekNumber(&y);
                if (y < year)
                    ts << "<";
                else if (y > year)
                    ts << ">";
                ts << w << ";";
            } else {
                ts << map.value(field).toString() << ";";
            }
        }

        QString keywordString;
        for (const auto &variant : m_keyword->keywordStringList(plantingId))
            keywordString += variant.toString() + QString(",");
        keywordString.chop(1);
        ts << keywordString;

        ts << "\n";
    }
    f.close();
}

QString Planting::toolTip(int plantingId, int locationId) const
{
    auto record = recordFromId("planting_view", plantingId);
    const QString crop = record.value("crop").toString();
    const QString variety = record.value("variety").toString();
    const QString bedUnit = m_settings->value("useStandardBedLength").toBool() ? tr("beds") : tr("m");
    const qreal totalLength = Helpers::bedLength(record.value("length").toDouble());

    if (locationId > 0) {
        return tr("%1, %2 (%L3/%L4 %5 assigned)")
                .arg(crop)
                .arg(variety)
                .arg(Helpers::bedLength(assignedLength(plantingId)))
                //                .arg(Helpers::bedLength(location->
                .arg(totalLength)
                .arg(bedUnit);
    }
    return tr("%1, %2 (%L3/%L4 %5 to assign)")
            .arg(crop)
            .arg(variety)
            .arg(Helpers::bedLength(lengthToAssign(plantingId)))
            .arg(totalLength)
            .arg(bedUnit);
}

QString Planting::growBarDescription(const QSqlRecord &record, int year, bool showNames) const
{
    if (record.isEmpty())
        return {};

    const QDate plantingDate = QDate::fromString(record.value("planting_date").toString(), Qt::ISODate);

    if (!showNames)
        return MDate::formatDate(plantingDate, year, "", false);

    const auto crop = record.value("crop").toString();
    const auto variety = record.value("variety").toString();
    const auto crop2 = QStringRef(&crop, 0, 2);
    const QString rank = record.value("planting_rank").toString();

    return MDate::formatDate(plantingDate, year, "", false) % QStringLiteral(" ") % crop2
            % QStringLiteral(" ") % rank % QStringLiteral(" ") % variety;
}

QString Planting::growBarDescription(int plantingId, int year, bool showNames) const
{
    return growBarDescription(recordFromId("planting_view", plantingId), year, showNames);
}

QVariantMap Planting::drawInfoMap(const QSqlRecord &record, int season, int year,
                                  bool showGreenhouseSow, bool showNames) const
{
    const auto sowingDate =
            QDate::fromString(record.value(QStringLiteral("sowing_date")).toString(), Qt::ISODate);
    const auto plantingDate =
            QDate::fromString(record.value(QStringLiteral("planting_date")).toString(), Qt::ISODate);
    const auto begHarvestDate =
            QDate::fromString(record.value(QStringLiteral("beg_harvest_date")).toString(), Qt::ISODate);
    const auto endHarvestDate =
            QDate::fromString(record.value(QStringLiteral("end_harvest_date")).toString(), Qt::ISODate);

    const auto seasonBegin = MDate::seasonBeginning(season, year);
    const qreal graphStart =
            Helpers::position(seasonBegin, showGreenhouseSow ? sowingDate : plantingDate);
    const qreal growStart = Helpers::position(seasonBegin, plantingDate) - graphStart;
    const qreal harvestStart = Helpers::position(seasonBegin, begHarvestDate) - graphStart;

    const qreal greenhouseWidth = Helpers::widthBetween(graphStart, seasonBegin, plantingDate);
    const qreal growWidth = Helpers::widthBetween(growStart + graphStart, seasonBegin, begHarvestDate);
    const qreal harvestWidth =
            Helpers::widthBetween(harvestStart + graphStart, seasonBegin, endHarvestDate);

    return { { "graphStart", graphStart },
             { "growStart", growStart },
             { "harvestStart", harvestStart },
             { "greenhouseWidth", greenhouseWidth },
             { "growWidth", growWidth },
             { "harvestWidth", harvestWidth },
             { "plantingId", record.value("planting_id") },
             { "sowingDate", MDate::formatDate(sowingDate, year, "", false) },
             { "begHarvestDate", MDate::formatDate(begHarvestDate, year, "", false) },
             { "cropColor", record.value("crop_color") },
             { "familyColor", record.value("family_color") },
             { "growBarDescription", growBarDescription(record, year, showNames) } };
}

QVariantMap Planting::drawInfoMap(int plantingId, int season, int year, bool showFamilyColor,
                                  bool showNames) const
{
    QElapsedTimer timer;
    timer.start();
    auto map = drawInfoMap(recordFromId("planting_view", plantingId), season, year, showFamilyColor,
                           showNames);
    qDebug() << "planting info map" << timer.elapsed() << "ms";
    return map;
}
