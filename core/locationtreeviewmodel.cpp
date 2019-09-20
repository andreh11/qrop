#include "locationtreeviewmodel.h"
#include "locationmodel.h"
#include "location.h"
#include "mdate.h"

LocationTreeViewModel::LocationTreeViewModel(QObject *parent)
    : TreeViewModel(parent)
    , m_locationModel(new LocationModel(this))
    , m_location(new Location(this))
{
    setSourceModel(m_locationModel);

    auto pair = MDate::seasonDates(filterSeason(), filterYear());
    m_nonOverlapMap = m_location->allNonOverlappingPlantingList(pair.first, pair.second);

    connect(m_locationModel, &LocationModel::showOnlyGreenhouseLocationsChanged, this,
            &LocationTreeViewModel::showOnlyGreenhouseLocationsChanged);
    connect(m_locationModel, &LocationModel::depthChanged, this, &LocationTreeViewModel::depthChanged);
    connect(m_locationModel, &LocationModel::countChanged, this, &LocationTreeViewModel::countChanged);

    connect(m_locationModel, &LocationModel::filterYearChanged, this,
            &LocationTreeViewModel::filterYearChanged);
    connect(m_locationModel, &LocationModel::filterSeasonChanged, this,
            &LocationTreeViewModel::filterSeasonChanged);

    connect(this, &LocationTreeViewModel::filterYearChanged, &LocationTreeViewModel::buildNonOverlapMap);
    connect(this, &LocationTreeViewModel::filterSeasonChanged,
            &LocationTreeViewModel::buildNonOverlapMap);

    connect(this, SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &)), this,
            SLOT(onDataChanged(const QModelIndex &, const QModelIndex &)));
    connect(this, SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &)), this,
            SIGNAL(contentHeightChanged()));
}

bool LocationTreeViewModel::showOnlyGreenhouseLocations() const
{
    Q_ASSERT(m_locationModel);
    return m_locationModel->showOnlyEmptyLocations();
}

void LocationTreeViewModel::setShowOnlyGreenhouseLocations(bool show)
{
    Q_ASSERT(m_locationModel);
    m_locationModel->setShowOnlyGreenhouseLocations(show);
}

int LocationTreeViewModel::filterYear() const
{
    Q_ASSERT(m_locationModel);
    return m_locationModel->filterYear();
}

void LocationTreeViewModel::setFilterYear(int year)
{
    Q_ASSERT(m_locationModel);
    m_locationModel->setFilterYear(year);
}

int LocationTreeViewModel::filterSeason() const
{
    Q_ASSERT(m_locationModel);
    return m_locationModel->filterSeason();
}

void LocationTreeViewModel::setFilterSeason(int year)
{
    Q_ASSERT(m_locationModel);
    m_locationModel->setFilterSeason(year);
}

int LocationTreeViewModel::depth() const
{
    Q_ASSERT(m_locationModel);
    return m_locationModel->depth();
}

int LocationTreeViewModel::contentHeight() const
{
    int height = 0;
    for (int row = 0; row < rowCount(); ++row) {
        auto idx = index(row);
        if (!data(idx, Hidden).toBool()) {
            int plantingId = data(idx, Qt::UserRole).toInt();
            const auto item = m_nonOverlapMap.constFind(plantingId);
            if (item != m_nonOverlapMap.cend())
                height += item.value().count();
            else
                height += 1;
        }
    }
    return height;
}

QVariant LocationTreeViewModel::data(const QModelIndex &proxyIndex, int role) const
{
    switch (role) {
    case NonOverlappingPlantingList: {
        int locationId = TreeViewModel::data(proxyIndex, Qt::UserRole).toInt();
        const auto item = m_nonOverlapMap.constFind(locationId);
        if (item == m_nonOverlapMap.constEnd())
            return QVariantList();
        return item.value();
    }
    default:
        return TreeViewModel::data(proxyIndex, role);
    }
}

QHash<int, QByteArray> LocationTreeViewModel::roleNames() const
{
    auto names = TreeViewModel::roleNames();
    names[NonOverlappingPlantingList] = "nonOverlappingPlantingList";
    return names;
}

void LocationTreeViewModel::onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight)
{
    if (topLeft != bottomRight)
        return;

    auto pair = MDate::seasonDates(filterSeason(), filterYear());
    int locationId = TreeViewModel::data(topLeft, Qt::UserRole).toInt();
    m_nonOverlapMap[locationId] =
            m_location->nonOverlappingPlantingList(locationId, pair.first, pair.second);
}

void LocationTreeViewModel::buildNonOverlapMap()
{
    auto pair = MDate::seasonDates(filterSeason(), filterYear());
    m_nonOverlapMap = m_location->allNonOverlappingPlantingList(pair.first, pair.second);
    emit dataChanged(index(0), index(rowCount() - 1), { NonOverlappingPlantingList });
}
