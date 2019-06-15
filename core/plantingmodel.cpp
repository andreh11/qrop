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
#include "location.h"
#include "planting.h"

PlantingModel::PlantingModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_week(-1)
    , m_showActivePlantings(false)
    , m_showOnlyUnassigned(false)
    , m_showOnlyGreenhouse(false)
    , m_showOnlyHarvested(false)
    , m_cropId(-1)
    , location(new Location(this))
    , planting(new Planting(this))
{
    setSortColumn("crop");
    connect(this, SIGNAL(countChanged()), this, SIGNAL(revenueChanged()));
}

bool PlantingModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_sortColumn == "variety") {
        auto leftCrop = rowValue(left.row(), left.parent(), "crop").toString();
        auto rightCrop = rowValue(right.row(), right.parent(), "crop").toString();

        auto leftVariety = rowValue(left.row(), left.parent(), "variety").toString();
        auto rightVariety = rowValue(right.row(), right.parent(), "variety").toString();

        return (leftCrop < rightCrop) || ((leftCrop == rightCrop) && (leftVariety < rightVariety));
    } else if (m_sortColumn == "locations") {
        int leftId = rowValue(left.row(), left.parent(), "planting_id").toInt();
        int rightId = rowValue(right.row(), right.parent(), "planting_id").toInt();
        return location->fullName(location->locations(leftId))
                < location->fullName(location->locations(rightId));
    }
    return SortFilterProxyModel::lessThan(left, right);
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

bool PlantingModel::showOnlyUnassigned() const
{
    return m_showOnlyUnassigned;
}

void PlantingModel::setShowOnlyUnassigned(bool show)
{
    if (m_showOnlyUnassigned == show)
        return;

    m_showOnlyUnassigned = show;
    invalidateFilter();
    emit showOnlyUnassignedChanged();
}

bool PlantingModel::showOnlyGreenhouse() const
{
    return m_showOnlyGreenhouse;
}

void PlantingModel::setShowOnlyGreenhouse(bool show)
{
    if (m_showOnlyGreenhouse == show)
        return;

    m_showOnlyGreenhouse = show;
    invalidateFilter();
    emit showOnlyGreenhouseChanged();
}

bool PlantingModel::showOnlyHarvested() const
{
    return m_showOnlyHarvested;
}

void PlantingModel::setShowOnlyHarvested(bool show)
{
    if (m_showOnlyHarvested == show)
        return;

    m_showOnlyHarvested = show;
    invalidateFilter();
    emit showOnlyHarvestedChanged();
}

int PlantingModel::cropId() const
{
    return m_cropId;
}

void PlantingModel::setCropId(int cropId)
{
    if (m_cropId == cropId)
        return;

    m_cropId = cropId;
    invalidateFilter();
    emit cropIdChanged();
}

int PlantingModel::revenue() const
{
    QString queryString("SELECT SUM(bed_revenue) "
                        "FROM planting_view WHERE strftime(\"%Y\", beg_harvest_date) = \"%1\"");
    QSqlQuery query(queryString.arg(m_year));
    query.next();
    return query.value(0).toInt();
}

bool PlantingModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int plantingId = rowValue(sourceRow, sourceParent, "planting_id").toInt();
    int length = rowValue(sourceRow, sourceParent, "length").toInt();
    QDate sowingDate = fieldDate(sourceRow, sourceParent, "sowing_date");
    QDate plantingDate = fieldDate(sourceRow, sourceParent, "planting_date");
    QDate harvestBeginDate = fieldDate(sourceRow, sourceParent, "beg_harvest_date");
    QDate harvestEndDate = fieldDate(sourceRow, sourceParent, "end_harvest_date");
    bool inGreenhouse = rowValue(sourceRow, sourceParent, "in_greenhouse").toInt() > 0;
    int cropId = rowValue(sourceRow, sourceParent, "crop_id").toInt();

    bool inRange = (isDateInRange(sowingDate) || isDateInRange(plantingDate)
                    || isDateInRange(harvestBeginDate) || isDateInRange(harvestEndDate))
            && (!m_showActivePlantings
                || (sowingDate.weekNumber() <= m_week && m_week <= harvestEndDate.weekNumber()))
            && (!m_showOnlyUnassigned || length > planting->assignedLength(plantingId))
            && (!m_showOnlyGreenhouse || inGreenhouse)
            && (!m_showOnlyHarvested
                || (harvestBeginDate.weekNumber() <= m_week && m_week <= harvestEndDate.weekNumber()))
            && (m_cropId < 1 || cropId == m_cropId);

    return inRange && QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
