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

#ifndef CMDFAMILYUPDATE_H
#define CMDFAMILYUPDATE_H

#include "cmdupdate.h"
#include "models/familymodel.h"
class CORESHARED_EXPORT CmdFamilyUpdate : public CmdUpdate
{
public:
    CmdFamilyUpdate(int row, int family_id, FamilyModel2::FamilyRole role, QVariant oldV, QVariant newV);

    void redo() override;
    void undo() override;

    QString str() const override
    {
        return QString("[CmdFamilyUpdate] family_id: %1, %2").arg(m_familyId).arg(CmdUpdate::str());
    }

private:
    const int m_familyId;
};

#endif // CMDFAMILYUPDATE_H
