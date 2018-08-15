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

#ifndef PLANTING_H
#define PLANTING_H

#include <QString>

#include "core_global.h"

class CORESHARED_EXPORT Planting
{
public:
    explicit Planting(const QString& crop = "");

    int id () const;
    void setId(int id);

    QString crop() const;
    void setCrop(const QString& crop);

    QString variety() const;
    void setVariety(const QString& variety);

    QString family() const;
    void setFamily(const QString& family);

    QString unit() const;
    void setUnit(const QString& unit);

private:
    int mId;
    QString mCrop;
    QString mVariety;
    QString mFamily;
    QString mUnit;
};

#endif // PLANTING_H
