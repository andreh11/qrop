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

#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

#include "mdate.h"
#include "taskmodel.h"

TaskModel::TaskModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("type");
    m_filterDate = QDate();
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

    const QString filterString = QString::fromLatin1(
                "date_assigned = %1").arg(date.toString(Qt::ISODate));

    emit dateChanged();
}

int TaskModel::year() const
{
    return m_year;
}

void TaskModel::setYear(int year)
{
    if (year < 0)
        return;

    m_year = year;
    updateWeekDates();
    invalidateFilter();
    emit yearChanged();
}

int TaskModel::week() const
{
    return m_week;
}

void TaskModel::setWeek(int week)
{
    if (week < 0)
        return;

    m_week = week;
    updateWeekDates();
    invalidateFilter();
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
}

bool TaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QDate assignedDate = fieldDate(sourceRow, sourceParent, "assigned_date");
    bool completed = !rowValue(sourceRow, sourceParent, "completed_date").toString().isEmpty();

    bool inRange = (m_showOverdue && !completed && assignedDate < m_mondayDate)
            || (m_showDue && !completed && m_mondayDate <= assignedDate && assignedDate <= m_sundayDate)
            || (m_showDone && completed);
    return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent) && inRange;
}
