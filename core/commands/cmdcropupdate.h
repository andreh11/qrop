#ifndef CMDCROPUPDATE_H
#define CMDCROPUPDATE_H


#include <QUndoCommand>
#include "models/cropmodel.h"
class CmdCropUpdate : public QUndoCommand
{
public:
    CmdCropUpdate(int row, int family_id, int crop_id, CropModel2::CropRole role, QVariant oldV, QVariant newV);

    void redo() override;
    void undo() override;

private:
    const int m_row;
    const int m_family_id;
    const int m_crop_id;
    const CropModel2::CropRole m_role;
    const QVariant m_oldValue;
    const QVariant m_newValue;
};


#endif // CMDCROPUPDATE_H
