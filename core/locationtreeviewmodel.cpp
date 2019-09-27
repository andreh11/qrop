#include "locationtreeviewmodel.h"
#include "locationmodel.h"
#include "location.h"
#include "mdate.h"

LocationTreeViewModel::LocationTreeViewModel(QObject *parent)
    : QQuickTreeModelAdaptor(parent)
    , m_locationModel(new LocationModel(this))
    , m_location(new Location(this))
{
    setModel(m_locationModel);
    rebuildAndRefresh();

    connect(m_locationModel, &LocationModel::showOnlyGreenhouseLocationsChanged, this,
            &LocationTreeViewModel::showOnlyGreenhouseLocationsChanged);
    connect(m_locationModel, &LocationModel::depthChanged, this, &LocationTreeViewModel::depthChanged);
    connect(m_locationModel, &LocationModel::countChanged, this, &LocationTreeViewModel::countChanged);

    connect(m_locationModel, &LocationModel::filterYearChanged, this,
            &LocationTreeViewModel::filterYearChanged);
    connect(m_locationModel, &LocationModel::filterSeasonChanged, this,
            &LocationTreeViewModel::filterSeasonChanged);

    connect(this, &LocationTreeViewModel::filterYearChanged, &LocationTreeViewModel::rebuildAndRefresh);
    connect(this, &LocationTreeViewModel::filterSeasonChanged,
            &LocationTreeViewModel::rebuildAndRefresh);

    connect(this, SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &)), this,
            SLOT(onDataChanged(const QModelIndex &, const QModelIndex &)));
    connect(this, SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &)), this,
            SIGNAL(contentHeightChanged()));
}

void LocationTreeViewModel::rebuildAndRefresh()
{
    buildNonOverlapPlantingMap();
    buildHistoryDescriptionMap();
    emit dataChanged(index(0), index(rowCount() - 1));
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

int LocationTreeViewModel::contentHeight()
{
    int height = 0;
    for (int row = 0; row < rowCount(); ++row) {
        auto idx = index(row);
        if (!isVisible(idx)) {
            int plantingId = data(idx, Qt::UserRole).toInt();
            const auto item = m_nonOverlapPlantingMap.constFind(plantingId);
            if (item != m_nonOverlapPlantingMap.cend())
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
        int locationId = QQuickTreeModelAdaptor::data(proxyIndex, Qt::UserRole).toInt();
        const auto item = m_nonOverlapPlantingMap.constFind(locationId);
        if (item == m_nonOverlapPlantingMap.constEnd())
            return QVariantList();
        return item.value();
    }
    case TaskList: {
        int locationId = QQuickTreeModelAdaptor::data(proxyIndex, Qt::UserRole).toInt();
        const auto item = m_nonOverlapTaskMap.constFind(locationId);
        if (item == m_nonOverlapTaskMap.constEnd())
            return QVariantList();
        return item.value();
    }
    case History: {
        int locationId = QQuickTreeModelAdaptor::data(proxyIndex, Qt::UserRole).toInt();
        const auto item = m_historyDescriptionMap.constFind(locationId);
        if (item == m_historyDescriptionMap.constEnd())
            return "";
        return item.value();
    }
    default:
        return QQuickTreeModelAdaptor::data(proxyIndex, role);
    }
}

QHash<int, QByteArray> LocationTreeViewModel::roleNames() const
{
    auto names = QQuickTreeModelAdaptor::roleNames();
    names[NonOverlappingPlantingList] = "nonOverlappingPlantingList";
    names[TaskList] = "taskList";
    names[History] = "history";
    return names;
}

void LocationTreeViewModel::onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight)
{
    if (topLeft != bottomRight) {
        if (buildNonOverlapPlantingMap()) {
            buildHistoryDescriptionMap();
            emit dataChanged(topLeft, bottomRight, { NonOverlappingPlantingList, TaskList, History });
        }
        return;
    }

    auto pair = MDate::seasonDates(filterSeason(), filterYear());
    int locationId = QQuickTreeModelAdaptor::data(topLeft, Qt::UserRole).toInt();
    auto newList = m_location->nonOverlappingPlantingList(locationId, pair.first, pair.second);
    if (m_nonOverlapPlantingMap[locationId] == newList)
        return;

    m_nonOverlapPlantingMap[locationId] = newList;

    // NOTE: Update task list. Because we are lazy, and because it costs only 1-2 ms,
    // we rebuild the whole map. But it would be possible to only update the relevant
    // location.
    auto dates = MDate::seasonDates(filterSeason(), filterYear());
    m_nonOverlapTaskMap =
            m_location->allNonOverlappingTaskList(m_nonOverlapPlantingMap, dates.first, dates.second);

    // NOTE: Same here, we could optimize.
    buildHistoryDescriptionMap();

    // I don't understand why, but it is not necessary to emit a new signal.
    // emit dataChanged(topLeft, bottomRight, { NonOverlappingPlantingList, TaskList });
}

bool LocationTreeViewModel::buildNonOverlapPlantingMap()
{
    auto dates = MDate::seasonDates(filterSeason(), filterYear());
    auto newMap = m_location->allNonOverlappingPlantingList(dates.first, dates.second);
    if (m_nonOverlapPlantingMap == newMap)
        return false;

    m_nonOverlapPlantingMap = newMap;
    m_nonOverlapTaskMap =
            m_location->allNonOverlappingTaskList(m_nonOverlapPlantingMap, dates.first, dates.second);

    return true;
}

void LocationTreeViewModel::addPlanting(int row, int plantingId, qreal length)
{
    return;
    //    auto idx = mapToSource(index(row));
    //    m_locationModel->addPlanting(idx, plantingId, length);
}

void LocationTreeViewModel::buildHistoryDescriptionMap()
{
    m_historyDescriptionMap = m_location->allHistoryDescription(filterSeason(), filterYear());
}

void LocationTreeViewModel::reload()
{
    m_locationModel->refresh();
}

void LocationTreeViewModel::refreshTree()
{
    emit dataChanged(index(0), index(rowCount() - 1));
}

QList<QModelIndex> LocationTreeViewModel::selectedIndexList() const
{
    QList<QModelIndex> indexList;
    for (int row = 0; row < rowCount(); ++row) {
        auto idx = index(row);
        //        if (data(idx, Selected).toBool()) {
        //            indexList.append(mapToSource(idx));
        //            qDebug() << mapToSource(idx).model();
        //        }
    }
    return indexList;
}

void LocationTreeViewModel::updateSelectedLocations(const QVariantMap &map)
{
    m_locationModel->updateIndexes(map, selectedIndexList());
}

bool LocationTreeViewModel::addLocations(const QString &baseName, int length, double width,
                                         int quantity, bool greenhouse)
{
    auto list = selectedIndexList();
    bool ret = false;
    if (list.isEmpty())
        ret = m_locationModel->addLocations(baseName, length, width, quantity, greenhouse);
    else
        ret = m_locationModel->addLocations(baseName, length, width, quantity, greenhouse, list);
    reload();
    return ret;
}
