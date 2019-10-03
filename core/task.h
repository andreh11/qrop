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

#ifndef TASK_H
#define TASK_H

#include <QDate>

#include "core_global.h"
#include "databaseutility.h"

class QSettings;

class CORESHARED_EXPORT Task : public DatabaseUtility
{
    Q_OBJECT
public:
    Task(QObject *parent = nullptr);

    Q_INVOKABLE std::pair<int, int> sowPlantTaskIds(int plantingId) const;

    Q_INVOKABLE int add(const QVariantMap &map) const override;
    Q_INVOKABLE QList<int> addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const;
    Q_INVOKABLE void update(int id, const QVariantMap &map) const override;
    Q_INVOKABLE void addPlanting(int plantingId, int taskId) const;
    Q_INVOKABLE void removePlanting(int plantingId, int taskId) const;

    Q_INVOKABLE QString type(int taskId) const;
    Q_INVOKABLE QString method(int taskId) const;
    Q_INVOKABLE QString implement(int taskId) const;
    Q_INVOKABLE QString description(int taskId) const;
    Q_INVOKABLE QString color(int taskId) const;
    Q_INVOKABLE QDate assignedDate(int taskId) const;
    Q_INVOKABLE int duration(int taskId) const;

    Q_INVOKABLE void createTasks(int plantingId, const QDate &plantingDate) const;

    Q_INVOKABLE void completeTask(int taskId, const QDate &date) const;
    Q_INVOKABLE void completeTask(int taskId) const { completeTask(taskId, QDate::currentDate()); }
    Q_INVOKABLE void uncompleteTask(int taskId) const;
    bool isComplete(int taskId) const;

    Q_INVOKABLE void delay(int taskId, int weeks);
    Q_INVOKABLE QList<int> plantingTasks(int plantingId) const;
    Q_INVOKABLE QList<int> taskPlantings(int taskId) const;
    Q_INVOKABLE void updateTaskDates(int plantingId, const QDate &plantingDate) const;
    Q_INVOKABLE void duplicatePlantingTasks(int sourcePlantingId, int newPlantingId) const;
    Q_INVOKABLE void removePlantingTasks(int plantingId) const;

    int createNurseryTask(int plantingId, const QDate &plantingDate, int dtt) const;
    Q_INVOKABLE void removeNurseryTask(int plantingId) const;

    Q_INVOKABLE void addLocation(int locationId, int taskId) const;
    Q_INVOKABLE void removeLocation(int locationId, int taskId) const;
    Q_INVOKABLE QList<int> locationTasks(int locationId) const;
    Q_INVOKABLE QList<int> taskLocations(int taskId) const;
    Q_INVOKABLE void duplicateLocationTasks(int sourceLocationId, int newLocationId) const;
    Q_INVOKABLE void removeLocationTasks(int locationId) const;

    int greenhouseSowingTask(int plantingId) const;
    int plantingTask(int plantingId) const;
    void updateType(int taskId, TaskType type) const;

    std::pair<QDate, int> assignedDateAndLinkTask(int plantingId, const QVariantMap &map) const;
    void updateLinkedTask(int plantingId, int taskId, QVariantMap &map) const;
    void updateHarvestLinkedTasks(int taskId) const;
    QList<int> uncompletedHarvestLinkedTasks(int plantingId) const;

    Q_INVOKABLE QVariantMap drawInfoMap(int taskId, int season, int year) const;

private:
    int typeId(int taskId) const;
    QSettings *mSettings;
};

#endif // TASK_H
