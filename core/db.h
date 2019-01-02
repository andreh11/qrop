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

#ifndef DB_H
#define DB_H

#include <QObject>
#include "core_global.h"

class CORESHARED_EXPORT Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);

    static QString databasePath();
    static void connectToDatabase();
    static void execSqlFile(const QString &fileName, const QString &separator = ";");
    static Q_INVOKABLE void createDatabase();
    static Q_INVOKABLE void deleteDatabase();
    static Q_INVOKABLE void createFakeData();
    static Q_INVOKABLE void resetDatabase();
};

#endif // DB_H
