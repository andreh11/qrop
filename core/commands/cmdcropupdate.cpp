#include "cmdcropupdate.h"
#include "qrop.h"
#include "dbutils/family.h"
#include "dbutils/databaseutility.h"
CmdCropUpdate::CmdCropUpdate(int row, int family_id, int crop_id, CropModel2::CropRole role,
                             QVariant oldV, QVariant newV)
    : QUndoCommand(nullptr)
    , m_row(row)
    , m_family_id(family_id)
    , m_crop_id(crop_id)
    , m_role(role)
    , m_oldValue(oldV)
    , m_newValue(newV)
{
    Qrop *qrop = Qrop::instance();
    setText(QString("Update family %1").arg(qrop->crop(m_crop_id)->name));
}

void CmdCropUpdate::redo()
{
    qDebug() << "[CmdCropUpdate::redo] Row: " << m_row << ", family_id: " << m_family_id
             << ", oldV : " << m_oldValue << ", newV: " << m_newValue;

    Qrop *qrop = Qrop::instance();
    qrp::Crop *crop = qrop->crop(m_crop_id);
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

    if (qrop->isLocalDatabase()) {
        DatabaseUtility sql("crop");
        sql.update(m_crop_id, { { CropModel2::roleName(m_role), m_newValue } });
    }

    emit qrop->cropUpdated(m_family_id, m_row);
}

void CmdCropUpdate::undo()
{
    Qrop *qrop = Qrop::instance();
    qrp::Crop *crop = qrop->crop(m_crop_id);
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

    if (qrop->isLocalDatabase()) {
        DatabaseUtility sql("crop");
        sql.update(m_crop_id, { { CropModel2::roleName(m_role), m_oldValue } });
    }
    emit qrop->cropUpdated(m_family_id, m_row);
}
