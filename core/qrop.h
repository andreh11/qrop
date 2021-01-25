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

#include <QObject>
#include <QSettings>
#include <QNetworkAccessManager>
#include <QHash>
#include "singleton.h"
#include "buildinfo.h"

class BuildInfo;
class Database;
class QropNews;
class QTranslator;

#include "business/family.h"
class Qrop : public QObject, public Singleton<Qrop>
{
    Q_OBJECT
    friend class Singleton<Qrop>;

private:
    QSettings m_settings;
    QTranslator *m_translator;

    Database *const m_db; //!< db connection
    BuildInfo *const m_buildInfo;

    QStringList m_errors; //!< non critical errors happening prior to the GUI
    QNetworkAccessManager m_netMgr; //!< for http(s) requests
    QropNews *m_news;

    QHash<uint, qrp::Family*> m_families;
    QHash<uint, qrp::Crop*> m_crops;
    QHash<uint, qrp::Variety*> m_varieties;


signals:
    void info(const QString &msg);
    void error(const QString &err);

private:
    Qrop(QObject *parent = nullptr);

    void clearBusinessObjects();

public:
    ~Qrop();

    int init();

    Q_INVOKABLE bool loadDatabase(const QUrl &url);
    Q_INVOKABLE QUrl defaultDatabaseUrl() const;
    Q_INVOKABLE bool saveDatabase(const QUrl &from, const QUrl &to);

    inline Q_INVOKABLE bool isMobileDevice() {return m_buildInfo->isMobileDevice();}

    inline Q_INVOKABLE QropNews *news() const {return m_news;}

    inline bool hasErrors() const {return m_errors.size() != 0;}
    inline void showErrors() {
        emit error(m_errors.join("\n"));
        m_errors.clear();
    };

    inline QNetworkAccessManager &networkManager() {return m_netMgr;}
    inline Q_INVOKABLE BuildInfo *buildInfo() const {return m_buildInfo;}

    inline void sendInfo(const QString &msg) {
        emit info(msg);
        qDebug() << msg;
    }
    void sendError(const QString &err){
        emit error(err);
        qCritical() << err;
    }

    inline QString preferredLanguage() const {
        return m_settings.value("preferredLanguage", "system").toString();
    }

    inline QDate lastNewsUpdate() const {
        QString dateStr = m_settings.value("lastNewsUpdate", "").toString();
        return dateStr.isEmpty() ? QDate() : QDate::fromString(dateStr, Qt::ISODate);
    }

    bool newReleaseAvailable(const QString &lastOnlineVersion);


    void addFamily(uint id, const QString &name, ushort interval, const QString &color) {
        m_families.insert(id, new qrp::Family(id, name, interval, color));
    }
    void addCrop(uint id, const QString &name, const QString &color, uint family_id) {
        qrp::Family *family = m_families.value(family_id, nullptr);
        if (family) {
            qrp::Crop *crop = new qrp::Crop(id, name, color, family);
            m_crops.insert(id, crop);
            family->addCrop(crop);
        }
    }
    void addVariety(uint id, const QString &name, uint crop_id, bool is_default) {
        qrp::Crop *crop = m_crops.value(crop_id, nullptr);
        if (crop) {
            qrp::Variety *variety = new qrp::Variety(id, name, is_default, crop);
            m_varieties.insert(id, variety);
            crop->addVariety(variety);
        }
    }


private:
    void loadCurrentDatabase();
    void installTranslator();



    void _dumpSettings();
};

#endif // QROP_H