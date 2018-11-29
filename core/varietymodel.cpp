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
#include "sqltablemodel.h"
#include "varietymodel.h"

VarietyModel::VarietyModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_cropId(-1)
{
    setFilterCropId(1);
    setFilterKeyColumn(2);
    setSortColumn("variety");
    //    int cropColumn = fieldColumn("crop_id");
    //    setRelation(cropColumn, QSqlRelation("crop", "crop_id", "crop"));

    //    int seedCompanyColumn = fieldColumn("seed_company_id");
    //    setRelation(seedCompanyColumn, QSqlRelation("seed_company",
    //                                                "seed_company_id",
    //                                                "seed_company"));
    //    select();
}

int VarietyModel::cropId() const
{
    return m_cropId;
}

void VarietyModel::setFilterCropId(int cropId)
{
    if (cropId == m_cropId)
        return;

    m_cropId = cropId;

    if (m_cropId < 1) {
        qInfo("[VarietyModel] null filter");

    } else {
        //        setFilterFixedString(QString(cropId));
        const QString filterString = QString::fromLatin1("crop_id = %1").arg(cropId);
        m_model->setFilter(filterString);
    }

    emit cropIdChanged();
}
