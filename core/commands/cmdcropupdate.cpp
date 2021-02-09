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

#include "cmdcropupdate.h"
#include "dbutils/family.h"
#include "dbutils/databaseutility.h"
#include "version.h"
#include "services/familyservice.h"
#include "qrop.h"

CmdCropUpdate::CmdCropUpdate(int row, int family_id, int crop_id, CropModel2::CropRole role,
                             const QVariant &oldV, const QVariant &newV)
    : CmdUpdate(row, role, oldV, newV)
    , m_family_id(family_id)
    , m_crop_id(crop_id)
{
    setText(QString("Update family %1").arg(s_familySvc->crop(m_crop_id)->name));
}

void CmdCropUpdate::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[redo] " << str();
#endif

    qrp::Crop *crop = s_familySvc->crop(m_crop_id);
    if (!crop) {
        qCritical() << "[CmdCropUpdate::redo] INVALID crop_id: " << m_crop_id;
        return;
    }

    switch (m_role) {
    case CropModel2::CropRole::name:
        crop->name = m_newValue.toString();
        break;
    case CropModel2::CropRole::color:
        crop->color = m_newValue.toString();
        break;
    default:
        break;
    }

    if (Qrop::instance()->isLocalDatabase()) {
        DatabaseUtility sql("crop");
        sql.update(m_crop_id, { { CropModel2::roleName(m_role), m_newValue } });
    }
    emit s_familySvc->cropUpdated(m_family_id, m_row);
}

void CmdCropUpdate::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[undo] " << str();
#endif

    qrp::Crop *crop = s_familySvc->crop(m_crop_id);
    if (!crop) {
        qCritical() << "[CmdCropUpdate::undo] INVALID crop_id: " << m_crop_id;
        return;
    }

    switch (m_role) {
    case CropModel2::CropRole::name:
        crop->name = m_oldValue.toString();
        break;
    case CropModel2::CropRole::color:
        crop->color = m_oldValue.toString();
        break;
    default:
        break;
    }

    if (Qrop::instance()->isLocalDatabase()) {
        DatabaseUtility sql("crop");
        sql.update(m_crop_id, { { CropModel2::roleName(m_role), m_oldValue } });
    }
    emit s_familySvc->cropUpdated(m_family_id, m_row);
}
