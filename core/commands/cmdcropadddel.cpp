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

#include "cmdcropadddel.h"
#include "qrop.h"
#include "version.h"
#include "dbutils/databaseutility.h"
#include "models/cropmodel.h"
#include "services/familyservice.h"
CmdCropAddDel::CmdCropAddDel(int familyId, const QString &name, const QString &color)
    : CmdAddDel(true, name)
    , m_familyId(familyId)
    , m_cropId(-1)
{
    setText(QString("Create crop %1").arg(m_name));
    if (Qrop::instance()->isLocalDatabase()) {
        DatabaseUtility sql("crop");
        m_cropId = sql.add(
                { { "family_id", m_familyId }, { "crop", name }, { "color", color }, { "deleted", true } });
    } else
        m_cropId = qrp::Crop::getNextId();

    // Add non visible Crop in Qrop data structure
    s_familySvc->addCrop(m_cropId, true, name, color, m_familyId, true);
}

CmdCropAddDel::CmdCropAddDel(int familyId, int cropId)
    : CmdAddDel(false, s_familySvc->crop(cropId)->name)
    , m_familyId(familyId)
    , m_cropId(cropId)
{
    setText(QString("Delete crop %1").arg(m_name));
}

void CmdCropAddDel::redo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdCropAddDel::redo] " << text();
#endif
    qrp::Crop *crop = s_familySvc->crop(m_cropId);
    if (!crop) {
        qCritical() << "[CmdCropAddDel::redo] INVALID crop_id: " << m_cropId;
        return;
    }

    if (m_creation) {
        if (crop->deleted)
            _setCropDelete(crop, false);
    } else {
        if (!crop->deleted)
            _setCropDelete(crop, true);
    }
}

void CmdCropAddDel::undo()
{
#ifdef TRACE_CPP_COMMANDS
    qDebug() << "[CmdCropAddDel::undo] " << text();
#endif
    qrp::Crop *crop = s_familySvc->crop(m_cropId);
    if (!crop) {
        qCritical() << "[CmdCropAddDel::redo] INVALID crop_id: " << m_cropId;
        return;
    }

    if (m_creation) {
        if (!crop->deleted)
            _setCropDelete(crop, true);
    } else {
        if (crop->deleted)
            _setCropDelete(crop, false);
    }
}

void CmdCropAddDel::_setCropDelete(qrp::Crop *crop, bool value)
{
    crop->deleted = value;
    if (Qrop::instance()->isLocalDatabase()) {
        DatabaseUtility sql("crop");
        sql.update(m_cropId, { { CropModel2::roleName(CropModel2::deleted), value } });
    }
    emit s_familySvc->cropVisible(m_familyId, m_cropId);
}
