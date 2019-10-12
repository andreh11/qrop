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

#ifndef EXPENSECATEGORYMODEL_H
#define EXPENSECATEGORYMODEL_H

#include <QObject>

#include "core_global.h"
#include "sqltablemodel.h"

class CORESHARED_EXPORT ExpenseCategoryModel : public SqlTableModel
{
    Q_OBJECT

public:
    ExpenseCategoryModel(QObject *parent = nullptr);
};

#endif // EXPENSECATEGORYMODEL_H
