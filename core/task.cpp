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

#include "task.h"

Task::Task(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "task";
    m_viewTable = "task_view";
}

int Task::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);

    auto plantingIdList = newMap.take("planting_ids").toList();
    auto locationIdList = newMap.take("location_ids").toList();

    int methodId = newMap.value("task_method_id").toInt();
    if (methodId < 1)
        newMap.take("task_method_id");

    int implementId = newMap.value("task_implement_id").toInt();
    if (implementId < 1)
        newMap.take("task_implement_id");

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

/** @brief Return the sowing or in-ground planting task id for \a plantingId. */
int Task::plantingTask(int plantingId) const
{
    QString queryString("SELECT task_id FROM planting_task "
                        "JOIN task USING (task_id) "
                        "WHERE planting_id = %1 "
                        "AND task_type_id IN (1,3)");

    auto idList = queryIds(queryString.arg(plantingId), "task_id");
    if (idList.isEmpty())
        return -1;

    return idList.first();
}

/**
 * @brief Create the nursery task for \a plantingId.
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

QList<int> Task::sowPlantTaskIds(int plantingId) const
{
    int sowTaskId = -1;
    int transplantTaskId = -1;
    for (const int taskId : plantingTasks(plantingId)) {
        auto record = recordFromId("task", taskId);
        auto taskType = static_cast<TaskType>(record.value("task_type_id").toInt());

        if (taskType == TaskType::DirectSow) {
            sowTaskId = taskId;
        } else if (taskType == TaskType::GreenhouseSow) {
            sowTaskId = taskId;
            if (transplantTaskId > 0)
                break;
        } else if (taskType == TaskType::Transplant) {
            transplantTaskId = taskId;
            if (sowTaskId > 0)
                break;
        }
    }

    return QList<int>({ sowTaskId, transplantTaskId });
}

void Task::updateTaskDates(int plantingId, const QDate &plantingDate) const
{
    qDebug() << Q_FUNC_INFO << "Updating sowing & planting tasks for planting: " << plantingId
             << plantingDate;

    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());
    auto taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

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
 * @brief Duplicate the tasks linked to \a sourcePlantingId and link them to \a newPlantingId.
 *
 * This method is used when duplicating plantings.
 */
void Task::duplicatePlantingTasks(int sourcePlantingId, int newPlantingId) const
{
    qDebug() << Q_FUNC_INFO << "Duplicate tasks of planting" << sourcePlantingId << "for"
             << newPlantingId;

    auto sourceTasks = plantingTasks(sourcePlantingId);
    for (const int taskId : sourceTasks) {
        auto map = mapFromId("task", taskId);
        map.remove("task_id");
        int newTaskId = add(map);
        addPlanting(newPlantingId, newTaskId);
    }
}

/** @brief Remove all the tasks linked to \a plantingId. */
void Task::removePlantingTasks(int plantingId) const
{
    qDebug() << "[Task] Removing tasks for planting: " << plantingId;
    QString queryString("DELETE FROM planting_task WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

/**
 * @brief Remove the nursery task for \a plantingId.
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

/** @brief Return a list of template tasks ids for the the template \a templateId. */
QList<int> Task::templateTasks(int templateId) const
{
    QString queryString("SELECT * FROM task WHERE task_template_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

/** @brief Create tasks from the template \a templateId for the planting \a plantingId */
void Task::applyTemplate(int templateId, int plantingId) const
{
    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

    auto taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

    if (sowTaskId == -1 && transplantTaskId == -1) {
        qDebug() << Q_FUNC_INFO << "both sow task and transplant task id are invalid";
        return;
    }

    for (const int taskId : templateTasks(templateId)) {
        auto map = mapFromId("task", taskId);
        auto templateDateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
        switch (templateDateType) {
        case TemplateDateType::FieldSowPlant:
            map["link_task_id"] =
                    plantingType == PlantingType::DirectSeeded ? sowTaskId : transplantTaskId;
            break;
        case TemplateDateType::GreenhouseStart:
            map["link_task_id"] = plantingType == PlantingType::TransplantRaised ? sowTaskId : -1;
            break;
        case TemplateDateType::FirstHarvest:
            map["link_task_id"] = -1;
            break;
        case TemplateDateType::LastHarvest:
            map["link_task_id"] = -1;
            break;
        }

        if (map["link_task_id"] != -1) {
            int id = add(map);
            addPlanting(plantingId, id);
        }
    }
}

void Task::removeTemplate(int templateId, int plantingId) const
{
    QString queryString("DELETE FROM task WHERE template_id = %1 "
                        "AND task_id IN "
                        "(SELECT task.task_id FROM task JOIN planting_task WHERE planting_id = %2");
    QSqlQuery query(queryString.arg(templateId).arg(plantingId));
    debugQuery(query);
}
