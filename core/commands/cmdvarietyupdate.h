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

#ifndef CMDVARIETYUPDATE_H
#define CMDVARIETYUPDATE_H

#include "CmdUpdate.h"
#include "models/varietymodel.h"
class CmdVarietyUpdate : public CmdUpdate
{
public:
    CmdVarietyUpdate(int row, int crop_id, int variety_id, VarietyModel2::VarietyRole role, QVariant oldV, QVariant newV);

    void redo() override;
    void undo() override;

    QString str() const override {
        return QString("[CmdVarietyUpdate] crop_id: %1, family_id: %2, %3").arg(
                    m_crop_id).arg(m_variety_id).arg(CmdUpdate::str());
    }


private:
    const int m_crop_id;
    const int m_variety_id;
};


#endif // CMDVARIETYUPDATE_H
