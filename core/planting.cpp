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
#include <QDebug>
#include <QSqlRecord>
#include <QVariantMap>

#include "planting.h"
#include "task.h"

Planting::Planting(QObject *parent)
    : DatabaseUtility(parent),
      task(new Task(this))
{
    m_table = "planting";
}

int Planting::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString = newMap.take("planting_date").toString();
    qDebug() << "PLANTING DATE" <<  plantingDateString;
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);

    int id = DatabaseUtility::add(map);
    task->createTasks(id, plantingDate);
    return id;
}

QList<int> Planting::addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const
{
    QDate date = QDate::fromString(map["planting_date"].toString(), Qt::ISODate);
    QList<int> ids;
    QVariantMap newMap(map);

    QSqlDatabase::database().transaction();
    for (int i = 0; i < successions; i++) {
        newMap["planting_date"] = date.toString(Qt::ISODate);
        ids.append(add(newMap));
        date = date.addDays(weeksBetween * 7);
    }
    QSqlDatabase::database().commit();

    return ids;
}

void Planting::update(int id, const QVariantMap &map) const
{
    QVariantMap newMap(map);
    QString plantingDateString = newMap.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);
    DatabaseUtility::update(id, newMap);
    task->updateTaskDates(id, plantingDate);
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
