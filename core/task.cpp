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
#include <QVariantMap>

#include "task.h"

Task::Task(QObject *parent)
    : DatabaseUtility(parent)
{
      m_table = "task";
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
    qDebug() << "[Task] Duplicate tasks of location" << sourceLocationId
             << "for" << newLocationId;

    QList<int> sourceTasks = locationTasks(sourceLocationId);
    for (const int taskId : sourceTasks) {
        QVariantMap map = mapFromId("task", taskId);
        map.remove("task_id");

        int newTaskId = add(map);
        addLocation(newLocationId, newTaskId);
    }
}

void Task::removeLocationTasks(int locationId) const
{
    qDebug() << "[Task] Removing tasks for location: " << locationId;
    QString queryString("DELETE FROM location_task WHERE location_id = %1");
    QSqlQuery query(queryString.arg(locationId));
    debugQuery(query);
}

QList<int> Task::plantingTasks(int plantingId) const
{

    QString queryString = "SELECT * FROM planting_task WHERE planting_id = %1";
    return queryIds(queryString.arg(plantingId), "task_id");
}

QList<int> Task::locationTasks(int locationId) const
{

    QString queryString = "SELECT * FROM location_task WHERE location_id = %1";
    return queryIds(queryString.arg(locationId), "task_id");
}

// TaskTypes: 0: DS, 1: GH sow, 2: TP
void Task::createTasks(int plantingId, const QDate &plantingDate) const
{
    qDebug() << "[Task] Creating tasks for planting: " << plantingId << plantingDate;

    QSqlRecord rec = recordFromId("planting", plantingId);
    auto type = static_cast<PlantingType>(rec.value("planting_type").toInt());
    int dtt = rec.value("dtt").toInt();

    switch(type) {
    case PlantingType::DirectSeeded: {
        int id = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                      {"task_type_id", 1}});
        addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
    case PlantingType::TransplantRaised: {
        QDate sowDate = plantingDate.addDays(-dtt);
        int sowId = add({{"assigned_date", sowDate.toString(Qt::ISODate)},
                         {"task_type_id", 2}});
        int plantId = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                           {"task_type_id", 3},
                           {"link_task_id", sowId}});
        addLink("planting_task", "planting_id", plantingId, "task_id", sowId);
        addLink("planting_task", "planting_id", plantingId, "task_id", plantId);
        break;
    }
    case PlantingType::TransplantBought:
        int id = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                      {"task_type_id", 3}});
        addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
}

QList<int> Task::sowPlantTaskIds(int plantingId) const
{
    int sowTaskId = -1;
    int transplantTaskId = -1;
    TaskType taskType;
    QSqlRecord record ;
    for (const int taskId : plantingTasks(plantingId)) {
        record = recordFromId("task", taskId);
        taskType = static_cast<TaskType>(record.value("task_type_id").toInt());

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

    return QList<int>({sowTaskId, transplantTaskId});
}

void Task::updateTaskDates(int plantingId, const QDate &plantingDate) const
{
    qDebug() << "[Task] Updating sow & plant tasks for planting: " << plantingId << plantingDate;

    QSqlRecord plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());
    QList<int> taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

    switch (plantingType) {
    case PlantingType::DirectSeeded: {
        QString queryString = "UPDATE task SET assigned_date = :assigned_date "
                              "WHERE task_id = :task_id";
        QSqlQuery query;
        query.prepare(queryString);
        query.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        query.bindValue(":task_id", sowTaskId);
        query.exec();
        debugQuery(query);
        break;
    }
    case PlantingType::TransplantRaised: {
        int dtt = plantingRecord.value("dtt").toInt();
        QString sowDate = plantingDate.addDays(-dtt).toString(Qt::ISODate);

        QString queryString = "UPDATE task SET assigned_date = :assigned_date "
                              "WHERE task_id = :task_id";
        QSqlQuery query;
        query.prepare(queryString);
        query.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        query.bindValue(":task_id", sowTaskId);
        query.exec();
        debugQuery(query);

        QString linkQueryString("UPDATE task SET link_days = :link_days, "
                                "assigned_date = :assigned_date "
                                "WHERE task_id = :task_id");

        QSqlQuery linkQuery;
        query.bindValue(":link_days", dtt);
        query.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        query.bindValue(":task_id", transplantTaskId);
        linkQuery.exec();
        debugQuery(linkQuery);
        break;
    }
    case PlantingType::TransplantBought: {
        QString queryString = "UPDATE task SET assigned_date = :assigned_date"
                              " WHERE task_id = :task_id";
        QSqlQuery query;
        query.bindValue(":assigned_date", plantingDate.toString(Qt::ISODate));
        query.bindValue(":task_id", transplantTaskId);
        query.exec();
        debugQuery(query);
        break;
    }
    }
}

void Task::duplicatePlantingTasks(int sourcePlantingId, int newPlantingId) const
{
    qDebug() << "[Task] Duplicate tasks of planting" << sourcePlantingId
             << "for" << newPlantingId;

    QList<int> sourceTasks = plantingTasks(sourcePlantingId);
    QVariantMap map;
    int newTaskId;
    for (const int taskId : sourceTasks) {
        map = mapFromId("task", taskId);
        map.remove("task_id");
        newTaskId = add(map);
        addPlanting(newPlantingId, newTaskId);
    }
}

void Task::removePlantingTasks(int plantingId) const
{
    qDebug() << "[Task] Removing tasks for planting: " << plantingId;
    QString queryString("DELETE FROM planting_task WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

QList<int> Task::templateTasks(int templateId) const
{
    QString queryString("SELECT * FROM task WHERE task_template_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

void Task::applyTemplate(int templateId, int plantingId) const
{
    QSqlRecord plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

    QVariantMap map;
    QList<int> taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

    if (sowTaskId == -1 && transplantTaskId == -1) {
        qDebug() << Q_FUNC_INFO << "both sow task and tranplant task id are invalid";
        return;
    }

    for (const int taskId : templateTasks(templateId)) {
        map = mapFromId("task", taskId);
        auto templateDateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
        switch (templateDateType) {
        case TemplateDateType::FieldSowPlant:
            map["link_task_id"] = plantingType == PlantingType::DirectSeeded ? sowTaskId
                                                                             : transplantTaskId;
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
