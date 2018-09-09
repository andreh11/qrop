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
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

#include "sqltablemodel.h"

SqlTableModel::SqlTableModel(QObject *parent)
    : QSqlRelationalTableModel(parent)
{
    setEditStrategy(QSqlTableModel::OnManualSubmit);
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    value = sqlRecord.value(role - Qt::UserRole);

    return value;
}

int SqlTableModel::fieldColumn(const QString &field) const
{
    return m_rolesIndexes[field];
}

QSqlRecord SqlTableModel::recordFromId(int id, QString tableName, QString idFieldName) const
{
    QSqlQuery query;
    query.prepare("SELECT * FROM :table where :field = :id");
    query.bindValue(":table", tableName);
    query.bindValue(":field", idFieldName);
    query.bindValue(":id", id);
    query.exec();

    if (query.next())
        return query.record();
    else
        return record();
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    for (int i = 0; i < this->record().count(); i ++)
        roles.insert(Qt::UserRole + i, record().fieldName(i).toUtf8());

    return roles;
}

// order must be "ascending" or "descending"
void SqlTableModel::setSortColumn(const QString fieldName, const QString order)
{
    if (!m_rolesIndexes.contains(fieldName)) {
        qDebug() << "m_rolesIndexes doesn't have key" << fieldName;
        return;
    }
    setSort(m_rolesIndexes[fieldName],
            order == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    select();
}

void SqlTableModel::setTable(const QString &tableName)
{
    QSqlTableModel::setTable(tableName);
    buildRolesIndexes();
    select();
}

bool SqlTableModel::submitAll()
{
   bool ok = QSqlTableModel::submitAll();
   if (!ok)
       qFatal("Cannot submit pending changes to database: %s",
              qPrintable(lastError().text()));

   return ok;
}

void SqlTableModel::buildRolesIndexes()
{
    for (int i = 0; i < this->record().count(); i++)
        m_rolesIndexes.insert(record().fieldName(i).toUtf8(), i);
}
