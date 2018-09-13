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
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QDate>

#include "plantingmodel.h"
#include "taskmodel.h"
#include "locationmodel.h"
#include "notemodel.h"
#include "keywordmodel.h"
#include "harvestmodel.h"
#include "expensemodel.h"

static const char *plantingTableName = "planting";

PlantingModel::PlantingModel(QObject *parent)
    : SqlTableModel(parent)
{
    setTable(plantingTableName);
    setSortColumn("seeding_date", "ascending");

//    int varietyColumn = fieldColumn("variety_id");
//    setRelation(varietyColumn, QSqlRelation("variety", "variety_id", "variety"));

    select();
}

int PlantingModel::add(QVariantMap map)
{
    QString plantingDateString = map.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);

    int id = SqlTableModel::add(map);
    TaskModel::createTasks(id, plantingDate);
    return id;
}

void PlantingModel::update(int id, QVariantMap map)
{
    QString plantingDateString = map.take("planting_date").toString();
    QDate plantingDate = QDate::fromString(plantingDateString, Qt::ISODate);

    SqlTableModel::update(id, map);
    TaskModel::updateTaskDates(id, plantingDate);
}

int PlantingModel::duplicate(int id)
{
    int newId = SqlTableModel::duplicate(id);
    TaskModel::duplicateTasks(id, newId);
//    KeywordModel::duplicatePlantingKeywords(id, newId);
    return newId;
}

void PlantingModel::remove(int id)
{
    SqlTableModel::remove(id);
    TaskModel::removeTasks(id);
    LocationModel::removePlantingLocations(id);
    NoteModel::removePlantingNotes(id);
//    KeywordModel::removePlantingKeywords(id);
//    HarvestModel::removePlantingHarvests(id);
//    ExpenseModel::removePlantingExpenses(id);
}

QVariant PlantingModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord rec = record(index.row());
    QVariant value = rec.value(role - Qt::UserRole);
    if ((Qt::UserRole + 9 <= role) && (role <= Qt::UserRole + 12))
        return QDate::fromString(value.toString(), Qt::ISODate);
    else
        return value;
}

QString PlantingModel::crop() const
{
    return m_crop;
}

void PlantingModel::setFilterCrop(const QString &crop)
{
   if (crop == m_crop)
       return;

   m_crop = crop;

    if (m_crop == "") {
        qInfo("[PlantingModel] null filter");
        setFilter("");
    } else {
        const QString filterString = QString::fromLatin1(
            "(crop LIKE '%%%1%%')").arg(crop);
        setFilter(filterString);
    }

    select();
    emit cropChanged();
}
