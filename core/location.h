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

#ifndef LOCATION_H
#define LOCATION_H

#include "core_global.h"
#include "databaseutility.h"

class CORESHARED_EXPORT Location : public DatabaseUtility
{
    Q_OBJECT
public:
    Location(QObject *parent = nullptr);
    //    Q_INVOKABLE int duplicate(int id) { return db.duplicate(id); } // TODO: duplicate children

    Q_INVOKABLE QString fullName(int locationId) const;
    Q_INVOKABLE QList<QSqlRecord> locations(int plantingId) const;
    Q_INVOKABLE QList<int> children(int locationId) const;
    Q_INVOKABLE void addPlanting(int plantingId, int locationId) const;
    Q_INVOKABLE void removePlanting(int plantingId, int locationId) const;
    Q_INVOKABLE void removePlantingLocations(int plantingId) const;
};

#endif // LOCATION_H
