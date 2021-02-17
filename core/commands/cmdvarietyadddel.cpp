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

CmdVarietyAddDel::CmdVarietyAddDel(int cropId, const QString &name, int seedCompanyId, bool isDefault)
    : CmdAddDel(true, name)
    , m_cropId(cropId)
    , m_varietyId(-1)
{
    setText(QString("Create variety %1").arg(m_name));
    if (Qrop::instance()->isLocalDatabase()) {
        dbutils::Variety sql;
        QVariantMap attribs = { { "crop_id", m_cropId }, { "variety", name }, { "deleted", true } };
        if (seedCompanyId != 0)
            attribs.insert("seed_company_id", seedCompanyId);
        if (isDefault)
            attribs.insert("is_default", true);
        m_varietyId = sql.add(attribs);
    } else
        m_varietyId = qrp::Variety::getNextId();

    // Add non visible Variety in Qrop data structure
    emit s_familySvc->beginAppendVariety(m_cropId);
    s_familySvc->addVariety(m_varietyId, true, name, m_cropId, false, seedCompanyId);
    emit s_familySvc->endAppendVariety(m_cropId);
}

CmdVarietyAddDel::CmdVarietyAddDel(int cropId, int varietyId)
    : CmdAddDel(false, s_familySvc->variety(m_varietyId)->name)
    , m_cropId(cropId)
    , m_varietyId(varietyId)
{
    setText(QString("Delete variety %1").arg(m_name));
}

void CmdVarietyAddDel::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdVarietyAddDel::redo] " << text();
#endif
    qrp::Variety *variety = s_familySvc->variety(m_varietyId);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_varietyId;
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
    qrp::Variety *variety = s_familySvc->variety(m_varietyId);
    if (!variety) {
        qCritical() << "[CmdVarietyUpdate::redo] INVALID variety_id: " << m_varietyId;
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
        sql.update(m_varietyId, { { VarietyModel2::roleName(VarietyModel2::deleted), value } });
    }
    emit s_familySvc->varietyVisible(m_cropId, m_varietyId);
}
