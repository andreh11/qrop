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

#include "qropnews.h"
#include "qrop.h"
#include "dbutils/db.h"
#include "models/familymodel.h"
#include "models/seedcompanymodel.h"

Qrop::Qrop(QObject *parent)
    : QObject(parent)
    , Singleton<Qrop>()
    , m_settings()
    , m_translator(new QTranslator)
    , m_db(new Database(this))
    , m_buildInfo(new BuildInfo)
    , m_errors()
    , m_netMgr()
    , m_news(new QropNews)
    , m_families()
    , m_crops()
    , m_varieties()
    , m_seedCompanies()
    , m_familyModel(new FamilyModel2(this))
    , m_familyProxyModel(new QSortFilterProxyModel)
    , m_seedCompanyModel(new SeedCompanyModel2(this))
    , m_seedCompanyProxyModel(new QSortFilterProxyModel)
{
    m_familyProxyModel->setSourceModel(m_familyModel);
    m_familyProxyModel->setSortRole(FamilyModel2::FamilyRole::name);
    m_familyProxyModel->setDynamicSortFilter(true);
    //    m_familyProxyModel->sort(0, Qt::AscendingOrder);

    m_seedCompanyProxyModel->setSourceModel(m_seedCompanyModel);
    m_seedCompanyProxyModel->setSortRole(SeedCompanyModel2::SeedCompanyRole::name);
    m_seedCompanyProxyModel->setDynamicSortFilter(true);
    //    m_seedCompanyProxyModel->sort(0, Qt::AscendingOrder);
}

void Qrop::clearBusinessObjects()
{
    if (!m_seedCompanies.isEmpty()) {
        emit beginResetSeedCompanyModel();
        qDeleteAll(m_seedCompanies);
        m_seedCompanies.clear();
        emit endResetSeedCompanyModel();
    }
    if (!m_families.isEmpty()) {
        emit beginResetFamilyModel();
        qDeleteAll(m_families);
        m_families.clear();
        emit endResetFamilyModel();
    }
    qDeleteAll(m_crops);
    m_crops.clear();
    qDeleteAll(m_varieties);
    m_varieties.clear();
}

Qrop::~Qrop()
{
    delete m_seedCompanyProxyModel;
    delete m_seedCompanyModel;
    delete m_familyProxyModel;
    delete m_familyModel;

    clearBusinessObjects();

    if (m_news->areRead())
        m_settings.setValue("lastNewsUpdate", m_news->lastUpdate().toString(Qt::ISODate));
    m_settings.sync();

    delete m_news;
    delete m_buildInfo;
    m_db->close();
    delete m_db;
    delete m_translator;
}

int Qrop::init()
{
    _dumpSettings();
    qDebug() << "Qrop version: " << m_buildInfo->version();

    // can we load SQLite driver?
    if (!m_db->addDefaultSqliteDatabase()) {
        qCritical() << "Cannot load SQLite driver...";
        return 1;
    }

    installTranslator();

    // load current database (or default one)
    loadCurrentDatabase();

    return 0;
}

bool Qrop::loadDatabase(const QUrl &url)
{
    clearBusinessObjects();
    if (url.isLocalFile()) {
        if (m_db->connectToDatabase(url)) {
            m_db->loadDatabase(this);
            qDebug() << "[Qrop::loadDatabase] "
                     << "nb Families: " << m_families.size() << ", nb Crops: " << m_crops.size()
                     << ", nb Varieties: " << m_varieties.size();
            return true;
        }
    } else if (url.scheme().startsWith("http"))
        return false; // MB_TODO: load from json request

    return false;
}

QUrl Qrop::defaultDatabaseUrl() const
{
    return m_db->defaultDatabasePathUrl();
}

bool Qrop::saveDatabase(const QUrl &from, const QUrl &to)
{
    if (from.isLocalFile() && to.isLocalFile()) {
        m_db->copy(from, to);
        return true;
    } else
        return false;
}

bool Qrop::newReleaseAvailable(const QString &lastOnlineVersion)
{
    QRegularExpression versionRegExp("^(\\d+)\\.(\\d+)\\.(\\d+)$");
    QRegularExpressionMatch matchLastVersion = versionRegExp.match(lastOnlineVersion),
                            matchCurrent = versionRegExp.match(m_buildInfo->version());
    if (matchLastVersion.hasMatch() && matchCurrent.hasMatch()) {
        int majorLast = matchLastVersion.captured(1).toInt(),
            majorCurrent = matchCurrent.captured(1).toInt();
        if (majorLast > majorCurrent)
            return true;
        else if (majorLast == majorCurrent) {
            int minorLast = matchLastVersion.captured(2).toInt(),
                minorCurrent = matchCurrent.captured(2).toInt();
            if (minorLast > minorCurrent)
                return true;
            else if (minorLast == minorCurrent
                     && matchLastVersion.captured(3).toInt() > matchCurrent.captured(3).toInt())
                return true;
        }
    }
    return false;
}

int Qrop::seedCompanyProxyIndex(uint seedCompanyId) const
{
    for (int row = 0; row < m_seedCompanyProxyModel->rowCount(); ++row) {
        if (seedCompanyId
            == m_seedCompanyProxyModel
                       ->data(m_seedCompanyProxyModel->index(row, 0),
                              SeedCompanyModel2::SeedCompanyRole::id)
                       .toUInt())
            return row;
    }
    return 0;
}

void Qrop::loadCurrentDatabase()
{
    int dbIdx = m_settings.value("currentDatabase", 1).toInt();
    QUrl defaultDatabaseUrl = m_db->defaultDatabasePathUrl();
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
    QString lang = QLocale::system().name(), prefLanguage = preferredLanguage();
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
