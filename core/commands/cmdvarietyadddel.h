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
#include "cmdfamily.h"
#include "business/family.h"
class Qrop;

class CORESHARED_EXPORT CmdVarietyAddDel : public QUndoCommand, public CmdFamily
{
public:
    CmdVarietyAddDel(int cropId, const QString &name, int seedCompanyId = -1); //!< for creation
    CmdVarietyAddDel(int cropId, int varietyId); //!< for deletion

    void redo() override;
    void undo() override;

    QString str() const override
    {
        return QString("[CmdVarietyAddDel] %1 variety %2").arg(m_creation ? "Create" : "Delete").arg(m_varietyName);
    }

    int varietyId() const { return m_varietyId; }

private:
    void _setVarietyDelete(qrp::Variety *variety, bool value);

private:
    const bool m_creation;
    int m_cropId;
    int m_varietyId;
    const QString m_varietyName;
};

#endif // CMDVARIETYADDDEL_H
