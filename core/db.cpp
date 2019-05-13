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
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlField>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QUrl>

#include "db.h"
#include "location.h"
#include "family.h"
#include "task.h"

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

void Database::backupDatabase()
{
    QFileInfo fileInfo(databasePath());
    auto today = QDate::currentDate();
    QString backupFileName =
            QString("%1-%2.sqlite").arg(fileInfo.baseName()).arg(today.toString(Qt::ISODate));
    qDebug() << backupFileName;
    QFile::copy(fileInfo.absoluteFilePath(), fileInfo.absolutePath() + "/" + backupFileName);
}

void Database::removeFileIfExists(const QUrl &url)
{
    QFileInfo fileInfo(url.toLocalFile());
    if (fileInfo.exists())
        QFile::remove(url.toLocalFile());
}

void Database::saveAs(const QUrl &url)
{
    removeFileIfExists(url);
    QFileInfo fileInfo(databasePath());
    QFile::copy(fileInfo.absoluteFilePath(), url.toLocalFile());
}

void Database::copy(const QUrl &from, const QUrl &to)
{
    removeFileIfExists(to);
    QFile::copy(from.toLocalFile(), to.toLocalFile());
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
        qInfo() << "Backup database...";
        backupDatabase();
        qInfo() << "done.";

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

void Database::connectToDatabase(const QUrl &url)
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s", qPrintable(database.lastError().text()));
    }

    if (database.isOpen())
        database.close();

    QString fileName;
    bool create = false;
    if (url.isEmpty()) { // default database path
        fileName = databasePath();
    } else {
        fileName = url.toLocalFile();
    }

    QFileInfo fileInfo(fileName);
    create = !fileInfo.exists();

    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    qInfo() << "Database file:" << fileName;
    database.setDatabaseName(fileName);
    if (!database.open()) {
        QFile::remove(fileName);
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
    }

    QSqlQuery query("PRAGMA foreign_keys = ON");
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
    qInfo() << "Creating database...";
    execSqlFile(":/db/tables.sql");
    execSqlFile(":/db/triggers.sql", "END;");
    Database::createData();
    //    execSqlFile(":/db/data.sql");
    qInfo() << "Database created.";
    migrationCheck();
}

void Database::createData()
{

    // name, rotation interval
    QList<QPair<QString, int>> familyList({ { tr("Alliaceae"), 4 },
                                            { tr("Apiaceae"), 3 },
                                            { tr("Asteraceae"), 2 },
                                            { tr("Brassicaceae"), 4 },
                                            { tr("Chenopodiaceae"), 3 },
                                            { tr("Cucurbitaceae"), 4 },
                                            { tr("Fabaceae"), 2 },
                                            { tr("Solanaceae"), 4 },
                                            { tr("Valerianaceae"), 2 } });

    // crop, family
    QList<QPair<QString, QString>> cropList({ { tr("Garlic"), tr("Alliaceae") },
                                              { tr("Onion"), tr("Alliaceae") },
                                              { tr("Leek"), tr("Alliaceae") },
                                              { tr("Carrot"), tr("Apiaceae") },
                                              { tr("Celery"), tr("Apiaceae") },
                                              { tr("Fennel"), tr("Apiaceae") },
                                              { tr("Parsnip"), tr("Apiaceae") },
                                              { tr("Chicory"), tr("Asteraceae") },
                                              { tr("Belgian endive"), tr("Asteraceae") },
                                              { tr("Lettuce"), tr("Asteraceae") },
                                              { tr("Cabbage"), tr("Brassicaceae") },
                                              { tr("Brussel Sprouts"), tr("Brassicaceae") },
                                              { tr("Kohlrabi"), tr("Brassicaceae") },
                                              { tr("Cauliflower"), tr("Brassicaceae") },
                                              { tr("Broccoli"), tr("Brassicaceae") },
                                              { tr("Turnip"), tr("Brassicaceae") },
                                              { tr("Radish"), tr("Brassicaceae") },
                                              { tr("Beetroot"), tr("Chenopodiaceae") },
                                              { tr("Chard"), tr("Chenopodiaceae") },
                                              { tr("Spinach"), tr("Chenopodiaceae") },
                                              { tr("Cucumber"), tr("Cucurbitaceae") },
                                              { tr("Zucchini"), tr("Cucurbitaceae") },
                                              { tr("Melon"), tr("Cucurbitaceae") },
                                              { tr("Watermelon"), tr("Cucurbitaceae") },
                                              { tr("Winter squash"), tr("Cucurbitaceae") },
                                              { tr("Bean"), tr("Fabaceae") },
                                              { tr("Fava bean"), tr("Fabaceae") },
                                              { tr("Pea"), tr("Fabaceae") },
                                              { tr("Eggplant"), tr("Solanaceae") },
                                              { tr("Pepper"), tr("Solanaceae") },
                                              { tr("Potatoe"), tr("Solanaceae") },
                                              { tr("Tomato"), tr("Solanaceae") },
                                              { tr("Mâche"), tr("Valerianaceae") } });

    QList<QString> taskList = { tr("Cultivation and Tillage"),
                                tr("Fertilize and Amend"),
                                tr("Irrigate"),
                                tr("Maintenance"),
                                tr("Pest and Disease"),
                                tr("Prune"),
                                tr("Row Cover and Mulch"),
                                tr("Stale Bed"),
                                tr("Thin"),
                                tr("Trellis"),
                                tr("Weed") };

    QList<QPair<QString, QString>> unitList = { { tr("kilogram"), tr("kg") },
                                                { tr("bunch"), tr("bn") },
                                                { tr("head"), tr("hd") } };

    QList<QString> companyList(
            { tr("Unknown company"), "Agrosemens", "Essembio", "Voltz", "Gautier", "Sativa" });

    QSqlDatabase::database().transaction();
    QMap<QString, int> familyMap;
    Family family;
    for (auto pair : familyList) {
        familyMap[pair.first] = family.add({ { "family", pair.first }, { "interval", pair.second } });
    }

    QMap<QString, int> cropMap;
    DatabaseUtility crop;
    crop.setTable("crop");
    for (auto pair : cropList) {
        cropMap[pair.first] =
                crop.add({ { "crop", pair.first }, { "family_id", familyMap.value(pair.second) } });
    }

    DatabaseUtility taskType;
    taskType.setTable("task_type");
    taskType.add({ { "type", tr("Direct sow") }, { "task_type_id", 1 } });
    taskType.add({ { "type", tr("Greenhouse sow") }, { "task_type_id", 2 } });
    taskType.add({ { "type", tr("Transplant") }, { "task_type_id", 3 } });
    for (auto task : taskList) {
        taskType.add({ { "type", task } });
    }

    DatabaseUtility unit;
    unit.setTable("unit");
    for (auto pair : unitList) {
        unit.add({ { "fullname", pair.first }, { "abbreviation", pair.second } });
    }

    DatabaseUtility seedCompany;
    seedCompany.setTable("seed_company");
    for (auto company : companyList) {
        seedCompany.add({ { "seed_company", company } });
    }

    QSqlDatabase::database().commit();
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
