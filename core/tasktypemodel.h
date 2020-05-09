/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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

#ifndef TASKTYPEMODEL_H
#define TASKTYPEMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT TaskTypeModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool showPlantingTasks READ showPlantingTasks WRITE setShowPlantingTasks NOTIFY showPlantingTasksChanged)

public:
    TaskTypeModel(QObject *parent = nullptr, const QString &tableName = "task_type");

    bool showPlantingTasks() const;
    void setShowPlantingTasks(bool show);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    bool m_showPlantingTasks { true };
    bool isPlantingTask(int sourceRow, const QModelIndex &sourceParent) const;

signals:
    void showPlantingTasksChanged();
};

#endif // TASKTYPEMODEL_H
