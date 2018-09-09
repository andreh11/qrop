#ifndef FAMILYTABLE_H
#define FAMILYTABLE_H

#include <QObject>

#include "core_global.h"
#include "sqltablemodel.h"

class CORESHARED_EXPORT FamilyTable : public SqlTableModel
{
public:
    FamilyTable(QObject *parent = nullptr);
    void add(const QString &name, const QString &color);
};

#endif // FAMILYTABLE_H
