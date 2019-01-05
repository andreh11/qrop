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

#ifndef FAMILY_H
#define FAMILY_H

#include "core_global.h"
#include "databaseutility.h"

class CORESHARED_EXPORT Family : public DatabaseUtility
{
    Q_OBJECT
public:
    Family(QObject *parent = nullptr);
    Q_INVOKABLE QString name(int familyId) const;
    Q_INVOKABLE QString color(int familyId) const;
    Q_INVOKABLE int interval(int familyId) const;
};

#endif // FAMILY_H
