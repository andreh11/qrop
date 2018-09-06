#ifndef FAMILYTABLE_H
#define FAMILYTABLE_H

#include <QObject>

#include "sqltablemodel.h"

class FamilyTable : public SqlTableModel
{
public:
    FamilyTable(QObject *parent = nullptr);
};

#endif // FAMILYTABLE_H
