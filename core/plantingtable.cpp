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

#include "plantingtable.h"

#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QDate>

static const char *plantingTableName = "planting";

PlantingTable::PlantingTable(QObject *parent)
    : SqlTableModel(parent)
{

//    connect(this, SIGNAL(primeInsert(int, QSqlRecord&)),
//            this, SLOT(createTasks(int, QSqlRecord&)));
    setTable(plantingTableName);
    setSortColumn("seeding_date", "ascending");
    select();
}

// IMPLEMENT THIS!!
void PlantingTable::add(QHash<QString, QVariant> hash)
{
    QSqlRecord rec = record();
    foreach (const QString key, hash.keys())
        if (key != "planting_date")
            rec.setValue(key, hash.value(key));
    insertRecord(-1, rec);
    submitAll();

    int id = query().lastInsertId().toInt();
    createTasks(id);
}

// Might not be needed...
void PlantingTable::createTasks(int id)
{
    qDebug() << "New planting_id: " << id;
}

QVariant PlantingTable::data(const QModelIndex &index, int role) const
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

QString PlantingTable::crop() const
{
    return m_crop;
}

void PlantingTable::setCrop(const QString &crop)
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
