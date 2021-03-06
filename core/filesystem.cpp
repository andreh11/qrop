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

#include "filesystem.h"
#include <QStandardPaths>
#include <QDebug>

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
#define APP_NAME "Qrop"
#include <QDir>
#if defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QtAndroid>
#endif
#endif

QString FileSystem::s_rootPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
const QMap<QString, QString> FileSystem::s_subFolders { { "csv", "csv" }, { "pdf", "pdf" } };
#endif

FileSystem::FileSystem(QObject *parent)
    : QObject(parent)
{
}

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
bool FileSystem::createDocumentsFolder()
{
    QFileInfo fi(s_rootPath);
    if (fi.exists()) {
        if (fi.isDir())
            return true;
        else {
            qCritical() << "Documents exists but is a File...";
            return false;
        }
    }

    qDebug() << "Creating Documents folder: " << s_rootPath;
    QDir dir(fi.absolutePath());
    if (!dir.mkdir(fi.fileName())) {
        qCritical() << "Couldn't create Documents folder...";
        return false;
    }
    return true;
}

bool FileSystem::createQropFolder()
{
    QFileInfo fi(QString("%1/%2").arg(s_rootPath, APP_NAME));
    if (!fi.exists()) {
        QDir dir(s_rootPath);
        if (!dir.mkdir(APP_NAME)) {
            qCritical() << "Couldn't create Qrop folder: " << fi.absoluteFilePath();
            return false;
        }
    }
    s_rootPath = fi.absoluteFilePath();
    return true;
}

void FileSystem::createMobileRootFilesDirectories()
{
#if defined(Q_OS_ANDROID)
    QtAndroid::PermissionResultMap res =
            QtAndroid::requestPermissionsSync({ "android.permission.WRITE_EXTERNAL_STORAGE" });
    if (res["android.permission.WRITE_EXTERNAL_STORAGE"] != QtAndroid::PermissionResult::Granted) {
        qCritical() << "don't have WRITE_EXTERNAL_STORAGE permission...";
        return;
    }
#endif

    if (createDocumentsFolder() && createQropFolder()) {
        // create all subFolders
        QDir dir(s_rootPath);
        for (const auto &folder : s_subFolders.values())
            dir.mkdir(folder);
    }
}

QStringList FileSystem::getAvailableDataBasesNames()
{
    QStringList dbNames;
    QDir dir(s_rootPath);
    for (const QFileInfo &fi :
         dir.entryInfoList(QStringList("*.sqlite"), QDir::Filter::Files, QDir::SortFlag::Name))
        dbNames << fi.completeBaseName();
    return dbNames;
}

QStringList FileSystem::getAvailableCsvFileNames()
{
    QStringList csvNames;
    QDir dir(csvPath());
    for (const QFileInfo &fi :
         dir.entryInfoList(QStringList("*.csv"), QDir::Filter::Files, QDir::SortFlag::Name))
        csvNames << fi.completeBaseName();
    return csvNames;
}
#endif // #if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
