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

#include "planting.h"
#include "tasktemplate.h"
#include "task.h"

TaskTemplate::TaskTemplate(QObject *parent)
    : DatabaseUtility(parent)
    , mPlanting(new Planting(this))
    , mTask(new Task(this))
{
    m_table = "task_template";
    m_viewTable = "task_template";
}

/**
 * Return an id list for the template tasks of \a templateId.
 */
QList<int> TaskTemplate::templateTasks(int templateId) const
{
    QString queryString("SELECT task_id FROM template_task WHERE task_template_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

/**
 * Return a list of the ids of the uncompleted tasks created from the task
 * template \a templateId.
 */
QList<int> TaskTemplate::uncompletedTasks(int templateId) const
{
    QString queryString("SELECT task_id FROM task_view "
                        "WHERE completed_date IS NULL "
                        "AND template_task_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

int TaskTemplate::duplicate(int id) const
{
    int newId = DatabaseUtility::duplicate(id);
    if (newId < 0) {
        qDebug() << "Cannot duplicate task template" << id;
        return -1;
    }

    for (const int taskId : templateTasks(id)) {
        auto map = mapFromId("task", taskId);
        map.take("task_id");
        map["task_template_id"] = newId;
        mTask->add(map);
    }

    return newId;
}

void TaskTemplate::remove(int id) const
{
    removeTemplateTasks(id);
    DatabaseUtility::remove(id);
}

void TaskTemplate::removeTemplateTasks(int templateId) const
{
    QString queryString("DELETE FROM template_task "
                        "WHERE task_template_id = %1");
    QSqlQuery query(queryString.arg(templateId));
    query.exec();
    debugQuery(query);
}

void TaskTemplate::removeUncompletedTasks(int templateId) const
{
    mTask->removeList(uncompletedTasks(templateId));
}

/**
 * Create tasks from the template \a templateId for the planting \a plantingId.
 */
void TaskTemplate::apply(int templateId, int plantingId) const
{
    if (templateId < 0 || plantingId < 0)
        return;

    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

    auto taskIds = mTask->sowPlantTaskIds(plantingId);
    int sowingTaskId = taskIds.first;
    int plantingTaskId = taskIds.second;

    if (sowingTaskId == -1 && plantingTaskId == -1) {
        qDebug() << "[TaskTemplate::apply] both sow task and transplant task ids are invalid";
        return;
    }

    for (const int taskId : templateTasks(templateId)) {
        auto map = mapFromId("task", taskId);
        map.remove("task_id");
        map.remove("assigned_date");
        map.remove("link_task_id");

        auto templateDateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
        int linkDays = map["link_days"].toInt();
        QDate assignedDate;
        if (templateDateType == TemplateDateType::FieldSowPlant) {
            if (plantingType == PlantingType::DirectSeeded)
                map["link_task_id"] = sowingTaskId;
            else
                map["link_task_id"] = plantingTaskId;
            assignedDate = mPlanting->plantingDate(plantingId).addDays(linkDays);
        } else if (templateDateType == TemplateDateType::GreenhouseStart) {
            map["link_task_id"] = plantingType == PlantingType::TransplantRaised ? sowingTaskId : -1;
            assignedDate = mPlanting->sowingDate(plantingId).addDays(linkDays);
        } else if (templateDateType == TemplateDateType::FirstHarvest) {
            map["link_task_id"] = -1;
            assignedDate = mPlanting->begHarvestDate(plantingId).addDays(linkDays);
        } else if (templateDateType == TemplateDateType::LastHarvest) {
            map["link_task_id"] = -1;
            assignedDate = mPlanting->endHarvestDate(plantingId).addDays(linkDays);
        }

        map["assigned_date"] = assignedDate.toString(Qt::ISODate);
        if (map["link_task_id"] != -1) {
            int taskId = mTask->add(map);
            if (taskId > 0)
                mTask->addPlanting(plantingId, taskId);
        }
    }
}

void TaskTemplate::unapply(int templateId, int plantingId) const
{
    QString queryString("DELETE FROM task WHERE template_id = %1 "
                        "AND task_id IN "
                        "(SELECT task.task_id FROM task JOIN planting_task WHERE planting_id = %2");
    QSqlQuery query(queryString.arg(templateId).arg(plantingId));
    debugQuery(query);
}

/**  */
void TaskTemplate::updateTemplateTasks(int taskId, const QVariantMap &map) const
{
    //    for (const int taskId : uncompletedTasks(templateId)) {
    //        auto taskMap = mapFromId("task", taskId);
    //        const auto assignedDate = QDate::fromString(taskMap["assigned_date"].toString(), Qt::ISODate);
    //        const auto dateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
    //        const int linkDays = map["link_days"].toInt();

    //        auto plantingIdList = mTask->taskPlantings(taskId);
    //        if (plantingIdList.length() > 1) {
    //            qDebug() << "[updateTemplateTasks] Template tasks must be linked to only one
    //            planting."; continue;
    //        }

    //        int plantingId = plantingIdList.first();
    //        auto plantingRecord = recordFromId("planting", plantingId);
    //        auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

    //        auto taskIds = mTask->sowPlantTaskIds(plantingId);
    //        int sowTaskId = taskIds.first;
    //        int transplantTaskId = taskIds.second;

    //        QDate newDate;
    //        if (dateType == TemplateDateType::FieldSowPlant) {
    //            if (plantingType == PlantingType::DirectSeeded)
    //                taskMap["link_task_id"] = sowTaskId;
    //            else
    //                taskMap["link_task_id"] = transplantTaskId;
    //            newDate = mPlanting->plantingDate(plantingId).addDays(linkDays);
    //        } else if (dateType == TemplateDateType::GreenhouseStart) {
    //            taskMap["link_task_id"] = plantingType == PlantingType::TransplantRaised ?
    //            sowTaskId : -1; newDate = mPlanting->sowingDate(plantingId).addDays(linkDays);
    //        } else {
    //            // TODO:
    //            //        TemplateDateType::FirstHarvest
    //            //        TemplateDateType::LastHarvest:
    //            taskMap["link_task_id"] = -1;
    //        }
    //    }
}
