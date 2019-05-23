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
#include <QPair>
#include <QDebug>
#include <QVariantMap>

#include "templatetask.h"

#include "task.h"
#include "planting.h"

TemplateTask::TemplateTask(QObject *parent)
    : DatabaseUtility(parent)
    , mPlanting(new Planting(this))
    , mTask(new Task(this))
{
    m_table = "template_task";
    m_viewTable = "template_task_view";
}

int TemplateTask::add(const QVariantMap &map) const
{
    return DatabaseUtility::add(removeInvalidIds(map));
}

void TemplateTask::update(int id, const QVariantMap &map) const
{
    DatabaseUtility::update(id, removeInvalidIds(map));
}

void TemplateTask::addToCurrentApplications(int templateTaskId) const
{
    applyList(templateTaskId, plantings(templateTaskId));
}

void TemplateTask::removeFromCurrentApplications(int templateTaskId) const
{
    qDebug() << "UNCOMPLETED TASKS" << uncompletedTasks(templateTaskId);
    mTask->removeList(uncompletedTasks(templateTaskId));
}

void TemplateTask::apply(int templateTaskId, int plantingId) const
{
    if (templateTaskId < 0 || plantingId < 0)
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
            return;
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

void TemplateTask::applyList(int templateTaskId, QList<int> plantingIdList) const
{
    QSqlDatabase::database().transaction();
    for (const int plantingId : plantingIdList)
        apply(templateTaskId, plantingId);
    QSqlDatabase::database().commit();
}

/**
 * Return the template to which \a templateTaskId belongs.
 */
int TemplateTask::templateId(int templateTaskId) const
{
    auto record = recordFromId("template_task", templateTaskId);
    if (record.isEmpty())
        return -1;
    return record.value("task_template_id").toInt();
}

/**
 * Return the plantings to which the template of \a templateTaskId is applied.
 */
QList<int> TemplateTask::plantings(int templateTaskId) const
{
    QString queryString("SELECT DISTINCT planting_id "
                        "FROM planting "
                        "JOIN planting_task USING (planting_id) "
                        "JOIN task_view USING (task_id) "
                        "WHERE task_template_id = %1 ");
    return queryIds(queryString.arg(templateId(templateTaskId)), "planting_id");
}

/**
 * Return a list of the ids of the uncompleted tasks created \a templateTaskId.
 */
QList<int> TemplateTask::uncompletedTasks(int templateTaskId) const
{
    QString queryString("SELECT task_id FROM task "
                        "WHERE completed_date IS NULL "
                        "AND template_task_id = %1");
    return queryIds(queryString.arg(templateTaskId), "task_id");
}

QVariantMap TemplateTask::removeInvalidIds(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    int methodId = newMap.value("task_method_id").toInt();
    if (methodId < 1)
        newMap.take("task_method_id");

    int implementId = newMap.value("task_implement_id").toInt();
    if (implementId < 1)
        newMap.take("task_implement_id");
    return newMap;
}
