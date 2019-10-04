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

#ifndef LOCATIONMODEL_H
#define LOCATIONMODEL_H

#include <QObject>
#include <QItemSelection>

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
    Q_PROPERTY(bool showOnlyGreenhouseLocations READ showOnlyGreenhouseLocations WRITE
                       setShowOnlyGreenhouseLocations NOTIFY showOnlyGreenhouseLocationsChanged)
    Q_PROPERTY(int depth READ depth NOTIFY depthChanged)

public:
    enum {
        NonOverlappingPlantingList = Qt::UserRole + 300,
        TaskList,
        History,
        RotationConflictList,
        SpaceConflictList
    };
    LocationModel(QObject *parent = nullptr, const QString &tableName = "location");
    QVariant data(const QModelIndex &proxyIndex, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE int locationId(const QModelIndex &idx) const;
    Q_INVOKABLE qreal length(const QModelIndex &index) const;

    Q_INVOKABLE void refresh() override;
    Q_INVOKABLE void refreshIndex(const QModelIndex &index);
    Q_INVOKABLE void refreshTree(const QModelIndex &root = QModelIndex());

    Q_INVOKABLE QVariantList plantings(int locationId, int season, int year) const;
    Q_INVOKABLE QVariantList plantings(const QModelIndex &index, int season, int year) const;
    Q_INVOKABLE QVariantList plantings(const QModelIndex &index) const;
    Q_INVOKABLE QVariantList tasks(const QModelIndex &index, int season, int year) const;
    Q_INVOKABLE QVariantList tasks(const QModelIndex &index) const;

    Q_INVOKABLE qreal availableSpace(const QModelIndex &index, const QDate &plantingDate,
                                     const QDate &endHarvestDate) const;
    Q_INVOKABLE bool acceptPlanting(const QModelIndex &index, const QDate &plantingDate,
                                    const QDate &endHarvestDate) const;
    Q_INVOKABLE bool acceptPlanting(const QModelIndex &index, int plantingId) const;
    Q_INVOKABLE bool rotationRespected(const QModelIndex &index, int plantingId) const;

    Q_INVOKABLE QVariantList rotationConflictingPlantings(const QModelIndex &index) const;

    Q_INVOKABLE QString historyDescription(const QModelIndex &index) const;
    Q_INVOKABLE QVariantList nonOverlappingPlantingList(const QModelIndex &index) const;
    Q_INVOKABLE QVariantList nonOverlappingTaskList(const QModelIndex &index) const;

    Q_INVOKABLE QString rotationConflictingDescription(const QModelIndex &index) const;
    Q_INVOKABLE bool hasRotationConflict(const QModelIndex &index) const;
    Q_INVOKABLE QVariantMap spaceConflictingPlantings(const QModelIndex &index) const;
    Q_INVOKABLE bool hasSpaceConflict(const QModelIndex &index) const;

    Q_INVOKABLE qreal plantingLength(int plantingId, const QModelIndex &index) const;
    Q_INVOKABLE void addPlanting(const QModelIndex &idx, int plantingId, qreal length);
    Q_INVOKABLE bool addLocations(const QString &baseName, int length, double width, int quantity,
                                  bool greenhouse,
                                  const QModelIndexList &parentList = { QModelIndex() });
    Q_INVOKABLE bool duplicateLocations(const QModelIndexList &indexList);
    Q_INVOKABLE bool updateIndexes(const QVariantMap &map, const QModelIndexList &indexList);
    Q_INVOKABLE bool removeIndexes(const QModelIndexList &indexList);
    Q_INVOKABLE QModelIndexList treeIndexes(int depth = -1, bool includeParent = true) const;
    Q_INVOKABLE int depth() const;

    Q_INVOKABLE void selectTree(QItemSelectionModel &selectionModel);
    Q_INVOKABLE QItemSelection treeSelection(const QModelIndex &root = QModelIndex()) const;
    Q_INVOKABLE QModelIndexList treeHasIds(const QVariantList &idList) const;
    Q_INVOKABLE QModelIndexList treePath(const QModelIndex &index) const;

    bool showOnlyEmptyLocations() const;
    void setShowOnlyEmptyLocations(bool show);

    bool showOnlyGreenhouseLocations() const;
    void setShowOnlyGreenhouseLocations(bool show);

signals:
    void showOnlyEmptyLocationsChanged();
    void showOnlyGreenhouseLocationsChanged();
    void depthChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    QVariant sourceRowValue(int row, const QModelIndex &parent, const QString &field) const override;

private:
    bool buildNonOverlapPlantingMap();
    bool buildNonOverlapTaskMap();
    bool buildHistoryDescriptionMap();
    bool buildRotationConflictMap();

    bool m_showOnlyEmptyLocations { false };
    bool m_showOnlyGreenhouseLocations { false };

    SqlTreeModel *m_treeModel;
    Planting *m_planting;
    Location *m_location;

    QMap<int, QList<QVariant>> m_nonOverlapPlantingMap;
    QMap<int, QList<QVariant>> m_nonOverlapTaskMap;
    QMap<int, QString> m_historyDescriptionMap;
    QMap<int, QVariantList> m_rotationConflictMap;

private slots:
    void rebuildAndRefresh();
    void onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight);
};

#endif // LOCATIONMODEL_H
