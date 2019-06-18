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

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QString>

#include "tasktemplatemodel.h"
#include "tasktemplate.h"

TaskTemplateModel::TaskTemplateModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , mTaskTemplate(new TaskTemplate(this))
{
    setSortColumn("name");
}

QList<int> TaskTemplateModel::plantingIdList() const
{
    return m_plantingIdList;
}

void TaskTemplateModel::setPlantingIdList(const QList<int> &idList)
{
    if (m_plantingIdList == idList)
        return;

    m_plantingIdList = idList;
    refreshTemplateList();
    plantingIdListChanged();
    refresh();
}

void TaskTemplateModel::refreshTemplateList()
{
    m_plantingTemplateList.clear();
    m_plantingTemplateList.append(mTaskTemplate->plantingsCommonTemplates(m_plantingIdList));
}

void TaskTemplateModel::toggle(int row)
{
    if (row < 0 || row > rowCount())
        return;

    auto idx = index(row, 0);

    auto templateId = rowValue(mapToSource(idx).row(), QModelIndex(), "task_template_id").toInt();
    if (isApplied(templateId))
        mTaskTemplate->unapplyList(templateId, m_plantingIdList);
    else
        mTaskTemplate->applyList(templateId, m_plantingIdList);

    refreshTemplateList();
    dataChanged(idx, idx);
}

QVariant TaskTemplateModel::data(const QModelIndex &idx, int role) const
{
    QModelIndex sourceIndex = mapToSource(idx);
    auto templateId = rowValue(sourceIndex.row(), sourceIndex.parent(), "task_template_id").toInt();
    switch (role) {
    case AppliedRole:
        return isApplied(templateId);
    default:
        return SortFilterProxyModel::data(idx, role);
    }
}

QHash<int, QByteArray> TaskTemplateModel::roleNames() const
{
    auto roles = SortFilterProxyModel::roleNames();
    roles.insert(AppliedRole, "is_applied");
    return roles;
}

bool TaskTemplateModel::isApplied(int templateId) const
{
    return m_plantingTemplateList.contains(templateId);
}
