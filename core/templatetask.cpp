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
    mTask->removeList(uncompletedTasks(templateTaskId));
}

std::pair<QDate, int> TemplateTask::assignedDateAndLinkTask(int plantingId, const QVariantMap &map) const
{
    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());
    auto dateType = static_cast<TemplateDateType>(map["template_date_type"].toInt());
    int linkDays = map["link_days"].toInt();
    int linkTaskId = -1;
    QDate assignedDate;

    auto taskIds = mTask->sowPlantTaskIds(plantingId);
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
        assignedDate = mPlanting->plantingDate(plantingId).addDays(linkDays);
        break;
    }
    case TemplateDateType::GreenhouseStart: {
        if (plantingType == PlantingType::TransplantRaised)
            linkTaskId = sowingTaskId;
        assignedDate = mPlanting->sowingDate(plantingId).addDays(linkDays);
        break;
    }
    case TemplateDateType::FirstHarvest:
        assignedDate = mPlanting->begHarvestDate(plantingId).addDays(linkDays);
        break;
    case TemplateDateType::LastHarvest:
        assignedDate = mPlanting->endHarvestDate(plantingId).addDays(linkDays);
        break;
    }
    return { assignedDate, linkTaskId };
}

void TemplateTask::apply(int templateTaskId, int plantingId) const
{
    if (templateTaskId < 0 || plantingId < 0)
        return;

    auto map = mapFromId("template_task", templateTaskId);
    map.take("task_template_id"); // not needed, since we can get it from template_task_id

    QDate assignedDate;
    int linkTaskId;
    std::tie(assignedDate, linkTaskId) = assignedDateAndLinkTask(plantingId, map);
    if (linkTaskId > 0)
        map["link_task_id"] = linkTaskId;
    map["assigned_date"] = assignedDate.toString(Qt::ISODate);
    map["planting_ids"] = QVariantList({ QString::number(plantingId) });
    mTask->add(map);
}

void TemplateTask::applyList(int templateTaskId, QList<int> plantingIdList) const
{
    QSqlDatabase::database().transaction();
    for (const int plantingId : plantingIdList)
        apply(templateTaskId, plantingId);
    QSqlDatabase::database().commit();
}

void TemplateTask::updateTasks(int templateTaskId) const
{
    const auto templateMap = mapFromId("template_task", templateTaskId);
    QSqlDatabase::database().transaction();
    for (const int taskId : uncompletedTasks(templateTaskId)) {
        auto map(templateMap);
        map.take("task_template_id"); // not needed, since we can get it from template_task_id

        auto plantingIdList = mTask->taskPlantings(taskId);
        if (plantingIdList.length() != 1)
            continue;

        const int plantingId = plantingIdList.first();
        QDate assignedDate;
        int linkTaskId;
        std::tie(assignedDate, linkTaskId) = assignedDateAndLinkTask(plantingId, map);
        if (linkTaskId > 0)
            map["link_task_id"] = linkTaskId;
        map["assigned_date"] = assignedDate.toString(Qt::ISODate);
        mTask->update(taskId, map);
    }
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
    if (newMap.contains("task_method_id") && newMap.value("task_method_id").toInt() < 1)
        newMap["task_method_id"] = QVariant(QVariant::Int);
    if (newMap.contains("task_implement_id") && newMap.value("task_implement_id").toInt() < 1)
        newMap["task_implement_id"] = QVariant(QVariant::Int);
    return newMap;
}
