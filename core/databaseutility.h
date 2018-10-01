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

#endif // DATABASEUTILITY_H
