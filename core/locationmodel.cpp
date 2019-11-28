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

#include <QDebug>
#include <QSqlQuery>
#include <QDate>
#include <QElapsedTimer>

#include "locationmodel.h"
#include "sqltablemodel.h"
#include "treemodel.h"
#include "location.h"
#include "planting.h"
#include "mdate.h"
#include "helpers.h"

LocationModel::LocationModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_treeModel(new SqlTreeModel("location_id", "parent_id", this))
    , m_planting(new Planting(this))
    , m_location(new Location(this))
{
    setSourceModel(m_treeModel);
    setRecursiveFilteringEnabled(true);

    //    rebuildAndRefresh();

    connect(this, SIGNAL(filterYearChanged()), this, SLOT(rebuildAndRefresh()));
    connect(this, SIGNAL(filterSeasonChanged()), this, SLOT(rebuildAndRefresh()));
    connect(this, SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &)), this,
            SLOT(onDataChanged(const QModelIndex &, const QModelIndex &)));
}

QVariant LocationModel::data(const QModelIndex &proxyIndex, int role) const
{
    if (!proxyIndex.isValid())
        return {};

    switch (role) {
    case NonOverlappingPlantingList:
        return nonOverlappingPlantingList(proxyIndex);
    case TaskList:
        return nonOverlappingTaskList(proxyIndex);
    case History:
        return historyDescription(proxyIndex);
    case SpaceConflictList:
        return spaceConflictingPlantings(proxyIndex);
    case HasSpaceConflict:
        return hasSpaceConflict(proxyIndex);
    case RotationConflictList:
        return rotationConflictingPlantings(proxyIndex);
    case RotationConflictDescription:
        return rotationConflictingDescription(proxyIndex);
    case HasRotationConflict:
        return hasRotationConflict(proxyIndex);
    case FullName:
        return fullName(proxyIndex);
    default:
        return SortFilterProxyModel::data(proxyIndex, role);
    }
}

QHash<int, QByteArray> LocationModel::roleNames() const
{
    auto names = SortFilterProxyModel::roleNames();
    names[NonOverlappingPlantingList] = "nonOverlappingPlantingList";
    names[TaskList] = "taskList";
    names[History] = "history";
    names[SpaceConflictList] = "spaceConflictList";
    names[HasSpaceConflict] = "hasSpaceConflict";
    names[RotationConflictList] = "rotationConflictList";
    names[RotationConflictDescription] = "rotationConflictDescription";
    names[HasRotationConflict] = "hasRotationConflict";
    names[FullName] = "fullName";
    return names;
}

void LocationModel::refresh()
{
    setSourceModel(nullptr);
    delete m_treeModel;
    m_treeModel = new SqlTreeModel("location_id", "parent_id", this);
    setSourceModel(m_treeModel);
    rebuildAndRefresh();
    emit countChanged();
}

void LocationModel::refreshIndex(const QModelIndex &index)
{
    dataChanged(index, index);
}

/** Emit dataChanged signal for all indexes of the subtree whose root is \a root. */
void LocationModel::refreshTree(const QModelIndex &root)
{
    // Check for empty tree
    if (!root.isValid() && rowCount() == 0)
        return;

    //    QModelIndexList treeList;
    //    treeList.push_back(root);

    emit layoutAboutToBeChanged();
    emit layoutChanged();

    //    QModelIndex parent;
    //    for (int i = 0; i < treeList.length(); ++i) {
    //        parent = treeList[i];
    //        dataChanged(index(0, 0, parent), index(rowCount(parent) - 1, 0, parent));

    //        int count = rowCount(parent);
    //        for (int row = 0; row < count; ++row) {
    //            const QModelIndex child = index(row, 0, parent);
    //            if (hasChildren(child))
    //                treeList.push_back(child);
    //        }
    //    }
}

int LocationModel::locationId(const QModelIndex &idx) const
{
    Q_ASSERT(checkIndex(idx, CheckIndexOption::IndexIsValid));
    // Here we assume that location_id is in the first column. This is a
    // reasonable assumption, but database schema update or API update
    // might break the code...
    int id = data(index(idx.row(), 0, idx.parent())).toInt();
    return id;
}

/** Return the bed length of \a index. */
qreal LocationModel::length(const QModelIndex &index) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    return rowValue(index, "length").toDouble();
}

/** Return the value of \a field for the source index of \a row, \a parent. */
QVariant LocationModel::sourceRowValue(int row, const QModelIndex &parent, const QString &field) const
{
    if (!m_treeModel)
        return {};

    QModelIndex index = m_treeModel->index(row, 0, parent);
    if (!index.isValid())
        return {};

    return m_treeModel->data(index, field);
}

QVariantList LocationModel::plantings(int locationId, int season, int year) const
{
    if (locationId < 0)
        return {};

    QDate beg;
    QDate end;
    std::tie(beg, end) = MDate::seasonDates(season, year);

    QVariantList list;
    for (int id : m_location->plantings(locationId, beg, end))
        list.push_back(id);
    return list;
}

/**
 * \return the plantings of \a index for \a season of \a year.
 *
 * \a index must be valid
 */
QVariantList LocationModel::plantings(const QModelIndex &index, int season, int year) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    int lid = locationId(index);
    return plantings(lid, season, year);
}

QVariantList LocationModel::plantings(const QModelIndex &index) const
{
    return plantings(index, m_season, m_year);
}

/**
 * \return the tasks of \a index for \a season of \a year.
 *
 * \a index must be valid
 */
QVariantList LocationModel::tasks(const QModelIndex &index, int season, int year) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    int lid = locationId(index);
    QDate beg;
    QDate end;
    std::tie(beg, end) = MDate::seasonDates(season, year);

    QVariantList list;
    for (int id : m_location->tasks(lid, beg, end))
        list.push_back(id);
    return list;
}

QVariantList LocationModel::tasks(const QModelIndex &index) const
{
    return tasks(index, m_season, m_year);
}

qreal LocationModel::plantingLength(int plantingId, const QModelIndex &index) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    if (plantingId < 1)
        return 0;

    return m_location->plantingLength(plantingId, locationId(index));
}

void LocationModel::addPlanting(const QModelIndex &idx, int plantingId, qreal length, bool addToSiblings)
{
    Q_ASSERT(checkIndex(idx, CheckIndexOption::IndexIsValid));
    Q_ASSERT(length > 0);
    auto dates = seasonDates();
    if (hasChildren(idx)) {
        qreal l = length;
        int row = 0;
        for (; row < rowCount(idx) && l > 0; row++) {
            const auto child = index(row, 0, idx);
            Q_ASSERT(checkIndex(child, CheckIndexOption::IndexIsValid));
            if (!hasChildren(child)) {
                int lid = locationId(child);
                l -= m_location->addPlanting(plantingId, lid, l, dates.first, dates.second);
            }
        }
        dataChanged(index(0, 0, idx), index(row - 1, 0, idx));
    } else if (addToSiblings) {
        qreal l = length;
        int startRow = idx.row();
        const auto parent = idx.parent();

        int row = startRow;
        for (; row < rowCount(parent) && l > 0; row++) {
            const auto child = index(row, 0, parent);
            if (!hasChildren(child)) {
                int lid = locationId(child);
                l -= m_location->addPlanting(plantingId, lid, l, dates.first, dates.second);
            }
        }
        dataChanged(index(startRow, 0, parent), index(row - 1, 0, parent));
    } else {
        int lid = locationId(idx);
        m_location->addPlanting(plantingId, lid, length, dates.first, dates.second);
        refreshIndex(idx);
    }
}

qreal LocationModel::availableSpace(const QModelIndex &index, const QDate &plantingDate,
                                    const QDate &endHarvestDate) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    int lid = locationId(index);
    auto dates = seasonDates();
    return m_location->availableSpace(lid, plantingDate, endHarvestDate, dates.first, dates.second);
}

/**
 * Return true iff there is some space left for the planting \a plantingId
 * on the location \a index.
 */
bool LocationModel::acceptPlanting(const QModelIndex &index, const QDate &plantingDate,
                                   const QDate &endHarvestDate) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    int lid = locationId(index);
    auto dates = seasonDates();
    return m_location->availableSpace(lid, plantingDate, endHarvestDate, dates.first, dates.second) > 0;
}

/** Return true iff there is some space left for the planting \a plantingId. */
bool LocationModel::acceptPlanting(const QModelIndex &index, int plantingId) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    int lid = locationId(index);
    auto dates = seasonDates();
    return m_location->availableSpace(lid, plantingId, dates.first, dates.second) > 0;
}

/** Returns true iff the planting \a plantingId respects the rotation. */
bool LocationModel::rotationRespected(const QModelIndex &index, int plantingId) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    const int lid = locationId(index);
    return m_location->rotationConflictingPlantings(lid, plantingId).count() == 0;
}

/**
 * Return a list of the ids of the plantings conflicting on the location
 * represented by \a index for the given \a season of \a year because they
 * don't respect the family rotation interval.
 */
QVariantList LocationModel::rotationConflictingPlantings(const QModelIndex &index) const
{
    int id = locationId(index);
    Q_ASSERT(id > 0);

    const auto it = m_rotationConflictMap.constFind(id);
    if (it == m_rotationConflictMap.cend())
        return {};
    return it.value();
}

QString LocationModel::historyDescription(const QModelIndex &index) const
{
    int id = locationId(index);
    Q_ASSERT(id > 0);

    const auto it = m_historyDescriptionMap.constFind(id);
    if (it == m_historyDescriptionMap.cend())
        return {};
    return it.value();
}

QVariantList LocationModel::nonOverlappingPlantingList(const QModelIndex &index) const
{
    int id = locationId(index);
    Q_ASSERT(id > 0);

    const auto it = m_nonOverlapPlantingMap.constFind(id);
    if (it == m_nonOverlapPlantingMap.cend())
        return {};
    return it.value();
}

QVariantList LocationModel::nonOverlappingTaskList(const QModelIndex &index) const
{
    int id = locationId(index);
    Q_ASSERT(id > 0);

    const auto it = m_nonOverlapTaskMap.constFind(id);
    if (it == m_nonOverlapTaskMap.cend())
        return {};
    return it.value();
}

QString LocationModel::rotationConflictingDescription(const QModelIndex &index) const
{
    const auto &list = Helpers::variantToIntList(rotationConflictingPlantings(index));
    auto query = m_location->queryFromIdList("planting_view", list);
    const int lid = locationId(index);
    QString text;
    QList<int> conflictList;
    while (query->next()) {
        text += QString("%1, %2 %3")
                        .arg(query->value("crop").toString())
                        .arg(query->value("variety").toString())
                        .arg(MDate::dateFromIsoString(query->value("planting_date").toString()).year());

        auto q = m_location->queryFromIdList(
                "planting_view",
                m_location->rotationConflictingPlantings(lid, query->value("planting_id").toInt()));
        while (q->next()) {
            text += QString(" ⋅ %1, %2 %3")
                            .arg(q->value("crop").toString())
                            .arg(q->value("variety").toString())
                            .arg(MDate::dateFromIsoString(q->value("planting_date").toString()).year());
        }
        text += "\n";
    }
    text.chop(1);
    return text;
}

/**
 * Return a map such as map[id] is a list of all plantings conflicting
 * with planting id on the location represented by \a index because they
 * don't observe the family rotation interval.
 */
QVariantMap LocationModel::spaceConflictingPlantings(const QModelIndex &index) const
{
    int id = locationId(index);
    Q_ASSERT(id > 0);

    const auto it = m_spaceConflictMap.constFind(id);
    if (it == m_spaceConflictMap.cend())
        return {};
    return it.value();

    //    const int lid = locationId(index);
    //    const auto dates = MDate::seasonDates(m_season, m_year);
    //    return m_location->spaceConflictingPlantings(lid, dates.first, dates.second);
}

bool LocationModel::hasRotationConflict(const QModelIndex &index) const
{
    return !rotationConflictingPlantings(index).empty();
}

bool LocationModel::hasSpaceConflict(const QModelIndex &index) const
{
    return !spaceConflictingPlantings(index).empty();
}

bool LocationModel::showOnlyEmptyLocations() const
{
    return m_showOnlyEmptyLocations;
}

void LocationModel::setShowOnlyEmptyLocations(bool show)
{
    if (show == m_showOnlyEmptyLocations)
        return;

    m_showOnlyEmptyLocations = show;
    invalidateFilter();
    emit showOnlyEmptyLocationsChanged();
}

bool LocationModel::showOnlyGreenhouseLocations() const
{
    return m_showOnlyGreenhouseLocations;
}

void LocationModel::setShowOnlyGreenhouseLocations(bool show)
{
    if (show == m_showOnlyGreenhouseLocations)
        return;

    m_showOnlyGreenhouseLocations = show;
    invalidateFilter();
    emit showOnlyGreenhouseLocationsChanged();
}

QString LocationModel::fullName(const QModelIndex &index) const
{
    return m_location->fullName(locationId(index));
}

/**
 * Insert \a quantity locations of given \a length and \a width, whose parents
 * while be indexes of \a parentList, and generating location names using \a baseName,
 * into database and underlying SqlTreeModel.
 *
 * The \a baseName string can represent:
 * \list
 * \li an integer n: generated names will be subsequent integers ;
 * \li an all uppercase or all lowercase code (A, bb, AA) : generated names
 * will have last character incremented (B, bc, AB)
 * \li a free-from string : an integer will be appended to \a baseName
 * \endlist
 *
 * Returns \c true if all locations can be added, \c false otherwise
 */
bool LocationModel::addLocations(const QString &baseName, int length, double width, int quantity,
                                 bool greenhouse, const QModelIndexList &parentList)
{
    int parentId = -1;
    QString parentIdString;
    int newId;
    QSqlDatabase::database().transaction();

    // Check if baseName represents an integer.
    bool isInt;
    int baseInt = baseName.toInt(&isInt);

    QString name;
    for (const auto &parent : parentList) {
        parentId = data(index(parent.row(), 0, parent.parent()), 0).toInt();
        parentIdString = parentId > 0 ? QString::number(parentId) : QString();
        for (int i = 0; i < quantity; i++) {
            if (isInt)
                name = QString::number(baseInt + i);
            else if (baseName.back().unicode() + i < 'Z')
                name = baseName.chopped(1) + QString(baseName.back().unicode() + i);
            else
                name = baseName + " " + QString::number(i);

            newId = m_location->add({ { "bed_length", length },
                                      { "bed_width", width },
                                      { "parent_id", parentIdString },
                                      { "name", name },
                                      { "greenhouse", greenhouse ? 1 : 0 } });
            m_treeModel->addRecord(m_location->recordFromId("location", newId), mapToSource(parent));
        }
    }
    QSqlDatabase::database().commit();
    refresh();
    emit depthChanged();

    return true;
}

/**
 * Insert duplicates of the locations (and their subtree) represented by
 * \a indexList in database and underlying TreeModel.
 *
 * Returns \c true if all locations can be added, \c false otherwise
 */
bool LocationModel::duplicateLocations(const QModelIndexList &indexList)
{
    int id;
    int newId;

    // TODO: This is ugly, we should redesign the class hierarchy.
    auto tmodel = dynamic_cast<SqlTreeModel *>(sourceModel());

    for (const auto &idx : indexList) {
        Q_ASSERT(checkIndex(idx, CheckIndexOption::IndexIsValid));
        id = data(index(idx.row(), 0, idx.parent()), 0).toInt();
        newId = m_location->duplicate(id);
        QList<QSqlRecord> recordList;
        recordList.push_back(m_location->recordFromId("location", newId));
        for (int childrenId : m_location->childrenTree(newId))
            recordList.push_back(m_location->recordFromId("location", childrenId));
        tmodel->addRecordTree(recordList, mapToSource(idx.parent()));
    }

    return true;
}

bool LocationModel::updateIndexes(const QVariantMap &map, const QModelIndexList &indexList)
{
    int id;

    // TODO: This is ugly, we should redesign the class hierarchy.
    auto tmodel = dynamic_cast<SqlTreeModel *>(sourceModel());

    for (const auto &idx : indexList) {
        Q_ASSERT(checkIndex(idx, CheckIndexOption::IndexIsValid));
        id = data(index(idx.row(), 0, idx.parent()), 0).toInt();
        m_location->update(id, map);

        const auto end = map.cend();
        for (auto it = map.cbegin(); it != end; it++)
            tmodel->setData(mapToSource(idx), it.value(), it.key());
        dataChanged(idx, idx);
    }

    return true;
}

bool LocationModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    bool accept = true;

    if (m_showOnlyEmptyLocations) {
        QModelIndex idx = mapFromSource(m_treeModel->index(sourceRow, 0, sourceParent));
        QVariantList plantingIdList = plantings(idx);
        bool isEmpty = plantingIdList.count() == 0;
        accept = accept && isEmpty;
    }

    if (m_showOnlyGreenhouseLocations) {
        bool isGreenhouse = sourceRowValue(sourceRow, sourceParent, "greenhouse").toInt() == 1;
        accept = accept && isGreenhouse;
    }

    return accept && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}

bool LocationModel::removeIndexes(const QModelIndexList &indexList)
{
    QList<QModelIndex> sourceIndexList;

    // TODO: This is ugly, we should redesign the class hierarchy.
    auto tmodel = dynamic_cast<SqlTreeModel *>(sourceModel());

    QList<int> idList;
    for (const auto &index : indexList) {
        Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
        sourceIndexList.push_back(mapToSource(index));
        idList.push_back(data(index, 0).toInt());
    }
    m_location->removeList(idList);
    emit depthChanged();

    return tmodel->removeIndexes(sourceIndexList);
}

/**
 * Return a list of all QModelIndex of location tree.
 *
 * If \a depth is greater or equal to 0, only indexes of this depth
 * will be return, including their parents if \a includeParent is true.
 */
QModelIndexList LocationModel::treeIndexes(int depth, bool includeParent) const
{
    QModelIndex root;
    QModelIndexList tmpList;
    QModelIndexList indexList;
    QMap<QModelIndex, int> indexDepth;

    for (int row = 0; row < rowCount(root); row++) {
        QModelIndex idx = index(row, 0, root);
        tmpList.push_back(idx);
        indexDepth[idx] = 0;
        if (depth < 0 || indexDepth[idx] == depth || (indexDepth[idx] < depth && includeParent))
            indexList.push_back(idx);
    }

    for (int i = 0; i < tmpList.length(); i++) {
        QModelIndex parent = tmpList[i];
        for (int row = 0; row < rowCount(parent); row++) {
            QModelIndex idx = index(row, 0, parent);
            indexDepth[idx] = indexDepth.value(parent) + 1;
            if (depth < 0 || indexDepth[idx] < depth)
                tmpList.push_back(idx);
            if (depth < 0 || indexDepth[idx] == depth || (indexDepth[idx] < depth && includeParent))
                indexList.push_back(idx);
        }
    }

    return indexList;
}

int LocationModel::depth() const
{
    QModelIndex root;
    QModelIndexList tmpList;
    QMap<QModelIndex, int> indexDepth;
    int d = 0;

    for (int row = 0; row < rowCount(root); row++) {
        QModelIndex idx = index(row, 0, root);
        tmpList.push_back(idx);
        indexDepth[idx] = 0;
    }

    for (int i = 0; i < tmpList.length(); i++) {
        QModelIndex parent = tmpList[i];
        for (int row = 0; row < rowCount(parent); row++) {
            QModelIndex idx = index(row, 0, parent);
            indexDepth[idx] = indexDepth.value(parent) + 1;
            tmpList.push_back(idx);

            if (indexDepth[idx] > d)
                d = indexDepth[idx];
        }
    }

    return d;
}

/**
 * Return a selection of the subtree whose root is \a root.
 *
 * If no root is given, retun the indexes of the whole tree.
 */
QItemSelection LocationModel::treeSelection(const QModelIndex &root) const
{
    QItemSelection selection;
    QModelIndexList treeList;
    treeList.push_back(root);

    QModelIndex parent;
    for (int i = 0; i < treeList.length(); i++) {
        parent = treeList[i];
        selection.merge(QItemSelection(index(0, 0, parent), index(rowCount(parent) - 1, 0, parent)),
                        QItemSelectionModel::Select);
        for (int row = 0; row < rowCount(parent); row++)
            treeList.push_back(index(row, 0, parent));
    }

    return selection;
}

/** Return a list of all QModelIndex of location tree. */
void LocationModel::selectTree(QItemSelectionModel &selectionModel)
{
    QModelIndex root;
    QModelIndexList treeList;

    for (int row = 0; row < rowCount(root); row++)
        treeList.push_back(index(row, 0, root));
    QItemSelection rootSelection(index(0, 0, root), index(rowCount() - 1, 0, root));
    selectionModel.select(rootSelection, QItemSelectionModel::Select);
    //    selectionList.push_back(rootSelection);

    for (int i = 0; i < treeList.length(); i++) {
        QModelIndex parent = treeList[i];
        QItemSelection sel(index(0, 0, parent), index(rowCount(parent) - 1, 0, parent));
        selectionModel.select(sel, QItemSelectionModel::Select);
        for (int row = 0; row < rowCount(parent); row++)
            treeList.push_back(index(row, 0, parent));
    }
}

/**
 * Return a list of QModelIndexes whose ids are in \a idList. Useful for
 * selecting indexes.
 */
QModelIndexList LocationModel::treeHasIds(const QVariantList &idList) const
{
    if (idList.isEmpty())
        return {};

    // Convert the list.
    QList<int> intList;
    for (const auto &val : idList)
        intList.push_back(val.toInt());

    QModelIndexList treeList = treeIndexes();
    QModelIndexList indexList;
    for (int i = 0; i < treeList.count(); i++) {
        QModelIndex idx = treeList[i];
        if (intList.contains(locationId(idx)))
            indexList.push_back(idx);
    }

    return indexList;
}

/**
 * Return the path from root to \a index.
 */
QModelIndexList LocationModel::treePath(const QModelIndex &index) const
{
    QModelIndexList list;
    for (auto p = parent(index); p.isValid(); p = parent(p))
        list.push_back(p);
    return list;
}

/** @return true if the map has changed, false otherwise */
bool LocationModel::buildNonOverlapPlantingMap()
{
    const auto newMap = m_location->allNonOverlappingPlantingList(filterSeason(), filterYear());

    if (m_nonOverlapPlantingMap == newMap)
        return false;

    m_nonOverlapPlantingMap = newMap;

    return true;
}

/** @return true if the map has changed, false otherwise */
bool LocationModel::buildNonOverlapTaskMap()
{
    const auto dates = MDate::seasonDates(filterSeason(), filterYear());
    const auto newMap =
            m_location->allNonOverlappingTaskList(m_nonOverlapPlantingMap, dates.first, dates.second);

    if (m_nonOverlapTaskMap == newMap)
        return false;

    m_nonOverlapTaskMap = newMap;

    return true;
}

/** @return true if the map has changed, false otherwise */
bool LocationModel::buildHistoryDescriptionMap()
{
    const auto newMap = m_location->allHistoryDescription(filterSeason(), filterYear());

    if (m_historyDescriptionMap == newMap)
        return false;

    m_historyDescriptionMap = newMap;
    return true;
}

/** @return true if the map has changed, false otherwise */
bool LocationModel::buildRotationConflictMap()
{
    const auto newMap = m_location->allRotationConflictingPlantings(filterSeason(), filterYear());

    if (m_rotationConflictMap == newMap)
        return false;

    m_rotationConflictMap = newMap;
    return true;
}

/** @return true if the map has changed, false otherwise */
bool LocationModel::buildSpaceConflictMap()
{
    const auto newMap = m_location->allSpaceConflictingPlantings(filterSeason(), filterYear());

    if (m_spaceConflictMap == newMap)
        return false;

    m_spaceConflictMap = newMap;
    return true;
}

/** Rebuild the planting, task and history maps. Refresh the model if needed. */
void LocationModel::rebuildAndRefresh()
{
    QElapsedTimer timer;
    //    timer.start();
    QList<bool> blist;
    blist.push_back(buildNonOverlapPlantingMap());
    //    qDebug() << "[planting]" << timer.elapsed() << "ms";
    //    timer.start();
    blist.push_back(buildNonOverlapTaskMap());
    //    qDebug() << "[task]" << timer.elapsed() << "ms";
    //    timer.start();
    blist.push_back(buildHistoryDescriptionMap());
    //    qDebug() << "[history]" << timer.elapsed() << "ms";
    //    timer.start();
    blist.push_back(buildRotationConflictMap());
    //    qDebug() << "[rotation]" << timer.elapsed() << "ms";
    //    timer.start();
    blist.push_back(buildSpaceConflictMap());
    //    qDebug() << "[space]" << timer.elapsed() << "ms";

    timer.start();
    for (const bool b : blist) {
        if (b) {
            refreshTree();
            break;
        }
    }
    qDebug() << "[REFRESH]" << timer.elapsed() << "ms";
}

void LocationModel::onDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight)
{
    if (topLeft != bottomRight) {
        if (buildNonOverlapPlantingMap()) {
            buildNonOverlapTaskMap();
            buildHistoryDescriptionMap();
            buildRotationConflictMap();
            buildSpaceConflictMap();
            //            emit dataChanged(topLeft, bottomRight,
            //                             { NonOverlappingPlantingList, TaskList, History, RotationConflictList,
            //                               SpaceConflictList });
        }
        return;
    }

    auto pair = MDate::seasonDates(filterSeason(), filterYear());
    int lid = locationId(topLeft);
    auto newList = m_location->nonOverlappingPlantingList(lid, pair.first, pair.second);
    if (m_nonOverlapPlantingMap[lid] == newList)
        return;

    m_nonOverlapPlantingMap[lid] = newList;

    // NOTE: Update task list. Because we are lazy, and because it costs only 1-2 ms,
    // we rebuild the whole map. But it would be possible to only update the relevant
    // location.
    buildNonOverlapTaskMap();

    // NOTE: Same here, we could optimize.
    buildHistoryDescriptionMap();
    buildRotationConflictMap();
    buildSpaceConflictMap();

    // I don't understand why, but it is not necessary to emit a new signal.
    //    qDebug() << "emit";
    //    emit dataChanged(topLeft, bottomRight, { NonOverlappingPlantingList, TaskList, History });
}
