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

#ifndef DB_H
#define DB_H

#include <QObject>
#include <QSqlRecord>
#include <QSqlRelationalTableModel>
#include <QHash>
#include <QByteArray>

#include "core_global.h"

enum PlantingType {
    DirectSeeded,
    TransplantRaised,
    TransplantBought
};

enum TaskType {
    DirectSow,
    GreenhouseSow,
    Transplant
};

class DatabaseUtility {
public:
    DatabaseUtility(const QString &table);
    QString table() const;
    QString idFieldName() const;
    void debugQuery(const QSqlQuery &query) const;

    QSqlRecord recordFromId(const QString &tableName, int id) const;
    QVariantMap recordMap(const QSqlRecord &record) const;

    int add(QVariantMap map);
    void addLink(const QString &table,
                 const QString &field1, int id1,
                 const QString &field2, int id2);

    void update(int id, QVariantMap map);
//    void update(QList<int> ids, QVariantMap map);

    int duplicate(int id);
    void duplicate(const QList<int> &idList);

    void remove(int id);
    void remove(const QList<int> &idList);
    void removeLink(const QString &table,
                    const QString &field1, int id1,
                    const QString &field2, int id2);
private:
    QString m_table;
};

class Planting {
public:
    static int add(QVariantMap map);
    static QList<int> addSuccessions(int successions, int daysBetween, QVariantMap map);

    static void update(int id, QVariantMap map);

    static int duplicate(int id);
//    void duplicate(const QList<int> &idList);

    static void remove(int id);

//    void remove(const QList<int> &idList);

private:
    static QString m_table;
    static DatabaseUtility db;
};

class Task {
public:
    static int add(QVariantMap map) { return db.add(map); }
    static void update(int id, QVariantMap map) { db.update(id, map); }
    static int duplicate(int id) { return db.duplicate(id); }
    static void remove(int id) { db.remove(id); } // TODO: remove from planting_task, etc

    static void addPlantingTask(int plantingId, int taskId);

    static QList<QSqlRecord> tasks(int plantingId);
    static void createTasks(int plantingId, const QDate &plantingDate);
    static void updateTaskDates(int plantingId, const QDate &plantingDate);
    static int duplicateTasks(int sourcePlantingId, int newPlantingId);
    static void removeTasks(int plantingId);

    static void applyTemplate(int templateId, int plantingId);
    static void removeTemplate(int templateId, int plantingId);

private:
    static QString m_table;
    static DatabaseUtility db;
};

class Location : public DatabaseUtility {
public:
    static int add(QVariantMap map) { return db.add(map); }
    static void update(int id, QVariantMap map) { db.update(id, map); }
    static int duplicate(int id) { return db.duplicate(id); }
    static void remove(int id) { db.remove(id); } // TODO: remove from planting_task, etc

    static QList<QSqlRecord> locations(int plantingId);
    static void addPlanting(int plantingId, int locationId);
    static void removePlanting(int plantingId, int locationId);
    static void removePlantingLocations(int plantingId);

private:
    static QString m_table;
    static DatabaseUtility db;
};

class Note : public DatabaseUtility {
private:
    static QString m_table;
};

class Keyword : public DatabaseUtility {
private:
    static QString m_table;
};

class Expense : public DatabaseUtility {
private:
    static QString table();
};

class User : public DatabaseUtility {
private:
    static QString table();
};


#endif // DB_H
