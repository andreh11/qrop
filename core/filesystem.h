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

#pragma once

#include "core_global.h"

#include <QObject>
#include <QMap>

class CORESHARED_EXPORT FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rootPath READ rootPath CONSTANT FINAL)
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    Q_PROPERTY(QString csvPath READ csvPath CONSTANT FINAL)
    Q_PROPERTY(QString pdfPath READ pdfPath CONSTANT FINAL)
#endif

public:
    explicit FileSystem(QObject *parent = nullptr);

    inline static QString rootPath() { return s_rootPath; }

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    inline static QString csvPath()
    {
        return QString("%1/%2").arg(s_rootPath).arg(s_subFolders.value("csv"));
    }
    inline static QString pdfPath()
    {
        return QString("%1/%2").arg(s_rootPath).arg(s_subFolders.value("pdf"));
    }

    Q_INVOKABLE static QStringList getAvailableDataBasesNames();
    Q_INVOKABLE static QStringList getAvailableCsvFileNames();

    static void createMobileRootFilesDirectories();
#endif

private:
    static QString s_rootPath;
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    static const QMap<QString, QString> s_subFolders;
    static bool createDocumentsFolder();
    static bool createQropFolder();
#endif
};
