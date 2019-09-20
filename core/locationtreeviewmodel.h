#ifndef LOCATIONTREEVIEWMODEL_H
#define LOCATIONTREEVIEWMODEL_H

#include <QObject>

#include "core_global.h"
#include "treeviewmodel.h"

class LocationModel;
class Location;

class CORESHARED_EXPORT LocationTreeViewModel : public TreeViewModel
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
    enum { NonOverlappingPlantingList = TreeSelected + 1 };
    explicit LocationTreeViewModel(QObject *parent = nullptr);
    QVariant data(const QModelIndex &proxyIndex, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool showOnlyGreenhouseLocations() const;
    void setShowOnlyGreenhouseLocations(bool show);
    int depth() const;

    int filterYear() const;
    int filterSeason() const;
    int contentHeight() const;
    void setFilterYear(int year);
    void setFilterSeason(int season);

private:
    LocationModel *m_locationModel;
    Location *m_location;

    QMap<int, QList<QVariant>> m_nonOverlapMap;
    void buildNonOverlapMap();

private slots:
    void onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight);

signals:
    void showOnlyGreenhouseLocationsChanged();
    void depthChanged();
    void countChanged();
    void filterYearChanged();
    void filterSeasonChanged();
    void contentHeightChanged();
};

#endif // LOCATIONTREEVIEWMODEL_H
