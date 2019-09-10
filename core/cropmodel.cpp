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
#include "cropmodel.h"

CropModel::CropModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop");
    setFilterKeyStringColumn("crop");
}

int CropModel::familyId() const
{
    return m_familyId;
}

void CropModel::setFilterFamilyId(int familyId)
{
    if (familyId == m_familyId)
        return;

    m_familyId = familyId;

    if (m_familyId < 1) {
        qInfo("[CropModel] null filter");

    } else {
        //        setFilterFixedString(QString(familyId));
        const QString filterString = QString::fromLatin1("family_id = %1").arg(familyId);
        m_model->setFilter(filterString);
    }

    emit familyIdChanged();
}
