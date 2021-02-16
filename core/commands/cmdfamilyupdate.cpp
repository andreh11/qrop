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

#include "cmdfamilyupdate.h"
#include "qrop.h"
#include "dbutils/family.h"
#include "version.h"
#include "services/familyservice.h"

CmdFamilyUpdate::CmdFamilyUpdate(int row, int family_id, FamilyModel2::FamilyRole role,
                                 QVariant oldV, QVariant newV)
    : CmdUpdate(row, role, oldV, newV)
    , m_family_id(family_id)
{
    setText(QString("Update family %1").arg(s_familySvc->family(m_family_id)->name));
}

void CmdFamilyUpdate::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[redo] " << str();
#endif
    qrp::Family *family = s_familySvc->family(m_family_id);
    if (!family) {
        qCritical() << "[CmdFamilyUpdate::redo] INVALID crop_id: " << m_family_id;
        return;
    }

    switch (m_role) {
    case FamilyModel2::FamilyRole::name:
        family->name = m_newValue.toString();
        break;
    case FamilyModel2::FamilyRole::color:
        family->color = m_newValue.toString();
        break;
    case FamilyModel2::FamilyRole::interval:
        family->interval = m_newValue.toUInt();
        break;
    default:
        break;
    }
    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Family sql;
        sql.update(m_family_id, { { FamilyModel2::roleName(m_role), m_newValue } });
    }
    emit s_familySvc->familyUpdated(m_row);
}

void CmdFamilyUpdate::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[undo] " << str();
#endif
    qrp::Family *family = s_familySvc->family(m_family_id);
    if (!family) {
        qCritical() << "[CmdFamilyUpdate::undo] INVALID crop_id: " << m_family_id;
        return;
    }

    switch (m_role) {
    case FamilyModel2::FamilyRole::name:
        family->name = m_oldValue.toString();
        break;
    case FamilyModel2::FamilyRole::color:
        family->color = m_oldValue.toString();
        break;
    case FamilyModel2::FamilyRole::interval:
        family->interval = m_oldValue.toUInt();
        break;
    default:
        break;
    }

    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Family sql;
        sql.update(m_family_id, { { FamilyModel2::roleName(m_role), m_oldValue } });
    }
    emit s_familySvc->familyUpdated(m_row);
}
