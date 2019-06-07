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

#ifndef VARIETY_H
#define VARIETY_H

#include "core_global.h"
#include "databaseutility.h"

class CORESHARED_EXPORT Variety : public DatabaseUtility
{
    Q_OBJECT
public:
    Variety(QObject *parent = nullptr);
    Q_INVOKABLE int cropId(int varietyId) const;
    Q_INVOKABLE QString varietyName(int varietyId) const;

    Q_INVOKABLE bool isDefault(int varietyId) const;
    Q_INVOKABLE void setDefault(int varietyId, bool def = true);
    Q_INVOKABLE int defaultVariety(int cropId) const;
    Q_INVOKABLE void addDefault(int cropId) const;
};

#endif // VARIETY_H
