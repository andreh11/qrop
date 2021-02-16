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

#include "cmdvarietyadddel.h"
#include "qrop.h"
#include "version.h"
#include "dbutils/variety.h"
#include "models/varietymodel.h"
#include "services/familyservice.h"

CmdVarietyAddDel::CmdVarietyAddDel(int crop_id, const QString &name, int seedCompanyId)
    : QUndoCommand()
    , m_creation(true)
    , m_crop_id(crop_id)
    , m_variety_id(-1)
{
    setText(QString("Create variety for crop: %1").arg(s_familySvc->crop(m_crop_id)->name));
    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Variety sql;
        m_variety_id = sql.add({ { "crop_id", m_crop_id },
                                 { "variety", name },
                                 { "seed_company_id", seedCompanyId },
                                 { "deleted", "true" } });
    } else
        m_variety_id = qrp::Variety::getNextId();

    // Add non visible Variety in Qrop data structure
    emit s_familySvc->beginAppendVariety(m_crop_id);
    s_familySvc->addVariety(m_variety_id, true, name, m_crop_id, false, seedCompanyId);
    emit s_familySvc->endAppendVariety(m_crop_id);
}

CmdVarietyAddDel::CmdVarietyAddDel(int crop_id, int variety_id)
    : QUndoCommand()
    , m_creation(false)
    , m_crop_id(crop_id)
    , m_variety_id(variety_id)
{
    setText(QString("Delete variety %1").arg(s_familySvc->variety(m_variety_id)->name));
}

void CmdVarietyAddDel::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdVarietyAddDel::redo] " << text();
#endif
    qrp::Variety *variety = s_familySvc->variety(m_variety_id);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_variety_id;
        return;
    }

    if (m_creation) {
        if (variety->deleted)
            _setVarietyDelete(variety, false);
    } else {
        if (!variety->deleted)
            _setVarietyDelete(variety, true);
    }
}

void CmdVarietyAddDel::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdVarietyAddDel::undo] " << text();
#endif
    qrp::Variety *variety = s_familySvc->variety(m_variety_id);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_variety_id;
        return;
    }

    if (m_creation) {
        if (!variety->deleted)
            _setVarietyDelete(variety, true);
    } else {
        if (variety->deleted)
            _setVarietyDelete(variety, false);
    }
}

void CmdVarietyAddDel::_setVarietyDelete(qrp::Variety *variety, bool value)
{
    variety->deleted = value;
    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Variety sql;
        sql.update(m_variety_id, { { VarietyModel2::roleName(VarietyModel2::deleted), value } });
    }
    emit s_familySvc->varietyVisible(m_crop_id, m_variety_id);
}
