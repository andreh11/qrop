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
    setSort(2, Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    select();
    qInfo("rows: %d", rowCount());
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
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "planting_id";
    names[Qt::UserRole + 1] = "crop";
    names[Qt::UserRole + 2] = "variety";
    names[Qt::UserRole + 3] = "family";
    names[Qt::UserRole + 4] = "unit";
    names[Qt::UserRole + 5] = "code";
    names[Qt::UserRole + 6] = "planting_type";
    names[Qt::UserRole + 7] = "comments";
    names[Qt::UserRole + 8] = "keywords";
    names[Qt::UserRole + 9] = "seeding_date";
    names[Qt::UserRole + 10] = "transplanting_date";
    names[Qt::UserRole + 11] = "beg_harvest_date";
    names[Qt::UserRole + 12] = "end_harvest_date";

    return names;
}
