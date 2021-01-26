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

#include <QAbstractListModel>
class Qrop;

class FamilyModel2 : public QAbstractListModel
{
    static const QHash<int, QByteArray> sRoleNames;

public:
    explicit FamilyModel2(Qrop *qrop, QObject *parent = nullptr);

    enum FamilyRole { name = Qt::UserRole, interval, color, id };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override { return sRoleNames; }

private:
    Qrop *m_qrop;
};

#endif // FAMILYTABLE_H
