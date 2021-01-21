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

#include "db.h"
#include "dbutils/family.h"
#include "dbutils/location.h"
#include "dbutils/task.h"
#include "dbutils/variety.h"
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
#include "filesystem.h"
#endif
Database::Database(QObject *parent)
    : QObject(parent)
{
}

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
    //    QSqlDatabase database = QSqlDatabase::database();
    //    if (!database.isValid())
    //        connectToDatabase();

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

bool Database::addDefaultSqliteDatabase() const
{
    return QSqlDatabase::addDatabase("QSQLITE").isValid();
}

bool Database::connectToDatabase(const QUrl &url)
{
    qDebug() << "connectToDatabase: " << url.toString();

    close();
    QSqlDatabase database = QSqlDatabase::database();

    QString fileName = url.toLocalFile();

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

    if (QFileInfo(fileName).exists())
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
    if (execSqlFile(":/db/tables.sql") == 0 && execSqlFile(":/db/triggers.sql") == 0) {
        qInfo() << "Database created.";
        migrate(); // MB_QUESTION: do we really need to migrate a new DB?
        createData();
    } else
        return false;
}

bool Database::createData()
{
    qInfo() << "Adding default data...";
    // name, rotation interval
    QList<std::pair<QString, int>> familyList({ { tr("Alliaceae"), 4 },
                                                { tr("Apiaceae"), 3 },
                                                { tr("Asteraceae"), 2 },
                                                { tr("Brassicaceae"), 4 },
                                                { tr("Chenopodiaceae"), 3 },
                                                { tr("Cucurbitaceae"), 4 },
                                                { tr("Fabaceae"), 2 },
                                                { tr("Solanaceae"), 4 },
                                                { tr("Valerianaceae"), 2 } });

    // crop, family
    QList<std::pair<QString, QString>> cropList({ { tr("Garlic"), tr("Alliaceae") },
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

    QList<std::pair<QString, QString>> unitList = { { tr("kilogram"), tr("kg") },
                                                    { tr("bunch"), tr("bn") },
                                                    { tr("head"), tr("hd") } };

    QList<QString> companyList(
            { tr("Unknown company"), "Agrosemens", "Essembio", "Voltz", "Gautier", "Sativa" });

    QSqlDatabase database = QSqlDatabase::database();
    if (!database.transaction()) {
        return false;
    }
    QMap<QString, int> familyMap;
    Family family;
    for (const auto &pair : familyList) {
        familyMap[pair.first] = family.add({ { "family", pair.first }, { "interval", pair.second } });
    }

    QMap<QString, int> cropMap;
    DatabaseUtility crop;
    Variety variety;
    crop.setTable("crop");
    for (const auto &pair : cropList) {
        cropMap[pair.first] =
                crop.add({ { "crop", pair.first }, { "family_id", familyMap.value(pair.second) } });
        variety.addDefault(cropMap[pair.first]);
    }

    DatabaseUtility taskType;
    taskType.setTable("task_type");
    taskType.add({ { "type", tr("Direct sow") }, { "task_type_id", 1 } });
    taskType.add({ { "type", tr("Greenhouse sow") }, { "task_type_id", 2 } });
    taskType.add({ { "type", tr("Transplant") }, { "task_type_id", 3 } });
    for (const auto &task : taskList) {
        taskType.add({ { "type", task } });
    }

    DatabaseUtility unit;
    unit.setTable("unit");
    for (const auto &pair : unitList) {
        unit.add({ { "fullname", pair.first }, { "abbreviation", pair.second } });
    }

    DatabaseUtility seedCompany;
    seedCompany.setTable("seed_company");
    for (const auto &company : companyList) {
        seedCompany.add({ { "seed_company", company } });
    }

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
