#include <QUrl>
#include <QTranslator>
#include <QCoreApplication>

#include "qropnews.h"
#include "qrop.h"
#include "dbutils/db.h"

Qrop::Qrop(QObject *parent)
    : QObject(parent)
    , Singleton<Qrop>()
    , m_settings()
    , m_translator(new QTranslator)
    , m_db(new Database(this))
    , m_buildInfo(new BuildInfo)
    , m_errors()
    , m_netMgr()
    , m_news(new QropNews())
{
}

Qrop::~Qrop()
{
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

    // can we load SQLite driver?
    if (!m_db->addDefaultSqliteDatabase()) {
        qCritical() << "Cannot load SQLite driver...";
        return 1;
    }

    installTranslator();

    // load current database (or default one)
    loadCurrentDatabase();

    m_news->fetchNews();

    return 0;
}

bool Qrop::loadDatabase(const QUrl &url)
{
    if (url.isLocalFile())
        return m_db->connectToDatabase(url);
    else if (url.scheme().startsWith("http"))
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
    QString lang = QLocale::system().name(),
            preferredLanguage = m_settings.value("preferredLanguage", "system").toString();
    qDebug() << "LANG: " << lang << ", preferredLanguage: " << preferredLanguage;

    if (preferredLanguage == "system")
        m_translator->load(QLocale(), "qrop", "_", ":/translations", ".qm");
    else
        m_translator->load(":/translations/qrop_" + preferredLanguage + ".qm");

    qApp->installTranslator(m_translator);
}

void Qrop::_dumpSettings()
{
    for (const QString &key : m_settings.allKeys())
        qDebug() << "[dumpSettings] " << key << ": " << m_settings.value(key);
}
