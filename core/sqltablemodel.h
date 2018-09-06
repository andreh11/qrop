#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QObject>
#include <QSqlTableModel>
#include <QHash>
#include <QByteArray>

class SqlTableModel : public QSqlTableModel
{
    Q_OBJECT

public:
    SqlTableModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    void setTable(const QString &tableName) Q_DECL_OVERRIDE;
    Q_INVOKABLE void setSortColumn(const QString fieldName, const QString order);

private:
    QHash<QString, int> m_rolesIndexes;

    void buildRolesIndexes();
};

#endif // SQLTABLEMODEL_H
