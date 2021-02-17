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

#ifndef CMDCROPADDDEL_H
#define CMDCROPADDDEL_H

#include "cmdadddel.h"
#include "business/family.h"
class Qrop;

class CORESHARED_EXPORT CmdCropAddDel : public CmdAddDel
{
public:
    CmdCropAddDel(int familyId, const QString &name, const QString &color); //!< for creation
    CmdCropAddDel(int familyId, int cropId); //!< for deletion

    void redo() override;
    void undo() override;

    QString str() const override
    {
        return QString("[CmdCropAddDel] %1 crop %2").arg(m_creation ? "Create" : "Delete").arg(m_name);
    }

    int cropId() const { return m_cropId; }

private:
    void _setCropDelete(qrp::Crop *crop, bool value);

private:
    const int m_familyId;
    int m_cropId;
};


#endif // CMDCROPADDDEL_H
