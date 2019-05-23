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

#ifndef TASKTEMPLATE_H
#define TASKTEMPLATE_H

#include <QDate>

#include "core_global.h"
#include "databaseutility.h"

class Planting;
class Task;
class TemplateTask;

class CORESHARED_EXPORT TaskTemplate : public DatabaseUtility
{
    Q_OBJECT
public:
    TaskTemplate(QObject *parent = nullptr);
    Q_INVOKABLE int duplicate(int id) const override;

    Q_INVOKABLE void apply(int templateId, int plantingId, bool transaction = false) const;
    Q_INVOKABLE void applyList(int templateId, QList<int> plantingIdList) const;
    Q_INVOKABLE void unapply(int templateId, int plantingId) const;
    Q_INVOKABLE void unapplyList(int templateId, QList<int> plantingIdList) const;

    Q_INVOKABLE void updateTemplateTasks(int taskId, const QVariantMap &map) const;
    Q_INVOKABLE void removeUncompletedTasks(int templateId) const;
    QList<int> plantingTemplates(int plantingId) const;
    QList<int> plantingsCommonTemplates(QList<int> plantingIdList) const;

private:
    Planting *mPlanting;
    Task *mTask;
    TemplateTask *mTemplateTask;
    QList<int> templateTasks(int templateId) const;
    QList<int> plantingTemplateTasks(int templateId, int plantingId) const;
    bool templateApplied(int templateId, int plantingId) const;
    QList<int> uncompletedPlantingTemplateTasks(int templateId, int plantingId) const;
    QList<int> uncompletedTasks(int templateId) const;
    void removeTemplateTasks(int templateId) const;
    void duplicateTemplateTasks(int fromId, int toId) const;
};

#endif // TASKTEMPLATE_H
