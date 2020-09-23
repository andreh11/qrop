#include <QtTest>
#include <QCoreApplication>
#include <QDate>

#include "qrpdate.h"

class tst_QrpDate : public QObject
{
    Q_OBJECT

public:
    tst_QrpDate();
    ~tst_QrpDate();

private slots:
    void dateFromWeekString();
    void dateFromDateString();
    void firstMondayOfYear_data();
    void firstMondayOfYear();
    //    void weekDates_data();
    //    void weekDates();
    void formatDate();
    void season();
    void seasonYear();
};

tst_QrpDate::tst_QrpDate() = default;

tst_QrpDate::~tst_QrpDate() = default;

void tst_QrpDate::dateFromWeekString()
{
    auto date = QDate::currentDate();
    int year = date.year();

    for (int week = 1; week <= 52; week++) {
        QCOMPARE(QrpDate::dateFromWeekString(QString::number(week)), QrpDate::mondayOfWeek(week, year));
        QCOMPARE(QrpDate::dateFromWeekString(QString("<") + QString::number(week)),
                 QrpDate::mondayOfWeek(week, year - 1));
        QCOMPARE(QrpDate::dateFromWeekString(QString(">") + QString::number(week)),
                 QrpDate::mondayOfWeek(week, year + 1));
    }
}

void tst_QrpDate::dateFromDateString()
{
    QCOMPARE(QrpDate::dateFromDateString("18/07"), QDate(QDate::currentDate().year(), 7, 18));
    QCOMPARE(QrpDate::dateFromDateString("18/07/2002"), QDate(2002, 7, 18));
}

void tst_QrpDate::firstMondayOfYear_data()
{
    QTest::addColumn<QDate>("actual");
    QTest::addColumn<QDate>("expected");

    QTest::newRow("") << QrpDate::firstMondayOfYear(2019) << QDate(2018, 12, 31);
    QTest::newRow("") << QrpDate::firstMondayOfYear(2018) << QDate(2018, 1, 1);
    QTest::newRow("") << QrpDate::firstMondayOfYear(2022) << QDate(2022, 1, 3);
}

void tst_QrpDate::firstMondayOfYear()
{
    QFETCH(QDate, actual);
    QFETCH(QDate, expected);

    QCOMPARE(actual, expected);
}

// void tst_QrpDate::weekDates_data()
//{
//    QTest::addColumn<std::pair<QDate, QDate>>("actual");
//    QTest::addColumn<std::pair<QDate, QDate>>("expected");

//    QTest::newRow("") << QrpDate::weekDates(2, 2019)
//                      << std::pair<QDate, QDate>({ QDate(2019, 1, 7), QDate(2019, 1, 13) });
//    QTest::newRow("") << QrpDate::weekDates(33, 2019)
//                      << std::pair<QDate, QDate>({ QDate(2019, 8, 12), QDate(2019, 8, 18) });
//}

// void tst_QrpDate::weekDates()
//{
//    QFETCH(std::pair<QDate, QDate>, actual);
//    QFETCH(std::pair<QDate, QDate>, expected);

//    QCOMPARE(actual, expected);
//}

void tst_QrpDate::formatDate()
{
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2019, "week", true), "7");
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2018, "week", true), ">7");
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2020, "week", true), "<7");
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2018, "week", false), "7");
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2020, "week", false), "7");

    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2019, "date", false), "11/02");
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2018, "date", false), "11/02/2019");
    QCOMPARE(QrpDate::formatDate(QDate(2019, 2, 11), 2020, "date", false), "11/02/2019");
}

void tst_QrpDate::season()
{
    QCOMPARE(QrpDate::season(QDate(2016, 2, 3)), static_cast<int>(QrpDate::Season::Winter));
    QCOMPARE(QrpDate::season(QDate(2018, 5, 1)), static_cast<int>(QrpDate::Season::Spring));
    QCOMPARE(QrpDate::season(QDate(2019, 8, 15)), static_cast<int>(QrpDate::Season::Summer));
    QCOMPARE(QrpDate::season(QDate(2040, 11, 28)), static_cast<int>(QrpDate::Season::Fall));
    QCOMPARE(QrpDate::season(QDate(2055, 12, 2)), static_cast<int>(QrpDate::Season::Winter));
}

void tst_QrpDate::seasonYear()
{
    QCOMPARE(QrpDate::seasonYear(QDate(2003, 11, 29)), 2003);
    QCOMPARE(QrpDate::seasonYear(QDate(2003, 12, 1)), 2004);
}

QTEST_APPLESS_MAIN(tst_QrpDate)

#include "tst_qrpdate.moc"
