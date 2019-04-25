/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

#include <QApplication>
#include <QQuickView>
#include <QQmlApplicationEngine>
#include <QDoubleValidator>
#include <QFontDatabase>
#include <QHash>
#include <QIcon>
#include <QSqlDatabase>
#include <QSqlError>
#include <QStandardPaths>
#include <QTranslator>
#include <QVariantMap>
#include <QFileSystemModel>
#include <QLibraryInfo>

#if defined(Q_OS_ANDROID)
#include <QAndroidJniObject>
#include <QtAndroid>
#endif

#include "buildinfo.h"
#include "db.h"
#include "family.h"
#include "keyword.h"
#include "location.h"
#include "mdate.h"
#include "note.h"
#include "pictureimageprovider.h"
#include "planting.h"
#include "print.h"
#include "task.h"
#include "tasktemplate.h"
#include "variety.h"
#include "version.h"

#include "cropmodel.h"
#include "familymodel.h"
#include "harvestmodel.h"
#include "keywordmodel.h"
#include "locationmodel.h"
#include "nametree.h"
#include "notemodel.h"
#include "plantingmodel.h"
#include "rolemodel.h"
#include "seedcompanymodel.h"
#include "seedlistmodel.h"
#include "taskimplementmodel.h"
#include "taskmethodmodel.h"
#include "taskmodel.h"
#include "tasktemplatemodel.h"
#include "tasktypemodel.h"
#include "templatetaskmodel.h"
#include "transplantlistmodel.h"
#include "treemodel.h"
#include "unitmodel.h"
#include "usermodel.h"
#include "varietymodel.h"

#include "qropdoublevalidator.h"

static QObject *plantingCallback(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    auto *planting = new Planting();
    return planting;
}

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
    qmlRegisterType<CropModel>("io.qrop.components", 1, 0, "CropModel");
    qmlRegisterType<FamilyModel>("io.qrop.components", 1, 0, "FamilyModel");
    qmlRegisterType<HarvestModel>("io.qrop.components", 1, 0, "HarvestModel");
    qmlRegisterType<KeywordModel>("io.qrop.components", 1, 0, "KeywordModel");
    qmlRegisterType<LocationModel>("io.qrop.components", 1, 0, "LocationModel");
    qmlRegisterType<NoteModel>("io.qrop.components", 1, 0, "NoteModel");
    qmlRegisterType<PlantingModel>("io.qrop.components", 1, 0, "PlantingModel");
    qmlRegisterType<QFileSystemModel>("io.qrop.components", 1, 0, "FileSystemModel");
    qmlRegisterType<QropDoubleValidator>("io.qrop.components", 1, 0, "QropDoubleValidator");
    qmlRegisterType<SeedCompanyModel>("io.qrop.components", 1, 0, "SeedCompanyModel");
    qmlRegisterType<SeedListModel>("io.qrop.components", 1, 0, "SeedListModel");
    qmlRegisterType<SqlTreeModel>("io.qrop.components", 1, 0, "SqlTreeModel");
    qmlRegisterType<TaskImplementModel>("io.qrop.components", 1, 0, "TaskImplementModel");
    qmlRegisterType<TaskMethodModel>("io.qrop.components", 1, 0, "TaskMethodModel");
    qmlRegisterType<TaskModel>("io.qrop.components", 1, 0, "TaskModel");
    qmlRegisterType<TemplateTaskModel>("io.qrop.components", 1, 0, "TemplateTaskModel");
    qmlRegisterType<TaskTemplateModel>("io.qrop.components", 1, 0, "TaskTemplateModel");
    qmlRegisterType<TaskTypeModel>("io.qrop.components", 1, 0, "TaskTypeModel");
    qmlRegisterType<TransplantListModel>("io.qrop.components", 1, 0, "TransplantListModel");
    qmlRegisterType<UnitModel>("io.qrop.components", 1, 0, "UnitModel");
    qmlRegisterType<VarietyModel>("io.qrop.components", 1, 0, "VarietyModel");

    qmlRegisterSingletonType<Planting>("io.qrop.components", 1, 0, "Planting", plantingCallback);

    qmlRegisterSingletonType<BuildInfo>("io.qrop.components", 1, 0, "BuildInfo",
                                        [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                            Q_UNUSED(engine)
                                            Q_UNUSED(scriptEngine)
                                            return new BuildInfo;
                                        });

    qmlRegisterSingletonType<Print>("io.qrop.components", 1, 0, "Print",
                                    [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                        Q_UNUSED(engine)
                                        Q_UNUSED(scriptEngine)
                                        auto *print = new Print();
                                        return print;
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
                                          variety->setTable("variety");
                                          return variety;
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

    qmlRegisterSingletonType<Task>("io.qrop.components", 1, 0, "TemplateTask",
                                   [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                       Q_UNUSED(engine)
                                       Q_UNUSED(scriptEngine)
                                       auto *task = new Task();
                                       task->setTable("task");
                                       task->setViewTable("template_task_view");
                                       return task;
                                   });

    qmlRegisterSingletonType<Location>("io.qrop.components", 1, 0, "Location",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                           Q_UNUSED(engine)
                                           Q_UNUSED(scriptEngine)
                                           auto *location = new Location();
                                           return location;
                                       });

    qmlRegisterSingletonType<MDate>("io.qrop.components", 1, 0, "MDate",
                                    [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                        Q_UNUSED(engine)
                                        Q_UNUSED(scriptEngine)
                                        auto *mdate = new MDate();
                                        return mdate;
                                    });

    qmlRegisterSingletonType<Database>("io.qrop.components", 1, 0, "Database",
                                       [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                           Q_UNUSED(engine)
                                           Q_UNUSED(scriptEngine)
                                           auto *db = new Database();
                                           return db;
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

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "Unit",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *unit = new DatabaseUtility();
                                                  unit->setTable("unit");
                                                  unit->setViewTable("unit");
                                                  return unit;
                                              });

    qmlRegisterSingletonType<DatabaseUtility>("io.qrop.components", 1, 0, "SeedCompany",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                                                  Q_UNUSED(engine)
                                                  Q_UNUSED(scriptEngine)
                                                  auto *seedCompany = new DatabaseUtility();
                                                  seedCompany->setTable("seed_company");
                                                  return seedCompany;
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

    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QApplication::setApplicationName("Qrop");
    QApplication::setOrganizationName("AH");
    QApplication::setOrganizationDomain("io.qrop");
    QApplication::setApplicationDisplayName("Qrop");
    QApplication::setApplicationVersion("0.1");
    QApplication::setWindowIcon(QIcon(":/icon.png"));

    QTranslator translator;
    QTranslator coreTranslator;
    const QString &lang = QLocale::system().name();
    if (lang.contains("fr")) {
        translator.load(":/translations/fr.qm");
        coreTranslator.load(":/core_translations/fr.qm");
        QApplication::installTranslator(&translator);
        QApplication::installTranslator(&coreTranslator);
    }

    registerFonts();
    registerTypes();

    Database db;
    Database::connectToDatabase();
    Database::migrationCheck();

#if defined(Q_OS_ANDROID)
    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window =
                QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
        window.callMethod<void>("addFlags", "(I)V", 0x80000000);
        window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
        window.callMethod<void>("setStatusBarColor", "(I)V", 0xff80CBC4); // Desired statusbar color
    });
#endif

    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/qml/main.qml"));
    engine.addImageProvider("pictures", new PictureImageProvider());
    Q_ASSERT(!engine.rootObjects().isEmpty());

    return QApplication::exec();
}
