#include "helpers.h"

#include <QtTest>
#include <QCoreApplication>

class tst_Helpers : public QObject
{
    Q_OBJECT

public:
    tst_Helpers();
    ~tst_Helpers();

private slots:
    void acronymize();
};

tst_Helpers::tst_Helpers() = default;

tst_Helpers::~tst_Helpers() = default;

void tst_Helpers::acronymize()
{
    QCOMPARE(QString("F"), Helpers::acronymize("F"));
    QCOMPARE(QString("F"), Helpers::acronymize("F "));
    QCOMPARE(QString("FA"), Helpers::acronymize(" Fa "));
    QCOMPARE("FA", Helpers::acronymize("Fabulous"));
    QCOMPARE("TDS", Helpers::acronymize("Travail du sol"));
    QCOMPARE("TDS", Helpers::acronymize(" Travail    du     sol"));
}

QTEST_APPLESS_MAIN(tst_Helpers)

#include "tst_helpers.moc"
