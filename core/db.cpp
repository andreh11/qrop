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
#include <QDirIterator>

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
    qInfo() << "Deleting database...";
    QSqlDatabase::database().close();
    QString fileName = databasePath();
    QFile::remove(fileName);
}

int Database::databaseVersion()
{
    QSqlQuery query("PRAGMA user_version");
    query.exec();
    query.next();
    return query.value(0).toInt();
}

void Database::migrationCheck()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid())
        connectToDatabase();

    int dbVersion = databaseVersion();

    QDir dir(":/db/migrations");
    QFileInfoList fileInfoList = dir.entryInfoList(QDir::NoFilter, QDir::Name);
    int lastVersion = fileInfoList.last().baseName().toInt();

    if (dbVersion < lastVersion) {
        qInfo() << "!!!! Migration database from version" << dbVersion << "to latest version "
                << lastVersion;

        for (const auto &fileInfo : fileInfoList) {
            int version = fileInfo.baseName().toInt();
            if (version > dbVersion) {
                qInfo() << "==== Migrating to version" << version;
                execSqlFile(fileInfo.absoluteFilePath());
            }
        }
    } else {
        qInfo() << "Latest database version:" << dbVersion;
    }
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
    qInfo() << "Database file:" << fileName;
    database.setDatabaseName(fileName);
    if (!database.open()) {
        QFile::remove(fileName);
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
    }

    QSqlQuery query("PRAGMA foreign_keys = ON");
    qInfo() << "Creating database...";
    query.exec();
    if (create)
        createDatabase();
}

void Database::execSqlFile(const QString &fileName, const QString &separator)
{
    Q_INIT_RESOURCE(core_resources); // Needed for the method to find the resource files.

    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "execSqlFile: cannot open" << fileName;
        return;
    }

    QTextStream textStream(&file);
    QString fileString = textStream.readAll();
    QStringList stringList = fileString.split(separator, QString::SkipEmptyParts);

    QSqlQuery query;
    for (const auto &queryString : stringList) {
        if (queryString.isNull() || queryString.trimmed().isEmpty())
            continue;

        if (!query.exec(queryString + separator))
            qDebug() << "execSqlFile: cannot execute query" << query.lastError().text()
                     << query.lastQuery();
    }
}

void Database::createDatabase()
{
    execSqlFile(":/db/tables.sql");
    execSqlFile(":/db/triggers.sql", "END;");
    execSqlFile(":/db/data.sql");
    qInfo() << "Database created.";
    migrationCheck();
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
