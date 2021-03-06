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

#ifndef QROP_H
#define QROP_H

#include "singleton.h"
#include "buildinfo.h"
#include "core_global.h"

#include <QObject>
#include <QSettings>
#include <QNetworkAccessManager>

class BuildInfo;
class Database;
class QropNews;
class QTranslator;

class CORESHARED_EXPORT Qrop : public QObject, public Singleton<Qrop>
{
    Q_OBJECT
    friend class Singleton<Qrop>;
    Q_PROPERTY(QStringList languageNames READ languageNames NOTIFY languageNamesChanged)
    Q_PROPERTY(QStringList languageCodes READ languageCodes NOTIFY languageCodesChanged)

private:
    Qrop(QObject *parent = nullptr);

public:
    ~Qrop() override;

    int init();

    Q_INVOKABLE bool loadDatabase(const QUrl &url);
    Q_INVOKABLE QUrl defaultDatabaseUrl() const;
    Q_INVOKABLE bool saveDatabase(const QUrl &from, const QUrl &to);

    inline Q_INVOKABLE bool isMobileDevice() { return m_buildInfo->isMobileDevice(); }
    inline Q_INVOKABLE QropNews *news() const { return m_news; }
    inline QNetworkAccessManager &networkManager() { return m_networkManager; }
    inline Q_INVOKABLE BuildInfo *buildInfo() const { return m_buildInfo; }

    inline bool hasErrors() const { return m_errors.size() != 0; }
    inline void showErrors()
    {
        emit error(m_errors.join("\n"));
        m_errors.clear();
    };

    inline void sendInfo(const QString &msg)
    {
        emit info(msg);
        qDebug() << msg;
    }

    void sendError(const QString &err)
    {
        emit error(err);
        qCritical() << err;
    }

    inline QString preferredLanguage() const
    {
        return m_settings.value("preferredLanguage", "system").toString();
    }

    inline QDate lastNewsUpdate() const
    {
        QString dateStr = m_settings.value("lastNewsUpdate", "").toString();
        return dateStr.isEmpty() ? QDate() : QDate::fromString(dateStr, Qt::ISODate);
    }

    bool newReleaseAvailable(const QString &lastOnlineVersion);

    QStringList languageNames() const;
    QStringList languageCodes() const;
    QStringList findQmFiles() const;
    QString languageName(const QString &qmFile) const;

signals:
    void info(const QString &msg);
    void error(const QString &err);
    void languageNamesChanged();
    void languageCodesChanged();

private:
    void loadCurrentDatabase();
    void installTranslator();

    void _dumpSettings();

private:
    QSettings m_settings;
    QTranslator *m_translator;

    BuildInfo *const m_buildInfo;

    QStringList m_errors; //!< non critical errors happening prior to the GUI
    QNetworkAccessManager m_networkManager; //!< for http(s) requests
    QropNews *m_news;
};

#endif // QROP_H
