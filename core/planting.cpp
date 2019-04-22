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

#include "databaseutility.h"
#include "family.h"
#include "keyword.h"
#include "location.h"
#include "mdate.h"
#include "planting.h"
#include "task.h"
#include "variety.h"

Planting::Planting(QObject *parent)
    : DatabaseUtility(parent)
    , crop(new DatabaseUtility(this))
    , family(new Family(this))
    , seedCompany(new DatabaseUtility(this))
    , keyword(new Keyword(this))
    , task(new Task(this))
    , unit(new DatabaseUtility(this))
    , variety(new Variety(this))
{
    m_table = "planting";
    m_viewTable = "planting_view";
    m_idFieldName = "planting_id";

    crop->setTable("crop");
    crop->setViewTable("crop");

    seedCompany->setTable("seed_company");
    seedCompany->setViewTable("seed_company");

    unit->setTable("unit");
    unit->setViewTable("unit");
}

// map has planting table's fields and a "keyword_ids" field.
int Planting::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    auto plantingDateString = newMap.take("planting_date").toString();
    auto plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    auto keywordIdList = newMap.take("keyword_ids").toList();

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

/*!
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
        if (id > 0) {
            idList.append(id);
        } else {
            qDebug() << "[addSuccesions] cannot add planting to the database. Rolling back...";
            break;
        }
    }

    if (i < successions)
        QSqlDatabase::database().rollback();
    else
        QSqlDatabase::database().commit();

    return idList;
}

/*!
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

/*!
 * \brief Given a \a key, return its value in \a map if \a map contains this key.
 * Otherwise, return the value of the \a record for \a key.
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
    const int plantsNeeded = get(map, record, "plants_needed").toInt();
    const int greenhouseLoss = get(map, record, "estimated_gh_loss").toInt();
    const int seedsPerHole = get(map, record, "seeds_per_hole").toInt();
    const double seedsPerGram = get(map, record, "seeds_per_gram").toDouble();
    const int traySize = get(map, record, "tray_size").toInt();

    const int plantsToStart = qCeil(static_cast<double>(plantsNeeded) / (1 - greenhouseLoss / 100));
    const double traysToStart = plantsToStart / traySize;
    const int seedsNumber = plantsToStart * seedsPerHole;
    const double seedsQuantity = seedsNumber / seedsPerGram;

    map["plants_to_start"] = plantsToStart;
    map["trays_to_start"] = traysToStart;
    map["seeds_number"] = seedsNumber;
    map["seeds_quantity"] = seedsQuantity;
}

void Planting::update(int id, const QVariantMap &map) const
{
    update(id, map, {});
}

int Planting::plantsNeeded(const QVariantMap &map, const QSqlRecord &record) const
{
    double length = get(map, record, "length").toDouble();
    int rows = get(map, record, "rows").toInt();
    int spacing = get(map, record, "spacing_plants").toInt();
    return spacing > 0 ? qCeil(length / spacing * 100 * rows) : 0;
}

void Planting::updateKeywords(int plantingId, const QVariantList newList, const QVariantList oldList) const
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
        keyword->addPlanting(plantingId, keywordId);

    for (const int keywordId : toRemove)
        keyword->removePlanting(plantingId, keywordId);
}

void Planting::update(int id, const QVariantMap &map, const QVariantMap &locationLengthMap) const
{
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
    int plantingTaskId = task->plantingTask(id);

    if (oldPlantingType == PlantingType::DirectSeeded) {
        if (newPlantingType == PlantingType::TransplantRaised) {
            task->updateType(plantingTaskId, TaskType::Transplant);

            // Create greenhouse sowing task.
            int dtt = get(newMap, record, "dtt").toInt();
            QDate pdate = plantingDateString.isNull()
                    ? plantingDate(id)
                    : QDate::fromString(plantingDateString, Qt::ISODate);
            task->createNurseryTask(id, pdate, dtt);
        } else if (newPlantingType == PlantingType::TransplantBought) {
            task->updateType(plantingTaskId, TaskType::Transplant);
        }
    } else if (oldPlantingType == PlantingType::TransplantRaised) {
        if (newPlantingType == PlantingType::DirectSeeded) {
            newMap["dtt"] = 0;
            task->updateType(plantingTaskId, TaskType::DirectSow);
            task->removeNurseryTask(id);
        } else if (newPlantingType == PlantingType::TransplantBought) {
            newMap["dtt"] = 0;
            task->removeNurseryTask(id);
        }
    } else if (oldPlantingType == PlantingType::TransplantBought) {
        if (newPlantingType == PlantingType::DirectSeeded) {
            task->updateType(plantingTaskId, TaskType::DirectSow);
        } else if (newPlantingType == PlantingType::TransplantRaised) {
            // Create greenhouse sowing task.
            int dtt = get(newMap, record, "dtt").toInt();
            QDate pdate = plantingDateString.isNull()
                    ? plantingDate(id)
                    : QDate::fromString(plantingDateString, Qt::ISODate);
            task->createNurseryTask(id, pdate, dtt);
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
        task->updateTaskDates(id, plantingDate);
    }
}

int Planting::duplicate(int id) const
{
    int newId = DatabaseUtility::duplicate(id);
    task->duplicatePlantingTasks(id, newId);
    return newId;
}

/*!
 * Duplicate a planting to another \a year.
 *
 * The seeding and planting tasks will also be duplicated.
 *
 * \param id the id of the planting to duplicate
 * \param year the targeted year
 * \return the id of the planting created
 */
int Planting::duplicateToYear(int id, int year) const
{
    if (id < 0)
        return -1;

    QDate fromDate = plantingDate(id);
    auto map = mapFromId(table(), id);
    map.remove(idFieldName());

    QSettings settings;
    QString dateType = settings.value("dateType", "week").toString();

    if (dateType == "week") {
        int fromWeek = fromDate.weekNumber();
        QDate toDate = MDate::mondayOfWeek(fromWeek, year);
        map["planting_date"] = toDate.toString(Qt::ISODate);

        int newId = add(map);
        keyword->duplicateKeywords(id, newId);
    }

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
    if (idList.empty())
        return {};

    QVariantMap common = DatabaseUtility::commonValues(idList);

    // Add common keywords
    auto commonKeywords = keyword->keywordIdList(idList.value(0));
    for (const auto plantingId : idList) {
        auto keywordIdList = keyword->keywordIdList(plantingId);
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

/*!
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

QString Planting::cropName(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("crop").toString();
}

int Planting::cropId(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("crop_id").toInt();
}

QString Planting::cropColor(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("crop_color").toString();
}

QString Planting::varietyName(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("variety").toString();
}

int Planting::familyId(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("family_id").toInt();
}

QString Planting::familyInterval(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("family_interval").toString();
}

QString Planting::familyColor(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("family_color").toString();
}

int Planting::type(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("planting_type").toInt();
}

QDate Planting::sowingDate(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return QDate::fromString(map.value("sowing_date").toString(), Qt::ISODate);
}

QDate Planting::plantingDate(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return QDate::fromString(map.value("planting_date").toString(), Qt::ISODate);
}

QDate Planting::begHarvestDate(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return QDate::fromString(map.value("beg_harvest_date").toString(), Qt::ISODate);
}

QDate Planting::endHarvestDate(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return QDate::fromString(map.value("end_harvest_date").toString(), Qt::ISODate);
}

int Planting::totalLength(int plantingId) const
{
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return {};
    return map.value("length").toInt();
}

/*! Return the already assigned bed length for \a plantingId */
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
    auto map = mapFromId("planting_view", plantingId);
    if (map.isEmpty())
        return 0;

    int length = map.value("length").toInt();
    return length - assignedLength(plantingId);
}

void Planting::csvImportPlan(int year, const QUrl &path) const
{
    if (year < 2000 || year > 3000)
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
                    familyId = family->add(m);
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
                    cropId = crop->add(m);
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
                    seedCompanyId = seedCompany->add(m);
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
                    unitId = unit->add(m);
                }
                map["unit_id"] = unitId;
            } else if (field == "keywords") {
                keywordIdList = keyword->keywordListFromString(line[i]);
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
                seedCompanyId = seedCompany->add(m);
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
            varietyId = variety->add(m);
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
                unitId = unit->add(m);
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
            keyword->addPlanting(plantingId, keywordId);
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
        for (const auto &variant : keyword->keywordStringList(plantingId))
            keywordString += variant.toString() + QString(",");
        keywordString.chop(1);
        ts << keywordString;

        ts << "\n";
    }
    f.close();
}
