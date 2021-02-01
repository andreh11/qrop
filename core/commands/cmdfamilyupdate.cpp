#include "cmdfamilyupdate.h"
#include "qrop.h"
#include "dbutils/family.h"

CmdFamilyUpdate::CmdFamilyUpdate(int row, int family_id, FamilyModel2::FamilyRole role,
                                 QVariant oldV, QVariant newV)
    : QUndoCommand(nullptr)
    , m_row(row)
    , m_family_id(family_id)
    , m_role(role)
    , m_oldValue(oldV)
    , m_newValue(newV)
{
    Qrop *qrop = Qrop::instance();
    setText(QString("Update family %1").arg(qrop->family(m_family_id)->name));
}

void CmdFamilyUpdate::redo()
{
    qDebug() << "[CmdFamilyUpdate::redo] Row: " << m_row << ", family_id: " << m_family_id
             << ", oldV : " << m_oldValue << ", newV: " << m_newValue;

    Qrop *qrop = Qrop::instance();
    qrp::Family *family = qrop->family(m_family_id);
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
    if (qrop->isLocalDatabase()) {
        dbutils::Family sql;
        sql.update(m_family_id, { { FamilyModel2::roleName(m_role), m_newValue } });
    }
    emit qrop->familyUpdated(m_row);
}

void CmdFamilyUpdate::undo()
{
    Qrop *qrop = Qrop::instance();
    qrp::Family *family = qrop->family(m_family_id);
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

    if (qrop->isLocalDatabase()) {
        dbutils::Family sql;
        sql.update(m_family_id, { { FamilyModel2::roleName(m_role), m_oldValue } });
    }
    emit qrop->familyUpdated(m_row);
}
