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

#ifndef PLANTINGMODEL_H
#define PLANTINGMODEL_H

#include <vector>
#include <memory>

#include <QAbstractListModel>
#include <QByteArray>

#include "core_global.h"
#include "planting.h"
#include "databasemanager.h"

class CORESHARED_EXPORT PlantingModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        CropRole,
        VarietyRole
    };

    PlantingModel(QObject *parent = nullptr);

    QModelIndex addPlanting(const Planting& planting);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role) override;
    Q_INVOKABLE bool removeRows(int row, int count, const QModelIndex& parent = QModelIndex()) override;
    QHash<int, QByteArray> roleNames() const override;

private:
    bool isIndexValid(const QModelIndex& index) const;
    DatabaseManager& mDatabase;
    std::unique_ptr<std::vector<std::unique_ptr<Planting>>> mPlantings;
};

#endif // PLANTINGMODEL_H
