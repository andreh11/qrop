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

#include <QDebug>

#include "taskimplementmodel.h"
#include "sqltablemodel.h"

TaskImplementModel::TaskImplementModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("implement");
    setFilterKeyStringColumn("implement");
}

int TaskImplementModel::methodId() const
{
    return m_methodId;
}

void TaskImplementModel::setMethodId(int methodId)
{
    if (m_methodId == methodId)
        return;

    m_methodId = methodId;
    invalidateFilter();
    methodIdChanged();
}

bool TaskImplementModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int taskMethodId = sourceRowValue(sourceRow, sourceParent, "task_method_id").toInt();
    return taskMethodId == m_methodId
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
