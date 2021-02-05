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

CmdVarietyAddDel::CmdVarietyAddDel(int crop_id, int variety_id)
    : QUndoCommand()
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

    if (!variety->deleted) {
        variety->deleted = true;
        if (qrop->isLocalDatabase()) {
            dbutils::Variety sql;
            sql.update(m_variety_id, { { VarietyModel2::roleName(VarietyModel2::deleted), true } });
        }
        emit qrop->varietyDeleted(m_crop_id, m_variety_id);
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

    if (variety->deleted) {
        variety->deleted = false;
        if (qrop->isLocalDatabase()) {
            dbutils::Variety sql;
            sql.update(m_variety_id, { { VarietyModel2::roleName(VarietyModel2::deleted), false } });
        }
        emit qrop->varietyDeleted(m_crop_id, m_variety_id);
    }
}
