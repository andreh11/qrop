/*
 * Copyright (C) 2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
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

#include <QUrl>
#include <QTranslator>
#include <QCoreApplication>
#include <QRegularExpression>
#include <QUndoStack>

#include "qropnews.h"
#include "qrop.h"
#include "dbutils/db.h"
#include "services/familyservice.h"

Qrop::Qrop(QObject *parent)
    : QObject(parent)
    , m_translator(new QTranslator(this))
    , m_buildInfo(new BuildInfo(this))
    , m_news(new QropNews(this))
    , m_undoStack(new QUndoStack(this))
    , m_isLocalDatabase(true)
    , m_familySvc(new FamilyService(this))
{
}

void Qrop::clearBusinessObjects()
{
    m_undoStack->clear();
    m_familySvc->clear();
}

Qrop::~Qrop()
{
    Database::close();

    if (m_news->areRead())
        m_settings.setValue("lastNewsUpdate", m_news->lastUpdate().toString(Qt::ISODate));
    m_settings.sync();
    qDebug() << "Qrop properly deleted!";
}

#include "commands/cmdfamily.h"
int Qrop::init()
{
    _dumpSettings();
    qDebug() << "Qrop version: " << m_buildInfo->version();

    // can we load SQLite driver?
    if (!Database::addDefaultSqliteDatabase()) {
        qCritical() << "Cannot load SQLite driver...";
        return 1;
    }

    installTranslator();

    initStatics();

    // load current database (or default one)
    loadCurrentDatabase();

    return 0;
}

void Qrop::initStatics()
{
    Database::initStatics();
    CmdFamily::s_familySvc = m_familySvc;
}

void Qrop::undo()
{
    if (m_undoStack->canUndo()) {
        sendInfo(tr("Undo %1").arg(m_undoStack->undoText()));
        m_undoStack->undo();
    }
}
void Qrop::redo()
{
    if (m_undoStack->canRedo()) {
        sendInfo(tr("Redo %1").arg(m_undoStack->redoText()));
        m_undoStack->redo();
    }
}

void Qrop::pushCommand(QUndoCommand *cmd)
{
    m_undoStack->push(cmd);
}

void Qrop::pushCommands(const QString &title, const QList<QUndoCommand *> &cmds)
{
    if (cmds.isEmpty())
        return;
    m_undoStack->beginMacro(title);
    for (QUndoCommand *cmd : cmds)
        m_undoStack->push(cmd);
    m_undoStack->endMacro();
}

bool Qrop::loadDatabase(const QUrl &url)
{
    clearBusinessObjects();
    if (url.isLocalFile()) {
        if (Database::connectToDatabase(url)) {
            Database::loadDatabase(m_familySvc);
            qDebug() << "[Qrop::loadDatabase] "
                     << "nb Families: " << m_familySvc->numberOfFamilies()
                     << ", nb Crops: " << m_familySvc->numberOfCrops()
                     << ", nb Varieties: " << m_familySvc->numberOfVarieties();
            m_isLocalDatabase = true;
            return true;
        }
    } else if (url.scheme().startsWith("http"))
        return false; // MB_TODO: load from json request

    return false;
}

QUrl Qrop::defaultDatabaseUrl() const
{
    return Database::defaultDatabasePathUrl();
}

bool Qrop::saveDatabase(const QUrl &from, const QUrl &to)
{
    if (from.isLocalFile() && to.isLocalFile()) {
        Database::copy(from, to);
        return true;
    }
    return false;
}

bool Qrop::newReleaseAvailable(const QString &lastOnlineVersion)
{
    QRegularExpression versionRegExp("^(\\d+)\\.(\\d+)\\.(\\d+)$");
    QRegularExpressionMatch matchLastVersion = versionRegExp.match(lastOnlineVersion);
    QRegularExpressionMatch matchCurrent = versionRegExp.match(m_buildInfo->version());

    if (matchLastVersion.hasMatch() && matchCurrent.hasMatch()) {
        int majorLast = matchLastVersion.captured(1).toInt();
        int majorCurrent = matchCurrent.captured(1).toInt();

        if (majorLast > majorCurrent)
            return true;

        if (majorLast == majorCurrent) {
            int minorLast = matchLastVersion.captured(2).toInt();
            int minorCurrent = matchCurrent.captured(2).toInt();
            if (minorLast > minorCurrent)
                return true;
            if (minorLast == minorCurrent
                && matchLastVersion.captured(3).toInt() > matchCurrent.captured(3).toInt()) {
                return true;
            }
        }
    }
    return false;
}

void Qrop::loadCurrentDatabase()
{
    int dbIdx = m_settings.value("currentDatabase", 1).toInt();
    QUrl defaultDatabaseUrl = Database::defaultDatabasePathUrl();
    QString firstDatabaseFile =
            m_settings.value("firstDatabaseFile", defaultDatabaseUrl.toString()).toString();
    QString secondDatabaseFile = m_settings.value("secondDatabaseFile", "").toString();
    qDebug() << dbIdx << firstDatabaseFile << secondDatabaseFile;

    QUrl currentDB = dbIdx == 2 && !secondDatabaseFile.isEmpty() ? QUrl(secondDatabaseFile)
                                                                 : QUrl(firstDatabaseFile);

    if (!loadDatabase(currentDB)) {
        m_errors << tr("Error loading current Database: %1").arg(currentDB.toString());
        qCritical() << "[Qrop::loadCurrentDatabase] Error loading currentDB: " << currentDB.toString();
        m_settings.setValue(dbIdx == 1 ? "firstDatabaseFile" : "secondDatabaseFile",
                            defaultDatabaseUrl.toString());
        loadDatabase(defaultDatabaseUrl);
    }
}

void Qrop::installTranslator()
{
    QString lang = QLocale::system().name();
    QString prefLanguage = preferredLanguage();
    qDebug() << "LANG: " << lang << ", preferredLanguage: " << prefLanguage;

    if (prefLanguage == "system")
        m_translator->load(QLocale(), "qrop", "_", ":/translations", ".qm");
    else
        m_translator->load(":/translations/qrop_" + prefLanguage + ".qm");

    qApp->installTranslator(m_translator);
}

void Qrop::_dumpSettings()
{
    for (const QString &key : m_settings.allKeys())
        qDebug() << "[dumpSettings] " << key << ": " << m_settings.value(key);
}
