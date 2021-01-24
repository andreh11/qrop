#ifndef QROP_H
#define QROP_H

#include <QObject>
#include <QSettings>
#include <QNetworkAccessManager>
#include "singleton.h"
#include "buildinfo.h"

class BuildInfo;
class Database;
class QropNews;
class QTranslator;

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

signals:
    void info(const QString &msg);
    void error(const QString &err);

private:
    Qrop(QObject *parent = nullptr);

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
        return m_settings.value("preferredLanguage", "").toString();
    }

    inline QDate lastNewsUpdate() const {
        QString dateStr = m_settings.value("lastNewsUpdate", "").toString();
        return dateStr.isEmpty() ? QDate() : QDate::fromString(dateStr, "yyyy/MM/dd");
    }

    bool newReleaseAvailable(const QString &lastOnlineVersion);

private:
    void loadCurrentDatabase();
    void installTranslator();



    void _dumpSettings();
};

#endif // QROP_H
