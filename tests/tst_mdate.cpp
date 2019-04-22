#include <QCoreApplication>
#include <QSqlDatabase>
#include <QDate>
#include <QPair>

#include "tst_mdate.h"
#include "mdate.h"

tst_MDate::tst_MDate() {}

tst_MDate::~tst_MDate() {}

void tst_MDate::dateFromWeekString()
{
    auto date = QDate::currentDate();
    int year = date.year();

    for (int week = 1; week <= 52; week++) {
        QCOMPARE(MDate::dateFromWeekString(QString::number(week)), MDate::mondayOfWeek(week, year));
        QCOMPARE(MDate::dateFromWeekString(QString("<") + QString::number(week)),
                 MDate::mondayOfWeek(week, year - 1));
        QCOMPARE(MDate::dateFromWeekString(QString(">") + QString::number(week)),
                 MDate::mondayOfWeek(week, year + 1));
    }
}

void tst_MDate::dateFromDateString()
{
    QCOMPARE(MDate::dateFromDateString("18/07"), QDate(QDate::currentDate().year(), 7, 18));
    QCOMPARE(MDate::dateFromDateString("18/07/2002"), QDate(2002, 7, 18));
}

void tst_MDate::firstMondayOfYear_data()
{
    QTest::addColumn<QDate>("actual");
    QTest::addColumn<QDate>("expected");

    QTest::newRow("") << MDate::firstMondayOfYear(2019) << QDate(2018, 12, 31);
    QTest::newRow("") << MDate::firstMondayOfYear(2018) << QDate(2018, 1, 1);
    QTest::newRow("") << MDate::firstMondayOfYear(2022) << QDate(2022, 1, 3);
}

void tst_MDate::firstMondayOfYear()
{
    QFETCH(QDate, actual);
    QFETCH(QDate, expected);

    QCOMPARE(actual, expected);
}

void tst_MDate::weekDates_data()
{
    QTest::addColumn<QList<QDate>>("actual");
    QTest::addColumn<QList<QDate>>("expected");

    QTest::newRow("") << MDate::weekDates(2, 2019)
                      << QList<QDate>({ QDate(2019, 1, 7), QDate(2019, 1, 13) });
    QTest::newRow("") << MDate::weekDates(33, 2019)
                      << QList<QDate>({ QDate(2019, 8, 12), QDate(2019, 8, 18) });
}

void tst_MDate::weekDates()
{
    QFETCH(QList<QDate>, actual);
    QFETCH(QList<QDate>, expected);

    QCOMPARE(actual, expected);
}

void tst_MDate::formatDate()
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

void tst_MDate::season()
{
    QCOMPARE(MDate::season(QDate(2016, 2, 3)), static_cast<int>(MDate::Season::Winter));
    QCOMPARE(MDate::season(QDate(2018, 5, 1)), static_cast<int>(MDate::Season::Spring));
    QCOMPARE(MDate::season(QDate(2019, 8, 15)), static_cast<int>(MDate::Season::Summer));
    QCOMPARE(MDate::season(QDate(2040, 11, 28)), static_cast<int>(MDate::Season::Fall));
    QCOMPARE(MDate::season(QDate(2055, 12, 2)), static_cast<int>(MDate::Season::Winter));
}

void tst_MDate::seasonYear()
{
    QCOMPARE(MDate::seasonYear(QDate(2003, 11, 29)), 2003);
    QCOMPARE(MDate::seasonYear(QDate(2003, 12, 1)), 2004);
}

QTEST_MAIN(tst_MDate)
