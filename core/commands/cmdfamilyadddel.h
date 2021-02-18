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

#ifndef CMDFAMILYADDDEL_H
#define CMDFAMILYADDDEL_H

#include "cmdadddel.h"
#include "business/family.h"

class CORESHARED_EXPORT CmdFamilyAddDel : public CmdAddDel
{
public:
    CmdFamilyAddDel(const QString &name, const QString &color); //!< for creation
    CmdFamilyAddDel(int familyId); //!< for deletion

    void redo() override;
    void undo() override;

    QString str() const override
    {
        return QString("[CmdFamilyAddDel] %1 family %2").arg(m_creation ? "Create" : "Delete").arg(m_name);
    }

    int familyId() const { return m_familyId; }

private:
    void _setFamilyDelete(qrp::Family *family, bool value);

private:
    int m_familyId;
};

#endif // CMDFAMILYADDDEL_H
