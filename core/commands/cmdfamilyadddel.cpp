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

#include "cmdfamilyadddel.h"
#include "qrop.h"
#include "version.h"
#include "dbutils/databaseutility.h"
#include "models/familymodel.h"
#include "services/familyservice.h"
CmdFamilyAddDel::CmdFamilyAddDel(const QString &name, const QString &color)
    : CmdAddDel(true, name)
    , m_familyId(-1)
{
    setText(QString("Create family %1").arg(m_name));
    if (Qrop::instance()->isLocalDatabase()) {
        DatabaseUtility sql("family");
        m_familyId = sql.add({ { "family", name }, { "color", color }, { "deleted", true } });
    } else
        m_familyId = qrp::Family::getNextId();

    // Add non visible Family in Qrop data structure
    emit s_familySvc->addFamily(m_familyId, true, name, 0, color, true);
}

CmdFamilyAddDel::CmdFamilyAddDel(int familyId)
    : CmdAddDel(false, s_familySvc->family(familyId)->name)
    , m_familyId(familyId)
{
    setText(QString("Delete crop %1").arg(m_name));
}

void CmdFamilyAddDel::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdFamilyAddDel::redo] " << text();
#endif
    qrp::Family *family = s_familySvc->family(m_familyId);
    if (!family) {
        qCritical() << "[CmdFamilyAddDel::redo] INVALID familyId: " << m_familyId;
        return;
    }

    if (m_creation) {
        if (family->deleted)
            _setFamilyDelete(family, false);
    } else {
        if (!family->deleted)
            _setFamilyDelete(family, true);
    }
}

void CmdFamilyAddDel::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdFamilyAddDel::undo] " << text();
#endif
    qrp::Family *family = s_familySvc->family(m_familyId);
    if (!family) {
        qCritical() << "[CmdFamilyAddDel::redo] INVALID familyId: " << m_familyId;
        return;
    }

    if (m_creation) {
        if (!family->deleted)
            _setFamilyDelete(family, true);
    } else {
        if (family->deleted)
            _setFamilyDelete(family, false);
    }
}

void CmdFamilyAddDel::_setFamilyDelete(qrp::Family *family, bool value)
{
    family->deleted = value;
    if (Qrop::instance()->isLocalDatabase()) {
        DatabaseUtility sql("family");
        sql.update(m_familyId, { { FamilyModel2::roleName(FamilyModel2::deleted), value } });
    }
    emit s_familySvc->familyVisible(m_familyId);
}
