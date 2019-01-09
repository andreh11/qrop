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

#include <QDate>
#include <QDir>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlField>
#include <QStandardPaths>
#include <QDebug>
#include <QFileInfo>

#include "db.h"
#include "location.h"

Database::Database(QObject *parent)
    : QObject(parent)
{
}

QString Database::databasePath()
{
    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s", qPrintable(writeDir.absolutePath()));

    // Ensure that we have a writable location on all devices.
    const QString fileName = writeDir.absolutePath() + "/qrop.db";

    return fileName;
}

void Database::deleteDatabase()
{
    QString fileName = databasePath();
    QFile::remove(fileName);
}

void Database::connectToDatabase()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s", qPrintable(database.lastError().text()));
    }

    QString fileName = databasePath();
    QFileInfo fileInfo(fileName);
    bool create = !fileInfo.exists();

    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    qDebug() << "Database file:" << fileName;
    database.setDatabaseName(fileName);
    if (!database.open()) {
        QFile::remove(fileName);
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
    }
    QSqlQuery query("PRAGMA foreign_keys = ON");
    qDebug() << "Creating database...";
    query.exec();
    if (create)
        createDatabase();
}

void Database::execSqlFile(const QString &fileName, const QString &separator)
{
    Q_INIT_RESOURCE(core_resources);

    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "createDatabase: cannot open" << fileName;
        return;
    }

    QTextStream textStream(&file);
    QString fileString = textStream.readAll();
    QStringList stringList = fileString.split(separator, QString::SkipEmptyParts);
    QSqlQuery query;
    for (const QString &queryString : stringList) {
        if (queryString.isEmpty())
            continue;

        if (!query.exec(queryString + separator))
            qDebug() << "createDatabase: cannot execute query" << query.lastError().text()
                     << query.lastQuery();
    }
}

void Database::createDatabase()
{
    execSqlFile(":/db/tables.sql");
    execSqlFile(":/db/triggers.sql", "END;");
    execSqlFile(":/db/data.sql");
    qInfo() << "Database created";
}

void Database::createFakeData()
{
    Location location;
    int parentId0;

    QSqlDatabase::database().transaction();
    for (int i = 0; i < 10; i++) {
        parentId0 =
                location.add({ { "name", QString::number(i) }, { "bed_length", 30 }, { "level", 0 } });
        for (int j = 0; j < 10; j++) {
            location.add({ { "name", QString::number(j) },
                           { "parent_id", parentId0 },
                           { "bed_length", 30 },
                           { "level", 1 } });
        }
    }
    QSqlDatabase::database().commit();
}

void Database::resetDatabase()
{
    deleteDatabase();
    connectToDatabase();
    createDatabase();
}
