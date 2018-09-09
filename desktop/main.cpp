#include <QGuiApplication>
#include <QFontDatabase>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QIcon>
#include <QHash>
#include <QVariantMap>

#include "plantingmodel.h"
#include "taskmodel.h"
#include "notemodel.h"

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
        QFile::remove(fileName);
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
    }
    qInfo("database open!");
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setApplicationName("Qrop");
    QCoreApplication::setOrganizationName("AH");
    QCoreApplication::setOrganizationDomain("io.qrop");

    QGuiApplication app(argc, argv);

    int ret1 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Bold.ttf");
    int ret2 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    int ret3 = QFontDatabase::addApplicationFont(":/fonts/RobotoCondensed-Regular.ttf");
    int ret4 = QFontDatabase::addApplicationFont(":/fonts/fa-regular-400.ttf"); // font-awesome
    if (ret1 == -1 || ret2 == -1 || ret3 == -1 || ret4 == -1)
        qWarning() << "Some custom fonts can't be loaded.";

    qmlRegisterType<PlantingModel>("io.croplan.components", 1, 0, "SqlPlantingModel");
    qmlRegisterType<TaskModel>("io.croplan.components", 1, 0, "SqlTaskModel");
    qmlRegisterType<NoteModel>("io.croplan.components", 1, 0, "SqlNoteModel");

    connectToDatabase();

    PlantingModel plantingTable;
    QVariantMap hash;
    hash["variety_id"] = 4;
    hash["crop"] = "TOMATO";
    hash["variety"] = "Cindel F1";
    hash["seeding_date"] = "2018-05-13";
    hash["transplanting_date"] = "2018-06-13";
    hash["beg_harvest_date"] = "2018-06-20";
    hash["end_harvest_date"] = "2018-06-30";
    plantingTable.add(hash);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
