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

#ifndef DB_H
#define DB_H

#include <QObject>
#include <QUrl>
#include "core_global.h"

class CORESHARED_EXPORT Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);

    static QString databasePath();
    static Q_INVOKABLE void connectToDatabase(const QUrl &url = QUrl());
    static void execSqlFile(const QString &fileName, const QString &separator = ";");
    static void migrate();
    static void backupDatabase();
    static Q_INVOKABLE void saveAs(const QUrl &url);
    static Q_INVOKABLE void replaceMainDatabase(const QUrl &url);
    static Q_INVOKABLE void copy(const QUrl &from, const QUrl &to);
    static Q_INVOKABLE void createDatabase();
    static Q_INVOKABLE void deleteDatabase();
    static Q_INVOKABLE void createData();
    static Q_INVOKABLE void resetDatabase();

private:
    static int databaseVersion();
    static void removeFileIfExists(const QUrl &url);
};

#endif // DB_H
