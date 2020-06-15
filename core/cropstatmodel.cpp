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

#include "cropstatmodel.h"
#include <QDate>

CropStatModel::CropStatModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop");
    connect(this, SIGNAL(dataChanged()), this, SIGNAL(revenueChanged()));
    connect(this, SIGNAL(countChanged()), this, SIGNAL(revenueChanged()));
    connect(this, SIGNAL(dataChanged()), this, SIGNAL(fieldLengthChanged()));
    connect(this, SIGNAL(countChanged()), this, SIGNAL(fieldLengthChanged()));
    connect(this, SIGNAL(dataChanged()), this, SIGNAL(greenhouseLengthChanged()));
    connect(this, SIGNAL(countChanged()), this, SIGNAL(greenhouseLengthChanged()));
    connect(this, SIGNAL(dataChanged()), this, SIGNAL(varietyNumberChanged()));
    connect(this, SIGNAL(countChanged()), this, SIGNAL(varietyNumberChanged()));
}

bool CropStatModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int year = sourceRowValue(sourceRow, sourceParent, "year").toInt();
    return ((year == m_year) && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent));
}

int CropStatModel::revenue() const
{
    int revenue = 0;
    for (int row = 0; row < rowCount(); ++row)
        revenue += rowValue(row, "total_revenue").toInt();
    return revenue;
}

qreal CropStatModel::fieldLength() const
{
    return length(false);
}

qreal CropStatModel::greenhouseLength() const
{
    return length(true);
}

qreal CropStatModel::length(bool greenhouse) const
{
    qreal length = 0;
    for (int row = 0; row < rowCount(); ++row) {
        if (greenhouse) {
            length += rowValue(row, "greenhouse_length").toDouble();
        } else {
            length += rowValue(row, "field_length").toDouble();
        }
    }
    return length;
}

int CropStatModel::varietyNumber() const
{
    int varietyNumber = 0;
    for (int row = 0; row < rowCount(); ++row)
        varietyNumber += rowValue(row, "variety_number").toInt();
    return varietyNumber;
}
