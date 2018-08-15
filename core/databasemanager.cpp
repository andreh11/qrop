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

#include "databasemanager.h"

#include <QSqlDatabase>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QFile>
#include <QStandardPaths>

void DatabaseManager::debugQuery(const QSqlQuery& query)
{
    if (query.lastError().type() == QSqlError::ErrorType::NoError) {
        qDebug() << "Query OK: " << query.lastQuery();
    } else {
        qWarning() << "Query ERROR: " << query.lastError().text();
        qWarning() << "Query text: " << query.lastQuery();
    }
}

DatabaseManager& DatabaseManager::instance()
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    QFile assetDbFile(":/database/" + DATABASE_FILENAME);
    QString destinationDbFile = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
                    .append("/" + DATABASE_FILENAME);

    qDebug() << "Assets file" << assetDbFile.fileName();
    qDebug() << "Database file" << destinationDbFile;
    if (assetDbFile.exists()) {
        qDebug() << "File exist in assets!!!!";
        if (!QFile::exists(destinationDbFile)) {

            assetDbFile.copy(destinationDbFile);
            QFile::setPermissions(destinationDbFile, QFile::WriteOwner | QFile::ReadOwner);
            qDebug() << "Setted permissions on copied file";
        }
    }
    static DatabaseManager singleton(destinationDbFile);
#else
    static DatabaseManager singleton;
#endif
    return singleton;
}

DatabaseManager::DatabaseManager(const QString& path) :
    mDatabase(new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"))),
    plantingDao(*mDatabase),
    locationDao(*mDatabase)
{
    mDatabase->setDatabaseName(path);

    bool openStatus = mDatabase->open();
    qDebug() << "Database connection: " << (openStatus ? "OK" : "ERROR");

    plantingDao.init();
//    locationDao.init()
}

DatabaseManager::~DatabaseManager()
{
    mDatabase->close();
}
