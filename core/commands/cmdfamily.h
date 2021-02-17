/*
 * Copyright (C) 2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
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

#ifndef CMDFAMILY_H
#define CMDFAMILY_H
#include "core_global.h"
class FamilyService;

class CmdFamily
{
    friend class Qrop;

public:
    CmdFamily() = default;
    virtual ~CmdFamily() = default;

    virtual QString str() const = 0;

protected:
    static FamilyService *s_familySvc;
};

#endif // CMDFAMILY_H
