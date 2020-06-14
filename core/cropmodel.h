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

#ifndef CROPMODEL_H
#define CROPMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT CropModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int familyId READ familyId WRITE setFamilyId NOTIFY familyIdChanged)

public:
    explicit CropModel(QObject *parent = nullptr, const QString &tableName = "crop");
    int familyId() const;
    void setFamilyId(int familyId);

signals:
    void familyIdChanged();

private:
    int m_familyId { -1 };
};

#endif // CROPMODEL_H
