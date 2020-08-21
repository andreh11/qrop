#ifndef FAMILYTABLE_H
#define FAMILYTABLE_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT FamilyModel : public SortFilterProxyModel
{
public:
    FamilyModel(QObject *parent = nullptr, const QString &tableName = "family");
};

#endif // FAMILYTABLE_H
