#include "sqlplantingmodel.h"

#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QDate>

static const char *plantingTableName = "planting";

SqlPlantingModel::SqlPlantingModel(QObject *parent)
    : QSqlTableModel(parent)
{
    setTable(plantingTableName);
    for (int i = 0; i < this->record().count(); i++) {
        m_rolesIndexes.insert(record().fieldName(i).toUtf8(), i);
    }

//    setSort(1, Qt::AscendingOrder);
    setSortColumn("seeding_date", "ascending");
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    select();

}

void SqlPlantingModel::setSortColumn(const QString fieldName, const QString order)
{
    if (!m_rolesIndexes.contains(fieldName)) {
        qDebug() << "m_rolesIndexes doesn't have key" << fieldName;
        return;
    }
    qDebug() << "New sort column: " << fieldName << m_rolesIndexes[fieldName];
    setSort(m_rolesIndexes[fieldName], order == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    select();
}

QVariant SqlPlantingModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    value = sqlRecord.value(role - Qt::UserRole);
    if ((Qt::UserRole + 9 <= role) && (role <= Qt::UserRole + 12))
        return QDate::fromString(value.toString(), Qt::ISODate);
    else
        return value;
}

QString SqlPlantingModel::crop() const
{
    return m_crop;
}

void SqlPlantingModel::setCrop(const QString &crop)
{
   if (crop == m_crop)
       return;

   m_crop = crop;

    if (m_crop == "") {
        qInfo("null!");
        setFilter("");
    } else {
        const QString filterString = QString::fromLatin1(
            "(crop LIKE '%%%1%%')").arg(crop);
        setFilter(filterString);
    }

    select();

    emit cropChanged();
}

QHash<int, QByteArray> SqlPlantingModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    for (int i = 0; i < this->record().count(); i ++)
        roles.insert(Qt::UserRole + i, record().fieldName(i).toUtf8());

    return roles;
}
