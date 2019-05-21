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
    , m_plantingId(-1)
    , mTaskTemplate(new TaskTemplate(this))
{
    setSortColumn("name");
}

int TaskTemplateModel::plantingId() const
{
    return m_plantingId;
}

void TaskTemplateModel::setPlantingId(int id)
{
    if (m_plantingId == id)
        return;

    m_plantingId = id;
    refreshTemplateList();
    plantingIdChanged();
    refresh();
}

void TaskTemplateModel::refreshTemplateList()
{
    m_plantingTemplateList.clear();
    m_plantingTemplateList.append(mTaskTemplate->plantingTemplates(m_plantingId));
}

void TaskTemplateModel::toggle(int row)
{
    if (row < 0 || row > rowCount())
        return;

    auto templateId = rowValue(row, QModelIndex(), "task_template_id").toInt();
    if (isApplied(templateId))
        mTaskTemplate->unapply(templateId, m_plantingId);
    else
        mTaskTemplate->apply(templateId, m_plantingId);

    auto idx = index(row, 0, QModelIndex());
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
