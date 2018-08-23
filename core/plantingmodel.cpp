/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QDate>
#include <QVariant>
#include <QString>
#include <QHash>

#include "plantingmodel.h"
#include "sqltablemodel.h"

static const char *plantingTableName = "planting";

PlantingModel::PlantingModel(QObject *parent)
    : SqlTableModel(parent)
{
    setTable(plantingTableName);
    for (int i = 0; i < this->record().count(); i++) {
        m_rolesIndexes.insert(record().fieldName(i).toUtf8(), i);
    }

//    setSort(1, Qt::AscendingOrder);
    setSortColumn("seeding_date", Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    select();
}

void PlantingModel::setSortColumn(const QString fieldName, const Qt::SortOrder order)
{
    if (!m_rolesIndexes.contains(fieldName)) {
        qDebug() << "m_rolesIndexes doesn't have key" << fieldName;
        return;
    }
    qDebug() << "New sort column: " << fieldName << m_rolesIndexes[fieldName] << order;
    setSort(m_rolesIndexes[fieldName], order);
    select();
}

QVariant PlantingModel::data(const QModelIndex &index, int role) const
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

QString PlantingModel::crop() const
{
    return m_crop;
}

void PlantingModel::setCrop(const QString &crop)
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

void PlantingModel::addPlanting(QString crop, QHash<QString, QVariant> values)
{
    Q_UNUSED(values)
    QSqlRecord r = record();
    r.setValue("crop", crop);

    if (!insertRecord(rowCount(), r)) {
        qWarning() << "Failed to send message:" << lastError().text();
        return;
    }

    if (!submitAll()) {
        qWarning() << "Failed to submit to DB:" << lastError().text();
        return;
    };

    qDebug() << "Added planting: " << crop;
    qInfo() << "Row count: " << rowCount();

}
