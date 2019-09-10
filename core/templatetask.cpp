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
    , mTask(new Task(this))
{
    m_table = "template_task";
    m_viewTable = "template_task_view";
}

int TemplateTask::add(const QVariantMap &map) const
{
    return DatabaseUtility::add(removeInvalidIds(map));
}

QList<int> TemplateTask::addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const
{
    const int daysBetween = weeksBetween * 7;
    int linkDays = map["link_days"].toInt();

    QVariantMap newMap(map);
    QList<int> idList;

    QSqlDatabase::database().transaction();
    int i = 0;
    for (; i < successions; i++) {
        int days = i * daysBetween;
        newMap["link_days"] = linkDays + days;

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

void TemplateTask::update(int id, const QVariantMap &map) const
{
    DatabaseUtility::update(id, removeInvalidIds(map));
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
        mTask->updateLinkedTask(plantingId, taskId, map);
    }
    QSqlDatabase::database().commit();
}

void TemplateTask::addToCurrentApplications(int templateTaskId) const
{
    applyList(templateTaskId, plantings(templateTaskId));
}

void TemplateTask::removeFromCurrentApplications(int templateTaskId) const
{
    mTask->removeList(uncompletedTasks(templateTaskId));
}

void TemplateTask::apply(int templateTaskId, int plantingId) const
{
    if (templateTaskId < 0 || plantingId < 0)
        return;

    auto map = mapFromId("template_task", templateTaskId);
    map.take("task_template_id"); // not needed, since we can get it from template_task_id

    QDate assignedDate;
    int linkTaskId;
    std::tie(assignedDate, linkTaskId) = mTask->assignedDateAndLinkTask(plantingId, map);
    if (linkTaskId > 0)
        map["link_task_id"] = linkTaskId;
    map["assigned_date"] = assignedDate.toString(Qt::ISODate);
    map["planting_ids"] = QVariantList({ QString::number(plantingId) });
    mTask->add(map);
}

void TemplateTask::applyList(int templateTaskId, const QList<int> &plantingIdList) const
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

int TemplateTask::uncompletedPlantingTask(int templateTaskId, int plantingId) const
{
    QString queryString("SELECT task_id FROM task "
                        "JOIN planting_task USING (task_id) "
                        "WHERE completed_date IS NULL "
                        "AND template_task_id = %1 "
                        "AND planting_id = %2");
    auto list = queryIds(queryString.arg(templateTaskId).arg(plantingId), "task_id");
    if (list.length())
        return list.first();
    return -1;
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
