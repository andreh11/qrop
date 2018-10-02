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
#include <QDate>
#include <QVector>

#include "plantingmodel.h"
#include "taskmodel.h"
#include "locationmodel.h"
#include "notemodel.h"
#include "keywordmodel.h"
#include "harvestmodel.h"
#include "expensemodel.h"

static const char *plantingTableName = "planting";

PlantingModel::PlantingModel(QObject *parent)
    : QSortFilterProxyModel(parent),
      m_model(new SqlTableModel(this)),
      m_year(QDate::currentDate().year()),
      m_season(1)
{
    m_model->setTable(plantingTableName);
    m_model->setSortColumn("seeding_date", "ascending");

    setSourceModel(m_model);

//    int varietyColumn = fieldColumn("variety_id");
//    setRelation(varietyColumn, QSqlRelation("variety", "variety_id", "variety"));

//    select();
}

QString PlantingModel::filterString() const
{
    return m_string;
}

int PlantingModel::filterYear() const
{
    return m_year;
}

int PlantingModel::filterSeason() const
{
    return m_season;
}

void PlantingModel::setFilterYear(int year)
{
    m_year = year;
    invalidateFilter();
}

void PlantingModel::setFilterSeason(int season)
{
    if (0 <= season && season <= 3)
        m_season = season;
    else
        m_season = 1; // default to Spring

    invalidateFilter();
}

QVector<QDate> PlantingModel::seasonDates() const
{
    switch (m_season) {
    case 0: // Spring
        return {QDate(m_year-1, 10, 1), QDate(m_year, 11, 30)};
    case 2: // Fall
        return {QDate(m_year, 4, 1), QDate(m_year+1, 3, 31)};
    case 3: // Winter
        return {QDate(m_year, 7, 1), QDate(m_year+1, 6, 30)};
    default: // Summer or invalid season
        return {QDate(m_year, 1, 1), QDate(m_year, 12, 31)};
    }
}

QDate PlantingModel::fieldDate(int row, const QModelIndex &parent, const QString &field) const
{
    QModelIndex index = m_model->index(row, 0, parent);
    QString string = m_model->data(index, field).toString();
    return QDate::fromString(string, Qt::ISODate);
}

bool PlantingModel::isDateInRange(const QDate &date) const
{
    QVector<QDate> dates = seasonDates();
    QDate seasonBeg = dates[0];
    QDate seasonEnd = dates[1];

    return seasonBeg <= date && date < seasonEnd;
}

bool PlantingModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QDate sowDate = fieldDate(sourceRow, sourceParent, "sow_date");
    QDate plantDate = fieldDate(sourceRow, sourceParent, "planting_date");
    QDate harvestBegDate = fieldDate(sourceRow, sourceParent, "harvest_beg_date");
    QDate harvestEndDate = fieldDate(sourceRow, sourceParent, "harvest_end_date");

    return (QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent)
            && (isDateInRange(sowDate)
                || isDateInRange(plantDate)
                || isDateInRange(harvestBegDate)
                || isDateInRange(harvestEndDate)));
}

//void PlantingModel::setFilterCrop(const QString &crop)
//{
//   if (crop == m_crop)
//       return;

//   m_crop = crop;

//    if (m_crop == "") {
//        qInfo("[PlantingModel] null filter");
//        setFilter("");
//    } else {
//        const QString filterString = QString::fromLatin1(
//            "(crop LIKE '%%%1%%')").arg(crop);
//        setFilter(filterString);
//    }

//    select();
//    emit cropChanged();
//}
