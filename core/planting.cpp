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

#include "planting.h"

Planting::Planting(const QString& crop) :
    mId(-1),
    mCrop(crop),
    mVariety(""),
    mFamily(""),
    mUnit("")
{

}

int Planting::id() const
{
    return mId;
}

void Planting::setId(int id)
{
    mId = id;
}

QString Planting::crop() const
{
    return mCrop;
}

void Planting::setCrop(const QString& crop)
{
    mCrop = crop;
}

QString Planting::variety() const
{
    return mVariety;
}

void Planting::setVariety(const QString& variety)
{
    mVariety = variety;
}

QString Planting::unit() const
{
    return mUnit;
}

void Planting::setUnit(const QString& unit)
{
    mUnit = unit;
}
