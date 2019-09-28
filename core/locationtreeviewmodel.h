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

#ifndef LOCATIONTREEVIEWMODEL_H
#define LOCATIONTREEVIEWMODEL_H

#include <QObject>
#include <QMap>

#include "core_global.h"
#include "treeviewmodel.h"
#include "qquicktreemodeladaptor.h"

class LocationModel;
class Location;

class CORESHARED_EXPORT LocationTreeViewModel : public QQuickTreeModelAdaptor
{
    Q_OBJECT

    Q_PROPERTY(bool showOnlyGreenhouseLocations READ showOnlyGreenhouseLocations WRITE
                       setShowOnlyGreenhouseLocations NOTIFY showOnlyGreenhouseLocationsChanged)
    Q_PROPERTY(int depth READ depth NOTIFY depthChanged)
    Q_PROPERTY(int rowCount READ rowCount() NOTIFY countChanged)
    Q_PROPERTY(int year READ filterYear() WRITE setFilterYear NOTIFY filterYearChanged)
    Q_PROPERTY(int season READ filterSeason() WRITE setFilterSeason NOTIFY filterSeasonChanged)
    Q_PROPERTY(int contentHeight READ contentHeight() NOTIFY contentHeightChanged)

public:
    enum { NonOverlappingPlantingList = 300, TaskList, History, ConflictList };

    explicit LocationTreeViewModel(QObject *parent = nullptr);
    QVariant data(const QModelIndex &proxyIndex, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool showOnlyGreenhouseLocations() const;
    void setShowOnlyGreenhouseLocations(bool show);

    int filterYear() const;
    void setFilterYear(int year);

    int filterSeason() const;
    void setFilterSeason(int season);

    int depth() const;
    int contentHeight();

    Q_INVOKABLE void addPlanting(int row, int plantingId, qreal length);
    Q_INVOKABLE void reload();
    Q_INVOKABLE void refreshTree();

    Q_INVOKABLE void updateSelectedLocations(const QVariantMap &map);
    Q_INVOKABLE bool addLocations(const QString &baseName, int length, double width, int quantity,
                                  bool greenhouse);
    //    Q_INVOKABLE void selectAll();
    //    Q_INVOKABLE void unselectAll();

signals:
    void showOnlyGreenhouseLocationsChanged();
    void depthChanged();
    void countChanged();
    void filterYearChanged();
    void filterSeasonChanged();
    void contentHeightChanged();

private:
    bool buildNonOverlapPlantingMap();
    bool buildNonOverlapTaskMap();
    void buildHistoryDescriptionMap();
    QList<QModelIndex> selectedIndexList() const;

    LocationModel *m_locationModel;
    Location *m_location;
    QMap<int, QList<QVariant>> m_nonOverlapPlantingMap;
    QMap<int, QList<QVariant>> m_nonOverlapTaskMap;
    QMap<int, QString> m_historyDescriptionMap;

private slots:
    void rebuildAndRefresh();
    void onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight);
};

#endif // LOCATIONTREEVIEWMODEL_H
