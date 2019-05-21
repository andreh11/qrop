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
#include "templatetask.h"

TaskTemplate::TaskTemplate(QObject *parent)
    : DatabaseUtility(parent)
    , mPlanting(new Planting(this))
    , mTask(new Task(this))
    , mTemplateTask(new TemplateTask(this))
{
    m_table = "task_template";
    m_viewTable = "task_template";
}

/**
 * Return an id list for the template tasks of \a templateId.
 */
QList<int> TaskTemplate::templateTasks(int templateId) const
{
    QString queryString("SELECT template_task_id "
                        "FROM template_task "
                        "WHERE task_template_id = %1");
    return queryIds(queryString.arg(templateId), "template_task_id");
}

QList<int> TaskTemplate::plantingTemplateTasks(int templateId, int plantingId) const
{
    QString queryString("SELECT task.task_id "
                        "FROM task_view "
                        "JOIN planting_task USING (task_id) "
                        "WHERE task_template_id = %1 "
                        "AND planting_id = %2 ");
    return queryIds(queryString.arg(templateId).arg(plantingId), "task_id");
}

QList<int> TaskTemplate::uncompletedPlantingTemplateTasks(int templateId, int plantingId) const
{
    QString queryString("SELECT task_view.task_id "
                        "FROM task_view "
                        "JOIN planting_task USING (task_id) "
                        "WHERE task_template_id = %1 "
                        "AND planting_id = %2 "
                        "AND completed_date IS NULL");
    return queryIds(queryString.arg(templateId).arg(plantingId), "task_id");
}

/**
 * Return a list of the ids of the uncompleted tasks created from the task
 * template \a templateId.
 */
QList<int> TaskTemplate::uncompletedTasks(int templateId) const
{
    QString queryString("SELECT task_id FROM task_view "
                        "WHERE completed_date IS NULL "
                        "AND task_template_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

void TaskTemplate::duplicateTemplateTasks(int fromId, int toId) const
{
    for (const int taskId : templateTasks(fromId)) {
        auto map = mapFromId("template_task", taskId);
        map.take("template_task_id");
        map["task_template_id"] = toId;
        mTemplateTask->add(map);
    }
}

int TaskTemplate::duplicate(int id) const
{
    if (id < 0)
        return -1;

    int newId = DatabaseUtility::duplicate(id);
    if (newId < 0) {
        qDebug() << "Cannot duplicate task template" << id;
        return -1;
    }

    duplicateTemplateTasks(id, newId);
    return newId;
}

void TaskTemplate::removeUncompletedTasks(int templateId) const
{
    mTask->removeList(uncompletedTasks(templateId));
}

QList<int> TaskTemplate::plantingTemplates(int plantingId) const
{
    QString queryString("SELECT DISTINCT task_template_id "
                        "FROM planting "
                        "JOIN planting_task USING (planting_id) "
                        "JOIN task_view USING (task_id) "
                        "WHERE planting_id = %1 "
                        "AND task_template_id IS NOT NULL");
    return queryIds(queryString.arg(plantingId), "task_template_id");
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

    for (const int templateTaskId : templateTasks(templateId)) {
        auto map = mapFromId("template_task", templateTaskId);
        auto dateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
        int linkDays = map["link_days"].toInt();
        QDate assignedDate;

        switch (dateType) {
        case TemplateDateType::FieldSowPlant: {
            if (plantingType == PlantingType::DirectSeeded)
                map["link_task_id"] = sowingTaskId;
            else
                map["link_task_id"] = plantingTaskId;
            assignedDate = mPlanting->plantingDate(plantingId).addDays(linkDays);
            break;
        }
        case TemplateDateType::GreenhouseStart: {
            if (plantingType == PlantingType::TransplantRaised)
                map["link_task_id"] = sowingTaskId;
            else
                continue;
            assignedDate = mPlanting->sowingDate(plantingId).addDays(linkDays);
            break;
        }
        case TemplateDateType::FirstHarvest: {
            map.take("link_task_id");
            assignedDate = mPlanting->begHarvestDate(plantingId).addDays(linkDays);
            break;
        }
        case TemplateDateType::LastHarvest: {
            map.take("link_task_id");
            assignedDate = mPlanting->endHarvestDate(plantingId).addDays(linkDays);
        }
        }

        map["assigned_date"] = assignedDate.toString(Qt::ISODate);
        map.take("task_template_id");
        int taskId = mTask->add(map);
        if (taskId < 0) {
            qDebug() << "Cannot create tasks from template!";
            return;
        }
        mTask->addPlanting(plantingId, taskId);
    }
}

void TaskTemplate::unapply(int templateId, int plantingId) const
{
    mTask->removeList(uncompletedPlantingTemplateTasks(templateId, plantingId));
}

void TaskTemplate::updateTemplateTasks(int templateTaskId, const QVariantMap &map) const
{
    for (const int taskId : uncompletedTasks(templateTaskId)) {
        auto taskMap = mapFromId("task", taskId);
        const auto assignedDate = QDate::fromString(taskMap["assigned_date"].toString(), Qt::ISODate);
        const auto dateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
        const int linkDays = map["link_days"].toInt();

        auto plantingIdList = mTask->taskPlantings(taskId);
        if (plantingIdList.length() > 1) {
            qDebug() << "[updateTemplateTasks] Template tasks must be linked to only one planting.";
            continue;
        }

        int plantingId = plantingIdList.first();
        auto plantingRecord = recordFromId("planting_view", plantingId);
        auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

        auto taskIds = mTask->sowPlantTaskIds(plantingId);
        int sowTaskId = taskIds.first;
        int transplantTaskId = taskIds.second;

        QDate newDate;
        if (dateType == TemplateDateType::FieldSowPlant) {
            if (plantingType == PlantingType::DirectSeeded)
                taskMap["link_task_id"] = sowTaskId;
            else
                taskMap["link_task_id"] = transplantTaskId;
            newDate = mPlanting->plantingDate(plantingId).addDays(linkDays);
        } else if (dateType == TemplateDateType::GreenhouseStart) {
            taskMap["link_task_id"] = plantingType == PlantingType::TransplantRaised ? sowTaskId : -1;
            newDate = mPlanting->sowingDate(plantingId).addDays(linkDays);
        } else {
            // TODO:
            //        TemplateDateType::FirstHarvest
            //        TemplateDateType::LastHarvest:
            taskMap["link_task_id"] = -1;
        }
    }
}
