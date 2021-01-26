/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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

#include "buildinfo.h"
#include "filesystem.h"
#include "helpers.h"
#include "qropnews.h"
#include "qrpdate.h"
#include "nametree.h"
#include "print.h"
#include "qrpimageprovider.h"
#include "version.h"

#include "dbutils/db.h"
#include "dbutils/family.h"
#include "dbutils/keyword.h"
#include "dbutils/location.h"
#include "dbutils/note.h"
#include "dbutils/planting.h"
#include "dbutils/seedcompany.h"
#include "dbutils/task.h"
#include "dbutils/tasktemplate.h"
#include "dbutils/templatetask.h"
#include "dbutils/variety.h"

#include "core/qrop.h"

#include "models/cropmodel.h"
#include "models/cropstatmodel.h"
#include "models/familymodel.h"
#include "models/harvestmodel.h"
#include "models/keywordmodel.h"
#include "models/locationmodel.h"
#include "models/notemodel.h"
#include "models/plantingmodel.h"
#include "models/recordmodel.h"
#include "models/rolemodel.h"
#include "models/seedcompanymodel.h"
#include "models/seedlistmodel.h"
#include "models/seedlistmonthmodel.h"
#include "models/seedlistquartermodel.h"
#include "models/taskimplementmodel.h"
#include "models/taskmethodmodel.h"
#include "models/taskmodel.h"
#include "models/tasktemplatemodel.h"
#include "models/tasktypemodel.h"
#include "models/templatetaskmodel.h"
#include "models/transplantlistmodel.h"
#include "models/treemodel.h"
#include "models/unitmodel.h"
#include "models/usermodel.h"
#include "models/varietymodel.h"
#include "models/qquicktreemodeladaptor.h"

#include "qropdoublevalidator.h"
#include "timevalidator.h"

#include <QApplication>
#include <QFileSystemModel>
#include <QFontDatabase>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlFileSelector>
#include <QLoggingCategory>
#include <QAbstractItemModel>

struct PkgVersion {
    const int maj;
    const int min;
    PkgVersion(int major, int minor)
        : maj(major)
        , min(minor)
    {
    }
};

void registerFonts()
{
    const int ret1 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Bold.ttf");
    const int ret2 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    const int ret3 = QFontDatabase::addApplicationFont(":/fonts/RobotoCondensed-Regular.ttf");
    const int ret4 = QFontDatabase::addApplicationFont(":/fonts/FontAwesome.otf"); // font-awesome
    const int ret5 = QFontDatabase::addApplicationFont(":/fonts/MaterialIcons-Regular.ttf");
    if (ret1 == -1 || ret2 == -1 || ret3 == -1 || ret4 == -1 || ret5 == -1)
        qWarning() << "[desktop main] Some custom fonts can't be loaded.";
}

void registerTypes()
{
    const char *packageURI = "io.qrop.components";
    const PkgVersion ver { 1, 0 };

    qmlRegisterUncreatableType<Qrop>(packageURI, ver.maj, ver.min, "Qrop",
                                     QStringLiteral("Qrop should not be created in QML"));

    qmlRegisterUncreatableType<BuildInfo>(packageURI, ver.maj, ver.min, "BuildInfo",
                                          QStringLiteral("BuildInfo should not be created in QML"));
    qmlRegisterUncreatableType<QropNews>(packageURI, ver.maj, ver.min, "QropNews",
                                         QStringLiteral("QropNews should not be created in QML"));

    qmlRegisterInterface<QAbstractItemModel>("io.qrop.components");
    //    qmlRegisterType<CropModel2>(packageURI, ver.maj, ver.min, "CropModel2");
    qmlRegisterType<CropProxyModel>(packageURI, ver.maj, ver.min, "CropProxyModel");

    qmlRegisterType<CropModel>(packageURI, ver.maj, ver.min, "CropModel");
    qmlRegisterType<CropStatModel>(packageURI, ver.maj, ver.min, "CropStatModel");
    qmlRegisterType<FamilyModel>(packageURI, ver.maj, ver.min, "FamilyModel");
    qmlRegisterType<HarvestModel>(packageURI, ver.maj, ver.min, "HarvestModel");
    qmlRegisterType<KeywordModel>(packageURI, ver.maj, ver.min, "KeywordModel");
    qmlRegisterType<LocationModel>(packageURI, ver.maj, ver.min, "LocationModel");
    qmlRegisterType<NoteModel>(packageURI, ver.maj, ver.min, "NoteModel");
    qmlRegisterType<PlantingModel>(packageURI, ver.maj, ver.min, "PlantingModel");
    qmlRegisterType<QFileSystemModel>(packageURI, ver.maj, ver.min, "FileSystemModel");
    qmlRegisterType<QropDoubleValidator>(packageURI, ver.maj, ver.min, "QropDoubleValidator");
    qmlRegisterType<RecordModel>(packageURI, ver.maj, ver.min, "RecordModel");
    qmlRegisterType<SeedCompanyModel>(packageURI, ver.maj, ver.min, "SeedCompanyModel");
    qmlRegisterType<SeedListModel>(packageURI, ver.maj, ver.min, "SeedListModel");
    qmlRegisterType<SeedListMonthModel>(packageURI, ver.maj, ver.min, "SeedListMonthModel");
    qmlRegisterType<SeedListQuarterModel>(packageURI, ver.maj, ver.min, "SeedListQuarterModel");
    qmlRegisterType<SqlTreeModel>(packageURI, ver.maj, ver.min, "SqlTreeModel");
    qmlRegisterType<TaskImplementModel>(packageURI, ver.maj, ver.min, "TaskImplementModel");
    qmlRegisterType<TaskMethodModel>(packageURI, ver.maj, ver.min, "TaskMethodModel");
    qmlRegisterType<TaskModel>(packageURI, ver.maj, ver.min, "TaskModel");
    qmlRegisterType<TaskTemplateModel>(packageURI, ver.maj, ver.min, "TaskTemplateModel");
    qmlRegisterType<TaskTypeModel>(packageURI, ver.maj, ver.min, "TaskTypeModel");
    qmlRegisterType<TemplateTaskModel>(packageURI, ver.maj, ver.min, "TemplateTaskModel");
    qmlRegisterType<TimeValidator>(packageURI, ver.maj, ver.min, "TimeValidator");
    qmlRegisterType<TransplantListModel>(packageURI, ver.maj, ver.min, "TransplantListModel");
    qmlRegisterType<UnitModel>(packageURI, ver.maj, ver.min, "UnitModel");
    qmlRegisterType<VarietyModel>(packageURI, ver.maj, ver.min, "VarietyModel");
    qmlRegisterType<QQuickTreeModelAdaptor>(packageURI, ver.maj, ver.min, "TreeModelAdaptor");

    qmlRegisterSingletonType<Planting>(packageURI, ver.maj, ver.min, "Planting",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                           Q_UNUSED(engine)
                                           Q_UNUSED(scriptEngine)
                                           return new Planting;
                                       });

    qmlRegisterSingletonType<FileSystem>(packageURI, ver.maj, ver.min, "FileSystem",
                                         [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                             Q_UNUSED(engine)
                                             Q_UNUSED(scriptEngine)
                                             return new FileSystem();
                                         });

    qmlRegisterSingletonType<Print>(packageURI, ver.maj, ver.min, "Print",
                                    [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                        Q_UNUSED(engine)
                                        Q_UNUSED(scriptEngine)
                                        auto *print = new Print();
                                        return print;
                                    });

    qmlRegisterSingletonType<Helpers>(packageURI, ver.maj, ver.min, "Helpers",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *helpers = new Helpers();
                                          return helpers;
                                      });

    qmlRegisterSingletonType<dbutils::Family>(packageURI, ver.maj, ver.min, "Family",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *family = new dbutils::Family();
                                                  return family;
                                              });

    qmlRegisterSingletonType<dbutils::Variety>(
            packageURI, ver.maj, ver.min, "Variety",
            [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                Q_UNUSED(engine)
                Q_UNUSED(scriptEngine)
                auto *variety = new dbutils::Variety();
                return variety;
            });

    qmlRegisterSingletonType<SeedCompany>(packageURI, ver.maj, ver.min, "SeedCompany",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                              Q_UNUSED(engine)
                                              Q_UNUSED(scriptEngine)
                                              auto *seedCompany = new SeedCompany();
                                              return seedCompany;
                                          });

    qmlRegisterSingletonType<Keyword>(packageURI, ver.maj, ver.min, "Keyword",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *keyword = new Keyword();
                                          return keyword;
                                      });

    qmlRegisterSingletonType<Task>(packageURI, ver.maj, ver.min, "Task",
                                   [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                       Q_UNUSED(engine)
                                       Q_UNUSED(scriptEngine)
                                       auto *task = new Task();
                                       return task;
                                   });

    qmlRegisterSingletonType<Location>(packageURI, ver.maj, ver.min, "Location",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                           Q_UNUSED(engine)
                                           Q_UNUSED(scriptEngine)
                                           auto *location = new Location();
                                           return location;
                                       });

    qmlRegisterSingletonType<QrpDate>(packageURI, ver.maj, ver.min, "QrpDate",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *mdate = new QrpDate();
                                          return mdate;
                                      });

    qmlRegisterSingletonType<Note>(packageURI, ver.maj, ver.min, "Note",
                                   [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                       Q_UNUSED(engine)
                                       Q_UNUSED(scriptEngine)
                                       auto *db = new Note();
                                       db->setTable("note");
                                       return db;
                                   });

    qmlRegisterSingletonType<DatabaseUtility>(packageURI, ver.maj, ver.min, "Crop",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *crop = new DatabaseUtility();
                                                  crop->setTable("crop");
                                                  return crop;
                                              });

    qmlRegisterSingletonType<TemplateTask>(packageURI, ver.maj, ver.min, "TemplateTask",
                                           [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                               Q_UNUSED(engine)
                                               Q_UNUSED(scriptEngine)
                                               auto *db = new TemplateTask();
                                               return db;
                                           });

    qmlRegisterSingletonType<DatabaseUtility>(packageURI, ver.maj, ver.min, "Unit",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *unit = new DatabaseUtility();
                                                  unit->setTable("unit");
                                                  unit->setViewTable("unit");
                                                  return unit;
                                              });

    qmlRegisterSingletonType<TaskTemplate>(packageURI, ver.maj, ver.min, "TaskTemplate",
                                           [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                               Q_UNUSED(engine)
                                               Q_UNUSED(scriptEngine)
                                               auto *tasktemplate = new TaskTemplate();
                                               return tasktemplate;
                                           });

    qmlRegisterSingletonType<DatabaseUtility>(packageURI, ver.maj, ver.min, "TaskType",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *tasktype = new DatabaseUtility();
                                                  tasktype->setTable("task_type");
                                                  tasktype->setViewTable("task_type");
                                                  return tasktype;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>(packageURI, ver.maj, ver.min, "TaskMethod",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *taskmethod = new DatabaseUtility();
                                                  taskmethod->setTable("task_method");
                                                  taskmethod->setViewTable("task_method");
                                                  return taskmethod;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>(packageURI, ver.maj, ver.min, "TaskImplement",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *taskimplement = new DatabaseUtility();
                                                  taskimplement->setTable("task_implement");
                                                  taskimplement->setViewTable("task_implement");
                                                  return taskimplement;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>(packageURI, ver.maj, ver.min, "Harvest",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *db = new DatabaseUtility();
                                                  db->setTable("harvest");
                                                  return db;
                                              });
}

int main(int argc, char *argv[])
{
    qInfo() << "qrop" << GIT_BRANCH << GIT_COMMIT_HASH;

    // disable SSL warnings
    QLoggingCategory::setFilterRules("qt.network.ssl.warning=false");

    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QApplication::setApplicationName("Qrop");
    QApplication::setOrganizationName("AH");
    QApplication::setOrganizationDomain("io.qrop");
    QApplication::setApplicationDisplayName("Qrop");
    QApplication::setApplicationVersion("0.4.5");
    QApplication::setWindowIcon(QIcon(":/icon.png"));

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    FileSystem::createMobileRootFilesDirectories();
#endif

    registerFonts();
    registerTypes();

    Qrop *qrop = Qrop::instance();
    QObject::connect(&app, &QCoreApplication::aboutToQuit, &Qrop::clear);
    int res = qrop->init();
    if (res != 0)
        return res;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("cppQrop", qrop);

    // really important, otherwise QML could take ownership and delete them
    // (cf http://doc.qt.io/qt-5/qtqml-cppintegration-data.html#data-ownership )
    engine.setObjectOwnership(qrop->buildInfo(), QQmlEngine::CppOwnership);
    engine.setObjectOwnership(qrop->news(), QQmlEngine::CppOwnership);
    engine.setObjectOwnership(qrop->modelFamily(), QQmlEngine::CppOwnership);

    //    QQmlFileSelector *selector = new QQmlFileSelector(&engine);
    const QUrl url(QStringLiteral("qrc:/qml/MainWindow.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                     [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     },
                     Qt::QueuedConnection);
    engine.load(url);
    engine.addImageProvider("pictures", new QrpImageProvider());

    if (qrop->hasErrors())
        qrop->showErrors();

    qrop->news()->fetchNews();

    return app.exec();
}
