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

#include "tasktemplate.h"
#include "task.h"

TaskTemplate::TaskTemplate(QObject *parent)
    : DatabaseUtility(parent)
    , mTask(new Task(this))
{
    m_table = "task_template";
    m_viewTable = "task_template";
}

/*! Return a list of template tasks ids for the the template \a templateId. */
QList<int> TaskTemplate::tasks(int templateId) const
{
    QString queryString("SELECT * FROM task WHERE assigned_date = \" \" AND task_template_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

int TaskTemplate::duplicate(int id) const
{
    int newId = DatabaseUtility::duplicate(id);
    for (const int taskId : tasks(id)) {
        auto map = mapFromId("task", taskId);
        map.take("task_id");
        map["task_template_id"] = newId;
        mTask->add(map);
    }
    return newId;
}

void TaskTemplate::remove(int id) const
{
    QString queryString = "DELETE FROM task WHERE task_template_id = %1";
    QSqlQuery query(queryString.arg(id));
    query.exec();
    debugQuery(query);
    DatabaseUtility::remove(id);
}

/*! Create tasks from the template \a templateId for the planting \a plantingId */
void TaskTemplate::apply(int templateId, int plantingId) const
{
    auto plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

    auto taskIds = mTask->sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

    if (sowTaskId == -1 && transplantTaskId == -1) {
        qDebug() << Q_FUNC_INFO << "both sow task and transplant task id are invalid";
        return;
    }

    for (const int taskId : tasks(templateId)) {
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
            mTask->addPlanting(plantingId, id);
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
