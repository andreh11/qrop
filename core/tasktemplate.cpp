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

bool TaskTemplate::templateApplied(int templateId, int plantingId) const
{
    return plantingTemplates(plantingId).contains(templateId);
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

QList<int> TaskTemplate::tasks(int templateId) const
{
    QString queryString("SELECT task_id FROM task_view "
                        "WHERE task_template_id = %1");
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

QList<int> TaskTemplate::plantingsCommonTemplates(QList<int> plantingIdList) const
{
    if (plantingIdList.empty())
        return {};

    auto common = plantingTemplates(plantingIdList.first());
    std::sort(common.begin(), common.end());

    for (const int plantingId : plantingIdList.mid(1)) {
        auto templates = plantingTemplates(plantingId);
        std::sort(templates.begin(), templates.end());

        auto i = common.begin();
        while (i != common.end()) {
            if (templates.contains(*i))
                i++;
            else
                i = common.erase(i);
        }
    }
    return common;
}

/**
 * Create tasks from the template \a templateId for the planting \a plantingId.
 */
void TaskTemplate::apply(int templateId, int plantingId, bool transaction) const
{
    if (templateId < 0 || plantingId < 0 || templateApplied(templateId, plantingId))
        return;

    if (!transaction)
        QSqlDatabase::database().transaction();
    for (const int templateTaskId : templateTasks(templateId))
        mTemplateTask->apply(templateTaskId, plantingId);
    if (!transaction)
        QSqlDatabase::database().commit();
}

void TaskTemplate::applyList(int templateId, QList<int> plantingIdList) const
{
    QSqlDatabase::database().transaction();
    for (const int plantingId : plantingIdList)
        apply(templateId, plantingId, true);
    QSqlDatabase::database().commit();
}

void TaskTemplate::unapply(int templateId, int plantingId) const
{
    mTask->removeList(uncompletedPlantingTemplateTasks(templateId, plantingId));
}

bool TaskTemplate::hasTasks(int templateId) const
{
    return tasks(templateId).length() > 0;
}

void TaskTemplate::unapplyList(int templateId, QList<int> plantingIdList) const
{
    for (const int plantingId : plantingIdList)
        unapply(templateId, plantingId);
}
