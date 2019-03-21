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

#ifndef VARIETYMODEL_H
#define VARIETYMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT VarietyModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int cropId READ cropId WRITE setFilterCropId NOTIFY cropIdChanged)

public:
    explicit VarietyModel(QObject *parent = nullptr, const QString &tableName = "variety_view");
    int cropId() const;
    void setFilterCropId(int cropId);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

signals:
    void cropIdChanged();

private:
    int m_cropId;
};

#endif // VARIETYMODEL_H
