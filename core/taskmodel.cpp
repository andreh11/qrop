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
{
    setSortColumn("assigned_date");
    m_filterDate = QDate();
    setDynamicSortFilter(true);
}

bool TaskModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    int leftType = rowValue(left.row(), left.parent(), "task_type_id").toInt();
    int rightType = rowValue(right.row(), right.parent(), "task_type_id").toInt();
    QDate leftDate = fieldDate(left.row(), left.parent(), "assigned_date");
    QDate rightDate = fieldDate(right.row(), right.parent(), "assigned_date");

    return (leftType < rightType) || (leftType == rightType && leftDate < rightDate);
}

QVariant TaskModel::data(const QModelIndex &idx, int role) const
{
    QModelIndex sourceIndex = mapToSource(idx);
    switch (role) {
    case Qt::UserRole + 100:
        return isOverdue(sourceIndex.row(), sourceIndex.parent());
    case Qt::UserRole + 101:
        return isDue(sourceIndex.row(), sourceIndex.parent());
    case Qt::UserRole + 102:
        return isDone(sourceIndex.row(), sourceIndex.parent());
    default:
        return SortFilterProxyModel::data(idx, role);
    }
}

QHash<int, QByteArray> TaskModel::roleNames() const
{
    QHash<int, QByteArray> roles = SortFilterProxyModel::roleNames();
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

    const QString filterString =
            QString::fromLatin1("date_assigned = %1").arg(date.toString(Qt::ISODate));

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

void TaskModel::updateWeekDates()
{
    QList<QDate> weekDates = MDate::weekDates(m_week, m_year);
    m_mondayDate = weekDates[0];
    m_sundayDate = weekDates[1];
    invalidate();
}

bool TaskModel::isDone(int row, const QModelIndex &parent) const
{
    QDate completedDate = fieldDate(row, parent, "completed_date");
    bool completed = completedDate.isValid();
    return completed && m_mondayDate <= completedDate && completedDate <= m_sundayDate
            && completedDate.year() == m_year;
}

bool TaskModel::isDue(int row, const QModelIndex &parent) const
{
    QDate assignedDate = fieldDate(row, parent, "assigned_date");
    bool completed = rowValue(row, parent, "completed_date").toString() != "";
    return !completed && m_mondayDate <= assignedDate && assignedDate <= m_sundayDate
            && assignedDate.year() == m_year;
}

bool TaskModel::isOverdue(int row, const QModelIndex &parent) const
{
    QDate assignedDate = fieldDate(row, parent, "assigned_date");
    bool completed = rowValue(row, parent, "completed_date").toString() != "";
    return !completed && assignedDate < m_mondayDate && assignedDate.year() == m_year;
}

bool TaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{

    bool inRange = (m_showOverdue && isOverdue(sourceRow, sourceParent))
            || (m_showDue && isDue(sourceRow, sourceParent))
            || (m_showDone && isDone(sourceRow, sourceParent));
    return inRange && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
