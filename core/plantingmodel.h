#ifndef PLANTINGMODEL_H
#define PLANTINGMODEL_H

#include "sqltablemodel.h"
#include "core_global.h"

class CORESHARED_EXPORT PlantingModel : public SqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QString crop READ crop WRITE setCrop NOTIFY cropChanged)

public:
    PlantingModel(QObject *parent = nullptr);

    QString crop() const;
    void setCrop(const QString &crop);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    Q_INVOKABLE void setSortColumn(const QString fieldName, const Qt::SortOrder order);

    Q_INVOKABLE void addPlanting(QString crop, QHash<QString, QVariant> map);
    void duplicatePlanting(int row);
    void updatePlanting(int row, QHash<QString, QVariant> map);

signals:
    void cropChanged();

private:
    QString m_crop;
    QHash<QString, int> m_rolesIndexes;
    QHash<QModelIndex, bool> m_selected;
};

#endif // PLANTINGMODEL_H
