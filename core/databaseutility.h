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

#ifndef DATABASEUTILITY_H
#define DATABASEUTILITY_H

#include <QObject>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QVariantMap>

#include "core_global.h"

enum class PlantingType { DirectSeeded = 1, TransplantRaised, TransplantBought };

enum class TaskType { DirectSow = 1, GreenhouseSow, Transplant };

enum class TemplateDateType { FieldSowPlant = 1, GreenhouseStart, FirstHarvest, LastHarvest };

class CORESHARED_EXPORT DatabaseUtility : public QObject
{
    Q_OBJECT
public:
    DatabaseUtility(QObject *parent = nullptr);

    QString table() const;
    void setTable(const QString &table);

    QString idFieldName() const;
    void setIdFieldName(const QString &fieldName);

    void debugQuery(const QSqlQuery &query) const;

    QList<int> queryIds(const QString &queryString, const QString &idFieldName) const;
    QSqlRecord recordFromId(const QString &tableName, int id) const;
    QList<QSqlRecord> recordListFromIdList(const QString &tableName, const QList<int> &idList) const;
    QVariantMap mapFromRecord(const QSqlRecord &record) const;
    Q_INVOKABLE QVariantMap mapFromId(const QString &tableName, int id) const;
    QList<QVariantMap> mapListFromIdList(const QString &tableName, const QList<int> &idList) const;

    virtual Q_INVOKABLE int add(const QVariantMap &map) const;
    void addLink(const QString &table, const QString &field1, int id1, const QString &field2,
                 int id2) const;

    virtual Q_INVOKABLE void update(int id, const QVariantMap &map) const;
    Q_INVOKABLE void updateList(const QList<int> &idList, const QVariantMap &map) const;

    virtual Q_INVOKABLE int duplicate(int id) const;
    Q_INVOKABLE void duplicateList(const QList<int> &idList) const;

    virtual Q_INVOKABLE void remove(int id) const;
    Q_INVOKABLE void removeList(const QList<int> &idList) const;
    void removeLink(const QString &table, const QString &field1, int id1, const QString &field2,
                    int id2) const;
    Q_INVOKABLE void rollback() const;

protected:
    QString m_table;
    QString m_idFieldName;
};

#endif // DATABASEUTILITY_H
