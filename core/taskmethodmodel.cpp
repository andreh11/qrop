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

#include "taskmethodmodel.h"
#include "sqltablemodel.h"

TaskMethodModel::TaskMethodModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_typeId(-1)
{
    setSortColumn("method");
    setFilterKeyStringColumn("method");
}

int TaskMethodModel::typeId() const
{
    return m_typeId;
}

void TaskMethodModel::setTypeId(int typeId)
{
    if (m_typeId == typeId)
        return;

    m_typeId = typeId;
    invalidateFilter();
    typeIdChanged();
}

bool TaskMethodModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int taskTypeId = rowValue(sourceRow, sourceParent, "task_type_id").toInt();
    return taskTypeId == m_typeId && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
