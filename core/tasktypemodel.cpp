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

#include "tasktypemodel.h"

TaskTypeModel::TaskTypeModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_showPlantingTasks(true)
{
    setSortColumn("type");
}

bool TaskTypeModel::showPlantingTasks() const
{
    return m_showPlantingTasks;
}

void TaskTypeModel::setShowPlantingTasks(bool show)
{
    if (m_showPlantingTasks == show)
        return;

    m_showPlantingTasks = show;
    invalidateFilter();
    showPlantingTasksChanged();
}

bool TaskTypeModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int taskTypeId = rowValue(sourceRow, sourceParent, "task_type_id").toInt();
    bool isPlantingTask = taskTypeId <= 3;
    return SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent)
            && (m_showPlantingTasks || !isPlantingTask);
}
