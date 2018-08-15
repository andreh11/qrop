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

#include <QAbstractListModel>

#include "plantingmodel.h"

using namespace std;

PlantingModel::PlantingModel(QObject* parent) :
    QAbstractListModel(parent),
    mDatabase(DatabaseManager::instance()),
    mPlantings(mDatabase.plantingDao.plantings())
{
}

QModelIndex PlantingModel::addPlanting(const Planting& planting)
{
    int rowIndex = rowCount();
    beginInsertRows(QModelIndex(), rowIndex, rowIndex);
    unique_ptr<Planting> newPlanting(new Planting(planting));
    mDatabase.plantingDao.addPlanting(*newPlanting);
    mPlantings->push_back(move(newPlanting));
    endInsertRows();

    return index(rowIndex, 0);
}

int PlantingModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return mPlantings->size();
}

QVariant PlantingModel::data(const QModelIndex& index, int role) const
{
    if (!isIndexValid(index)) {
        return QVariant();
    }

    const Planting& planting = *mPlantings->at(index.row());

    switch (role) {
    case Qt::DisplayRole:
        return planting.crop() + " " + planting.variety();
    case Roles::IdRole:
        return planting.id();
    case Roles::CropRole:
        return planting.crop();
    case Roles::VarietyRole:
        return planting.variety();
    default:
        return QVariant();
    }
}

bool PlantingModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (!isIndexValid(index)
            || role == IdRole) {
        return false;
    }

    Planting& planting = *mPlantings->at(index.row());
    planting.setCrop(value.toString());
    mDatabase.plantingDao.updatePlanting(planting);
    emit dataChanged(index, index);

    return true;
}

bool PlantingModel::removeRows(int row, int count, const QModelIndex& parent)
{
    if  (row < 0
         || row >= rowCount()
         || count < 0
         || (row + count) > rowCount()) {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);
    int countLeft = count;
    while (countLeft--) {
        const Planting& planting = *mPlantings->at(row + countLeft);
        mDatabase.plantingDao.removePlanting(planting.id());
    }
    mPlantings->erase(mPlantings->begin() + row,
                      mPlantings->begin() + row + count);
    endRemoveRows();

    return true;
}

QHash<int, QByteArray> PlantingModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Roles::IdRole] = "planting_id";
    roles[Roles::CropRole] = "crop";
    roles[Roles::VarietyRole] = "variety";

    return roles;
}

bool PlantingModel::isIndexValid(const QModelIndex& index) const
{
    return index.isValid() && (0 <= index.row() < rowCount());
}
