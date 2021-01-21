#include <QDebug>
#include <QUrl>

#include "qrop.h"
#include "dbutils/db.h"

Qrop::Qrop(QObject *parent)
    : QObject(parent)
    , Singleton<Qrop>()
    , m_settings()
    , m_db(new Database(this))
    , m_errors()
{
}

Qrop::~Qrop()
{
    m_db->close();
    m_settings.sync();
}

int Qrop::init()
{
    // can we load SQLite driver?
    if (!m_db->addDefaultSqliteDatabase()) {
        qCritical() << "Cannot load SQLite driver...";
        return 1;
    }

    // load current database (or default one)
    loadCurrentDatabase();

    return 0;
}

bool Qrop::loadDatabase(const QUrl &url)
{
    if (url.isLocalFile())
        return m_db->connectToDatabase(url);
    else if (url.scheme().startsWith("http"))
        return false; // MB_TODO: load from json request
}

QUrl Qrop::defaultDatabaseUrl() const
{
    return m_db->defaultDatabasePathUrl();
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
