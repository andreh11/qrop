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

#include <QDebug>
#include <QSqlError>
#include <QSqlField>
#include <QSqlRecord>

#include "databaseutility.h"

DatabaseUtility::DatabaseUtility(QObject *parent)
    : QObject(parent),
      m_table(""),
      m_idFieldName("")
{
}

void DatabaseUtility::rollback() const
{
    qDebug() << "Rolling back...";
    QSqlDatabase::database().rollback();
    qDebug() << QSqlDatabase::database().lastError().text();

}

QString DatabaseUtility::table() const
{
    return m_table;
}

void DatabaseUtility::setTable(const QString &table)
{
    m_table = table;
}

QString DatabaseUtility::idFieldName() const
{
    if (!m_idFieldName.isEmpty())
        return m_idFieldName;
    return table() + "_id";
}

void DatabaseUtility::setIdFieldName(const QString &name)
{
    m_idFieldName = name;
}

void DatabaseUtility::debugQuery(const QSqlQuery& query) const
{
    if (query.lastError().type() == QSqlError::ErrorType::NoError) {
        qDebug() << "Query OK: " << query.lastQuery();
    } else {
        qWarning() << "Query ERROR: " << query.lastError().text();
        qWarning() << "Query text: " << query.lastQuery();
    }
}

QList<int> DatabaseUtility::queryIds(const QString &queryString, const QString &idFieldName) const
{
    QSqlQuery query(queryString);
    debugQuery(query);

    QList<int> list;
    while (query.next()) {
        int id = query.value(idFieldName).toInt();
        list.append(id);
    }
    return list;
}

QSqlRecord DatabaseUtility::recordFromId(const QString &tableName, int id) const
{
    if (id < 0)
        return QSqlRecord();
    if (tableName.isNull())
        return QSqlRecord();

    QString queryString("SELECT * FROM %1 WHERE %2 = %3");
    QSqlQuery query(queryString.arg(tableName).arg(tableName + "_id").arg(id));
    query.exec();
    debugQuery(query);

    query.next();
    if (query.isValid())
        return query.record();

    return QSqlRecord();
}

QList<QSqlRecord> DatabaseUtility::recordListFromIdList(const QString &tableName,
                                                        const QList<int> &idList) const
{
    if (idList.length() < 1)
        return {};
    if (tableName.isNull())
        return {};

    QString queryString("SELECT * FROM %1 WHERE %2 in %3");
    QString ids = "(";
    int i;
    for (i = 0; i < idList.length() - 1; i++)
        ids.append(QString::number(idList[i]) + ", ");
    ids.append(QString::number(idList[i]) + ")");

    QSqlQuery query(queryString.arg(tableName).arg(tableName + "_id").arg(ids));
    query.exec();
    debugQuery(query);

    QList<QSqlRecord> recordList;
    while (query.next())
        if (query.isValid())
            recordList.push_back(query.record());

    return recordList;
}

QVariantMap DatabaseUtility::mapFromRecord(const QSqlRecord &record) const
{
    QVariantMap map;
    for (int i = 0; i < record.count(); i++)
        map[record.field(i).name()] = record.field(i).value();
    return map;
}

QVariantMap DatabaseUtility::mapFromId(const QString &tableName, int id) const
{
    return mapFromRecord(recordFromId(tableName, id));
}

QList<QVariantMap> DatabaseUtility::mapListFromIdList(const QString &tableName,
                                                      const QList<int> &idList) const
{
    QList<QVariantMap> mapList;
    QList<QSqlRecord> recordList = recordListFromIdList(tableName, idList);

    for (auto &record : recordList)
        if (!record.isEmpty())
            mapList.push_back(mapFromRecord(record));
    return mapList;
}

int DatabaseUtility::add(const QVariantMap &map) const
{
    QString queryNameString = QString("INSERT INTO %1 (").arg(table());
    QString queryValueString = " VALUES (";
    QString fieldName = idFieldName();

    for (const auto &key : map.keys())
        if (key != fieldName) {
            queryNameString.append(QString(" %1,").arg(key));
            queryValueString.append(QString(" :%1,").arg(key));
        }

    // Remove last semicolons.
    queryNameString.chop(1);
    queryValueString.chop(1);

    queryNameString.append(")");
    queryValueString.append(")");

    QString queryString = queryNameString + queryValueString;

    QSqlQuery query;
    query.prepare(queryString) ;

    for (const auto &key : map.keys())
        query.bindValue(QString(":%1").arg(key), map[key]);

    query.exec();
    debugQuery(query);

    int newId = query.lastInsertId().toInt();
    return newId;
}

void DatabaseUtility::addLink(const QString &table,
                              const QString &field1, int id1,
                              const QString &field2, int id2) const
{
    QString queryString = "INSERT INTO %1(%2,%3) VALUES (%4,%5)";
    QSqlQuery query(queryString.arg(table, field1, field2).arg(id1).arg(id2));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::update(int id, const QVariantMap &map) const
{
    if (id < 0)
        return;
    if (table().isNull())
        return;
    if (map.isEmpty())
        return;

    QString queryString = QString("UPDATE %1 SET ").arg(table());
    for (const auto &key : map.keys())
        queryString.append(QString(" %1 = :%1,").arg(key));
    queryString.chop(1); // remove last comma
    queryString.append(QString(" WHERE %1 = %2").arg(idFieldName()).arg(id));

    QSqlQuery query;
    query.setForwardOnly(true);
    query.prepare(queryString);
    for (const auto &key : map.keys())
        query.bindValue(QString(":%1").arg(key), map[key]);
    qDebug() << "QUERY STRING:" << queryString;
    qDebug() << "boundValues:"  << query.boundValues();

    query.exec();
    debugQuery(query);
}

void DatabaseUtility::updateList(const QList<int> &idList, const QVariantMap &map) const
{
    QSqlDatabase::database().transaction();
    for (const int id : idList)
        update(id, map);
    QSqlDatabase::database().commit();
}

int DatabaseUtility::duplicate(int id) const
{
    if (id < 0)
        return -1;
    if (table().isNull())
        return - 1;

    QVariantMap map = mapFromId(table(), id);
    map.remove(idFieldName());

    return add(map);
}

void DatabaseUtility::duplicateList(const QList<int> &idList) const
{
    qDebug() << "Batch duplicate:" << idList;
    QSqlDatabase::database().transaction();
    for (const int id : idList)
        duplicate(id);
    QSqlDatabase::database().commit();
}

void DatabaseUtility::remove(int id) const
{
    QString queryString = "DELETE FROM %1 WHERE %2 = %3";
    QString idColumnName = table() + "_id";
    QSqlQuery query(queryString.arg(table()).arg(idColumnName).arg(id));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::removeList(const QList<int> &idList) const
{
    qDebug() << "Batch remove:" << idList;
    QSqlDatabase::database().transaction();
    for (const int id : idList)
        remove(id);
    QSqlDatabase::database().commit();
}

void DatabaseUtility::removeLink(const QString &table,
                                 const QString &field1, int id1,
                                 const QString &field2, int id2) const
{
    QString queryString = "DELETE FROM %1 WHERE %2 = %3 AND %4 = %5";
    QSqlQuery query(queryString.arg(table, field1).arg(id1).arg(field2).arg(id2));
    query.exec();
    debugQuery(query);
}
