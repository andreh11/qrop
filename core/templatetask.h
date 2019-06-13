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

#ifndef TEMPLATE_TASK_H
#define TEMPLATE_TASK_H

#include <QDate>

#include "core_global.h"
#include "databaseutility.h"

class Task;

class CORESHARED_EXPORT TemplateTask : public DatabaseUtility
{
    Q_OBJECT
public:
    TemplateTask(QObject *parent = nullptr);
    Q_INVOKABLE int add(const QVariantMap &map) const override;
    Q_INVOKABLE QList<int> addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const;
    Q_INVOKABLE void update(int id, const QVariantMap &map) const override;
    Q_INVOKABLE void updateTasks(int templateTaskId) const;
    Q_INVOKABLE void addToCurrentApplications(int templateTaskId) const;
    Q_INVOKABLE void removeFromCurrentApplications(int templateTaskId) const;

    Q_INVOKABLE void apply(int templateTaskId, int plantingId) const;
    Q_INVOKABLE void applyList(int templateTaskId, QList<int> plantingIdList) const;
    //    Q_INVOKABLE void unapply(int templateTaskId, int plantingId) const;
    //    Q_INVOKABLE void unapplyList(int templateTaskId, QList<int> plantingIdList) const;

private:
    Task *mTask;
    int templateId(int templateTaskId) const;
    QList<int> plantings(int templateTaskId) const;
    QList<int> uncompletedTasks(int templateTaskId) const;
    int uncompletedPlantingTask(int templateTaskId, int plantingId) const;
    QVariantMap removeInvalidIds(const QVariantMap &map) const;
};

#endif // TEMPLATE_TASK_H
