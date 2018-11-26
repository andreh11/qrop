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

#ifndef TASKMETHODMODEL_H
#define TASKMETHODMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT TaskMethodModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int typeId READ typeId WRITE setTypeId NOTIFY typeIdChanged)

public:
    TaskMethodModel(QObject *parent = nullptr, const QString &tableName = "task_method");

    int typeId() const;
    void setTypeId(int typeId);

private:
    int m_typeId;

signals:
    void typeIdChanged();
};

#endif // TASKMETHODMODEL_H
