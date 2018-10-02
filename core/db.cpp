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

#include "db.h"

void connectToDatabase()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s",
                   qPrintable(database.lastError().text()));
    }

    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s",
               qPrintable(writeDir.absolutePath()));

    // Ensure that we have a writable location on all devices.
    const QString fileName = writeDir.absolutePath() + "/qrop.db";
    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    qDebug() << fileName;
    database.setDatabaseName(fileName);
    if (!database.open()) {
        QFile::remove(fileName);
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
    }
}

//Note::Note(QObject *parent)
//    : DatabaseUtility(parent)
//{
//    m_table = "note";
//}

//Keyword::Keyword(QObject *parent)
//    : DatabaseUtility(parent)
//{
//    m_table = "keyword";
//}

//Expense::Expense(QObject *parent)
//    : DatabaseUtility(parent)
//{
//    m_table = "expense";
//}

//User::User(QObject *parent)
//    : DatabaseUtility(parent)
//{
//    m_table = "user";
//}
