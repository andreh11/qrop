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
    , m_methodId(-1)
{
    int col = m_model->record().indexOf("task_method_id");
    setFilterKeyColumn(col);
    setSortColumn("implement");
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
    setFilterFixedString(QString::number(m_methodId));
    methodIdChanged();
}
