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

#include <QUndoCommand>
#include <QPersistentModelIndex>

class CmdVarietyAddDel : public QUndoCommand
{
public:
    CmdVarietyAddDel(int crop_id, int variety_id);

    void redo() override;
    void undo() override;

//    QString str() const override {
//        return QString("[CmdVarietyAddDel] crop_id: %1, family_id: %2, %3").arg(
//                    m_crop_id).arg(m_variety_id).arg(CmdUpdate::str());
//    }


private:
    const int m_crop_id;
    const int m_variety_id;
};

#endif // CMDVARIETYADDDEL_H
