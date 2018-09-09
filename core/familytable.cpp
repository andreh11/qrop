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

#include "sqltablemodel.h"
#include "familytable.h"

FamilyTable::FamilyTable(QObject *parent)
    : SqlTableModel(parent)
{
    setTable("family");
}

void FamilyTable::add(const QString &name, const QString &color)
{
    QSqlRecord rec = record();
    rec.setValue("name", name);
    rec.setValue("color", color);
    insertRecord(-1, rec);
    submitAll();
}
