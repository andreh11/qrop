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

CmdVarietyAddDel::CmdVarietyAddDel(int crop_id, const QString &name, int seedCompanyId)
    : QUndoCommand()
    , m_creation(true)
    , m_crop_id(crop_id)
    , m_variety_id(-1)
{
    Qrop *qrop = Qrop::instance();
    setText(QString("Create variety for crop: %1").arg(qrop->crop(m_crop_id)->name));
    if (qrop->isLocalDatabase()) {
        dbutils::Variety sql;
        m_variety_id = sql.add({ { "crop_id", m_crop_id },
                                 { "variety", name },
                                 { "seed_company_id", seedCompanyId },
                                 { "deleted", "true" } });
    } else
        m_variety_id = qrp::Variety::getNextId();

    // Add non visible Variety in Qrop data structure
    emit qrop->beginAppendVariety(m_crop_id);
    qrop->addVariety(m_variety_id, true, name, m_crop_id, false, seedCompanyId);
    emit qrop->endAppendVariety(m_crop_id);
}

CmdVarietyAddDel::CmdVarietyAddDel(int crop_id, int variety_id)
    : QUndoCommand()
    , m_creation(false)
    , m_crop_id(crop_id)
    , m_variety_id(variety_id)
{
    Qrop *qrop = Qrop::instance();
    setText(QString("Delete variety %1").arg(qrop->variety(m_variety_id)->name));
}

void CmdVarietyAddDel::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdVarietyAddDel::redo] " << text();
#endif

    Qrop *qrop = Qrop::instance();
    qrp::Variety *variety = qrop->variety(m_variety_id);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_variety_id;
        return;
    }

    if (m_creation) {
        if (variety->deleted)
            _setVarietyDelete(variety, false, qrop);
    } else {
        if (!variety->deleted)
            _setVarietyDelete(variety, true, qrop);
    }
}

void CmdVarietyAddDel::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdVarietyAddDel::undo] " << text();
#endif

    Qrop *qrop = Qrop::instance();
    qrp::Variety *variety = qrop->variety(m_variety_id);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_variety_id;
        return;
    }

    if (m_creation) {
        if (!variety->deleted)
            _setVarietyDelete(variety, true, qrop);
    } else {
        if (variety->deleted)
            _setVarietyDelete(variety, false, qrop);
    }
}

void CmdVarietyAddDel::_setVarietyDelete(qrp::Variety *variety, bool value, Qrop *qrop)
{
    variety->deleted = value;
    if (qrop->isLocalDatabase()) {
        dbutils::Variety sql;
        sql.update(m_variety_id, { { VarietyModel2::roleName(VarietyModel2::deleted), value } });
    }
    emit qrop->varietyVisible(m_crop_id, m_variety_id);
}
