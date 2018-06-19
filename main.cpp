#include <QGuiApplication>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QIcon>

#include "sqlplantingmodel.h"
#include "sqltaskmodel.h"

static void connectToDatabase()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s",
                   qPrintable(database.lastError().text()));
    }

    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s",
               qPrintable(writeDir.absolutePath()));

    // Ensure that we have a writable location on all devices.
    //const QString fileName = writeDir.absolutePath() + "/croplan.sqlite3";
    const QString fileName = "/home/ah/.logimaraich/db.sqlite";
    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    database.setDatabaseName(fileName);
    if (!database.open()) {
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
        QFile::remove(fileName);
    }
    qInfo("database open!");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<SqlPlantingModel>("io.croplan.components", 1, 0, "SqlPlantingModel");
    qmlRegisterType<SqlTaskModel>("io.croplan.components", 1, 0, "SqlTaskModel");

    connectToDatabase();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
