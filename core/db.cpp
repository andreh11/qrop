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

#include <QDate>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlField>
#include <QDebug>

#include "db.h"

DatabaseUtility::DatabaseUtility(const QString &table)
    : m_table(table)
{
}

QString DatabaseUtility::table() const
{
    return m_table;
}

QString DatabaseUtility::idFieldName() const
{
    return table() + "_id";
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
    else
        return QSqlRecord();
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

int DatabaseUtility::add(QVariantMap map)
{
    QString queryNameString = QString("INSERT INTO %1 (").arg(table());
    QString queryValueString = " VALUES (";
    foreach (const QString key, map.keys()) {
        if (key != idFieldName()) {
            queryNameString.append(QString(" %1,").arg(key));
            queryValueString.append(QString(" %1,").arg(map[key].toString()));
        }
    }

    // Remove last semicolons.
    queryNameString.chop(1);
    queryValueString.chop(1);

    queryNameString.append(")");
    queryValueString.append(")");

    QSqlQuery query(queryNameString + queryValueString);
    debugQuery(query);

    int newId = query.lastInsertId().toInt();
    return newId;
}

void DatabaseUtility::addLink(const QString &table,
                              const QString &field1, int id1,
                              const QString &field2, int id2)
{
    QString queryString = "INSERT INTO %1(%2,%3) VALUES (%4,%5)";
    QSqlQuery query(queryString.arg(table, field1, field2).arg(id1).arg(id2));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::update(int id, QVariantMap map)
{
    if (id < 0)
        return;
    if (table().isNull())
        return;
    if (map.isEmpty())
        return;

    QString queryString = QString("UPDATE %1 SET ").arg(table());
    foreach (const QString key, map.keys())
        queryString.append(QString("%1 = \"%2\",").arg(key).arg(map[key].toString()));
    queryString.chop(1); // remove last comma
    queryString.append(QString(" WHERE %1 = %2").arg(idFieldName()).arg(id));

    QSqlQuery query(queryString);
    query.exec();
    debugQuery(query);
}

int DatabaseUtility::duplicate(int id)
{
    if (id < 0)
        return -1;
    if (table().isNull())
        return - 1;

    QVariantMap map = mapFromId(table(), id);
    map.remove(idFieldName());

    return add(map);
}

void DatabaseUtility::duplicate(const QList<int> &idList)
{
    QSqlDatabase::database().transaction();
    foreach (int id, idList)
        duplicate(id);
    QSqlDatabase::database().commit();
}

void DatabaseUtility::remove(int id)
{
    QString queryString = "DELETE FROM %1 WHERE %2 = %3";
    QString idColumnName = table() + "_id";
    QSqlQuery query(queryString.arg(table()).arg(idColumnName).arg(id));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::removeLink(const QString &table,
                                 const QString &field1, int id1,
                                 const QString &field2, int id2)
{
    QString queryString = "DELETE FROM %1 WHERE %2 = %3 AND %4 = %5";
    QSqlQuery query(queryString.arg(table, field1).arg(id1).arg(field2).arg(id2));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::remove(const QList<int> &idList)
{
    QSqlDatabase::database().transaction();
    foreach (int id, idList)
        remove(id);
    QSqlDatabase::database().commit();
}

// Planting

DatabaseUtility Planting::db("planting");

int Planting::add(QVariantMap map)
{
    QString plantingDateString = map.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);

    int id = db.add(map);
    Task::createTasks(id, plantingDate);
    return id;
}

QList<int> Planting::addSuccessions(int successions, int daysBetween, QVariantMap map)
{
    QDate date = QDate::fromString(map["planting_date"].toString(), Qt::ISODate);
    QList<int> ids;

    QSqlDatabase::database().transaction();
    for (int i = 0; i < successions; i++) {
        map["planting_date"] = date.toString(Qt::ISODate);
        ids.append(add(map));
        date = date.addDays(daysBetween);
    }
    QSqlDatabase::database().commit();

    return ids;
}

void Planting::update(int id, QVariantMap map)
{
    QString plantingDateString = map.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);

    db.update(id, map);
    Task::updateTaskDates(id, plantingDate);
}

//void Planting::update(QList<int> ids, QVariantMap map)
//{
//}

int Planting::duplicate(int id)
{
    if (id < 0)
        return -1;

    QVariantMap map = db.mapFromId("planting", id);
    map.remove(db.idFieldName());

    return add(map);
}

// Task

DatabaseUtility Task::db("task");

QList<QSqlRecord> Task::tasks(int plantingId)
{
    QString queryString = "SELECT * FROM planting_task WHERE planting_id = %1";
    QSqlQuery query(queryString.arg(plantingId));
    db.debugQuery(query);

    QList<QSqlRecord> recordList;
    int id = -1;
    while (query.next()) {
        id = query.value("task_id").toInt();
        recordList.append(db.recordFromId("task", id));
    }
    return recordList;
}

// TaskTypes: 0: DS, 1: GH sow, 2: TP
void Task::createTasks(int plantingId, const QDate &plantingDate)
{
    qDebug() << "[Task] Creating tasks for planting: " << plantingId << plantingDate;

    QSqlRecord rec = db.recordFromId("planting", plantingId);
    auto type = static_cast<PlantingType>(rec.value("planting_type").toInt());
    int dtt = rec.value("dtt").toInt();

    switch(type) {
    case PlantingType::DirectSeeded: {
        int id = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                      {"task_type_id", 0}});
        db.addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
    case PlantingType::TransplantRaised: {
        QDate sowDate = plantingDate.addDays(-dtt);
        int sowId = add({{"assigned_date", sowDate.toString(Qt::ISODate)},
                         {"task_type_id", 1}});
        int plantId = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                           {"task_type_id", 2},
                           {"link_task_id", sowId}});
        db.addLink("planting_task", "planting_id", plantingId, "task_id", sowId);
        db.addLink("planting_task", "planting_id", plantingId, "task_id", plantId);
        break;
    }
    case PlantingType::TransplantBought:
        int id = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                  {"task_type_id", 2}});
        db.addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
}

void Task::updateTaskDates(int plantingId, const QDate &plantingDate)
{
    qDebug() << "[Task] Updating tasks for planting: " << plantingId << plantingDate;
    QSqlRecord plantingRecord = db.recordFromId("planting", plantingId);


    // Find planting task id.
    QVariantMap map;
    int plantingTaskId = -1;
    foreach (const QSqlRecord record, tasks(plantingId)) {
        map = db.mapFromRecord(record);
        if (map["task_type_id"].toInt() == 4) {
            plantingTaskId = map["task_id"].toInt();
            break;
        }
    }

    QString queryString = "UPDATE task SET link_days = %1, assigned_date = %2 WHERE task_id = %3";
    int dtt = plantingRecord.value("dtt").toInt();
    QString assignedDate = plantingDate.addDays(dtt).toString(Qt::ISODate);

    QSqlQuery query(queryString.arg(dtt).arg(assignedDate).arg(plantingTaskId));
    db.debugQuery(query);
}

//int Task::duplicateTasks(int sourcePlantingId, int newPlantingId)
//{
//    // TODO
//    qDebug() << "[Task] Duplicate tasks of planting" << sourcePlantingId
//             << "for" << newPlantingId;
//    return -1;
//}

//void Task::removeTasks(int plantingId)
//{
//    qDebug() << "[Task] Removing tasks for planting: " << plantingId;
//    QString queryString("DELETE FROM planting_task WHERE planting_id = %1");
//    QSqlQuery query(queryString.arg(plantingId));
//    db.debugQuery(query);
//}

void Task::applyTemplate(int templateId, int plantingId)
{
    // foreach task template in templateId
    // create task from template, linked to plantingId and templateId
}

void Task::removeTemplate(int templateId, int plantingId)
{
    QString queryString("DELETE FROM task WHERE template_id = %1 "
                        "AND task_id IN "
                        "(SELECT task.task_id FROM task JOIN planting_task WHERE planting_id = %2");
    QSqlQuery query(queryString.arg(templateId).arg(plantingId));
    db.debugQuery(query);
}

// Location

DatabaseUtility Location::db("location");

QList<QSqlRecord> Location::locations(int plantingId)
{
    QString queryString = "SELECT * FROM planting_location WHERE planting_id = %1";
    QSqlQuery query(queryString.arg(plantingId));
    db.debugQuery(query);

    QList<QSqlRecord> recordList;
    int id = -1;
    while (query.next()) {
        id = query.value("location_id").toInt();
        recordList.append(db.recordFromId("location", id));
    }
    return recordList;
}

void Location::addPlanting(int plantingId, int locationId)
{
    db.addLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

void Location::removePlanting(int plantingId, int locationId)
{
    db.removeLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

void Location::removePlantingLocations(int plantingId)
{
    QString queryString = "DELETE FROM planting_location WHERY planting_id = %1)";
    QSqlQuery query(queryString.arg(plantingId));
    db.debugQuery(query);
}
