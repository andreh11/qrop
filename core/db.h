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

class CORESHARED_EXPORT DatabaseUtility : public QObject {
    Q_OBJECT
public:
    enum PlantingType {
        DirectSeeded,
        TransplantRaised,
        TransplantBought
    };

    enum TaskType {
        DirectSow = 1,
        GreenhouseSow,
        Transplant
    };

    enum TemplateDateType {
        FieldSowPlant = 1,
        GreenhouseStart,
        FirstHarvest,
        LastHarvest
    };
    DatabaseUtility(QObject *parent = nullptr);
    QString table() const;
    QString idFieldName() const;
    void debugQuery(const QSqlQuery &query) const;

    QList<int> queryIds(const QString &queryString, const QString &idFieldName) const;
    QSqlRecord recordFromId(const QString &tableName, int id) const;
    QVariantMap mapFromRecord(const QSqlRecord &record) const;
    QVariantMap mapFromId(const QString &tableName, int id) const;

    int add(QVariantMap map) const;
    void addLink(const QString &table,
                 const QString &field1, int id1,
                 const QString &field2, int id2) const;

    void update(int id, QVariantMap map) const;
//    void update(QList<int> ids, QVariantMap map);

    int duplicate(int id) const;
    void duplicate(const QList<int> &idList) const;

    void remove(int id) const;
    void remove(const QList<int> &idList) const;
    void removeLink(const QString &table,
                    const QString &field1, int id1,
                    const QString &field2, int id2) const;
protected:
    QString m_table;
};

class CORESHARED_EXPORT Task : public DatabaseUtility {
    Q_OBJECT
public:
    Task(QObject *parent = nullptr);
    Q_INVOKABLE QList<int> sowPlantTaskIds(int plantingId) const;
    Q_INVOKABLE void addPlanting(int plantingId, int taskId) const;
    Q_INVOKABLE void removePlanting(int plantingId, int taskId) const;
    Q_INVOKABLE void createTasks(int plantingId, const QDate &plantingDate) const;
    Q_INVOKABLE QList<int> plantingTasks(int plantingId) const;
    Q_INVOKABLE void updateTaskDates(int plantingId, const QDate &plantingDate) const;
    Q_INVOKABLE int duplicateTasks(int sourcePlantingId, int newPlantingId) const;
    Q_INVOKABLE void removeTasks(int plantingId) const;

    Q_INVOKABLE void addLocation(int locationId, int taskId) const;
    Q_INVOKABLE void removeLocation(int locationId, int taskId) const;
    Q_INVOKABLE QList<int> locationTasks(int locationId) const;

    Q_INVOKABLE void applyTemplate(int templateId, int plantingId) const;
    Q_INVOKABLE void removeTemplate(int templateId, int plantingId) const;

private:
    QList<int> templateTasks(int templateId) const;
};

class CORESHARED_EXPORT Planting : public DatabaseUtility {
    Q_OBJECT
public:
    Planting(QObject *parent = nullptr);
    Q_INVOKABLE int add(QVariantMap map) const;
    Q_INVOKABLE QList<int> addSuccessions(int successions, int daysBetween, QVariantMap map) const;
    Q_INVOKABLE void update(int id, QVariantMap map) const;
    Q_INVOKABLE int duplicate(int id) const;

    // temporary: we'll use a SQLITE view
    Q_INVOKABLE QString varietyName(int id) const;
    Q_INVOKABLE QString cropName(int id) const;
private:
    Task task;
//    void duplicate(const QList<int> &idList);
//    void remove(const QList<int> &idList);
};

class CORESHARED_EXPORT Location : public DatabaseUtility {
    Q_OBJECT
public:
    Location(QObject *parent = nullptr);
//    Q_INVOKABLE int duplicate(int id) { return db.duplicate(id); } // TODO: duplicate children

    Q_INVOKABLE QString fullName(int locationId) const;
    Q_INVOKABLE QList<QSqlRecord> locations(int plantingId) const;
    Q_INVOKABLE QList<int> children(int locationId) const;
    Q_INVOKABLE void addPlanting(int plantingId, int locationId) const;
    Q_INVOKABLE void removePlanting(int plantingId, int locationId) const;
    Q_INVOKABLE void removePlantingLocations(int plantingId) const;
};

class CORESHARED_EXPORT Note : public DatabaseUtility {
    Q_OBJECT
public:
    Note(QObject *parent = nullptr);
};

class CORESHARED_EXPORT Keyword : public DatabaseUtility {
    Q_OBJECT
    Keyword(QObject *parent = nullptr);
};

class CORESHARED_EXPORT Expense : public DatabaseUtility {
    Q_OBJECT
    Expense(QObject *parent = nullptr);
};

class CORESHARED_EXPORT User : public DatabaseUtility {
    Q_OBJECT
    User(QObject *parent = nullptr);
};

#endif // DB_H
