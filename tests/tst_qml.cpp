
#include <QtQuickTest>

#include <QObject>
#include <QQmlEngine>
#include <QLocale>

#include "qropdoublevalidator.h"


class Setup : public QObject
{
    Q_OBJECT

public:
    Setup() {}
    virtual ~Setup() {}

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        Q_UNUSED(engine);
        qmlRegisterType<QropDoubleValidator>("io.qrop.components", 1, 0, "QropDoubleValidator");
        QLocale::setDefault(QLocale("fr_FR.UTF-8")); // So tests don't depend on user locale
    }
};

QUICK_TEST_MAIN_WITH_SETUP(qml, Setup)

#include "tst_qml.moc"
