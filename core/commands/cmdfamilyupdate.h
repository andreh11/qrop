#ifndef CMDFAMILYUPDATE_H
#define CMDFAMILYUPDATE_H

#include <QUndoCommand>
#include "models/familymodel.h"
class CmdFamilyUpdate : public QUndoCommand
{
public:
    CmdFamilyUpdate(int row, int family_id, FamilyModel2::FamilyRole role, QVariant oldV, QVariant newV);

    void redo() override;
    void undo() override;

private:
    const int m_row;
    const int m_family_id;
    const FamilyModel2::FamilyRole m_role;
    const QVariant m_oldValue;
    const QVariant m_newValue;
};

#endif // CMDFAMILYUPDATE_H
