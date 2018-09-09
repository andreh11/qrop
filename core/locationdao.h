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

#ifndef LOCATIONDAO_H
#define LOCATIONDAO_H

#include <memory>
#include <vector>

#include "core_global.h"

class QSqlDatabase;
class Location;

class CORESHARED_EXPORT LocationDao
{
public:
    LocationDao(QSqlDatabase& database);
//    void init() const;
private:
    QSqlDatabase& mDatabase;
};

#endif // LOCATIONDAO_H
