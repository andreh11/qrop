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
#include <QDoubleValidator>
#include <QFontDatabase>
#include <QHash>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QSqlDatabase>
#include <QSqlError>
#include <QStandardPaths>
#include <QTranslator>
#include <QVariantMap>
#include <QtQml>
//#include <QAndroidJniObject>
//#include <QtAndroid>

#include "db.h"
#include "keyword.h"
#include "mdate.h"
#include "planting.h"
#include "variety.h"

#include "cropmodel.h"
#include "familymodel.h"
#include "keywordmodel.h"
#include "notemodel.h"
#include "plantingmodel.h"
#include "rolemodel.h"
#include "seedcompanymodel.h"
#include "taskmodel.h"
#include "unitmodel.h"
#include "usermodel.h"
#include "varietymodel.h"


static QObject *plantingCallback(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    auto *planting = new Planting();
    return planting;
}

// A subclass of QDoubleValidator which always use "." as a decimalPoint.
class TextFieldDoubleValidator : public QDoubleValidator {
public:
    TextFieldDoubleValidator (QObject *parent = nullptr) : QDoubleValidator(parent) {}
    TextFieldDoubleValidator (double bottom, double top, int decimals, QObject * parent) :
    QDoubleValidator(bottom, top, decimals, parent) {}
    const QLocale locale;

    QValidator::State validate(QString &input, int &pos) const override {
        const QString decimalPoint = locale.decimalPoint();
        input.replace(".", decimalPoint);
        return QDoubleValidator::validate(input, pos);
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setApplicationName("Qrop");
    QCoreApplication::setOrganizationName("AH");
    QCoreApplication::setOrganizationDomain("io.qrop");

    QApplication app(argc, argv);
    app.setWindowIcon(QIcon("/home/ah/src/qrop/icon.png"));
    QTranslator translator;

    const QString &lang = QLocale::system().name();
    if (lang.contains("fr")) {
        translator.load(":/translations/fr.qm");
        app.installTranslator(&translator);
    }

    const int ret1 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Bold.ttf");
    const int ret2 = QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    const int ret3 = QFontDatabase::addApplicationFont(":/fonts/RobotoCondensed-Regular.ttf");
    const int ret4 = QFontDatabase::addApplicationFont(":/fonts/fa-regular-400.ttf"); // font-awesome
    const int ret5 = QFontDatabase::addApplicationFont(":/fonts/MaterialIcons-Regular.ttf");
    if (ret1 == -1 || ret2 == -1 || ret3 == -1 || ret4 == -1 || ret5 == -1)
        qWarning() << "[desktop main] Some custom fonts can't be loaded.";

    qmlRegisterType<CropModel>("io.croplan.components", 1, 0, "CropModel");
    qmlRegisterType<FamilyModel>("io.croplan.components", 1, 0, "FamilyModel");
    qmlRegisterType<KeywordModel>("io.croplan.components", 1, 0, "KeywordModel");
    qmlRegisterType<NoteModel>("io.croplan.components", 1, 0, "NoteModel");
    qmlRegisterType<PlantingModel>("io.croplan.components", 1, 0, "PlantingModel");
    qmlRegisterType<SeedCompanyModel>("io.croplan.components", 1, 0, "SeedCompanyModel");
    qmlRegisterType<TaskModel>("io.croplan.components", 1, 0, "TaskModel");
    qmlRegisterType<UnitModel>("io.croplan.components", 1, 0, "UnitModel");
    qmlRegisterType<VarietyModel>("io.croplan.components", 1, 0, "VarietyModel");
    qmlRegisterType<TextFieldDoubleValidator>("io.croplan.components", 1, 0, "TextFieldDoubleValidator");

//    qmlRegisterType<Planting>("io.croplan.components", 1, 0, "Planting");
    qmlRegisterSingletonType<Planting>("io.croplan.components", 1, 0, "Planting", plantingCallback);

    qmlRegisterSingletonType<DatabaseUtility>("io.croplan.components", 1, 0, "Crop",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject*
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        auto *crop = new DatabaseUtility();
        crop->setTable("crop");
        return crop;
    }
    );

    qmlRegisterSingletonType<Variety>("io.croplan.components", 1, 0, "Variety",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject*
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        auto *variety = new Variety();
        variety->setTable("variety");
        return variety;
    }
    );

    qmlRegisterSingletonType<DatabaseUtility>("io.croplan.components", 1, 0, "Unit",
                                              [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject*
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        auto *unit = new DatabaseUtility();
        unit->setTable("unit");
        return unit;
    }
    );

    qmlRegisterSingletonType<Keyword>("io.croplan.components", 1, 0, "Keyword", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject*
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        auto *keyword = new Keyword();
        return keyword;
    }
    );

    qmlRegisterSingletonType<MDate>("io.croplan.components", 1, 0, "NDate", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject*
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        auto *mdate = new MDate();
        return mdate;
    }
    );

//    deleteDatabase();
    connectToDatabase();
//    createDatabase();

//    QtAndroid::runOnAndroidThread([=]()
//    {
//        QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
//        window.callMethod<void>("addFlags", "(I)V", 0x80000000);
//        window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
//        window.callMethod<void>("setStatusBarColor", "(I)V", 0xff80CBC4); // Desired statusbar color
//    });

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
