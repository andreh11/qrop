#include <QtTest>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QDate>
#include <QPair>

#include "db.h"
#include "mdate.h"

class tst_App : public QObject
{
    Q_OBJECT

public:
    tst_App();
    ~tst_App();

private slots:
    // Database
    void databasePath();
    void connectToDatabase();

    // MDate
    void dateFromWeekString();
    void dateFromDateString();
    void firstMondayOfYear_data();
    void firstMondayOfYear();
    void weekDates_data();
    void weekDates();
    void formatDate();
    void season();
    void seasonYear();
};

tst_App::tst_App() {}

tst_App::~tst_App() {}

/**
 * Database
 */

void tst_App::databasePath()
{
    Database db;
    QVERIFY(db.databasePath().contains("qrop.db"));
}

void tst_App::connectToDatabase()
{
    Database db;
    db.connectToDatabase();
    QVERIFY(QSqlDatabase::database().isValid());
}

/**
 * MDate
 */

void tst_App::dateFromWeekString()
{
    QDate date = QDate::currentDate();
    int year = date.year();

    for (int week = 1; week <= 52; week++) {
        QCOMPARE(MDate::dateFromWeekString(QString::number(week)), MDate::mondayOfWeek(week, year));
    }
}

void tst_App::dateFromDateString()
{
    QCOMPARE(MDate::dateFromDateString("18/07"), QDate(QDate::currentDate().year(), 7, 18));
    QCOMPARE(MDate::dateFromDateString("18/07/2002"), QDate(2002, 7, 18));
}

void tst_App::firstMondayOfYear_data()
{
    QTest::addColumn<QDate>("actual");
    QTest::addColumn<QDate>("expected");

    QTest::newRow("") << MDate::firstMondayOfYear(2019) << QDate(2018, 12, 31);
    QTest::newRow("") << MDate::firstMondayOfYear(2018) << QDate(2018, 1, 1);
    QTest::newRow("") << MDate::firstMondayOfYear(2022) << QDate(2022, 1, 3);
}

void tst_App::firstMondayOfYear()
{
    QFETCH(QDate, actual);
    QFETCH(QDate, expected);

    QCOMPARE(actual, expected);
}

void tst_App::weekDates_data()
{
    QTest::addColumn<QList<QDate>>("actual");
    QTest::addColumn<QList<QDate>>("expected");

    QTest::newRow("") << MDate::weekDates(2, 2019)
                      << QList<QDate>({ QDate(2019, 1, 7), QDate(2019, 1, 13) });
    QTest::newRow("") << MDate::weekDates(33, 2019)
                      << QList<QDate>({ QDate(2019, 8, 12), QDate(2019, 8, 18) });
}

void tst_App::weekDates()
{
    QFETCH(QList<QDate>, actual);
    QFETCH(QList<QDate>, expected);

    QCOMPARE(actual, expected);
}

void tst_App::formatDate()
{
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2019, "week", true), "7");
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2018, "week", true), ">7");
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2020, "week", true), "<7");
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2018, "week", false), "7");
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2020, "week", false), "7");

    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2019, "date", false), "11/02");
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2018, "date", false), "11/02/2019");
    QCOMPARE(MDate::formatDate(QDate(2019, 2, 11), 2020, "date", false), "11/02/2019");
}

void tst_App::season()
{
    QCOMPARE(MDate::season(QDate(2016, 2, 3)), static_cast<int>(Season::Winter));
    QCOMPARE(MDate::season(QDate(2018, 5, 1)), static_cast<int>(Season::Spring));
    QCOMPARE(MDate::season(QDate(2019, 8, 15)), static_cast<int>(Season::Summer));
    QCOMPARE(MDate::season(QDate(2040, 11, 28)), static_cast<int>(Season::Fall));
    QCOMPARE(MDate::season(QDate(2055, 12, 2)), static_cast<int>(Season::Winter));
}

void tst_App::seasonYear()
{
    QCOMPARE(MDate::seasonYear(QDate(2003, 11, 29)), 2003);
    QCOMPARE(MDate::seasonYear(QDate(2003, 12, 1)), 2004);
}

QTEST_MAIN(tst_App)

#include "tst_app.moc"
