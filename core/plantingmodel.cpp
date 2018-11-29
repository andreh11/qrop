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

#include <QDate>
#include <QDebug>
#include <QVector>

#include "databaseutility.h"
#include "plantingmodel.h"
#include "sqltablemodel.h"

PlantingModel::PlantingModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_week(-1)
    , m_showActivePlantings(false)
{
    setSortColumn("crop");
}

int PlantingModel::week() const
{
    return m_week;
}

void PlantingModel::setWeek(int week)
{
    if (week < 0 || m_week == week)
        return;

    m_week = week;
    invalidateFilter();
    emit weekChanged();
}

bool PlantingModel::showActivePlantings() const
{
    return m_showActivePlantings;
}

void PlantingModel::setShowActivePlantings(bool show)
{
    if (m_showActivePlantings == show)
        return;

    m_showActivePlantings = show;
    invalidateFilter();
    emit showActivePlantingsChanged();
}

bool PlantingModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QDate sowingDate = fieldDate(sourceRow, sourceParent, "sowing_date");
    QDate plantingDate = fieldDate(sourceRow, sourceParent, "planting_date");
    QDate harvestBeginDate = fieldDate(sourceRow, sourceParent, "beg_haverst_date");
    QDate harvestEndDate = fieldDate(sourceRow, sourceParent, "end_harvest_date");

    bool inRange = (isDateInRange(sowingDate) || isDateInRange(plantingDate)
                    || isDateInRange(harvestBeginDate) || isDateInRange(harvestEndDate))
            && (!m_showActivePlantings
                || (sowingDate.weekNumber() <= m_week && m_week <= harvestEndDate.weekNumber()));

    return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent) && inRange;
}
