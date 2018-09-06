#include "sqltablemodel.h"
#include "familytable.h"

FamilyTable::FamilyTable(QObject *parent)
    : SqlTableModel(parent)
{
    setTable("family");
}
