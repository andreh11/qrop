#ifndef SQLTASKGMODEL_H
#define SQLTASKMODEL_H

#include <QSqlTableModel>
#include <QDate>

class SqlTaskModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)

public:
    SqlTaskModel(QObject *parent = 0);

    QDate date() const;
    void setDate(const QDate &date);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

signals:
    void dateChanged();

private:
    QDate m_date;
};

#endif // SQLPLANTINGMODEL_H