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

void TaskModel::updateWeekDates()
{
    QList<QDate> weekDates = MDate::weekDates(m_week, m_year);
    m_mondayDate = weekDates[0];
    m_sundayDate = weekDates[1];
}

bool TaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QDate assignedDate = fieldDate(sourceRow, sourceParent, "assigned_date");
    bool inRange = m_mondayDate <= assignedDate && assignedDate <= m_sundayDate;
    return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent) && inRange;
}
