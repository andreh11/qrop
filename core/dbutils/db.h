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

class Qrop;
class CORESHARED_EXPORT Database : public QObject
{
    Q_OBJECT

    friend class Qrop;
    friend class tst_Database;

public:
    explicit Database(QObject *parent = nullptr);

    static QString defaultDatabasePath();
    inline static Q_INVOKABLE QUrl defaultDatabasePathUrl()
    {
        return QUrl::fromLocalFile(defaultDatabasePath());
    }
    static bool connectToDatabase(const QUrl &url = QUrl());
    static void copy(const QUrl &from, const QUrl &to);
    static void close();

    void loadDatabase(Qrop *qrop);

private:
    void loadSeedCompanies(Qrop *qrop);
    void loadFamilies(Qrop *qrop);
    void loadCrops(Qrop *qrop);
    void loadVarieties(Qrop *qrop);

    static bool addDefaultSqliteDatabase();

    static int databaseVersion();
    static void removeFileIfExists(const QUrl &url);
    static QString fileNameFrom(const QUrl &url);
    static bool shrink();

    static int execSqlFile(const QString &fileNameFrom, const QString &separator = ";");
    static bool migrate();
    static bool createDatabase();

    static void backupDatabase();
    static void deleteDatabase();
    static bool createData();
};

#endif // DB_H
