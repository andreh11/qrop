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

#include <QDate>
#include <QDebug>
#include <QVector>

#include "databaseutility.h"
#include "plantingmodel.h"
#include "sqltablemodel.h"
#include "location.h"
#include "planting.h"
#include "helpers.h"

PlantingModel::PlantingModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , location(new Location(this))
    , planting(new Planting(this))
{
    setSortColumn("crop");
    connect(this, SIGNAL(countChanged()), this, SIGNAL(revenueChanged()));
    connect(this, SIGNAL(countChanged()), this, SIGNAL(totalBedLengthChanged()));
    //    connect(this, SIGNAL(filterYearChanged()), this, SLOT(dataChangedForAll()));
    //    connect(this, SIGNAL(filterSeasonChanged()), this, SLOT(dataChangedForAll()));
}

bool PlantingModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_sortColumn == QStringLiteral("variety")) {
        auto leftCrop = sourceRowValue(left.row(), left.parent(), QStringLiteral("crop")).toString();
        auto rightCrop =
                sourceRowValue(right.row(), right.parent(), QStringLiteral("crop")).toString();

        int cmp = leftCrop.localeAwareCompare(rightCrop);
        if (cmp == -1)
            return true;
        if (cmp == 1)
            return false;

        auto leftVariety =
                sourceRowValue(left.row(), left.parent(), QStringLiteral("variety")).toString();
        auto rightVariety =
                sourceRowValue(right.row(), right.parent(), QStringLiteral("variety")).toString();

        return leftVariety.localeAwareCompare(rightVariety) == -1;
    }

    if (m_sortColumn == QStringLiteral("locations")) {
        int leftId = sourceRowValue(left.row(), left.parent(), QStringLiteral("planting_id")).toInt();
        int rightId =
                sourceRowValue(right.row(), right.parent(), QStringLiteral("planting_id")).toInt();
        return location->fullNameList(location->locations(leftId))
                       .localeAwareCompare(location->fullNameList(location->locations(rightId)))
                == -1;
    }

    return SortFilterProxyModel::lessThan(left, right);
}

QVariant PlantingModel::data(const QModelIndex &proxyIndex, int role) const
{
    Q_ASSERT(checkIndex(proxyIndex, CheckIndexOption::IndexIsValid));
    switch (role) {
    case InfoMap:
        return planting->drawInfoMap(m_model->record(mapToSource(proxyIndex).row()), m_season,
                                     m_year, true, false);
    default:
        return SortFilterProxyModel::data(proxyIndex, role);
    }
}

QHash<int, QByteArray> PlantingModel::roleNames() const
{
    auto names = SortFilterProxyModel::roleNames();
    names[InfoMap] = "infoMap";
    return names;
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

bool PlantingModel::showOnlyField() const
{
    return m_showOnlyField;
}

void PlantingModel::setShowOnlyField(bool show)
{
    if (m_showOnlyField == show)
        return;

    m_showOnlyField = show;
    invalidateFilter();
    emit showOnlyFieldChanged();
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

int PlantingModel::keywordId() const
{
    return m_keywordId;
}

void PlantingModel::setKeywordId(int keywordId)
{
    if (m_keywordId == keywordId)
        return;

    m_keywordId = keywordId;
    invalidateFilter();
    emit keywordIdChanged();
}

bool PlantingModel::showFinished() const
{
    return m_showFinished;
}

void PlantingModel::setShowFinished(bool show)
{
    if (m_showFinished == show)
        return;

    m_showFinished = show;
    invalidateFilter();
    emit showFinishedChanged();
}

int PlantingModel::revenue() const
{
    int revenue = 0;
    QDate harvestDate;
    for (int row = 0; row < rowCount(); ++row) {
        harvestDate = QDate::fromString(rowValue(row, "beg_harvest_date").toString(), Qt::ISODate);
        if (isDateInRange(harvestDate)) {
            revenue += rowValue(row, "bed_revenue").toInt();
        }
    }
    return revenue;
}

/* TODO: remove, this shouldn't be in a model */
qreal PlantingModel::totalBedLength() const
{
    QString queryString("SELECT SUM(length) "
                        "FROM planting_view WHERE strftime(\"%Y\", beg_harvest_date) = \"%1\"");
    QSqlQuery query(queryString.arg(m_year));
    query.next();
    return query.value(0).toInt();
}

bool PlantingModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int plantingId = sourceRowValue(sourceRow, sourceParent, "planting_id").toInt();
    qreal length = sourceRowValue(sourceRow, sourceParent, "length").toDouble();
    QDate sowingDate = sourceFieldDate(sourceRow, sourceParent, "sowing_date");
    QDate plantingDate = sourceFieldDate(sourceRow, sourceParent, "planting_date");
    QDate harvestBeginDate = sourceFieldDate(sourceRow, sourceParent, "beg_harvest_date");
    QDate harvestEndDate = sourceFieldDate(sourceRow, sourceParent, "end_harvest_date");
    bool inGreenhouse = sourceRowValue(sourceRow, sourceParent, "in_greenhouse").toInt() > 0;
    bool isFinished = sourceRowValue(sourceRow, sourceParent, "finished").toInt() > 0;
    int cropId = sourceRowValue(sourceRow, sourceParent, "crop_id").toInt();

    return (isDateInRange(sowingDate) || isDateInRange(plantingDate)
            || isDateInRange(harvestBeginDate) || isDateInRange(harvestEndDate)
            || (plantingDate < seasonDates().first && harvestEndDate > seasonDates().second))
            && (!m_showActivePlantings
                || (sowingDate.weekNumber() <= m_week && m_week <= harvestEndDate.weekNumber()))
            && (!m_showOnlyUnassigned || length > planting->assignedLength(plantingId))
            && (!m_showOnlyGreenhouse || inGreenhouse) && (!m_showOnlyField || !inGreenhouse)
            && (!m_showOnlyHarvested
                || (harvestBeginDate.weekNumber() <= m_week && m_week <= harvestEndDate.weekNumber()))
            && (m_showFinished || !isFinished) && (m_cropId < 1 || cropId == m_cropId)
            && (m_keywordId < 1
                || Helpers::listOfInt(sourceRowValue(sourceRow, sourceParent, "keyword_ids").toString())
                           .contains(m_keywordId))
            && QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
