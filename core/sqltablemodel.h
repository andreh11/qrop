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

#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QObject>
#include <QSqlRecord>
#include <QSqlRelationalTableModel>
#include <QHash>
#include <QByteArray>

#include "core_global.h"

class CORESHARED_EXPORT SqlTableModel : public QSqlRelationalTableModel
{
    Q_OBJECT

public:
    SqlTableModel(QObject *parent = nullptr);

    Q_INVOKABLE int add(QVariantMap map);
    Q_INVOKABLE void update(int id, QVariantMap map);
    Q_INVOKABLE int duplicate(int id);
    Q_INVOKABLE void remove(int id);

    static void debugQuery(const QSqlQuery &query);
    bool insertRecord(int row, const QSqlRecord &record);
    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    int fieldColumn(const QString &field) const;
    QSqlRecord recordFromId(int id, QString tableName, QString idColumnName) const;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    Q_INVOKABLE void setSortColumn(const QString fieldName, const QString order);
    void setTable(const QString &tableName) Q_DECL_OVERRIDE;
    bool submitAll();

private:
    QHash<QString, int> m_rolesIndexes;

    void buildRolesIndexes();
};

#endif // SQLTABLEMODEL_H
