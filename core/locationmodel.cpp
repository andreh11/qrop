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
#include <QSqlQuery>
#include <QDate>

#include "locationmodel.h"
#include "sqltablemodel.h"
#include "treemodel.h"
#include "location.h"
#include "planting.h"
#include "mdate.h"

LocationModel::LocationModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_showOnlyEmptyLocations(false)
    , m_treeModel(new SqlTreeModel("location_id", "parent_id", this))
    , planting(new Planting(this))
    , location(new Location(this))
{
    setSourceModel(m_treeModel);
    setRecursiveFilteringEnabled(true);
}

int LocationModel::locationId(const QModelIndex &idx) const
{
    if (!idx.isValid())
        return -1;

    /* Here we assume that location_id if on first column. This is a
     * reasonable assumption, but database schema update or API update
     * might break the code...*/
    int id = data(index(idx.row(), 0, idx.parent())).toInt();
    return id;
}

void LocationModel::refresh()
{
    setSourceModel(nullptr);
    delete m_treeModel;
    m_treeModel = new SqlTreeModel("location_id", "parent_id", this);
    setSourceModel(m_treeModel);
    countChanged();
}

/** \brief Emit dataChanged signal for all indexes of the tree. */
void LocationModel::refreshTree()
{
    QModelIndex root;
    QModelIndexList treeList;

    dataChanged(index(0, 0, root), index(rowCount() - 1, 0, root));
    for (int row = 0; row < rowCount(root); row++)
        treeList.push_back(index(row, 0, root));

    for (int i = 0; i < treeList.length(); i++) {
        QModelIndex parent = treeList[i];
        dataChanged(index(0, 0, parent), index(rowCount(parent) - 1, 0, parent));
        for (int row = 0; row < rowCount(parent); row++)
            treeList.push_back(index(row, 0, parent));
    }
}

QVariant LocationModel::rowValue(int row, const QModelIndex &parent, const QString &field) const
{
    if (!m_treeModel)
        return {};

    QModelIndex index = m_treeModel->index(row, 0, parent);
    if (!index.isValid())
        return {};

    return m_treeModel->data(index, field);
}

QVariantList LocationModel::plantings(const QModelIndex &index, int season, int year) const
{
    if (!index.isValid())
        return {};

    int lid = locationId(index);
    QVariantList list;
    QPair<QDate, QDate> dates = MDate::seasonDates(season, year);
    for (int id : location->plantings(lid, dates.first, dates.second))
        list.push_back(id);
    return list;
}

QVariantList LocationModel::plantings(const QModelIndex &index) const
{
    return plantings(index, m_season, m_year);
}

void LocationModel::addPlanting(const QModelIndex &idx, int plantingId, int length)
{
    if (!idx.isValid())
        return;
    if (length < 1)
        return;

    QPair<QDate, QDate> dates = seasonDates();
    if (hasChildren(idx)) {
        int l = length;
        int row = 0;
        for (; row < rowCount(idx) && l > 0; row++) {
            QModelIndex child = index(row, 0, idx);
            if (!hasChildren(child)) {
                int lid = locationId(child);
                l -= location->addPlanting(plantingId, lid, length, dates.first, dates.second);
            }
        }
        dataChanged(index(0, 0, idx), index(row - 1, 0, idx));
    } else {
        int lid = locationId(idx);
        location->addPlanting(plantingId, lid, length, dates.first, dates.second);
        refreshIndex(idx);
    }
}

int LocationModel::availableSpace(const QModelIndex &index, const QDate &plantingDate,
                                  const QDate &endHarvestDate) const
{
    if (!index.isValid())
        return false;

    int lid = locationId(index);
    QPair<QDate, QDate> dates = seasonDates();

    return location->availableSpace(lid, plantingDate, endHarvestDate, dates.first, dates.second);
}

/*! Returns true if there is some space left for the planting \a plantingId. */
bool LocationModel::acceptPlanting(const QModelIndex &index, const QDate &plantingDate,
                                   const QDate &endHarvestDate) const
{
    if (!index.isValid())
        return false;

    int lid = locationId(index);
    QPair<QDate, QDate> dates = seasonDates();

    return location->availableSpace(lid, plantingDate, endHarvestDate, dates.first, dates.second) > 0;
}

/*! Returns true if there is some space left for the planting \a plantingId. */
bool LocationModel::acceptPlanting(const QModelIndex &index, int plantingId) const
{
    if (!index.isValid())
        return false;

    int lid = locationId(index);
    QPair<QDate, QDate> dates = seasonDates();

    return location->availableSpace(lid, plantingId, dates.first, dates.second) > 0;
}

/*! Returns true if the planting \a plantingId respects the rotation. */
bool LocationModel::rotationRespected(const QModelIndex &index, int plantingId) const
{
    if (!index.isValid())
        return false;

    const int lid = locationId(index);
    return location->rotationConflictingPlantings(lid, plantingId).count() == 0;
}

/**
 * \brief Returns a list all plantings conflicting on the location represented
 * by \a index for the given \a season of \a year because they don't respect the
 * family rotation interval.
 */
QList<int> LocationModel::rotationConflictingPlantings(const QModelIndex &index, int season, int year) const
{
    if (!index.isValid())
        return {};

    const int lid = locationId(index);
    QPair<QDate, QDate> dates = MDate::seasonDates(season, year);
    QList<int> plantingIdList = location->plantings(lid, dates.first, dates.second);
    QList<int> list;
    for (const int pid : plantingIdList) {
        auto conflictList = location->rotationConflictingPlantings(lid, pid);
        if (conflictList.count() > 0)
            list.push_back(pid);
    }
    return list;
}

/*! Returns a map such as map[id] is a list of all plantings conflicting
    with planting id on the location represented by \a index because they
    don't observe the family rotation interval.
*/
QVariantMap LocationModel::spaceConflictingPlantings(const QModelIndex &index, int season, int year) const
{
    if (!index.isValid())
        return {};

    const int lid = locationId(index);
    QPair<QDate, QDate> dates = MDate::seasonDates(season, year);
    return location->spaceConflictingPlantings(lid, dates.first, dates.second);
}

bool LocationModel::hasRotationConflict(const QModelIndex &index, int season, int year) const
{
    return !rotationConflictingPlantings(index, season, year).empty();
}

bool LocationModel::hasSpaceConflict(const QModelIndex &index, int season, int year) const
{
    return !spaceConflictingPlantings(index, season, year).empty();
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
                                 const QModelIndexList &parentList)
{
    // TODO: This is ugly, we should redesign the class hierarchy.
    auto tmodel = dynamic_cast<SqlTreeModel *>(sourceModel());

    int parentId = -1;
    QString parentIdString;
    int newId;
    QSqlDatabase::database().transaction();

    // Check if baseName represents an integer.
    bool isInt;
    int baseInt = baseName.toInt(&isInt);

    QString name;
    for (auto parent : parentList) {
        parentId = data(index(parent.row(), 0, parent.parent()), 0).toInt();
        parentIdString = parentId > 0 ? QString::number(parentId) : QString();
        for (int i = 0; i < quantity; i++) {
            if (isInt)
                name = QString::number(baseInt + i);
            else if (baseName.back().unicode() + i < 'Z')
                name = baseName.chopped(1) + QString(baseName.back().unicode() + i);
            else
                name = baseName + " " + QString::number(i);

            newId = location->add({ { "bed_length", length },
                                    { "bed_width", width },
                                    { "parent_id", parentIdString },
                                    { "name", name } });
            tmodel->addRecord(location->recordFromId("location", newId), mapToSource(parent));
        }
    }
    QSqlDatabase::database().commit();
    depthChanged();

    return true;
}

/*!
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

    for (auto idx : indexList) {
        id = data(index(idx.row(), 0, idx.parent()), 0).toInt();
        newId = location->duplicate(id);
        QList<QSqlRecord> recordList;
        recordList.push_back(location->recordFromId("location", newId));
        for (int childrenId : location->childrenTree(newId))
            recordList.push_back(location->recordFromId("location", childrenId));
        tmodel->addRecordTree(recordList, mapToSource(idx.parent()));
    }

    return true;
}

bool LocationModel::updateIndexes(const QVariantMap &map, const QModelIndexList &indexList)
{
    int id;

    // TODO: This is ugly, we should redesign the class hierarchy.
    auto tmodel = dynamic_cast<SqlTreeModel *>(sourceModel());

    for (auto idx : indexList) {
        id = data(index(idx.row(), 0, idx.parent()), 0).toInt();
        location->update(id, map);
        for (const auto &key : map.keys())
            tmodel->setData(mapToSource(idx), map.value(key), key);
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
        bool isGreenhouse = rowValue(sourceRow, sourceParent, "greenhouse").toInt() == 1;
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
    for (auto &index : indexList) {
        sourceIndexList.push_back(mapToSource(index));
        idList.push_back(data(index, 0).toInt());
    }
    location->removeList(idList);

    depthChanged();
    return tmodel->removeIndexes(sourceIndexList);
}

/*!
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
            if (indexDepth[idx] < depth)
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

/** Return a list of all QModelIndex of location tree. */
QItemSelection LocationModel::treeSelection() const
{
    QModelIndex root;
    QModelIndexList treeList;
    QItemSelection selection;

    for (int row = 0; row < rowCount(root); row++)
        treeList.push_back(index(row, 0, root));
    QItemSelection rootSelection(index(0, 0, root), index(rowCount() - 1, 0, root));
    selection.merge(rootSelection, QItemSelectionModel::Select);

    for (int i = 0; i < treeList.length(); i++) {
        QModelIndex parent = treeList[i];
        QItemSelection sel(index(0, 0, parent), index(rowCount(parent) - 1, 0, parent));
        selection.merge(sel, QItemSelectionModel::Select);
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

/** Return a list of QModelIndex which ids are in \a idList. Useful for
 *  selecting indexes. */
QModelIndexList LocationModel::treeHasIds(const QVariantList &idList) const
{
    QModelIndexList treeList = treeIndexes();
    QModelIndexList matchIndexes;
    QList<int> intList;

    for (const auto &val : idList)
        intList.push_back(val.toInt());

    for (int i = 0; i < treeList.count(); i++) {
        QModelIndex idx = treeList[i];
        if (intList.contains(locationId(idx)))
            matchIndexes.push_back(idx);
    }

    return matchIndexes;
}
