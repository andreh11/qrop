#ifndef FAMILYTABLE_H
#define FAMILYTABLE_H

#include <QObject>

#include "core_global.h"
#include "sqltablemodel.h"

class CORESHARED_EXPORT FamilyModel : public SqlTableModel
{
public:
    FamilyModel(QObject *parent = nullptr);
};

#endif // FAMILYTABLE_H
