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

DatabaseUtility::DatabaseUtility(QObject *parent)
    : QObject(parent),
      m_table("")
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

QList<int> DatabaseUtility::queryIds(const QString &queryString, const QString &idFieldName) const
{
    QSqlQuery query(queryString);
    debugQuery(query);

    QList<int> list;
    int id = -1;
    while (query.next()) {
        id = query.value(idFieldName).toInt();
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

int DatabaseUtility::add(QVariantMap map) const
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
                              const QString &field2, int id2) const
{
    QString queryString = "INSERT INTO %1(%2,%3) VALUES (%4,%5)";
    QSqlQuery query(queryString.arg(table, field1, field2).arg(id1).arg(id2));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::update(int id, QVariantMap map) const
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

void DatabaseUtility::duplicate(const QList<int> &idList) const
{
    QSqlDatabase::database().transaction();
    foreach (int id, idList)
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

void DatabaseUtility::removeLink(const QString &table,
                                 const QString &field1, int id1,
                                 const QString &field2, int id2) const
{
    QString queryString = "DELETE FROM %1 WHERE %2 = %3 AND %4 = %5";
    QSqlQuery query(queryString.arg(table, field1).arg(id1).arg(field2).arg(id2));
    query.exec();
    debugQuery(query);
}

void DatabaseUtility::remove(const QList<int> &idList) const
{
    QSqlDatabase::database().transaction();
    foreach (int id, idList)
        remove(id);
    QSqlDatabase::database().commit();
}

// Planting

Planting::Planting(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "planting";
}

QString Planting::varietyName(int id) const
{
    QSqlRecord plantingRecord = recordFromId("planting", id);
    int varietyId = plantingRecord.value("variety_id").toInt();
    QSqlRecord varietyRecord = recordFromId("variety", varietyId);
    return varietyRecord.value("variety").toString();
}

QString Planting::cropName(int id) const
{
    QSqlRecord plantingRecord = recordFromId("planting", id);
    int varietyId = plantingRecord.value("variety_id").toInt();
    QSqlRecord varietyRecord = recordFromId("variety", varietyId);
    int cropId = varietyRecord.value("crop_id").toInt();
    QSqlRecord cropRecord = recordFromId("crop", cropId);

    return cropRecord.value("crop").toString();
}

int Planting::add(QVariantMap map) const
{
    QString plantingDateString = map.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);

    int id = DatabaseUtility::add(map);
    task.createTasks(id, plantingDate);
    return id;
}

QList<int> Planting::addSuccessions(int successions, int daysBetween, QVariantMap map) const
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

void Planting::update(int id, QVariantMap map) const
{
    QString plantingDateString = map.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    DatabaseUtility::update(id, map);
    task.updateTaskDates(id, plantingDate);
}

//void Planting::update(QList<int> ids, QVariantMap map)
//{
//}

int Planting::duplicate(int id) const
{
    if (id < 0)
        return -1;

    QVariantMap map = mapFromId("planting", id);
    map.remove(idFieldName());

    return add(map);
}

// Task

Task::Task(QObject *parent)
    : DatabaseUtility(parent)
{
      m_table = "task";
}

void Task::addPlanting(int plantingId, int taskId) const
{
    addLink("planting_task", "planting_id", plantingId, "task_id", taskId);
}

void Task::removePlanting(int plantingId, int taskId) const
{
    removeLink("planting_task", "planting_id", plantingId, "task_id", taskId);
}

void Task::addLocation(int locationId, int taskId) const
{
    addLink("location_task", "location_id", locationId, "task_id", taskId);
}

void Task::removeLocation(int locationId, int taskId) const
{
    removeLink("location_task", "location_id", locationId, "task_id", taskId);
}

void Task::duplicateLocationTasks(int sourceLocationId, int newLocationId) const
{
    qDebug() << "[Task] Duplicate tasks of location" << sourceLocationId
             << "for" << newLocationId;

    QList<int> sourceTasks = locationTasks(sourceLocationId);
    QVariantMap map;
    int newTaskId;
    foreach (const int taskId, sourceTasks) {
        map = mapFromId("task", taskId);
        map.remove("task_id");
        newTaskId = add(map);
        addLocation(newLocationId, newTaskId);
    }
}

void Task::removeLocationTasks(int locationId) const
{
    qDebug() << "[Task] Removing tasks for location: " << locationId;
    QString queryString("DELETE FROM location_task WHERE location_id = %1");
    QSqlQuery query(queryString.arg(locationId));
    debugQuery(query);
}

QList<int> Task::plantingTasks(int plantingId) const
{

    QString queryString = "SELECT * FROM planting_task WHERE planting_id = %1";
    return queryIds(queryString.arg(plantingId), "task_id");
}

QList<int> Task::locationTasks(int locationId) const
{

    QString queryString = "SELECT * FROM location_task WHERE location_id = %1";
    return queryIds(queryString.arg(locationId), "task_id");
}

// TaskTypes: 0: DS, 1: GH sow, 2: TP
void Task::createTasks(int plantingId, const QDate &plantingDate) const
{
    qDebug() << "[Task] Creating tasks for planting: " << plantingId << plantingDate;

    QSqlRecord rec = recordFromId("planting", plantingId);
    auto type = static_cast<PlantingType>(rec.value("planting_type").toInt());
    int dtt = rec.value("dtt").toInt();

    switch(type) {
    case PlantingType::DirectSeeded: {
        int id = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                      {"task_type_id", 0}});
        addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
    case PlantingType::TransplantRaised: {
        QDate sowDate = plantingDate.addDays(-dtt);
        int sowId = add({{"assigned_date", sowDate.toString(Qt::ISODate)},
                         {"task_type_id", 1}});
        int plantId = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                           {"task_type_id", 2},
                           {"link_task_id", sowId}});
        addLink("planting_task", "planting_id", plantingId, "task_id", sowId);
        addLink("planting_task", "planting_id", plantingId, "task_id", plantId);
        break;
    }
    case PlantingType::TransplantBought:
        int id = add({{"assigned_date", plantingDate.toString(Qt::ISODate)},
                  {"task_type_id", 2}});
        addLink("planting_task", "planting_id", plantingId, "task_id", id);
        break;
    }
}

QList<int> Task::sowPlantTaskIds(int plantingId) const
{
    int sowTaskId = -1;
    int transplantTaskId = -1;
    TaskType taskType;
    QSqlRecord record ;
    foreach (int taskId, plantingTasks(plantingId)) {
        record = recordFromId("task", taskId);
        taskType = static_cast<TaskType>(record.value("task_type_id").toInt());

        if (taskType == TaskType::DirectSow) {
            sowTaskId = taskId;
        } else if (taskType == TaskType::GreenhouseSow) {
            sowTaskId = taskId;
            if (transplantTaskId > 0)
                break;
        } else if (taskType == TaskType::Transplant) {
            transplantTaskId = taskId;
            if (sowTaskId > 0)
                break;
        }
    }

    return QList<int>({sowTaskId, transplantTaskId});
}

void Task::updateTaskDates(int plantingId, const QDate &plantingDate) const
{
    qDebug() << "[Task] Updating sow & plant tasks for planting: " << plantingId << plantingDate;

    QSqlRecord plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());
    QList<int> taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

    switch (plantingType) {
    case PlantingType::DirectSeeded: {
        QString queryString = "UPDATE task SET assigned_date = %2 WHERE task_id = %3";
        QSqlQuery query(queryString.arg(plantingDate.toString(Qt::ISODate).arg(sowTaskId)));
        debugQuery(query);
        break;
    }
    case PlantingType::TransplantRaised: {
        int dtt = plantingRecord.value("dtt").toInt();
        QString sowDate = plantingDate.addDays(-dtt).toString(Qt::ISODate);

        QString queryString = "UPDATE task SET assigned_date = %2 WHERE task_id = %3";
        QSqlQuery query(queryString.arg(plantingDate.toString(Qt::ISODate).arg(sowTaskId)));
        debugQuery(query);

        QString linkQueryString("UPDATE task SET link_days = %1, "
                                "assigned_date = %2 WHERE task_id = %3");
        QSqlQuery linkQuery(queryString.arg(dtt).arg(plantingDate.toString(Qt::ISODate))
                            .arg(transplantTaskId));
        debugQuery(linkQuery);
        break;
    }
    case PlantingType::TransplantBought: {
        QString queryString = "UPDATE task SET assigned_date = %2 WHERE task_id = %3";
        QSqlQuery query(queryString.arg(plantingDate.toString(Qt::ISODate).arg(transplantTaskId)));
        debugQuery(query);
        break;
    }
    }
}

void Task::duplicatePlantingTasks(int sourcePlantingId, int newPlantingId) const
{
    qDebug() << "[Task] Duplicate tasks of planting" << sourcePlantingId
             << "for" << newPlantingId;

    QList<int> sourceTasks = plantingTasks(sourcePlantingId);
    QVariantMap map;
    int newTaskId;
    foreach (const int taskId, sourceTasks) {
        map = mapFromId("task", taskId);
        map.remove("task_id");
        newTaskId = add(map);
        addPlanting(newPlantingId, newTaskId);
    }
}

void Task::removePlantingTasks(int plantingId) const
{
    qDebug() << "[Task] Removing tasks for planting: " << plantingId;
    QString queryString("DELETE FROM planting_task WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

QList<int> Task::templateTasks(int templateId) const
{
    QString queryString("SELECT * FROM task WHERE task_template_id = %1");
    return queryIds(queryString.arg(templateId), "task_id");
}

void Task::applyTemplate(int templateId, int plantingId) const
{
    QSqlRecord plantingRecord = recordFromId("planting", plantingId);
    auto plantingType = static_cast<PlantingType>(plantingRecord.value("planting_type").toInt());

    QVariantMap map;
    QList<int> taskIds = sowPlantTaskIds(plantingId);
    int sowTaskId = taskIds[0];
    int transplantTaskId = taskIds[1];

    if (sowTaskId == -1 && transplantTaskId == -1) {
        qDebug() << Q_FUNC_INFO << "both sow task and tranplant task id are invalid";
        return;
    }

    foreach (int taskId, templateTasks(templateId)) {
        map = mapFromId("task", taskId);
        switch (map["template_date_type"].toInt()) {
        case TemplateDateType::FieldSowPlant:
            map["link_task_id"] = plantingType == PlantingType::DirectSeeded ? sowTaskId
                                                                             : transplantTaskId;
            break;
        case TemplateDateType::GreenhouseStart:
            map["link_task_id"] = plantingType == PlantingType::TransplantRaised ? sowTaskId
                                                                                 : -1;
            break;
        case TemplateDateType::FirstHarvest:
            map["link_task_id"] = -1;
            break;
        case TemplateDateType::LastHarvest:
            map["link_task_id"] = -1;
            break;
        }

        if (map["link_task_id"] != -1) {
            int id = add(map);
            addPlanting(plantingId, id);
        }
    }
}

void Task::removeTemplate(int templateId, int plantingId) const
{
    QString queryString("DELETE FROM task WHERE template_id = %1 "
                        "AND task_id IN "
                        "(SELECT task.task_id FROM task JOIN planting_task WHERE planting_id = %2");
    QSqlQuery query(queryString.arg(templateId).arg(plantingId));
    debugQuery(query);
}

// Location

Location::Location(QObject *parent)
    : DatabaseUtility(parent)
{
      m_table = "location";
}

QString Location::fullName(int locationId) const
{
    if (locationId < 1)
        return QString();
    QSqlRecord record = recordFromId("location", locationId);

    if (record.isEmpty())
        return QString();

    QString name = record.value("name").toString();
    while (!record.value("parent_id").isNull()) {
        record = recordFromId("location", record.value("parent_id").toInt());
        name = record.value("name").toString() + name;
    }
    return name;
}

QList<QSqlRecord> Location::locations(int plantingId) const
{
    QString queryString = "SELECT * FROM planting_location WHERE planting_id = %1";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);

    QList<QSqlRecord> recordList;
    int id = -1;
    while (query.next()) {
        id = query.value("location_id").toInt();
        recordList.append(recordFromId("location", id));
    }
    return recordList;
}

QList<int> Location::children(int locationId) const
{
    QString queryString("SELECT * FROM location WHERE parent_id = %1");
    return queryIds(queryString.arg(locationId), "location_id");
}

void Location::addPlanting(int plantingId, int locationId) const
{
    addLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

void Location::removePlanting(int plantingId, int locationId) const
{
    removeLink("planting_location", "planting_id", plantingId, "location_id", locationId);
}

void Location::removePlantingLocations(int plantingId) const
{
    QString queryString = "DELETE FROM planting_location WHERY planting_id = %1)";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

Note::Note(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "note";
}

Keyword::Keyword(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "keyword";
}

Expense::Expense(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "expense";
}

User::User(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "user";
}
