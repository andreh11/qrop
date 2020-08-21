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

#include "harvestmodel.h"
#include "mdate.h"

HarvestModel::HarvestModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
}

int HarvestModel::year() const
{
    return m_year;
}

void HarvestModel::setYear(int year)
{
    if (year < 0 || m_year == year)
        return;

    m_year = year;
    updateWeekDates();
    emit yearChanged();
}

int HarvestModel::week() const
{
    return m_week;
}

void HarvestModel::setWeek(int week)
{
    if (week < 0 || m_week == week)
        return;

    m_week = week;
    updateWeekDates();
    emit weekChanged();
}
void HarvestModel::updateWeekDates()
{
    std::tie(m_mondayDate, m_sundayDate) = MDate::weekDates(m_week, m_year);
    // We have to use both of these to get everything working.
    invalidateFilter();
    invalidate();
}

bool HarvestModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QDate taskDate = sourceFieldDate(sourceRow, sourceParent, "date");
    bool inRange = m_mondayDate <= taskDate && taskDate <= m_sundayDate;
    return inRange && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
