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
#include <QVariantMap>
#include <QSettings>

#include "task.h"
#include "templatetask.h"

Task::Task(QObject *parent)
    : DatabaseUtility(parent)
    , mSettings(new QSettings(this))
{
    m_table = "task";
    m_viewTable = "task_view";
}

QString Task::type(int taskId) const
{
    auto record = recordFromId("task_view", taskId);
    if (record.isEmpty())
        return {};
    return record.value("type").toString();
}

QString Task::method(int taskId) const
{
    auto record = recordFromId("task_view", taskId);
    if (record.isEmpty())
        return {};
    return record.value("method").toString();
}

QString Task::implement(int taskId) const
{
    auto record = recordFromId("task_view", taskId);
    if (record.isEmpty())
        return {};
    return record.value("implement").toString();
}

QString Task::description(int taskId) const
{
    int taskTypeId = typeId(taskId);
    bool useStandardBedLength = mSettings->value("useStandardBedLength").toBool();
    int standardBedLength = mSettings->value("standardBedLength").toInt();

    if (taskTypeId > 3) {
        QString m = method(taskId);
        QString i = implement(taskId);

        if (i.isEmpty())
            return m;
        return m + QString(", ") + i;
    }

    auto plantingIdList = taskPlantings(taskId);
    int plantingId = plantingIdList.first();

    QVariantMap map = mapFromId("planting_view", plantingId);
    int rows = map.value("rows").toInt();
    int spacing = map.value("spacing_plants").toInt();
    int trays = map.value("trays_to_start").toInt();
    int traySize = map.value("tray_size").toInt();
    int seedsPerHole = map.value("seeds_per_hole").toInt();

    int length = map.value("length").toInt();
    QString lengthString;
    if (useStandardBedLength)
        lengthString = tr("%L1 beds").arg(length * 1.0 / standardBedLength);
    else
        lengthString = tr("%L1 bed m.").arg(length);

    QString description;
    if (taskTypeId == 1)
        return QString(tr("%L1, %L2 rows x %L3 cm")).arg(lengthString).arg(rows).arg(spacing);
    if (taskTypeId == 2) {
        if (seedsPerHole > 1)
            return QString(tr("%L1 x %L2, %L3 seeds per hole")).arg(trays).arg(traySize).arg(seedsPerHole);
        return QString(tr("%L1 x %L2")).arg(trays).arg(traySize);
    }
    return QString(tr("%L1, %L2 rows x %L3 cm")).arg(lengthString).arg(rows).arg(spacing);
}

QString Task::color(int taskId) const
{
    auto record = recordFromId("task_view", taskId);
    if (record.isEmpty())
        return {};
    return record.value("color").toString();
}

QDate Task::assignedDate(int taskId) const
{
    return dateFromField("task", "assigned_date", taskId);
}

int Task::duration(int taskId) const
{
    auto record = recordFromId("task", taskId);
    if (record.isEmpty())
        return {};
    return record.value("duration").toInt();
}

int Task::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);

    qDebug() << newMap.value("planting_ids");

    auto plantingIdList = newMap.take("planting_ids").toList();
    auto locationIdList = newMap.take("location_ids").toList();

    qDebug() << plantingIdList;

    int methodId = newMap.value("task_method_id").toInt();
    if (methodId < 1)
        newMap.take("task_method_id");

    int implementId = newMap.value("task_implement_id").toInt();
    if (implementId < 1)
        newMap.take("task_implement_id");

    auto completedDate = newMap.value("completed_date").toString();
    if (completedDate.isEmpty())
        newMap["completed_date"] = QVariant(QVariant::String); // Set NULL value.

    int id = DatabaseUtility::add(newMap);
    if (id < 1) {
        qDebug() << Q_FUNC_INFO << "Couln't create task" << newMap;
        return -1;
    }

    for (const auto &idString : plantingIdList) {
        int plantingId = idString.toInt();
        addPlanting(plantingId, id);
    }

    for (const auto &idString : locationIdList) {
        int locationId = idString.toInt();
        addLocation(locationId, id);
    }

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
QList<int> Task::addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const
{
    const int daysBetween = weeksBetween * 7;
    const auto assignedDate = QDate::fromString(map["assigned_date"].toString(), Qt::ISODate);
    QVariantMap newMap(map);
    QList<int> idList;

    QSqlDatabase::database().transaction();
    int i = 0;
    for (; i < successions; i++) {
        int days = i * daysBetween;
        newMap["assigned_date"] = assignedDate.addDays(days).toString(Qt::ISODate);

        int id = add(newMap);
        if (id > 0) {
            idList.append(id);
        } else {
            qDebug() << "[addSuccesions] cannot add task to the database. Rolling back...";
            break;
        }
    }

    if (i < successions)
        QSqlDatabase::database().rollback();
    else
        QSqlDatabase::database().commit();

    return idList;
}

void Task::update(int id, const QVariantMap &map) const
{
    QVariantMap newMap(map);

    // Set NULL values instead of -1 to prevent SQL foreign key errors.
    if (newMap.contains("task_method_id") && newMap.value("task_method_id").toInt() < 1)
        newMap["task_method_id"] = QVariant(QVariant::Int);
    if (newMap.contains("task_implement_id") && newMap.value("task_implement_id").toInt() < 1)
        newMap["task_implement_id"] = QVariant(QVariant::Int);

    if (map.contains("planting_ids")) {
        const auto &plantingIdList = newMap.take("planting_ids").toList();
        const auto &oldPlantingIdList = taskPlantings(id);
        QList<int> toAdd;
        QList<int> toRemove;

        for (const auto &newId : plantingIdList)
            if (!oldPlantingIdList.contains(newId.toInt()))
                toAdd.push_back(newId.toInt());

        for (const auto &oldId : oldPlantingIdList)
            if (!plantingIdList.contains(oldId))
                toRemove.push_back(oldId);

        for (const int plantingId : toAdd)
            addPlanting(plantingId, id);

        for (const int plantingId : toRemove)
            removePlanting(plantingId, id);
    }

    if (map.contains("location_ids")) {
        const auto &locationIdList = newMap.take("location_ids").toList();
        const auto &oldLocationList = taskLocations(id);
        QList<int> toAdd;
        QList<int> toRemove;

        for (const auto &newId : locationIdList)
            if (!oldLocationList.contains(newId.toInt()))
                toAdd.push_back(newId.toInt());

        for (const auto &oldId : oldLocationList)
            if (!locationIdList.contains(oldId))
                toRemove.push_back(oldId);

        for (const int locationId : toAdd)
            addLocation(locationId, id);

        for (const int locationId : toRemove)
            removeLocation(locationId, id);
    }

    DatabaseUtility::update(id, newMap);
}

void Task::addPlanting(int plantingId, int taskId) const
{
    addLink("planting_task", "planting_id", plantingId, "task_id", taskId);
}

void Task::removePlanting(int plantingId, int taskId) const
{
    removeLink("planting_task", "planting_id", plantingId, "task_id", taskId);
}

void Task::addLocation(int locationId, int taskId) const
{
    addLink("location_task", "location_id", locationId, "task_id", taskId);
}

void Task::removeLocation(int locationId, int taskId) const
{
    removeLink("location_task", "location_id", locationId, "task_id", taskId);
}

void Task::duplicateLocationTasks(int sourceLocationId, int newLocationId) const
{
    qDebug() << Q_FUNC_INFO << "Duplicate tasks of location" << sourceLocationId << "for"
             << newLocationId;

    auto sourceTasks = locationTasks(sourceLocationId);
    for (const int taskId : sourceTasks) {
        auto map = mapFromId("task", taskId);
        map.remove("task_id");

        int newTaskId = add(map);
        addLocation(newLocationId, newTaskId);
    }
}

void Task::removeLocationTasks(int locationId) const
{
    qDebug() << Q_FUNC_INFO << "Removing tasks for location: " << locationId;
    QString queryString("DELETE FROM location_task WHERE location_id = %1");
    QSqlQuery query(queryString.arg(locationId));
    debugQuery(query);
}

QList<int> Task::plantingTasks(int plantingId) const
{
    QString queryString = "SELECT * FROM planting_task WHERE planting_id = %1";
    return queryIds(queryString.arg(plantingId), "task_id");
}

QList<int> Task::taskPlantings(int taskId) const
{
    QString queryString = "SELECT * FROM planting_task WHERE task_id = %1";
    return queryIds(queryString.arg(taskId), "planting_id");
}

QList<int> Task::locationTasks(int locationId) const
{
    QString queryString = "SELECT * FROM location_task WHERE location_id = %1";
    return queryIds(queryString.arg(locationId), "task_id");
}

QList<int> Task::taskLocations(int taskId) const
{
    QString queryString = "SELECT * FROM location_task WHERE task_id = %1";
    return queryIds(queryString.arg(taskId), "location_id");
}

// TaskTypes: 0: DS, 1: GH sow, 2: TP
void Task::createTasks(int plantingId, const QDate &plantingDate) const
{
    qDebug() << "[Task] Creating tasks for planting: " << plantingId << plantingDate;

    auto record = recordFromId("planting", plantingId);
    auto type = static_cast<PlantingType>(record.value("planting_type").toInt());
    int dtt = record.value("dtt").toInt();

    switch (type) {
    case PlantingType::DirectSeeded: {
        int id = add({ { "assigned_date", plantingDate.toString(Qt::ISODate) }, { "task_type_id", 1 } });
        addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
    case PlantingType::TransplantRaised: {
        QDate sowDate = plantingDate.addDays(-dtt);
        int sowId = add({ { "assigned_date", sowDate.toString(Qt::ISODate) }, { "task_type_id", 2 } });
        int plantId = add({ { "assigned_date", plantingDate.toString(Qt::ISODate) },
                            { "task_type_id", 3 },
                            { "link_days", dtt },
                            { "link_task_id", sowId } });
        addLink("planting_task", "planting_id", plantingId, "task_id", sowId);
        addLink("planting_task", "planting_id", plantingId, "task_id", plantId);
        break;
    }
    case PlantingType::TransplantBought:
        int id = add({ { "assigned_date", plantingDate.toString(Qt::ISODate) }, { "task_type_id", 3 } });
        addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
}

/**
 * Return the greenhouse sowing task id for \a plantingId.
 *
 * If \a plantingId is not a TP, raised planting, return -1.
 */
int Task::greenhouseSowingTask(int plantingId) const
{
    if (plantingId < 1)
        return -1;

    QString queryString("SELECT task_id FROM planting_task "
                        "JOIN task USING (task_id) "
                        "WHERE planting_id = %1 "
                        "AND task_type_id = 2");

    auto idList = queryIds(queryString.arg(plantingId), "task_id");
    if (idList.isEmpty())
        return -1;

    return idList.first();
}

/** Return the sowing or in-ground planting task id for \a plantingId. */
int Task::plantingTask(int plantingId) const
{
    if (plantingId < 1)
        return -1;

    QString queryString("SELECT task_id FROM planting_task "
                        "JOIN task USING (task_id) "
                        "WHERE planting_id = %1 "
                        "AND task_type_id IN (1,3)");

    auto idList = queryIds(queryString.arg(plantingId), "task_id");
    if (idList.isEmpty())
        return -1;

    return idList.first();
}

/** Set the task type of \a taskId to \a type. */
void Task::updateType(int taskId, TaskType type) const
{
    update(taskId, { { "task_type_id", static_cast<int>(type) } });
}

int Task::typeId(int taskId) const
{
    auto record = recordFromId("task", taskId);
    return record.value("task_type_id").toInt();
}

/**
 * Create the nursery task for \a plantingId.
 *
 * Return the id of the nursery task.
 *
 * This method is used when the type of the planting \a plantingId is changed
 * from DS or TP, bought to TP, raised.
 */
int Task::createNurseryTask(int plantingId, const QDate &plantingDate, int dtt) const
{
    int plantingTaskId = plantingTask(plantingId);
    if (plantingTaskId < 0) {
        qDebug() << Q_FUNC_INFO << "Cannot create nursery task:"
                 << "planting task not found for planting id" << plantingId;
        return -1;
    }

    QDate sowDate = plantingDate.addDays(-dtt);
    int sowTaskId = add({ { "assigned_date", sowDate.toString(Qt::ISODate) }, { "task_type_id", 2 } });
    addLink("planting_task", "planting_id", plantingId, "task_id", sowTaskId);
    update(plantingTaskId, { { "link_days", dtt }, { "link_task_id", sowTaskId } });

    return sowTaskId;
}

void Task::completeTask(int taskId, const QDate &date) const
{
    update(taskId, { { "completed_date", date.toString(Qt::ISODate) } });
    updateHarvestLinkedTasks(taskId);
}

void Task::uncompleteTask(int taskId) const
{
    update(taskId, { { "completed_date", QVariant(QVariant::String) } });
    updateHarvestLinkedTasks(taskId);
}

bool Task::isComplete(int taskId) const
{
    auto date = dateFromField("task", "completed_date", taskId);
    return date.isValid();
}

void Task::delay(int taskId, int weeks)
{
    if (taskId < 0)
        return;

    QVariantMap map = mapFromId("task", taskId);
    if (!map.contains("assigned_date"))
        return;

    QDate assignedDate = QDate::fromString(map.value("assigned_date").toString(), Qt::ISODate);
    QString newDateString = assignedDate.addDays(weeks * 7).toString(Qt::ISODate);
    update(taskId, { { "assigned_date", newDateString } });
}

std::pair<int, int> Task::sowPlantTaskIds(int plantingId) const
{
    int sowingTaskId = -1;
    int plantingTaskId = -1;

    for (const int taskId : plantingTasks(plantingId)) {
        auto record = recordFromId("task", taskId);
        auto taskType = static_cast<TaskType>(record.value("task_type_id").toInt());

        if (taskType == TaskType::DirectSow) {
            sowingTaskId = plantingTaskId = taskId;
            break;
        } else if (taskType == TaskType::GreenhouseSow) {
            sowingTaskId = taskId;
            if (plantingTaskId > 0)
                break;
        } else if (taskType == TaskType::Transplant) {
            plantingTaskId = taskId;
            if (sowingTaskId > 0)
                break;
        }
    }

    return { sowingTaskId, plantingTaskId };
}

void Task::updateTaskDates(int plantingId, const QDate &plantingDate) const
{
    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());
    auto taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds.first;
    int transplantTaskId = taskIds.second;

    switch (plantingType) {
    case PlantingType::DirectSeeded: {
        QString queryString("UPDATE task SET assigned_date = :assigned_date "
                            "WHERE task_id = :task_id");
        qDebug() << Q_FUNC_INFO << "New date for sowing task:" << plantingDate.toString(Qt::ISODate);
        QSqlQuery query;
        query.prepare(queryString);
        query.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        query.bindValue(":task_id", sowTaskId);
        query.exec();
        debugQuery(query);
        break;
    }
    case PlantingType::TransplantRaised: {
        auto dtt = plantingRecord.value("dtt").toInt();
        auto sowDate = plantingDate.addDays(-dtt).toString(Qt::ISODate);

        QString queryString("UPDATE task SET assigned_date = :assigned_date "
                            "WHERE task_id = :task_id");
        QSqlQuery query;
        query.prepare(queryString);
        query.bindValue(":assigned_date", sowDate);
        query.bindValue(":task_id", sowTaskId);
        query.exec();
        debugQuery(query);

        QString linkQueryString("UPDATE task SET link_days = :link_days, "
                                "assigned_date = :assigned_date "
                                "WHERE task_id = :task_id");
        QSqlQuery linkQuery;
        linkQuery.prepare(linkQueryString);
        linkQuery.bindValue(":link_days", dtt);
        linkQuery.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        linkQuery.bindValue(":task_id", transplantTaskId);
        linkQuery.exec();
        debugQuery(linkQuery);
        break;
    }
    case PlantingType::TransplantBought: {
        QString queryString("UPDATE task SET assigned_date = :assigned_date"
                            " WHERE task_id = :task_id");
        QSqlQuery query;
        query.prepare(queryString);
        query.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        query.bindValue(":task_id", transplantTaskId);
        query.exec();
        debugQuery(query);
        break;
    }
    }
}

/**
 * Duplicate the tasks linked to \a sourcePlantingId and link them to \a newPlantingId.
 *
 * This method is used when duplicating plantings.
 */
void Task::duplicatePlantingTasks(int sourcePlantingId, int newPlantingId) const
{
    QList<int> linkedTaskList;
    QMap<int, int> taskIdMap;

    for (const int taskId : plantingTasks(sourcePlantingId)) {
        auto map = mapFromId("task", taskId);
        map.remove("task_id");
        map["completed_date"] = "";
        int newTaskId = add(map);
        addPlanting(newPlantingId, newTaskId);
        taskIdMap[taskId] = newTaskId;

        auto linkTaskId = map.value("link_task_id").toInt();
        if (linkTaskId > 0) {
            linkedTaskList.push_back(newTaskId);
        }
    }

    for (const int taskId : linkedTaskList) {
        auto map = mapFromId("task", taskId);
        auto linkTaskId = map.value("link_task_id").toInt();
        if (!taskIdMap.contains(linkTaskId)) {
            qDebug() << "Task::duplicate() : cannot find link task";
            break;
        }
        update(taskId, { { "link_task_id", taskIdMap[linkTaskId] } });
    }
}

/**  Remove all the tasks linked to \a plantingId. */
void Task::removePlantingTasks(int plantingId) const
{
    qDebug() << "[Task] Removing tasks for planting: " << plantingId;
    QString queryString("DELETE FROM planting_task WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

/**
 * Remove the nursery task for \a plantingId.
 *
 * This method is used when the planting type of a planting is changed
 * from TP, raised to DS or TP, bought.
 */
void Task::removeNurseryTask(int plantingId) const
{
    QString taskQueryString("SELECT task_id FROM planting_task "
                            "JOIN task USING (task_id) "
                            "WHERE planting_id = %1 AND task_type_id = 2");

    auto taskIdList = queryIds(taskQueryString.arg(plantingId), "task_id");
    if (taskIdList.isEmpty())
        return;

    int taskId = taskIdList.first();

    QString queryString("DELETE FROM planting_task WHERE task_id = %1");
    QSqlQuery query(queryString.arg(taskId));
    debugQuery(query);
}

std::pair<QDate, int> Task::assignedDateAndLinkTask(int plantingId, const QVariantMap &map) const
{
    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());
    auto dateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
    int linkDays = map["link_days"].toInt();
    int linkTaskId = -1;
    QDate assignedDate;

    auto taskIds = sowPlantTaskIds(plantingId);
    int sowingTaskId = taskIds.first;
    int plantingTaskId = taskIds.second;

    if (sowingTaskId == -1 && plantingTaskId == -1) {
        qDebug() << "[TaskTemplate::apply] both sow task and transplant task ids are invalid";
        return {};
    }

    switch (dateType) {
    case TemplateDateType::FieldSowPlant: {
        if (plantingType == PlantingType::DirectSeeded)
            linkTaskId = sowingTaskId;
        else
            linkTaskId = plantingTaskId;
        assignedDate = dateFromField("planting_view", "planting_date", plantingId).addDays(linkDays);
        break;
    }
    case TemplateDateType::GreenhouseStart: {
        if (plantingType == PlantingType::TransplantRaised)
            linkTaskId = sowingTaskId;
        assignedDate = dateFromField("planting_view", "sowing_date", plantingId).addDays(linkDays);
        break;
    }
    case TemplateDateType::FirstHarvest:
        assignedDate = dateFromField("planting_view", "beg_harvest_date", plantingId).addDays(linkDays);
        break;
    case TemplateDateType::LastHarvest:
        assignedDate = dateFromField("planting_view", "end_harvest_date", plantingId).addDays(linkDays);
        break;
    }
    return { assignedDate, linkTaskId };
}

void Task::updateLinkedTask(int plantingId, int taskId, QVariantMap &map) const
{
    QDate assignedDate;
    int linkTaskId;
    std::tie(assignedDate, linkTaskId) = assignedDateAndLinkTask(plantingId, map);
    if (linkTaskId > 0)
        map["link_task_id"] = linkTaskId;
    map["assigned_date"] = assignedDate.toString(Qt::ISODate);
    update(taskId, map);
}

void Task::updateHarvestLinkedTasks(int taskId) const
{
    int type = typeId(taskId);
    if (type != 1 && type != 3)
        return;

    auto plantingList = taskPlantings(taskId);
    int plantingId = plantingList.first();
    for (const int taskId : uncompletedHarvestLinkedTasks(plantingId)) {
        auto map = mapFromId("task", taskId);
        if (!map.isEmpty())
            updateLinkedTask(plantingId, taskId, map);
    }
}

QList<int> Task::uncompletedHarvestLinkedTasks(int plantingId) const
{
    QString queryString("SELECT task_id FROM task "
                        "JOIN planting_task using (task_id) "
                        "WHERE completed_date IS NULL "
                        "AND planting_id = %1 "
                        "AND template_date_type in (2,3)");
    return queryIds(queryString.arg(plantingId), "task_id");
}
