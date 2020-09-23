/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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
#include <QElapsedTimer>

#include "dbutils/location.h"
#include "dbutils/planting.h"
#include "dbutils/task.h"

#include "qrpdate.h"
#include "taskmodel.h"

TaskModel::TaskModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_location(new Location(this))
    , m_planting(new Planting(this))
    , m_task(new Task(this))
{
    setSortColumn("assigned_date");
    m_filterDate = QDate();
    setDynamicSortFilter(true);
}

void TaskModel::setSortColumn(const QString &columnName)
{
    m_sortColumn = columnName;
    sort(0, m_sortOrder == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    emit sortColumnChanged();
}

void TaskModel::setSortOrder(const QString &order)
{
    m_sortOrder = order;
    sort(0, m_sortOrder == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    emit sortOrderChanged();
}

bool TaskModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    auto leftType = sourceRowValue(left.row(), left.parent(), "task_type_id").toInt();
    auto rightType = sourceRowValue(right.row(), right.parent(), "task_type_id").toInt();

    if (m_plantingId < 0) { // We don't care about task types when listing one planting's tasks.
        if (leftType < rightType)
            return QSortFilterProxyModel::sortOrder() == Qt::AscendingOrder;
        if (leftType > rightType)
            return QSortFilterProxyModel::sortOrder() == Qt::DescendingOrder;
    }

    bool before = true;
    if (m_sortColumn == QStringLiteral("assigned_date")) {
        auto leftDate = sourceFieldDate(left.row(), left.parent(), "completed_date");
        auto rightDate = sourceFieldDate(right.row(), right.parent(), "completed_date");

        if (!leftDate.isValid())
            leftDate = sourceFieldDate(left.row(), left.parent(), "assigned_date");
        if (!rightDate.isValid())
            rightDate = sourceFieldDate(right.row(), right.parent(), "assigned_date");

        before = leftDate < rightDate;
    }

    return before;
}

QVariant TaskModel::data(const QModelIndex &idx, int role) const
{
    QModelIndex sourceIndex = mapToSource(idx);
    switch (role) {
    case Qt::UserRole + 100:
        return overdue(sourceIndex.row(), sourceIndex.parent());
    case Qt::UserRole + 101:
        return due(sourceIndex.row(), sourceIndex.parent());
    case Qt::UserRole + 102:
        return done(sourceIndex.row(), sourceIndex.parent());
    default:
        return SortFilterProxyModel::data(idx, role);
    }
}

QHash<int, QByteArray> TaskModel::roleNames() const
{
    auto roles = SortFilterProxyModel::roleNames();
    roles.insert(Qt::UserRole + 100, "overdue");
    roles.insert(Qt::UserRole + 101, "due");
    roles.insert(Qt::UserRole + 102, "done");
    return roles;
}

QDate TaskModel::date() const
{
    return m_filterDate;
}

void TaskModel::setFilterDate(const QDate &date)
{
    if (date == m_filterDate)
        return;

    m_filterDate = date;
    emit dateChanged();
}

int TaskModel::year() const
{
    return m_year;
}

void TaskModel::setYear(int year)
{
    if (year < 0 || m_year == year)
        return;

    m_year = year;
    updateWeekDates();
    emit yearChanged();
}

int TaskModel::week() const
{
    return m_week;
}

void TaskModel::setWeek(int week)
{
    if (week < 0 || m_week == week)
        return;

    m_week = week;
    updateWeekDates();
    emit weekChanged();
}

bool TaskModel::showDone() const
{
    return m_showDone;
}

void TaskModel::setShowDone(bool showDone)
{
    if (m_showDone == showDone)
        return;

    m_showDone = showDone;
    invalidateFilter();
    emit showDoneChanged();
}

bool TaskModel::showDue() const
{
    return m_showDue;
}

void TaskModel::setShowDue(bool showDue)
{
    if (m_showDue == showDue)
        return;
    m_showDue = showDue;
    invalidateFilter();
    emit showDueChanged();
}

bool TaskModel::showOverdue() const
{
    return m_showOverdue;
}

void TaskModel::setShowOverdue(bool showOverdue)
{
    if (m_showOverdue == showOverdue)
        return;

    m_showOverdue = showOverdue;
    invalidateFilter();
    emit showOverdueChanged();
}

int TaskModel::plantingId() const
{
    return m_plantingId;
}

void TaskModel::setPlantingId(int id)
{
    if (m_plantingId == id)
        return;

    m_plantingId = id;
    emit plantingIdChanged();
    invalidateFilter();
}

void TaskModel::updateWeekDates()
{
    std::tie(m_mondayDate, m_sundayDate) = QrpDate::weekDates(m_week, m_year);
    // Strangely, we have to use both of these to get everything working.
    invalidateFilter();
    invalidate();
}

bool TaskModel::done(int row, const QModelIndex &parent) const
{
    QDate completedDate = sourceFieldDate(row, parent, "completed_date");
    bool completed = completedDate.isValid();
    return completed
            && (m_plantingId > 0
                || ((m_mondayDate <= completedDate) && (completedDate <= m_sundayDate)));
}

bool TaskModel::due(int row, const QModelIndex &parent) const
{
    QDate assignedDate = sourceFieldDate(row, parent, "assigned_date");
    bool completed = sourceRowValue(row, parent, "completed_date").toString() != "";
    if (m_plantingId > 0)
        return !completed && assignedDate >= QDate::currentDate();
    return !completed && m_mondayDate <= assignedDate && assignedDate <= m_sundayDate;
}

bool TaskModel::overdue(int row, const QModelIndex &parent) const
{
    QDate assignedDate = sourceFieldDate(row, parent, "assigned_date");
    bool completed = sourceRowValue(row, parent, "completed_date").toString() != "";
    if (m_plantingId > 0)
        return !completed && assignedDate < QDate::currentDate();
    return !completed && assignedDate < m_mondayDate && QrpDate::isoYear(assignedDate) == m_year;
}

bool TaskModel::isAssignedToPlanting(int sourceRow, const QModelIndex &sourceParent) const
{
    auto plantingString = sourceRowValue(sourceRow, sourceParent, "plantings").toString();
    QList<int> plantingIdList;
    for (const auto &plantingId : plantingString.split(","))
        plantingIdList.push_back(plantingId.toInt());

    return plantingIdList.contains(m_plantingId);
}

bool TaskModel::isInSeason(int sourceRow, const QModelIndex &sourceParent) const
{
    return (m_showOverdue && overdue(sourceRow, sourceParent))
            || (m_showDue && due(sourceRow, sourceParent))
            || (m_showDone && done(sourceRow, sourceParent));
}

bool TaskModel::showPlantingTasks() const
{
    return m_plantingId > 0;
}

bool TaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    return (showPlantingTasks() ? isAssignedToPlanting(sourceRow, sourceParent)
                                : isInSeason(sourceRow, sourceParent))
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
