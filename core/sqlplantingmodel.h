#ifndef SQLPLANTINGMODEL_H
#define SQLPLANTINGMODEL_H

#include <QSqlTableModel>

class SqlPlantingModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QString crop READ crop WRITE setCrop NOTIFY cropChanged)

public:
    SqlPlantingModel(QObject *parent = nullptr);

    QString crop() const;
    void setCrop(const QString &crop);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    Q_INVOKABLE void setSortColumn(const QString fieldName, const QString order);

signals:
    void cropChanged();

private:
    QString m_crop;
    QHash<QString, int> m_rolesIndexes;
    QHash<QModelIndex, bool> m_selected;
};

#endif // SQLPLANTINGMODEL_H
