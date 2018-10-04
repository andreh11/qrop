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

#include <QDebug>
#include "usermodel.h"

UserModel::UserModel(QObject *parent)
    : SqlTableModel(parent)
{
    setTable("user");

    // BUG: create a query bug on submitAll() after insertRecord()
//    int roleColumn = fieldColumn("role_id");
//    qDebug() << "ROLE COLUMN" << roleColumn;
//    setRelation(roleColumn, QSqlRelation("role", "role_id", "role"));
}
