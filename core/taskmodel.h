#ifndef SQLTASKGMODEL_H
#define SQLTASKMODEL_H

#include <QSqlTableModel>
#include <QDate>

#include "core_global.h"

class CORESHARED_EXPORT TaskModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setFilterDate NOTIFY dateChanged)

public:
    TaskModel(QObject *parent = nullptr);

    QDate date() const;
    void setFilterDate(const QDate &date);
    static void createTasks(int cropId);

signals:
    void dateChanged();

private:
    QDate m_filterDate;
};

#endif // SQLPLANTINGMODEL_H
