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
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>

#include "mdate.h"
#include "templatetaskmodel.h"

TemplateTaskModel::TemplateTaskModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("link_days");
    setSortOrder("ascending");
    setDynamicSortFilter(true);
}

// bool TemplateTaskModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
//{
//    int leftType = rowValue(left.row(), left.parent(), "task_type_id").toInt();
//    int rightType = rowValue(right.row(), right.parent(), "task_type_id").toInt();
//    QDate leftDate = fieldDate(left.row(), left.parent(), "assigned_date");
//    QDate rightDate = fieldDate(right.row(), right.parent(), "assigned_date");

//    return (leftType < rightType) || (leftType == rightType && leftDate < rightDate);
//}

int TemplateTaskModel::taskTemplateId() const
{
    return m_taskTemplateId;
}

void TemplateTaskModel::setTaskTemplateId(int taskTemplateId)
{
    if (m_taskTemplateId == taskTemplateId)
        return;

    m_taskTemplateId = taskTemplateId;
    invalidateFilter();
    taskTemplateIdChanged();
}

int TemplateTaskModel::templateDateType() const
{
    return m_templateDateType;
}

void TemplateTaskModel::setTemplateDateType(int templateDateType)
{
    if (m_templateDateType == templateDateType)
        return;
    m_templateDateType = templateDateType;
    invalidateFilter();
    templateDateTypeChanged();
}

bool TemplateTaskModel::beforeDate() const
{
    return m_beforeDate;
}

void TemplateTaskModel::setBeforeDate(bool before)
{
    if (m_beforeDate == before)
        return;

    m_beforeDate = before;
    invalidateFilter();
    beforeDateChanged();
}

bool TemplateTaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int taskTemplateId = rowValue(sourceRow, sourceParent, "task_template_id").toInt();
    if (taskTemplateId < 0 || m_taskTemplateId < 0)
        return false;

    int templateDateType = rowValue(sourceRow, sourceParent, "template_date_type").toInt();
    if (templateDateType < 0 || templateDateType > 3)
        return false;

    int linkDays = rowValue(sourceRow, sourceParent, "link_days").toInt();
    return ((m_beforeDate && linkDays < 0) || (!m_beforeDate && linkDays >= 0))
            && taskTemplateId == m_taskTemplateId && templateDateType == m_templateDateType
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
