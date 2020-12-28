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

#include "buildinfo.h"
#include "version.h"

#include <QDebug>
#include <QStandardPaths>

BuildInfo::BuildInfo(QObject *parent)
    : QObject(parent)
    ,
#ifdef QROP_VERSION
    m_version(QROP_VERSION)
#else
    m_version(tr("Unknown build version"))
#endif
    ,
#ifdef GIT_COMMIT_HASH
    m_commit(GIT_COMMIT_HASH)
#else
    m_commit(tr("Unknown commit hash"))
#endif
    ,
#ifdef GIT_BRANCH
    m_branch(GIT_BRANCH)
#else
    m_branch(tr("Unknown commit branch"))
#endif
  ,
//  m_rootPath("/home/bruel/Documents/Qrop")
  m_rootPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation))
{
}

QString BuildInfo::version() const
{
    qDebug() << "VERSION" << m_version;
    return m_version;
}

QString BuildInfo::commit() const
{
    qDebug() << "COMMIT" << m_commit;
    return m_commit;
}

QString BuildInfo::branch() const
{
    qDebug() << "BRANCH" << m_branch;
    return m_branch;
}


//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
#define APP_NAME "Qrop"
#include <QDir>
#if defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QtAndroid>
#endif
void BuildInfo::createMobileRootFilesDirectory()
{
    qDebug() << "[MB_TRACE] standard writable app data loc: " << QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    qDebug() << "[MB_TRACE] standard writable app conf loc: " << QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    qDebug() << "[MB_TRACE] standard writable data loc: "     << QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    qDebug() << "[MB_TRACE] standard writable apps loc: "     << QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
    qDebug() << "[MB_TRACE] standard writable doc loc: "      << QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    qDebug() << "[MB_TRACE] standard writable down loc: "     << QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);

    m_rootPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
#if defined(Q_OS_ANDROID)
        QtAndroid::PermissionResultMap res = QtAndroid::requestPermissionsSync({"android.permission.WRITE_EXTERNAL_STORAGE"});
        if (res["android.permission.WRITE_EXTERNAL_STORAGE"] != QtAndroid::PermissionResult::Granted) {
            qCritical() << "don't have WRITE_EXTERNAL_STORAGE permission...";
            return;
        }
#endif

    // 1. Check if main Documents folder exist
    if (!QDir(m_rootPath).exists()) {
        qDebug() << "Creating Documents folder: " << m_rootPath;
        QFileInfo fi(m_rootPath);
        QDir dir(fi.absolutePath());
        if (!dir.mkdir(fi.fileName())){
            qCritical() << "Couldn't create Documents folder...";
            return;
        }
    }

    // 2.: Create Qrop subFolder
    QFileInfo fi(QString("%1/%2").arg(m_rootPath).arg(APP_NAME));
    if (!fi.exists()) {
        QDir dir(m_rootPath);
        if (!dir.mkdir(APP_NAME))
            qCritical() << "Couldn't create folder: " << fi.absoluteFilePath();
    }

    // 3.: create all subFolders
    if (fi.exists())
    {
        m_rootPath = fi.absoluteFilePath();
        QDir dir(m_rootPath);
        for (const auto folder : {"csv", "pdf"}) {
            if (!QFileInfo(QString("%1/%2").arg(m_rootPath).arg(folder)).exists())
                dir.mkdir(folder);
        }
    }
}

QStringList BuildInfo::getAvailableDataBasesNames() const
{
    QStringList dbPaths;
    QDir dir(m_rootPath);
    for(const QFileInfo &fi: dir.entryInfoList(QStringList("*.sqlite"),
                                               QDir::Filter::Files,
                                               QDir::SortFlag::Name))
        dbPaths << fi.completeBaseName();
    return dbPaths;
}
//#endif // #if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
