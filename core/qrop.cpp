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
    , m_familyProxyModel(new FamilyProxyModel(this))
    , m_seedCompanyProxyModel(new SeedCompanyProxyModel(this))
    , m_undoStack(new QUndoStack)
    , m_isLocalDatabase(true)
{
}

void Qrop::clearBusinessObjects()
{
    m_undoStack->clear();

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
    delete m_familyProxyModel;

    clearBusinessObjects();
    delete m_undoStack;

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

bool Qrop::loadDatabase(const QUrl &url)
{
    clearBusinessObjects();
    if (url.isLocalFile()) {
        if (m_db->connectToDatabase(url)) {
            m_db->loadDatabase(this);
            qDebug() << "[Qrop::loadDatabase] "
                     << "nb Families: " << m_families.size() << ", nb Crops: " << m_crops.size()
                     << ", nb Varieties: " << m_varieties.size();
            m_isLocalDatabase = true;
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

QAbstractItemModel *Qrop::modelFamily() const
{
    return m_familyProxyModel;
}

QAbstractItemModel *Qrop::modelSeedCompany() const
{
    return m_seedCompanyProxyModel;
}

int Qrop::seedCompanyIdFromProxyRow(int proxyRow) const
{
    QModelIndex proxyIndex = m_seedCompanyProxyModel->index(proxyRow, 0);
    if (proxyIndex.isValid())
        return m_seedCompanyProxyModel->data(proxyIndex, SeedCompanyModel2::SeedCompanyRole::id).toInt();
    return 0;
}

int Qrop::seedCompanyProxyIndex(int seedCompanyId) const
{
    for (int row = 0; row < m_seedCompanyProxyModel->rowCount(); ++row) {
        if (seedCompanyId
            == m_seedCompanyProxyModel
                       ->data(m_seedCompanyProxyModel->index(row, 0),
                              SeedCompanyModel2::SeedCompanyRole::id)
                       .toInt())
            return row;
    }
    qDebug() << "[Qrop::seedCompanyProxyIndex] NOT FOUND seedCompanyId: " << seedCompanyId;
    return 0;
}

#include "commands/cmdfamilyupdate.h"
#include "commands/cmdcropupdate.h"
#include "commands/cmdvarietyupdate.h"
#include "commands/cmdvarietyadddel.h"
void Qrop::updateFamilyName(int proxyRow, int family_id, const QString &oldV, const QString &newV)
{
    int srcRow = m_familyProxyModel->sourceRow(proxyRow);
    qDebug() << "[Qrop::updateFamilyName] Row: " << srcRow << ", family_id: " << family_id
             << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(
                new CmdFamilyUpdate(srcRow, family_id, FamilyModel2::FamilyRole::name, oldV, newV));
}

void Qrop::updateFamilyColor(int proxyRow, int family_id, const QString &oldV, const QString &newV)
{
    int srcRow = m_familyProxyModel->sourceRow(proxyRow);
    qDebug() << "[Qrop::updateFamilyColor] Row: " << srcRow << ", family_id: " << family_id
             << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(new CmdFamilyUpdate(srcRow, family_id, FamilyModel2::FamilyRole::color,
                                              oldV, newV));
}

void Qrop::updateFamilyInterval(int proxyRow, int family_id, int oldV, int newV)
{
    int srcRow = m_familyProxyModel->sourceRow(proxyRow);
    qDebug() << "[Qrop::updateFamilyInterval] Row: " << srcRow << ", family_id: " << family_id
             << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(new CmdFamilyUpdate(srcRow, family_id, FamilyModel2::FamilyRole::interval,
                                              oldV, newV));
}

void Qrop::updateCropName(int srcRow, int family_id, int crop_id, const QString &oldV,
                          const QString &newV)
{
    qDebug() << "[Qrop::updateCropName] Row: " << srcRow << ", family_id: " << family_id
             << ", crop_id: " << crop_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(new CmdCropUpdate(srcRow, family_id, crop_id, CropModel2::CropRole::name,
                                            oldV, newV));
}

void Qrop::updateCropColor(int srcRow, int family_id, int crop_id, const QString &oldV,
                           const QString &newV)
{
    qDebug() << "[Qrop::updateCropColor] Row: " << srcRow << ", family_id: " << family_id
             << ", crop_id: " << crop_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(new CmdCropUpdate(srcRow, family_id, crop_id, CropModel2::CropRole::color,
                                            oldV, newV));
}

void Qrop::updateVarietyName(int srcRow, int crop_id, int variety_id, const QString &oldV,
                             const QString &newV)
{
    qDebug() << "[Qrop::updateVarietyName] Row: " << srcRow << ", crop_id: " << crop_id
             << ", variety_id: " << variety_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(new CmdVarietyUpdate(srcRow, crop_id, variety_id,
                                               VarietyModel2::VarietyRole::name, oldV, newV));
}

void Qrop::updateVarietyCompanySeed(int srcRow, int crop_id, int variety_id, int oldV, int newV)
{
    qDebug() << "[Qrop::updateVarietyCompanySeed] Row: " << srcRow << ", crop_id: " << crop_id
             << ", variety_id: " << variety_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        m_undoStack->push(new CmdVarietyUpdate(
                srcRow, crop_id, variety_id, VarietyModel2::VarietyRole::seedCompanyId, oldV, newV));
}

void Qrop::updateVarietyIsDefault(int srcRow, int crop_id, int variety_id, bool oldV, bool newV)
{
    qDebug() << "[Qrop::updateVarietyIsDefault] Row: " << srcRow << ", crop_id: " << crop_id
             << ", variety_id: " << variety_id << ", oldV : " << oldV << ", newV: " << newV;

    if (oldV != newV)
        m_undoStack->push(new CmdVarietyUpdate(srcRow, crop_id, variety_id,
                                               VarietyModel2::VarietyRole::isDefault, oldV, newV));
}

void Qrop::deleteVariety(int crop_id, int variety_id)
{
    qDebug() << "[Qrop::deleteVariety]  crop_id: " << crop_id << ", variety_id: " << variety_id;
    m_undoStack->push(new CmdVarietyAddDel(crop_id, variety_id));
}

void Qrop::addNewVariety(int crop_id, const QString &name, int seedCompanyId)
{
    qDebug() << "[Qrop::addNewVariety]  crop_id: " << crop_id;
    m_undoStack->push(new CmdVarietyAddDel(crop_id, name, seedCompanyId));
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
