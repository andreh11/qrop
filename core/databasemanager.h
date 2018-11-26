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

#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <memory>

#include <QString>

#include "plantingdao.h"
#include "locationdao.h"

class QSqlQuery;
class QSqlDatabase;

const QString DATABASE_FILENAME = "qrop.db";

class DatabaseManager
{
public:
    static void debugQuery(const QSqlQuery &query);

    static DatabaseManager &instance();
    ~DatabaseManager();

protected:
    DatabaseManager(const QString &path = DATABASE_FILENAME);
    DatabaseManager &operator=(const DatabaseManager &rhs);

private:
    std::unique_ptr<QSqlDatabase> mDatabase;

public:
    const PlantingDao plantingDao;
    const LocationDao locationDao;
};

#endif // DATABASEMANAGER_H
