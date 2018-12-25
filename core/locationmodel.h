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

#ifndef LOCATIONMODEL_H
#define LOCATIONMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class Planting;
class Location;
class SqlTreeModel;

class CORESHARED_EXPORT LocationModel : public SortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(bool showOnlyEmptyLocations READ showOnlyEmptyLocations WRITE
                       setShowOnlyEmptyLocations NOTIFY showOnlyEmptyLocationsChanged)

public:
    LocationModel(QObject *parent = nullptr, const QString &tableName = "location");
    Q_INVOKABLE QVariantList plantings(const QModelIndex &index, int season, int year) const;
    Q_INVOKABLE QVariantList plantings(const QModelIndex &index) const;
    Q_INVOKABLE int locationId(const QModelIndex &index) const;
    Q_INVOKABLE void refreshIndex(const QModelIndex &index) { emit dataChanged(index, index); }
    Q_INVOKABLE bool acceptPlanting(const QModelIndex &index, int plantingId) const;
    Q_INVOKABLE bool rotationRespected(const QModelIndex &index, int plantingId) const;
    Q_INVOKABLE QList<int> conflictingPlantings(const QModelIndex &index, int season, int year) const;
    Q_INVOKABLE bool hasRotationConflict(const QModelIndex &index, int season, int year) const;

    Q_INVOKABLE void addPlanting(const QModelIndex &index, int plantingId, int length) const;

    Q_INVOKABLE bool addLocations(const QString &baseName, int length, int width, int quantity,
                                  const QModelIndexList &parentList = { QModelIndex() });
    Q_INVOKABLE bool duplicateLocations(const QModelIndexList &indexList);
    Q_INVOKABLE bool updateIndexes(const QVariantMap &map, const QModelIndexList &indexList);
    Q_INVOKABLE bool removeIndexes(const QModelIndexList &indexList);

    bool showOnlyEmptyLocations() const;
    void setShowOnlyEmptyLocations(bool show);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

signals:
    void showOnlyEmptyLocationsChanged();

private:
    bool m_showOnlyEmptyLocations;
    SqlTreeModel *m_treeModel;
    Planting *planting;
    Location *location;
};

#endif // LOCATIONMODEL_H
