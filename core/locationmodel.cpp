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

QVariantList LocationModel::plantings(const QModelIndex &index, int season, int year) const
{
    if (!index.isValid())
        return {};

    int lid = locationId(index);
    QVariantList list;
    QPair<QDate, QDate> dates = seasonDates(season, year);
    for (int id : location->plantings(lid, dates.first, dates.second))
        list.push_back(id);
    return list;
}

QVariantList LocationModel::plantings(const QModelIndex &index) const
{
    return plantings(index, m_season, m_year);
}

void LocationModel::addPlanting(const QModelIndex &index, int plantingId, int length) const
{
    if (!index.isValid())
        return;
    if (length < 1)
        return;

    QPair<QDate, QDate> dates = seasonDates();
    int lid = locationId(index);
    location->addPlanting(plantingId, lid, length, dates.first, dates.second);
}

int LocationModel::availableSpace(const QModelIndex &index, const QDate &plantingDate,
                                  const QDate &endHarvestDate) const
{
    if (!index.isValid())
        return false;

    int lid = locationId(index);
    QVariantList list;
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
    QVariantList list;
    QPair<QDate, QDate> dates = seasonDates();

    return location->availableSpace(lid, plantingDate, endHarvestDate, dates.first, dates.second) > 0;
}

/*! Returns true if there is some space left for the planting \a plantingId. */
bool LocationModel::acceptPlanting(const QModelIndex &index, int plantingId) const
{
    if (!index.isValid())
        return false;

    int lid = locationId(index);
    QVariantList list;
    QPair<QDate, QDate> dates = seasonDates();

    return location->availableSpace(lid, plantingId, dates.first, dates.second) > 0;
}

/*! Returns true if the planting \a plantingId respects the rotation. */
bool LocationModel::rotationRespected(const QModelIndex &index, int plantingId) const
{
    if (!index.isValid())
        return false;

    const int lid = locationId(index);
    return location->conflictingPlantings(lid, plantingId).count() == 0;
}

/*! Returns a map such as map[id] is a list of all plantings conflicting
 * with planting id on the location represented by \a index. */
QList<int> LocationModel::conflictingPlantings(const QModelIndex &index, int season, int year) const
{
    if (!index.isValid())
        return {};

    const int lid = locationId(index);
    QPair<QDate, QDate> dates = seasonDates(season, year);
    QList<int> plantingIdList = location->plantings(lid, dates.first, dates.second);
    QList<int> list;
    for (const int pid : plantingIdList) {
        auto conflictList = location->conflictingPlantings(lid, pid);
        if (conflictList.count() > 0)
            list.push_back(pid);
    }
    return list;
}

bool LocationModel::hasRotationConflict(const QModelIndex &index, int season, int year) const
{
    return conflictingPlantings(index, season, year).size() > 0;
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

/*!
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
bool LocationModel::addLocations(const QString &baseName, int length, int width, int quantity,
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
        for (auto key : map.keys())
            tmodel->setData(mapToSource(idx), map.value(key), key);
        dataChanged(idx, idx);
    }

    return true;
}

bool LocationModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (!m_showOnlyEmptyLocations)
        return SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);

    QModelIndex idx = mapFromSource(sourceModel()->index(sourceRow, 0, sourceParent));
    QVariantList plantingIdList = plantings(idx);
    bool isEmpty = plantingIdList.count() == 0;

    return isEmpty && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
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

    return tmodel->removeIndexes(sourceIndexList);
}

/** Return a list of all QModelIndex of location tree. */
QModelIndexList LocationModel::treeIndexes() const
{
    QModelIndex root;
    QModelIndexList treeList;

    for (int row = 0; row < rowCount(root); row++)
        treeList.push_back(index(row, 0, root));

    return treeList;
}

/** Return a list of QModelIndex which ids are in \a idList. Useful for
 *  selecting indexes. */
QModelIndexList LocationModel::treeHasIds(const QVariantList &idList) const
{
    QModelIndexList treeList = treeIndexes();
    QModelIndexList matchIndexes;
    QList<int> intList;

    for (auto val : idList)
        intList.push_back(val.toInt());

    for (int i = 0; i < treeList.count(); i++) {
        QModelIndex idx = treeList[i];
        if (intList.contains(locationId(idx)))
            matchIndexes.push_back(idx);
        for (int row = 0; row < rowCount(idx); row++)
            treeList.push_back(index(row, 0, idx));
    }

    return matchIndexes;
}
