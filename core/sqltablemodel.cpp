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
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

#include "sqltablemodel.h"

SqlTableModel::SqlTableModel(QObject *parent)
    : QSqlRelationalTableModel(parent)
{
    setEditStrategy(QSqlTableModel::OnManualSubmit);
}

bool SqlTableModel::insertRecord(int row, const QSqlRecord &record)
{
    bool ok = QSqlTableModel::insertRecord(row, record);
    if (!ok)
        qWarning() << "Couldn't insert record" << record << "in database:"
                   << query().lastError().text();
    return ok;
}

// Return last inserted rowid.
int SqlTableModel::add(QVariantMap map)
{
    if (tableName().isNull())
        return -1;
    if (map.isEmpty())
        return -1;

    QSqlRecord rec = record();
    foreach (const QString key, map.keys())
        rec.setValue(key, map.value(key));
    insertRecord(-1, rec);
    submitAll();

    int id = query().lastInsertId().toInt();
    return id;
}

// Return last inserted rowid.
void SqlTableModel::update(int id, QVariantMap map)
{
    if (id < 0)
        return;
    if (tableName().isNull())
        return;
    if (map.isEmpty())
        return;

    QString idFieldName = tableName() + "_id";
    QString queryString = QString("UPDATE %1 SET ").arg(tableName());
    foreach (const QString key, map.keys())
        queryString.append(QString("%1 = \"%2\",").arg(key).arg(map[key].toString()));
    queryString.chop(1); // remove last comma
    queryString.append(QString(" WHERE %1 = %2").arg(idFieldName).arg(id));

    QSqlQuery query(queryString);
    query.exec();
    debugQuery(query);
}

// Return last inserted rowid.
int SqlTableModel::duplicate(int id)
{
    if (tableName().isNull())
        return -1;

    QString idFieldName = tableName() + "_id";
    QSqlRecord rec = recordFromId(id, tableName(), idFieldName);
    QSqlRecord dupRecord(rec);
    dupRecord.remove(dupRecord.indexOf(idFieldName));
    insertRecord(-1, dupRecord);
    qDebug() << "Dup record" << dupRecord;
    submitAll();

    select();
    int newId = query().lastInsertId().toInt();
    return newId;
}

void SqlTableModel::duplicate(QList<int> idList)
{
    QSqlDatabase::database().transaction();
    foreach (int id, idList)
        duplicate(id);
    QSqlDatabase::database().commit();
}

void SqlTableModel::remove(int id)
{
    QString queryString = "DELETE FROM %1 WHERE %2 = %3";
    QString table = tableName();
    QString idColumnName = table + "_id";
    QSqlQuery query(queryString.arg(table).arg(idColumnName).arg(id));
    query.exec();
    debugQuery(query);
}

void SqlTableModel::remove(QList<int> idList)
{
    QSqlDatabase::database().transaction();
    foreach (int id, idList)
        remove(id);
    QSqlDatabase::database().commit();
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    value = sqlRecord.value(role - Qt::UserRole);

    return value;
}

int SqlTableModel::fieldColumn(const QString &field) const
{
    return m_rolesIndexes[field];
}

void SqlTableModel::debugQuery(const QSqlQuery& query)
{
    if (query.lastError().type() == QSqlError::ErrorType::NoError) {
        qDebug() << "Query OK: " << query.lastQuery();
    } else {
        qWarning() << "Query ERROR: " << query.lastError().text();
        qWarning() << "Query text: " << query.lastQuery();
    }
}

QSqlRecord SqlTableModel::recordFromId(int id, const QString &tableName,
                                       const QString &idFieldName) const
{
    QString queryString("SELECT * from %1 WHERE %2 = %3");
    QSqlQuery query(queryString.arg(tableName).arg(idFieldName).arg(id));
    query.exec();
    debugQuery(query);

    query.next();
    if (query.isValid())
        return query.record();
    else
        return record();
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    for (int i = 0; i < this->record().count(); i ++)
        roles.insert(Qt::UserRole + i, record().fieldName(i).toUtf8());

    return roles;
}

// order must be "ascending" or "descending"
void SqlTableModel::setSortColumn(const QString fieldName, const QString order)
{
    if (!m_rolesIndexes.contains(fieldName)) {
        qDebug() << "m_rolesIndexes doesn't have key" << fieldName;
        return;
    }
    setSort(m_rolesIndexes[fieldName],
            order == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    select();
}

void SqlTableModel::setTable(const QString &tableName)
{
    QSqlTableModel::setTable(tableName);
    buildRolesIndexes();
    select();
}

bool SqlTableModel::submitAll()
{
   bool ok = QSqlTableModel::submitAll();
   if (!ok)
       qFatal("Cannot submit pending changes to database: %s",
              qPrintable(lastError().text()));

   return ok;
}

void SqlTableModel::buildRolesIndexes()
{
    for (int i = 0; i < this->record().count(); i++)
        m_rolesIndexes.insert(record().fieldName(i).toUtf8(), i);
}
