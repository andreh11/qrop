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
#include "taskmodel.h"

TaskModel::TaskModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_week(0)
    , m_showDone(false)
    , m_showDue(false)
    , m_showOverdue(false)
    , m_plantingId(-1)
{
    setSortColumn("assigned_date");
    m_filterDate = QDate();
    setDynamicSortFilter(true);
}

bool TaskModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    QDate leftAssignedDate = fieldDate(left.row(), left.parent(), "assigned_date");
    QDate rightAssignedDate = fieldDate(right.row(), right.parent(), "assigned_date");
    QDate leftCompletedDate = fieldDate(left.row(), left.parent(), "completed_date");
    QDate rightCompletedDate = fieldDate(right.row(), right.parent(), "completed_date");

    auto leftDate = leftCompletedDate.isValid() ? leftCompletedDate : leftAssignedDate;
    auto rightDate = rightCompletedDate.isValid() ? rightCompletedDate : rightAssignedDate;
    bool before = leftDate < rightDate;

    if (m_plantingId > 0)
        return before;

    int leftType = rowValue(left.row(), left.parent(), "task_type_id").toInt();
    int rightType = rowValue(right.row(), right.parent(), "task_type_id").toInt();

    return (leftType < rightType) || (leftType == rightType && before);
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
    showDoneChanged();
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
    showDueChanged();
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
    showOverdueChanged();
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
    plantingIdChanged();
    invalidateFilter();
}

void TaskModel::updateWeekDates()
{
    auto weekDates = MDate::weekDates(m_week, m_year);
    m_mondayDate = weekDates[0];
    m_sundayDate = weekDates[1];
    // Strangely, we have to use both of these to get everything working.
    invalidateFilter();
    invalidate();
}

bool TaskModel::done(int row, const QModelIndex &parent) const
{
    QDate completedDate = fieldDate(row, parent, "completed_date");
    bool completed = completedDate.isValid();
    return completed
            && (m_plantingId > 0
                || ((m_mondayDate <= completedDate) && (completedDate <= m_sundayDate)));
}

bool TaskModel::due(int row, const QModelIndex &parent) const
{
    QDate assignedDate = fieldDate(row, parent, "assigned_date");
    bool completed = rowValue(row, parent, "completed_date").toString() != "";
    if (m_plantingId > 0)
        return !completed && assignedDate >= QDate::currentDate();
    return !completed && m_mondayDate <= assignedDate && assignedDate <= m_sundayDate;
}

bool TaskModel::overdue(int row, const QModelIndex &parent) const
{
    QDate assignedDate = fieldDate(row, parent, "assigned_date");
    bool completed = rowValue(row, parent, "completed_date").toString() != "";
    if (m_plantingId > 0)
        return !completed && assignedDate < QDate::currentDate();
    return !completed && assignedDate < m_mondayDate && MDate::isoYear(assignedDate) == m_year;
}

bool TaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_plantingId > 0) {
        auto plantingString = rowValue(sourceRow, sourceParent, "plantings").toString();
        QList<int> plantingIdList;
        for (const auto &plantingId : plantingString.split(","))
            plantingIdList.push_back(plantingId.toInt());

        return plantingIdList.contains(m_plantingId)
                && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
    }

    bool inRange = (m_showOverdue && overdue(sourceRow, sourceParent))
            || (m_showDue && due(sourceRow, sourceParent))
            || (m_showDone && done(sourceRow, sourceParent));
    return inRange && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
