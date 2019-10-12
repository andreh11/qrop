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

#ifndef TASKTEMPLATEMODEL_H
#define TASKTEMPLATEMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class TaskTemplate;

class CORESHARED_EXPORT TaskTemplateModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QList<int> plantingIdList READ plantingIdList WRITE setPlantingIdList NOTIFY plantingIdListChanged)

public:
    TaskTemplateModel(QObject *parent = nullptr, const QString &tableName = "task_template");
    QVariant data(const QModelIndex &idx, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QList<int> plantingIdList() const;
    void setPlantingIdList(const QList<int> &idList);
    Q_INVOKABLE void toggle(int row);

signals:
    void plantingIdListChanged();

private:
    enum { AppliedRole = Qt::UserRole + 100 };
    QList<int> m_plantingIdList;
    QList<int> m_plantingTemplateList;
    TaskTemplate *mTaskTemplate;
    bool isApplied(int templateId) const;
    void refreshTemplateList();
};

#endif // TASKTEMPLATEMODEL_H
