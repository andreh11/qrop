#ifndef SQLTASKGMODEL_H
#define SQLTASKMODEL_H

#include <QDate>

#include "core_global.h"
#include "sqltablemodel.h"

class CORESHARED_EXPORT TaskModel : public SqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setFilterDate NOTIFY dateChanged)

public:
    TaskModel(QObject *parent = nullptr);

    QDate date() const;
    void setFilterDate(const QDate &date);

signals:
    void dateChanged();

private:
    QDate m_filterDate;
};

#endif // SQLPLANTINGMODEL_H
