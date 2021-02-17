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

#ifndef CMDADDDEL_H
#define CMDADDDEL_H

#include <QUndoCommand>
#include "cmdfamily.h"

class CmdAddDel : public QUndoCommand, public CmdFamily
{
public:
    explicit CmdAddDel(bool creation, const QString &name)
        : QUndoCommand(nullptr)
        , m_creation(creation)
        , m_name(name)
    {}

protected:
    const bool m_creation;
    const QString m_name;
};
#endif // CMDADDDEL_H
