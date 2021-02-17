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

#ifndef CMDVARIETYADDDEL_H
#define CMDVARIETYADDDEL_H

#include "cmdadddel.h"
#include "business/family.h"

class CORESHARED_EXPORT CmdVarietyAddDel : public CmdAddDel
{
public:
    CmdVarietyAddDel(int cropId, const QString &name, int seedCompanyId,
                     bool isDefault = false); //!< for creation
    CmdVarietyAddDel(int cropId, int varietyId); //!< for deletion

    void redo() override;
    void undo() override;

    QString str() const override
    {
        return QString("[CmdVarietyAddDel] %1 variety %2").arg(m_creation ? "Create" : "Delete").arg(m_name);
    }

    int varietyId() const { return m_varietyId; }

private:
    void _setVarietyDelete(qrp::Variety *variety, bool value);

private:
    const int m_cropId;
    int m_varietyId;
};

#endif // CMDVARIETYADDDEL_H
