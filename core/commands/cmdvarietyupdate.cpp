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

#include "cmdvarietyupdate.h"
#include "qrop.h"
#include "dbutils/variety.h"
#include "version.h"
#include "services/familyservice.h"

CmdVarietyUpdate::CmdVarietyUpdate(int row, int crop_id, int variety_id,
                                   VarietyModel2::VarietyRole role, QVariant oldV, QVariant newV)
    : CmdUpdate(row, role, oldV, newV)
    , m_crop_id(crop_id)
    , m_variety_id(variety_id)
{
    setText(QString("Update variety %1").arg(s_familySvc->variety(m_variety_id)->name));
}

void CmdVarietyUpdate::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[redo] " << str();
#endif
    qrp::Variety *variety = s_familySvc->variety(m_variety_id);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_variety_id;
        return;
    }

    switch (m_role) {
    case VarietyModel2::VarietyRole::name:
        variety->name = m_newValue.toString();
        break;
    case VarietyModel2::VarietyRole::isDefault:
        variety->isDefault = m_newValue.toBool();
        break;
    case VarietyModel2::VarietyRole::seedCompanyId:
        variety->seedCompany = s_familySvc->seedCompany(m_newValue.toInt());
        break;
    default:
        break;
    }
    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Variety sql;
        sql.update(m_variety_id, { { VarietyModel2::roleName(m_role), m_newValue } });
    }
    emit s_familySvc->varietyUpdated(m_crop_id, m_row);
}

void CmdVarietyUpdate::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[undo] " << str();
#endif
    qrp::Variety *variety = s_familySvc->variety(m_variety_id);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_variety_id;
        return;
    }

    switch (m_role) {
    case VarietyModel2::VarietyRole::name:
        variety->name = m_oldValue.toString();
        break;
    case VarietyModel2::VarietyRole::isDefault:
        variety->isDefault = m_oldValue.toBool();
        break;
    case VarietyModel2::VarietyRole::seedCompanyId:
        variety->seedCompany = s_familySvc->seedCompany(m_oldValue.toInt());
        break;
    default:
        break;
    }
    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Variety sql;
        sql.update(m_variety_id, { { VarietyModel2::roleName(m_role), m_oldValue } });
    }
    emit s_familySvc->varietyUpdated(m_crop_id, m_row);
}
