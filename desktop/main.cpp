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
    qmlRegisterUncreatableType<BuildInfo>("io.qrop.components", 1, 0, "BuildInfo",
                                          QStringLiteral("BuildInfo should not be created in QML"));
    qmlRegisterUncreatableType<QropNews>("io.qrop.components", 1, 0, "QropNews",
                                         QStringLiteral("QropNews should not be created in QML"));

    qmlRegisterType<CropModel>("io.qrop.components", 1, 0, "CropModel");
    qmlRegisterType<CropStatModel>("io.qrop.components", 1, 0, "CropStatModel");
    qmlRegisterType<FamilyModel>("io.qrop.components", 1, 0, "FamilyModel");
    qmlRegisterType<HarvestModel>("io.qrop.components", 1, 0, "HarvestModel");
    qmlRegisterType<KeywordModel>("io.qrop.components", 1, 0, "KeywordModel");
    qmlRegisterType<LocationModel>("io.qrop.components", 1, 0, "LocationModel");
    qmlRegisterType<NoteModel>("io.qrop.components", 1, 0, "NoteModel");
    qmlRegisterType<PlantingModel>("io.qrop.components", 1, 0, "PlantingModel");
    qmlRegisterType<QFileSystemModel>("io.qrop.components", 1, 0, "FileSystemModel");
    qmlRegisterType<QropDoubleValidator>("io.qrop.components", 1, 0, "QropDoubleValidator");
    qmlRegisterType<RecordModel>("io.qrop.components", 1, 0, "RecordModel");
    qmlRegisterType<SeedCompanyModel>("io.qrop.components", 1, 0, "SeedCompanyModel");
    qmlRegisterType<SeedListModel>("io.qrop.components", 1, 0, "SeedListModel");
    qmlRegisterType<SeedListMonthModel>("io.qrop.components", 1, 0, "SeedListMonthModel");
    qmlRegisterType<SeedListQuarterModel>("io.qrop.components", 1, 0, "SeedListQuarterModel");
    qmlRegisterType<SqlTreeModel>("io.qrop.components", 1, 0, "SqlTreeModel");
    qmlRegisterType<TaskImplementModel>("io.qrop.components", 1, 0, "TaskImplementModel");
    qmlRegisterType<TaskMethodModel>("io.qrop.components", 1, 0, "TaskMethodModel");
    qmlRegisterType<TaskModel>("io.qrop.components", 1, 0, "TaskModel");
    qmlRegisterType<TaskTemplateModel>("io.qrop.components", 1, 0, "TaskTemplateModel");
    qmlRegisterType<TaskTypeModel>("io.qrop.components", 1, 0, "TaskTypeModel");
    qmlRegisterType<TemplateTaskModel>("io.qrop.components", 1, 0, "TemplateTaskModel");
    qmlRegisterType<TimeValidator>("io.qrop.components", 1, 0, "TimeValidator");
    qmlRegisterType<TransplantListModel>("io.qrop.components", 1, 0, "TransplantListModel");
    qmlRegisterType<UnitModel>("io.qrop.components", 1, 0, "UnitModel");
    qmlRegisterType<VarietyModel>("io.qrop.components", 1, 0, "VarietyModel");
    qmlRegisterType<QQuickTreeModelAdaptor>("io.qrop.components", 1, 0, "TreeModelAdaptor");

    qmlRegisterSingletonType<Planting>("io.qrop.components", 1, 0, "Planting",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                           Q_UNUSED(engine)
                                           Q_UNUSED(scriptEngine)
                                           return new Planting;
                                       });

    qmlRegisterSingletonType<FileSystem>("io.qrop.components", 1, 0, "FileSystem",
                                         [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                             Q_UNUSED(engine)
                                             Q_UNUSED(scriptEngine)
                                             return new FileSystem();
                                         });

    qmlRegisterSingletonType<Print>("io.qrop.components", 1, 0, "Print",
                                    [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                        Q_UNUSED(engine)
                                        Q_UNUSED(scriptEngine)
                                        auto *print = new Print();
                                        return print;
                                    });

    qmlRegisterSingletonType<Helpers>("io.qrop.components", 1, 0, "Helpers",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *helpers = new Helpers();
                                          return helpers;
                                      });

    qmlRegisterSingletonType<Family>("io.qrop.components", 1, 0, "Family",
                                     [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                         Q_UNUSED(engine)
                                         Q_UNUSED(scriptEngine)
                                         auto *family = new Family();
                                         return family;
                                     });

    qmlRegisterSingletonType<Variety>("io.qrop.components", 1, 0, "Variety",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *variety = new Variety();
                                          return variety;
                                      });

    qmlRegisterSingletonType<SeedCompany>("io.qrop.components", 1, 0, "SeedCompany",
                                          [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                              Q_UNUSED(engine)
                                              Q_UNUSED(scriptEngine)
                                              auto *seedCompany = new SeedCompany();
                                              return seedCompany;
                                          });

    qmlRegisterSingletonType<Keyword>("io.qrop.components", 1, 0, "Keyword",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *keyword = new Keyword();
                                          return keyword;
                                      });

    qmlRegisterSingletonType<Task>("io.qrop.components", 1, 0, "Task",
                                   [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                       Q_UNUSED(engine)
                                       Q_UNUSED(scriptEngine)
                                       auto *task = new Task();
                                       return task;
                                   });

    qmlRegisterSingletonType<Location>("io.qrop.components", 1, 0, "Location",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                           Q_UNUSED(engine)
                                           Q_UNUSED(scriptEngine)
                                           auto *location = new Location();
                                           return location;
                                       });

    qmlRegisterSingletonType<QrpDate>("io.qrop.components", 1, 0, "QrpDate",
                                      [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                          Q_UNUSED(engine)
                                          Q_UNUSED(scriptEngine)
                                          auto *mdate = new QrpDate();
                                          return mdate;
                                      });

    qmlRegisterSingletonType<Note>("io.qrop.components", 1, 0, "Note",
                                   [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                       Q_UNUSED(engine)
                                       Q_UNUSED(scriptEngine)
                                       auto *db = new Note();
                                       db->setTable("note");
                                       return db;
                                   });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "Crop",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *crop = new DatabaseUtility();
                                                  crop->setTable("crop");
                                                  return crop;
                                              });

    qmlRegisterSingletonType<TemplateTask>("io.qrop.components", 1, 0, "TemplateTask",
                                           [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                               Q_UNUSED(engine)
                                               Q_UNUSED(scriptEngine)
                                               auto *db = new TemplateTask();
                                               return db;
                                           });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "Unit",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *unit = new DatabaseUtility();
                                                  unit->setTable("unit");
                                                  unit->setViewTable("unit");
                                                  return unit;
                                              });

    qmlRegisterSingletonType<TaskTemplate>("io.qrop.components", 1, 0, "TaskTemplate",
                                           [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                               Q_UNUSED(engine)
                                               Q_UNUSED(scriptEngine)
                                               auto *tasktemplate = new TaskTemplate();
                                               return tasktemplate;
                                           });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "TaskType",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *tasktype = new DatabaseUtility();
                                                  tasktype->setTable("task_type");
                                                  tasktype->setViewTable("task_type");
                                                  return tasktype;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "TaskMethod",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *taskmethod = new DatabaseUtility();
                                                  taskmethod->setTable("task_method");
                                                  taskmethod->setViewTable("task_method");
                                                  return taskmethod;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "TaskImplement",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *taskimplement = new DatabaseUtility();
                                                  taskimplement->setTable("task_implement");
                                                  taskimplement->setViewTable("task_implement");
                                                  return taskimplement;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "Harvest",
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
    QApplication::setApplicationVersion(QROP_VERSION);
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

    //    QQmlFileSelector *selector = new QQmlFileSelector(&engine);
    const QUrl url("qrc:/qml/Qrop.qml");
    QObject::connect(
            &engine, &QQmlApplicationEngine::objectCreated, &app,
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

    return QApplication::exec();
}
