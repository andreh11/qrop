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
#include <QTranslator>
#include <QQuickView>

#include "plantingmodel.h"
#include "taskmodel.h"
#include "notemodel.h"
#include "usermodel.h"
#include "rolemodel.h"
#include "cropmodel.h"
#include "varietymodel.h"
#include "db.h"

// TODO: move this to core
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
    const QString fileName = writeDir.absolutePath() + "/qrop.db";
    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    qDebug() << fileName;
    database.setDatabaseName(fileName);
    if (!database.open()) {
        QFile::remove(fileName);
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
    }
}

static QObject *plantingCallback(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    Planting *planting = new Planting();
    return planting;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setApplicationName("Qrop");
    QCoreApplication::setOrganizationName("AH");
    QCoreApplication::setOrganizationDomain("io.qrop");

    QGuiApplication app(argc, argv);

    QString lang = QLocale::system().name();
//    if (lang == "fr_FR") {
        QTranslator translator;
        translator.load(":/translations/fr.qm");
        app.installTranslator(&translator);
//    }

    int ret1 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Bold.ttf");
    int ret2 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    int ret3 = QFontDatabase::addApplicationFont(":/fonts/RobotoCondensed-Regular.ttf");
    int ret4 = QFontDatabase::addApplicationFont(":/fonts/fa-regular-400.ttf"); // font-awesome
    if (ret1 == -1 || ret2 == -1 || ret3 == -1 || ret4 == -1)
        qWarning() << "Some custom fonts can't be loaded.";

//    QQuickView view;
//    Planting dbPlanting;

//      view.rootContext()->setContextProperty("dbPlanting", &dbPlanting);

    qmlRegisterType<PlantingModel>("io.croplan.components", 1, 0, "PlantingModel");
    qmlRegisterType<CropModel>("io.croplan.components", 1, 0, "CropModel");
    qmlRegisterType<VarietyModel>("io.croplan.components", 1, 0, "VarietyModel");
    qmlRegisterType<VarietyModel>("io.croplan.components", 1, 0, "CropModel");
    qmlRegisterType<TaskModel>("io.croplan.components", 1, 0, "TaskModel");
    qmlRegisterType<NoteModel>("io.croplan.components", 1, 0, "NoteModel");

//    qmlRegisterType<Planting>("io.croplan.components", 1, 0, "Planting");
    qmlRegisterSingletonType<Planting>("io.croplan.components", 1, 0, "Planting", plantingCallback);

    connectToDatabase();

//    QList<QList<QVariant>> userList({{"André", "Hoarau", "ah@ouvaton.org", 1},
//                                     {"Diane", "Richard", "danette222@hotmail.fr", 1}});

//    UserModel userModel;
//    foreach (const QList<QVariant> &user, userList) {
//        QVariantMap userMap({{"first_name", user[0]},
//                             {"last_name", user[1]},
//                             {"email", user[2]},
//                             {"role_id", user[3]}});

//        int id = userModel.add(userMap);
//        int dupId = userModel.duplicate(id);
//        userModel.remove(dupId);
//        userModel.update(id, {{"last_name", "Waro"}});
//    }

//    PlantingModel plantingModel;
//    QList<QList<QVariant>> plantingMap({{1, 0, "2018-03-02"},
//                                        {2, 1, "2018-01-04"},
//                                        {2, 2, "2018-01-28"}});

//    foreach (const QList<QVariant> &planting, plantingMap) {
//        QVariantMap plantingMap({{"variety_id", planting[0]},
//                                 {"planting_type", planting[1]},
//                                 {"planting_date", planting[2]}});
//        Planting::add(plantingMap);
//    }

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
