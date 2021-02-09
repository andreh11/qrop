/*
 * Copyright (C) 2018-2020 André Hoarau <ah@ouvaton.org>
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
#include <QSqlDriver>
#include <QSettings>
#include <QCoreApplication>
#include <QRegularExpression>

#include "db.h"
#include "dbutils/family.h"
#include "dbutils/location.h"
#include "dbutils/task.h"
#include "dbutils/variety.h"
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
#include "filesystem.h"
#endif

QString Database::defaultDatabasePath()
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return FileSystem::rootPath();
#else
    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s", qPrintable(writeDir.absolutePath()));

    return QString("%1/qrop.db").arg(writeDir.absolutePath());
#endif
}

void Database::deleteDatabase()
{
    qInfo() << "Deleting database...";
    close();
    QString fileName = defaultDatabasePath();
    QFile::remove(fileName);
}

int Database::databaseVersion()
{
    QSqlQuery query("PRAGMA user_version");
    query.next();
    return query.value(0).toInt();
}

void Database::backupDatabase()
{
    QDebug debug = qDebug();
    debug << "Backing up database...";
    QFileInfo fileInfo(defaultDatabasePath());
    auto today = QDate::currentDate();
    QString backupFileName =
            QString("%1-%2.sqlite").arg(fileInfo.baseName(), today.toString(Qt::ISODate));
    QFile::copy(fileInfo.absoluteFilePath(), fileInfo.absolutePath() + "/" + backupFileName);
    debug << "done.";
}

void Database::removeFileIfExists(const QUrl &url)
{
    QFileInfo fileInfo(url.toLocalFile());
    if (fileInfo.exists())
        QFile::remove(url.toLocalFile());
}

void Database::copy(const QUrl &from, const QUrl &to)
{
    removeFileIfExists(to);
    QFile::copy(from.toLocalFile(), to.toLocalFile());
}

bool Database::migrate()
{
    int fullyMigrated = true;
    int dbVersion = databaseVersion();

    QDir dir(":/db/migrations");
    QFileInfoList fileInfoList = dir.entryInfoList(QDir::NoFilter, QDir::Name);
    int lastVersion = fileInfoList.last().baseName().toInt();

    if (dbVersion < lastVersion) {
        backupDatabase();

        qInfo() << "!!!! Migrating database from version" << dbVersion << "to latest version "
                << lastVersion;

        for (const auto &fileInfo : fileInfoList) {
            int version = fileInfo.baseName().toInt();
            if (version > dbVersion) {
                qInfo() << "==== Migrating to version" << version;
                fullyMigrated &= execSqlFile(fileInfo.absoluteFilePath()) == 0;
            }
        }
        shrink();
    } else {
        qInfo() << "Latest database version:" << dbVersion;
    }

    return fullyMigrated;
}

QString Database::fileNameFrom(const QUrl &url)
{
    if (url.isEmpty()) {
        QSettings settings;
        int currentDatabase = settings.value("currentDatabase").toInt();
        QString firstDatabaseFile =
                settings.value("firstDatabaseFile", defaultDatabasePath()).toString();
        QString secondDatabaseFile = settings.value("secondDatabaseFile", "").toString();
        qDebug() << currentDatabase << firstDatabaseFile << secondDatabaseFile;

        if (currentDatabase == 1)
            return QUrl(firstDatabaseFile).toLocalFile();
        else if (currentDatabase == 2 && !secondDatabaseFile.isEmpty())
            return QUrl(secondDatabaseFile).toLocalFile();
        return defaultDatabasePath();
    }
    return url.toLocalFile();
}

bool Database::addDefaultSqliteDatabase()
{
    return QSqlDatabase::addDatabase("QSQLITE").isValid();
}

bool Database::connectToDatabase(const QUrl &url)
{
    qDebug() << "connectToDatabase: " << url.toString();

    close();
    QSqlDatabase database = QSqlDatabase::database();

    QString fileName = url.toLocalFile();
    bool dbAlreadyExists = QFileInfo(fileName).exists();

    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    database.setDatabaseName(fileName);
    if (!database.open()) {
        //        QFile::remove(fileName);
        qCritical() << "Cannot open database: " << qPrintable(database.lastError().text());
        return false;
    }

    QSqlQuery query("PRAGMA foreign_keys = ON");
    query.exec("PRAGMA journal_mode = WAL");
    query.exec("PRAGMA wal_autocheckpoint = 16");
    query.exec("PRAGMA journal_size_limit = 1536");

    if (dbAlreadyExists)
        return migrate();
    else
        return createDatabase();
}

void Database::close()
{
    auto database = QSqlDatabase::database();
    if (!database.isOpen())
        return;

    qDebug() << "Optimizing database...";
    QSqlQuery query;
    query.exec("PRAGMA optimize");
    qDebug() << "Closing database...";
    database.close();
}

int Database::execSqlFile(const QString &fileName, const QString &separator)
{
    Q_INIT_RESOURCE(core_resources); // Needed for the method to find the resource files.

    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "execSqlFile: cannot open" << fileName;
        return -1;
    }

    QTextStream textStream(&file);
    QString fileString = textStream.readAll();
    // Remove commented out lines to prevent errors.
    fileString.replace(QRegularExpression("--.*?\\n"), " ");

    QStringList stringList = fileString.split(separator, QString::SkipEmptyParts);

    QSqlQuery query;
    int nbFailed = 0;
    for (const auto &queryString : stringList) {
        QString end = separator;
        if (queryString.isNull() || queryString.trimmed().isEmpty()
            || queryString.trimmed().startsWith("END")) {
            continue;
        }

        if (queryString.trimmed().startsWith("CREATE TRIGGER"))
            end = "; END;";

        if (!query.exec(queryString + end)) {
            qDebug() << "execSqlFile: cannot execute query" << query.lastError().text()
                     << query.lastQuery();
            ++nbFailed;
        }
    }

    return nbFailed;
}

bool Database::createDatabase()
{
    qInfo() << "Creating database...";
    int nbErrors = execSqlFile(":/db/tables.sql");
    nbErrors += execSqlFile(":/db/triggers.sql");

    if (nbErrors == 0) {
        qInfo() << "Database created.";
        if (migrate())
            return createData();
        else
            qCritical() << "Error migrating Database  => data not created...";
    } else
        qCritical() << "Error creating Database (" << nbErrors << ")"
                    << " => data not created...";
    return false;
}

QList<std::pair<QString, int>> Database::s_familyList;
QList<std::pair<QString, QString>> Database::s_cropList;
QList<QString> Database::s_taskList;
QList<std::pair<QString, QString>> Database::s_unitList;
QList<QString> Database::s_companyList;
void Database::initStatics()
{
    s_familyList = { { QCoreApplication::translate("Database", "Alliaceae"), 4 },
                     { QCoreApplication::translate("Database", "Apiaceae"), 3 },
                     { QCoreApplication::translate("Database", "Asteraceae"), 2 },
                     { QCoreApplication::translate("Database", "Brassicaceae"), 4 },
                     { QCoreApplication::translate("Database", "Chenopodiaceae"), 3 },
                     { QCoreApplication::translate("Database", "Cucurbitaceae"), 4 },
                     { QCoreApplication::translate("Database", "Fabaceae"), 2 },
                     { QCoreApplication::translate("Database", "Solanaceae"), 4 },
                     { QCoreApplication::translate("Database", "Valerianaceae"), 2 } };

    s_cropList = { { QCoreApplication::translate("Database", "Garlic"),
                     QCoreApplication::translate("Database", "Alliaceae") },
                   { QCoreApplication::translate("Database", "Onion"),
                     QCoreApplication::translate("Database", "Alliaceae") },
                   { QCoreApplication::translate("Database", "Leek"),
                     QCoreApplication::translate("Database", "Alliaceae") },
                   { QCoreApplication::translate("Database", "Carrot"),
                     QCoreApplication::translate("Database", "Apiaceae") },
                   { QCoreApplication::translate("Database", "Celery"),
                     QCoreApplication::translate("Database", "Apiaceae") },
                   { QCoreApplication::translate("Database", "Fennel"),
                     QCoreApplication::translate("Database", "Apiaceae") },
                   { QCoreApplication::translate("Database", "Parsnip"),
                     QCoreApplication::translate("Database", "Apiaceae") },
                   { QCoreApplication::translate("Database", "Chicory"),
                     QCoreApplication::translate("Database", "Asteraceae") },
                   { QCoreApplication::translate("Database", "Belgian endive"),
                     QCoreApplication::translate("Database", "Asteraceae") },
                   { QCoreApplication::translate("Database", "Lettuce"),
                     QCoreApplication::translate("Database", "Asteraceae") },
                   { QCoreApplication::translate("Database", "Cabbage"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Brussel Sprouts"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Kohlrabi"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Cauliflower"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Broccoli"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Turnip"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Radish"),
                     QCoreApplication::translate("Database", "Brassicaceae") },
                   { QCoreApplication::translate("Database", "Beetroot"),
                     QCoreApplication::translate("Database", "Chenopodiaceae") },
                   { QCoreApplication::translate("Database", "Chard"),
                     QCoreApplication::translate("Database", "Chenopodiaceae") },
                   { QCoreApplication::translate("Database", "Spinach"),
                     QCoreApplication::translate("Database", "Chenopodiaceae") },
                   { QCoreApplication::translate("Database", "Cucumber"),
                     QCoreApplication::translate("Database", "Cucurbitaceae") },
                   { QCoreApplication::translate("Database", "Zucchini"),
                     QCoreApplication::translate("Database", "Cucurbitaceae") },
                   { QCoreApplication::translate("Database", "Melon"),
                     QCoreApplication::translate("Database", "Cucurbitaceae") },
                   { QCoreApplication::translate("Database", "Watermelon"),
                     QCoreApplication::translate("Database", "Cucurbitaceae") },
                   { QCoreApplication::translate("Database", "Winter squash"),
                     QCoreApplication::translate("Database", "Cucurbitaceae") },
                   { QCoreApplication::translate("Database", "Bean"),
                     QCoreApplication::translate("Database", "Fabaceae") },
                   { QCoreApplication::translate("Database", "Fava bean"),
                     QCoreApplication::translate("Database", "Fabaceae") },
                   { QCoreApplication::translate("Database", "Pea"),
                     QCoreApplication::translate("Database", "Fabaceae") },
                   { QCoreApplication::translate("Database", "Eggplant"),
                     QCoreApplication::translate("Database", "Solanaceae") },
                   { QCoreApplication::translate("Database", "Pepper"),
                     QCoreApplication::translate("Database", "Solanaceae") },
                   { QCoreApplication::translate("Database", "Potatoe"),
                     QCoreApplication::translate("Database", "Solanaceae") },
                   { QCoreApplication::translate("Database", "Tomato"),
                     QCoreApplication::translate("Database", "Solanaceae") },
                   { QCoreApplication::translate("Database", "Mâche"),
                     QCoreApplication::translate("Database", "Valerianaceae") } };

    s_taskList = { QCoreApplication::translate("Database", "Cultivation and Tillage"),
                   QCoreApplication::translate("Database", "Fertilize and Amend"),
                   QCoreApplication::translate("Database", "Irrigate"),
                   QCoreApplication::translate("Database", "Maintenance"),
                   QCoreApplication::translate("Database", "Pest and Disease"),
                   QCoreApplication::translate("Database", "Prune"),
                   QCoreApplication::translate("Database", "Row Cover and Mulch"),
                   QCoreApplication::translate("Database", "Stale Bed"),
                   QCoreApplication::translate("Database", "Thin"),
                   QCoreApplication::translate("Database", "Trellis"),
                   QCoreApplication::translate("Database", "Weed") };

    s_unitList = { { QCoreApplication::translate("Database", "kilogram"),
                     QCoreApplication::translate("Database", "kg") },
                   { QCoreApplication::translate("Database", "bunch"),
                     QCoreApplication::translate("Database", "bn") },
                   { QCoreApplication::translate("Database", "head"),
                     QCoreApplication::translate("Database", "hd") } };

    s_companyList = { QCoreApplication::translate("Database", "Unknown company"),
                      "Agrosemens",
                      "Essembio",
                      "Voltz",
                      "Gautier",
                      "Sativa" };
}

bool Database::createData()
{
    qInfo() << "Adding default data...";

    QSqlDatabase database = QSqlDatabase::database();
    if (!database.transaction()) {
        return false;
    }
    QMap<QString, int> familyMap;
    Family family;
    for (auto it = s_familyList.cbegin(), itEnd = s_familyList.cend(); it != itEnd; ++it)
        familyMap[it->first] = family.add({ { "family", it->first }, { "interval", it->second } });

    QMap<QString, int> cropMap;
    DatabaseUtility crop;
    Variety variety;
    crop.setTable("crop");
    for (auto it = s_cropList.cbegin(), itEnd = s_cropList.cend(); it != itEnd; ++it) {
        cropMap[it->first] =
                crop.add({ { "crop", it->first }, { "family_id", familyMap.value(it->second) } });
        variety.addDefault(cropMap[it->first]);
    }

    DatabaseUtility taskType;
    taskType.setTable("task_type");
    taskType.add({ { "type", QCoreApplication::translate("Database", "Direct sow") },
                   { "task_type_id", 1 } });
    taskType.add({ { "type", QCoreApplication::translate("Database", "Greenhouse sow") },
                   { "task_type_id", 2 } });
    taskType.add({ { "type", QCoreApplication::translate("Database", "Transplant") },
                   { "task_type_id", 3 } });
    for (auto it = s_taskList.cbegin(), itEnd = s_taskList.cend(); it != itEnd; ++it)
        taskType.add({ { "type", *it } });

    DatabaseUtility unit;
    unit.setTable("unit");
    for (auto it = s_unitList.cbegin(), itEnd = s_unitList.cend(); it != itEnd; ++it)
        unit.add({ { "fullname", it->first }, { "abbreviation", it->second } });

    DatabaseUtility seedCompany;
    seedCompany.setTable("seed_company");
    for (auto it = s_companyList.cbegin(), itEnd = s_companyList.cend(); it != itEnd; ++it)
        seedCompany.add({ { "seed_company", *it } });

    bool success = database.commit();
    if (success)
        qInfo() << "Default data added.";
    else
        qCritical() << "Error creating data: " << qPrintable(database.lastError().text());

    return success;
}

bool Database::shrink()
{
    //    if (!QSqlDatabase::database().isOpen())
    //        return;
    QSqlQuery query;
    return query.exec("VACUUM");
}
