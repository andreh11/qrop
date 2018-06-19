#ifndef SQLPLANTINGMODEL_H
#define SQLPLANTINGMODEL_H

#include <QSqlTableModel>

class SqlPlantingModel : public QSqlTableModel
{
    Q_OBJECT

public:
    SqlPlantingModel(QObject *parent = 0);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
};

#endif // SQLPLANTINGMODEL_H
